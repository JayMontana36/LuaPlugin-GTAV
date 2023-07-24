local setmetatable = setmetatable
local metatable =
{
	__mode	=	"kv",
	__call	=	function(Self,Key)return Self[Key]end,
}
return function()return setmetatable({},metatable)end