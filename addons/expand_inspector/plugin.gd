@tool
extends EditorPlugin

var _inspector: EditorInspector


func _enter_tree() -> void:
	_inspector = EditorInterface.get_inspector()
	_inspector.edited_object_changed.connect(_on_edited_object_changed)


func _exit_tree() -> void:
	if _inspector and _inspector.edited_object_changed.is_connected(_on_edited_object_changed):
		_inspector.edited_object_changed.disconnect(_on_edited_object_changed)


func _on_edited_object_changed() -> void:
	_expand_all.call_deferred()


func _expand_all() -> void:
	_expand_node(_inspector)


func _expand_node(node: Node) -> void:
	if node.has_method("unfold"):
		node.unfold()
	for child in node.get_children():
		_expand_node(child)
