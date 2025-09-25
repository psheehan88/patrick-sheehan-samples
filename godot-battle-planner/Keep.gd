
---

## Example Code Snippets

### 1) `Keep.gd` (handles size, dragging, popup menu, overlap hint)

```gdscript
extends Node2D
class_name Keep

@export var keep_id: String
@export var player_id: String
@export var size: int = 2 # 2 or 3
@export var color: Color = Color(0.8, 0.2, 0.2)

var is_dragging := false
var grid: Node = null
var popup: PopupMenu = null
var arrow_manager: Node = null
var highlight: Node2D = null

func _ready():
	# colorize sprite
	var spr := $Sprite2D
	if spr:
		spr.modulate = color

	# popup menu
	popup = $PopupMenu
	if popup:
		popup.clear()
		popup.add_item("Create reinforcement…", 1)
		popup.add_separator()
		popup.add_item("Delete keep", 99)
		popup.id_pressed.connect(_on_popup_id)

	# overlap highlight node
	highlight = $Highlight
	_update_highlight(false)

func set_grid(g: Node) -> void:
	grid = g

func set_arrow_manager(m: Node) -> void:
	arrow_manager = m

#handle user input
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if _is_mouse_over():
				is_dragging = true
				get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if _is_mouse_over():
				_show_popup()
				get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and not event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and is_dragging:
			is_dragging = false
			_snap_to_grid()

	if event is InputEventScreenTouch:
		if event.pressed and _is_touch_over(event.position):
			# long-press is handled by InputMap/Timer in your project; simplified here
			is_dragging = true
		elif not event.pressed and is_dragging:
			is_dragging = false
			_snap_to_grid()

func _process(_dt):
	if is_dragging:
		global_position = get_global_mouse_position()
		_update_overlap_state()

func _is_mouse_over() -> bool:
	var spr := $Sprite2D
	if not spr: return false
	return spr.get_rect().has_point(to_local(get_global_mouse_position()))

func _is_touch_over(pos: Vector2) -> bool:
	var spr := $Sprite2D
	if not spr: return false
	return spr.get_rect().has_point(to_local(pos))

#handle popup settings
func _show_popup():
	if popup:
		popup.position = get_viewport().get_mouse_position()
		popup.popup()

func _on_popup_id(id: int):
	match id:
		1:
			_request_reinforcement()
		99:
			queue_free()

func _request_reinforcement():
	if arrow_manager:
		arrow_manager.start_arrow_from_keep(self)

#snap to grid option
func _snap_to_grid():
	if grid and grid.has_method("snap_global_to_cell_origin"):
		var snapped := grid.snap_global_to_cell_origin(global_position, size)
		global_position = snapped
	_update_overlap_state()

func _update_overlap_state():
	if grid and grid.has_method("is_occupied_rect"):
		var rect := _occupied_rect()
		var overlapping := grid.is_occupied_rect(rect, self)
		_update_highlight(overlapping)

func _occupied_rect() -> Rect2i:
	# uses grid's cell size; assume grid provides col/row conversion
	if not grid: return Rect2i()
	var colrow := grid.global_to_cell(global_position)
	return Rect2i(colrow.x, colrow.y, size, size)

func _update_highlight(bad: bool):
	if highlight:
		highlight.visible = bad
