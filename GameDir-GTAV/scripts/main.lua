-- Config Area
DebugMode       = false
Scripts_Path    = "scripts\\ScriptsDir-Lua\\" or "C:\\Path\\To\\ScriptsDir-Lua\\"



-- Script/Code Area
--[[ Define JM36 LP Version ]]
JM36_GTAV_LuaPlugin_Version=20230825.0



--[[ Localize all "frequently" used things ]]
local Scripts_Path = Scripts_Path
local setmetatable = setmetatable
local pairs = pairs
local type = type
local coroutine = coroutine
local coroutine_yield = coroutine.yield
local coroutine_create = coroutine.create
local coroutine_wrap = coroutine.wrap
local coroutine_resume = coroutine.resume
local coroutine_status = coroutine.status
local table_sort = table.sort
local lfs_dir = lfs.dir
local print = print
local pcall = pcall
local require = require
local collectgarbage = collectgarbage



--[[ Set the garbage collector to be more aggressive by default (from 200,200 to 100,100) ]]
collectgarbage("setpause",100)
collectgarbage("setstepmul",100)



--[[ Create secondary "global" table for storing tables containing "global" functions, such as natives. ]]
local GlobalsWarnAndRedirect
do
	local _G2 = setmetatable
	(
		{_GlobalVariables={}},
		{
			__index = function(Self,Key)
				for k,v in pairs(Self) do
					local ReturnValue = type(v)=='table' and v[Key]
					if ReturnValue then return ReturnValue end
				end
			end
		}
	)
	_G._G2 = _G2
	setmetatable
	(
		_G,
		{
			__index = function(Self,Key)
				return _G2[Key]
			end,
			__newindex = function(Self,Key,Value)
				local DebugData = debug.getinfo(2,'lS')
				if DebugData and GlobalsWarnAndRedirect and not (DebugData.what == 'main' or DebugData.short_src == 'scripts/main.lua') then
					print(('[Warning - Script]	%s:%s\n	Variable "%s" (%s) declared global (use local).'):format(DebugData.short_src, DebugData.currentline, Key, type(Value)))
					_G2._GlobalVariables[Key] = Value
				else
					rawset(Self,Key,Value)
				end
			end
		}
	)
end



