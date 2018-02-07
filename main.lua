-- 320x480
local widget = require( "widget" )
local json = require("json")
local loadsave = require("loadsave")

local centerX = display.contentCenterX
local centerY = display.contentCenterY
local _W = display.contentWidth
local _H = display.contentHeight
local numColumns = 7
local numRows = 7
local xForm = (_W-numColumns*40)/2-20
local yForm = (_H-numRows*40)/2-20
local storage = {}
local canPlay = 1
local switchTime = 200
local dieTime = 500
local operation = 1
local ended = 1
local ching = 0
local usingChannel = 0
local map = {}
local musicMenu = 0
local questionMenu = 0
local creditMenu = 0
local function resetMap(event)
	for i = 1,49 do
		map[i] = i
	end
end
resetMap()
local group = display.newGroup()
list = {}
listClear = 1
rowClear = {}
local pts = 0
audioVolume = 1
local clock = 1
audio.setVolume( audioVolume, { channel = 1 } )
audio.setVolume( audioVolume, { channel = 5 })
audio.setVolume( audioVolume, { channel = 2 })
audioLoaded = audio.loadSound( "secrets.wav" )
audio.play( audioLoaded, { channel = 5, loops = -1 } ) 

print('screen is '.._W.."by".._H)

local function calc(i,j)
	return((i-1)*numRows+(j))
end

local function sliderListener( event )
	local value = event.value
		    		    
	--Convert the value to a floating point number we can use it to set the audio volume	
	audioVolume = value / 100
	audioVolume = string.format('%.02f', audioVolume )
				
	--Set the audio volume at the current level
   	audio.setVolume( audioVolume, { channel = 1 } )
	audio.setVolume( audioVolume, { channel = 5 })
	audio.setVolume( audioVolume, { channel = 2 })
end

local function noThrough(event)
	return true
end
local background4 = display.newImage( "background2.png", centerX, centerY-10, true )
background4.alpha = 0
background4:addEventListener( "touch", noThrough )
questionSet = display.newGroup()
local explanation = display.newImage( "explain.png", centerX, centerY, true)
local function closeQuestionFn(event)
	background4.alpha = 0
	questionSet.alpha = 0
	questionMenu = 0
end
closeQuestion = widget.newButton{
	defaultFile = "close.png",
	onPress = closeQuestionFn,
}
closeQuestion.x, closeQuestion.y = _W-25, -5
local function linkWeb(event)
	system.openURL("http://www.recologysf.com/index.php/for-homes/residential-recycling-compost-trash#recycling")
end
recology = widget.newButton{
	defaultFile = "link.png",
	onPress = linkWeb,
}
recology.x, recology.y = centerX, _H-45
questionSet:insert(closeQuestion)
questionSet:insert(explanation)
questionSet:insert(recology)
local creditSet = display.newGroup()

local background5 = display.newImage( "background2.png", centerX, centerY-10, true )
background5.alpha = 0
background5:addEventListener( "touch", noThrough )
local function creditFn( event )
	background5.alpha = 1
	background5:toFront()
	creditSet.alpha = 1
	creditSet:toFront()
	creditMenu = 1
end
credit = widget.newButton{
	defaultFile= "letter.png",
	onPress = creditFn,
}
credit.x,credit.y = centerX/2, _H
local function closeCreditFn(event)
	background5.alpha = 0
	creditSet.alpha = 0
	creditMenu = 0
end
closeCredit = widget.newButton{
	defaultFile = "close.png",
	onPress = closeCreditFn,
}
closeCredit.x, closeCredit.y = _W-25, -5
creditSet:insert(closeCredit)
local source = display.newImage( "sources.png", centerX, centerY-10, true )
creditSet:insert(source)

