class_name Pozo
extends Node3D

signal estado_cambiado(estado: Estado)

enum Estado { VACIO, MARCADO, PERFORADO, CARGADO }

@onready var marcador_socket: VRSocket = %MarcadorSocket

var estado: Estado = Estado.VACIO

func _ready() -> void:
	marcador_socket.inserted.connect(_on_marcador_inserted)
	marcador_socket.removed.connect(_on_marcador_removed)

func perforar() -> bool:
	if estado != Estado.MARCADO:
		return false
	_set_estado(Estado.PERFORADO)
	return true

func reiniciar() -> void:
	marcador_socket.eject()
	_set_estado(Estado.VACIO)

func _on_marcador_inserted(_item: VRGrabbable) -> void:
	_set_estado(Estado.MARCADO)

func _on_marcador_removed(_item: VRGrabbable) -> void:
	_set_estado(Estado.VACIO)

func _set_estado(nuevo_estado: Estado) -> void:
	if estado == nuevo_estado:
		return
	estado = nuevo_estado
	estado_cambiado.emit(estado)
