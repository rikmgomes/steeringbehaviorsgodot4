extends CharacterBody2D

@export var speed = 200.0  # Velocidade máxima do agente.
@export var steering_force = 400.0  # Força máxima de steering (aceleração).
@export var drag = 0.01  # Fator de arrasto (simula desaceleração).
@export var evasion_radius = 100.0  # Raio de detecção para evasão.
@export var wander_circle_distance = 80.0  # Distância do círculo à frente do agente (usa no wander).
@export var wander_circle_radius = 60.0  # Raio do círculo de wander.
@export var wander_angle_change = 0.5  # Quanto o ângulo pode variar por frame (usa no wander).
@export var path_offset: float = 0.0  # Offset inicial ao longo do caminho.
@export var path: Path2D  # Referência ao caminho a seguir.
@export var path_lookahead: float = 150.0  # Distância à frente para calcular o ponto alvo no caminho.
@export var path_radius: float = 100.0  # Raio de tolerância para o caminho.

var wander_angle = 0.0  # Ângulo atual usado no wander.
var current_distance: float = 0.0  # Posição atual ao longo do caminho (path).
var behavior = "default"  # Comportamento atual do agente (começa default).
var initial_position = Vector2.ZERO  # Posição original do agente.
var _mouse_position = Vector2.ZERO  # Posição atual do mouse (alvo do agente).

func _ready():
	initial_position = position  # Armazena a posição inicial do agente.

func _process(_delta):
	_mouse_position = get_global_mouse_position()  # Atualiza a posição do mouse.
	queue_redraw()  # Pede para redesenhar o debug visual.

func _physics_process(delta):
	match behavior:  # Seleciona o comportamento atual.
		"default":
			velocity = Vector2.ZERO  # Para o agente.
			position = initial_position  # Retorna à posição inicial.
		"seek":
			velocity += seek(_mouse_position) * delta  # Aplica força de seek.
		"flee":
			velocity += flee(_mouse_position) * delta  # Aplica força de flee.
		"pursuit":
			velocity += pursuit() * delta  # Aplica força de pursuit.
		"evasion":
			var evasion_force = evasion()
			if evasion_force != Vector2.ZERO:
				velocity += evasion_force * delta  # Aplica evasão se necessário.
			else:
				velocity *= (1.0 - drag)  # Aplica arrasto.
		"wander":
			var wander_force = wander()
			if wander_force != Vector2.ZERO:
				velocity += wander_force * delta  # Aplica wander.
			else:
				velocity *= (1.0 - drag)
		"path_follow":
			velocity += follow_path() * delta  # Segue o caminho.
		"arrival":
			velocity += arrival(_mouse_position) * delta  # Freia ao se aproximar.
		"departure":
			velocity += departure(_mouse_position) * delta  # Acelera ao se afastar.

	if behavior != "default":
		velocity = velocity.limit_length(speed)  # Limita à velocidade máxima.
		if velocity.length() > 10:
			rotation = velocity.angle()  # Rotaciona o agente na direção do movimento.
		_wrap_screen()  # Teleporta o agente para o lado oposto da tela se sair.

	move_and_slide()  # Move o agente com física integrada.

# -- Steering Behaviors --

func seek(target_pos: Vector2) -> Vector2:
	var desired_velocity = (target_pos - position).normalized() * speed  # Calcula a velocidade desejada em direção ao alvo, com magnitude igual à velocidade máxima.
	return (desired_velocity - velocity).limit_length(steering_force)    # Retorna a força de steering: a diferença entre a velocidade desejada e a atual, limitada pela força máxima.

func flee(target_pos: Vector2) -> Vector2:
	var desired_velocity = (position - target_pos).normalized() * speed  # Calcula a velocidade desejada para fugir do alvo, indo na direção oposta (contrário de Seek).
	return (desired_velocity - velocity).limit_length(steering_force)    # Retorna a força de steering necessária para fugir, limitada pela força máxima.

func pursuit() -> Vector2:
	var intercept_direction = (_mouse_position - position).normalized()  # Direção do agente até o alvo (mouse).
	var speed_ratio = velocity.length() / speed                          # Proporção da velocidade atual em relação à velocidade máxima.
	var interception_point = _mouse_position + intercept_direction * speed_ratio * 150.0  # Estima onde o alvo estará no futuro com base na direção e na velocidade.
	return (interception_point - position).normalized() * speed * 1.2 - velocity          # Gera uma força de "seek" para esse ponto futuro, com leve aumento na velocidade.

