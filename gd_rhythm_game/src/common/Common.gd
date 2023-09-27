extends Node
# ======================================================
# 共通モジュール.
# ======================================================

# ------------------------------------------------------
# const.
# ------------------------------------------------------
## サウンドの最大数
const MAX_SOUND = 32
## サウンドのデフォルトのdB
const DEFAULT_DB = -6.0

enum eDefaultSe {
	KICK,
	SNARE,
	CH,
	OH,
}

const DEFAULT_SE_TBL = {
	"KICK": "res://assets/sound/kits/909_kick.wav",
	"SNARE": "res://assets/sound/kits/909_snare.wav",
	"CH": "res://assets/sound/kits/909_CH.wav",
	"OH": "res://assets/sound/kits/909_OH.wav",
}

# ------------------------------------------------------
# var.
# ------------------------------------------------------
var _snds:Array[AudioStreamPlayer] = []
var _layers:Array[CanvasLayer] = []

# ------------------------------------------------------
# public function.
# ------------------------------------------------------
## セットアップ.
func setup(root:Node2D, layers:Array[CanvasLayer]) -> void:
	_layers = layers
	# サウンドの生成.
	_create_snd(root)

## サウンドの事前読み込み.
func preload_snd(idx:int, path:String) -> void:
	if idx < 0 or MAX_SOUND <= idx:
		push_error("不正なサウンドIndex: %d"%idx)
		return	
	var snd:AudioStreamPlayer = _snds[idx]
	snd.stream = load(path)

## サウンドの再生.
func play_se(idx:int) -> void:
	if idx < 0 or MAX_SOUND <= idx:
		push_error("不正なサウンドIndex: %d"%idx)
		return	
	var snd = _snds[idx]
	snd.play()

## 名前指定で再生.
func play_se_by_name(name:String, idx:int) -> void:
	if not name in DEFAULT_SE_TBL:
		push_error("存在しないサウンド %s"%name)
		return
	preload_snd(idx, DEFAULT_SE_TBL[name])
	play_se(idx)

# ------------------------------------------------------
# private function.
# ------------------------------------------------------
## サウンドの生成.
func _create_snd(root:Node2D) -> void:
	# いったんクリア.
	_snds.clear()
	
	for i in range(MAX_SOUND):
		var snd = AudioStreamPlayer.new() # Audio生成.
		snd.volume_db = DEFAULT_DB # デフォルトのdBを設定.
		root.add_child(snd)
		_snds.append(snd)
