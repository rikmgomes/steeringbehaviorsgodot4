extends Node2D

func _draw():
	if Engine.is_editor_hint():  # Evita desenhar o triângulo no editor (só aparece no jogo em execução).
		return
	var triangle_points = PackedVector2Array([  # Define os vértices do triângulo em relação ao centro do nó.
		Vector2(15, 0),   # Ponta do triângulo (frente → eixo X positivo).
		Vector2(-10, -8), # Traseira esquerda do triângulo.
		Vector2(-10, 8)   # Traseira direita do triângulo.
	])
	draw_polygon(triangle_points, [Color.GREEN])  # Desenha o triângulo com cor verde sólida.
