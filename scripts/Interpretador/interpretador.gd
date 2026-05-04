extends Node
class_name Interpreter

@export var debug = false

var executor = Executor.new()
var executor_flag := false
var erros: Array = []
var _tem_erro_fatal := false

# ─── Registro de erros ────────────────────────────────────────────────────────

## Erros de parse/lexer: acumula e continua (para reportar múltiplos erros)
func registrar_erro(msg: String, linha: int = -1, coluna: int = -1,
		tipo: ErroInterpretador.TipoErro = ErroInterpretador.TipoErro.RUNTIME) -> void:
	erros.append(ErroInterpretador.new(msg, linha, coluna, tipo))

## Erros de runtime: para imediatamente para não crashar a Godot
func erro_runtime(msg: String, linha: int = -1, coluna: int = -1) -> void:
	registrar_erro(msg, linha, coluna, ErroInterpretador.TipoErro.RUNTIME)
	_tem_erro_fatal = true
	executor_flag = false
	executor.is_finished = true

## Para a execução imediatamente (alias de erro_runtime, aceita tipo customizado)
func erro_fatal(msg: String, linha: int = -1, coluna: int = -1,
		tipo: ErroInterpretador.TipoErro = ErroInterpretador.TipoErro.RUNTIME) -> void:
	registrar_erro(msg, linha, coluna, tipo)
	_tem_erro_fatal = true
	executor_flag = false
	executor.is_finished = true

func tem_erros() -> bool:
	return erros.size() > 0

func _formatar_erros() -> String:
	var linhas := []
	for e in erros:
		linhas.append(e.formatar())
	return "\n".join(linhas)

# ─── Pipeline principal ───────────────────────────────────────────────────────

func run(codigo: String, context) -> void:
	erros.clear()
	_tem_erro_fatal = false
	executor_flag = false

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
	executor_flag = true

# ─── Loop de execução ─────────────────────────────────────────────────────────

var steps_per_frame = 1

func _process(_delta: float) -> void:
	if executor == null or not executor_flag:
		return
	if executor.is_finished:
		executor_flag = false
		return

	for _i in range(steps_per_frame):
		# Captura qualquer erro não tratado que possa vir do executor
		executor.step()

		if _tem_erro_fatal or executor.is_finished:
			break

	# Verifica se erros foram acumulados durante a execução
	if tem_erros():
		executor_flag = false
		executor.is_finished = true
		_emitir_erros()

# ─── Saída de erros ───────────────────────────────────────────────────────────

func _emitir_erros() -> void:
	var texto = _formatar_erros()
	if debug:
		print("[Interpreter] Erros encontrados:\n", texto)
	Eventos.emit_signal("send_debug", texto)
