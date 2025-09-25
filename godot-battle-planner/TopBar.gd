extends HBoxContainer

# Top bar manager, signal linked to all setting buttons in toolbar
signal request_settings
signal request_help
signal request_save
signal request_load
signal request_export

#signal connection to setting buttons
func _ready() -> void:
	$BtnSettings.pressed.connect(func(): emit_signal("request_settings"))
	$BtnHelp.pressed.connect(func(): emit_signal("request_help"))
	$BtnSave.pressed.connect(func(): emit_signal("request_save"))
	$BtnLoad.pressed.connect(func(): emit_signal("request_load"))
	$BtnExport.pressed.connect(func(): emit_signal("request_export"))
	
func _on_SettingsButton_pressed() -> void:
	emit_signal("request_settings")

func _on_HelpButton_pressed() -> void:
	emit_signal("request_help")

func _on_SaveButton_pressed() -> void:
	emit_signal("request_save")

func _on_LoadButton_pressed() -> void:
	emit_signal("request_load")

func _on_ExportButton_pressed() -> void:
	emit_signal("request_export")