local background2 = display.newImage( "background2.png", centerX, centerY-10, true )
background2.alpha = 0
background2:addEventListener( "touch", noThrough )
local scoreGroup = display.newGroup()
local setings = display.newGroup()
local background3 = display.newImage( "end.png", centerX, centerY-10, true )
background3.alpha = 1
background3:addEventListener( "touch", noThrough )
background3:toFront()
scoreGroup:insert(background3)
local noise = display.newGroup()
local volume = widget.newSlider{
	top = 410,
	left = 50,
	listener = sliderListener
}
noise:insert(volume)
local function markFn(event)
	questionMenu = 1
	background4.alpha = 1
	background4:toFront()
	questionSet.alpha = 1
	questionSet:toFront()
end
local question = widget.newButton{
	defaultFile="mark.png",
	onPress = markFn,
}
question.x,question.y = _W-centerX/2, _H
setings:insert(question)
local function closeNoiseFn(event)
	background2.alpha = 0
	noise.alpha = 0
	musicMenu = 0
end
closeNoise = widget.newButton{
	defaultFile = "close.png",
	onPress = closeNoiseFn,
}
closeNoise.x, closeNoise.y = _W-25, 10
noise:insert(closeNoise)
local function create2( i, j, name, types )
	local trash = display.newImage(name, 40*i+xForm, 40*j+yForm, true)
	noise:insert(trash)
end

for ty = 1,5 do
	for j = 1,5 do
		if ty == 1 then
			create2(ty,j,"glass "..j..".png", ty)
		end
		if ty == 2  then
			create2(ty,j,"battery "..j..".png", ty)
		end
		if ty == 3 then
			create2(ty,j, "compost "..j..".png", ty)
		end
		if ty == 4  then
			create2(ty,j, "metal "..j..".png", ty)
		end
		if ty == 5 then
			create2(ty,j, "trash "..j..".png", ty)
		end
	end
end
local background = display.newImage( "paper.png", centerX, centerY-10, true )
backGroup = display.newGroup()
local score = display.newText("", centerX+95, 100 + display.screenOriginY, native.systemFont, 25)
score.text = pts
local title = display.newImage("Title.png", centerX, 15, true)
noise.alpha = 0
local clockOutline = display.newImage("clock.png", 35, 65, true)
local clockText = display.newText("", 35, 111 + display.screenOriginY, native.systemFont, 25)
clockText.text = clock
local text = display.newText( "Score", centerX, centerY-15, native.systemFont, 25)
local tempScore = display.newText(pts, centerX, centerY+10, native.systemFont, 25)
local text2 = display.newText( "High Score", centerX, centerY-60, native.systemFont, 25)
local high = display.newText("later when i json", centerX, centerY-35, native.systemFont, 25)
text:setFillColor(0, 0.65,0.1)
text2:setFillColor(0, 0.65,0.1)
high:setFillColor(0, 0.65,0.1)
tempScore:setFillColor(0, 0.65,0.1)
scoreGroup:insert(text)
scoreGroup:insert(tempScore)
scoreGroup:insert(text2)
scoreGroup:insert(high)
local function musicf(event)
	background2.alpha = 0.3
	background2:toFront()
	noise:toFront()
	noise.alpha = 1
	musicMenu = 1
end
music = widget.newButton{
	defaultFile = "music.png",
	onPress = musicf,
}
music.x, music.y = centerX, _H
setings:insert(music)
setings:insert(credit)
setings:toFront()

local function timeIncrement( binary )
	if binary == 0 then
		if clock < 94 then
			clock = clock + 4
			clockText.text = clock
		else
			clock = 99
			clockText.text = clock
		end
	elseif binary == 1 then
		if clock < 89 then
			clock = clock + 10
			clockText.text = clock
		else
			clock = 99
			clockText.text = clock
		end
	end
end

local function changeBlock( num )
	randomize = math.random(1,5)
	ran = string.format('%2.0f', randomize )
	if num == 1 then
		return "glass"..ran..".png"
	elseif num == 2 then
		return "battery"..ran..".png"
	elseif num == 3 then
		return "compost"..ran..".png"
	elseif num == 4 then
		return "metal"..ran..".png"
	elseif num == 5 then
		return "trash"..ran..".png"
	end
