extends Area2D
class_name NumberZombie

# can't mark this as constant because Godot is dumb. Pretend it's immutable.
var OPERATIONS = {
	"+": func(a, b): return a + b,
	"-": func(a, b): return a - b,
	"": func(a, b): return a * b,
	"÷": func(a, b): return a / b,
}

signal hit
signal kill

@export var speed: int = 400
@export var target: Vector2 = Vector2(0, 0)
@export_enum("+", "-", "", "÷") var opreation: String = "+"
@export var operands: Array[int] = [1, 2]


@onready var text: Label = get_node("Text")

func _ready():
	text.text = str(operands[0]) + " " + opreation + " " + str(operands[1])


func shoot(answer: int) -> bool:
	if answer == OPERATIONS[opreation].call(operands[0], operands[1]):
		queue_free()
		emit_signal("kill")
		return true

	return false


func _on_detection_area_area_entered(_area: Area2D):
	emit_signal("hit", self)
	queue_free()


func _physics_process(delta):
	# having issues with this not working so I'm throwing it here as a hacky fix
	text.text = str(operands[0]) + " " + opreation + " " + str(operands[1])

	var direction = target - position
	var distance = direction.length()
	var velocity = direction.normalized() * speed * delta

	if distance < velocity.length():
		velocity = direction
	position += velocity
