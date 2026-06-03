extends Node

const UpgradeData = preload("res://data/UpgradeData.gd")

signal upgrade_liberado(id, data)
signal upgrade_comprado(id)
signal upgrade_aplicado(id)
signal upgrades_atualizados()

var upgrades_liberados = []
var upgrades_comprados = {}
var reward_multiplier := 1.0
var spawn_delay_min := 5.0
var spawn_delay_max := 8.0

func _ready() -> void:
	verificar_desbloqueios()

func verificar_desbloqueios() -> void:
	for id in UpgradeData.UPGRADES:
		var data = UpgradeData.UPGRADES[id]
		var dinheiro_minimo = data.get("dinheiro_minimo", 0)
		var requisitos = data.get("requer", [])

		if GameManager.money >= dinheiro_minimo and _requisitos_comprados(requisitos) and not upgrades_liberados.has(id):
			upgrades_liberados.append(id)
			upgrade_liberado.emit(id, data)
	upgrades_atualizados.emit()

func _requisitos_comprados(requisitos: Array) -> bool:
	for requisito in requisitos:
		if not upgrades_comprados.has(str(requisito)):
			return false
	return true

func get_upgrades_visiveis() -> Array:
	var upgrades_visiveis = []

	for id in upgrades_liberados:
		if not UpgradeData.UPGRADES.has(id):
			continue

		upgrades_visiveis.append({
			"id": id,
			"data": UpgradeData.UPGRADES[id],
			"comprado": upgrades_comprados.has(id)
		})

	return upgrades_visiveis

func has_upgrade(id: String) -> bool:
	return upgrades_comprados.has(id)

func can_buy(id: String) -> bool:
	if not UpgradeData.UPGRADES.has(id):
		return false
	if not upgrades_liberados.has(id) or upgrades_comprados.has(id):
		return false
	return GameManager.money >= int(UpgradeData.UPGRADES[id].get("preco", 0))

func comprar_upgrade(id: String) -> void:
	if not UpgradeData.UPGRADES.has(id):
		push_warning("Upgrade inexistente: %s" % id)
		return

	if not upgrades_liberados.has(id):
		push_warning("Upgrade ainda nao liberado: %s" % id)
		return

	if upgrades_comprados.has(id):
		return
	
	var preco = int(UpgradeData.UPGRADES[id].get("preco", 0))
	if GameManager.money < preco:
		push_warning("Dinheiro insuficiente para comprar: %s" % id)
		return

	upgrades_comprados[id] = true
	if not GameManager.upgrades.has(id):
		GameManager.upgrades.append(id)
	EventBus.emit_signal("update_money", -preco)
	print("Upgrade comprado: ", id)
	aplicar_upgrade(id)
	upgrade_comprado.emit(id)
	verificar_desbloqueios()

func aplicar_upgrade(id: String) -> void:
	if not UpgradeData.UPGRADES.has(id):
		return
	print("Aplicando upgrade: ", id)
	var efeito = UpgradeData.UPGRADES[id].get("efeito", {})
	match efeito.get("tipo", ""):
		"unlock_feature":
			FeatureManager.unlock_feature(str(efeito.get("feature", "")))
		"reward_multiplier":
			reward_multiplier += float(efeito.get("valor", 0.0))
		"spawn_delay":
			spawn_delay_min = float(efeito.get("min", spawn_delay_min))
			spawn_delay_max = float(efeito.get("max", spawn_delay_max))
	upgrade_aplicado.emit(id)

func calcular_recompensa(valor_base: int) -> int:
	return max(1, int(round(valor_base * reward_multiplier)))

func get_spawn_delay_range() -> Vector2:
	return Vector2(spawn_delay_min, spawn_delay_max)

func get_save_data() -> Dictionary:
	return {
		"comprados": upgrades_comprados.duplicate(true)
	}

func load_save_data(data: Dictionary) -> void:
	upgrades_comprados.clear()
	upgrades_liberados.clear()
	reward_multiplier = 1.0
	spawn_delay_min = 5.0
	spawn_delay_max = 8.0
	FeatureManager.reset_progression()

	if not data.has("comprados"):
		verificar_desbloqueios()
		return

	var comprados = data["comprados"]
	if comprados is Dictionary:
		for id in comprados:
			if bool(comprados[id]):
				upgrades_comprados[id] = true
	elif comprados is Array:
		for id in comprados:
			upgrades_comprados[str(id)] = true

	for id in upgrades_comprados:
		aplicar_upgrade(id)

	verificar_desbloqueios()
