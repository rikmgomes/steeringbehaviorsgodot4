extends Node2D

@onready var agent = $Agent  # Obtém referência ao nó 'Agent' quando a cena estiver pronta.

# Dicionário que mapeia cada comportamento ao botão correspondente e à cor que será usada.
var behaviors = {
	"default": {"button": "BtnDefault", "color": Color.GRAY},
	"seek": {"button": "BtnSeek", "color": Color.GREEN},
	"flee": {"button": "BtnFlee", "color": Color.RED},
	"pursuit": {"button": "BtnPursuit", "color": Color.BLUE},
	"evasion": {"button": "BtnEvasion", "color": Color.HOT_PINK},
	"wander": {"button": "BtnWander", "color": Color.PURPLE},
	"path_follow": {"button": "BtnPathFollow", "color": Color.YELLOW},
	"arrival": {"button": "BtnArrival", "color": Color.INDIAN_RED},
	"departure": {"button": "BtnDeparture", "color": Color.SKY_BLUE},
}

func _ready():
	_set_behavior("default")  # Define o comportamento inicial como "default".

func _set_behavior(behavior_name: String):
	agent.behavior = behavior_name  # Atribui o comportamento escolhido ao agente.

	# Loop que reseta a cor de todos os botões para branco (== não selecionados).
	for behavior_data in behaviors.values():
		$CanvasLayer/HBoxContainer.get_node(behavior_data["button"]).modulate = Color.WHITE

	# Define a cor do botão correspondente ao comportamento atual.
	var current = behaviors[behavior_name]
	$CanvasLayer/HBoxContainer.get_node(current["button"]).modulate = current["color"]

func _on_btn_default_pressed():
	_set_behavior("default")

func _on_btn_seek_pressed():
	_set_behavior("seek")

func _on_btn_flee_pressed():
	_set_behavior("flee")

func _on_btn_pursuit_pressed():
	_set_behavior("pursuit")

func _on_btn_evasion_pressed():
	_set_behavior("evasion")

func _on_btn_wander_pressed():
	_set_behavior("wander")

func _on_btn_path_follow_pressed():
	_set_behavior("path_follow")

func _on_btn_arrival_pressed():
	_set_behavior("arrival")

func _on_btn_departure_pressed():
	_set_behavior("departure")
