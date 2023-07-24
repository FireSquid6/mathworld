extends MiniGame

var tick_scene = preload("res://minigames/counting/falling_decimals_0_to_1/tick.tscn")
var number_scene = preload("res://minigames/counting/falling_decimals_0_to_1/number.tscn")
var ticks = 21
var tick_map = {}  # used by arrow key movement
var dx = 70
var line_a = Vector2(250,800)
var line_b = Vector2(line_a.x + (ticks-1)*dx, line_a.y)

var selected_number: Node2D
var score = 0
var rounds = 3
var high_score

func _on_num_selection(node):
	if selected_number == null or not is_instance_valid(selected_number):
		selected_number = node
	else:
		if selected_number.find_tick != true:
			selected_number.get_node("Sprite2D").frame = 0
		else:
			selected_number.get_node("Sprite2D").frame = 2	
		selected_number = node
	node.get_node("Sprite2D").frame = 1


# snaps the selected number either to the nearest 
func _move_selected_number(direction: int) -> void:
	if direction != 0 && selected_number != null:
		var closest_tick_right = null
		var closest_tick_left = null
		var selected_pos = selected_number.position.x
		
		for tick_position in tick_map:
			if tick_position > selected_number.position.x and (closest_tick_right == null or tick_position < closest_tick_right):
				closest_tick_right = tick_position
			if tick_position < selected_number.position.x and (closest_tick_left == null or tick_position > closest_tick_left):
				closest_tick_left = tick_position
		print(closest_tick_left)
		print(closest_tick_right)
		var tick = tick_map[closest_tick_right] if direction == 1 else tick_map[closest_tick_left]
		
		_on_tick_selection(tick)


func _on_tick_selection(node):
	node.get_node("Sprite2D").frame = 1
	node.get_node("ColorTimer").start()
	if selected_number != null and is_instance_valid(selected_number):
		selected_number.tick = node
		selected_number.find_tick = true

func _add_number():
	var number = number_scene.instantiate()
	add_child(number)
	
	assert(number.connect("selected", Callable(self, "_on_num_selection")) == 0)

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var integer = rng.randi_range(0, 1)
	var decimal = rng.randi_range(0, 9)
	number.value = integer + 0.1*decimal
	number.mk_number(str(integer), str(decimal), Vector2(-12,-4))
	number.position = Vector2(line_a. x + rng.randi_range(0, line_b.x - line_a. x), 100)
	number.add_to_group("numbers")
	
func validate(area, tick = null):
	var number = area.get_parent()
	number.get_node("ExitTimer").start()
	if tick != null:
		if snapped(number.value, 0.1) == snapped(tick.value, 0.1):
			score += 1
			$ScoreBox/ScoreLabel.text = str(score)
			number.get_node("Sprite2D").frame = 3
		else: 
			rounds -= 1
			number.get_node("Sprite2D").frame = 4
	else:
		rounds -= 1
		number.get_node("Sprite2D").frame = 4
	if score > 9:
		$ScoreBox/ScoreLabel.position.x = 10
	$RoundsBox/RoundsLabel.text = str(rounds)
	if rounds == 0:
		if high_score != null:
			if score > high_score:
				high_score = score
		else: high_score = score
		$ScoreBoard/HighScore.text = str(high_score)
		$NumberTimer.stop()
		get_tree().call_group("numbers", "queue_free")
		$Music.stop()
		$GameOver.play()
		$EndBox.show()
		$RestartButton.show()
		
func _on_restart():
	score = 0
	rounds = 3
	$RoundsBox/RoundsLabel.text = str(rounds)
	$ScoreBox/ScoreLabel.text = str(score)
	$EndBox.visible = false
	$RestartButton.hide()
	$NumberTimer.wait_time = 4
	$NumberTimer.start()
	$Music.play()
	
