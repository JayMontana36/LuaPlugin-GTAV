local setmetatable = setmetatable
local metatable =
{
	__mode	=	"kv",
	__index =	function(Self,Key)local Value=Self.__SrcFunc(Key)Self[Key]=Value;return Value;end,
	__call	=	function(Self,Key)return Self[Key]end,
}
return function(SrcFunc)return setmetatable({__SrcFunc=SrcFunc},metatable)end