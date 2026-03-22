extends Node

var first_card = null
var second_card = null
var checking := false


func card_flipped(card):
	if checking:
		return

	if first_card == null:
		first_card = card
		
	elif second_card == null and card != first_card:
		second_card = card
		check_match()

func check_match():
	checking = true
	
	if first_card.card_id == second_card.card_id:
		first_card.set_matched()
		second_card.set_matched()
	else:
		await get_tree().create_timer(1.0).timeout
		first_card.flip_back()
		second_card.flip_back()
	
	reset_selection()
	checking = false

func reset_selection():
	first_card = null
	second_card = null
