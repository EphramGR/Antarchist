extends Node

#settings
var musicVolume = 1 #does nothing
var shootVolume = 1

#Singletons (AutoLoad)
#(
var sellPercent = 0.5
var startingCash:int = 750
var upgradeCostMult = 1
var cashFromKillMult = 1


var startingLumens:int = 4
var waveEndLumens:int = 4
var maxLumens:int = 10
#)

var reincarnationPercent = 0
var startingHp = 20#()
var maxSheildHits:int = -1
var regenPercent = 0#()

#(
var burnPercent = 0.05 #of max *100
var burnTickRate = 200 #ms x2
var maxBurnDuration = 2.5 # x2 5 sec

var poisionPercent = 0.13 #of current
var poisionTickRate = 200 #ms x2
var maxPoisionDuration = 2.5 # x2 5 sec

var maxSlowDuration = 2.5
var slowPercent = 0.7

var maxFreezeDuration = 0.3
var freezeImmunityDuration = 0.8*1000

var maxConfusionDuration = 0.5
var confusionImmunityDuration = 0.8*1000

var maxWeakenTime = 2.5
var weakenMultiplier = 1.5

var maxSickTime = 2.5
var sickMultiplier = 1.5


var freezeDurationMult = 1
var slowDurationMult = 1
var confusionDurationMult = 1
var fireDurationMult = 1
var poisonDurationMult = 1
var weakenDurationMult = 1
var sickDurationMult = 1


var physicalDamageMult = 1
var elementalDamageMult = 1

var summonDamage = 1

var rangeMultiplier = 1
var bulletSpeedMultiplier = 1
var firerateMultiplier = 1


var freeTowerUnder:int = -1
var chanceToIgnoreDamage = -1#)
var barbDamage:int = 0


var costs = {
	"Cannon":300,
	"Archer":300,
	"Castle":400,
	"Flail":500,
	"Mortar":450,
	"Salvo":700,
	"Flame":900,
	"Ice":600,
	"Needle":550,
	"Inferno":900,
	"Tesla":800,
	"Vortex":750,
	"Drone":600,
	"Boost":650,
	"Stock":650
}

var maxCharges = {
	"Cannon":6,
	"Archer":5,
	"Castle":4,
	"Flail":7,
	"Mortar":5,
	"Salvo":7,
	"Flame":5,
	"Ice":6,
	"Needle":5,
	"Inferno":7,
	"Tesla":6,
	"Vortex":4,
	"Drone":4,
	"Boost":4,
	"Stock":4
}

var currentCharges = {
	"Cannon":0,
	"Archer":0,
	"Castle":0,
	"Flail":0,
	"Mortar":0,
	"Salvo":0,
	"Flame":0,
	"Ice":0,
	"Needle":0,
	"Inferno":0,
	"Tesla":0,
	"Vortex":0,
	"Drone":0,
	"Boost":0,
	"Stock":0
}

const maxNecroTime = 2.5

const baseStats = {
	"Cannon":{
		"Damage":100,
		"Firerate":1000/float(2000),
		"Bullet Speed":3,
		"Range":150,
		"Camo":false,
		"Flying":false
	},
	"Archer":{
		"Damage":100,
		"Firerate":1000/float(2000),
		"Bullet Speed":1/0.25,
		"Range":150,
		"Camo":true
	},
	"Castle":{
		"Spawning Range":100,
		"Spawn Rate":4000/float(2000),
		"Max Knights":3,
		"Spawn Damage":100,
		"Spawn Attack Speed":1000/float(2000),
		"Spawn Speed":70/10,
		"Spawn Sight Range":75,
		"Spawn Health":100,
		"Camo":false,
		"Flying":false
	},
	"Flail":{
		"Damage":50,
		"Spin Speed":4,
		"Flail Scale":1,
		"Number of Flails":2,
		"Flying":false
	},
	"Mortar":{
		"Damage":150,
		"Fire Rate":2500/float(2000),
		"Bullet Speed":1/0.5,
		"Explosion Radius":70,
		"Range":175,
		"Camo":true,
		"Flying":true
	},
	"Salvo":{
		"Damage":100,
		"Range":150,
		"Bullet Speed":1/0.4,
		"Number of Bullets":6,
		"Shot Delay":100/float(2000),
		"Reload Time":4000/float(2000),
		"Explosion Radius":20,
		"Camo":false,
		"Flying":true
	},
	"Flame":{
		"Damage":15,
		"Range":100,
		"Spread":30,
		"Tick Rate":200/float(2000),
		"Element Duration":0.25/2,
		"Camo":true,
		"Flying":true
	},
	"Ice":{
		"Damage":50,
		"Range":50,
		"Fire Rate":1000/float(2000),
		"Effect Duration":0.4/2,
		"Camo":false
	},
	"Needle":{
		"Damage":40,
		"Range":125,
		"Fire Rate":0.5/2,
		"Poison Duration":0.25/2,
		"Number of Needles":2,
		"Camo":false,
		"Flying":false
	},
	"Inferno":{
		"Initial Damage":20,
		"Damage Cap":250,
		"Charge Rate":1.2,
		"Range":150,
		"Tick Rate":200/float(2000),
		"Camo":false
	},
	"Tesla":{
		"Damage":100,
		"Range":150,
		"Chain Range":100,
		"Chain Cap":3,
		"Fire Rate":1800/float(2000),
		"Camo":false
	},
	"Vortex":{
		"Damage":100,
		"Range":50,
		"Bullet Speed":50/10,
		"Fire Rate":1000/float(2000),
		"Confusion Chance":"60%",
		"Confusion Duration":0.4/2,
		"Number of Vortexs":3,
		"Size":100,
		"Camo":true
	},
	"Drone":{
		"Range":75,
		"Drone Speed":2,
		"Number of Drones":1
	},
	"Boost":{
		"Range Buff":"10%"
	},
	"Stock":{
		"Min Amount":1,
		"Max Amount":5,
		"Sell Cooldown":20*2
	}
}

