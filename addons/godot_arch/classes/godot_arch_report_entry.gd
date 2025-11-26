class_name GodotArchReportEntry
extends Resource

@export var absolute_file_path: String
@export var rule_name: String
@export var message: String

static func from_json(json: Dictionary) -> GodotArchReportEntry:
	var entry := GodotArchReportEntry.new()
	if not json.has("absolute_file_path") or json.absolute_file_path is not String:
		push_error("Malformed JSON Output: ReportEntry.absolute_file_path")
		return null
	if not json.has("rule_name") or json.rule_name is not String:
		push_error("Malformed JSON Output: ReportEntry.rule_name")
		return null
	if not json.has("message") or json.message is not String:
		push_error("Malformed JSON Output: ReportEntry.message")
		return null
	entry.absolute_file_path = json.absolute_file_path
	entry.rule_name = json.rule_name
	entry.message = json.message
	return entry