--[[ Add string functions ]]
do
	local FuncStrMeta = getmetatable("")
	local FuncStr = FuncStrMeta.__index
	
	FuncStrMeta.__index = function(Self,Key)
		if type(Key) ~= 'number' then
			return FuncStr[Key]
		end
		local Value = Self:sub(Key,Key)
		return Value ~= "" and Value or nil
	end
	
	FuncStrMeta.__add = function(strA,strB)
		return strA..strB
	end
	FuncStrMeta.__sub = function(strA,strB)
		return strA:gsub(strB,"")
	end
	FuncStrMeta.__mul = function(str,num)
		return str:rep(num)
	end
	
	FuncStr.split = function(str,sep) -- Split strings into chunks or arguments (in tables)
		sep = sep or "%s"
		local t,n={},0
		for str in str:gmatch("([^"..sep.."]+)") do
			n=n+1 t[n]=str
		end
		return t
	end
	
	FuncStr.upperFirst = function(str) -- Make the first letter of a string uppercase
		return str:sub(1,1):upper()..str:sub(2)
	end
	
	FuncStr.startsWith = function(str, startsWith) -- Check if a string starts with something
		return str:sub(1, #startsWith) == startsWith
	end
	FuncStr.endsWith = function(str, endsWith) -- Check if a string ends with something
		return str:sub(-#endsWith) == endsWith
	end
	
	FuncStr.escape = function(str)
		return str:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]","%%%1")
	end
end



--[[ Add useful core/framework functions ]]
local unrequire
do
	local package_loaded = package.loaded
	function unrequire(script) -- Very useful for script resets/reloads/cleanup
		package_loaded[script]=nil
	end
end
_G.unrequire = unrequire



-- Set up framework
--[[ Fix Scripts_Path string variable if missing the trailing "//" on the end ]]
if not Scripts_Path:endsWith("//") then
	Scripts_Path = Scripts_Path.."//"
	_G.Scripts_Path = Scripts_Path
end

--[[ Define other additional Script Paths ]]
local Script_Modules = Scripts_Path.."Modules//" _G.Script_Modules = Script_Modules -- Modular Script Components/Parts
local __Script_Modules = Scripts_Path.."__Modules//" _G.__Script_Modules = __Script_Modules -- Shared Script Components/Resources
local Script_Libs = Scripts_Path.."libs//" _G.Script_Libs = Script_Libs -- Standard libs Directory For Environment
local __Script_Libs = Scripts_Path.."__libs//" _G.__Script_Libs = __Script_Libs -- Automatically Loaded libs On Startup
local __Internal_Path = Scripts_Path.."__Internal//" _G.__Internal_Path = __Internal_Path

--[[ Update the search path ]]
do
	local package_path = package.path
	local DirectoriesList = {"Scripts_Path","Script_Modules","__Script_Modules","Script_Libs","__Script_Libs"}
	local FiletypesList = {".dll",".luac","",".lua"}
	
	for i=1,5 do
		local Directory = _G[DirectoriesList[i]]
		for j=1,4 do
			local Filetype = FiletypesList[j]
			package_path = (".\\?%s;%s?%s;%slibs\\?%s;%slibs\\?\\init%s;%s"):format(Filetype,Directory,Filetype,Directory,Filetype,Directory,Filetype,package_path)
			--Type,Directory,Type,Directory,Type,Directory,Type,ConcatOnTo
		end
	end
	package.path = package_path
end

local Threads_HighPriority = {}
local Threads_New = {}
local Threads = {}

local Info = {Enabled=false,Time=0,Player=0}
_G.Info = Info

local JM36 =
{
	CreateThread_HighPriority = function(func)
			Threads_HighPriority[#Threads_HighPriority+1] = coroutine_create(func)
		end,
	CreateThread = function(func)
			Threads_New[#Threads_New+1] = coroutine_create(func)
		end,
	Wait=0,
	wait=0,
	yield=0,
	yield_once=coroutine_yield
}
do
	local Halt = function(ms)
		if not ms then
			coroutine_yield()
		else
			ms = Info.Time+ms
			repeat
				coroutine_yield()
			until Info.Time > ms
		end
	end
	JM36.Wait, JM36.wait, JM36.yield = Halt, Halt, Halt
	JM36.CreateThread_HighPriority(function() wait=JM36.wait;IsKeyPressed=get_key_pressed end)
end
_G.JM36 = JM36

local Scripts_Init, Scripts_Stop
do
	local loopToThread
	do
		local CreateThread = JM36.CreateThread
		local yield = JM36.yield
		loopToThread = function(func)
			CreateThread(function()
				while true do
					func(Info)
					yield()
				end
			end)
		end
	end
	Scripts_Init = setmetatable({},{
		__call	=	function(Self)
						if Info.Enabled then Scripts_Stop() end
						
						local Scripts_List, Scripts_NMBR = {}, 0
						for Script in lfs_dir(Script_Modules) do
							if Script:endsWith(".lua") then
								Scripts_NMBR = Scripts_NMBR+1
								Scripts_List[Scripts_NMBR] = Script:gsub(".lua","")
							elseif Script:endsWith(".luac") then
								Scripts_NMBR = Scripts_NMBR+1
								Scripts_List[Scripts_NMBR] = Script:gsub(".luac","")
							end
						end
						
						table_sort(Scripts_List)
						Scripts_List.Num = Scripts_NMBR
						Self.List = Scripts_List
						
						for i=1, Scripts_NMBR do
							local Successful, Script = pcall(require, Scripts_List[i])
							if Successful then
								if type(Script)=='table' then
									Self[#Self+1] = Script.init
									
									Scripts_Stop[#Scripts_Stop+1] = (Script.stop or Script.unload)
									
									local loop = (Script.loop or Script.tick)
									if loop then
										loopToThread(loop)
									end
								end
							else
								print(Script)
							end
						end
						
						JM36.CreateThread_HighPriority(function()
							for i=1, #Self do
								local Successful, Error = pcall(Self[i], Info) if not Successful then print(Error) end
							end
						end)
						
						Info.Enabled = true
					end
	})
end
do
	Scripts_Stop = setmetatable({},{
		__call  =   function(Self)
						Info.Enabled = false
						
						local Scripts_List = Scripts_Init.List
						for i=1, Scripts_List.Num do
							unrequire(Scripts_List[i])
						end
						
						for i=1, #Scripts_Init do
							Scripts_Init[i]=nil
						end
						
						for i=1, #Threads do
							Threads[i]=nil
						end
						for i=1, #Threads_New do
							Threads_New[i]=nil
						end
						
						for i=1, #Self do
							local Successful, Error = pcall(Self[i], Info) if not Successful then print(Error) end Self[i]=nil
						end
						
						collectgarbage()
					end
	})
end
_G.Scripts_Init, _G.Scripts_Stop = Scripts_Init, Scripts_Stop



--[[ Automatically load __Internal ]]
do
	local Functions = setmetatable({},{
		__call  =   function(Self)
						for i=1, #Self do
							Self[i](Info)
						end
					end
	})
	Info.Functions = Functions
	
	local package = package
	local package_path_orig = package.path
	
	package.path = ("%s?.lua;%s?.luac"):format(__Internal_Path,__Internal_Path)
	
	local List, ListNum = {}, 0
	for Lib in lfs_dir(__Internal_Path) do
		if Lib:endsWith(".lua") then
			ListNum = ListNum+1
			List[ListNum] = Lib:gsub(".lua","")
		elseif Lib:endsWith(".luac") then
			ListNum = ListNum+1
			List[ListNum] = Lib:gsub(".luac","")
		end
	end
	table_sort(List)
	local FunctionsNum = 0
	for i=1, ListNum do
		local Successful, Function = pcall(require, List[i])
		if Successful then
			local Type = type(Function)
			if Type == "table" then
				if not Function.InfoKeyOnly then
					FunctionsNum = FunctionsNum + 1
					Functions[FunctionsNum] = Function
				end
				local Key = Function.InfoKeyName
				if type(Key) == "string" then
					Info[Key] = Function
				end
			elseif Type == "function" then
				FunctionsNum = FunctionsNum + 1
				Functions[FunctionsNum] = Function
			end
		else
			print(Function)
		end
	end
	
	package.path = package_path_orig
end

--[[ Automatically load __libs ]]
do
	local __libs_List, __libs_NMBR = {}, 0
	for __lib in lfs_dir(__Script_Libs) do
		if __lib:endsWith(".lua") then
			__libs_NMBR = __libs_NMBR+1
			__libs_List[__libs_NMBR] = __lib:gsub(".lua","")
		elseif __lib:endsWith(".luac") then
			__libs_NMBR = __libs_NMBR+1
			__libs_List[__libs_NMBR] = __lib:gsub(".luac","")
		end
	end
	
	table_sort(__libs_List)
	
	for i=1, __libs_NMBR do
		local Successful, __lib = pcall(require, __libs_List[i])
		if not Successful then
			print(__lib)
		end
	end
end



--[[ Create init "handler" function for lp ]]
init = function()
	collectgarbage()
	GlobalsWarnAndRedirect = true
	Scripts_Init()
end



--[[ Create tick "handler" function for lp ]]
tick = coroutine_wrap(function()
	local GetTime = coroutine_wrap(function()
		local os_clock = os.clock
		while true do
			coroutine_yield(os_clock()*1000)
		end
	end)
	
	local Functions = Info.Functions
	
	while true do
		Info.Time = GetTime()
		if Info.Enabled then
			for i=1, #Functions do
				Functions[i](Info)
			end
			do
				local j = 1
				for i = 1, #Threads_HighPriority do
					local Thread = Threads_HighPriority[i]
					if Thread and coroutine_status(Thread)~="dead" then
						do
							local Successful, Error = coroutine_resume(Thread)
							if not Successful then print(Error) end
						end
						if i ~= j then
							Threads_HighPriority[j] = Threads_HighPriority[i]
							Threads_HighPriority[i] = nil
						end
						j = j + 1
					else
						Threads_HighPriority[i] = nil
					end
				end
			end
			local ThreadsNum = #Threads
			for i=1, #Threads_New do
				ThreadsNum = ThreadsNum + 1
				Threads[ThreadsNum] = Threads_New[i]
				Threads_New[i] = nil
			end
			local j = 1
			for i = 1, ThreadsNum do
				local Thread = Threads[i]
				if Thread and coroutine_status(Thread)~="dead" then
					do
						local Successful, Error = coroutine_resume(Thread)
						if not Successful then print(Error) end
					end
					if i ~= j then
						Threads[j] = Threads[i]
						Threads[i] = nil
					end
					j = j + 1
				else
					Threads[i] = nil
				end
			end
		end
		coroutine_yield()
	end
end)

--[[ Create unload "handler" function for lp ]]
unload = Scripts_Stop