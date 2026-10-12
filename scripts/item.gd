class_name Item
extends RefCounted
## One item that can be bought from a customer, held in inventory, and sold.

var name: String
var category: String
var condition: int              # 0-100
var defects: Array[String] = []
var estimated_value: int        # what the player believes it's worth in mint condition
var actual_value: int           # hidden "true" mint value; customers price off this
var purchase_price := -1        # what the shop paid (-1 = not owned yet)
var on_display := false


## Condition scales value: a wrecked item is worth 40% of a mint one.
static func condition_factor(cond: int) -> float:
	return 0.4 + 0.6 * cond / 100.0


## What the player *thinks* it's worth right now.
func estimated_worth() -> int:
	return int(estimated_value * condition_factor(condition))


## What it's *actually* worth right now (hidden from the player).
func market_value() -> int:
	return int(actual_value * condition_factor(condition))


## Fixes one visible defect. Returns false if there was nothing to fix.
func clean() -> bool:
	if defects.is_empty():
		return false
	defects.pop_front()
	condition = mini(condition + 20, 100)
	return true


func describe() -> String:
	var lines := PackedStringArray([
		"Category: %s" % category,
		"Condition: %d%%" % condition,
		"Defects: %s" % ("none" if defects.is_empty() else ", ".join(PackedStringArray(defects))),
		"Estimated value (mint): $%d" % estimated_value,
		"Estimated value (as-is): $%d" % estimated_worth(),
	])
	if purchase_price >= 0:
		lines.append("You paid: $%d" % purchase_price)
	return "\n".join(lines)