const towerThumbnails = {
	"Cannon":preload("res://Assets/Buildings/Towers/Cannon/cannon_tumbnail.png"),
	"Archer":preload("res://Assets/Buildings/Towers/Archer/arch_0.png"),
	"Castle":preload("res://Assets/Buildings/Towers/Castle/castle_0.png"),
	"Flail":preload("res://Assets/Buildings/Towers/Flail/flail_0.png"),
	"Mortar":preload("res://Assets/Buildings/Towers/Mortar/mortar_thumbnail.png"),
	"Salvo":preload("res://Assets/Buildings/Towers/Salvo/salvo_thumbnail.png"),
	"Flame":preload("res://Assets/Buildings/Towers/FlameThrower/flame_thumbnail.png"),
	"Ice":preload("res://Assets/Buildings/Towers/IceTower/icetower_0.png"),
	"Needle":preload("res://Assets/Buildings/Towers/Needle/needle_0.png"),
	"Inferno":preload("res://Assets/Buildings/Towers/Inferno/inferno_0.png"),
	"Tesla":preload("res://Assets/Buildings/Towers/Tesla/tesla_0.png"),
	"Vortex":preload("res://Assets/Buildings/Towers/Vortex/vortex_0.png"),
	"Drone":preload("res://Assets/Buildings/Towers/Drone/drone_0.png"),
	"Boost":preload("res://Assets/Buildings/Towers/Boost/boost_0.png"),
	"Stock":preload("res://Assets/Buildings/Towers/Stock/stock_0.png")
}

enum baseUpgrades {
	AERIALASSAULT,
	AOE,
	BULLETSPEED,
	CAMOVISION,
	DAMAGE,
	ELEMENTDURATION,
	FIRERATE,
	RANGE,
	RECHARGE
}

enum arch {
	second,
	third,
	fifth,
	critEye,
	critCamo,
	infinite,
	pierce,
	sturdy
}

enum boost {
	cheaper,
	goldenGlove,
	killer,
	thirdEye,
	valueAble
}

enum cannon {
	doubleBarrel,
	gattleing,
	heavyShot,
	rolling,
	trippleBarrel
}

enum castle {
	allSoldiers,
	moreSoldiers,
	necro,
	prot,
	sightRange,
	wizard
}

enum drone {
	secondDrone,
	thirdDrone,
	fifthDrone,
	armed,
	armed2,
	droneSpeed,
	missles,
	support
}

enum flail {
	thirdFlail,
	forthFlail,
	fifthFlail,
	iceBalls,
	momentus,
	powerInNumbers,
	quality,
	spikey,
	aero
}

enum flame {
	flank,
	ice,
	poison,
	quad
}

enum ice {
	freeze,
	radialSlow,
	tremble
}

enum inferno {
	second,
	third,
	fifth,
	life,
	persistantReach
}

enum mortar {
	molten,
	nuke,
	shrapnel
}

enum needle {
	addNeedle,
	moreNeedles,
	overload,
	pandemic,
	spray
}

enum salvo {
	thirdRow,
	fourthColumn,
	fifthColumn,
	firework,
	maxRockets,
	passive,
	pikes
}

enum stock {
	advertise,
	bbooking,
	biggerMoney,
	bot,
	evenBiggerMoney,
	fastestWithdraws,
	fastWithdraws,
	influencer,
	insiderInfo,
	marketManipulation,
	quickWithdraw,
	tradingFirm
}

enum tesla {
	accel,
	chain,
	fork,
	moreChains,
	prox
}

enum vortex {
	additionalVortex,
	barrage,
	double,
	massiveVortex,
	relentless
}

const defaultUpgradeSprites = {
	baseUpgrades.AERIALASSAULT:preload("res://Assets/SkillTree/Universal/aerialAce.png"),
	baseUpgrades.AOE:preload("res://Assets/SkillTree/Universal/aoe.png"),
	baseUpgrades.BULLETSPEED:preload("res://Assets/SkillTree/Universal/bulletSpeed.png"),
	baseUpgrades.CAMOVISION:preload("res://Assets/SkillTree/Universal/camoVision.png"),
	baseUpgrades.DAMAGE:preload("res://Assets/SkillTree/Universal/damage.png"),
	baseUpgrades.ELEMENTDURATION:preload("res://Assets/SkillTree/Universal/elementDuration.png"),
	baseUpgrades.FIRERATE:preload("res://Assets/SkillTree/Universal/firerate.png"),
	baseUpgrades.RANGE:preload("res://Assets/SkillTree/Universal/range.png"),
	baseUpgrades.RECHARGE:preload("res://Assets/SkillTree/Universal/rechargeTime.png")
}

const archUpgrades = {
	arch.second:preload("res://Assets/SkillTree/Archer/2nd Archer.png"),
	arch.third:preload("res://Assets/SkillTree/Archer/3rd Archer.png"),
	arch.fifth:preload("res://Assets/SkillTree/Archer/4thand5th Archer.png"),
	arch.critEye:preload("res://Assets/SkillTree/Archer/criticalEye.png"),
	arch.critCamo:preload("res://Assets/SkillTree/Archer/criticalCamo.png"),
	arch.infinite:preload("res://Assets/SkillTree/Archer/infinite.png"),
	arch.pierce:preload("res://Assets/SkillTree/Archer/pierce.png"),
	arch.sturdy:preload("res://Assets/SkillTree/Archer/sturdyShaft.png")
}

const boostUpgrades = {
	boost.cheaper:preload("res://Assets/SkillTree/Boost/cheaperUpgrades.png"),
	boost.goldenGlove:preload("res://Assets/SkillTree/Boost/goldenGlove.png"),
	boost.killer:preload("res://Assets/SkillTree/Boost/killerInstinct.png"),
	boost.thirdEye:preload("res://Assets/SkillTree/Boost/thirdEye.png"),
	boost.valueAble:preload("res://Assets/SkillTree/Boost/valueableAnts.png")
}