func evasion() -> Vector2:
	var distance_to_mouse = position.distance_to(_mouse_position)  # Calcula a distância entre o agente e o mouse.
	if distance_to_mouse > evasion_radius:
		return Vector2.ZERO  # Se estiver fora do raio de evasão, não faz nada.
	var intercept_direction = (_mouse_position - position).normalized()  # Direção do mouse em relação ao agente.
	var speed_ratio = velocity.length() / speed  # Proporção da velocidade atual do agente em relação à velocidade máxima.
	var interception_point = _mouse_position + intercept_direction * speed_ratio * 150.0  # Estima onde o mouse estará no futuro.
	return (position - interception_point).normalized() * speed * 1.5  # Foge na direção oposta ao ponto de intercepção, com força aumentada.

func wander() -> Vector2:
	var forward_direction = Vector2.RIGHT.rotated(rotation)  # Direção para frente baseada na rotação do agente.
	var circle_center = position + forward_direction * wander_circle_distance  # Centro do círculo de wander à frente do agente.
	var displacement = forward_direction.rotated(wander_angle) * wander_circle_radius  # Deslocamento rotacionado dentro do círculo.
	var target_position = circle_center + displacement  # Ponto alvo dentro do círculo.
	var desired_velocity = (target_position - position).normalized() * speed  # Velocidade desejada em direção ao ponto alvo.
	wander_angle += randf_range(-wander_angle_change, wander_angle_change)  # Altera levemente o ângulo para o próximo frame.
	return (desired_velocity - velocity).limit_length(steering_force)  # Calcula o steering final limitado pela força máxima.

func follow_path() -> Vector2:
	if not path:
		return Vector2.ZERO  # Sem caminho, sem steering.

	var curve = path.curve
	if not curve or curve.get_point_count() < 2:
		return Vector2.ZERO  # Sem curva ou com poucos pontos, não há caminho útil.

	current_distance = curve.get_closest_offset(path.to_local(position))  # Calcula a distância do ponto mais próximo do agente ao longo da curva.
	var target_distance = current_distance + path_offset + path_lookahead  # Offset e lookahead para prever onde deve ir.
	var target_position = path.global_position + curve.sample_baked(target_distance)  # Converte para posição global o ponto previsto no caminho.
	var desired_velocity = (target_position - position).normalized() * speed  # Velocidade desejada em direção ao ponto previsto.
	return (desired_velocity - velocity).limit_length(steering_force)  # Calcula o steering limitado à força máxima.

func arrival(target_pos: Vector2, slowing_radius := 150.0) -> Vector2:
	var to_target = target_pos - position  # Vetor até o alvo.
	var distance = to_target.length()  # Distância até o alvo.

	if distance < 1.0:
		return -velocity  # Para o agente quando estiver muito próximo.

	var ramped_speed = speed * (distance / slowing_radius)  # Velocidade proporcional à distância (mais perto → mais devagar).
	var clipped_speed = min(ramped_speed, speed)  # Garante que não ultrapasse a velocidade máxima.
	var desired_velocity = to_target.normalized() * clipped_speed  # Direção com a velocidade ajustada.
	return (desired_velocity - velocity).limit_length(steering_force)  # Steering limitado.

func departure(target_pos: Vector2, departure_radius := 150.0) -> Vector2:
	var to_target = position - target_pos  # Vetor do alvo até o agente (fuga).
	var distance = to_target.length()  # Distância entre agente e alvo.

	if distance == 0:
		return Vector2.ZERO  # Evita divisão por zero se estiver exatamente no alvo.

	var desired_speed = speed if distance >= departure_radius else speed * (distance / departure_radius)  # Acelera conforme se afasta.
	var desired_velocity = to_target.normalized() * desired_speed  # Direção da fuga com velocidade ajustada.
	return (desired_velocity - velocity).limit_length(steering_force)  # Steering limitado.

# -- Desenho para depuração visual --

