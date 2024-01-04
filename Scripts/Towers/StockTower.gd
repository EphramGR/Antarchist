extends Tower

onready var sprite = get_node("Sprite")
const stockMarket = preload("res://Scenes/StockMarket.tscn")
var stockMarketInstance

var first = true

#logic
var currentAmount = 1
var ownedStock = {}
var buyPrice = {}
var currentCooldown = {}
var stockPrices
var pause = 0

#settings
var minPurchase = 1
var maxPurchase = 5
var inc = 1
var cooldown = 20 #sec *2

var insiderInfo = false
var lastInfoTime = 0
const infoCooldown = 1000
const infoDuration = 500
var exclamationPosition = Vector2(70,5)
var exclamationVisible = false

var advertising = false
const advertisingDuration = 5
var advertisingCost = 500
var advertisingCooldown = 10000
var currentBoostDuration = 0

var tradeingFirm = false
var currentCashToTrade = 25000
var lastRechargeTime = 0
const cashToTrade = 2500
const percentOfProfits = 0.1
const rechargeTime = 10000

var bbook = false
var bot = false
var lastPrice = {}

#Saveing variables
var stocks

func _ready():
	actualRange = 0
	RANGE = 0
	
	updatePerkTree()
	
	if mint:
		sprite.texture = load("res://Assets/Buildings/Towers/Stock/stock_0_mint.png")
	
func updateStats():
	stats = {
		"Min Amount":minPurchase,
		"Max Amount":maxPurchase,
		"Sell Cooldown":cooldown*2
	}
	
func updatePerkTree():
	upgrades = {
		"Quick Withdraws":[],
		"Bigger Money Cap":["Quick Withdraws"],
		"Fastest Withdraws":["Bigger Money Cap"],
		"Insider Info":["Fastest Withdraws"],
		"Even Bigger Money Cap":["Bigger Money Cap"],
		"Advertising":["Even Bigger Money Cap"],
		"Fast Withdraws":["Bigger Money Cap"],
		"Trading Firm":["Fast Withdraws"],
		"B-Booking":["Trading Firm"],
		"Influencer":["Advertising"],
		"Market Manipulation":["Advertising"],
		"Bot Trading":["Trading Firm"]
	}
	descriptions = {
		"Quick Withdraws":"Slightly decreases withdraw time.",
		"Bigger Money Cap":"Can invest more money into stocks.",
		"Even Bigger Money Cap":"Can invest more money into stocks.",
		"Advertising":"Can pay money to have garenteed increase in chosen stock for x seconds.",
		"Influencer":"Influence is now free, but has cooldown.",
		"Market Manipulation":"Influence no longer has a cooldown.",
		"Fastest Withdraws":"Drastically decreases withdraw time.",
		"Insider Info":"Occasionaly get hints when a stock will increase in the short term.",
		"Fast Withdraws":"Decreases withdraw time.",
		"Trading Firm":"Get x money to trade with per round and gain 10% of its profits, but take 0% of its losses. Can no longer invest your own money.",
		"B-Booking":"Profits come out fo your pocket, but take 100% of its losses.",
		"Bot Trading":"Bots trade the stocks randomly, giving passive rewards."
	}
	upgradeSprites = {
		"Quick Withdraws": Perks.stockUpgrades[Perks.stock.quickWithdraw],
		"Bigger Money Cap": Perks.stockUpgrades[Perks.stock.biggerMoney],
		"Even Bigger Money Cap": Perks.stockUpgrades[Perks.stock.evenBiggerMoney],
		"Advertising": Perks.stockUpgrades[Perks.stock.advertise],
		"Influencer": Perks.stockUpgrades[Perks.stock.influencer],
		"Market Manipulation": Perks.stockUpgrades[Perks.stock.marketManipulation],
		"Fastest Withdraws": Perks.stockUpgrades[Perks.stock.fastestWithdraws],
		"Insider Info": Perks.stockUpgrades[Perks.stock.insiderInfo],
		"Fast Withdraws": Perks.stockUpgrades[Perks.stock.fastWithdraws],
		"Trading Firm": Perks.stockUpgrades[Perks.stock.tradingFirm],
		"B-Booking": Perks.stockUpgrades[Perks.stock.bbooking],
		"Bot Trading": Perks.stockUpgrades[Perks.stock.bot]
	}
	prices = {
		"Quick Withdraws": 125*Perks.upgradeCostMult,
		"Bigger Money Cap": 600*Perks.upgradeCostMult,
		"Even Bigger Money Cap": 750*Perks.upgradeCostMult,
		"Advertising": 1250*Perks.upgradeCostMult,
		"Influencer": 2750*Perks.upgradeCostMult,
		"Market Manipulation": 2250*Perks.upgradeCostMult,
		"Fastest Withdraws": 2500*Perks.upgradeCostMult,
		"Insider Info": 2000*Perks.upgradeCostMult,
		"Fast Withdraws": 300*Perks.upgradeCostMult,
		"Trading Firm": 2500*Perks.upgradeCostMult,
		"B-Booking": 3000*Perks.upgradeCostMult,
		"Bot Trading": 3000*Perks.upgradeCostMult
	}

	
