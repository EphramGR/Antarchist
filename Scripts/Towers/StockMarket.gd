extends CanvasLayer

var tower

onready var text = get_node("UI/Background/Text")
onready var maxText = get_node("UI/Background/MaxPrice")
onready var midText = get_node("UI/Background/MidPrice")
onready var minText = get_node("UI/Background/MinPrice")
onready var gainText = get_node("UI/Background/Gain")
onready var cooldown = get_node("UI/Background/Cooldown")
onready var currentValueText = get_node("UI/Background/CurrentStocks")
onready var itemList = get_node("UI/Background/StockNames")
onready var stockLine = get_node("UI/Background/ReferenceRect/Line2D")
onready var referenceRect = get_node("UI/Background/ReferenceRect")
onready var lineOffset = referenceRect.rect_position/2 + referenceRect.rect_size/2 + Vector2(9, -11)
onready var exclamation = get_node("UI/Background/Exclamation")

const exclamationOffset = 35
const exclamationPosition = 70

onready var MIN = Vector2(7,9) + lineOffset
onready var MAX = Vector2(500,300) + lineOffset

var minInterval = 5000 #ms *2
var maxInterval = 100000
var visualTimeScale = 0.001

var maxPrice = 1000
var minPrice = 1

var stocks = {}
var stockPrices = {}
var selected = null

var sneaky:bool = false

func _ready():
	createStockItems()
	for stock in stocks:
		if stocks[stock].size() == 0:
			generatePointsForStock(stock, TimeScaler.stockTime(), 25)
			
	exclamation.visible = tower.exclamationVisible
	exclamation.rect_position = tower.exclamationPosition
	
	get_node("UI/Background/Boost").visible = tower.advertising
	
	if tower.bot:
		if sneaky:
			botTrading()
			queue_free()
			
		else:
			handleBotChanges()
		
func botTrading():
	for stock in stocks:
		var p1:float = getPriceOfAt(stock, TimeScaler.stockTime())
		var p2:float
		
		if stock in tower.lastPrice:
			p2 = tower.lastPrice[stock]
		else:
			tower.lastPrice[stock] = p1
			continue
			
		var dif:float
		
		if tower.bbook:
			dif = max(p2-p1, 0) * (500/p2)
		else:
			dif = (max(p1 - p2, 0) * tower.percentOfProfits) * (500/p2)
		
		print("gain ", dif)
		tower.game._addMoney(round(dif))
		
		tower.lastPrice[stock] = p1
		
func handleBotChanges():
	for stock in stocks:
		
		if stock in tower.lastPrice:
			tower.ownedStock[stock] = round(500/tower.lastPrice[stock])
			
	get_node("UI/Background/Check").visible = false
	get_node("UI/Background/Minus").visible = false
	get_node("UI/Background/Plus").visible = false
	get_node("UI/Background/Sell").visible = false
	
		
		

func generateStockNames(amount:int = 5):
	var alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	
	while amount > 0:
		var string = ""
		
		for _j in range(3):
			var random_index = randi() % alphabet.length()
			var random_letter = alphabet[random_index]
			string += random_letter
		
		if not string in stocks:
			stocks[string] = []
			tower.ownedStock[string] = 0
			tower.buyPrice[string] = null
			tower.currentCooldown[string] = 0
			stockPrices[string] = getRandomPriceRange()
			amount -= 1
	
func createStockItems()->void:
	for stock in stocks:
		itemList.add_item(stock)


func _on_StockNames_item_selected(index:int)->void:
	selected = itemList.get_item_text(index)
	updateMinMidMax()
	
func generatePoints(currentTime:int = 0, amount:int=100)->void:
	var time = currentTime
	var points = stocks[selected]
	
	for i in range(amount):
		points.append(generatePoint(time))
		time += rand_range(maxInterval, minInterval)
		
func generatePoint(time:float)->Vector2:
	return Vector2(time, rand_range(stockPrices[selected].x, stockPrices[selected].y))
	
	
func generatePointsForStock(stock:String, currentTime:int = 0, amount:int=100)->void:
	var time = currentTime
	var points = stocks[stock]
	
	for i in range(amount):
		points.append(generatePointForStock(time,stock))
		time += rand_range(maxInterval, minInterval)
		
func generatePointForStock(time:float,stock:String)->Vector2:
	return Vector2(time, rand_range(stockPrices[stock].x, stockPrices[stock].y))
	
func _process(delta:float)->void:
	if not tower.game.isWaveActive():
		handleTimeStall(delta*1000)
	drawPoints()
	updateDisplay()
	if tower.insiderInfo:
		giveHints()
	
		
func handleTimeStall(delta:float):
	tower.lastInfoTime += delta
		
