extends Node

signal execution_finished(output)

signal execution_failed(errors)

signal send_output(id,args)

signal catch_input(id)

signal redraw_buttons()

signal input_submitted(text)

signal end_client(result)

signal update_money(num)

signal open_client_terminal()

signal update_context(context)

signal get_estoque()

signal send_estoque(estoque)

signal send_debug(text)