const cannonUpgrades = {
	cannon.doubleBarrel:preload("res://Assets/SkillTree/Cannon/doubleBarrel.png"),
	cannon.gattleing:preload("res://Assets/SkillTree/Cannon/gattleingGun.png"),
	cannon.heavyShot:preload("res://Assets/SkillTree/Cannon/heavyShot.png"),
	cannon.rolling:preload("res://Assets/SkillTree/Cannon/rollingSeige.png"),
	cannon.trippleBarrel:preload("res://Assets/SkillTree/Cannon/trippleBarrel.png")
}

const castleUpgrades = {
	castle.allSoldiers:preload("res://Assets/SkillTree/Castle/All the soldiers.png"),
	castle.moreSoldiers:preload("res://Assets/SkillTree/Castle/moreSoldier.png"),
	castle.necro:preload("res://Assets/SkillTree/Castle/necro.png"),
	castle.prot:preload("res://Assets/SkillTree/Castle/prot.png"),
	castle.sightRange:preload("res://Assets/SkillTree/Castle/sightrange.png"),
	castle.wizard:preload("res://Assets/SkillTree/Castle/wizard.png")
}

const droneUpgrades = {
	drone.secondDrone:preload("res://Assets/SkillTree/Drone/2nd drone.png"),
	drone.thirdDrone:preload("res://Assets/SkillTree/Drone/3rd drone.png"),
	drone.fifthDrone:preload("res://Assets/SkillTree/Drone/5drone.png"),
	drone.armed:preload("res://Assets/SkillTree/Drone/armed.png"),
	drone.armed2:preload("res://Assets/SkillTree/Drone/armed2.png"),
	drone.droneSpeed:preload("res://Assets/SkillTree/Drone/droneSpeed.png"),
	drone.missles:preload("res://Assets/SkillTree/Drone/missles.png"),
	drone.support:preload("res://Assets/SkillTree/Drone/support.png")
}

const flailUpgrades = {
	flail.thirdFlail:preload("res://Assets/SkillTree/Flail/3rd Flail.png"),
	flail.forthFlail:preload("res://Assets/SkillTree/Flail/4th Flail.png"),
	flail.fifthFlail:preload("res://Assets/SkillTree/Flail/5th Flail.png"),
	flail.iceBalls:preload("res://Assets/SkillTree/Flail/iceBalls.png"),
	flail.momentus:preload("res://Assets/SkillTree/Flail/momentus.png"),
	flail.powerInNumbers:preload("res://Assets/SkillTree/Flail/powerInNumbers.png"),
	flail.quality:preload("res://Assets/SkillTree/Flail/quality.png"),
	flail.spikey:preload("res://Assets/SkillTree/Flail/spikey.png"),
	flail.aero:preload("res://Assets/SkillTree/Flail/aero.png")
}

const flameUpgrades = {
	flame.flank:preload("res://Assets/SkillTree/FlameThrower/flank.png"),
	flame.ice:preload("res://Assets/SkillTree/FlameThrower/IceThrower.png"),
	flame.poison:preload("res://Assets/SkillTree/FlameThrower/poisonThrower.png"),
	flame.quad:preload("res://Assets/SkillTree/FlameThrower/quad.png")
}

const iceUpgrades = {
	ice.freeze:preload("res://Assets/SkillTree/IceTower/freeze.png"),
	ice.radialSlow:preload("res://Assets/SkillTree/IceTower/radialSlow.png"),
	ice.tremble:preload("res://Assets/SkillTree/IceTower/tremble.png")
}

const infernoUpgrades = {
	inferno.second:preload("res://Assets/SkillTree/Inferno/2nd.png"),
	inferno.third:preload("res://Assets/SkillTree/Inferno/3rd.png"),
	inferno.fifth:preload("res://Assets/SkillTree/Inferno/5th.png"),
	inferno.life:preload("res://Assets/SkillTree/Inferno/Life.png"),
	inferno.persistantReach:preload("res://Assets/SkillTree/Inferno/Persistant.png")
}

const mortarUpgrades = {
	mortar.molten:preload("res://Assets/SkillTree/Mortar/molten.png"),
	mortar.nuke:preload("res://Assets/SkillTree/Mortar/nuke.png"),
	mortar.shrapnel:preload("res://Assets/SkillTree/Mortar/shrapnel.png")
}

const needleUpgrades = {
	needle.addNeedle:preload("res://Assets/SkillTree/Needle/addNeedle.png"),
	needle.moreNeedles:preload("res://Assets/SkillTree/Needle/moreNeedle.png"),
	needle.overload:preload("res://Assets/SkillTree/Needle/overload.png"),
	needle.pandemic:preload("res://Assets/SkillTree/Needle/pandemic.png"),
	needle.spray:preload("res://Assets/SkillTree/Needle/spray.png")
}

const salvoUpgrades = {
	salvo.thirdRow:preload("res://Assets/SkillTree/Salvo/3rdRow.png"),
	salvo.fourthColumn:preload("res://Assets/SkillTree/Salvo/4thCol.png"),
	salvo.fifthColumn:preload("res://Assets/SkillTree/Salvo/5thCol.png"),
	salvo.firework:preload("res://Assets/SkillTree/Salvo/Firework.png"),
	salvo.maxRockets:preload("res://Assets/SkillTree/Salvo/maxRockets.png"),
	salvo.passive:preload("res://Assets/SkillTree/Salvo/passive.png"),
	salvo.pikes:preload("res://Assets/SkillTree/Salvo/pikes.png")
}

