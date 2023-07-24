local setmetatable = setmetatable
local __call = function(Self,Key)return Self[Key]end
local __cache = {}
local metatable =
{
	__mode	=	"kv",
	__index =	function(Self,Key)local Value=__cache[Self](Key);Self[Key]=Value;return Value;end,
	__call	=	__call,
}
return setmetatable
(
	{},
	{
		__mode="v",
		__index=function(Self,SrcFunc)local Value=setmetatable({},metatable);Self[SrcFunc]=Value;__cache[Value]=SrcFunc;return Value;end,
		__call=__call,
	}
)