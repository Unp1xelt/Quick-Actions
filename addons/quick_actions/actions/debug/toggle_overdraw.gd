func init_menu(plugin: QuickActions, menu: PopupMenu, id: int):
	menu.hide_on_checkable_item_selection = false
	menu.add_radio_check_item("Overdraw", id, KEY_T)

func run(plugin: QuickActions, menu: PopupMenu, id: int):
	var viewport = EditorInterface.get_editor_viewport_3d()
	
	menu.toggle_item_checked(menu.get_item_index(id))
	
	if viewport.debug_draw == Viewport.DEBUG_DRAW_OVERDRAW:
		viewport.debug_draw = Viewport.DEBUG_DRAW_DISABLED
	else:
		viewport.debug_draw = Viewport.DEBUG_DRAW_OVERDRAW
