extends Node

const DeliveryPanelScene = preload("res://scenes/delivery/delivery_panel.tscn")
const CompletionOverlayScene = preload("res://scenes/game/completion_overlay.tscn")
const GameScene = preload("res://scenes/game/game.tscn")

var _failures: Array[String] = []


func _ready() -> void:
	FeatureManager.reset_progression()
	GameManager.money = 321
	GameManager.diamonds = 2
	GameManager.game_completed = false
	DeliverySystem.load_save_data({})
	DeliverySystem.unlock(false)
	DeliverySystem.debug_set_report([3, 0, 2])

	await _test_panel_content_and_responsiveness()
	_test_game_hud_structure()
	_test_completion_overlay()

	if _failures.is_empty():
		print("DELIVERY_UI_TEST_OK")
	else:
		push_error("\n".join(_failures))
	await get_tree().process_frame
	get_tree().quit()


func _test_panel_content_and_responsiveness() -> void:
	var panel := DeliveryPanelScene.instantiate()
	add_child(panel)
	panel.open_panel()
	_check(panel.visible, "Painel do Delivery deve abrir.")
	_check(panel.get_node("%NormalCount").text == "3", "Painel deve mostrar entregas normais.")
	_check(panel.get_node("%ExpressCount").text == "0", "Painel deve mostrar categoria zerada.")
	_check(panel.get_node("%VipCount").text == "2", "Painel deve mostrar entregas VIP.")
	_check(panel.get_node("%DiamondsLabel").text == "2 / 5", "Painel deve mostrar diamantes separados do dinheiro.")
	_check(panel.get_node("%MoneyLabel").text.contains("321"), "Painel deve reutilizar o dinheiro real do jogo.")
	_check(panel.get_node("%StatusLabel").text.contains("AGUARDANDO"), "Painel deve mostrar o estado atual.")
	_check(panel.get_node_or_null("WindowFrame/OuterMargin/RootLayout/TopBar/TitleBlock/Subtitle") == null, "Painel não deve exibir subtítulo no topo.")
	_check(not panel.get_node("%CooldownPanel").visible, "Painel não deve exibir a orientação inferior sobre await() durante o relatório.")
	_check(not panel.get_node("WindowFrame/OuterMargin/RootLayout/StatusBanner").tooltip_text.is_empty(), "Status deve possuir tooltip pedagógico.")
	_check(not panel.get_node("WindowFrame/OuterMargin/RootLayout/TopBar/DiamondStrip").tooltip_text.is_empty(), "Diamantes devem possuir tooltip próprio.")

	DeliverySystem.last_feedback_kind = "rejected"
	DeliverySystem.last_feedback = "Declaração rejeitada para teste."
	panel.refresh()
	_check(panel.get_node("%StatusLabel").text.contains("REJEITADA"), "Painel deve mostrar declaração rejeitada.")
	_check(panel.get_node("%FeedbackPanel").visible, "Painel deve exibir o motivo da rejeição.")

	DeliverySystem.state = DeliverySystem.State.COOLDOWN
	DeliverySystem.next_report_unix = int(Time.get_unix_time_from_system()) + 42
	panel.refresh()
	_check(panel.get_node("%StatusLabel").text.contains("APROVADA"), "Painel deve mostrar declaração aprovada durante cooldown.")
	_check(panel.get_node("%CooldownPanel").visible, "Painel deve manter o contador durante o cooldown.")
	_check(panel.get_node("%CooldownLabel").text.contains("RELATÓRIO EM"), "Painel deve mostrar o cooldown controlado pelo jogo.")

	GameManager.diamonds = 5
	DeliverySystem.state = DeliverySystem.State.WAITING_DECLARATION
	DeliverySystem.last_feedback_kind = ""
	panel.refresh()
	_check(panel.get_node("%DiamondsLabel").text == "5 / 5", "Painel deve representar o máximo de diamantes.")
	_check(panel.get_node("%StatusLabel").text.contains("MÁXIMO"), "Painel deve avisar quando os diamantes atingirem o máximo.")

	GameManager.game_completed = true
	DeliverySystem.mark_completed(false)
	panel.refresh()
	_check(panel.get_node("%StatusLabel").text.contains("CONCLUÍDO"), "Painel deve mostrar o estado de jogo concluído.")

	GameManager.game_completed = false
	DeliverySystem.state = DeliverySystem.State.LOCKED
	panel.refresh()
	_check(panel.get_node("%StatusLabel").text.contains("BLOQUEADO"), "Painel deve representar o Delivery bloqueado.")

	panel.call("_update_responsive_layout", 640.0)
	_check(panel.get_node("%BodyGrid").columns == 1, "Painel deve empilhar os blocos em viewport estreito.")
	_check(panel.get_node("%CategoryGrid").columns == 1, "Categorias devem empilhar em viewport estreito.")
	panel.call("_update_responsive_layout", 1152.0)
	_check(panel.get_node("%BodyGrid").columns == 2, "Painel deve usar duas colunas em viewport largo.")
	_check(panel.get_node("%CategoryGrid").columns == 3, "Categorias devem usar três colunas em viewport largo.")
	panel.close_panel()
	_check(not panel.visible, "Painel do Delivery deve fechar sem pausar o jogo.")
	panel.queue_free()
	await get_tree().process_frame


func _test_game_hud_structure() -> void:
	var game := GameScene.instantiate()
	_check(game.get_node_or_null("VBoxContainer/Delivery/DeliveryButton") != null, "HUD deve possuir acesso próprio ao Delivery.")
	_check(game.get_node_or_null("VBoxContainer/ColorRect/VBoxContainer/DiamondRow/DiamondLabel") != null, "HUD deve possuir contador de diamantes.")
	_check(game.get_node_or_null("HUD/NotificationPanel") != null, "HUD deve possuir notificações não bloqueantes.")
	_check(game.get_node_or_null("HUD/DeliveryPanel") != null, "HUD deve instanciar o painel do Delivery.")
	_check(game.get_node_or_null("HUD/CompletionOverlay") != null, "HUD deve instanciar a finalização do jogo.")
	var delivery_access := game.get_node("VBoxContainer/Delivery") as Control
	var shop_access := game.get_node("ShopMenu/ColorRect2") as Control
	_check(delivery_access.custom_minimum_size.x == shop_access.custom_minimum_size.x, "Delivery e Melhorias devem ter a mesma largura.")
	game.free()


func _test_completion_overlay() -> void:
	var overlay := CompletionOverlayScene.instantiate()
	add_child(overlay)
	overlay.open_overlay()
	_check(overlay.visible and get_tree().paused, "Finalização deve pausar e ficar visível.")
	_check(overlay.get_node("%ContinueButton") != null and overlay.get_node("%MainMenuButton") != null, "Finalização deve oferecer continuar e voltar ao menu.")
	overlay.close_overlay()
	_check(not overlay.visible and not get_tree().paused, "Continuar deve retomar o jogo.")
	overlay.queue_free()


func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
