extends MiniGame

const Number = preload("res://minigames/counting/number_catch_0_to_9/number.gd")
var number : Number = preload("res://minigames/counting/number_catch_0_to_9/Number.tscn").instantiate()
#var circle_white : Texture2D = preload("res://minigames/generics/assets/circle_white.svg")
#var circle_blue : Texture2D = preload("res://minigames/generics/assets/circle_purple.svg")
var tennis_ball : Texture2D = preload("res://minigames/generics/assets/tennis_ball_small.png")
var tennis_ball_purple : Texture2D = preload("res://minigames/generics/assets/tennis_ball_small_purple.png")
var character : Node2D = preload("res://minigames/counting/number_catch_0_to_9/Character.tscn").instantiate()

var audio_player := AudioStreamPlayer2D.new()
var correct_sound : AudioStream = preload("res://minigames/generics/assets/correct.mp3")

const radius := 50.0
const left_margin := 100
const right_margin := 360
const top_margin := -100
var width : float
var current_sprite : Sprite2D
var current_node : Node2D
var collision_area : Area2D

var values : Array = [
	preload("res://minigames/generics/assets/stroke_numbers/one-stroke.svg"),
	preload("res://minigames/generics/assets/stroke_numbers/two-stroke.svg"),
	preload("res://minigames/generics/assets/stroke_numbers/three-stroke.svg"),
	preload("res://minigames/generics/assets/stroke_numbers/four-stroke.svg"),
	preload("res://minigames/generics/assets/stroke_numbers/five-stroke.svg"),
	preload("res://minigames/generics/assets/stroke_numbers/six-stroke.svg"),
	preload("res://minigames/generics/assets/stroke_numbers/seven-stroke.svg"),
	preload("res://minigames/generics/assets/stroke_numbers/eight-stroke.svg"),
	preload("res://minigames/generics/assets/stroke_numbers/nine-stroke.svg"),		
]

# Called when the node enters the scene tree for the first time.
func _add_specifics() -> void:
	
	world_part = "counting"
	id = "number_catch_0_to_9"
	
	var area2D : Area2D = character.get_node("number_container/Area2D")
	assert(area2D.connect("body_entered", _on_character_entered) == 0)
	assert($Timer.connect("timeout", _spawn_numbers) == 0)
	assert($GasTimer.connect("timeout", _cut_gas) == 0)
	
	width = get_viewport_rect().size.x-right_margin
	var OneSprite := Sprite2D.new() 
	OneSprite.texture = values[0]
#	current_node = character.get_node("number_container")
#	current_node.add_child(OneSprite)
#	current_sprite = current_node.get_node("Circle")
#	current_sprite.texture = tennis_ball_purple
#	collision_area = current_node.get_node("Area2D")
	add_child(character)
	_spawn_numbers()
	$Timer.start()
	add_child(audio_player)
	audio_player.stream = correct_sound

func _spawn_numbers():
	randomize()
	
	for i in range(3):
		var random_number = randi() % 9 + 1
		var num : Number = number.duplicate()
		num.value = random_number
		num.get_node("Orb").frame = random_number - 1
		num.position = Vector2(left_margin+randf_range(i*width/3, (i+1)*width/3), top_margin)
		add_child(num)


func update_physics(NumberContainer):
	current_node.remove_child(collision_area)
	NumberContainer.add_child(collision_area)
	current_node.add_child(NumberContainer)
	current_node = NumberContainer




func _cut_gas() -> void:
	character.get_node("GasFront").hide()
	character.get_node("GasBack").hide()

func _on_character_entered(body : Node2D) -> void:
	if body as Number and body.value == character.value + 1:
		character.get_node("GasFront").show()
		character.get_node("GasBack").show()
		$GasTimer.start()
		character.get_node("Canister").frame += 1
		var NumberContainer := Node2D.new()
		var NumberSprite := Sprite2D.new() 
		var CircleSprite := Sprite2D.new()
		NumberContainer.name = 'number_container'
		NumberSprite.texture = values[body.value - 1]
		NumberContainer.position = Vector2(0, -2*radius)
		CircleSprite.position = NumberSprite.position
		CircleSprite.texture = tennis_ball_purple
		character.value += 1
#		call_deferred('update_physics', NumberContainer)
		NumberContainer.add_child(CircleSprite)
		NumberContainer.add_child(NumberSprite)
#		current_sprite.texture = tennis_ball
#		current_sprite = CircleSprite
		body.queue_free()
		audio_player.play()
		
		if character.value == 9:
			await get_tree().create_timer(0.5).timeout
			_end_game()
