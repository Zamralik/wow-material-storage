local _, internal = ...

internal.initialized = false

local function getItemInfo(item_id)
	local item_info = { GetItemInfo(item_id) }

	if not item_info[1] then
		-- print("Missing data for item with id:", item_id)
		return nil
	end

	local item_name = item_info[1]
	local item_link = item_info[2]
	-- local item_rarity = item_info[3]
	local item_icon_texture = item_info[10]

	local quantity = internal.getItemQuantity()

	return {
		name = item_name,
		link = item_link,
		icon = item_icon_texture,
		quantity = quantity,
	}
end

local function makeFrameMovable(frame)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag(true)
	frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
	frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
end

local function makeFrameCloseOnEscape(frame)
	tinsert(UISpecialFrames, frame:GetName())
end

local function updateItemButton(button, quantity)
	SetItemButtonCount(button, quantity)

	if quantity == 0
	then
		button:SetAlpha(0.3)
	else
		button:SetAlpha(1)
	end
end
internal.updateItemButton = updateItemButton

local function initializeItemButton(button, item_info)
	SetItemButtonTexture(button, item_info.icon)
	updateItemButton(button, item_info.quantity)

	button:SetScript("OnClick", function(self, button, down)
		if button == "LeftButton" then
			print("Item:", item_info.name or button:GetID())
		end
	end)

	button:HookScript("OnEnter", function()
		GameTooltip:SetOwner(button, "ANCHOR_TOP")
		GameTooltip:SetHyperlink(item_info.link)
		GameTooltip:Show()
	end)

	button:HookScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end


-- Function to update the material list display
local function generateItemSlots()
	local content = internal.content

	local item_slots = {}
	internal.itemSlots = item_slots

	local data = internal.data
	internal.data = nil

	content:SetSize(
		3 + internal.MAX_COLUMN * internal.ITEM_SLOT_WIDTH,
		math.ceil(#data.items / internal.MAX_COLUMN) * internal.ITEM_SLOT_WIDTH + 3
	)

	local pending_buttons = {}

	local row_index = 0
	local column_index = 0

	for i, item in ipairs(data.items) do
		row_index = math.floor((i - 1) / internal.MAX_COLUMN)
		column_index = (i - 1 - row_index * internal.MAX_COLUMN)

		local button = CreateFrame("Button", "MaterialStorage_ItemSlot" .. item.id, content, "ItemButtonTemplate")
		tinsert(item_slots, button)

		local offset_x = column_index * internal.ITEM_SLOT_WIDTH + internal.ITEM_SLOT_OFFSET_X
		local offset_y = internal.ITEM_SLOT_OFFSET_Y - row_index * internal.ITEM_SLOT_WIDTH

		button:SetPoint("TOPLEFT", content, "TOPLEFT", offset_x, offset_y)
		button:SetID(item.id)
		button.isBag = true
		SetItemButtonTexture(button, "Interface\PaperDoll\UI-Backpack-EmptySlot.blp")

		item_info = getItemInfo(item.id)

		if item_info then
			initializeItemButton(button, item_info)
		else
			tinsert(pending_buttons, button)
		end
	end

	if not next(pending_buttons) then
		return
	end

	local loading_frame = CreateFrame("Frame", nil, UIParent)

	local last_index = #pending_buttons

	local retry = 0

	local max_throttle = 10
	local throttle = max_throttle

	loading_frame:SetScript("OnUpdate", function()
		if last_index < 1 then
			loading_frame:Hide()
			loading_frame:SetScript("OnUpdate", nil)
			loading_frame:SetParent(nil)
			return
		end

		if throttle < max_throttle then
			throttle = throttle + 1
			return
		end

		throttle = 0

		local last_button = pending_buttons[last_index]

		if retry > 10 then
			print("Failed to load item data for item id:", last_button:GetID())
			last_index = 0
			return
		end

		print("Loading item data for item id:", last_button:GetID())
		local item_info = getItemInfo(last_button:GetID())

		if not item_info then
			retry = retry + 1

			if retry > 1 then
				return
			end

			GameTooltip:SetOwner(UIParent)
			GameTooltip:SetHyperlink("item:" .. last_button:GetID())

			return
		end

		retry = 0
		last_index = last_index - 1
		initializeItemButton(last_button, item_info)
	end)
end

local function initialize()
	if internal.initialized then return end

	internal.initialized = true

	local window = CreateFrame("Frame", "MaterialStorage_Panel", UIParent, "UIPanelDialogTemplate")
	internal.window = window
	window:SetSize(530, 400)
	window:SetPoint("CENTER")
	window.title:SetText("Material Storage")

	makeFrameMovable(window)
	makeFrameCloseOnEscape(window)

	local scroll_frame = CreateFrame("ScrollFrame", "MaterialStorage_ScrollFrame", window, "UIPanelScrollFrameTemplate")
	internal.scrollFrame = scroll_frame

	scroll_frame:SetPoint("TOPLEFT", MaterialStorage_PanelDialogBG, "TOPLEFT", 3, -7)
	scroll_frame:SetPoint("BOTTOMRIGHT", MaterialStorage_PanelDialogBG, "BOTTOMRIGHT", -23, 2)

	local content = CreateFrame("Frame", nil, scroll_frame)
	internal.content = content

	generateItemSlots()

	scroll_frame:SetScrollChild(content)
	scroll_frame:EnableMouse(true)
end

internal.initialize = initialize