end

local function evaluate ( event )
	if ended == 1 and operation == 1 and canPlay == 0 then
		canPlay = 1
	end
end

local function checkElement( element, table )
	count = 0
	for i in pairs(list) do
		count = count + 1
	end
	for i=1,count do
		print(table[i])
		if table[i] == element then
			return true
		end
	end
	return false
end

local function create( i, j, name, types )
	local trash = display.newImage (name, 40*i+xForm, 40*j+yForm, true)
	storage[calc(i,j)] = types
	trash.type = types
	group:insert(trash)
end

local function fillRows( event )
	rowsToClear = 0
	for i in pairs(rowClear) do
		rowsToClear = rowsToClear + 1
	end
	alreadyUsed = {}
	countSeparate = 0
	for i = 1,rowsToClear do
		rowNumber = 0
		k = numColumns+1 
		for g = 1,rowsToClear do
			if not checkElement( rowClear[g], alreadyUsed ) then
				if rowClear[g] < k then
					k = rowClear[g]
				end
			end
		end
		table.insert(alreadyUsed, k)
		complete = {}
		otherImp = {}
		for p = 1,numColumns do
			table.insert(complete, {(k*7-p+1),0})
		end
		for j = 1, numColumns do
			if map[k*7-j+1] then
			else
				complete[j] = {(k*7-j+1),0}
				table.insert(otherImp, (k*7-j+1))
				for l = j+1, numColumns do
					temporary=complete[l][2]
					complete[l] = {(k*7-l+1),temporary+1}
				end
			end
		end
		numberMoving = 0
		for i in pairs(complete) do
			numberMoving = numberMoving + 1
		end
		for j = 1,numberMoving do
			if (complete[j][2]) ~= 0 then
				transition.to( group[map[complete[j][1]]], { time=switchTime/2*complete[j][2], x=backGroup[complete[j][1]].x, y=backGroup[complete[j][1]].y+40*complete[j][2], alpha=1.0} )
				switch = map[complete[j][1]]
				switchOther = map[(complete[j][1]+complete[j][2])]
				if switch == nil then
					print("nil= switch")
				else
					print(switch.."= switch")
				end
				if switchOther == nil then
					print("nil=switchOther")
				else
					print(switchOther.."=switchOther")
				end
				map[complete[j][1]] = switchOther
				map[(complete[j][1]+complete[j][2])] = switch
			end
		end
		numberReplacingInRow = 0
		for i in pairs(otherImp) do
			numberReplacingInRow = numberReplacingInRow + 1
		end
		print(numberReplacingInRow.."is number to replace in row"..k)
		rowCompleted = 0
		for i = 1,numberReplacingInRow do
			if rowCompleted == 0 then 
				for j = 1,numColumns do
					if map[(k-1)*7+j] and i==1 then
						print("map #"..((k-1)*7+j).."is mapped to"..map[j])
					elseif not map[(k-1)*7+j] then
						countSeparate = countSeparate + 1
						rowNumber = rowNumber+1
						image = math.random(1,5)
						create( k, rowNumber, changeBlock( image ), image )
						groupLen = 1
						while true do
							if group[groupLen] then
								groupLen = groupLen +1
							else
								groupLen = groupLen -1
								break
							end
						end
						print("map #"..((k-1)*7+j).."is mapped to "..groupLen)
						map[(k-1)*7+j] = groupLen
					end
				end
				rowCompleted = 1
			end
		end
	end
	rowClear = nil
	rowClear = {}
	special = nil
	special = {}
end

local function obtainRow( entry )
	if entry > 7 then
		if entry > 14 then
			if entry > 21 then
				if entry > 28 then
					if entry > 35 then
						if entry > 42 then
							if entry < 50 then
								return 7
							end
						else
							return 6
						end
					else
						return 5
					end
				else
					return 4
				end
			else
				return 3
			end
		else
			return 2
		end
	elseif entry > 0 then
		return 1
	end
