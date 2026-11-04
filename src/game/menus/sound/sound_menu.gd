class_name SoundMenu
extends Control


@export_group("Nodes")
@export var back_button_1: CustomIconButton
@export var music_control: CustomSpinbox
@export var sound_control: CustomSpinbox
@export var sfx_control: CustomSpinbox
@export var mute_control: CustomSwitchButton
@export var back_button_2: CustomButton


func _ready() -> void:
	back_button_1.pressed.connect(_exit)
	back_button_2.pressed.connect(_exit)

	music_control.value = int(SoundManager.get_music_volume())
	sound_control.value = int(SoundManager.get_sound_volume())
	sfx_control.value = int(SoundManager.get_sfx_volume())
	
	music_control.value_changed.connect(_changed_music_volume)
	sound_control.value_changed.connect(_changed_sound_volume)
	sfx_control.value_changed.connect(_changed_sfx_volume)
	
	hide()


func _changed_music_volume(value: int) -> void:
	SoundManager.set_music_volume(float(value))


func _changed_sound_volume(value: int) -> void:
	SoundManager.set_sound_volume(float(value))


func _changed_sfx_volume(value: int) -> void:
	SoundManager.set_sfx_volume(float(value))


func _exit() -> void:
	hide()
