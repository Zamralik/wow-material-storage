local _, internal = ...

SLASH_MATERIALSTORAGE1 = "/materialstorage"
SLASH_MATERIALSTORAGE2 = "/ms"

SlashCmdList["MATERIALSTORAGE"] = function()
	MaterialStorage:ToggleWindow()
end

SLASH_MATERIALSTORAGE_REFRESH1 = "/msr"

SlashCmdList["MATERIALSTORAGE_REFRESH"] = function()
	MaterialStorage:RefreshWindow()

	if msg == "" then
		return
	end

	local quantity = tonumber(msg)

	for i, button in ipairs(internal.itemSlots) do
		internal.updateItemButton(button, quantity)
	end
end

SLASH_MATERIALSTORAGE_DEPOSIT1 = "/msd"

SlashCmdList["MATERIALSTORAGE_DEPOSIT"] = function(msg)
	if msg == "" then
		return
	end

	local parsed_message = string.gmatch(msg, "%d+")

	local bag_id = tonumber(parsed_message() or "0")
	local slot_id = tonumber(parsed_message() or "0")

	print("Depositing item from bag", bag_id, "slot", slot_id)

	internal.deposit(bag_id, slot_id)
end

SLASH_MATERIALSTORAGE_DEPOSIT_ALL1 = "/msda"

SlashCmdList["MATERIALSTORAGE_DEPOSIT_ALL"] = function(msg)
	internal.depositAll()
end
