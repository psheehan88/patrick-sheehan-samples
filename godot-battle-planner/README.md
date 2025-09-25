# Dynamic Battle Planner (Godot 4.4)

Touch-friendly isometric battle planner used to prototype hive layouts, assign keeps, and plan
reinforcements. Supports small (2x2) and large (3x3) keeps, grid snapping, overlap detection,
arrow lines with troop-type icons, and JSON save/load of the map.

## Key Features
- Isometric grid with **snap-to-grid** placement
- **Drag & drop** keeps (desktop + mobile long-press)
- **2x2** and **3x3** keep sizes (per-player toggle)
- **Popup menu** on keep (mobile-friendly) with:
  - Create reinforcement arrow → choose troop type
  - Delete keep
  - (Optional) Change arrow icon
- Reinforcement **arrows**: each keep can send to exactly one target; targets can receive multiple
- **Overlap detection** with visual highlight
- **Save/Load** map to JSON (players, keeps, arrows)
- (Optional) Top-down / isometric view toggle (kept non-blocking to working isometric logic)

## Controls
**Desktop**
- Click + drag: move keep (snaps to grid)
- Right click (or double-click): open keep popup menu
- ESC: cancel placement / popup

**Mobile**
- Long-press: pick up keep
- Release: place (snaps to grid)
- Double-tap: open keep popup menu (safest universal gesture)

## Tech / Project Notes
- Engine: **Godot 4.4**
- Scenes: `Keep.tscn` (2x2/3x3), `ReinforcementArrow.tscn`, `GridOverlay.tscn`
- Scripts: `Keep.gd`, `KeepFactory.gd`, `GridOverlay.gd`, `ReinforcementArrow.gd`, `ArrowManager.gd`
- Data: `save/map.json` (players, keeps, arrows, troop types)
- Known good: **isometric mode** is the canonical view; top-down is optional and shouldn’t alter placement logic

## Save File (JSON) – Example
```json
{
  "grid": { "cols": 60, "rows": 60 },
  "players": [
    {"id":"p1","name":"KP","color":"#6aa6ff","large_keep":false},
    {"id":"p2","name":"Bruce","color":"#ffcc66","large_keep":true}
  ],
  "keeps": [
    {"id":"k_001","player_id":"p1","col":24,"row":18,"size":2},
    {"id":"k_002","player_id":"p2","col":30,"row":20,"size":3}
  ],
  "arrows": [
    {"from":"k_001","to":"k_002","troop_type":"archers"}
  ]
}
