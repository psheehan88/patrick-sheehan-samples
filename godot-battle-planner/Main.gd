extends Node2D

const STATIC_ROOT := "$EXPORT_file_loc"

#Main core logic for file save, load, export, UI structure and grid snapping

@onready var topbar:        = $UI/TopBar
@onready var settings_menu:  = $UI/SettingsMenu
@onready var help_popup:     = $UI/HelpPopup
@onready var ui_layer:       = $UI
@onready var player_panel:  = $UI/PlayerPanel

# keep_factory file path
@onready var map_container: Node     = $MapContainer
@onready var keep_factory: Node      = $MapContainer/KeepFactory   

func _enter_tree() -> void:
	print("[Main] _enter_tree path=", get_path())

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		print("[Main] NOTIFICATION_READY path=", get_path())

func _ready() -> void:
	print("[Main] _ready path=", get_path())
	print("[Main] nodes:",
		"\n  topbar=", get_node_or_null("UI/TopBar"),
		"\n  player_panel=", get_node_or_null("UI/PlayerPanel"),
		"\n  map_container=", get_node_or_null("MapContainer"),
		"\n  keep_factory=", get_node_or_null("MapContainer/KeepFactory"))
	_wire_ui()
	_show_first_run_help()

func _data_path(subdir: String) -> String:
	var dir := "%s/%s" % [STATIC_ROOT, subdir]
	DirAccess.make_dir_recursive_absolute(dir)
	return dir

#wire UI file path
func _wire_ui() -> void:
	var tb = get_node_or_null("UI/TopBar")
	if tb == null:
		push_error("[Main] TopBar NOT FOUND at UI/TopBar")
	else:
		print("[Main] TopBar found, wiring…")
		tb.request_settings.connect(_open_settings)
		tb.request_help.connect(_open_help)
		tb.request_save.connect(_request_save)
		tb.request_load.connect(_request_load)
		tb.request_export.connect(_request_export)
	var pp = get_node_or_null("UI/PlayerPanel")
	if pp == null:
		push_error("[Main] PlayerPanel NOT FOUND at UI/PlayerPanel")
	else:
		pp.create_player.connect(_on_create_player)
	print("[Main] UI wired (if no errors above)")


# ----------------------------
# SAVE / LOAD (Layouts)
# ----------------------------
func _request_save() -> void:
	print("[Main] _request_save called")
	var keeps: Array = keep_factory.get_keep_dicts()
	print("[Main] saving keeps:", keeps.size())
	for d in keeps:
		print("[Save] ", d.get("name","?"), " anchor=", d.get("anchor"), " pos=", d.get("pos"))

	var ts: String = Time.get_datetime_string_from_system().replace(":", "").replace(" ", "-")
	var layouts_dir := _data_path("layouts")
	var path: String = "%s/layout-%s.json" % [layouts_dir, ts]

	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	f.store_string(JSON.stringify({
		"version": "1.0",
		"created": Time.get_datetime_string_from_system(),
		"keeps": keeps
	}, "  "))
	f.close()
	print("[Main] saved %s" % path)
	
func _request_load() -> void:
	print("[Main] _request_load called")

	var layouts_dir: String = _data_path("layouts")
	var da := DirAccess.open(layouts_dir)
	if da == null:
		print("[Main] No layouts dir at:", layouts_dir)
		return

	var newest: String = ""
	var t_latest: int = -1
	for fname in da.get_files():
		if fname.ends_with(".json"):
			var full: String = "%s/%s" % [layouts_dir, fname]
			var t: int = FileAccess.get_modified_time(full)
			if t > t_latest:
				t_latest = t
				newest = full

	if newest == "":
		print("[Main] No layout JSON found in:", layouts_dir)
		return

	# Clear current keeps
	var before_clear: int = keep_factory.get_keep_nodes().size()
	for k in keep_factory.get_keep_nodes():
		k.queue_free()
	print("[Main] cleared keeps:", before_clear)

	# Load + spawn
	var content: String = FileAccess.get_file_as_string(newest)
	var parsed: Variant = JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[Main] Bad JSON at: " + newest)
		return

	var root: Dictionary = parsed
	var keeps_arr: Array = root.get("keeps", [])
	print("[Main] spawning keeps:", keeps_arr.size())

	var MAP_ROWS := -1
	var MAP_COLS := -1

	for d_raw in keeps_arr:
		var d: Dictionary = d_raw

		# ---- read basics ----
		var size: int = int(d.get("size", 1))
		var anchor: String = str(d.get("anchor", "center")) # legacy had no anchor
		var grid_arr: Array = d.get("grid", [0, 0])
		var r := float(grid_arr[0])
		var c := float(grid_arr[1])

				# ---- NORMALIZATION if file already has exact pixel position, skip normalization
		var has_pos := d.has("pos") and (d.get("pos") is Array) and ((d.get("pos") as Array).size() == 2)

		if not has_pos:
			if anchor != "topLeft":
				var off := (size - 1) / 2.0
				var r_tl := int(floor(r - off))
				var c_tl := int(floor(c - off))
				d["grid"] = [r_tl, c_tl]
				d["anchor"] = "topLeft"
			else:
				d["grid"] = [int(r), int(c)]

		# ---- END NORMALIZATION ----

		# ---- optional clamp so full footprint stays on-map ----
		if MAP_ROWS > 0 and MAP_COLS > 0:
			var r_tl2 := clampi(d["grid"][0], 0, max(0, MAP_ROWS - size))
			var c_tl2 := clampi(d["grid"][1], 0, max(0, MAP_COLS - size))
			d["grid"] = [r_tl2, c_tl2]

		var pos_note := " (pos present)" if has_pos else ""
		print("[%s] keep:%s size:%d anchor:%s grid(TL):%s%s" % [
			"Main", String(d.get("name","?")), size, String(d.get("anchor")), str(d.get("grid")), pos_note
		])


		keep_factory.spawn_keep_from_dict(d)

	print("[Main] loaded %s" % newest)

