class_name SoundMenu
extends Control


@export_group("Nodes")
@export var back_button: CustomIconButton
@export var music_control: CustomSpinbox
@export var sound_control: CustomSpinbox
@export var sfx_control: CustomSpinbox
@export var mute_control: CustomSwitchButton
@export var exit_button: CustomButton

var _hidden_siblings: Array[Control] = []
var _previous_focus: Control = null


func _ready() -> void:
	back_button.pressed.connect(_exit)
	exit_button.pressed.connect(_exit)

	music_control.value = int(SoundManager.get_music_volume())
	sound_control.value = int(SoundManager.get_sound_volume())
	sfx_control.value = int(SoundManager.get_sfx_volume())
	mute_control.value = SoundManager.is_mute()
	
	music_control.value_changed.connect(_changed_music_volume)
	sound_control.value_changed.connect(_changed_sound_volume)
	sfx_control.value_changed.connect(_changed_sfx_volume)
	
	mute_control.value_changed.connect(_changed_mute)

	hide()


func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED and is_inside_tree() and is_node_ready():
		if visible:
			_isolate_menu()
		else:
			_restore_siblings()


func _isolate_menu() -> void:
	_previous_focus = get_viewport().gui_get_focus_owner()
	_hidden_siblings.clear()
	
	var parent_node := get_parent()
	if parent_node:
		for child in parent_node.get_children():
			if child != self and child is Control and child.visible:
				_hidden_siblings.append(child)
				child.visible = false
	
	if back_button and back_button.is_inside_tree():
		back_button.grab_focus()


func _restore_siblings() -> void:
	for child in _hidden_siblings:
		if is_instance_valid(child):
			child.visible = true
	_hidden_siblings.clear()
	
	if _previous_focus and is_instance_valid(_previous_focus) and _previous_focus.is_visible_in_tree():
		_previous_focus.grab_focus()



func _changed_music_volume(value: int) -> void:
	SoundManager.set_music_volume(float(value))


func _changed_sound_volume(value: int) -> void:
	SoundManager.set_sound_volume(float(value))


func _changed_sfx_volume(value: int) -> void:
	SoundManager.set_sfx_volume(float(value))


func _changed_mute(is_on: bool) -> void:
	SoundManager.update_mute(is_on)


func _exit() -> void:
	hide()
