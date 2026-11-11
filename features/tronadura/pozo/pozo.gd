class_name Pozo
extends Node3D

signal estado_cambiado(estado: Estado)

enum Estado { VACIO, MARCADO, PERFORADO, CARGADO }

const SONIDO_SAMPLE_RATE: int = 22050
const SONIDO_DURATION: float = 0.2

@onready var marcador_socket: VRSocket = %MarcadorSocket
@onready var carga_socket: VRSocket = %CargaSocket
@onready var borde: MeshInstance3D = %Borde
@onready var hueco: MeshInstance3D = %Hueco
@onready var sonido_perforacion: AudioStreamPlayer3D = %SonidoPerforacion

var estado: Estado = Estado.VACIO
var _material_vacio: StandardMaterial3D
var _material_cargado: StandardMaterial3D

func _ready() -> void:
	marcador_socket.inserted.connect(_on_marcador_inserted)
	marcador_socket.removed.connect(_on_marcador_removed)
	carga_socket.inserted.connect(_on_carga_inserted)
	carga_socket.removed.connect(_on_carga_removed)
	_material_vacio = borde.material_override as StandardMaterial3D
	_material_cargado = _material_vacio.duplicate() as StandardMaterial3D
	_material_cargado.albedo_color = Color(0.2, 0.58, 0.32, 1)
	_actualizar_presentacion()
	sonido_perforacion.stream = _crear_sonido_perforacion()

func perforar() -> bool:
	if estado != Estado.MARCADO:
		return false
	hueco.visible = true
	sonido_perforacion.play()
	_set_estado(Estado.PERFORADO)
	return true

func reiniciar() -> void:
	carga_socket.eject()
	marcador_socket.eject()
	hueco.visible = false
	sonido_perforacion.stop()
	_set_estado(Estado.VACIO)

func _on_marcador_inserted(_item: VRGrabbable) -> void:
	_set_estado(Estado.MARCADO)

func _on_marcador_removed(_item: VRGrabbable) -> void:
	if estado == Estado.MARCADO:
		_set_estado(Estado.VACIO)

func _on_carga_inserted(_item: VRGrabbable) -> void:
	if estado == Estado.PERFORADO:
		_set_estado(Estado.CARGADO)
	else:
		carga_socket.eject()

func _on_carga_removed(_item: VRGrabbable) -> void:
	if estado == Estado.CARGADO:
		_set_estado(Estado.PERFORADO)

func _set_estado(nuevo_estado: Estado) -> void:
	if estado == nuevo_estado:
		return
	estado = nuevo_estado
	_actualizar_presentacion()
	estado_cambiado.emit(estado)

func _actualizar_presentacion() -> void:
	var carga_activa := estado == Estado.PERFORADO
	carga_socket.monitoring = carga_activa
	carga_socket.set_physics_process(carga_activa)
	borde.material_override = _material_cargado if estado == Estado.CARGADO else _material_vacio

func _crear_sonido_perforacion() -> AudioStreamWAV:
	var sample_count := int(SONIDO_SAMPLE_RATE * SONIDO_DURATION)
	var samples := PackedByteArray()
	samples.resize(sample_count * 2)
	for index: int in range(sample_count):
		var time := float(index) / float(SONIDO_SAMPLE_RATE)
		var progress := time / SONIDO_DURATION
		var phase := TAU * (520.0 * time - 205.0 * time * progress)
		var envelope := (1.0 - progress) * exp(-8.0 * time)
		var sample := roundi(sin(phase) * envelope * 28000.0)
		samples.encode_s16(index * 2, sample)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SONIDO_SAMPLE_RATE
	stream.stereo = false
	stream.data = samples
	return stream
