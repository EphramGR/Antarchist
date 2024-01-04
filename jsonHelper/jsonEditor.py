import itertools
import json
from PIL import Image

#list if side combos that dont have a valid connection, so force their connection to be solid of lower case r or y
importantList = ['Y|rr', 'y|RR', 'r|YY', 'R|yy', 'b|Y|r', 'b|y|R', 'b|R|y', 'b|r|Y']

for i in range(len(importantList)):
    importantList.append(importantList[i][::-1])

def Remove(duplicate):
    final_list = []
    for num in duplicate:
        if num not in final_list:
            final_list.append(num)
    return final_list

def allCombos():
    pattern = ['r', 'R', 'y', 'Y', 'b']
    size = 3

    # Generate all possible combinations of the characters
    combinations = list(itertools.product(pattern, repeat=size))

    # Generate all possible permutations of the combinations
    permutations = []
    for c in combinations:
        for p in itertools.permutations(c):
            permutations.append(p)

    # Generate all possible permutations of the combinations with separators
    permutations_with_separators = []
    for p in permutations:
        for i in range(1, size):
            for s in itertools.combinations(range(size - 1), i):
                new_p = list(p)
                for j in s:
                    new_p[j] += '|'
                permutations_with_separators.append(new_p)

    # Merge permutations and permutations_with_separators
    result = permutations + permutations_with_separators

    # Convert result to a list of strings
    result = [''.join(p) for p in result]

    result = Remove(result)

    return result

#inefficient and bad coding practices, but I only need to run once so I threw together real quick
def side_inverse(pattern):
    if pattern in importantList:
        if pattern[0] == "b":
            if "r" in pattern:
                return ["b|rr"]
            else:
                return ["b|yy"]
        elif pattern[-1] == "b":
            if "r" in pattern:
                return ["rr|b"]
            else:
                return ["yy|b"]
        elif "r" in pattern:
            return ["rrr"]
        else:
            return ["yyy"]

    elif pattern in ["b|rr", "b|yy", "rr|b", "yy|b", "rrr", "yyy"]:
        if pattern == "yyy":
            return ['y|RR', 'R|yy', 'yyy']
        elif pattern == "rrr":
            return ['Y|rr', 'r|YY', 'rrr']
        elif pattern == "yy|b":
            return ['R|y|b', 'y|R|b', 'yy|b']
        elif pattern == "rr|b":
            return ['Y|r|b', 'r|Y|b', 'rr|b']
        elif pattern == "b|yy":
            return ['b|y|R', 'b|R|y', 'b|yy']
        else:
            return ['b|Y|r', 'b|r|Y', 'b|rr']

    else:
        inverse_pattern = ""
        for i in range(len(pattern)):
            if pattern[i] in ['Y', 'R']:
                if pattern[i] == 'Y':
                    inverse_pattern += 'R'
                else:
                    inverse_pattern += 'Y'
            else:
                inverse_pattern += pattern[i]
        return [inverse_pattern]

def top_inverse(pattern):
    if len(pattern) == 3 and pattern[0] != pattern[2]:
        return pattern[2] + pattern[1] + pattern[0]
    return [pattern]


def flip(arr):
    result = []
    for i in range(len(arr)):
        if i % 2 == 0:
            string = arr[i][::-1]
            string = swap_chars(string, "r", "y")
            string = swap_chars(string, "R", "Y")
            result.append(string)
        else:
            if i == 1:
                string = swap_chars(arr[3], "r", "y")
                string = swap_chars(string, "R", "Y")
                result.append(string)
            else:
                string = swap_chars(arr[1], "r", "y")
                string = swap_chars(string, "R", "Y")
                result.append(string)
    return result

def swap_chars(s, a, b):
    result = ''
    for i in range(len(s)):
        if s[i] == a:
            result += b
        elif s[i] == b:
            result += a
        else:
            result += s[i]
    return result

def printSpecialCases():
    for i in range(len(importantList)):
        print(importantList[i] + " -> " + str(side_inverse(importantList[i])))
    print()
    for i in range(len(["b|rr", "b|yy", "rr|b", "yy|b", "rrr", "yyy"])):
        print(["b|rr", "b|yy", "rr|b", "yy|b", "rrr", "yyy"][i] + " -> " + str(side_inverse(["b|rr", "b|yy", "rr|b", "yy|b", "rrr", "yyy"][i])))