const stockUpgrades = {
	stock.advertise:preload("res://Assets/SkillTree/Stock/advertise.png"),
	stock.bbooking:preload("res://Assets/SkillTree/Stock/bbooking.png"),
	stock.biggerMoney:preload("res://Assets/SkillTree/Stock/biggerMoneyCap.png"),
	stock.bot:preload("res://Assets/SkillTree/Stock/bot.png"),
	stock.evenBiggerMoney:preload("res://Assets/SkillTree/Stock/EvenBiggerMoneyCap.png"),
	stock.fastestWithdraws:preload("res://Assets/SkillTree/Stock/fastestWithdraw.png"),
	stock.fastWithdraws:preload("res://Assets/SkillTree/Stock/fastWithdraw.png"),
	stock.influencer:preload("res://Assets/SkillTree/Stock/influencer.png"),
	stock.insiderInfo:preload("res://Assets/SkillTree/Stock/insiderInfo.png"),
	stock.marketManipulation:preload("res://Assets/SkillTree/Stock/marketManipulation.png"),
	stock.quickWithdraw:preload("res://Assets/SkillTree/Stock/quickWithdraw.png"),
	stock.tradingFirm:preload("res://Assets/SkillTree/Stock/tradingFirm.png")
}

const teslaUpgrades = {
	tesla.accel:preload("res://Assets/SkillTree/Tesla/accel.png"),
	tesla.chain:preload("res://Assets/SkillTree/Tesla/chain.png"),
	tesla.fork:preload("res://Assets/SkillTree/Tesla/ForkLighting.png"),
	tesla.moreChains:preload("res://Assets/SkillTree/Tesla/moreChains.png"),
	tesla.prox:preload("res://Assets/SkillTree/Tesla/prox.png")
}

const vortexUpgrades = {
	vortex.additionalVortex:preload("res://Assets/SkillTree/Vortex/additionalVortex.png"),
	vortex.barrage:preload("res://Assets/SkillTree/Vortex/barrage.png"),
	vortex.double:preload("res://Assets/SkillTree/Vortex/double.png"),
	vortex.massiveVortex:preload("res://Assets/SkillTree/Vortex/massive.png"),
	vortex.relentless:preload("res://Assets/SkillTree/Vortex/relentless.png")
}





var perkPoints = 10
var activePerks = {
	
}

const perksTree = {
		"Lethal Spikes":[],
		"Arctic Winds":["Abundant Magic"],
		"Malnourished":["Abundant Magic"],
		"Endless Kindling":["Malnourished"],
		"Virus Outbreak":["Abundant Magic"],
		"Toxic Fields":["Virus Outbreak"],
		"Bulky Base":["Lethal Spikes"],
		"Regeneration":["Bulky Base"],
		"Ration Shields":["Regeneration"],
		"Deflection":["Bulky Base"],
		"Reincarnation":["Deflection"],
		"Five Finger Discount":["Lethal Spikes"],
		"Thieving Rounds":["Five Finger Discount"],
		"Money Bags":["Thieving Rounds"],
		"Early Access":["Money Bags"],
		"Polisher":["Early Access"],
		"Barterer":["Clearance"],
		"Refund Policy":["Money Bags"],
		"Clearance":["Refund Policy"],
		"Bright Lights":["Polisher"],
		"Quality Ammo":["Thieving Rounds"],
		"Oiled Barrels":["Quality Ammo"],
		"Aerodynamics":["Oiled Barrels"],
		"Keen Eye":["Quality Ammo"],
		"Lethal Loyals":["Keen Eye"],
		"Efficient Energy":["Lethal Spikes"],
		"Lingering Hex":["Efficient Energy"],
		"Abundant Magic":["Lingering Hex"],
		"Freezing Touch":["Arctic Winds"],
		"Miscommunication":["Abundant Magic"]
}

const perksDescriptions = {
		"Lethal Spikes":"Barbedwire x does damage on contact.",
		"Arctic Winds":"Slow effect buffs.",
		"Malnourished":"Weaken effect buffs.",
		"Endless Kindling":"Fire effect buffs.",
		"Virus Outbreak":"Sick effect buffs.",
		"Toxic Fields":"Poison effect buffs.",
		"Bulky Base":"x% max health.",
		"Regeneration":"Heal x% max health a round.",
		"Ration Shields":"Obtain a sheild that takes up to x hits each round.",
		"Deflection":"x% chance to ignore damage.",
		"Reincarnation":"The first time you die, get resurrected with x% of your max health, and restart the wave.",
		"Five Finger Discount":"First tower under $x is free.",
		"Thieving Rounds":"x% more cash from killing ants.",
		"Money Bags":"x% starting cash.",
		"Early Access":"Each mint charge starts x% full (Rounded down, minimum 1).",
		"Polisher":"Can choose x towers to have 1 less max mint charge.",
		"Barterer":"x% upgrade cost.",
		"Refund Policy":"Sell value is now x% (base 50%).",
		"Clearance":"x% tower cost.",
		"Bright Lights":"Better lumens.",
		"Quality Ammo":"x times more physical damage (Cannon, Archer, Knight, Flail, Mortar, Salvo, Needle).",
		"Oiled Barrels":"x% more firerate.",
		"Aerodynamics":"x% more bulletspeed.",
		"Keen Eye":"x% more range.",
		"Lethal Loyals":"Summons do x% more damage (Drone, Knight, Wizard, Necromancer, Archer).",
		"Efficient Energy":"x times more special damage (Elements, Flame, Ice, Vortex, Inferno, Tesla, Wizard).",
		"Lingering Hex":"Elemental max duration is x times longer.",
		"Abundant Magic":"Elemental duration is x times longer.",
		"Freezing Touch":"Ice effect buffs.",
		"Miscommunication":"Confusion effect buffs."
}

