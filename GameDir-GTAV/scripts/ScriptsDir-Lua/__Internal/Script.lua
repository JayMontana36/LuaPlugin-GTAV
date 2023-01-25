local type = type
local pairs = pairs

local Script_Persist_Reloads = {} -- never gc these
--local Script_Persist = setmetatable({},{__index=function(Self,Key)return Script_Persist_Reloads[Key] or Script_Persist_Restarts[Key] or nil end})

local Script_Properties_Handler =
{
	PersistReloads	=	function(Table, Key, State)
							Script_Persist_Reloads[Key] = State and Table or nil;return Table
						end
}

Script = setmetatable
(
	{},
	{
		__mode  =   "v",
		__index =   Script_Persist_Reloads,
		__call	=	function(Self, Key, Properties)
						local Value
						if Key then
							Value = Self[Key] or {}
							if Properties and type(Properties) == 'table' then
								for _Key, _Value in pairs(Properties) do
									_Key = _Value and Script_Properties_Handler[_Key]
									if _Key then
										Value = _Key(Value, Key, _Value)
									end
								end
							end
							Self[Key] = Value
						else
							-- generate Key from debug info for the calling module
						end
						return Value
					end,
	}
)
