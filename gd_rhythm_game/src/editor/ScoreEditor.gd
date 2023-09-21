extends Node2D
# =============================================
# 譜面エディタ.
# =============================================
# ---------------------------------------------
# const.
# ---------------------------------------------
const PATH_SCORE = "res://assets/scores/1.txt"
const OFS_X = 64
const OFS_Y = 0
const SCORE_WIDTH = 320
const SCORE_HEIGHT = 600
const SCORE_UNIT = 32 # 32分音符を最小単位とする.

# ---------------------------------------------
# onready.
# ---------------------------------------------
@onready var _label_base_time = $UILayer/BaseTime
@onready var _label_debug = $UILayer/LabelDebug

# ---------------------------------------------
# var.
# ---------------------------------------------
## 基準
var _base_time = 0.0 # 時間.
var _base_bar = 0.0 # 拍

var _beat_h = 32.0 # 1拍あたりのノートの高さ.
var _bpm = 130.0
var _total_time = 60 * 3
var _bps = 1.0
var _bar_beats = 4 # 4/4拍子.
var _score_data = {}
var _anim_timer = 0.0

# ---------------------------------------------
# private function.
# ---------------------------------------------
## 開始.
func _ready() -> void:
	# bpsを計算.
	_bps = 60.0 / _bpm
	
	for i in range(TimeMgr.MAX_NOTES):
		# ノート番号ごとに管理する.
		var notes = {}
		_score_data[i] = notes

## 更新.
func _process(delta: float) -> void:
	_anim_timer += delta
	
	_update_click()
	
	# UIの更新.
	_update_ui()
	
	# _draw()を呼び出す.
	queue_redraw()

## クリック処理.
func _update_click() -> void:
	if Input.is_action_just_pressed("click") == false:
		return
		
	# クリックしたのでノート配置 or 削除.
	var mouse = get_global_mouse_position()
	var pos = _screen_to_score_pos(mouse)
	if pos.x < 0:
		return # 譜面の範囲外.
	
	# 配置済みなら削除。そうでなければ配置.
	var b = _get_note(pos.x, pos.y)
	_set_note(pos.x, pos.y, !b)
	
	
## 指定の位置にノートが配置されているかどうか.
func _get_note(note_idx:int, pos:int) -> bool:
	if note_idx < 0 or TimeMgr.MAX_NOTES <= note_idx:
		return false # 領域外.
	if pos < 0:
		return false # 領域外.
	
	var notes = _score_data[note_idx]
	if pos in notes:
		return true
	return false

func _set_note(note_idx:int, pos:int, b:bool) -> void:
	if note_idx < 0 or TimeMgr.MAX_NOTES <= note_idx:
		return # 領域外.
	if pos < 0:
		return # 領域外.
	
	var notes = _score_data[note_idx]
	if b:
		# 配置
		notes[pos] = true
	else:
		# 削除.
		notes.erase(pos)

## UIの更新.
func _update_ui() -> void:
	_label_base_time.text = TimeMgr.time_to_str(_base_time)
	var pos = get_global_mouse_position()
	var p = _screen_to_score_pos(pos)
	_label_debug.text = "%d,%d"%[p.x, p.y]

## 描画.
func _draw() -> void:
	# 譜面グリッドの描画.
	_draw_grid_vertical() # 縦
	_draw_grid_horizontal() # 横.
	
	# ノートの描画.
	_draw_notes()
	
	# カーソルの描画.
	_draw_cursor()

## 時間に対応するスクリーン座標(Y).
func _time_to_screen_y(t:float) -> float:
	var d = t - _base_time
	return OFS_Y + SCORE_HEIGHT - (d * _beat_h)

## 小節と小節内の位置からトータルの単位を返す.
func _barpos_to_total_unit(bar:int, pos:int) -> int:
	return (bar * SCORE_UNIT) + pos

## スクリーン座標に対応する譜面の位置を取得する.
func _screen_to_score_pos(pos:Vector2) -> Vector2i:
	var dx = pos.x - OFS_X
	var dy = pos.y - OFS_Y
	if dx < 0 or SCORE_WIDTH < dx:
		return Vector2i.ONE * -1
	if dy < 0 or SCORE_HEIGHT < dy:
		return Vector2i.ONE * -1
	
	# スクロールを考慮.
	dy -= (_base_bar * _get_note_height())
	# 逆順になる
	dy = SCORE_HEIGHT - dy
		
	var ret = Vector2i()
	ret.x = int(dx / _get_note_width())
	ret.y = int(dy / _get_note_height())
	return ret