const perksLvls = {
		"Lethal Spikes":[25,50,75],
		"Arctic Winds":["Duration times 1.25","Max duration times 1.25","20% more slow"],
		"Malnourished":["Duration times 1.25","Max duration times 1.25","1.5x damage -> 2x"],
		"Endless Kindling":["Max duration times 1.25","Ticks 1.25x faster","5% of max health per tick -> 7.5%"],
		"Virus Outbreak":["Duration times 1.25","Max duration times 1.25","1.5x damage -> 2x"],
		"Toxic Fields":["Max duration times 1.25","Ticks 1.25x faster","13% of health per tick -> 18%"],
		"Bulky Base":[150,175,200],
		"Regeneration":[5,7.5,10],
		"Ration Shields":[1,2,3],
		"Deflection":[10,20,30],
		"Reincarnation":[1,25,50],
		"Five Finger Discount":[400,650,1000],
		"Thieving Rounds":[5,10,15],
		"Money Bags":[150,175,200],
		"Early Access":[20,40,60],
		"Polisher":[1,2,3],
		"Barterer":[90,85,80],
		"Refund Policy":[70,85,100],
		"Clearance":[90,80,70],
		"Bright Lights":["8 more starting lumens","Can always start a wave, regardless of your lumens","2 more wave end lumens"],
		"Quality Ammo":[1.1,1.15,1.25],
		"Oiled Barrels":[10,20,30],
		"Aerodynamics":[10,20,30],
		"Keen Eye":[10,20,30],
		"Lethal Loyals":[10,15,25],
		"Efficient Energy":[1.1,1.15,1.25],
		"Lingering Hex":[1.15,1.2,1.25],
		"Abundant Magic":[1.15,1.2,1.25],
		"Freezing Touch":["Duration times 1.25","Max duration times 1.25","Immunity 0.4 -> 0.35"],
		"Miscommunication":["Duration times 1.25","Max duration times 1.25","Immunity 0.4 -> 0.35"]
}

const perkCosts = {
		"Lethal Spikes":0,
		"Arctic Winds":0,
		"Malnourished":0,
		"Endless Kindling":0,
		"Virus Outbreak":0,
		"Toxic Fields":0,
		"Bulky Base":0,
		"Regeneration":0,
		"Ration Shields":0,
		"Deflection":0,
		"Reincarnation":0,
		"Five Finger Discount":0,
		"Thieving Rounds":0,
		"Money Bags":0,
		"Early Access":0,
		"Polisher":0,
		"Barterer":0,
		"Refund Policy":0,
		"Clearance":0,
		"Bright Lights":0,
		"Quality Ammo":0,
		"Oiled Barrels":0,
		"Aerodynamics":0,
		"Keen Eye":0,
		"Lethal Loyals":0,
		"Efficient Energy":0,
		"Lingering Hex":0,
		"Abundant Magic":0,
		"Freezing Touch":0,
		"Miscommunication":0
}


var ownedPerks = [
	"Lethal Spikes",
	"Arctic Winds",
	"Malnourished",
	"Endless Kindling",
	"Virus Outbreak",
	"Toxic Fields",
	"Bulky Base",
	"Regeneration",
	"Ration Shields",
	"Deflection",
	"Reincarnation",
	"Five Finger Discount",
	"Thieving Rounds",
	"Money Bags",
	"Early Access",
	"Polisher",
	"Barterer",
	"Refund Policy",
	"Clearance",
	"Bright Lights",
	"Quality Ammo",
	"Oiled Barrels",
	"Aerodynamics",
	"Keen Eye",
	"Lethal Loyals",
	"Efficient Energy",
	"Lingering Hex",
	"Abundant Magic",
	"Freezing Touch",
	"Miscommunication"
]

enum PERKS {
	LethalSpikes,
	ArcticWinds,
	Malnourished,
	EndlessKindling,
	VirusOutbreak,
	ToxicFields,
	BulkyBase,
	Regeneration,
	RationShields,
	Deflection,
	Reincarnation,
	FiveFingerDiscount,
	ThievingRounds,
	MoneyBags,
	EarlyAccess,
	Polisher,
	Barterer,
	RefundPolicy,
	Clearance,
	BrightLights,
	QualityAmmo,
	OiledBarrels,
	Aerodynamics,
	KeenEye,
	LethalLoyals,
	EfficientEnergy,
	LingeringHex,
	AbundantMagic,
	FreezingTouch,
	Miscommunication
}

const numToPerk = {
	PERKS.LethalSpikes:"Lethal Spikes",
	PERKS.ArcticWinds:"Arctic Winds",
	PERKS.Malnourished:"Malnourished",
	PERKS.EndlessKindling:"Endless Kindling",
	PERKS.VirusOutbreak:"Virus Outbreak",
	PERKS.ToxicFields:"Toxic Fields",
	PERKS.BulkyBase:"Bulky Base",
	PERKS.Regeneration:"Regeneration",
	PERKS.RationShields:"Ration Shields",
	PERKS.Deflection:"Deflection",
	PERKS.Reincarnation:"Reincarnation",
	PERKS.FiveFingerDiscount:"Five Finger Discount",
	PERKS.ThievingRounds:"Thieving Rounds",
	PERKS.MoneyBags:"Money Bags",
	PERKS.EarlyAccess:"Early Access",
	PERKS.Polisher:"Polisher",
	PERKS.Barterer:"Barterer",
	PERKS.RefundPolicy:"Refund Policy",
	PERKS.Clearance:"Clearance",
	PERKS.BrightLights:"Bright Lights",
	PERKS.QualityAmmo:"Quality Ammo",
	PERKS.OiledBarrels:"Oiled Barrels",
	PERKS.Aerodynamics:"Aerodynamics",
	PERKS.KeenEye:"Keen Eye",
	PERKS.LethalLoyals:"Lethal Loyals",
	PERKS.EfficientEnergy:"Efficient Energy",
	PERKS.LingeringHex:"Lingering Hex",
	PERKS.AbundantMagic:"Abundant Magic",
	PERKS.FreezingTouch:"Freezing Touch",
	PERKS.Miscommunication:"Miscommunication"
}

func perkToNum(perk:String)->int:
	return perksDescriptions.keys().find(perk)

