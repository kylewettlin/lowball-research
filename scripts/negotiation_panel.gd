class_name NegotiationPanel
extends CenterContainer
## Front-desk haggling screen. Shows the item, the customer's dialogue, and lets
## the player make offers, take the customer's price, or send them away.

signal closed

var customer: Customer
var pending_price := 0

@onready var title_label: Label = %TitleLabel
@onready var item_label: Label = %ItemLabel
@onready var info_label: Label = %InfoLabel
@onready var dialogue_label: Label = %DialogueLabel
@onready var offer_row: HBoxContainer = %OfferRow
@onready var offer_spin: SpinBox = %OfferSpin
@onready var confirm_row: HBoxContainer = %ConfirmRow
@onready var confirm_button: Button = %ConfirmButton
@onready var leave_button: Button = %LeaveButton
@onready var done_button: Button = %DoneButton


func _ready() -> void:
	hide()
	%OfferButton.pressed.connect(_on_offer)
	%TakeButton.pressed.connect(_on_take_their_price)
	confirm_button.pressed.connect(_on_confirm)
	%BackOutButton.pressed.connect(_finish.bind("You back out of the deal. The customer storms off."))
	leave_button.pressed.connect(_finish.bind("You send the customer away."))
	done_button.pressed.connect(_on_done)


func open(c: Customer) -> void:
	customer = c
	var selling := c.kind == Customer.Kind.SELLER
	title_label.text = "Customer wants to SELL to you" if selling else "Customer wants to BUY from you"
	item_label.text = c.item.name
	info_label.text = c.item.describe()
	dialogue_label.text = "\"%s\"" % c.opening_line()
	offer_spin.value = c.target_price
	_set_mode("offer")
	show()


func _set_mode(mode: String) -> void:
	offer_row.visible = mode == "offer"
	leave_button.visible = mode == "offer"
	confirm_row.visible = mode == "confirm"
	done_button.visible = mode == "done"


func _on_offer() -> void:
	offer_spin.apply()
	var reply := customer.respond(int(offer_spin.value))
	dialogue_label.text = "\"%s\"" % reply["line"]
	match reply["result"]:
		"accept":
			_ask_confirm(reply["price"])
		"counter":
			offer_spin.value = reply["price"]
		"leave":
			_finish(dialogue_label.text + "\n\nThe customer leaves.")


func _on_take_their_price() -> void:
	dialogue_label.text = "\"Pleasure doing business.\""
	_ask_confirm(customer.target_price)


## Customer agreed; the player gets one last chance to back out.
func _ask_confirm(price: int) -> void:
	pending_price = price
	confirm_button.text = "Confirm deal at $%d" % price
	_set_mode("confirm")


func _on_confirm() -> void:
	var item := customer.item
	if customer.kind == Customer.Kind.SELLER:
		if not GameState.can_afford(pending_price):
			dialogue_label.text = "You can't afford $%d. You only have $%d. Make a lower offer." % [
				pending_price, GameState.money]
			_set_mode("offer")
			return
		GameState.buy_item(item, pending_price)
		_finish("You bought the %s for $%d." % [item.name, pending_price])
	else:
		var profit := pending_price - item.purchase_price
		GameState.sell_item(item, pending_price)
		_finish("You sold the %s for $%d (profit: $%d)." % [item.name, pending_price, profit])


func _finish(message: String) -> void:
	dialogue_label.text = message
	GameState.customer_done()
	_set_mode("done")


func _on_done() -> void:
	hide()
	closed.emit()