#go through all, if flip doesnt equal itself, then add "fx.x"
#go through new all, compute valid socket combos with inverse (north, south east west)
#go through new all, compute neighbours by checking valid socket combos
#5,12 good test
#in stockCombos[i]
#print(allCombos())
#print(side_inverse("b|y|R"))
#print(flip(["b", "rrr", "y|r", "YYY"]))
#print(top_inverse("y|b"))
#print(importantList)
#printSpecialCases()

#adding to the json:
def readTileMap(tileMap):
    with open(tileMap, "r") as file:
        data = json.load(file)

    return data

def writeTileMap(dictionary, tileMap):
    with open(tileMap, "w") as file:
        json.dump(dictionary, file, indent=4)



def addFlips(tileMapFrom, tileMapTo):
    tileMap = readTileMap(tileMapFrom)

    newTileMap = {}

    for tile in tileMap:
        newTileMap[tile] = tileMap[tile]
        flippedSocket = flip(tileMap[tile]["socketTypes"])
        if tileMap[tile]["socketTypes"] != flippedSocket:
            newTileMap["f"+tile] = {"socketTypes": flippedSocket,"validSocketCombo": [],"validNeighbours": []}

    writeTileMap(newTileMap, tileMapTo)

#addFlips("tileMap.json", "tileMapWithFlips.json")
#flip has been completed


#computing valid socket combos:

def computeSocketCombos(tileMapFrom, tileMapTo):
    tileMap = readTileMap(tileMapFrom)


    newTileMap = {}

    for tile in tileMap:
        socketTypes = tileMap[tile]["socketTypes"]
        newTileMap[tile] = {"socketTypes": socketTypes,
        "validSocketCombo": [[socketTypes[0]], side_inverse(socketTypes[1]), [socketTypes[2]], side_inverse(socketTypes[3])]
        ,"validNeighbours": []}


    writeTileMap(newTileMap, tileMapTo)

#computeSocketCombos("tileMapWithFlips.json", "tileMapSocketCombos.json")
#valid socket combos have been completed

