extends Control

var last_focus = null
var max_value = 100.0

func _ready():
	$Node2D/VBoxContainer/MasterVolumeSlider.value = SettingsManager.volumes["Master"] * max_value
	$Node2D/VBoxContainer/MusicVolumeSlider.value = SettingsManager.volumes["Music"] * max_value
	$Node2D/VBoxContainer/SfxVolumeSlider.value = SettingsManager.volumes["Sfx"] * max_value
	$Node2D/VBoxContainer/FullScreen/CheckButton.pressed = SettingsManager.is_fullscreen
	last_focus = get_focus_owner()
	$Node2D/VBoxContainer/MasterVolumeSlider/HSlider.grab_focus()
	if OS.get_name() == "Web":
		$Node2D/VBoxContainer/FullScreen.hide()

func _on_master_volume_slider_value_changed(value):
	SettingsManager.set_bus_volume("Master", value/max_value)
	$TestSfx.play()

func _on_music_volume_slider_value_changed(value):
	SettingsManager.set_bus_volume("Music", value/max_value)

func _on_sfx_volume_slider_value_changed(value):
	SettingsManager.set_bus_volume("Sfx", value/max_value)
	$TestSfx.play()

func _on_back_button_pressed():
	UiSoundManager.play_button()
	if last_focus != null:
		last_focus.grab_focus()
	SettingsManager.save_settings()
	get_parent().remove_child(self)

func _on_check_button_toggled(button_pressed):
	SettingsManager.set_fullscreen(button_pressed)