func newGame()->void:
	sellPercent = 0.5
	startingCash = 750
	upgradeCostMult = 1
	cashFromKillMult = 1

	startingLumens = 4
	waveEndLumens = 4
	maxLumens = 10


	reincarnationPercent = 0
	startingHp = 25
	maxSheildHits = -1
	regenPercent = 0


	burnPercent = 0.05 #of max *100
	burnTickRate = 200 #ms x2
	maxBurnDuration = 2.5 # x2 5 sec

	poisionPercent = 0.13 #of current
	poisionTickRate = 200 #ms x2
	maxPoisionDuration = 2.5 # x2 5 sec

	maxSlowDuration = 2.5
	slowPercent = 0.7

	maxFreezeDuration = 0.3
	freezeImmunityDuration = 0.8*1000

	maxConfusionDuration = 0.5
	confusionImmunityDuration = 0.8*1000

	maxWeakenTime = 2.5
	weakenMultiplier = 1.5

	maxSickTime = 2.5
	sickMultiplier = 1.5


	freezeDurationMult = 1
	slowDurationMult = 1
	confusionDurationMult = 1
	fireDurationMult = 1
	poisonDurationMult = 1
	weakenDurationMult = 1
	sickDurationMult = 1


	physicalDamageMult = 1
	elementalDamageMult = 1

	summonDamage = 1

	rangeMultiplier = 1
	bulletSpeedMultiplier = 1
	firerateMultiplier = 1


	freeTowerUnder = -1
	chanceToIgnoreDamage = -1
	barbDamage = 0


	costs = {
		"Cannon":150*2,
		"Archer":150*2,
		"Castle":200*2,
		"Flail":250*2,
		"Mortar":225*2,
		"Salvo":350*2,
		"Flame":450*2,
		"Ice":300*2,
		"Needle":275*2,
		"Inferno":450*2,
		"Tesla":400*2,
		"Vortex":375*2,
		"Drone":300*2,
		"Boost":325*2,
		"Stock":325*2
	}

	maxCharges = {
		"Cannon":6,
		"Archer":5,
		"Castle":4,
		"Flail":7,
		"Mortar":5,
		"Salvo":7,
		"Flame":5,
		"Ice":6,
		"Needle":5,
		"Inferno":7,
		"Tesla":6,
		"Vortex":4,
		"Drone":4,
		"Boost":4,
		"Stock":4
	}

	currentCharges = {
		"Cannon":0,
		"Archer":0,
		"Castle":0,
		"Flail":0,
		"Mortar":0,
		"Salvo":0,
		"Flame":0,
		"Ice":0,
		"Needle":0,
		"Inferno":0,
		"Tesla":0,
		"Vortex":0,
		"Drone":0,
		"Boost":0,
		"Stock":0
	}

