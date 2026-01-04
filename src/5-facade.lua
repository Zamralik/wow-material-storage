local _, internal = ...

local function isWindowVisible()
	return internal.initialized and internal.window:IsShown()
end

MaterialStorage = {}

function MaterialStorage:RefreshWindow()
	if not isWindowVisible() then
		return
	end

	print("Refreshing Material Storage window")

	for i, button in ipairs(internal.itemSlots) do
		internal.updateItemButton(button, internal.getItemQuantity(button:GetID()))
	end
end

function MaterialStorage:ShowWindow()
	if not internal.initialized then
		internal.initialize()
	end

	internal.window:Show()
	PlaySound("GuildVaultOpen")
end

function MaterialStorage:HideWindow()
	if isWindowVisible() then
		return
	end

	internal.window:Hide()
end

function MaterialStorage:ToggleWindow()
	if isWindowVisible() then
		MaterialStorage:HideWindow()
		return
	end

	MaterialStorage:ShowWindow()
end

function MaterialStorage:DepositAll()
	internal.depositAll()
end

function MaterialStorage:Withdraw(item_template_id, quantity)
	print("Withdraw is not implemented yet")
end
