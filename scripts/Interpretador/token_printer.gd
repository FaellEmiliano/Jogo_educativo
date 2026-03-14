extends Node
class_name TokenPrinter


func print_tokens(tokens):
	var text = tokens_to_string(tokens)
	print(text)


func tokens_to_string(tokens) -> String:
	var lines := []

	lines.append("========== TOKENS ==========")
	lines.append("")

	var header = "%-6s %-6s %-20s %-15s"
	lines.append(header % ["LINE", "COL", "TYPE", "VALUE"])
	lines.append("-----------------------------------------------")

	for t in tokens:
		lines.append(token_line(t))

	lines.append("")
	lines.append("Total tokens: " + str(tokens.size()))
	lines.append("============================")

	return "\n".join(lines)


func token_line(token) -> String:

	var type_name = Token.TiposToken.keys()[token.type]

	var value = str(token.value)
	value = value.replace("\n", "\\n")

	return "%-6s %-6s %-20s %-15s" % [
		str(token.linha),
		str(token.coluna),
		type_name,
		value
	]