end

local function remove( event )
	print('i am running')
	count = 0
	special = {}
	for i in pairs(list) do
		count = count + 1
	end
	for i = 1,count do
		group[map[list[i]]].alpha = 0
		group[map[list[i]]].x = 0
		group[map[list[i]]].y = 0
		group[map[list[i]]] = 'nil'
		table.insert(special, map[list[i]])
		--print("item in spot"..list[i].."was "..map[list[i]])
		map[list[i]] = nil
		if not checkElement(obtainRow(list[i]), rowClear) then
			--print("inserting row"..obtainRow(list[i]))
			table.insert(rowClear, obtainRow(list[i]))
		end
	end
	fillRows()
	list = nil
	list = {}
	operation2 = 0
end

local function clear( table )
	listClear = 0
	count = 0
	for i in pairs(list) do
		count = count + 1
	end
	for i = 1,count do
		transition.to( group[map[list[i]]], { time=dieTime, xScale=.2, yScale=.2 } )
		pts = pts+1
		score.text = pts
	end
	timer.performWithDelay(dieTime, function() remove() end, 1)
end

local function transitionOther( identity1, identity2, direction )
	if direction == "right" then
		transition.to( group[map[identity1]], { time=switchTime, x=backGroup[identity1].x+40, y=backGroup[identity1].y, alpha=1.0} )
		transition.to(group[map[identity2]], { time=switchTime, x=backGroup[identity2].x-40, y=backGroup[identity2].y, alpha=1.0})
	elseif direction == "left" then
		transition.to( group[map[identity1]], { time=switchTime, x=backGroup[identity1].x-40, y=backGroup[identity1].y, alpha=1.0} )
		transition.to(group[map[identity2]], { time=switchTime, x=backGroup[identity2].x+40, y=backGroup[identity2].y, alpha=1.0})
	elseif direction == "up" then
		transition.to( group[map[identity1]], { time=switchTime, x=backGroup[identity1].x, y=backGroup[identity1].y-40, alpha=1.0} )
		transition.to(group[map[identity2]], { time=switchTime, x=backGroup[identity2].x, y=backGroup[identity2].y+40, alpha=1.0})
	elseif direction == "down" then
		transition.to( group[map[identity1]], { time=switchTime, x=backGroup[identity1].x, y=backGroup[identity1].y+40, alpha=1.0} )
		transition.to(group[map[identity2]], { time=switchTime, x=backGroup[identity2].x, y=backGroup[identity2].y-40, alpha=1.0})
	end
	switch = map[identity1]
	switchOther = map[identity2]
	map[identity1] = switchOther
	map[identity2] = switch
end

local function insert( array, thing, note )
	if checkElement( thing, array ) then
		return true
	else
		table.insert(array, thing)
		listClear = 0
	end
	if note == 1 then
		ching = ching + 1
		print("incrementing ching")
	end
end

