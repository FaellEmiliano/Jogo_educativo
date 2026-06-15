extends Node

const SAVE_PATH = "user://save.json"
const SAVE_VERSION = 1

var dados: Dictionary = {}

func salvar(dinheiro: int = -1, mechanics: Dictionary = {}, upgrades: Array = []) -> void:
	_atualizar_estado_legacy(dinheiro, mechanics, upgrades)

	var save_data = _montar_save_data()
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Erro ao salvar o jogo")
		return

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	print("salvo")

func carregar() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		dados = _save_padrao()
		_carregar_sistemas(dados)
		return _dados_compatibilidade(dados)

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Erro ao abrir save")
		dados = _save_padrao()
		_carregar_sistemas(dados)
		return _dados_compatibilidade(dados)

	var texto = file.get_as_text()
	file.close()

	var json = JSON.new()
	var erro = json.parse(texto)
	if erro != OK or not (json.data is Dictionary):
		push_error("Save corrompido ou JSON invalido")
		dados = _save_padrao()
		_carregar_sistemas(dados)
		return _dados_compatibilidade(dados)

	dados = _validar_dados(json.data)
	_carregar_sistemas(dados)
	return _dados_compatibilidade(dados)

func resetar() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	dados = _save_padrao()
	_carregar_sistemas(dados)

func solicitar_save(_motivo := "") -> void:
	salvar()

func get_tutorial_data() -> Dictionary:
	if dados.is_empty():
		carregar()
	dados = _validar_dados(dados)
	return dados.get("tutorial", {}).duplicate(true)

func set_tutorial_step(step: int) -> void:
	if dados.is_empty():
		carregar()
	dados = _validar_dados(dados)
	dados["tutorial"]["step"] = max(0, step)
	salvar()

func complete_tutorial() -> void:
	if dados.is_empty():
		carregar()
	dados = _validar_dados(dados)
	dados["tutorial"]["completed"] = true
	salvar()

func _montar_save_data() -> Dictionary:
	return _validar_dados({
		"meta": {
			"save_version": SAVE_VERSION
		},
		"game": _coletar_dados_sistema(GameManager),
		"shop": _coletar_dados_sistema(UpgradeManager),
		"stock": _coletar_dados_sistema(StockSystem),
		"interpreter": _coletar_dados_sistema(InterpreterSystem),
		"tutorial": _validar_tutorial(dados.get("tutorial", {}))
	})

func _coletar_dados_sistema(system: Object) -> Dictionary:
	if system != null and system.has_method("get_save_data"):
		var save_data = system.get_save_data()
		if save_data is Dictionary:
			return save_data
	return {}

func _carregar_sistemas(save_data: Dictionary) -> void:
	_carregar_sistema(GameManager, save_data.get("game", {}))
	_carregar_sistema(UpgradeManager, save_data.get("shop", {}))
	_carregar_sistema(StockSystem, save_data.get("stock", {}))
	_carregar_sistema(InterpreterSystem, save_data.get("interpreter", {}))

func _carregar_sistema(system: Object, system_data: Variant) -> void:
	if system != null and system.has_method("load_save_data") and system_data is Dictionary:
		system.load_save_data(system_data)

func _atualizar_estado_legacy(dinheiro: int, mechanics: Dictionary, upgrades: Array) -> void:
	if dinheiro >= 0:
		GameManager.money = dinheiro

	if not mechanics.is_empty():
		for key in GameManager.unlocked_mechanics:
			if mechanics.has(key):
				GameManager.unlocked_mechanics[key] = bool(mechanics[key])

	if not upgrades.is_empty():
		GameManager.upgrades = upgrades.duplicate()

func _save_padrao() -> Dictionary:
	return {
		"meta": {
			"save_version": SAVE_VERSION
		},
		"game": {
			"dinheiro": 0,
			"unlocked_mechanics": {
				"sum": true,
				"cart": false,
				"discount": false,
				"change": false,
				"stock": false,
				"if": false,
				"sensor": false
			},
			"upgrades": []
		},
		"shop": {
			"comprados": {}
		},
		"stock": {
			"quantities": {}
		},
		"interpreter": {
			"script_text": ""
		},
		"tutorial": {
			"completed": false,
			"step": 0
		}
	}

