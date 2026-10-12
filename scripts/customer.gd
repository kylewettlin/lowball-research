class_name Customer
extends RefCounted
## A customer at the front desk who either wants to sell the shop an item
## or buy one off the display case. Handles their side of the haggling.

enum Kind { SELLER, BUYER }

var kind: Kind
var item: Item
var target_price: int   # the price the customer is currently asking/offering
var limit_price: int    # seller: lowest they'll go. buyer: highest they'll pay
var patience := 3       # bad offers before they walk out


static func new_seller(for_sale: Item) -> Customer:
	var c := Customer.new()
	c.kind = Kind.SELLER
	c.item = for_sale
	c.target_price = int(for_sale.market_value() * randf_range(0.8, 1.1))
	c.limit_price = int(c.target_price * randf_range(0.6, 0.8))
	return c


static func new_buyer(wanted: Item) -> Customer:
	var c := Customer.new()
	c.kind = Kind.BUYER
	c.item = wanted
	c.limit_price = int(wanted.market_value() * randf_range(1.0, 1.3))
	c.target_price = int(c.limit_price * 0.7)
	return c


func opening_line() -> String:
	var item_name := item.name.to_lower()
	if kind == Kind.SELLER:
		return "I'd like $%d for this %s. %s" % [target_price, item_name, _hint()]
	return "I've had my eye on that %s. I'll give you $%d for it." % [item_name, target_price]


## A loose clue about the hidden actual value, so reading dialogue matters.
func _hint() -> String:
	var ratio := float(item.actual_value) / item.estimated_value
	if ratio > 1.2:
		return "My grandpa always said it was a rare one."
	if ratio < 0.8:
		return "It works fine... mostly. I just need it gone today."
	return "It's in about the shape you'd expect."


## The player names a price. Returns {result, price, line} where result is
## "accept", "counter", "reject", or "leave".
func respond(offer: int) -> Dictionary:
	if kind == Kind.SELLER:
		if offer >= target_price:
			return _reply("accept", offer, "Deal. $%d works for me." % offer)
		if offer >= limit_price:
			target_price = int((offer + target_price) * 0.5)
			if target_price - offer <= 5:
				return _reply("accept", target_price, "Fine, fine. $%d it is." % target_price)
			return _reply("counter", target_price, "Hmm... meet me at $%d?" % target_price)
	else:
		if offer <= target_price:
			return _reply("accept", offer, "Sold! $%d works for me." % offer)
		if offer <= limit_price:
			target_price = int((offer + target_price) * 0.5)
			if offer - target_price <= 5:
				return _reply("accept", offer, "Alright, you twisted my arm. $%d." % offer)
			return _reply("counter", target_price, "That's steep. How about $%d?" % target_price)

	patience -= 1
	if patience <= 0:
		return _reply("leave", 0, "Forget it. I'm out of here.")
	if kind == Kind.SELLER:
		return _reply("reject", 0, "Ha! That's insulting. Try again.")
	return _reply("reject", 0, "No way I'm paying that. Try again.")


func _reply(result: String, price: int, line: String) -> Dictionary:
	return {"result": result, "price": price, "line": line}
