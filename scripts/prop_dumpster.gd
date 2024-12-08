extends "res://scripts/prop_interact.gd"

const TRASHBAG_LIMIT := 20

var trashbag_scene := preload("res://components/props/prop-trashbag.tscn")
var trashbag_index := 0
var trashbag_active: Array[Node3D] = []

func player_interact(player: Node3D) -> void:
	print("dumpster script: ", self, ", player: ", player)
	
	# spawn a trash bag
	var trashbag := trashbag_scene.instantiate()
	trashbag.name = "trashbag-%s" % trashbag_index
	trashbag.connect("hover_start", player._on_prop_hover_start)
	trashbag.connect("hover_leave", player._on_prop_hover_leave)
	trashbag.connect("player_interaction", player._on_prop_player_interaction)
	print("creating trashbag: ", trashbag.name)
	
	# TODO: raycast a valid position from space
	trashbag.position = self.position + Vector3(0, 1, 0)
	
	get_tree().root.add_child(trashbag)
	trashbag_active.append(trashbag)
	trashbag_index += 1
	
	while trashbag_active.size() > TRASHBAG_LIMIT:
		var remove_trashbag: Node3D = trashbag_active.pop_front()
		print("removing trashbag over the limit: ", remove_trashbag)
		remove_trashbag.get_parent().remove_child(remove_trashbag)
