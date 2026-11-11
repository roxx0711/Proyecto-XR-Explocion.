extends Node3D

signal todos_los_pozos_marcados

var _pozos: Array[Pozo] = []
var _todos_marcados: bool = false

func _ready() -> void:
	for pozo_node: Node in get_tree().get_nodes_in_group(&"pozos"):
		var pozo := pozo_node as Pozo
		if pozo == null:
			continue
		_pozos.append(pozo)
		pozo.estado_cambiado.connect(_on_pozo_estado_cambiado)
	_evaluar_pozos()

func _on_pozo_estado_cambiado(_estado: int) -> void:
	_evaluar_pozos()

func _evaluar_pozos() -> void:
	var todos_marcados := _pozos.size() == 6
	for pozo: Pozo in _pozos:
		if pozo.estado != Pozo.Estado.MARCADO:
			todos_marcados = false
			break
	if not todos_marcados:
		_todos_marcados = false
		return
	if _todos_marcados:
		return
	_todos_marcados = true
	print("Los seis pozos están marcados.")
	todos_los_pozos_marcados.emit()
