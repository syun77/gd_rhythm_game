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
static func setup(audio:AudioStreamPlayer, bpm:float) -> void:
	_audio = audio
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

## BPMを取得する.
static func get_bpm() -> float:
	return _bpm

## 拍数を取得する.
static func get_bar_beats() -> float:
	return _bar_beats

## 1拍に対応する時間を取得する.
static func get_beat_per_sec() -> float:
	# 60sec ÷ BPM ÷ 拍数.
	return 60.0 / _bpm# / get_bar_beats()

## 基準座標.
static func get_now_screen_ofs_y() -> float:
	return (SCORE_HEIGHT * OFS_NOW_TIME)
static func get_now_screen_y() -> float:
	return SCORE_OFS_Y + get_now_screen_ofs_y()
	
## ノートの時間に対応するスクリーン座標(Y)を取得.
static func time_to_screen_y(time:float) -> float:
	var d = time - get_now_time()
	var ofs_y = get_now_screen_ofs_y()
	var base_y = get_now_screen_y()
	return base_y - (SCORE_HEIGHT * d / _top_to_now_time)
	
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
	
	# 現在の時間のラインを描画.
	var now = get_now_time()
	var now_y = get_now_screen_y()
	var p1 = Vector2(SCORE_OFS_X, now_y)
	var p2 = Vector2(SCORE_OFS_X + SCORE_WIDTH, now_y)
	node.draw_line(p1, p2, Color.WHITE)
	
	# ビートの区切り線の表示.
	for i in range(int(get_bar_beats()) * 3):
		var bps = get_beat_per_sec()
		var t = now - fmod(now, bps) + bps * (i + 1)
		var y = time_to_screen_y(t)
		p1.y = y
		p2.y = y
		node.draw_line(p1, p2, Color.GRAY)