# Convert a center grid coordinate to a TOP-LEFT grid coordinate for a keep of given size.
func _top_left_from_center(r_c: float, c_c: float, size: int) -> Vector2i:
	var off := (size - 1) / 2.0  # 3x3 -> 1.0, 2x2 -> 0.5
	return Vector2i(floor(r_c - off), floor(c_c - off))

# Convert a TOP-LEFT grid coordinate back to the center (useful in the spawner/renderer).
func _center_from_top_left(r_tl: int, c_tl: int, size: int) -> Vector2:
	var off := (size - 1) / 2.0
	return Vector2(r_tl + off, c_tl + off)

# Optional: clamp so the entire footprint stays inside your logical map bounds.
# Pass map_rows/map_cols if you have them; otherwise skip clamping.
func _clamp_top_left(r_tl: int, c_tl: int, size: int, map_rows: int, map_cols: int) -> Vector2i:
	var r := clampi(r_tl, 0, max(0, map_rows - size))
	var c := clampi(c_tl, 0, max(0, map_cols - size))
	return Vector2i(r, c)


# ----------------------------
# SCREENSHOT / IMAGE EXPORT
# ----------------------------
func _request_export() -> void:
	print("[Main] _request_export called")
	await get_tree().process_frame
	var img: Image = get_viewport().get_texture().get_image()
	if img == null:
		print("[Main] export failed: no image")
		return

	var ts: String = Time.get_datetime_string_from_system().replace(":", "").replace(" ", "-")
	var exports_dir := _data_path("exports")
	var path: String = "%s/shot-%s.png" % [exports_dir, ts]

	var err: int = img.save_png(path)
	if err == OK:
		print("[Main] exported %s" % path)
	else:
		print("[Main] export failed code %d" % err)

# ----------------------------
# UI plumbing
# ----------------------------
func _on_create_player(player: Dictionary) -> void:
	print("[Main] create_player received:", player)
	EventBus.emit_signal("toast", "Player created: %s" % player.get("name",""))

func _open_settings() -> void:
	settings_menu.popup_centered()

func _open_help() -> void:
	help_popup.popup_centered()

@onready var HelpOverlayScene: PackedScene = preload("res://scenes/ui/HelpOverlay.tscn")

func _show_first_run_help() -> void:
	Settings.first_run = false
	if not Settings.first_run:
		return

	var overlay := HelpOverlayScene.instantiate()
	ui_layer.add_child(overlay)

	# Connect something that actually exists:
	if overlay is AcceptDialog:
		overlay.confirmed.connect(_on_help_overlay_done.bind(overlay))
		overlay.canceled.connect(_on_help_overlay_done.bind(overlay))
		overlay.popup_centered()
	elif overlay is Window:
		overlay.close_requested.connect(_on_help_overlay_done.bind(overlay))
		overlay.popup_centered()
	elif overlay.has_signal("finished"):
		overlay.finished.connect(_on_help_overlay_done.bind(overlay))
	else:
		# fallback: when it disappears from tree
		overlay.tree_exited.connect(_on_help_overlay_done.bind(overlay))

func _on_help_overlay_done(overlay: Node) -> void:
	if is_instance_valid(overlay):
		overlay.queue_free()
	Settings.first_run = false
	Settings.save_settings()
