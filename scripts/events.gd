extends Node

var context

signal send_output(id,args)

signal catch_input(id)

signal redraw_buttons()

signal input_submitted(text)

signal end_client(result)

signal update_money(num)

signal open_client_terminal()

signal update_context(context)

signal update_state(new_state)
