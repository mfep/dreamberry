extends HBoxContainer

export(Array) var Seed_Textures

func _ready():
	$'/root/Game'.connect('Picked_Seeds_Changed', self, '_on_Picked_Seeds_Changed')
	$GoButton.connect('pressed', $'/root/Game', '_on_Go_Button_pressed')

func _on_Picked_Seeds_Changed(seeds):
	update_texture($PanelContainer/TextureRect, seeds[0])
	update_texture($PanelContainer2/TextureRect2, seeds[1])

func update_texture(texture_rect, seed_idx):
	if seed_idx == 0:
		texture_rect.texture = null
	else:
		texture_rect.texture = Seed_Textures[seed_idx-1]
