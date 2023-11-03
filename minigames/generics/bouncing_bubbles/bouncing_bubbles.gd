extends MiniGame

const Bubble = preload("res://minigames/generics/bouncing_bubbles/bubble.gd")

enum {REPRESENTATION_A, REPRESENTATION_B}

var chosen_bubble : String
var bubble_container := Node2D.new()
var left_wall := StaticBody2D.new()
var right_wall := StaticBody2D.new()
var top_wall := StaticBody2D.new()
var bottom_wall := StaticBody2D.new()
var audio_player := AudioStreamPlayer2D.new()
var correct_sound : AudioStream = preload("res://minigames/generics/assets/correct.mp3")
var incorrect_sound : AudioStream = preload("res://minigames/generics/assets/whip.mp3")


func _add_generics() -> void:
	var window : Vector2 = get_viewport_rect().size
	
	var border_shape = CollisionShape2D.new()
	border_shape.shape = SegmentShape2D.new()
	
	var left_border = CollisionShape2D.new()
	left_border.shape = SegmentShape2D.new()
	left_border.shape.a = Vector2(0, 0)
	left_border.shape.b = Vector2(0, window.y)
	left_wall.add_child(left_border)
	var right_border = CollisionShape2D.new()
	right_border.shape = SegmentShape2D.new()
	right_border.shape.a = Vector2(window.x, 0)
	right_border.shape.b = Vector2(window.x, window.y)
	right_wall.add_child(right_border)
	var bottom_border = CollisionShape2D.new()
	bottom_border.shape = SegmentShape2D.new()
	bottom_border.shape.a = Vector2(0, window.y)
	bottom_border.shape.b = window
	bottom_wall.add_child(bottom_border)
	var top_border = CollisionShape2D.new()
	top_border.shape = SegmentShape2D.new()
	top_border.shape.a = Vector2(0, 0)
	top_border.shape.b = Vector2(window.x, 0)
	top_wall.add_child(top_border)
	
	add_child(bubble_container)
	add_child(left_wall)
	add_child(right_wall)
	add_child(bottom_wall)
	add_child(top_wall)
	add_child(audio_player)
	
	_add_specifics()
	_mk_bubbles()

func _add_specifics() -> void:
	pass


func _mk_bubbles():
	pass


func _on_bubble_pressed(_name : String) -> void:
	if _name == chosen_bubble:
		bubble_container.get_node(_name).sprite.frame = 0
		chosen_bubble = ''
	else:
		if chosen_bubble == '':
			bubble_container.get_node(_name).sprite.frame = 1
			chosen_bubble = _name
		elif bubble_container.get_node(chosen_bubble).representation != bubble_container.get_node(_name).representation:
			if _bubbles_are_equal(_name, chosen_bubble):
				audio_player.stream = correct_sound
				audio_player.play()
				
				var bubble1 = bubble_container.get_node(chosen_bubble)
				var bubble2 = bubble_container.get_node(_name)
				
				bubble1.on_kill()
				bubble2.on_kill()
				
				bubble1.queue_free()
				bubble2.queue_free()
				chosen_bubble = ''
			else:
				audio_player.stream = incorrect_sound
				print("You messed up")
				var bubble = bubble_container.get_node(chosen_bubble)
				print(bubble)
				audio_player.play()
				if status_bar.frame == 0:
					_end_game_with_failure()
					
				status_bar.frame -= 1
				return

			if _end_game_condition(): 
				await get_tree().create_timer(0.5).timeout
				_end_game()


func _bubbles_are_equal(_bubble1 : String, _bubble2 : String) -> bool:
	return false


func _end_game_condition() -> bool:
	return bubble_container.get_child_count() == 0


