extends Node2D
# =============================================
# メインシーン.
# =============================================
# ---------------------------------------------
# const.
# ---------------------------------------------

# ---------------------------------------------
# onready.
# ---------------------------------------------
@onready var _label_now_time = $UILayer/NowTime
@onready var _audio = $Bgm

# ---------------------------------------------
# var.
# ---------------------------------------------
## 一時停止フラグ.
var _is_pause = false
## ノート音.
var _snd_note_list:Array[AudioStreamPlayer] = []
## 押しているノート番号.
var _pressed_notes:Array[bool] = []

# ---------------------------------------------
# private function.
# ---------------------------------------------

## 開始.
func _ready() -> void:
	TimeMgr.setup(_audio)
	for kit in [
			"res://assets/sound/kits/909_kick.wav"
			,"res://assets/sound/kits/909_snare.wav"
			,"res://assets/sound/kits/909_CH.wav"
			,"res://assets/sound/kits/909_OH.wav"]:
		var audio = AudioStreamPlayer.new()
		audio.stream = load(kit)
		_snd_note_list.append(audio)
		add_child(audio) # 再生できるようにする.

	for i in range(TimeMgr.MAX_NOTES):
		_pressed_notes.append(false)

## 更新.
func _physics_process(delta: float) -> void:
	if _is_pause:
		# ポーズ中.
		delta = 0.0
		
	for i in range(4):
		var action = "note_%d"%i
		_pressed_notes[i] = false
		if Input.is_action_just_pressed(action):
			_snd_note_list[i].play()
		if Input.is_action_pressed(action):
			# 押している鍵盤.
			_pressed_notes[i] = true
	
	# 時間の更新.
	TimeMgr.update(delta)
	
	# 背景の描画.
	queue_redraw()
	
	# UIの更新.
	_update_ui()
	
	# デバッグの更新.
	_update_debug()
	
## 更新 > UI.
func _update_ui() -> void:
	_label_now_time.text = TimeMgr.time_to_str(TimeMgr.get_now_time())
	_label_now_time.text += "/" + TimeMgr.time_to_str(TimeMgr.get_total_time())
	_label_now_time.text += " %dBPM"%int(TimeMgr.get_bpm())

## 更新 > デバッグ.
func _update_debug() -> void:
	if Input.is_action_just_pressed("pause"):
		# ポーズフラグをトグル.
		_is_pause = !_is_pause
	if Input.is_action_just_pressed("reset"):
		# リセット.
		get_tree().change_scene_to_file("res://Main.tscn")

## 描画.
func _draw() -> void:
	TimeMgr.draw_score(self)
	var idx = 0
	for pressed in _pressed_notes:
		if pressed:
			TimeMgr.draw_pressed_note(self, idx)
		idx += 1
