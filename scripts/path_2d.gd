extends Path2D

@onready var line_2d: Line2D = $Line2D #Obtém uma referência ao nó Line2D filho

func _ready():
	update_line()  # Atualiza os pontos da Line2D com base na curva do Path2D.

func update_line():
	if not curve:
		return  # Se não houver uma curva definida no Path2D, sai da função.
	line_2d.clear_points()  # Limpa os pontos existentes na Line2D para redesenhar do zero.
	var point_count = 50 # Define quantos pontos serão usados para amostrar a curva (mais pontos = curva mais suave).
	var baked_length = curve.get_baked_length() # Obtém o comprimento total da curva (usada para calcular a distância entre os pontos).
	
	# Loop que percorre de 0 até point_count (inclusive), gerando pontos ao longo da curva.
	for i in point_count + 1:
		var distance = (i / float(point_count)) * baked_length # Distância proporcional ao longo da curva.
		var point = curve.sample_baked(distance) #Posição do ponto na curva com base na distância calculada acima.
		line_2d.add_point(point) # Adiciona o ponto na Line2D para que ele seja desenhado.
