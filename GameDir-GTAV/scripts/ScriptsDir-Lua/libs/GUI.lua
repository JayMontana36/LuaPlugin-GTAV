local Info = Info

local print = print
local type = type
local ipairs = ipairs
local pairs = function(t)return next,t end -- avoid using __pairs in Lua 5.2+

local DrawRect = DrawRect
local GetScreenResolution = GetScreenResolution
local SetTextFont = SetTextFont
local SetTextScale = SetTextScale
local SetTextColour = SetTextColour
local SetTextCentre = SetTextCentre
local SetTextDropshadow = SetTextDropshadow
local SetTextEdge = SetTextEdge
local BeginTextCommandDisplayText = BeginTextCommandDisplayText
local AddTextComponentSubstringPlayerName = AddTextComponentSubstringPlayerName
local EndTextCommandDisplayText = EndTextCommandDisplayText

local get_key_pressed = get_key_pressed

local GUI = {}
GUI.GUI = {}
GUI.buttonCount = 0
GUI.loaded = false
GUI.selection = 0
GUI.time = 0
GUI.hidden = false
function GUI.addButton(name, func,args, xmin, xmax, ymin, ymax)
	print("Added Button "..name )
	GUI.GUI[GUI.buttonCount +1] = {}
	GUI.GUI[GUI.buttonCount +1]["name"] = name
	GUI.GUI[GUI.buttonCount+1]["func"] = func
	GUI.GUI[GUI.buttonCount+1]["args"] = args
	GUI.GUI[GUI.buttonCount+1]["active"] = false
	GUI.GUI[GUI.buttonCount+1]["xmin"] = xmin
	GUI.GUI[GUI.buttonCount+1]["ymin"] = ymin * (GUI.buttonCount + 0.01) +0.02
	GUI.GUI[GUI.buttonCount+1]["xmax"] = xmax 
	GUI.GUI[GUI.buttonCount+1]["ymax"] = ymax 
	GUI.buttonCount = GUI.buttonCount+1
end
function GUI.init()
	GUI.loaded = true
end
function GUI.tick()
	if(not GUI.hidden)then
		if( GUI.time == 0) then
			GUI.time = Info.Time
		end
		if((Info.Time - GUI.time)> 100) then
			GUI.updateSelection()
		end	
		GUI.renderGUI()	
		if(not GUI.loaded ) then
			GUI.init()	 
		end
	end
end

function GUI.updateSelection() 
	if(get_key_pressed(Keys.NumPad2)) then 
		if(GUI.selection < GUI.buttonCount -1  )then
			GUI.selection = GUI.selection +1
			GUI.time = 0
		end
	elseif (get_key_pressed(Keys.NumPad8) )then
		if(GUI.selection > 0)then
			GUI.selection = GUI.selection -1
			GUI.time = 0
		end
	elseif (get_key_pressed(Keys.Space)) then
		if(type(GUI.GUI[GUI.selection +1]["func"]) == "function") then
			GUI.GUI[GUI.selection +1]["func"](GUI.GUI[GUI.selection +1]["args"])
		else
			print(type(GUI.GUI[GUI.selection]["func"]))
		end
		GUI.time = 0
	end
	local iterator = 0
	for id, settings in ipairs(GUI.GUI) do
		GUI.GUI[id]["active"] = false
		if(iterator == GUI.selection ) then
			GUI.GUI[iterator +1]["active"] = true
		end
		iterator = iterator +1
	end
end

function GUI.renderGUI()
	 GUI.renderButtons()
end
function GUI.renderBox(xMin,xMax,yMin,yMax,color1,color2,color3,color4)
	DrawRect(xMin, yMin,xMax, yMax, color1, color2, color3, color4)
end

function GUI.renderButtons()
	for id, settings in pairs(GUI.GUI) do
		local screen_w, screen_h = GetScreenResolution(0, 0)
		local r, g, b, a = 70, 95, 95, 255
		if(settings["active"]) then
			r, g, b, a = 218, 242, 216, 255
		end
		SetTextFont(0)
		SetTextScale(0.0, 0.35)
		SetTextColour(255, 255, 255, 255)
		SetTextCentre(true)
		SetTextDropshadow(0, 0, 0, 0, 0)
		SetTextEdge(0, 0, 0, 0, 0)
		BeginTextCommandDisplayText("STRING")
		AddTextComponentSubstringPlayerName(settings["name"])
		EndTextCommandDisplayText(settings["xmin"]+ 0.05, (settings["ymin"] - 0.0125 ))
		--AddTextComponentSubstringPlayerName(settings["name"])
		GUI.renderBox(settings["xmin"] ,settings["xmax"], settings["ymin"], settings["ymax"], r, g, b, a)
	 end     
end
return GUI