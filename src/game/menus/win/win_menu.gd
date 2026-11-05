class_name WinMenu
extends PanelContainer

@export var heading_label: Label
@export var level_label: Label
@export var level_value: Label
@export var time_label: Label
@export var time_value: Label
@export var lives_label: Label
@export var lives_value: Label
@export var stars_row: HBoxContainer
@export var level_row: HBoxContainer
@export var time_row: HBoxContainer
@export var lives_row: HBoxContainer
@export var play_next_button: CustomButton
@export var play_again_button: CustomButton
@export var exit_button: CustomButton


func _ready() -> void:
	_setup(GameManager.game_mode())
	hide()


func _setup(mode: GameManager.GameMode) -> void:
	heading_label.text = _heading_text(mode)
	level_label.text = "LEVEL"
	level_value.text = "000"
	time_label.text = "TIME TAKEN"
	time_value.text = "00:00"
	lives_label.text = "LIVES LEFT"
	lives_value.text = "0"

	match mode:
		GameManager.GameMode.QUICK:
			stars_row.hide()
			level_row.hide()


func update(time: float, lives: int, level_no: int = -1) -> void:
	time_value.text = Utils.format_time(time)
	lives_value.text = str(lives)
	
	if level_no != -1:
		level_value.text = "%03d" % level_no

	_update_stars(lives)


func _update_stars(stars: int) -> void:
	for i in range(stars_row.get_children().size()):
		var star_node = stars_row.get_child(i)
		if star_node is TextureRect:
			star_node.modulate = Palette.YELLOW if i < stars else Palette.SURFACE2


func _heading_text(mode: GameManager.GameMode) -> String:
	match mode:
		GameManager.GameMode.QUICK:
			return "YOU WIN!"
		GameManager.GameMode.LEVEL:
			return "LEVEL CLEAR!"
	return ""