func updatePerks():
	# Barbedwire perk
	if "Lethal Spikes" in activePerks:
		barbDamage = perksLvls["Lethal Spikes"][activePerks["Lethal Spikes"]]
	
	# Arctic Winds perk
	if "Arctic Winds" in activePerks:
		if activePerks["Arctic Winds"] == 2:
			slowPercent *= 1.2
		if activePerks["Arctic Winds"] >= 1:
			maxSlowDuration *= 1.25
		slowDurationMult *= 1.25
	
	# Malnourished perk
	if "Malnourished" in activePerks:
		if activePerks["Malnourished"] == 2:
			weakenMultiplier = 2
		if activePerks["Malnourished"] >= 1:
			maxWeakenTime *= 1.25
		weakenDurationMult *= 1.25
			
	
	# Endless Kindling perk
	if "Endless Kindling" in activePerks:
		if activePerks["Endless Kindling"] == 2:
			burnPercent = 0.075
		if activePerks["Endless Kindling"] >= 1:
			burnTickRate *= 0.75
		maxBurnDuration *= 1.25
	
	# Virus Outbreak perk
	if "Virus Outbreak" in activePerks:
		if activePerks["Virus Outbreak"] == 2:
			sickMultiplier = 2
		if activePerks["Virus Outbreak"] >= 1:
			maxSickTime *= 1.25
		sickDurationMult *= 1.25
	
	# Toxic Fields perk
	if "Toxic Fields" in activePerks:
		if activePerks["Toxic Fields"] == 2:
			poisionPercent = 0.18
		if activePerks["Toxic Fields"] >= 1:
			poisionTickRate *= 0.75
		maxPoisionDuration *= 1.25
	
	# Bulky Base perk
	if "Bulky Base" in activePerks:
		startingHp *= perksLvls["Bulky Base"][activePerks["Bulky Base"]]/100
	
	# Regeneration perk
	if "Regeneration" in activePerks:
		regenPercent = perksLvls["Regeneration"][activePerks["Regeneration"]]/float(100)
	
	# Ration Shields perk
	if "Ration Shields" in activePerks:
		maxSheildHits = perksLvls["Ration Shields"][activePerks["Ration Shields"]]
	
	# Deflection perk
	if "Deflection" in activePerks:
		chanceToIgnoreDamage = perksLvls["Deflection"][activePerks["Deflection"]]/float(100)
	
	# Reincarnation perk
	if "Reincarnation" in activePerks:
		reincarnationPercent = perksLvls["Reincarnation"][activePerks["Reincarnation"]]/float(100)
	
	# Five Finger Discount perk
	if "Five Finger Discount" in activePerks:
		freeTowerUnder = perksLvls["Five Finger Discount"][activePerks["Five Finger Discount"]]
	
	# Thieving Rounds perk
	if "Thieving Rounds" in activePerks:
		cashFromKillMult = 1 + (0.01 * perksLvls["Thieving Rounds"][activePerks["Thieving Rounds"]])
	
	# Money Bags perk
	if "Money Bags" in activePerks:
		startingCash *= perksLvls["Money Bags"][activePerks["Money Bags"]]/100
	
	# Early Access perk
	if "Early Access" in activePerks:
		for tower in currentCharges:
			currentCharges[tower] = max(1, round(maxCharges[tower]*perksLvls["Early Access"][activePerks["Early Access"]]/100))

	# Polisher perk
	if "Polisher" in activePerks:
		pass# Implement the logic for choosing x towers to have 1 less max mint charge here
	
	# Barterer perk
	if "Barterer" in activePerks:
		upgradeCostMult = perksLvls["Barterer"][activePerks["Barterer"]]/float(100)
	
	# Refund Policy perk
	if "Refund Policy" in activePerks:
		sellPercent = perksLvls["Refund Policy"][activePerks["Refund Policy"]]/100
	
	# Clearance perk
	if "Clearance" in activePerks:
		for tower in costs:
			costs[tower] *= perksLvls["Clearance"][activePerks["Clearance"]]/float(100)
	
	# Bright Lights perk
	if "Bright Lights" in activePerks:
		if activePerks["Bright Lights"] == 2:
			waveEndLumens += 2
		if activePerks["Bright Lights"] >= 1:
			maxLumens = 100000
			
		startingLumens += 8
		
	
	# Quality Ammo perk
	if "Quality Ammo" in activePerks:
		physicalDamageMult *= perksLvls["Quality Ammo"][activePerks["Quality Ammo"]]
	
	# Oiled Barrels perk
	if "Oiled Barrels" in activePerks:
		firerateMultiplier += perksLvls["Oiled Barrels"][activePerks["Oiled Barrels"]] / float(100)
	
	# Aerodynamics perk
	if "Aerodynamics" in activePerks:
		bulletSpeedMultiplier += perksLvls["Aerodynamics"][activePerks["Aerodynamics"]] / float(100)
	
	# Keen Eye perk
	if "Keen Eye" in activePerks:
		rangeMultiplier += perksLvls["Keen Eye"][activePerks["Keen Eye"]] / float(100)
	
	# Lethal Loyals perk
	if "Lethal Loyals" in activePerks:
		summonDamage *= 1 + (0.01 * perksLvls["Lethal Loyals"][activePerks["Lethal Loyals"]])
	
	# Efficient Energy perk
	if "Efficient Energy" in activePerks:
		elementalDamageMult *= perksLvls["Efficient Energy"][activePerks["Efficient Energy"]]
	
	# Lingering Hex perk
	if "Lingering Hex" in activePerks:
		var mult = perksLvls["Lingering Hex"][activePerks["Lingering Hex"]]
		maxFreezeDuration *= mult
		maxSlowDuration *= mult
		maxBurnDuration *= mult
		maxPoisionDuration *= mult
		maxWeakenTime *= mult
		maxSickTime *= mult
		maxConfusionDuration *= mult
	
	# Abundant Magic perk
	if "Abundant Magic" in activePerks:
		var mult = perksLvls["Abundant Magic"][activePerks["Abundant Magic"]]
		freezeDurationMult *= mult
		slowDurationMult *= mult
		fireDurationMult *= mult
		poisonDurationMult *= mult
		weakenDurationMult *= mult
		sickDurationMult *= mult
		confusionDurationMult *= mult
	
	# Freezing Touch perk
	if "Freezing Touch" in activePerks:
		if activePerks["Freezing Touch"] == 2:
			freezeImmunityDuration = 0.7 * 1000
		if activePerks["Freezing Touch"] >= 1:
			maxFreezeDuration *= 1.25
		freezeDurationMult *= 1.25
	
	# Miscommunication perk
	if "Miscommunication" in activePerks:
		if activePerks["Miscommunication"] == 2:
			confusionImmunityDuration = 0.7 * 1000
		if activePerks["Miscommunication"] >= 1:
			maxConfusionDuration *= 1.25
		confusionDurationMult *= 1.25
		
		
		