local function delete( target )
	print(target.identity.."is identity")
	if target.identity > 14 then 
		if group[map[target.identity-7]].type == group[map[target.identity]].type then
			if group[map[target.identity-14]].type == group[map[target.identity]].type then
				insert(list, target.identity, 1)
				print("linserted "..target.identity)
				insert(list, target.identity-7, 0)
				print("linserted "..target.identity-7)
				insert(list, target.identity-14, 0)
				print("linserted "..target.identity-14)
				print("left final")
				if target.identity < 43 then
					if group[map[target.identity+7]].type == group[map[target.identity]].type then
						insert(list, target.identity+7, 0)
						print("linserted "..target.identity+7)
						if target.identity < 36 and group[map[target.identity+14]].type == group[map[target.identity]].type then
							insert(list, target.identity+14, 0)
							print("linserted "..target.identity+14)
							timeIncrement( 1 )
						else
							timeIncrement( 0 )
						end
					end
				end
			end
		end
	end
	if target.identity < 36 then 
		if group[map[target.identity+7]].type == group[map[target.identity]].type then
			if group[map[target.identity+14]].type == group[map[target.identity]].type then
				insert(list, target.identity, 1)
				print("rinserted "..target.identity)
				insert(list, target.identity+7, 0)
				print("rinserted "..target.identity+7)
				insert(list, target.identity+14, 0)
				print("rinserted "..target.identity+14)
				print("right final")
				if target.identity > 7 then
					if group[map[target.identity-7]].type == group[map[target.identity]].type then
						insert(list, target.identity-7, 0)
						print("rinserted "..target.identity-7)
						if target.identity > 14 and group[map[target.identity-14]].type == group[map[target.identity]].type then
							insert(list, target.identity-14, 0)
							print("rinserted "..target.identity-14)
							timeIncrement( 1)
						else
							timeIncrement( 0 )
						end
					end
				end
			end
		end
	end
	if target.identity%7>2 or target.identity%7 == 0 then
		if group[map[target.identity-1]].type == group[map[target.identity]].type then
			if group[map[target.identity-2]].type == group[map[target.identity]].type then
				insert(list, target.identity, 1)
				print("uinserted "..target.identity)
				print("up final")
				insert(list, target.identity-1, 0)
				print("uinserted "..target.identity-1)
				insert(list, target.identity-2, 0)
				print("uinserted "..target.identity-2)
				if target.identity%7<7 then
					if group[map[target.identity+1]].type == group[map[target.identity]].type then
						insert(list, target.identity+1, 0)
						if target.identity%7<6 and group[map[target.identity+2]].type == group[map[target.identity]].type then
							insert(list, target.identity+2, 0)
							print("uinserted "..target.identity+2)
							timeIncrement( 1)
						else
							timeIncrement( 0 )
						end
					end
				end
			end
		end
	end
	if target.identity%7<6 and target.identity%7 ~= 0 then
		if group[map[target.identity+1]].type == group[map[target.identity]].type then
			if group[map[target.identity+2]].type == group[map[target.identity]].type then
				insert(list, target.identity, 1)
				print("dinserted "..target.identity)
				print("down final")
				insert(list, target.identity+1, 0)
				print("dinserted "..target.identity+1)
				insert(list, target.identity+2, 0)
				print("dinserted "..target.identity+2)
				if target.identity%7>1 then
					if group[map[target.identity-1]].type == group[map[target.identity]].type then
						insert(list, target.identity-1, 0)
						print("dinserted "..target.identity-1)
						if target.identity%7>2 and group[map[target.identity-2]].type == group[map[target.identity]].type then
							insert(list, target.identity-2, 0)
							print("dinserted "..target.identity-2)
							timeIncrement( 1)
						else
							timeIncrement( 0 )
						end
					end
				end
			end
		end
	end
	if target.identity%7<7 and target.identity%7>1 then
		if group[map[target.identity+1]].type == group[map[target.identity]].type then
			if group[map[target.identity-1]].type == group[map[target.identity]].type then
				insert(list, target.identity, 1)
				print("hminserted "..target.identity)
				print("hmiddle final")
				insert(list, target.identity+1, 0)
				print("hminserted "..target.identity+1)
				insert(list, target.identity-1, 0)
				print("hminserted "..target.identity-1)
			end
		end
	end
	if target.identity<43 and target.identity>7 then
		if group[map[target.identity+7]].type == group[map[target.identity]].type then
			if group[map[target.identity-7]].type == group[map[target.identity]].type then
				insert(list, target.identity, 1)
				print("vmiddle final")
				print("vminserted "..target.identity)
				insert(list, target.identity+7, 0)
				print("vminserted "..target.identity+7)
				insert(list, target.identity-7, 0)
				print("vminserted "..target.identity-7)
			end
		end
	end
end 

local function clearOut( event )
	if operation2 == 0 and not list[1] then 
		print('clearing out')
		for i = 1,(numColumns*numRows) do
			delete(backGroup[i])
		end
		if list[1] then
			clear(list)
			print('clearing')
		else
			operation2 = 1
			operation = 1
		end
	end
