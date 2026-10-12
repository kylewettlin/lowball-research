extends Node
## Global game data. Registered as the "GameState" autoload in Project Settings,
## so it survives scene changes (menu -> shop -> end of day -> shop ...).

const STARTING_MONEY := 500

const ITEM_TEMPLATES := [
	{"name": "Electric Guitar", "category": "Instruments", "base_value": 400,
		"defects": ["Scratched body", "Rusty strings", "Loose tuning peg"]},
	{"name": "Gold Watch", "category": "Jewelry", "base_value": 650,
		"defects": ["Cracked crystal", "Tarnished band"]},
	{"name": "Retro Game Console", "category": "Electronics", "base_value": 180,
		"defects": ["Yellowed plastic", "Dusty cartridge slot", "Frayed cable"]},
	{"name": "Power Drill", "category": "Tools", "base_value": 90,
		"defects": ["Worn chuck", "Dead battery"]},
	{"name": "Baseball Card", "category": "Collectibles", "base_value": 120,
		"defects": ["Bent corner", "Faded print"]},
	{"name": "Antique Lamp", "category": "Furniture", "base_value": 220,
		"defects": ["Dented shade", "Frayed cord", "Dusty"]},
]

var money: int
var day: int
var inventory: Array[Item] = []
var customers_left: int
var stats: Dictionary


func _ready() -> void:
	# Lets you run the shop scene directly (F6) without going through the menu.
	new_game()


func new_game() -> void:
	money = STARTING_MONEY
	day = 1
	inventory.clear()
	start_day()


func start_day() -> void:
	customers_left = 3 + day
	stats = {
		"start_money": money,
		"customers": 0,
		"bought_count": 0,
		"bought_value": 0,
		"sold_count": 0,
		"sold_value": 0,
	}


func next_day() -> void:
	day += 1
	start_day()


func can_afford(price: int) -> bool:
	return money >= price


func buy_item(item: Item, price: int) -> void:
	money -= price
	item.purchase_price = price
	inventory.append(item)
	stats["bought_count"] += 1
	stats["bought_value"] += price


func sell_item(item: Item, price: int) -> void:
	money += price
	inventory.erase(item)
	stats["sold_count"] += 1
	stats["sold_value"] += price


func customer_done() -> void:
	customers_left -= 1
	stats["customers"] += 1


func displayed_items() -> Array[Item]:
	var result: Array[Item] = []
	for item in inventory:
		if item.on_display:
			result.append(item)
	return result


## Half the time, if anything is on display, the next customer is a buyer.
func next_customer() -> Customer:
	var for_sale := displayed_items()
	if not for_sale.is_empty() and randf() < 0.5:
		return Customer.new_buyer(for_sale.pick_random())
	return Customer.new_seller(random_item())


func random_item() -> Item:
	var t: Dictionary = ITEM_TEMPLATES.pick_random()
	var item := Item.new()
	item.name = t["name"]
	item.category = t["category"]
	item.estimated_value = t["base_value"]
	item.actual_value = int(t["base_value"] * randf_range(0.6, 1.5))
	var pool: Array = t["defects"].duplicate()
	pool.shuffle()
	var defect_count := randi_range(0, pool.size())
	for i in defect_count:
		item.defects.append(pool[i])
	item.condition = clampi(95 - defect_count * 20 + randi_range(-5, 5), 5, 100)
	return item