func printDif()->void:
	var newsellPercent = 0.5
	var newstartingCash = 750
	var newupgradeCostMult = 1
	var newcashFromKillMult = 1

	var newstartingLumens = 4
	var newwaveEndLumens = 4
	var newmaxLumens = 10


	var newreincarnationPercent = 0
	var newstartingHp = 20
	var newmaxSheildHits = -1
	var newregenPercent = 0


	var newburnPercent = 0.05 #of max *100
	var newburnTickRate = 200 #ms x2
	var newmaxBurnDuration = 2.5 # x2 5 sec

	var newpoisionPercent = 0.13 #of current
	var newpoisionTickRate = 200 #ms x2
	var newmaxPoisionDuration = 2.5 # x2 5 sec

	var newmaxSlowDuration = 2.5
	var newslowPercent = 0.7

	var newmaxFreezeDuration = 0.3
	var newfreezeImmunityDuration = 0.8*1000

	var newmaxConfusionDuration = 0.5
	var newconfusionImmunityDuration = 0.8*1000

	var newmaxWeakenTime = 2.5
	var newweakenMultiplier = 1.5

	var newmaxSickTime = 2.5
	var newsickMultiplier = 1.5


	var newfreezeDurationMult = 1
	var newslowDurationMult = 1
	var newconfusionDurationMult = 1
	var newfireDurationMult = 1
	var newpoisonDurationMult = 1
	var newweakenDurationMult = 1
	var newsickDurationMult = 1


	var newphysicalDamageMult = 1
	var newelementalDamageMult = 1

	var newsummonDamage = 1

	var newrangeMultiplier = 1
	var newbulletSpeedMultiplier = 1
	var newfirerateMultiplier = 1


	var newfreeTowerUnder = -1
	var newchanceToIgnoreDamage = -1
	var newbarbDamage = 0


	var newcosts = {
		"Cannon":150*2,
		"Archer":150*2,
		"Castle":200*2,
		"Flail":250*2,
		"Mortar":225*2,
		"Salvo":350*2,
		"Flame":450*2,
		"Ice":300*2,
		"Needle":275*2,
		"Inferno":450*2,
		"Tesla":400*2,
		"Vortex":375*2,
		"Drone":300*2,
		"Boost":325*2,
		"Stock":325*2
	}

	var newmaxCharges = {
		"Cannon":6,
		"Archer":5,
		"Castle":4,
		"Flail":7,
		"Mortar":5,
		"Salvo":7,
		"Flame":5,
		"Ice":6,
		"Needle":5,
		"Inferno":7,
		"Tesla":6,
		"Vortex":4,
		"Drone":4,
		"Boost":4,
		"Stock":4
	}

	var newcurrentCharges = {
		"Cannon":0,
		"Archer":0,
		"Castle":0,
		"Flail":0,
		"Mortar":0,
		"Salvo":0,
		"Flame":0,
		"Ice":0,
		"Needle":0,
		"Inferno":0,
		"Tesla":0,
		"Vortex":0,
		"Drone":0,
		"Boost":0,
		"Stock":0
	}
	
	if sellPercent != newsellPercent:
		print("sellPercent:", sellPercent)
	if startingCash != newstartingCash:
		print("startingCash:", startingCash)
	if upgradeCostMult != newupgradeCostMult:
		print("upgradeCostMult:", upgradeCostMult)
	if cashFromKillMult != newcashFromKillMult:
		print("cashFromKillMult:", cashFromKillMult)
	
	if startingLumens != newstartingLumens:
		print("startingLumens:", startingLumens)
	if waveEndLumens != newwaveEndLumens:
		print("waveEndLumens:", waveEndLumens)
	if maxLumens != newmaxLumens:
		print("maxLumens:", maxLumens)
	
	if reincarnationPercent != newreincarnationPercent:
		print("reincarnationPercent:", reincarnationPercent)
	if startingHp != newstartingHp:
		print("startingHp:", startingHp)
	if maxSheildHits != newmaxSheildHits:
		print("maxSheildHits:", maxSheildHits)
	if regenPercent != newregenPercent:
		print("regenPercent:", regenPercent)
	
	if burnPercent != newburnPercent:
		print("burnPercent:", burnPercent)
	if burnTickRate != newburnTickRate:
		print("burnTickRate:", burnTickRate)
	if maxBurnDuration != newmaxBurnDuration:
		print("maxBurnDuration:", maxBurnDuration)
	
	if poisionPercent != newpoisionPercent:
		print("poisionPercent:", poisionPercent)
	if poisionTickRate != newpoisionTickRate:
		print("poisionTickRate:", poisionTickRate)
	if maxPoisionDuration != newmaxPoisionDuration:
		print("maxPoisionDuration:", maxPoisionDuration)
	
	if maxSlowDuration != newmaxSlowDuration:
		print("maxSlowDuration:", maxSlowDuration)
	if slowPercent != newslowPercent:
		print("slowPercent:", slowPercent)
	
	if maxFreezeDuration != newmaxFreezeDuration:
		print("maxFreezeDuration:", maxFreezeDuration)
	if freezeImmunityDuration != newfreezeImmunityDuration:
		print("freezeImmunityDuration:", freezeImmunityDuration)
	
	if maxConfusionDuration != newmaxConfusionDuration:
		print("maxConfusionDuration:", maxConfusionDuration)
	if confusionImmunityDuration != newconfusionImmunityDuration:
		print("confusionImmunityDuration:", confusionImmunityDuration)
	
	if maxWeakenTime != newmaxWeakenTime:
		print("maxWeakenTime:", maxWeakenTime)
	if weakenMultiplier != newweakenMultiplier:
		print("weakenMultiplier:", weakenMultiplier)
	
	if maxSickTime != newmaxSickTime:
		print("maxSickTime:", maxSickTime)
	if sickMultiplier != newsickMultiplier:
		print("sickMultiplier:", sickMultiplier)
	
	if freezeDurationMult != newfreezeDurationMult:
		print("freezeDurationMult:", freezeDurationMult)
	if slowDurationMult != newslowDurationMult:
		print("slowDurationMult:", slowDurationMult)
	if confusionDurationMult != newconfusionDurationMult:
		print("confusionDurationMult:", confusionDurationMult)
	if fireDurationMult != newfireDurationMult:
		print("fireDurationMult:", fireDurationMult)
	if poisonDurationMult != newpoisonDurationMult:
		print("poisonDurationMult:", poisonDurationMult)
	if weakenDurationMult != newweakenDurationMult:
		print("weakenDurationMult:", weakenDurationMult)
	if sickDurationMult != newsickDurationMult:
		print("sickDurationMult:", sickDurationMult)
	
	if physicalDamageMult != newphysicalDamageMult:
		print("physicalDamageMult:", physicalDamageMult)
	if elementalDamageMult != newelementalDamageMult:
		print("elementalDamageMult:", elementalDamageMult)
	
	if summonDamage != newsummonDamage:
		print("summonDamage:", summonDamage)
	
	if rangeMultiplier != newrangeMultiplier:
		print("rangeMultiplier:", rangeMultiplier)
	if bulletSpeedMultiplier != newbulletSpeedMultiplier:
		print("bulletSpeedMultiplier:", bulletSpeedMultiplier)
	if firerateMultiplier != newfirerateMultiplier:
		print("firerateMultiplier:", firerateMultiplier)
	
	if freeTowerUnder != newfreeTowerUnder:
		print("freeTowerUnder:", freeTowerUnder)
	if chanceToIgnoreDamage != newchanceToIgnoreDamage:
		print("chanceToIgnoreDamage:", chanceToIgnoreDamage)
	if barbDamage != newbarbDamage:
		print("barbDamage:", barbDamage)
		
	for tower in costs:
		if costs[tower] != newcosts[tower]:
			print(tower, "cost:", costs[tower])
			
		# maxCharges dictionary
	for tower in maxCharges:
		if maxCharges[tower] != newmaxCharges[tower]:
			print(tower, "max charges:", maxCharges[tower])

	# currentCharges dictionary
	for tower in currentCharges:
		if currentCharges[tower] != newcurrentCharges[tower]:
			print(tower, "current charges:", currentCharges[tower])

	# costs dictionary
	for tower in costs:
		if costs[tower] != newcosts[tower]:
			print(tower, "cost:", costs[tower])