#compute valid neighbours:
def computeValidNeighbours(tileMapFrom, tileMapTo):
    tileMap = readTileMap(tileMapFrom)


    newTileMap = {}

    for tile in tileMap:
        socketTypes = tileMap[tile]["socketTypes"]
        socketCombos = tileMap[tile]["validSocketCombo"]
        validNeighbours = [[],[],[],[]]

        for compareTile in tileMap:
            compareSocket = tileMap[compareTile]["socketTypes"]
            for i in range(4):
                oppositeSide = (i + 4 // 2) % 4
                if compareSocket[oppositeSide] in socketCombos[i]:
                    validNeighbours[i].append(compareTile)

        newTileMap[tile] = {"socketTypes": socketTypes,
        "validSocketCombo": socketCombos
        ,"validNeighbours": validNeighbours}


    writeTileMap(newTileMap, tileMapTo)


#computeValidNeighbours("tileMapSocketCombos.json", "tileMapTight.json")

#some tiles are illigal: they have no valid socket combos on one side or more. This function will weed them out

def weed(tileMapFrom, tileMapTo):
    tileMap = readTileMap(tileMapFrom)

    illigals = []
    newTileMap = {}

    for tile in tileMap:
        socketTypes = tileMap[tile]["socketTypes"]
        socketCombos = tileMap[tile]["validSocketCombo"]
        validNeighbours = tileMap[tile]["validNeighbours"]

        for i in range(4):
            if validNeighbours[i] == []:
                illigals.append(tile)
                break

    for tile in tileMap:
        if not (tile in illigals):
            socketTypes = tileMap[tile]["socketTypes"]
            socketCombos = tileMap[tile]["validSocketCombo"]
            validNeighbours = tileMap[tile]["validNeighbours"]

            newValidNeighbours = [[],[],[],[]]

            for i in range(4):
                for j in range(len(validNeighbours[i])):
                    if not (validNeighbours[i][j] in illigals):
                        newValidNeighbours[i].append(validNeighbours[i][j])

            newTileMap[tile] = {"socketTypes": socketTypes,"validSocketCombo": socketCombos,"validNeighbours": newValidNeighbours}



    writeTileMap(newTileMap, tileMapTo)


#weed("tileMapTight.json", "tileMapCleanTight.json")

def addCorruptionLink(tileMapFrom, tileMapTo):
    tileMap = readTileMap(tileMapFrom)

    for tile in tileMap:
        for i in range(4):
            validNeighbours = tileMap[tile]["validNeighbours"][i].append("11,7")

    writeTileMap(tileMap, tileMapTo)

#addCorruptionLink("tileMapCleanTight.json", "tileMapCleanTight2.json")


def calcConnections(photo, json, yStart = 0, yStop = 32, xStart = 0, xStop = 19):
    tileMap = {}

    image = Image.open(photo)
    BLACK = (0, 0, 0, 255)
    RED = (172, 50, 50, 255)
    YELLOW = (251, 242, 54, 255)
    BLUE = (99, 155, 255, 255)
    GREEN1 = (75, 105, 47, 255) #light
    GREEN2 = (35, 60, 57, 255) #dark

    colorCode = {RED:"r", YELLOW:"y", BLUE:"b"}

    for y in range(yStart,yStop + 1,1):
        for x in range(xStart,xStop + 1,1):
            
            coords = (28*x, 28*y)
            topRight = getTopRight(coords, image)
            if topRight == GREEN1 or topRight == GREEN2 or (y == 11 and (x == 7 or x == 6)):
                continue


            """topAr = [None, None]
            botAr = [None, None]
            leftAr = [None, None, None]
            leftSep = [False, False]
            rightAr = [None, None, None]
            rightSep = [False, False]"""

            topAr = ["None", "None"]
            botAr = ["None", "None"]
            leftAr = ["None", "None", "None"]
            leftSep = [False, False]
            rightAr = ["None", "None", "None"]
            rightSep = [False, False]

            topRightSep = False
            topLeftSep = False
            botRightSep = False
            botLeftSep = False

            name = str(y) + "," + str(x)

            topLeft = getTopLeft(coords, image)
            botRight = getBotRight(coords, image)
            botLeft = getBotLeft(coords, image)
            top = getTop(coords, image)
            bot = getBot(coords, image)
            right = getRight(coords, image)
            left = getLeft(coords, image)

            topAr[0] = colorCode[getPixelAt(add(getTopLeft2(coords), (6,0)), image)]
            topAr[1] = colorCode[getPixelAt(add(getTopRight2(coords), (-6,0)), image)]

            botAr[0] = colorCode[getPixelAt(add(getBotLeft2(coords), (6,0)), image)]
            botAr[1] = colorCode[getPixelAt(add(getBotRight2(coords), (-6,0)), image)]



            


            if getPixelAt(add(getTopLeft2(coords), (1,6)), image) == BLACK or getPixelAt(add(getTopLeft2(coords), (1,8)), image) == BLACK:
                leftSep[0] = True
            if getPixelAt(add(getTopLeft2(coords), (1,20)), image) == BLACK or getPixelAt(add(getTopLeft2(coords), (1,22)), image) == BLACK:
                leftSep[1] = True

            if getPixelAt(add(getTopRight2(coords), (-1,6)), image) == BLACK or getPixelAt(add(getTopRight2(coords), (-1,8)), image) == BLACK:
                rightSep[0] = True
            if getPixelAt(add(getTopRight2(coords), (-1,20)), image) == BLACK or getPixelAt(add(getTopRight2(coords), (-1,22)), image) == BLACK:
                rightSep[1] = True


            leftAr[0] = colorCode[getPixelAt(add(getTopLeft2(coords), (1,5)), image)]
            leftAr[1] = colorCode[getPixelAt(add(getLeft2(coords), (1,0)), image)]
            leftAr[2] = colorCode[getPixelAt(add(getTopLeft2(coords), (1,23)), image)]

            rightAr[0] = colorCode[getPixelAt(add(getTopRight2(coords), (-1,5)), image)]
            rightAr[1] = colorCode[getPixelAt(add(getRight2(coords), (-1,0)), image)]
            rightAr[2] = colorCode[getPixelAt(add(getTopRight2(coords), (-1,23)), image)]
            

            if getPixelAt(add(getTopLeft2(coords), (0,5)), image) == BLACK:
                leftAr[0] = leftAr[0].upper()
            if getPixelAt(getLeft2(coords), image) == BLACK:
                leftAr[1] = leftAr[1].upper()
            if getPixelAt(add(getTopLeft2(coords), (0,23)), image) == BLACK:
                leftAr[2] = leftAr[2].upper()

            if getPixelAt(add(getTopRight2(coords), (0,5)), image) == BLACK:
                rightAr[0] = rightAr[0].upper()
            if getPixelAt(getRight2(coords), image) == BLACK:
                rightAr[1] = rightAr[1].upper()
            if getPixelAt(add(getTopRight2(coords), (0,23)), image) == BLACK:
                rightAr[2] = rightAr[2].upper()



            if botAr[0] == botAr[1]:
                botAr = [botAr[0]]

            if topAr[0] == topAr[1]:
                topAr = [topAr[0]]

            #print(name, " has been finished")
            socketTypes = arrsToRules(topAr, botAr, rightAr, leftAr, rightSep, leftSep)
            
            tileMap[name] = {"socketTypes": socketTypes,"validSocketCombo": [],"validNeighbours": []}

    writeTileMap(tileMap, json)



def arrsToRules(topAr, botAr, rightAr, leftAr, rightSep, leftSep):
    socketTypes = []

    socketTypes.append(topAr[0])
    if len(topAr) != 1:
        socketTypes[0] = topAr[0] + "|" + topAr[1]

    right = "".join(rightAr)
    if rightSep[0]:
        right = right[:1] + "|" + right[1:]
        if rightSep[1]:
            right = right[:3] + "|" + right[3:]
    elif rightSep[1]:
        right = right[:2] + "|" + right[2:]

    socketTypes.append(right)

    socketTypes.append(botAr[0])
    if len(botAr) != 1:
        socketTypes[2] = botAr[0] + "|" + botAr[1]

    left = "".join(leftAr)
    if leftSep[0]:
        left = left[:1] + "|" + left[1:]
        if leftSep[1]:
            left = left[:3] + "|" + left[3:]
    elif leftSep[1]:
        left = left[:2] + "|" + left[2:]

    socketTypes.append(left)

    return socketTypes


def getTop(coords, photo):
    trueCoords = add(coords, (13, 0))
    return getPixelAt(trueCoords, photo)
def getTopLeft(coords, photo):
    trueCoords = add(coords, (0, 0))
    return getPixelAt(trueCoords, photo)
def getTopRight(coords, photo):
    trueCoords = add(coords, (27, 0))
    return getPixelAt(trueCoords, photo)

def getBot(coords, photo):
    trueCoords = add(coords, (13, 27))
    return getPixelAt(trueCoords, photo)
def getBotRight(coords, photo):
    trueCoords = add(coords, (27, 27))
    return getPixelAt(trueCoords, photo)
def getBotLeft(coords, photo):
    trueCoords = add(coords, (0, 27))
    return getPixelAt(trueCoords, photo)

def getRight(coords, photo):
    trueCoords = add(coords, (27, 13))
    return getPixelAt(trueCoords, photo)
def getLeft(coords, photo):
    trueCoords = add(coords, (0, 13))
    return getPixelAt(trueCoords, photo)

def getTop2(coords):
    trueCoords = add(coords, (13, 0))
    return trueCoords
def getTopLeft2(coords):
    trueCoords = add(coords, (0, 0))
    return trueCoords
def getTopRight2(coords):
    trueCoords = add(coords, (27, 0))
    return trueCoords

def getBot2(coords):
    trueCoords = add(coords, (13, 27))
    return trueCoords
def getBotRight2(coords):
    trueCoords = add(coords, (27, 27))
    return trueCoords
def getBotLeft2(coords):
    trueCoords = add(coords, (0, 27))
    return trueCoords

def getRight2(coords):
    trueCoords = add(coords, (27, 13))
    return trueCoords
def getLeft2(coords):
    trueCoords = add(coords, (0, 13))
    return trueCoords

def getPixelAt(coords, image):
    pixel_color = image.getpixel(coords)
    return pixel_color

def add(tuple1, tuple2):
    return (tuple1[0] + tuple2[0], tuple1[1] + tuple2[1])


calcConnections("tilemapCubePremium.png", "scriptTileMap.json")
addFlips("scriptTileMap.json", "scriptTileMapWithFlips.json")
computeSocketCombos("scriptTileMapWithFlips.json", "scriptTileMapSocketCombos.json")
computeValidNeighbours("scriptTileMapSocketCombos.json", "scriptTileMapTight.json")
weed("scriptTileMapTight.json", "scriptTileMapCleanTight.json")
addCorruptionLink("scriptTileMapCleanTight.json", "longIllegal.json")