## 譜面の位置に対応する座標を取得する.
func _score_pos_to_screen(note_idx:int, pos:int) -> Vector2i:
	var ret = Vector2i()
	ret.x = OFS_X + (note_idx * _get_note_width())
	ret.y = OFS_Y
	# スクロールを考慮.
	var pos2 = (pos - _base_bar)
	# 逆順になる.
	ret.y += SCORE_HEIGHT - (pos2 * _get_note_height())
	return ret

## ノート1つあたりの幅.
func _get_note_width() -> float:
	return SCORE_WIDTH / TimeMgr.MAX_NOTES
## ノート1つあたりの高さ.
func _get_note_height() -> float:
	return _bps * _beat_h


## 譜面グリッドの描画(縦線).
func _draw_grid_vertical() -> void:
	var p1 = Vector2(0, OFS_Y)
	var p2 = Vector2(0, OFS_Y + SCORE_HEIGHT)
	var dx = _get_note_width()
	for i in range(TimeMgr.MAX_NOTES + 1):
		var px = OFS_X + (dx * i)
		p1.x = px
		p2.x = px
		draw_line(p1, p2, Color.WHITE)

## 譜面グリッドの描画(横線).
func _draw_grid_horizontal() -> void:
	var p1 = Vector2(OFS_X, 0)
	var p2 = Vector2(OFS_X + SCORE_WIDTH, 0)
	var t:float = _base_time
	for i in range(64):
		var py = _time_to_screen_y(t)
		p1.y = py
		p2.y = py
		var color = Color.GRAY
		var beats = int(t / _bps)
		if beats%(_bar_beats*4) == 0:
			# 1小節.
			color.a = 1.0
		elif beats%_bar_beats == 0:
			# 1拍目.
			color.a = 0.6
		else:
			# それ以外.
			color.a = 0.3
			
		draw_line(p1, p2, color)
		t += _bps

## ノートの描画.
func _draw_notes() -> void:
	var rect = Rect2(0, 0, _get_note_width(), _get_note_height())
	for note_idx in _score_data.keys():
		var notes = _score_data[note_idx]
		for pos in notes.keys():
			var p = _score_pos_to_screen(note_idx, pos)
			# 下から描画しているので1つずれる.
			p.y -= _get_note_height()
			rect.position.x = p.x
			rect.position.y = p.y
			var color = Color.WHITE
			color.a = 0.5
			draw_rect(rect, color)

## カーソルの描画.
func _draw_cursor() -> void:
	var mouse = get_global_mouse_position()
	var pos = _screen_to_score_pos(mouse)
	if pos.x < 0:
		return # 譜面の範囲外.
	
	var p = _score_pos_to_screen(pos.x, pos.y)
	var rect = Rect2(0, 0, _get_note_width(), _get_note_height())
	# 下から描画しているので1つずれる.
	p.y -= _get_note_height()
	rect.position.x = p.x
	rect.position.y = p.y
	var color = Color.YELLOW
	color.a = 0.8 + (0.2 * sin(_anim_timer * 4))
	draw_rect(rect, color, false)
			
## 譜面データのパスを取得する.
func _get_score_path() -> String:
	return PATH_SCORE

## 時間を拍に変更する.
func _time_to_bar(time:float) -> float:
	return time / _bps

# ---------------------------------------------
# signal.
# ---------------------------------------------

## 時間スライダーの値が変化した.
func _on_time_slider_value_changed(value: float) -> void:
	_base_time = value
	# 正規化.
	_base_time -= fmod(_base_time, _bps)
	_base_bar = _time_to_bar(_base_time)

## SAVEボタンを押した.
func _on_button_save_pressed() -> void:
	var file = FileAccess.open(PATH_SCORE, FileAccess.WRITE)
	var data = {}
	data["bpm"] = _bpm
	data["score"] = _score_data
	# 文字列に変換.
	var s = var_to_str(data)
	print(s)
	file.store_string(s)
	file.close()

## LOADボタンを押した.
func _on_button_load_pressed() -> void:
	var path = _get_score_path()
	if FileAccess.file_exists(path) == false:
		push_warning("%sは存在しません"%path)
		return
		
	var file = FileAccess.open(PATH_SCORE, FileAccess.READ)
	var s = file.get_as_text()
	file.close()
	# 文字列から辞書型に変換.
	var data = str_to_var(s)
	_bpm = float(data["bpm"])
	_score_data = data["score"]
