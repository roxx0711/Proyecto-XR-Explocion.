class_name Perforadora
extends VRGrabbable

@onready var punta_area: Area3D = %PuntaArea

func _ready() -> void:
	super._ready()

func use(anchor: Node3D) -> void:
	if not is_instance_valid(held_by) or held_by != anchor:
		return
	for target_area: Area3D in punta_area.get_overlapping_areas():
		var socket := target_area as VRSocket
		if socket == null or socket.accepted_item != &"marcador":
			continue
		var pozo := socket.get_parent() as Pozo
		if pozo == null or pozo.estado != Pozo.Estado.MARCADO:
			continue
		if not pozo.perforar():
			continue
		var grip_node := anchor.get_parent()
		if grip_node != null:
			var hand := grip_node.get_parent() as VRHand
			if hand != null:
				hand.pulse.call_deferred(0.7)
		used.emit()
		return
