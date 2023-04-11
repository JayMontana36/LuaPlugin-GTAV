local setmetatable = setmetatable
local __call = function(Self,Key)return Self[Key]end
local metatable =
{
	__mode	=	"kv",
	__index =	function(Self,Key)local Value=Self.__SrcFunc(Key)Self[Key]=Value;return Value;end,
	__call	=	__call,
}
return setmetatable
(
	{},
	{
		__mode="v",
		__index=function(Self,SrcFunc)local Value=setmetatable({__SrcFunc=SrcFunc},metatable)Self[SrcFunc]=Value;return Value;end,
		__call,
	}
)