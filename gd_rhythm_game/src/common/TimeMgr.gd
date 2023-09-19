extends Node
# =============================================
# 時間管理オブジェクト.
# @note staticオブジェクト
#
# +----ofs----+ <- screen top
# |           |
# |           |
# |           |
# |           |
# |           |
# |           |
# +----now----+ <- just time
# |           |
# +-----------+
# =============================================
class_name TimeMgr

# ---------------------------------------------
# const.
# ---------------------------------------------
## 譜面の開始座標.
const SCORE_OFS_X = 0
const SCORE_OFS_Y = 0
## 譜面のサイズ.
const SCORE_WIDTH = 480.0
const SCORE_HEIGHT = 600.0
## 現在の時間へのオフセット割合.
const OFS_NOW_TIME = 0.9
## ノートの最大数.
const MAX_NOTES = 7 # 7鍵盤.

# ---------------------------------------------
# var.
# ---------------------------------------------
## AudioStreamPlayer
static var _audio:AudioStreamPlayer
## BPM.
static var _bpm = 130.0
## 曲のトータル時間.
static var _total_time = 0.0
## トップから現在の時間までの高さ.
static var _top_to_now_time = 3.0
## 拍.
static var _bar_beats = 4 # 4/4拍子.

# ---------------------------------------------
# public functions.
# ---------------------------------------------
## セットアップ.
static func setup(audio:AudioStreamPlayer) -> void:
	_audio = audio
	# MP3ファイル前提.
	var stream:AudioStreamMP3 = _audio.stream
	_bpm = stream.bpm
	_bar_beats = stream.bar_beats
	# トータル再生時間.
	_total_time = 60.0 * stream.beat_count / _bpm

## 更新.
static func update(delta: float) -> void:
	pass

## 現在の時間を取得する.
static func get_now_time() -> float:
	return _audio.get_playback_position()

## 現在の拍数を取得する.
static func get_now_beat_cnt() -> int:
	# 時間 ÷ bps
	return int(get_now_time() / get_beat_per_sec())

## 表示開始となる時間.
static func get_starting_display_time() -> float:
	var now = get_now_time() # 現在時間.
	var t = now + _top_to_now_time # 一番上となる時間.
	return t

## BPMを取得する.
static func get_bpm() -> float:
	return _bpm

## 拍数を取得する.
static func get_bar_beats() -> float:
	return _bar_beats

## 1拍に対応する時間を取得する (bps[beat/sec]).
static func get_beat_per_sec() -> float:
	# 60sec ÷ BPM.
	return 60.0 / _bpm

## 基準座標.
static func get_now_screen_ofs_y() -> float:
	# "スコアの高さ x 現在時間の割合" が現在時間の高さ.
	return (SCORE_HEIGHT * OFS_NOW_TIME)
static func get_now_screen_y() -> float:
	return SCORE_OFS_Y + get_now_screen_ofs_y()
	
## ノートの時間に対応するスクリーン座標(Y)を取得.
static func time_to_screen_y(time:float) -> float:
	var d = time - get_now_time()
	var ofs_y = get_now_screen_ofs_y()
	var base_y = get_now_screen_y()
	return base_y - (SCORE_HEIGHT * d / _top_to_now_time)

## ノート番号に対応するスクリーン座標(X)を取得.
static func get_screen_note_x(note_idx:int) -> float:
	if note_idx < 0 or MAX_NOTES <= note_idx:
		# 領域外の場合はいったん0を返す.
		return 0
	
	var base_x = SCORE_OFS_X
	var dx = get_note_width()
	return base_x + (dx * note_idx)
	
## ノート1つあたりの幅を取得する.
static func get_note_width() -> float:
	return SCORE_WIDTH / MAX_NOTES

## 曲のトータル時間を取得する.
static func get_total_time() -> float:
	return _total_time

## 時間に対応する文字列表現を取得する.
static func time_to_str(time) -> String:
	var min = int(time / 60)
	var sec = int(time) % 60
	var msec = int(time * 1000) % 1000
	return "%02d:%02d.%03d"%[min, sec, msec]

## 譜面の描画.
static func draw_score(node:Node2D) -> void:
	# 背景の描画.
	var rect = Rect2(SCORE_OFS_X, SCORE_OFS_Y, SCORE_WIDTH, SCORE_HEIGHT)
	node.draw_rect(rect, Color.DIM_GRAY)
	
	# ノートの区切り線を描画.
	_draw_note_line(node)
	
	# 現在の時間のラインを描画.
	var now_y = get_now_screen_y()
	var p1 = Vector2(SCORE_OFS_X, now_y)
	var p2 = Vector2(SCORE_OFS_X + SCORE_WIDTH, now_y)
	node.draw_line(p1, p2, Color.WHITE)
	
	# ビートの区切り線の表示.
	_draw_beat_lines(node)

## 押しているノートの表示.
static func draw_pressed_note(node:Node2D, note_idx:int) -> void:
	# ノートのX座標(左)を取得する.
	var x = get_screen_note_x(note_idx)
	var y = SCORE_OFS_Y
	var w = get_note_width()
	var h = SCORE_HEIGHT
	var rect = Rect2(x, y, w, h)
	var color = Color.RED
	color.a = 0.2
	node.draw_rect(rect, color)

# ---------------------------------------------
# private functions.
# ---------------------------------------------

## ノートの区切り線を描画.
static func _draw_note_line(node:Node2D) -> void:
	for i in range(MAX_NOTES):
		var p1 = Vector2(get_screen_note_x(i), SCORE_OFS_Y)
		var p2 = p1 + Vector2(0, SCORE_HEIGHT)
		var color = Color.DARK_GRAY
		color.a = 0.2
		node.draw_line(p1, p2, color)

## ビートの区切り線の表示.
static func _draw_beat_lines(node:Node2D) -> void:
	# 現在の時間.
	var now = get_now_time()
	# 現在の拍数.
	var now_cnt = get_now_beat_cnt()

	# 線分のX値だけ設定.
	var p1 = Vector2(SCORE_OFS_X, 0)
	var p2 = Vector2(SCORE_OFS_X + SCORE_WIDTH, 0)

	# 1拍あたりの秒.
	var bps = get_beat_per_sec()
	# 1拍ごとに点滅.
	var blink_rate = 1 - fmod(now, bps) / bps
	# now_normal = 現在時間 - 拍の余り = 現在時間を1拍ごとに丸めた時間
	var now_normal = now - fmod(now, bps)
	
	for i in range(int(get_bar_beats()) * 3):
		# t = now_normal + (1拍あたりの秒 * (i + 1つずらす))
		var t = now_normal + bps * (i + 1)
		
		# 線分のYを設定.
		var y = time_to_screen_y(t)
		p1.y = y
		p2.y = y
		
		# 基本の色を設定
		var color = Color.GRAY
		color.a = 0.2
		# 点滅の色をブレンド.
		color = color.lerp(Color.YELLOW, 0.5 * blink_rate)
		if (now_cnt + i + 1)%int(get_bar_beats()) == 0:
			# 1拍目の色を強調する.
			color.a = 1
		# 描画.
		node.draw_line(p1, p2, color)