func giveHints()->void:
	if TimeScaler.stockTime()-tower.lastInfoTime > tower.infoCooldown:
		
		var hint:String = getPositiveStock()
		
		if hint != null:
			exclamation.visible = true
			exclamation.rect_position = Vector2(exclamationPosition, (exclamationOffset*stocks.keys().find(hint)))
			
			tower.exclamationVisible = true
			tower.exclamationPosition = exclamation.rect_position

		
		tower.lastInfoTime = TimeScaler.stockTime() + tower.infoDuration
		
	elif exclamation.visible and TimeScaler.stockTime()-tower.lastInfoTime > 0:
		exclamation.visible = false
		tower.exclamationVisible = false
		
func getPositiveStock() -> String:
	var biggestDifference = 0
	var bestStock:String
	
	for stock in stocks:
		var currentPrice = getPriceOfAt(stock, TimeScaler.stockTime())
		var futurePrice = getPriceOfAt(stock, TimeScaler.stockTime()+tower.cooldown)
		
		if futurePrice - currentPrice > biggestDifference:
			biggestDifference = futurePrice - currentPrice
			bestStock = stock
	
	#print(bestStock, biggestDifference)
	return bestStock
	
func getPriceOfAt(stock:String, time:float)->float:
	var previousOutOfBounds = true
	var points = stocks[stock]
	
	var minPric = stockPrices[stock].x
	var maxPric = stockPrices[stock].y
	
	var visualPoints = []
	
	for i in range(points.size()):
		var x = (points[i].x - TimeScaler.stockTime())*visualTimeScale + MIN.x
		if x > MIN.x and x < MAX.x:
			var actualCoords = Vector2(x, (points[i].y-minPric)/(maxPric-minPric) * (MAX.y - MIN.y) + MIN.y)
			if previousOutOfBounds and i != 0:
				var previousCoords = Vector2((points[i-1].x - time)*visualTimeScale + MIN.x, (points[i-1].y-minPric)/(maxPric-minPric) * (MAX.y - MIN.y) + MIN.y)
				visualPoints.append(get_intersection_point(actualCoords, get_angle(actualCoords, previousCoords), MIN.x))
				previousOutOfBounds = false
				
			visualPoints.append(actualCoords)
			
		elif not previousOutOfBounds:
			var actualCoords = Vector2(x, (points[i].y-minPric)/(maxPric-minPric) * (MAX.y - MIN.y) + MIN.y)
			var previousCoords = Vector2((points[i-1].x - time)*visualTimeScale + MIN.x, (points[i-1].y-minPric)/(maxPric-minPric) * (MAX.y - MIN.y) + MIN.y)
			visualPoints.append(get_intersection_point(previousCoords, get_angle(previousCoords, actualCoords), MAX.x))
			break
	
	if visualPoints.size() == 0:
		return 0.0
	
	var y = visualPoints[(visualPoints.size() - 1)].y
	
	y = maxPric - ((y-MIN.y)/(MAX.y - MIN.y) * (maxPric-minPric) + minPric)
	
	#print(stock, " in ", time - TimeScaler.stockTime(), " ms will be ", round(y))
	
	return round(y)
	
func getRandomPriceRange(ROUND:int = 10, min_value: int = minPrice, max_value: int = maxPrice) -> Vector2:
	var RANGE = max_value - min_value + 1
	var third = RANGE / 3
	return Vector2(round((randi() % third + min_value)/ROUND)*ROUND, round((randi() % third + (max_value - third + 1))/ROUND)*ROUND)
	
func drawPoints()->void:
	if selected != null:
		stockLine.clear_points()
		
		var previousOutOfBounds = true
		var remove = []
		var points = stocks[selected]
		
		var minPric = stockPrices[selected].x
		var maxPric = stockPrices[selected].y
		
		
		for i in range(points.size()):
			var x = (points[i].x - TimeScaler.stockTime())*visualTimeScale + MIN.x
			if x > MIN.x and x < MAX.x:
				var actualCoords = Vector2(x, (points[i].y-minPric)/(maxPric-minPric) * (MAX.y - MIN.y) + MIN.y)
				if previousOutOfBounds and i != 0:
					var previousCoords = Vector2((points[i-1].x - TimeScaler.stockTime())*visualTimeScale + MIN.x, (points[i-1].y-minPric)/(maxPric-minPric) * (MAX.y - MIN.y) + MIN.y)
					stockLine.add_point(get_intersection_point(actualCoords, get_angle(actualCoords, previousCoords), MIN.x))
					previousOutOfBounds = false
					
					if i >= 2:
						for j in range(i-1):
							remove.append(points[j])
					
				stockLine.add_point(actualCoords)
				
			elif not previousOutOfBounds:
				var actualCoords = Vector2(x, (points[i].y-minPric)/(maxPric-minPric) * (MAX.y - MIN.y) + MIN.y)
				var previousCoords = Vector2((points[i-1].x - TimeScaler.stockTime())*visualTimeScale + MIN.x, (points[i-1].y-minPric)/(maxPric-minPric) * (MAX.y - MIN.y) + MIN.y)
				stockLine.add_point(get_intersection_point(previousCoords, get_angle(previousCoords, actualCoords), MAX.x))
				break
				
		if previousOutOfBounds:
			generatePoints(TimeScaler.stockTime())
				
		for i in range(remove.size()):
			points.erase(remove[i])
			if tower.pause <= 0:
				generateNewPoint()
			else: 
				tower.pause -= 1
			
		
		if tower.currentBoostDuration > 0:
			stockLine.default_color = Color(1-tower.currentBoostDuration/tower.advertisingDuration,1-tower.currentBoostDuration/tower.advertisingDuration,1)
		else:
			stockLine.default_color = Color.white

