extends MiniGame

const Number = preload("res://minigames/generics/puzzles/amounts/number.gd")
const NumberBoard = preload("res://minigames/generics/puzzles/amounts/number_board.gd")
const NumberPlace = preload("res://minigames/generics/puzzles/amounts/number_place.gd")

var one_texture = preload("res://minigames/generics/puzzles/amounts/assets/one.svg")
var ten_texture = preload("res://minigames/generics/puzzles/amounts/assets/ten.svg")
var hundred_texture = preload("res://minigames/generics/puzzles/amounts/assets/hundred.svg")

var textures: Dictionary = {
	1: one_texture,
	2: ten_texture,
	3: hundred_texture
}

var number_places : Dictionary
var number_boards : Dictionary
 
var one_board : Node2D
var one_place : Area2D

var place_dx = 300

var dx1 = 50
var dy1 = 50

var dx10 = 35

var tenths: Array
var ones: Array
var tens: Array
var hundreds: Array

var numbers : Dictionary = {
	-1: tenths,
	1: ones,
	2: tens,
	3: hundreds
}

var one_positions : Array = [
	Vector2(-dx1, -2*dy1),
	Vector2(dx1, -dy1),
	Vector2(-dx1, -dy1),
	Vector2(dx1, 0),
	Vector2(-dx1, 0),
	Vector2(dx1, dy1),
	Vector2(-dx1, dy1),
	Vector2(dx1, 2*dy1),
	Vector2(-dx1, 2*dy1),
]

var ten_positions : Array = [
	Vector2(-4*dx10, 0),
	Vector2(-3*dx10, 0),
	Vector2(-2*dx10, 0),
	Vector2(-1*dx10, 0),
	Vector2(0, 0),
	Vector2(dx10, 0),
	Vector2(2*dx10, 0),
	Vector2(3*dx10, 0),
	Vector2(4*dx10, 0),
]

var diagonal := Vector2(15, -15)
var hundred_positions : Array = [
	-4*diagonal,
	-3*diagonal,
	-2*diagonal,
	-diagonal,
	Vector2(0,0),
	diagonal,
	2*diagonal,
	3*diagonal,
	4*diagonal,
]

var number_positions : Dictionary = {
	1: one_positions,
	2: ten_positions,
	3: hundred_positions
}

var number_positions_duplicate: Dictionary = number_positions.duplicate(true)

var number_place_positions : Dictionary = {
	1: Vector2(1300, 450),
	2: Vector2(900, 450),
	3: Vector2(400, 450)
}

var change_mode : Dictionary = {
	-1: true,
	1: true,
	2: true,
	3: true
}


func _add_number(place : int) -> void:
	var number : Area2D
	match place:
		1:
			number = Number.new(one_texture)
			number.position = number_place_positions[place] + Vector2(0, 320)
			number.original_position = Vector2(number.position)
		2:
			number = Number.new(ten_texture)
			number.position = number_place_positions[place] + Vector2(0, 400)
			number.original_position = Vector2(number.position)
		3:
			number = Number.new(hundred_texture)
			number.position = number_place_positions[place] + Vector2(0, 400)
			number.original_position = Vector2(number.position)
	number.place = place
	call_deferred("add_child", number)
	


func _add_number_places(places: Array) -> void:
	for i in places:
		var number_place : NumberPlace = NumberPlace.new(i)
		number_place.place = i
		number_place.position = number_place_positions[i]
		assert(number_place.number_entered.connect(_on_number_entered_board) == 0)
		number_places[i] = number_place
		add_child(number_place)		
	
	
func _add_board(place: int, pos: Vector2) -> void:
	var board = NumberBoard.new()
	board.position = pos
	number_boards[place] = board
	add_child(board)


func _on_number_entered_board(_number : Area2D, _name : String) -> void:
	var place = _number.place
	var _number_place : Area2D = get_node(_name)
	_number.movable_shape.set_deferred("active", false)
	if place == _number_place.place:
		_number.movable_shape.disabled = true
		numbers[place].push_back(_number)
		if numbers[place].size() != 10:
			_number.position = _number_place.position + number_positions[place].pop_back()
			number_boards[place].one_up()
			if _end_game_condition():
				_end_game()
			else:
				if change_mode[place]:
					_add_number(place)
				else:
					_add_number(place - 1)
		else:
			number_positions[place] = number_positions_duplicate.duplicate(true)[place] 
			_collect_numbers(place)
	else:
		_number.position = _number.original_position



func _connect_line(board: NumberBoard, number_place: Area2D) -> void:
	var line = Line2D.new()
	line.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line.end_cap_mode = Line2D.LINE_CAP_ROUND
	line.width = 5
	line.antialiased = true
	line.default_color = Color8(0,0,0)
	line.add_point(board.position + Vector2(0, board.one_board_texture.get_height()/2.0))
	line.add_point(number_place.position + Vector2(0, -number_place.sprite.texture.get_height()/2.0))
	add_child(line)


func _end_game_message():
	return "Mini game completed!"


func _end_game() -> void:
	await get_tree().create_timer(1).timeout
	var message = load("res://minigames/generics/SuccessMessage.tscn").instantiate()
	message.get_node("%Label").text = _end_game_message()
	add_child(message)
	
	
func _collect_numbers(place: int) -> void:
	var sz = textures[place].get_size()
	var nums = numbers[place]
	number_boards[place].set_to_zero()
	for i in [9, 8, 7, 6, 5, 4, 3, 2, 1, 0]:
		if place == 1:
			await get_tree().create_timer(0.3).timeout	
			nums[i].position = number_place_positions[place+1] + Vector2(0, 9*sz.y + i*sz.y)
	await get_tree().create_timer(0.3).timeout	
	for j in range(10):
		nums[j].queue_free()
	numbers[place] = []
	await get_tree().create_timer(0.5).timeout	
	_add_number(place + 1)

	
func _end_game_condition() -> bool:
	return false