func _validar_dados(data: Dictionary) -> Dictionary:
	var resultado = _save_padrao()
	var normalizado = _normalizar_formato(data)

	if normalizado.has("meta") and normalizado["meta"] is Dictionary:
		var meta = normalizado["meta"]
		if meta.has("save_version") and (meta["save_version"] is int or meta["save_version"] is float):
			resultado["meta"]["save_version"] = int(meta["save_version"])

	if normalizado.has("game") and normalizado["game"] is Dictionary:
		resultado["game"] = _validar_game(normalizado["game"])

	if normalizado.has("shop") and normalizado["shop"] is Dictionary:
		resultado["shop"] = _validar_shop(normalizado["shop"])

	if normalizado.has("stock") and normalizado["stock"] is Dictionary:
		resultado["stock"] = _validar_stock(normalizado["stock"])

	if normalizado.has("interpreter") and normalizado["interpreter"] is Dictionary:
		resultado["interpreter"] = _validar_interpreter(normalizado["interpreter"])

	if normalizado.has("tutorial") and normalizado["tutorial"] is Dictionary:
		resultado["tutorial"] = _validar_tutorial(normalizado["tutorial"])

	return resultado

func _normalizar_formato(data: Dictionary) -> Dictionary:
	if data.has("game") or data.has("meta"):
		return data

	var convertido = _save_padrao()
	convertido["game"]["dinheiro"] = data.get("dinheiro", convertido["game"]["dinheiro"])
	convertido["game"]["unlocked_mechanics"] = data.get("unlocked_mechanics", convertido["game"]["unlocked_mechanics"])
	convertido["game"]["upgrades"] = data.get("upgrades", convertido["game"]["upgrades"])
	return convertido

func _validar_game(data: Dictionary) -> Dictionary:
	var resultado = _save_padrao()["game"]

	if data.has("dinheiro") and (data["dinheiro"] is int or data["dinheiro"] is float):
		resultado["dinheiro"] = int(data["dinheiro"])

	if data.has("unlocked_mechanics") and data["unlocked_mechanics"] is Dictionary:
		for key in resultado["unlocked_mechanics"]:
			if data["unlocked_mechanics"].has(key):
				resultado["unlocked_mechanics"][key] = bool(data["unlocked_mechanics"][key])

	if data.has("upgrades") and data["upgrades"] is Array:
		resultado["upgrades"] = data["upgrades"].duplicate()

	return resultado

func _validar_shop(data: Dictionary) -> Dictionary:
	var resultado = _save_padrao()["shop"]

	if data.has("comprados"):
		if data["comprados"] is Dictionary:
			for id in data["comprados"]:
				resultado["comprados"][str(id)] = bool(data["comprados"][id])
		elif data["comprados"] is Array:
			for id in data["comprados"]:
				resultado["comprados"][str(id)] = true

	return resultado

func _validar_interpreter(data: Dictionary) -> Dictionary:
	var resultado = _save_padrao()["interpreter"]

	if data.has("script_text") and data["script_text"] is String:
		resultado["script_text"] = data["script_text"]

	return resultado

func _validar_stock(data: Dictionary) -> Dictionary:
	var resultado = _save_padrao()["stock"]

	if data.has("quantities") and data["quantities"] is Dictionary:
		for item_name in data["quantities"]:
			var quantity = data["quantities"][item_name]
			if quantity is int or quantity is float:
				resultado["quantities"][str(item_name)] = max(0, int(quantity))

	return resultado

func _validar_tutorial(data: Dictionary) -> Dictionary:
	var resultado = _save_padrao()["tutorial"]

	if data.has("completed"):
		resultado["completed"] = bool(data["completed"])

	if data.has("step") and (data["step"] is int or data["step"] is float):
		resultado["step"] = max(0, int(data["step"]))

	return resultado

func _dados_compatibilidade(save_data: Dictionary) -> Dictionary:
	var game = save_data.get("game", {})
	var compat = save_data.duplicate(true)
	compat["dinheiro"] = game.get("dinheiro", 0)
	compat["unlocked_mechanics"] = game.get("unlocked_mechanics", {})
	compat["upgrades"] = game.get("upgrades", [])
	return compat