func _draw():
	if Engine.is_editor_hint():
		return
	draw_line(Vector2.ZERO, velocity.normalized() * 60, Color.RED, 2) # Linha vermelha → direção atual da velocidade do agente (vetor de movimento real).
	draw_line(Vector2.ZERO, (_mouse_position - position).normalized() * 60, Color.GREEN, 2) # Linha verde → direção desejada em direção ao alvo (normalmente o mouse).

	if behavior == "pursuit":
		var future_pos = _mouse_position + (_mouse_position - position).normalized() * 100 # Calcula uma posição futura do mouse, para onde o agente vai mirar.
		draw_line(Vector2.ZERO, to_local(future_pos), Color.BLUE, 1) # Linha azul indicando essa posição futura.

	if behavior == "evasion":
		draw_arc(Vector2.ZERO, evasion_radius, 0, TAU, 32, Color(1.0, 0.4118, 0.7059, 0.3), 2.0) # Desenha o raio de detecção de evasão (círculo rosa transparente).

	if behavior == "wander":
		var forward_direction = Vector2.RIGHT.rotated(rotation) # Calcula a direção "para frente" do agente (baseada na rotação).
		var circle_center = forward_direction * wander_circle_distance # Centro do círculo de wander, à frente do agente.
		draw_circle(circle_center, wander_circle_radius, Color(0.5, 0, 1, 0.3)) # Círculo roxo semi-transparente representando a área de wander.
		draw_line(Vector2.ZERO, circle_center, Color.PURPLE, 1) # Linha roxa do agente até o centro do círculo.
		var target_local = forward_direction.rotated(wander_angle) * wander_circle_radius + circle_center # Calcula o ponto alvo rotacionado dentro do círculo.
		draw_line(circle_center, target_local, Color.PURPLE, 2) # Linha roxa do centro até o ponto alvo.
		draw_circle(target_local, 5, Color.PURPLE) # Ponto alvo como um pequeno círculo roxo.

	if behavior == "path_follow" and path:
		var curve = path.curve
		if curve:
			# Ponto mais próximo no caminho (em relação ao agente).
			var closest_point = path.to_local(position)
			var closest_offset = curve.get_closest_offset(closest_point)
			var path_position = curve.sample_baked(closest_offset)
			draw_circle(to_local(path.to_global(path_position)), 10, Color.PURPLE) # Círculo roxo no ponto mais próximo do caminho.
			
			# Ponto mais à frente no caminho (lookahead).
			var target_offset = closest_offset + path_offset + path_lookahead
			var target_path_position = curve.sample_baked(target_offset)
			draw_circle(to_local(path.to_global(target_path_position)), 10, Color.YELLOW) # Círculo amarelo no ponto futuro.

	if behavior == "path_follow" and path:
		var closest_point = path.curve.get_closest_point(path.to_local(position))
		draw_line(Vector2.ZERO, to_local(path.to_global(closest_point)), Color.WHITE, 1.0) # Linha branca entre o agente e o ponto mais próximo da curva.

	if behavior == "arrival":
		draw_arc(Vector2.ZERO, 150.0, 0, TAU, 32, Color(0.8039, 0.3608, 0.3608, 0.3), 2.0) # Zona de slowdown (círculo vermelho claro).

	if behavior == "departure":
		var departure_radius = 150.0
		draw_arc(Vector2.ZERO, departure_radius, 0, TAU, 32, Color(0.529, 0.808, 0.922, 0.3), 2.0) # Zona de repulsão (círculo azul claro).
		draw_line(Vector2.ZERO, (position - _mouse_position).normalized() * 60, Color(0.529, 0.808, 0.922, 0.8), 2) # Linha azul apontando na direção de fuga do alvo.

# -- Teleporte de borda de tela --

func _wrap_screen():
	var viewport_size = get_viewport_rect().size  # Obtém o tamanho atual da tela (largura e altura).
	var margin = 10  # Margem para evitar "flickering" (teleporte contínuo se ficar no limite).

	if position.x < -margin:
		position.x = viewport_size.x + margin  # Saiu pela esquerda? Reaparece na direita.
	elif position.x > viewport_size.x + margin:
		position.x = -margin  # Saiu pela direita? Reaparece na esquerda.
	
	if position.y < -margin:
		position.y = viewport_size.y + margin  # Saiu por cima? Reaparece embaixo.
	elif position.y > viewport_size.y + margin:
		position.y = -margin  # Saiu por baixo? Reaparece em cima.
