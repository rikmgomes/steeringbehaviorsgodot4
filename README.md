# steeringbehaviorsgodot4

### 🕹️ Como Utilizar o Programa
Importante citar que o projeto foi desenvolvido na engine Godot 4.4. Recomenda-se ter uma versão próxima ou pelo menos a partir da versão 4 para evitar problemas de compatibilidade. Para rodar o projeto, abra a cena principal “*scene_2d.tscn*”. O programa abrirá uma janela em que o agente teste se encontrará (triângulo verde). Além disso, no topo da tela, se encontram botões para que você ative cada comportamento implementado individualmente. Cada steering behavior acontece entre a posição atual do mouse e o agente (triângulo verde). Os códigos principais se encontram no script “*steering_agent.gd*” (possível atualização futura para separar os comportamentos em scripts separados está planejada).

### 📁 Estrutura do Projeto
```text
steeringbehaviorsgodot4/
├── extra/
│   ├── icon.svg
│   └── icon.svg.import
│
├── scenes/
│   └── scene_2d.tscn (cena principal)
│
├── scripts/
│   ├── path_2d.gd (script do caminho para path following)
│   ├── path_2d.gd.uid
│   ├── scene_2d.gd (implementação dos botões)
│   ├── scene_2d.gd.uid
│   ├── steering_agent.gd (script principal)
│   ├── steering_agent.gd.uid
│   ├── triangle_visual.gd (script que desenha o agente/triângulo)
│   └── triangle_visual.gd.uid
│
├── .editorconfig
├── .gitattributes
├── .gitignore
├── README.md
└── project.godot
```

### 🧠 Explicação dos 5 Steering Behaviors Implementados
#### 1️⃣ **Seek** / **Flee**
O comportamento **Seek** faz o agente se mover na direção de um alvo. Ele calcula um vetor de **velocidade desejada** apontando do agente até o alvo, e ajusta a movimentação para se alinhar com esse vetor. É útil para **seguir um ponto fixo**, perseguir algo simples, ou alinhar-se com um destino. **Flee** é o inverso do Seek. Em vez de ir **em direção** a um alvo, o agente se move **na direção oposta**, tentando colocar o máximo de distância entre ele e o alvo. É útil para simular **fuga de um inimigo**, ou evitar algo perigoso.

#### 2️⃣ **Pursuit** / **Evasion**
Melhora o Seek ao lidar com **alvos móveis**. Em vez de mirar na posição atual do alvo, ele **prevê onde o alvo estará** com base na sua velocidade e direção, e tenta interceptá-lo. É mais realista para perseguições, onde apenas seguir o alvo diretamente não é suficiente. **Evasion** é o oposto do Pursuit: o agente tenta prever **onde o perseguidor vai chegar**, e foge desse ponto. Ele calcula a posição futura do perigo, e se move para longe dela.

#### 3️⃣ **Arrival** / **Departure**
Extensão do Seek que melhora o comportamento de chegada. Ao se aproximar do alvo, o agente **reduz gradualmente a velocidade**, o que evita que ele ultrapasse o destino bruscamente. Isso dá uma sensação mais **natural e suave**. No **Departure**, o agente **foge** de um ponto, mas a força de fuga **depende da proximidade**. Quanto mais longe do ponto, mais forte ele foge. Serve para manter uma **zona de afastamento**.

#### 4️⃣ **Wander**
O **Wander** simula um movimento espontâneo e fluido, sem um alvo específico. Ao invés de movimentos aleatórios e bruscos, ele **gira levemente a direção desejada ao longo do tempo**, criando uma trajetória curva e natural. Costuma ser implementado com um "círculo de projeção" na frente do agente, e o alvo se move um pouco dentro desse círculo.

#### 5️⃣ **Path Following**
Esse comportamento faz o agente seguir um **caminho pré-definido**, como uma série de pontos, segmentos ou curvas. O agente tenta sempre se manter no caminho ou se reposicionar se sair dele.

### ⚠️ Desafios Encontrados
A implementação dos comportamentos foi relativamente simples (tirando Wander). O maior desafio foi encontrar o balanceamento correto dos valores nas variáveis para tudo ficar redondinho e não extremamente lento (várias vezes aumentei velocidade e steering). Além disso, não consegui implementar de nenhum jeito o steering behavior de "*Obstacle Avoidance*", o comportamento sempre ficou errático e não realizava o predict em tempo hábil ou de forma satisfatória. Dessa forma, resolvi não implementar esse comportamento, optando por outro ("*Path Following*") na lista.

### 📚 Referências
**REYNOLDS, Craig W.**
Steering behaviors for autonomous characters. In: GAME DEVELOPERS CONFERENCE, 1999, San Jose. Proceedings... San Jose: GDC, 1999.

**MILLINGTON, Ian.**
AI for games. 3. ed. Boca Raton: CRC Press, 2019. 872 p. ISBN 9781138483972.

**GDQUEST.**
Intro to steering behaviors in Godot. 2021. Disponível em: https://www.gdquest.com/tutorial/godot/2d/intro-to-steering-behaviors/. Acesso em: 9 abr. 2025.
