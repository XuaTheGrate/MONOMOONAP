class_name CollectableEmblem
extends Collectable

enum EmblemType {
	Star, Earth, Water, Crown
}

@export var emblem_type: EmblemType = EmblemType.Star

static func get_sprites(t: EmblemType) -> Array[Texture2D]:
	match t:
		EmblemType.Star: return [
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/star_emblem.tres"),
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/star_emblem_unlit.tres"),
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/star_emblem_normals.tres")
		]
		EmblemType.Earth: return [
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/earth_emblem.tres"),
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/earth_emblem_unlit.tres"),
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/earth_emblem_normals.tres")
		]
		EmblemType.Water: return [
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/water_emblem.tres"),
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/water_emblem_unlit.tres"),
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/water_emblem_normals.tres")
		]
		EmblemType.Crown: return [
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/crown_emblem.tres"),
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/crown_emblem_unlit.tres"),
			preload("res://mods-unpacked/MayaXTG-Archipelago/assets/crown_emblem_normals.tres")
		]
	return [
		preload("res://mods-unpacked/MayaXTG-Archipelago/assets/collectible_ap.png"),
		preload("res://mods-unpacked/MayaXTG-Archipelago/assets/collectible_ap_unlit.png"),
		preload("res://mods-unpacked/MayaXTG-Archipelago/assets/collectible_ap_normals.png")
	]

func _ready() -> void:
	# custom type so it doesn't conflict with anything
	type = (1 << 21) as Collectable.Type
	super()
	var sprites = get_sprites(emblem_type)
	icon = sprites[0]
	$Squasher/Sprite.texture = icon
	$Squasher/Sprite/SelectedOutline.texture = icon
	var shader: ShaderMaterial = $Squasher/Sprite.material
	shader.set_shader_parameter("unlit_texture", sprites[1])
	shader.set_shader_parameter("normalmap", sprites[2])
