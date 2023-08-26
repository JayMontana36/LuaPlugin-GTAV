local math_sqrt = math.sqrt
local function GetDistanceBetweenCoords(x1 --[[ number ]], y1 --[[ number ]], z1 --[[ number ]], x2 --[[ number ]], y2 --[[ number ]], z2 --[[ number ]], useZ --[[ boolean ]])
	local xDist, yDist = x1 - x2, y1 - y2
	if useZ == false then
		return math_sqrt((xDist^2)+(yDist^2))
	end
	local zDist = z1 - z2
	return math_sqrt((xDist^2)+(yDist^2)+(zDist^2))
end
_G.GetDistanceBetweenCoords = GetDistanceBetweenCoords
return GetDistanceBetweenCoords