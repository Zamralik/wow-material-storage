local _, internal = ...

SLASH_MATERIALSTORAGE1 = "/materialstorage"
SLASH_MATERIALSTORAGE2 = "/ms"

SlashCmdList["MATERIALSTORAGE"] = function()
	MaterialStorage:ToggleWindow()
end

SLASH_MATERIALSTORAGE_REFRESH1 = "/msr"

SlashCmdList["MATERIALSTORAGE_REFRESH"] = function(msg)
	MaterialStorage:RefreshWindow()

	if msg == "" then
		return
	end

	local quantity = tonumber(msg)

	for i, button in ipairs(internal.itemSlots) do
		internal.updateItemButton(button, quantity)
	end
end