func generateNewPoint():
	var points = stocks[selected]
	points.append(generatePoint(points[points.size()-1].x + rand_range(maxInterval, minInterval)))

func get_intersection_point(pointA: Vector2, angleA: float, intersectX: int) -> Vector2:
	var slopeA = tan(angleA)
	var intersectY = pointA.y + (intersectX - pointA.x) * slopeA
	var intersectionPoint = Vector2(intersectX, intersectY)
	return intersectionPoint
	
func get_angle(startPoint: Vector2, endPoint: Vector2) -> float:
	var direction = endPoint - startPoint
	var angle = direction.angle()
	return angle
	
func setText():
	var currentPrice = getCurrentPrice()
	text.bbcode_text = "[center]" + String(tower.currentAmount) + " for " + String(currentPrice) + " per = " + String(tower.currentAmount * currentPrice)
	
func getCurrentPrice():
	if stockLine.get_point_count() == 0:
		return 0
	
	var y = stockLine.get_point_position(stockLine.get_point_count() - 1).y
	
	var minPric = stockPrices[selected].x
	var maxPric = stockPrices[selected].y
	
	y = maxPric - ((y-MIN.y)/(MAX.y - MIN.y) * (maxPric-minPric) + minPric)
	return round(y)


func updateDisplay():
	setText()
	
	var thisStock = 0
	var thisGain = null
	
	if selected != null:
		thisStock = tower.ownedStock[selected]
		thisGain = tower.buyPrice[selected]
		var currentCooldown = tower.currentCooldown[selected]
		
		if currentCooldown > 0:
			cooldown.text = "Cooldown: " + String("%.1f"%float(round(currentCooldown*2*10)/10))
		else: 
			cooldown.text = ""
	else:
		cooldown.text = ""
		
	currentValueText.text = "Current Stock: " + String(thisStock) + "\nCurrent Value: " + String(thisStock * getCurrentPrice())

	if thisGain != null:
		var text = "[center]"
		thisGain = float(round((getCurrentPrice()*tower.ownedStock[selected] - thisGain)/thisGain *1000)/10)
		if thisGain >= 0:
			text += "[color=green]+"
		else:
			text += "[color=red]"
		text += String("%.1f"% thisGain) + "%"
		gainText.bbcode_text = text
	else:
		gainText.bbcode_text = ""

func updateMinMidMax():
	minText.text = String(stockPrices[selected].x)
	maxText.text = String(stockPrices[selected].y)
	midText.text = String((stockPrices[selected].x + stockPrices[selected].y )/ 2)
	
	
func getFarthestVisibleStock():
	var points = stocks[selected]
	
	for i in range(points.size()):
		var x = (points[i].x - TimeScaler.stockTime())*visualTimeScale + MIN.x
		if x > MAX.x:
			return i - 1
			
func _on_Check_pressed():
	tower.confirmPurchase()


func _on_Plus_pressed():
	tower.currentAmount = min(tower.currentAmount + tower.inc, tower.maxPurchase)


func _on_Minus_pressed():
	tower.currentAmount = max(tower.currentAmount - tower.inc, tower.minPurchase)


func _on_Sell_pressed():
	tower.sellStock()

func _on_Boost_pressed():
	if selected != null and tower.advertising and tower.game.money >= tower.advertisingCost:
		tower.game._addMoney(-1*tower.advertisingCost)
		
		tower.currentBoostDuration += tower.advertisingDuration
		stocks[selected][stocks[selected].size()-1].x = TimeScaler.stockTime()
		
		var index = getFarthestVisibleStock() + 1
		
		var minPric = stockPrices[selected].x
		var maxPric = stockPrices[selected].y
		
		var x = (MAX.x-MIN.x)/visualTimeScale + TimeScaler.stockTime()
		var y = stockLine.get_point_position(stockLine.get_point_count() - 1).y
		y = ((y-MIN.y)/(MAX.y-MIN.y))*(maxPric-minPric)+minPric
		
		stocks[selected].insert(index, Vector2(x, y))
		
		
		#NOTE: since the final price is inverted, somethign that is stored at 0 price is max, adn viseversa
		stocks[selected][index+1] = Vector2(x + rand_range(maxInterval, minInterval)/2, rand_range(stockPrices[selected].x, y))
		
		tower.pause += 1
		
		print(stocks[selected][index], stocks[selected][index+1])
