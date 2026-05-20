extends Node

# Contexto atual do interpretador (ChallengeData)
var current_context = null

# Estado financeiro do jogador
var money: int = 0
var upgrades: Array = []

# Mecânicas desbloqueadas (substitui state_of_game)
var unlocked_mechanics = {
	"sum": true,
	"change": false,
	"stock": false
}