func _add_specifics():
	
	world_part = "counting"
	id = "falling_decimals_0_to_1"
	minigame_type = NUMBER_LINE
	
	for i in range(ticks):
		var tick = tick_scene.instantiate()
		add_child(tick)
		
		var x_position = line_a.x + dx*i
		tick.position = Vector2(x_position, line_a.y)
		tick_map[x_position] = tick
		
		tick.value = i*0.1
		assert(tick.connect("selected", Callable(self, "_on_tick_selection")) == 0)
	
	print(tick_map)

	$ScoreBox/ScoreLabel.text = str(score)
	$ScoreBorder.position = $ScoreBox.position
	$ScoreBorder.size = $ScoreBox.size
	
	$RoundsBox.size = $ScoreBox.size
	$RoundsBox.position = $ScoreBox.position + Vector2(0, 150)
	$RoundsBox/RoundsLabel.text = str(rounds)
	$RoundsBorder.position = $RoundsBox.position
	$RoundsBorder.size = $RoundsBox.size
	
	$ScoreBoard.position = $RoundsBox.position + Vector2(0, 150)
	
	_mk_number(self, "0", null, Vector2(line_a.x, line_a.y+40), 0.5, 20, 5, 10, 10)
	_mk_number(self, "0", "5", Vector2(line_a.x-10+5*dx, line_a.y+40), 0.5, 20, 5, 10, 10)
	_mk_number(self, "1", null, Vector2(line_a.x+10*dx, line_a.y+40), 0.5, 20, 5, 10, 10)
	_mk_number(self, "1", "5", Vector2(line_a.x-10+15*dx, line_a.y+40), 0.5, 20, 5, 10, 10)
	_mk_number(self, "2", null, Vector2(line_a.x+20*dx, line_a.y+40), 0.5, 20, 5, 10, 10)
	
	assert($NumberTimer.connect("timeout", Callable(self, "_add_number")) == 0 )
	assert($RestartButton.connect("pressed", Callable(self, "_on_restart")) == 0)
	$NumberTimer.start()
	$EndBox.hide()
	$RestartButton.hide()
	$Music.play()

func _mk_number(scene, number, decs, pos, num_scale = 1, x_sep = 20, comma_sep = 20, comma_sep2 = 5, comma_y = 5):
	var num_scene = preload("res://minigames/counting/falling_decimals_0_to_1/int.tscn")
	var num_list = []
	var comma
	var cnt = 0
	for digit in number:
		var dig = num_scene.instantiate()
		dig.scale = num_scale*Vector2(1, 1)
		dig.position = pos + Vector2(cnt*x_sep, 0)
		dig.frame = int(digit)
		cnt += 1
		scene.add_child(dig)
		num_list.append(dig)
	if decs != null:
		comma = _mk_operator(scene, 5, pos + Vector2(cnt*x_sep - comma_sep, comma_y), num_scale)
		num_list.append(comma)
		for digit in decs:
			var dig = num_scene.instantiate()
			dig.scale = num_scale*Vector2(1, 1)
			dig.position = pos + Vector2(cnt*x_sep + comma_sep2, 0)
			dig.frame = int(digit)
			cnt += 1
			scene.add_child(dig)
			num_list.append(dig)
	return num_list


func _mk_operator(scene, int_frame, pos, num_scale = 1):
	var op_scene = preload("res://minigames/counting/falling_decimals_0_to_1/operator.tscn")
	var op = op_scene.instantiate()
	op.scale = num_scale*Vector2(1, 1)
	op.frame = int_frame
	op.position = pos
	scene.add_child(op)
	return op


func _draw():
	draw_line(line_a, line_b, Color(0,0,0), 7)

var time = 0
func _process(delta):
	time += delta
	if time > 20: 
		$NumberTimer.wait_time = 0.9*$NumberTimer.wait_time
		time = 0
	
	# this should probably in in an input event
	_move_selected_number( int(Input.is_action_just_pressed("ui_right")) - int(Input.is_action_just_released("ui_left")) )
