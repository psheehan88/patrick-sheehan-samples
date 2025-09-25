extends Node
#setting and current config files to be loaded on opening application...
# account for first time run
const PATH := "user://settings.cfg"
var cfg := ConfigFile.new()

var ui_scale := 1.0 : set = set_ui_scale
var player_panel_collapsed := false
var show_grid := true : set = set_show_grid
var grid_opacity := 0.65 : set = set_grid_opacity
var snap_to_grid := true : set = set_snap
var first_run := true
var theme := "system"
var language := "en"
var performance_mode := false

func _ready() -> void:
	load_settings()

#Load current settings last saved by user
func load_settings() -> void:
	var err := cfg.load(PATH)
	if err != OK:
		save_settings() # write defaults
		return
	ui_scale = cfg.get_value("ui", "scale", ui_scale)
	player_panel_collapsed = cfg.get_value("ui", "player_panel_collapsed", player_panel_collapsed)
	show_grid = cfg.get_value("map", "show_grid", show_grid)
	grid_opacity = cfg.get_value("map", "grid_opacity", grid_opacity)
	snap_to_grid = cfg.get_value("map", "snap_to_grid", snap_to_grid)
	first_run = cfg.get_value("app", "first_run", first_run)
	theme = cfg.get_value("app", "theme", theme)
	language = cfg.get_value("app", "language", language)
	performance_mode = cfg.get_value("app", "performance_mode", performance_mode)

func save_settings() -> void:
	cfg.set_value("ui", "scale", ui_scale)
	cfg.set_value("ui", "player_panel_collapsed", player_panel_collapsed)
	cfg.set_value("map", "show_grid", show_grid)
	cfg.set_value("map", "grid_opacity", grid_opacity)
	cfg.set_value("map", "snap_to_grid", snap_to_grid)
	cfg.set_value("app", "first_run", first_run)
	cfg.set_value("app", "theme", theme)
	cfg.set_value("app", "language", language)
	cfg.set_value("app", "performance_mode", performance_mode)
	cfg.save(PATH)

func set_show_grid(v: bool) -> void:
	show_grid = v
	EventBus.emit_signal("grid_visibility_changed", v)
	save_settings()

func set_grid_opacity(v: float) -> void:
	grid_opacity = clampf(v, 0.0, 1.0)
	EventBus.emit_signal("grid_opacity_changed", grid_opacity)
	save_settings()

func set_snap(v: bool) -> void:
	snap_to_grid = v
	EventBus.emit_signal("snap_toggled", v)
	save_settings()

func set_ui_scale(v: float) -> void:
	ui_scale = clampf(v, 0.75, 1.5)
	EventBus.emit_signal("ui_scale_changed", ui_scale)
	save_settings()
