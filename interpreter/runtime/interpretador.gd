extends Node
class_name Interpreter

signal execution_started
signal execution_finished
 
@export var debug = false
var executor = Executor.new()
var executor_flag := false
var erros: Array = []
var saidas: Array[String] = []
var _tem_erro_fatal := false
var _tempo_inicio: int = 0
var _execution_active := false
 
# ─── Registro de erros ────────────────────────────────────────────────────────
 
## Erros de parse/lexer: acumula e continua (para reportar múltiplos erros)
func registrar_erro(msg: String, linha: int = -1, coluna: int = -1,
		tipo: ErroInterpretador.TipoErro = ErroInterpretador.TipoErro.RUNTIME) -> void:
	var e = ErroInterpretador.new(msg, linha, coluna, tipo)
	erros.append(e)
	print("[Interpreter] ", e.formatar())
 
## Erros de runtime: para imediatamente e emite debug
func erro_runtime(msg: String, linha: int = -1, coluna: int = -1) -> void:
	registrar_erro(msg, linha, coluna, ErroInterpretador.TipoErro.RUNTIME)
	_tem_erro_fatal = true
	_finish_execution()
	_emitir_erros()
 
## Para a execução imediatamente (alias de erro_runtime, aceita tipo customizado)
func erro_fatal(msg: String, linha: int = -1, coluna: int = -1,
		tipo: ErroInterpretador.TipoErro = ErroInterpretador.TipoErro.RUNTIME) -> void:
	registrar_erro(msg, linha, coluna, tipo)
	_tem_erro_fatal = true
	_finish_execution()
	_emitir_erros()
 
func tem_erros() -> bool:
	return erros.size() > 0
 
func _formatar_erros() -> String:
	var linhas := []
	for e in erros:
		linhas.append(e.formatar())
	return "\n".join(linhas)

func emitir_saida(texto: String) -> void:
	saidas.append(texto)
	EventBus.emit_signal("send_debug", "\n".join(saidas))
 
# ─── Pipeline principal ───────────────────────────────────────────────────────
 
func run(codigo: String, context) -> void:
	_finish_execution()
	erros.clear()
	saidas.clear()
	EventBus.emit_signal("send_debug", "")
	_tem_erro_fatal = false
	executor_flag = false
	_execution_active = false
	_tempo_inicio = Time.get_ticks_msec()
 
	# 1. Tokenizar
	var lexer = Lexer.new(codigo)
	lexer.interpreter = self
	var tokens = lexer.tokenize()
 
	if tem_erros():
		_emitir_erros()
		return
 
	if debug:
		TokenPrinter.new().print_tokens(tokens)
 
	# 2. Parser
	var parser = Parser.new(tokens)
	parser.interpreter = self
	var ast = parser.parse()
 
	if tem_erros():
		_emitir_erros()
		return
 
	if debug:
		parser.print_parser()
		var printer = ASTPrinter.new()
		printer.print_ast(ast)
 
	# 3. Executor
	executor.load_program(ast, context)
	executor.interpreter = self
	_start_execution()

func stop_execution() -> void:
	_finish_execution()

func _start_execution() -> void:
	if executor_flag and _execution_active:
		return
	executor_flag = true
	_execution_active = true
	emit_signal("execution_started")

func _finish_execution() -> void:
	var was_active := _execution_active or executor_flag
	executor_flag = false
	if executor != null:
		executor.is_finished = true
	_execution_active = false
	if was_active:
		emit_signal("execution_finished")
 
# ─── Loop de execução ─────────────────────────────────────────────────────────
 
var steps_per_frame = 1
 
func _process(_delta: float) -> void:
	if executor == null or not executor_flag:
		return
 
	if executor.is_finished:
		_finish_execution()
		_emitir_sucesso()
		return
 
	for _i in range(steps_per_frame):
		executor.step()
 
		if _tem_erro_fatal or executor.is_finished:
			break
 
	if tem_erros():
		_finish_execution()
		_emitir_erros()
	elif executor.is_finished:
		_finish_execution()
		_emitir_sucesso()
 
# ─── Saída ────────────────────────────────────────────────────────────────────
 
func _emitir_erros() -> void:
	if erros.is_empty():
		return
	var texto = _formatar_erros()
	if not saidas.is_empty():
		texto = "\n".join(saidas) + "\n" + texto
	print("[Interpreter] Erros:\n", texto)
	EventBus.emit_signal("send_debug", texto)
 
func _emitir_sucesso() -> void:
	if tem_erros():
		return
	if not saidas.is_empty():
		return
	var ms = Time.get_ticks_msec() - _tempo_inicio
	var texto = "Executado em %dms" % ms
	print("[Interpreter] ", texto)
	EventBus.emit_signal("send_debug", texto)
