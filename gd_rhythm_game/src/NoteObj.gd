extends Node2D
# =============================================
# ノートオブジェクト.
# =============================================
class_name NoteObj

# ---------------------------------------------
# onready.
# ---------------------------------------------
@onready var _spr = $Sprite

# ---------------------------------------------
# var.
# ---------------------------------------------
## note on となる時間.
var _note_on_time = 0.0

# ---------------------------------------------
# public functions.
# ---------------------------------------------

# ---------------------------------------------
# private functions.
# ---------------------------------------------
