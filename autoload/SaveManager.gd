extends Node

const SAVE_PATH = "user://save.json"
var dados

# SALVAR
func salvar(dinheiro: int, mechanics: Dictionary, upgrades: Array):
	var save_data = {
		"dinheiro": dinheiro,
		"unlocked_mechanics": mechanics,
		"upgrades": upgrades
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("salvo")
	else:
		push_error("Erro ao salvar o jogo")


# CARREGAR
func carregar() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return _save_padrao()
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("Erro ao abrir save")
		return _save_padrao()
	
	var texto = file.get_as_text()
	
	var json = JSON.new()
	var erro = json.parse(texto)
	print("JSON LIDO:", texto)
	print("DADOS PARSEADOS:", json.data)
	if erro != OK:
		push_error("Erro ao ler JSON")
		return _save_padrao()
	
	dados = json.data
	return _validar_dados(dados)


# RESETAR SAVE
func resetar():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)


# SAVE PADRÃO
func _save_padrao() -> Dictionary:
	return {
		"dinheiro": 0,
		"unlocked_mechanics": {
			"sum": true,
			"change": false,
			"stock": false
		},
		"upgrades": []
	}

# VALIDAÇÃO
func _validar_dados(d: Dictionary) -> Dictionary:
	var resultado = _save_padrao()
	
	if "dinheiro" in d and (d["dinheiro"] is int or d["dinheiro"] is float):
		resultado["dinheiro"] = int(d["dinheiro"])
	
	if "unlocked_mechanics" in d and d["unlocked_mechanics"] is Dictionary:
		for key in resultado["unlocked_mechanics"]:
			if key in d["unlocked_mechanics"]:
				resultado["unlocked_mechanics"][key] = d["unlocked_mechanics"][key]
	
	if "upgrades" in d and d["upgrades"] is Array:
		resultado["upgrades"] = d["upgrades"]
	
	return resultado
