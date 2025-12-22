local _, internal = ...

local function getItemQuantity()
	local quantity = math.random(1, 1000)

	-- Simulate lack of stock
	if (quantity > 500) then
		return 0
	end

	return quantity
end
internal.getItemQuantity = getItemQuantity
