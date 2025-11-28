@tool
extends PanelContainer
class_name GodotArchInspector

@onready var execute_button : Button = %ExecuteButton

const POPUP_MENU_OPEN_FILE := 0

func _ready() -> void:
	execute_button.icon = EditorInterface.get_base_control().get_theme_icon("Play", "EditorIcons")

func update_from_report_data(report : GodotArchReport):
	%AmountFailed.text = str(report.files_failed)
	%AmountTotal.text = str(report.files_tested)
	%ProgressBar.value = float(report.files_failed) / float(report.files_tested) * 100.
	
	var reports_by_file_path : Dictionary[String, Array] = {}
	
	for failed_report in report.failed_reports:
		if not reports_by_file_path.has(failed_report.absolute_file_path):
			reports_by_file_path[failed_report.absolute_file_path] = []
		reports_by_file_path[failed_report.absolute_file_path].push_back(failed_report)
	
	%ReportsTree.clear()
	
	var failures_tree_root : TreeItem = %ReportsTree.create_item()
	failures_tree_root.set_text(0, str(reports_by_file_path.keys().size()) + " files with issues")
	failures_tree_root.set_custom_color(0, Color.DARK_GRAY)
	failures_tree_root.set_selectable(0, false)
	
	for key in reports_by_file_path.keys():
		var file_tree_entry : TreeItem = %ReportsTree.create_item(failures_tree_root)
		file_tree_entry.set_text(0, key.replace(ProjectSettings.globalize_path("res://"), ""))
		file_tree_entry.set_tooltip_text(0, key)
		file_tree_entry.set_icon(0, EditorInterface.get_base_control().get_theme_icon("Folder", "EditorIcons"))
		file_tree_entry.set_meta("reports", reports_by_file_path[key])
		file_tree_entry.set_meta("path", key)


		for entry in reports_by_file_path[key] as Array[GodotArchReportEntry]:
			var report_entry : TreeItem = %ReportsTree.create_item(file_tree_entry)
			report_entry.set_text(0, entry.message)
			report_entry.set_autowrap_mode(0, TextServer.AUTOWRAP_WORD_SMART)
			report_entry.set_selectable(0, false)
			report_entry.set_custom_color(0, Color.html("d35316"))
			report_entry.set_suffix(0, "(" + entry.rule_name + ")")
		
func _on_tree_item_mouse_selected(mouse_position: Vector2, mouse_button_index: int) -> void:
	var context_menu_file_path
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		%PopupMenu.position = %ReportsTree.get_screen_position() + mouse_position
		%PopupMenu.popup()

func _on_popup_menu_index_pressed(index: int) -> void:
	var tree_item : TreeItem = %ReportsTree.get_selected()
	if not tree_item: return;
	var path = tree_item.get_meta("path", null)
	var entries = tree_item.get_meta("reports", null)
	match(index):
		POPUP_MENU_OPEN_FILE:
			EditorInterface.get_file_system_dock().navigate_to_path(path.replace(ProjectSettings.globalize_path("res://"), "res://"))

func collapse_all_items():
	var root = %ReportsTree.get_root()
	if root:
		root.set_collapsed_recursive(true)
		
		# Expand root node so we can still see the files
		root.collapsed = false

func expand_all_items():
	var root = %ReportsTree.get_root()
	if root:
		root.set_collapsed_recursive(false)

func _on_collapse_button_pressed() -> void:
	collapse_all_items()

func _on_expand_button_pressed() -> void:
	expand_all_items()
