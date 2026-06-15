extends Node

# Contexto atual do interpretador (ChallengeData)
var current_context = null

# Estado financeiro do jogador
var money: int = 0
var upgrades: Array = []

# Mecânicas desbloqueadas (substitui state_of_game)
var unlocked_mechanics = {
	"sum": true,
	"cart": false,
	"discount": false,
	"change": false,
	"stock": false,
	"if": false,
	"sensor": false
}

func get_save_data() -> Dictionary:
	return {
		"dinheiro": money,
		"unlocked_mechanics": unlocked_mechanics.duplicate(true),
		"upgrades": upgrades.duplicate()
	}

func load_save_data(data: Dictionary) -> void:
	if data.has("dinheiro") and (data["dinheiro"] is int or data["dinheiro"] is float):
		money = int(data["dinheiro"])

	if data.has("upgrades") and data["upgrades"] is Array:
		upgrades = data["upgrades"].duplicate()

	if data.has("unlocked_mechanics") and data["unlocked_mechanics"] is Dictionary:
		for key in unlocked_mechanics:
			if data["unlocked_mechanics"].has(key):
				unlocked_mechanics[key] = bool(data["unlocked_mechanics"][key])
		FeatureManager.load_legacy_features(unlocked_mechanics)
