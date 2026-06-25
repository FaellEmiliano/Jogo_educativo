extends Node

var _failures: Array[String] = []
var _debug_text := ""

func _ready() -> void:
	EventBus.update_money.connect(_on_update_money)
	EventBus.send_debug.connect(_on_send_debug)
	FeatureManager.unlock_feature(FeatureManager.FEATURE_IF)

	await _test_get_stock_basic()
	await _test_get_stock_returns_copy()
	await _test_buy_stock_valid_purchase()
	await _test_buy_stock_wrong_size()
	await _test_buy_stock_negative_quantity()
	await _test_buy_stock_over_capacity()
	await _test_buy_stock_insufficient_money()
	await _test_buy_stock_zero_purchase()
	await _test_full_restock_script()

	if _failures.is_empty():
		print("STOCK_BUILTINS_TEST_OK")
	else:
		push_error("\n".join(_failures))

	await get_tree().process_frame
	get_tree().quit()

func _test_get_stock_basic() -> void:
	_set_quantities([4, 10, 0, 2, 6, 1])
	await _run_code("""
int main() {
	int estoque[6];

	estoque = get_stock();

	print(estoque[0]);
	print(estoque[1]);
}
""")
	_check(_debug_text == "4\n10", "get_stock() deve imprimir os valores atuais do estoque.")

func _test_get_stock_returns_copy() -> void:
	_set_quantities([4, 10, 0, 2, 6, 1])
	await _run_code("""
int main() {
	int estoque[6];

	estoque = get_stock();
	estoque[0] = 999;
}
""")
	_check(StockSystem.get_stock()[0].quantity == 4, "Alterar o array retornado por get_stock() nao pode alterar o estoque real.")

func _test_buy_stock_valid_purchase() -> void:
	_reset_stock()
	GameManager.money = 100
	await _run_code("""
int main() {
	int compra[6];

	for (int i = 0; i < 6; i++) {
		compra[i] = 0;
	}

	compra[0] = 1;
	compra[1] = 2;

	buy_stock(compra);
}
""")
	_check(StockSystem.get_stock()[0].quantity == 1, "Compra valida deve aumentar o produto 0.")
	_check(StockSystem.get_stock()[1].quantity == 2, "Compra valida deve aumentar o produto 1.")
	_check(GameManager.money == 89, "Compra valida deve descontar o custo total correto.")

func _test_buy_stock_wrong_size() -> void:
	_reset_stock()
	GameManager.money = 100
	await _run_code("""
int main() {
	int compra[3];

	compra[0] = 1;
	compra[1] = 2;
	compra[2] = 3;

	buy_stock(compra);
}
""")
	_check(_stock_quantities() == [0, 0, 0, 0, 0, 0], "Array de tamanho errado nao deve alterar estoque.")
	_check(GameManager.money == 100, "Array de tamanho errado nao deve alterar dinheiro.")
	_check(_debug_text.contains("buy_stock(): esperado array de tamanho 6."), "Array de tamanho errado deve mostrar erro no output.")

func _test_buy_stock_negative_quantity() -> void:
	_reset_stock()
	GameManager.money = 100
	await _run_code("""
int main() {
	int compra[6];

	for (int i = 0; i < 6; i++) {
		compra[i] = 0;
	}

	compra[0] = -1;

	buy_stock(compra);
}
""")
	_check(_stock_quantities() == [0, 0, 0, 0, 0, 0], "Quantidade negativa nao deve alterar estoque.")
	_check(GameManager.money == 100, "Quantidade negativa nao deve alterar dinheiro.")
	_check(_debug_text.contains("buy_stock(): quantidade negativa no indice 0."), "Quantidade negativa deve mostrar erro no output.")

func _test_buy_stock_over_capacity() -> void:
	_reset_stock()
	GameManager.money = 10000
	await _run_code("""
int main() {
	int compra[6];

	for (int i = 0; i < 6; i++) {
		compra[i] = 999;
	}

	buy_stock(compra);
}
""")
	_check(_stock_quantities() == [0, 0, 0, 0, 0, 0], "Compra acima do limite nao deve alterar estoque.")
	_check(GameManager.money == 10000, "Compra acima do limite nao deve alterar dinheiro.")
	_check(_debug_text.contains("buy_stock(): compra ultrapassa o estoque maximo no indice 0."), "Compra acima do limite deve mostrar erro no output.")

func _test_buy_stock_insufficient_money() -> void:
	_reset_stock()
	GameManager.money = 1
	await _run_code("""
int main() {
	int compra[6];

	for (int i = 0; i < 6; i++) {
		compra[i] = 0;
	}

	compra[5] = 2;

	buy_stock(compra);
}
""")
	_check(_stock_quantities() == [0, 0, 0, 0, 0, 0], "Dinheiro insuficiente nao deve alterar estoque.")
	_check(GameManager.money == 1, "Dinheiro insuficiente nao deve alterar dinheiro.")
	_check(_debug_text.contains("buy_stock(): dinheiro insuficiente para realizar a compra."), "Dinheiro insuficiente deve mostrar erro no output.")

func _test_buy_stock_zero_purchase() -> void:
	_reset_stock()
	GameManager.money = 100
	await _run_code("""
int main() {
	int compra[6];

	for (int i = 0; i < 6; i++) {
		compra[i] = 0;
	}

	buy_stock(compra);
}
""")
	_check(_stock_quantities() == [0, 0, 0, 0, 0, 0], "Compra zerada nao deve alterar estoque.")
	_check(GameManager.money == 100, "Compra zerada nao deve alterar dinheiro.")

func _test_full_restock_script() -> void:
	_reset_stock()
	_set_quantities([4, 10, 0, 2, 6, 1])
	GameManager.money = 1000
	await _run_code("""
int main() {
	int estoque[6];
	int compra[6];

	estoque = get_stock();

	for (int i = 0; i < 6; i++) {
		compra[i] = 0;
	}

	for (int i = 0; i < 6; i++) {
		if (estoque[i] < 5) {
			compra[i] = 5 - estoque[i];
		}
	}

	buy_stock(compra);
}
""")
	_check(_stock_quantities() == [5, 10, 5, 5, 6, 5], "Script completo deve repor produtos abaixo de 5.")
	_check(GameManager.money == 938, "Script completo deve descontar apenas a compra valida.")

func _run_code(code: String) -> void:
	_debug_text = ""
	var interpreter := Interpreter.new()
	interpreter.steps_per_frame = 1000
	add_child(interpreter)
	interpreter.run(code, EnvContext.new([], 0, []))

	var guard := 0
	while interpreter.executor_flag and guard < 60:
		guard += 1
		await get_tree().process_frame

	if interpreter.executor_flag:
		_check(false, "Execucao do script excedeu o limite de frames.")
		interpreter.stop_execution()

	interpreter.queue_free()
	await get_tree().process_frame

func _reset_stock() -> void:
	for item in StockSystem.get_stock():
		item.quantity = 0
		item.max_quantity = 10
	GameManager.money = 0

func _set_quantities(values: Array) -> void:
	_reset_stock()
	for i in range(values.size()):
		StockSystem.get_stock()[i].quantity = int(values[i])

func _stock_quantities() -> Array:
	var quantities := []
	for item in StockSystem.get_stock():
		quantities.append(int(item.quantity))
	return quantities

func _on_update_money(amount: int) -> void:
	GameManager.money += amount

func _on_send_debug(text: String) -> void:
	_debug_text = text

func _check(condition: bool, message: String) -> void:
	if not condition:
		_failures.append(message)
