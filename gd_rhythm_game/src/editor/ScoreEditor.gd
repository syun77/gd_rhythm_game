extends Node2D
# =============================================
# 譜面エディタ.
# =============================================
# ---------------------------------------------
# const.
# ---------------------------------------------
const OFS_X = 32
const OFS_Y = 0
const SCORE_WIDTH = 320
const SCORE_HEIGHT = 640

# ---------------------------------------------
# onready.
# ---------------------------------------------
@onready var _label_base_time = $UILayer/BaseTime

# ---------------------------------------------
# var.
# ---------------------------------------------
var _base_time = 0.0
var _beat_h = 32.0 # 1拍あたりのノートの高さ.
var _bpm = 130.0
var _total_time = 60 * 3
var _bps = 1.0

# ---------------------------------------------
# private function.
# ---------------------------------------------
## 開始.
func _ready() -> void:
	# bpsを計算.
	_bps = 60.0 / _bpm

## 更新.
func _process(delta: float) -> void:
	# UIの更新.
	_update_ui()
	
	queue_redraw()

## UIの更新.
func _update_ui() -> void:
	_label_base_time.text = TimeMgr.time_to_str(_base_time)

## 描画.
func _draw() -> void:
	# 譜面グリッドの描画.
	_draw_grid_vertical() # 縦
	_draw_grid_horizontal() # 横.

## 時間に対応するスクリーン座標(Y).
func _time_to_screen_y(t:float) -> float:
	var d = t - _base_time
	return SCORE_HEIGHT - (d * _beat_h)

## 譜面グリッドの描画(縦線).
func _draw_grid_vertical() -> void:
	var p1 = Vector2(0, OFS_Y)
	var p2 = Vector2(0, OFS_Y + SCORE_HEIGHT)
	var dx = SCORE_WIDTH / TimeMgr.MAX_NOTES
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
		draw_line(p1, p2, Color.GRAY)
		t += _bps

# ---------------------------------------------
# signal.
# ---------------------------------------------

## 時間スライダーの値が変化した.
func _on_time_slider_value_changed(value: float) -> void:
	_base_time = value
