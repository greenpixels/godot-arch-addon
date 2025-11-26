class_name GodotArchWarning

var message: String
var absolute_path: String

static func from_json(json: Dictionary) -> GodotArchWarning:
	var warning := GodotArchWarning.new()
	if not json.has("message") or json.message is not String:
		push_error("Malformed JSON Output: Warning.message")
		return null
	if not json.has("absolute_path") or json.absolute_path is not String:
		push_error("Malformed JSON Output: Warning.absolute_path")
		return null
	warning.message = json.message
	warning.absolute_path = json.absolute_path
	return warning