end

local function swipeHandler( event )
	if event.phase == "moved" and canPlay == 1 then
		local dX = event.x - event.xStart
		local dY = event.y - event.yStart
		if math.abs(dX) > math.abs(dY) then
			if dX > 10 then
				print ("right")
				operation = 0
				canPlay = 0
				ended = 0
				if event.target.xPosition > (numColumns-1) then
					canPlay = 1
				else
					transitionOther(event.target.identity, event.target.identity+7, "right")
					list = nil
					list = {}
					listClear = 1
					delete(event.target)
					delete(backGroup[event.target.identity+7])
					if list[1] then
						clear( list )
					else
						print("reswitched")
						timer.performWithDelay(250, function() transitionOther(event.target.identity, event.target.identity+7, "right") end, 1)
						operation = 1
					end
 				end
			elseif dX < -10 then
				print("left")
				operation = 0
				canPlay = 0
				ended = 0
				if event.target.xPosition < 2 then
					canPlay = 1
				else
					transitionOther( event.target.identity, event.target.identity-7, "left" )
					list = nil
					list = {}
					listClear = 1
					delete(event.target)
					delete(backGroup[event.target.identity-7])
					if list[1] then
						clear( list )
					else
						print("reswitched")
						timer.performWithDelay(250, function() transitionOther(event.target.identity, event.target.identity-7, "left") end, 1)
						operation = 1
					end
				end
			end
		elseif math.abs(dY) > math.abs(dX) then
			if dY > 10 then
				print ("down")
				operation = 0
				canPlay = 0
				ended = 0
				if event.target.yPosition > (numRows-1) then
					canPlay = 1
				else
					transitionOther( event.target.identity, event.target.identity+1, "down")
					list = nil
					list = {}
					listClear = 1
					delete(event.target)
					delete(backGroup[event.target.identity+1])
					if list[1] then
						clear( list )
					else
						print("reswitched")
						timer.performWithDelay(250, function() transitionOther(event.target.identity, event.target.identity+1, "down") end, 1)
						operation = 1
					end
				end
			elseif dY < -10 then
				print("up")
				operation = 0
				canPlay = 0
				ended = 0
				if event.target.yPosition < 2 then
					canPlay = 1
				else
					transitionOther( event.target.identity, event.target.identity-1, "up")
					list = nil
					list = {}
					listClear = 1
					delete(event.target)
					delete(backGroup[event.target.identity-1])
					if list[1] then
						clear( list )
					else
						print("reswitched")
						timer.performWithDelay(250, function() transitionOther(event.target.identity, event.target.identity-1, "up") end, 1)
						operation = 1
					end
				end
			end
		end
	end
	if event.phase == "ended" then
		ended = 1
	end
	return true
end

for i = 1,numColumns do
	for j = 1,numRows do
		local space = display.newImage("crate.png", 40*i+xForm, 40*j+yForm, true)
		space.alpha = 0.3
		space.identity = calc(i,j)
		space.xPosition = i
		space.yPosition = j
		space:addEventListener( "touch", swipeHandler )
		backGroup:insert(space)
	end
end

local function check(i,j,types)
	if i >= 3 then
		if storage[calc(i-1,j)] == storage[calc(i-2,j)] then
			if storage[calc(i-1,j)] == types then
				return false
			end
		end
	end
	if j>=3 then
		if storage[calc(i,j-1)] == storage[calc(i,j-2)] then
			if storage[calc(i,j)-1] == types then
				return false
			end
		end
	end
	return true
end

yes = display.newGroup()

--local function debug()
--	yes:removeSelf()
--	yes = nil
--	yes = display.newGroup()
--	for i = 1,49 do
--		local key = display.newText(map[i], 40*backGroup[i].xPosition+xForm, 40*backGroup[i].yPosition+yForm, native.systemFont, 25)
--		yes:insert(key)
--	end
--	for i = 1,49 do
--		print(backGroup[i].xPosition..", "..backGroup[i].yPosition)
--	end
--end

