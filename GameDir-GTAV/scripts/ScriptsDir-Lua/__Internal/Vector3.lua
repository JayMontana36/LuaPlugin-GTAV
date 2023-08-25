local type = type
--local assert = assert
local math_sqrt = math.sqrt
local math_abs = math.abs
local math_min = math.min
local math_max = math.max

local GetEntityCoords = GetEntityCoords



local v3_FuncsOrigin = {}
local v3_Meta = Vector3
local Trash = getmetatable(v3_Meta)
for Key, Value in pairs(v3_Meta) do
	if not Key:startsWith("__") then
		v3_FuncsOrigin[Key] = Value
	end
	Trash[Key] = nil
end
Trash = nil
setmetatable(v3_Meta,nil)
vector3, vec3, v3 = v3_Meta, v3_Meta, v3_Meta



local GetX, GetY, GetZ, SetX, SetY, SetZ;do
	local Get, Set = v3_FuncsOrigin[".get"], v3_FuncsOrigin[".set"]
	GetX, GetY, GetZ, SetX, SetY, SetZ = Get.x, Get.y, Get.z, Set.x, Set.y, Set.z
end



local v3_New = function(x,y,z)
	local NewVector3 = GetEntityCoords(0,false)
	local ParamTypeX = type(x)
	if ParamTypeX ~= 'nil' then
		if ParamTypeX == 'number' then
			SetX(NewVector3,x)
			if type(y) == 'number' then
				SetY(NewVector3,y)
			end
			if type(z) == 'number' then
				SetZ(NewVector3,z)
			end
		elseif ParamTypeX == 'userdata' then
			SetX(NewVector3,GetX(x))
			SetY(NewVector3,GetY(x))
			SetZ(NewVector3,GetZ(x))
		elseif ParamTypeX == 'table' then
			if type(x.x) == 'number' then
				SetX(NewVector3,x.x)
			end
			if type(x.y) == 'number' then
				SetY(NewVector3,x.y)
			end
			if type(x.z) == 'number' then
				SetZ(NewVector3,x.z)
			end
		end
	end
	return NewVector3
end
v3_Meta.__call, v3_Meta.new = v3_New, v3_New

v3_Meta.reset = function(Self)
	SetX(Self,0)
	SetY(Self,0)
	SetZ(Self,0)
end

local v3_Get = function(Self)
	return GetX(Self),GetY(Self),GetZ(Self)
end
v3_Meta.get = v3_Get
v3_Meta.getX = GetX
v3_Meta.getY = GetY
v3_Meta.getZ = GetZ

local v3_Set = function(Self,x,y,z)
	SetX(Self,x)
	SetY(Self,y)
	SetZ(Self,z)
	--[[if type(x) == 'number' then
		SetX(Self,x)
	end
	if type(y) == 'number' then
		SetY(Self,y)
	end
	if type(z) == 'number' then
		SetZ(Self,z)
	end]]
end
v3_Meta.set = v3_Set
v3_Meta.setX = function(Self,x)
	SetX(Self,x)
end
v3_Meta.setY = function(Self,y)
	SetY(Self,y)
end
v3_Meta.setZ = function(Self,z)
	SetZ(Self,z)
end

do
	local v3_Add = function(Self,Othr)
		local x1,y1,z1 = v3_Get(Self)
		local x2,y2,z2 = v3_Get(Othr)
		v3_Set(Self, x1+x2, y1+y2, z1+z2)
		return Self
	end
	v3_Meta.__add, v3_Meta.add = v3_Add, v3_Add
end
local v3_Sub = function(Self,Othr)
	local x1,y1,z1 = v3_Get(Self)
	local x2,y2,z2 = v3_Get(Othr)
	v3_Set(Self, x1-x2, y1-y2, z1-z2)
	return Self
end
v3_Meta.__sub, v3_Meta.sub = v3_Sub, v3_Sub
do
	local v3_Mul = function(Self,Nmbr)
		local x,y,z = v3_Get(Self)
		v3_Set(Self, x*Nmbr,y*Nmbr,z*Nmbr)
		return Self
	end
	v3_Meta.__mul, v3_Meta.mul = v3_Mul, v3_Mul
end
do
	local v3_Div = function(Self,Nmbr)
		local x,y,z = v3_Get(Self)
		v3_Set(Self, x/Nmbr,y/Nmbr,z/Nmbr)
		return Self
	end
	v3_Meta.__div, v3_Meta.div = v3_Div, v3_Div
end

do
	local v3_Equal = function(Self,Othr)
		return (GetX(Self) == GetX(Othr) and GetY(Self) == GetY(Othr) and GetZ(Self) == GetZ(Othr))
	end
	v3_Meta.__eq, v3_Meta.eq = v3_Equal, v3_Equal
end

local v3_Magnitude = function(Self)
	return math_sqrt((GetX(Self)^2) + (GetY(Self)^2) + (GetZ(Self)^2))
end
v3_Meta.__len, v3_Meta.magnitude = v3_Magnitude, v3_Magnitude

do
	local v3_Dist = function(Self,Othr,Do3d) -- Add assert for type check (ensure userdata) maybe?
		if Do3d == false then
			return math_sqrt(((GetX(Self)-GetX(Othr))^2)+((GetY(Self)-GetY(Othr))^2))
		end
		return v3_Magnitude(v3_Sub(Self,Othr)) -- #(Self-Othr) 
	end
	v3_Meta.distance, v3_Meta.dist = v3_Dist, v3_Dist
end

v3_Meta.abs = function(Self)
	local x,y,z = v3_Get(Self)
	x,y,z = math_abs(x),math_abs(y),math_abs(z)
	v3_Set(Self, x, y, z)
	return Self
end

-- v3_Meta.sum

v3_Meta.min = function(Self)
	return math_min(v3_Get(Self))
end

v3_Meta.max = function(Self)
	return math_max(v3_Get(Self))
end

-- v3_Meta.dot

do
	local v3_Norm = function(Self)
		local x,y,z = v3_Get(Self)
		local Magnitude = math_sqrt((x^2) + (y^2) + (z^2))
		v3_Set(Self, x/Magnitude, y/Magnitude, z/Magnitude)
		return Self
	end
	v3_Meta.norm, v3_Meta.normalize, v3_Meta.normalise = v3_Norm, v3_Norm, v3_Norm
end

-- v3_Meta.crossProduct
-- v3_Meta.toRot
-- v3_Meta.lookAt
-- v3_Meta.toDir

do
	local v3_ToStr = function(Self)
		return ("vector3(%g, %g, %g)"):format(v3_Get(Self))
	end
	v3_Meta.__tostring, v3_Meta.toString = v3_ToStr, v3_ToStr
end

v3_Meta.dump = function(Self)
	local RetVal = {x=0.0,y=0.0,z=0.0}
	RetVal.x,RetVal.y,RetVal.z = v3_Get(Self)
	return RetVal
end

-- Experimental And Undefined Functions/Methods (undefined behavior, can/will change whenever) Below
-- __newindex __index __concat __unm __pow __mod __le __lt

v3_Meta.__unm = function(Self)
	local x,y,z = v3_Get(Self)
	v3_Set(Self, -x, -y, -z)
	return Self
end

v3_Meta.__le = function(Self,Othr)
	return v3_Magnitude(Self) <= v3_Magnitude(Othr)
end
v3_Meta.__lt = function(Self,Othr)
	return v3_Magnitude(Self) < v3_Magnitude(Othr)
end

v3_Meta.__metatable = true