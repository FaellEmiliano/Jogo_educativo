extends Node

const ScriptWorkspace = preload("res://systems/ScriptWorkspace.gd")

func _ready() -> void:
	_test_workspace_documents()
	_test_legacy_migration()
	_test_delivery_document()
	print("SCRIPT_WORKSPACE_SMOKE_TEST_OK")
	await get_tree().process_frame
	get_tree().quit()

func _test_workspace_documents() -> void:
	var workspace := ScriptWorkspace.new()
	assert(workspace.scripts.size() == 1, "Workspace deve iniciar com uma aba.")
	assert(workspace.get_active_title() == "Principal", "A primeira aba deve ser Principal.")

	var principal_id := workspace.active_script_id
	workspace.update_active_source("codigo principal")

	var new_id := workspace.create_script()
	assert(new_id != principal_id, "Nova aba deve receber id diferente.")
	workspace.set_active_script(new_id)
	assert(workspace.get_active_source().contains("int main"), "Nova aba deve iniciar com codigo base.")

	workspace.update_active_source("codigo novo")
	workspace.set_active_script(principal_id)
	assert(workspace.get_active_source() == "codigo principal", "Trocar de aba nao pode perder o codigo Principal.")
	workspace.set_active_script(new_id)
	assert(workspace.get_active_source() == "codigo novo", "Trocar de volta nao pode perder o codigo da aba nova.")

	workspace.rename_script(new_id, "Principal")
	assert(workspace.get_script_document(new_id).get("title") == "Principal", "Renomear deve permitir nomes repetidos.")
	assert(workspace.get_script_document(new_id).get("id") == new_id, "Renomear nao pode alterar o id interno.")

	var serialized := workspace.serialize()
	var loaded := ScriptWorkspace.new()
	loaded.deserialize(serialized)
	assert(loaded.scripts.size() == 2, "Load deve restaurar todas as abas.")
	assert(loaded.scripts[0].get("id") == principal_id, "Load deve preservar a ordem visual.")
	assert(loaded.active_script_id == new_id, "Load deve restaurar a aba ativa.")
	assert(loaded.get_active_source() == "codigo novo", "Load deve restaurar o texto da aba ativa.")

	assert(loaded.delete_script(principal_id), "Deve apagar uma aba quando ainda existe outra.")
	assert(loaded.active_script_id == new_id, "Apagar outra aba nao pode invalidar a aba ativa.")
	assert(not loaded.delete_script(new_id), "Nao deve apagar a ultima aba.")

func _test_legacy_migration() -> void:
	var migrated := ScriptWorkspace.new()
	migrated.deserialize({"script_text": "codigo antigo"})
	assert(migrated.scripts.size() == 1, "Save antigo deve virar uma aba.")
	assert(migrated.get_active_title() == "Principal", "Save antigo deve migrar para Principal.")
	assert(migrated.get_active_source() == "codigo antigo", "Migracao nao pode perder o codigo antigo.")

func _test_delivery_document() -> void:
	var workspace := ScriptWorkspace.new()
	var delivery_id := workspace.ensure_delivery_script()
	assert(not delivery_id.is_empty(), "Delivery deve receber um id próprio.")
	assert(workspace.get_script_document(delivery_id).get("title") == "Delivery", "A aba reservada deve se chamar Delivery.")
	workspace.rename_script(delivery_id, "Outro nome")
	assert(workspace.get_script_document(delivery_id).get("title") == "Delivery", "A aba Delivery não pode ser renomeada.")
	assert(not workspace.delete_script(delivery_id), "A aba Delivery não pode ser apagada.")
	workspace.set_active_script(delivery_id)
	workspace.update_active_source("codigo delivery")
	var loaded := ScriptWorkspace.new()
	loaded.deserialize(workspace.serialize())
	assert(loaded.delivery_script_id == delivery_id, "O save deve preservar o id da aba Delivery.")
	assert(loaded.get_script_document(delivery_id).get("source") == "codigo delivery", "O save deve preservar o código do Delivery.")