--goAgain = widget.newButton
--{
--	defaultFile = "Chest Closed.png",
--	onPress = debug,
--}
local function createTrash( event )
	for i = 1,numColumns do
		for j = 1,numRows do
			types = math.random(1,5)
			randomize = math.random(1,5)
			ran = string.format('%2.0f', randomize )
			if (types == 1 and check(i,j,types)) then
				create(i,j,"glass"..ran..".png", types)
			elseif types == 1 then
				types = types + 1
			end
			if (types == 2 and check(i,j,types)) then
				create(i,j,"battery"..ran..".png", types)
			elseif types == 2 then
				types = types + 1
			end
			if (types == 3 and check(i,j,types)) then
				create(i,j, "compost"..ran..".png", types)
			elseif types == 3 then
				types = types + 1
			end
			if (types == 4 and check(i,j,types)) then
				create(i,j, "metal"..ran..".png", types)
			elseif types == 4 then
				types = types + 1
			end
			if (types == 5 and check(i,j,types)) then
				create(i,j, "trash"..ran..".png", types)
			elseif types == 5 then
				types = 1
					if (types == 1 and check(i,j,types)) then
						create(i,j,"glass"..ran..".png", types)
					elseif types == 1 then
						types = types + 1
					end
					if (types == 2 and check(i,j,types)) then
						create(i,j,"battery"..ran..".png", types)
					elseif types == 2 then
						types = types + 1
					end
			end
		end
	end
end
createTrash()

local function reset( event )
	usingChannel = 0
end

local function coiner( event )
	if ching > 0 and usingChannel == 0 then
		audioLoaded = audio.loadSound( "coin.wav" )
		usingChannel = 1
		audio.play( audioLoaded, { channel = 1, loops = 0, onComplete=reset } ) 
		ching = ching-1
	end
end

local function highScore( event )
	loaded = loadsave.loadTable("settings.json")
	if loaded == nil then
		topScore = {}
		topScore.current=0
	else
		topScore = loaded
	end
	if topScore == nil then
		topScore = {}
		topScore.current=0
		tempNum = tonumber(topScore.current)
	elseif topScore.current == nil then
		topScore = {}
		topScore.current=0
		tempNum = tonumber(topScore.current)
	else
		tempNum = tonumber(topScore.current)
	end
	if pts > tempNum then
		topScore.current = pts
	end
	high.text = topScore.current
	scoreGroup.alpha = 1
	scoreGroup:toFront()
	title:toFront()
	setings:toFront()
	tempScore.text=pts
	loadsave.saveTable(topScore, "settings.json")
end

local function deincrement( event )
	if clock > 0 then
		clock = clock-1
		clockText.text = clock
		audioLoaded = audio.loadSound( "tick.wav" )
		audio.play( audioLoaded, { channel = 2, loops = 0 } ) 
	else
		highScore()
	end
	if musicMenu == 1 then
		background2:toFront()
		noise:toFront()
	end
	if questionMenu ==1 then
		background4:toFront()
		questionSet:toFront()
	end
	if creditMenu ==1 then
		background5:toFront()
		creditSet:toFront()
	end
end

local function start(event)
	pts = 0
	score.text = pts
	clock = 60
	clockText.text = 60
	scoreGroup.alpha = 0
	resetMap()
	group:removeSelf()
	group = display.newGroup()
	createTrash()
end
goAgain = widget.newButton
{
	defaultFile = "replay.png",
	onPress = start,
}
goAgain.x, goAgain.y = centerX, centerY+50
scoreGroup:insert(goAgain)

timer.performWithDelay(1000, function() deincrement() end, -1)
timer.performWithDelay(16.7, function() coiner() end, -1)
timer.performWithDelay(16.7, function() evaluate() end, -1)
timer.performWithDelay(16.7, function() clearOut() end, -1)
group:toFront()