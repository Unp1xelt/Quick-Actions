const label = "Toggle overdraw"
const key: Key = KEY_4

func run(plugin: QuickActions, menu: PopupMenu, id: int):
	var viewport = EditorInterface.get_editor_viewport_3d()
	
	if viewport.debug_draw == Viewport.DEBUG_DRAW_OVERDRAW:
		viewport.debug_draw = Viewport.DEBUG_DRAW_DISABLED
	else:
		viewport.debug_draw = Viewport.DEBUG_DRAW_OVERDRAW
