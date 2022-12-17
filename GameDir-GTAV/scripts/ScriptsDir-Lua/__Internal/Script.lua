local type = type

local Script_Persist = {} -- never gc these
Script = setmetatable
(
	{},
	{
		__mode  =   "v",
		--[[__index =   function(Self, Key)
						local Value = {}
						Self[Key] = Value
						return Value
					end,]]
		__index =   Script_Persist,
		__call	=	function(Self, Key, Persist)
						local Value, JustCreated
						if Key then
							Value = Self[Key]
							if not Value then
								JustCreated = true
								Value = {}
								Self[Key] = Value
							end
						else
							-- generate Key from debug info for the calling module
						end
						if not JustCreated then
							local _Persist = Script_Persist[Key]
							if _Persist and type(_Persist) == "boolean" then
								Script_Persist[Key] = Value
							end
						else
							Script_Persist[Key] = Persist and type(Persist) == "boolean" 
						end
						return Value
					end,
	}
)