func updateUpgrade(upgrade: String) -> void:
	if upgrade == "Quick Withdraws":
		# Code for "Quick Withdraws" upgrade
		cooldown *= 0.8

	elif upgrade == "Bigger Money Cap":
		# Code for "Bigger Money Cap" upgrade
		maxPurchase += 2

	elif upgrade == "Even Bigger Money Cap":
		# Code for "Even Bigger Money Cap" upgrade
		maxPurchase += 3

	elif upgrade == "Advertising":
		# Code for "Advertising" upgrade
		advertising = true

	elif upgrade == "Influencer":
		# Code for "Influencer" upgrade
		advertisingCost = 0

	elif upgrade == "Market Manipulation":
		# Code for "Market Manipulation" upgrade
		advertisingCooldown = 0

	elif upgrade == "Fastest Withdraws":
		# Code for "Fastest Withdraws" upgrade
		cooldown *= 0.7

	elif upgrade == "Insider Info":
		# Code for "Insider Info" upgrade
		insiderInfo = true

	elif upgrade == "Fast Withdraws":
		# Code for "Fast Withdraws" upgrade
		cooldown *= 0.85

	elif upgrade == "Trading Firm":
		# Code for "Trading Firm" upgrade
		tradeingFirm = true

	elif upgrade == "B-Booking":
		# Code for "B-Booking" upgrade
		bbook = true

	elif upgrade == "Bot Trading":
		# Code for "Bot Trading" upgrade
		bot = true

	else:
		print("Upgrade not found.")
		

	
func _process(delta):
	if not game.isWaveActive():
		delta = 0
	
	
	for stock in currentCooldown:
		if currentCooldown[stock] > 0:
			currentCooldown[stock] -= delta
			
	if currentBoostDuration > 0:
		currentBoostDuration -= delta
		
	if tradeingFirm:
		var thisTime = TimeScaler.stockTime()
		if thisTime - lastRechargeTime > rechargeTime:
			currentCashToTrade = cashToTrade
		
			if bot:
				if stockMarketInstance != null and is_instance_valid(stockMarketInstance):
					stockMarketInstance.botTrading()
				else:
					createSneakyMarket()
					
			lastRechargeTime = thisTime
			
		

func toggleSelected():
	if selected:
		createMarket()
	else:
		eraseMarket()
		
func createSneakyMarket():
	var market = stockMarket.instance()
	market.tower = self
	
	market.stocks = stocks
	market.stockPrices = stockPrices
	market.visible = false
	
	market.sneaky = true
	
	game.add_child(market)
		
func createMarket():
	stockMarketInstance = stockMarket.instance()
	stockMarketInstance.tower = self
	
	if first:
		stockMarketInstance.generateStockNames()
		first = false
	else:
		stockMarketInstance.stocks = stocks
		stockMarketInstance.stockPrices = stockPrices
		
	game.add_child(stockMarketInstance)
	var exitButton = stockMarketInstance.get_node("UI/Background/Exit")
	exitButton.connect("pressed", self, "onExitButtonPressed")
	
func onExitButtonPressed():
	if not confirmDelete:
		stockPrices = stockMarketInstance.stockPrices
		handleDeselect(true)
		game.toggleSkillTreeButtonForStock()
	
func handleDeselect(exit=false):
	if exit:
		if confirmDelete:
			confirmDelete = false
		else:
			selected = false
			game.buttonsEnabled = true
			toggleSelected()
			
func upgradePressed()->void:
	onExitButtonPressed()
	stockMarketInstance.queue_free()
	
func cleanUp():
	eraseMarket()
	
func eraseMarket():
	if stockMarketInstance != null:
		stocks = stockMarketInstance.stocks
		stockMarketInstance.queue_free()
		
func confirmPurchase():
	var cost = stockMarketInstance.getCurrentPrice() * currentAmount
	
	if stockMarketInstance.selected != null and ((not tradeingFirm and game.money >= cost) or currentCashToTrade >= cost):
		#check if have enough money
		ownedStock[stockMarketInstance.selected] += currentAmount
		if buyPrice[stockMarketInstance.selected] == null:
			buyPrice[stockMarketInstance.selected] = cost
		else:
			buyPrice[stockMarketInstance.selected] += cost
		currentCooldown[stockMarketInstance.selected] = cooldown
		
		if tradeingFirm and currentCashToTrade >= cost:
			currentCashToTrade -= cost
		elif game.money >= cost:
			game._addMoney(-1*cost)
		
	
func sellStock():
	if stockMarketInstance.selected != null and currentCooldown[stockMarketInstance.selected] <= 0:
		var moneyGained = 0
		if not tradeingFirm:
			#give money
			moneyGained = ownedStock[stockMarketInstance.selected] * stockMarketInstance.getCurrentPrice()
			
			
		elif not bbook:
			moneyGained = percentOfProfits * max(ownedStock[stockMarketInstance.selected] * (stockMarketInstance.getCurrentPrice() - buyPrice[stockMarketInstance.selected]), 0)
		else:
			moneyGained = max(ownedStock[stockMarketInstance.selected] * (buyPrice[stockMarketInstance.selected] - stockMarketInstance.getCurrentPrice()), 0)
		
		game._addMoney(moneyGained)
		
		ownedStock[stockMarketInstance.selected] = 0
		buyPrice[stockMarketInstance.selected] = null
			
	
