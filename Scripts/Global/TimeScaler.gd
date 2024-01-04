extends Node
#Singletons (AutoLoad)
var timer_started = false
var elapsed_time = 0.0
var stock_time = 0.0

var prep:bool = true

func _ready() -> void:
	if !timer_started:
		timer_started = true
		set_process(true)

func _process(delta:float) -> void:
	var elapsed = delta * 1000.0
	
	elapsed_time += elapsed
	
	if not prep:
		stock_time += elapsed
	

func time() -> float:
	return elapsed_time
	
func stockTime() -> float:
	return stock_time
	
func antTime(factor:float) -> float:
	return elapsed_time * factor
	
	
func getWaveData(waveIndex:int):
	var file = File.new()
	if file.open("res://Scripts/waves.csv", File.READ) == OK:
		var waveData = []
		while !file.eof_reached():
			var line = file.get_line()
			if line.strip_edges().empty():
				continue
			waveData.append(line.split(","))
		file.close()
		
		
		
		var data = [null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null]
		
		if waveIndex >= waveData.size():
			waveIndex = waveData.size() - 1
		
		for i in range(waveData[waveIndex].size()):
			if not waveData[waveIndex][i].empty():
				data[i] = (int(waveData[waveIndex][i]))
			
		#print(data)
		return data

