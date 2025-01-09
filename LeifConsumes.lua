local LeifConsumes, Addon = ...
Addon = Addon or {}

-- Create a frame to handle the ADDON_LOADED event
local addonLoadedFrame = CreateFrame("Frame")
addonLoadedFrame:RegisterEvent("ADDON_LOADED")
addonLoadedFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "LeifConsumes" then
        -- Global declaration of LeifConsumesDB
        LeifConsumesDB = LeifConsumesDB or {
            elixirs = {},
            flask = {},
            food = {},
            lowDurationWarning = false,
            mainHandEnchants = {},
            offHandEnchants = {},
            other = {},
            isVerticalMode = false,
            isRaidOnly = false,
            textPlacement = "Above",
            isHideIgnore = false,
            scale = 1
        }

Addon.LeifConsumesDB = LeifConsumesDB


Addon.weaponEnchantIdToName  = {
    -- Low Level Testing
    [13] = "Coarse Sharpening Stone",
    [22] = "Crippling Poison",
    [35] = "Mind-numbing Poison",
    [324] = "Instant Poison II",
    [8113] = "Scroll of Spirit II",

    -- Oils
    [2628] = "Brilliant Wizard Oil",
    [2629] = "Brilliant Mana Oil",
    [7650] = "Enchanted Repellent",

    -- Weapon Stones
    [1643] = "Dense Sharpening Stone",
    [2506] = "Elemental Sharpening Stone",

    -- Poisons
    [603] = "Crippling Poison II",
    [625] = "Instant Poison VI",
    [643] = "Mind-numbing Poison III",
    [706] = "Wound Poison IV",
    [2630] = "Deadly Poison V",

    -- Poisons SoD
    [7542] = "Occult Poison I",
    [7254] = "Sebacious Poison",
    [7255] = "Numbing Poison",
    [7256] = "Atrophic Poison",

}

Addon.foodAndSpecialConsumables = {
    -- Specials
    ["Supercharged Chronoboon Displacer"] = 349981,

    -- Food
    ["Dragonbreath Chili"] = 15851, -- Dragon Breaths
    ["Grilled Squid"] = 18192,  -- Agility
    ["Nightfin Soup"] = 18194, -- Mp5
    ["Runn Tum Tuber Surprise"] = 22730, -- Intellect
    ["Smoked Desert Dumplings"] = 24799, -- Strength
    ["Darkclaw Bisque"] = 470361,
    ["Smoked Redgill"] = 470367,

        -- Testing
    ["Dry Pork Ribs"] = 19706,
    ["Jungle Stew"] = 19709,
    ["Hot Lion Chops"] = 19708,
}

Addon.editBoxes = {} 
Addon.horizontalButtons = {}
Addon.verticalButtons = {}
Addon.areLeifEditBoxesVisible = false

-- Size settings
Addon.scale = LeifConsumesDB.scale
Addon.BUTTON_SIZE = 32 * Addon.scale
MAIN_FRAME_WIDTH = 200 * Addon.scale
MAIN_FRAME_HEIGHT = 20 * Addon.scale
DRAGHANDLE_WIDTH = 80 * Addon.scale

BUMPER_5 = 5 * Addon.scale
BUMPER_10 = 10 * Addon.scale
BUMPER_15 = 15 * Addon.scale
BUMPER_20 = 20 * Addon.scale

Addon.numCategories = 1
for categoryName, categoryValue in pairs(Addon.LeifConsumesDB) do
  if type(categoryValue) == "table" then
    Addon.numCategories = Addon.numCategories + 1  -- Add the number of elements in the table
  end
end

Addon.mainFrame = CreateFrame("Frame", nil, UIParent) 
Addon.mainFrame:SetPoint("CENTER", UIParent, "CENTER", MAIN_FRAME_WIDTH, MAIN_FRAME_WIDTH)
Addon.mainFrame:SetSize(MAIN_FRAME_WIDTH, 20)
Addon.mainFrame:SetMovable(true)
Addon.mainFrame:SetScript("OnDragStart", nil)
Addon.mainFrame:SetScript("OnDragStop", nil)

Addon.mainFrameBackground = Addon.mainFrame:CreateTexture(nil, "BACKGROUND")
Addon.mainFrameBackground:SetAllPoints()
Addon.mainFrameBackground:SetColorTexture(0, 0, 0, 0)

local function SaveWrapperPosition()
    local centerX, centerY = Addon.mainFrame:GetCenter()

    Addon.LeifConsumesDB.mainFrameX = centerX
    Addon.LeifConsumesDB.mainFrameY = centerY    
end

Addon.dragHandle = CreateFrame("Frame", nil, Addon.mainFrame)
Addon.dragHandle:SetPoint("CENTER", Addon.mainFrame, "CENTER")
Addon.dragHandle:SetSize(DRAGHANDLE_WIDTH, MAIN_FRAME_HEIGHT)
Addon.dragHandle:EnableMouse(true)
Addon.dragHandle:RegisterForDrag("LeftButton")

-- Add OnDragStart and OnDragStop scripts to rowOne
Addon.dragHandle:SetScript("OnDragStart", function(self)
    self:StartMoving()
    Addon.mainFrame:ClearAllPoints()
    Addon.mainFrame:SetPoint("CENTER", self, "CENTER")
end)

Addon.dragHandle:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
        C_Timer.After(0.1, SaveWrapperPosition)
    end)
Addon.dragHandle:Hide()

Addon.dragHandleBg = Addon.dragHandle:CreateTexture(nil, "BACKGROUND")
Addon.dragHandleBg:SetAllPoints()
Addon.dragHandleBg:SetColorTexture(0, 0, 0, 0.8)

    
Addon.buttonGroupHorizontal = CreateFrame("Frame", nil, Addon.mainFrame)
Addon.buttonGroupHorizontal:SetPoint("CENTER", Addon.dragHandle, "CENTER" ,0 , - Addon.BUTTON_SIZE / 2 - BUMPER_10)
Addon.buttonGroupHorizontal:SetSize(Addon.numCategories * Addon.BUTTON_SIZE, Addon.BUTTON_SIZE)
Addon.buttonGroupHorizontal:SetMovable(true)
Addon.buttonGroupHorizontal:EnableMouse(false)

Addon.buttonGroupHorizontalBg = Addon.buttonGroupHorizontal:CreateTexture(nil, "BACKGROUND")
Addon.buttonGroupHorizontalBg:SetAllPoints(Addon.buttonGroupHorizontal)
Addon.buttonGroupHorizontalBg:SetColorTexture(0, 0, 0, 0)

local point, relativeTo, relativePoint, xOfs, yOfs = Addon.buttonGroupHorizontal:GetPoint()

Addon.buttonGroupVertical = CreateFrame("Frame", nil, Addon.mainFrame)
Addon.buttonGroupVertical:SetPoint("CENTER", Addon.dragHandle, "CENTER",0, - Addon.BUTTON_SIZE * Addon.numCategories/2 - BUMPER_10)
Addon.buttonGroupVertical:SetSize(Addon.BUTTON_SIZE, Addon.numCategories * Addon.BUTTON_SIZE)
Addon.buttonGroupVertical:SetMovable(true)
Addon.buttonGroupVertical:EnableMouse(false)

Addon.buttonGroupVerticalBg = Addon.buttonGroupVertical:CreateTexture(nil, "BACKGROUND")
Addon.buttonGroupVerticalBg:SetAllPoints(Addon.buttonGroupVertical)
Addon.buttonGroupVerticalBg:SetColorTexture(0, 0, 0, 0)


local function FormatRemainingTime(remainingDuration)
    if not remainingDuration or type(remainingDuration) ~= "number" then
        return ""
    end

    local minutes = math.floor(remainingDuration / 60)
    local seconds = math.floor(remainingDuration % 60)

    if minutes >= 5 then  -- Check if it's more than 5 minutes
        return string.format("%d m", minutes)  -- Only display full minutes
    elseif minutes > 0 and seconds > 0 then
        return string.format("%d m\n%d s", minutes, seconds)
    elseif minutes > 0 then
        return string.format("%d m", minutes)
    elseif seconds > 0 then
        return string.format("%d s", seconds)
    else
        return ""
    end
end


local function isConsumableActive(itemName, category, horizontalButton, verticalButton)
    local weaponEnchantIdToName = Addon.weaponEnchantIdToName
    local foodAndSpecialConsumables = Addon.foodAndSpecialConsumables
    local playerHasBuff = false
    local currentButtonAlpha = 1  -- Default alpha value
    local remainingDuration = nil
    local totalDuration = nil

    if itemName then
        local spellName, spellId = GetItemSpell(itemName)

        if foodAndSpecialConsumables[itemName] then
            spellId = foodAndSpecialConsumables[itemName]
        end

        if spellId then
            totalDuration = nil  -- Reset totalDuration before the loop
            for i = 1, 40 do
                local _, _, _, _, duration, expirationTime, _, _, _, auraSpellId = UnitAura("player", i)
                
                if auraSpellId and (auraSpellId == spellId or (itemName == "Winterfall Firewater" and auraSpellId == 473469)) then
                    totalDuration = duration
                    remainingDuration = expirationTime - GetTime()
                    -- print("totalDuration in loop", itemName, totalDuration)
                    playerHasBuff = true

                    if Addon.LeifConsumesDB.lowDurationWarning and itemName ~= "Supercharged Chronoboon Displacer" then

                        if remainingDuration <= totalDuration * 0.2 then
                            currentButtonAlpha = 0.5
                        elseif remainingDuration >= 1 then
                            currentButtonAlpha = 0.7  
                        else
                            currentButtonAlpha = 1 
                        end
                    end
                end
            end
        end
        local hasMainHandEnchant, mainHandExpiration, _, mainHandEnchantID, hasOffHandEnchant, offHandExpiration, _, offHandEnchantID = GetWeaponEnchantInfo()

        -- print("totalDuration between loops", itemName, totalDuration)

        if (category == "mainHandEnchants" and hasMainHandEnchant and weaponEnchantIdToName[mainHandEnchantID] == itemName) or 
           (category == "offHandEnchants" and hasOffHandEnchant and weaponEnchantIdToName[offHandEnchantID] == itemName) then
            playerHasBuff = true

            totalDuration = (30 * 60) -- Most Weapon Enchants are 30 minutes

            if category == "mainHandEnchants" then
                remainingDuration = (category == "mainHandEnchants" and mainHandExpiration) / 1000
            elseif category == "offHandEnchants" then
                remainingDuration = (category == "offHandEnchants" and offHandExpiration) / 1000
            end

            if Addon.LeifConsumesDB.lowDurationWarning and itemName ~= "Supercharged Chronoboon Displacer" then
                if remainingDuration >= (1 * 60) then
                    currentButtonAlpha = 0.5 
                elseif remainingDuration >= 1 then
                    currentButtonAlpha = 0.7 
                else
                    currentButtonAlpha = 1
                end
            end
        end
    end
    -- Debug prints before returning
    -- print("itemName:", itemName, "totalDuration:", totalDuration, "remainingDuration:", remainingDuration)

    return playerHasBuff, currentButtonAlpha, remainingDuration, totalDuration
end


local function updateButtonVisibility(horizontalButton, verticalButton)
    local itemName = horizontalButton.itemName
    local category = horizontalButton.category
    local foodAndSpecialConsumables = Addon.foodAndSpecialConsumables
    local isHideIgnore = Addon.LeifConsumesDB.isHideIgnore
    local lowDurationWarning = Addon.LeifConsumesDB.lowDurationWarning
    local currentDurationStatus = nil

    local isActive, currentButtonAlpha, remainingDuration, totalDuration = isConsumableActive(itemName, category, horizontalButton, verticalButton)

    if totalDuration and remainingDuration then
        currentDurationStatus = remainingDuration / totalDuration
    end

    if foodAndSpecialConsumables[itemName] == 349981 then  -- Special case: Supercharged Chronoboon Displacer
        horizontalButton:SetAlpha(currentButtonAlpha)
        verticalButton:SetAlpha(currentButtonAlpha)
        if isActive then
            horizontalButton:Show()
            verticalButton:Show()
        else
            horizontalButton:Hide()
            verticalButton:Hide()
        end
        return remainingDuration  -- Exit early for this special case
    end

    local _, _, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemName)
    if itemTexture then
        horizontalButton:SetNormalTexture(itemTexture)
        verticalButton:SetNormalTexture(itemTexture)
    else
        -- print("Icon not found for:", itemName, "It needs to be in your bags. For now...")
    end

    if isHideIgnore then
        horizontalButton:Show()
        verticalButton:Show()
        if currentDurationStatus ~= nil then
            if lowDurationWarning and currentDurationStatus <= 0.2 then
                horizontalButton:SetAlpha(0.5)  -- Faded if low duration warning is on
                verticalButton:SetAlpha(0.5)
            else
                horizontalButton:SetAlpha(currentButtonAlpha)
                verticalButton:SetAlpha(currentButtonAlpha)
            end
        end
    elseif lowDurationWarning and currentDurationStatus ~= nil then
        if currentDurationStatus <= 0.2 then
            horizontalButton:Show()
            verticalButton:Show()
            horizontalButton:SetAlpha(0.5)  -- Faded
            verticalButton:SetAlpha(0.5)
        else
            horizontalButton:Hide()
            verticalButton:Hide()
        end
    else
        if isActive then
            horizontalButton:Hide()  -- Only show if not active
            verticalButton:Hide()
        else
            horizontalButton:Show()
            verticalButton:Show()
            horizontalButton:SetAlpha(currentButtonAlpha)
            verticalButton:SetAlpha(currentButtonAlpha)
        end
    end

    horizontalButton:SetAlpha(currentButtonAlpha)
    verticalButton:SetAlpha(currentButtonAlpha)
    if not isActive then
        local isInRaid = IsInRaid()
        if Addon.LeifConsumesDB.isRaidOnly and not isInRaid and not Addon.areLeifEditBoxesVisible then
            horizontalButton:Hide()
            verticalButton:Hide()
        elseif Addon.LeifConsumesDB.isVerticalMode and not Addon.areLeifEditBoxesVisible then
            horizontalButton:Hide()
            verticalButton:Show()
        elseif not Addon.areLeifEditBoxesVisible then
            horizontalButton:Show()
            verticalButton:Hide()
        end
    end
    return remainingDuration
end

function updateButton(itemName, category, index)
    local vertical = Addon.LeifConsumesDB.isVerticalMode
    local raidOnly = Addon.LeifConsumesDB.isRaidOnly
    local buttonHorizontal, buttonVertical
    local textPlacement = Addon.LeifConsumesDB.textPlacement
    

    if Addon.horizontalButtons[index] and Addon.verticalButtons[index] then
        -- Buttons already exist, update their properties
        local buttonHorizontal = Addon.horizontalButtons[index].button
        local buttonVertical = Addon.verticalButtons[index].button

        -- Update itemName and category
        buttonHorizontal.itemName = itemName
        buttonHorizontal.category = category
        buttonVertical.itemName = itemName
        buttonVertical.category = category

        -- Update textures
        local _, _, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemName)
        if itemTexture then
            buttonHorizontal:SetNormalTexture(itemTexture)
            buttonVertical:SetNormalTexture(itemTexture)
        else
            print("Icon not found for:", itemName, ". It needs to be in your bags. For now...")
        end

        -- Update macro text
        local macroText = "/use " .. itemName
        if category == "mainHandEnchants" then
            macroText = macroText .. "\n/use 16"
        elseif category == "offHandEnchants" then
            macroText = macroText .. "\n/use 17"
        end
        buttonHorizontal:SetAttribute("type", "macro")
        buttonHorizontal:SetAttribute("macrotext", macroText)
        buttonVertical:SetAttribute("type", "macro")
        buttonVertical:SetAttribute("macrotext", macroText)
    else
        -- Create new buttons
        local buttonHorizontal = CreateFrame("Button", nil, Addon.buttonGroupHorizontal, "SecureActionButtonTemplate")
        buttonHorizontal:SetSize(Addon.BUTTON_SIZE, Addon.BUTTON_SIZE)

        local buttonVertical = CreateFrame("Button", nil, Addon.buttonGroupVertical, "SecureActionButtonTemplate")
        buttonVertical:SetSize(Addon.BUTTON_SIZE, Addon.BUTTON_SIZE)

        -- Set up buttonHorizontal properties  (These lines were missing)
        buttonHorizontal.itemName = itemName
        buttonHorizontal.category = category
        buttonHorizontal.index = index

        buttonVertical.itemName = itemName
        buttonVertical.category = category
        buttonVertical.index = index

        local _, _, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemName)
        if itemTexture then
            buttonHorizontal:SetNormalTexture(itemTexture)
            buttonVertical:SetNormalTexture(itemTexture)
        end

        local macroText = "/use " .. itemName
        if category == "mainHandEnchants" then
            macroText = macroText .. "\n/use 16"
        elseif category == "offHandEnchants" then
            macroText = macroText .. "\n/use 17"
        end

        buttonHorizontal:SetAttribute("type", "macro")
        buttonHorizontal:SetAttribute("macrotext", macroText)
        buttonVertical:SetAttribute("type", "macro")
        buttonVertical:SetAttribute("macrotext", macroText)

        buttonHorizontal:SetPoint("TOPLEFT", Addon.buttonGroupHorizontal, "TOPLEFT", Addon.BUTTON_SIZE * index, 0)
        buttonVertical:SetPoint("TOPLEFT", Addon.buttonGroupVertical, "TOPLEFT", 0, Addon.BUTTON_SIZE - Addon.BUTTON_SIZE * index)

        -- Create the font string for remaining time
        local buttonTextHorizontal = buttonHorizontal:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")  -- Create and assign the font string
        buttonHorizontal.timeText = buttonTextHorizontal  -- Assign the font string to the button

        local buttonTextVertical = buttonVertical:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")  -- Create and assign the font string
        buttonVertical.timeText = buttonTextVertical  -- Assign the font string to the button

        if itemName ~= "Supercharged Chronoboon Displacer" then  -- Skip for Chronoboon
            local _, _, remainingDuration = isConsumableActive(itemName, category)
            local formattedTime = FormatRemainingTime(remainingDuration)
            buttonTextHorizontal:SetText(formattedTime)
            buttonTextVertical:SetText(formattedTime)
        end 

        if textPlacement == "Above" then
            buttonTextHorizontal:SetPoint("CENTER", buttonHorizontal, "CENTER", 0, Addon.BUTTON_SIZE)
            buttonTextVertical:SetPoint("CENTER", buttonVertical, "CENTER", 0, Addon.BUTTON_SIZE)
        elseif textPlacement == "Below" then
            buttonTextHorizontal:SetPoint("CENTER", buttonHorizontal, "CENTER", 0, - Addon.BUTTON_SIZE)
            buttonTextVertical:SetPoint("CENTER", buttonVertical, "CENTER", 0, - Addon.BUTTON_SIZE)
        elseif textPlacement == "Left" then
            buttonTextHorizontal:SetPoint("CENTER", buttonHorizontal, "CENTER", - Addon.BUTTON_SIZE, 0)
            buttonTextVertical:SetPoint("CENTER", buttonVertical, "CENTER", - Addon.BUTTON_SIZE, 0)
        elseif textPlacement == "Right" then
            buttonTextHorizontal:SetPoint("CENTER", buttonHorizontal, "CENTER", Addon.BUTTON_SIZE, 0)
            buttonTextVertical:SetPoint("CENTER", buttonVertical, "CENTER", Addon.BUTTON_SIZE, 0)
        end
        
        -- Add the new buttons to the tables
        Addon.horizontalButtons[index] = { button = buttonHorizontal, itemName = itemName, category = category, index = index }
        Addon.verticalButtons[index] = { button = buttonVertical, itemName = itemName, category = category, index = index }
    end
end


function InitializeButtons()
    local index = 1
    local categoryOrder = { "elixirs", "flask", "food", "mainHandEnchants", "offHandEnchants", "other" }
    local textPlacement = Addon.LeifConsumesDB.textPlacement

    for _, category in ipairs(categoryOrder) do
        local items = Addon.LeifConsumesDB[category]
        if type(items) == "table" then
            for _, itemName in ipairs(items) do
                if itemName then
                    -- Create both buttons at once
                    local buttonHorizontal = CreateFrame("Button", nil, Addon.buttonGroupHorizontal, "SecureActionButtonTemplate")
                    local buttonVertical = CreateFrame("Button", nil, Addon.buttonGroupVertical, "SecureActionButtonTemplate")

                    -- Configure both buttons
                    for _, button in ipairs({buttonHorizontal, buttonVertical}) do
                        button:SetPoint("TOPLEFT", button == buttonHorizontal and Addon.buttonGroupHorizontal or Addon.buttonGroupVertical, "TOPLEFT", 
                                        button == buttonHorizontal and Addon.BUTTON_SIZE * index or 0, 
                                        button == buttonHorizontal and 0 or Addon.BUTTON_SIZE - Addon.BUTTON_SIZE * index)
                        button:SetSize(Addon.BUTTON_SIZE, Addon.BUTTON_SIZE)
                        button.itemName = itemName
                        button.category = category

                        -- Set up the macro
                        local macroText = "/use " .. itemName
                        if category == "mainHandEnchants" then
                            macroText = macroText .. "\n/use 16"
                        elseif category == "offHandEnchants" then
                            macroText = macroText .. "\n/use 17"
                        end
                        button:SetAttribute("type", "macro")
                        button:SetAttribute("macrotext", macroText)

                        -- Set the icon
                        local _, _, _, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(itemName)
                        if itemTexture then
                            button:SetNormalTexture(itemTexture)
                        end
                        
                        -- Create the font string for the button
                        local buttonText = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightMedium")
                        button.timeText = buttonText

                        -- Set the text placement
                        if textPlacement == "Above" then
                            buttonText:SetPoint("CENTER", button, "CENTER", 0, Addon.BUTTON_SIZE)
                        elseif textPlacement == "Below" then
                            buttonText:SetPoint("CENTER", button, "CENTER", 0, - Addon.BUTTON_SIZE)
                        elseif textPlacement == "Left" then
                            buttonText:SetPoint("CENTER", button, "CENTER", - Addon.BUTTON_SIZE, 0)
                        elseif textPlacement == "Right" then
                            buttonText:SetPoint("CENTER", button, "CENTER", Addon.BUTTON_SIZE, 0)
                        end

                        if itemName ~= "Supercharged Chronoboon Displacer" then  -- Skip for Chronoboon
                            local _, _, remainingDuration = isConsumableActive(itemName, category)
                            local formattedTime = FormatRemainingTime(remainingDuration)
                            buttonText:SetText(formattedTime)
                        end 
                    end

                    -- Store both buttons in their respective arrays
                    table.insert(Addon.horizontalButtons, { button = buttonHorizontal, itemName = itemName, category = category, index = index }) 
                    table.insert(Addon.verticalButtons, { button = buttonVertical, itemName = itemName, category = category, index = index })

                    index = index + 1
                end
            end
        end
    end
end

-- Intialize the first button creation
C_Timer.After(1, InitializeButtons)

SLASH_LEIF1 = "/leif"
SlashCmdList["LEIF"] = function(msg)
    local dragHandle = Addon.dragHandle
    local dragHandleBg = Addon.dragHandleBg
    Addon.areLeifEditBoxesVisible = true

    -- Show background for drag bar
    dragHandleBg:Show()
    dragHandle:Show()
    dragHandle:SetMovable(true)

    -- Create the drag text
    local dragText = dragHandle:CreateFontString(nil, "ARTWORK", "GameFontNormal") -- Use Addon.buttonGroupHorizontal
    dragText:SetPoint("TOP", Addon.dragHandle, "TOP", 0, - BUMPER_5)
    dragText:SetText("Drag Me!")
    dragText:Show()

    -- Create the background frame
    local bgFrame = CreateFrame("Frame", nil, UIParent)
    bgFrame:SetSize(300, 620)
    bgFrame:SetPoint("CENTER")

    bgFrame:SetMovable(true)
    bgFrame:EnableMouse(true)
    bgFrame:RegisterForDrag("LeftButton")
    bgFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)
    bgFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    -- Create a texture and set it as the background
    local bgTexture = bgFrame:CreateTexture(nil, "BACKGROUND")
    bgTexture:SetAllPoints(bgFrame)
    bgTexture:SetColorTexture(0, 0, 0, 0.8)

    -- Create the header text
    local headerText = bgFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    headerText:SetPoint("TOP", bgFrame, "TOP", 0, -10)
    headerText:SetText("Leif Consumes")

    editBoxes = {}
    buffButtons = {}
    additionalButtons = {} -- Clear additionalButtons

    -- Add the dropdown box
    local textPlacementDropdown = CreateFrame("Frame", "LeifConsumesTextPlacementDropdown", bgFrame, "UIDropDownMenuTemplate")
    textPlacementDropdown:SetPoint("TOPLEFT", 0, -50)
    UIDropDownMenu_SetWidth(textPlacementDropdown, 100)

    local textPlacementLabel = bgFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    textPlacementLabel:SetPoint("TOPLEFT", textPlacementDropdown, "TOPLEFT", 15, 15)
    textPlacementLabel:SetText("Text Placement:")

    -- Function to update button text position
    local function UpdateButtonTextPosition(button)
        local textPlacement = Addon.LeifConsumesDB.textPlacement
        local buttonText = button.timeText -- Assuming each button has a "timeText" property for the font string

        if textPlacement == "Above" then
            buttonText:SetPoint("CENTER", button, "CENTER", 0, Addon.BUTTON_SIZE)
        elseif textPlacement == "Below" then
            buttonText:SetPoint("CENTER", button, "CENTER", 0, -Addon.BUTTON_SIZE)
        elseif textPlacement == "Left" then
            buttonText:SetPoint("CENTER", button, "CENTER", - Addon.BUTTON_SIZE, 0)
        elseif textPlacement == "Right" then
            buttonText:SetPoint("CENTER", button, "CENTER", Addon.BUTTON_SIZE, 0)
        end
    end

    local function InitializeTextPlacementDropdown()
        local options = {
            { text = "Above", value = "Above" },
            { text = "Below", value = "Below" },
            { text = "Left",  value = "Left" },
            { text = "Right", value = "Right" }
        }
    
        UIDropDownMenu_Initialize(textPlacementDropdown, function(self, level)
            for _, option in ipairs(options) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = option.text
                info.value = option.value
                info.func = function(self)
                    Addon.LeifConsumesDB.textPlacement = option.value
                    UIDropDownMenu_SetText(textPlacementDropdown, option.text)
    
                    -- Update the button layout immediately
                    for _, buttonData in ipairs(Addon.horizontalButtons) do
                        -- print("Updating Horizontal")
                        UpdateButtonTextPosition(buttonData.button) -- Update text position for horizontal buttons
                    end
                    for _, buttonData in ipairs(Addon.verticalButtons) do
                        -- print("Updating Vertical")
                        UpdateButtonTextPosition(buttonData.button) -- Update text position for vertical buttons
                    end
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
    
        local savedPlacement = Addon.LeifConsumesDB.textPlacement or "Above"
        UIDropDownMenu_SetText(textPlacementDropdown, savedPlacement)
        UIDropDownMenu_JustifyText(textPlacementDropdown, "LEFT")
    end

    InitializeTextPlacementDropdown()  -- Call the initialization function

    local checkboxCount = 0  -- Initialize a counter for checkboxes

    local function CreateCheckbox(parent, relativePoint, yOffset, labelText, dbVariable, tooltipText)
        checkboxCount = checkboxCount + 1  -- Increment the counter
    
        local checkbox = CreateFrame("CheckButton", dbVariable .. "Checkbox", parent, "UICheckButtonTemplate")
    
        -- Calculate x-offset based on checkbox count
        local xOffset = (checkboxCount <= 2) and 10 or 150  
    
        checkbox:SetPoint("TOPLEFT", parent, relativePoint, xOffset, yOffset)
    
        local label = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        label:SetText(labelText)
    
        local checkedTexture = checkbox:CreateTexture(nil, "ARTWORK")
        checkedTexture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        checkbox:SetCheckedTexture(checkedTexture)
    
        local uncheckedTexture = checkbox:CreateTexture(nil, "ARTWORK")
        uncheckedTexture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
        checkbox:SetDisabledCheckedTexture(uncheckedTexture)
    
        checkbox:SetChecked(Addon.LeifConsumesDB[dbVariable])
    
        checkbox:SetScript("OnClick", function(self)
            Addon.LeifConsumesDB[dbVariable] = self:GetChecked()
    
            -- Update the button layout immediately
            for _, buttonData in ipairs(Addon.horizontalButtons) do
                updateButtonVisibility(buttonData.button, Addon.verticalButtons[buttonData.index].button)
            end
            for _, buttonData in ipairs(Addon.verticalButtons) do
                updateButtonVisibility(Addon.horizontalButtons[buttonData.index].button, buttonData.button)
            end
    
            if Addon.LeifConsumesDB.isVerticalMode then
                Addon.buttonGroupHorizontal:Hide()
                Addon.buttonGroupVertical:Show()
            else
                Addon.buttonGroupHorizontal:Show()
                Addon.buttonGroupVertical:Hide()
            end
        end)

        
         -- Store tooltipText as a property of the checkbox
        checkbox.tooltipText = tooltipText 
    
        -- Add tooltip support
        checkbox:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tostring(tooltipText), 1, 1, 1) 
            GameTooltip:Show()
        end)

        checkbox:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        return checkbox
    end

    CreateCheckbox(bgFrame, "TOPLEFT", -80, "Vertical Layout", "isVerticalMode", "Enable vertical layout for the buttons.")
    CreateCheckbox(bgFrame, "TOPLEFT", -110, "Load in Raid Only", "isRaidOnly", "Only load the addon when you are in a raid group.")
    CreateCheckbox(bgFrame, "TOPLEFT", -80, "Low Duration Warning", "lowDurationWarning", "Show buttons with lower opacties when consumables have low remaining duration. Without this they are hidden as long as you have the buff.")
    CreateCheckbox(bgFrame, "TOPLEFT", -110, "Never fade", "isHideIgnore", "Buttons will now only fade out instead of hiding completely")

    -- Add the slider for scale
    local scaleSlider = CreateFrame("Slider", "LeifConsumesScaleSlider", bgFrame, "OptionsSliderTemplate")
        scaleSlider:SetPoint("TOPLEFT", 150, -50) -- Adjust position as needed
        scaleSlider:SetWidth(110)
        scaleSlider:SetMinMaxValues(0.3, 3) -- Set minimum and maximum scale values
        scaleSlider:SetValueStep(0.1) -- Set the increment for the slider
        scaleSlider:SetValue(Addon.LeifConsumesDB.scale) -- Set initial value from saved settings

        -- Create the slider label
        local scaleLabel = bgFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        scaleLabel:SetPoint("TOPLEFT", scaleSlider, "TOPLEFT", 0, 15)
        scaleLabel:SetText("Scale:")

        -- Create the slider value text
        local scaleValueText = bgFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
        scaleValueText:SetPoint("RIGHT", scaleSlider, "RIGHT", -5, 15)  -- Adjusted position for better visibility

        -- Function to update the scale value text
        local function UpdateScaleValueText(value)
        scaleValueText:SetFormattedText("%.1f", value)
        end

        -- Set the initial scale value text
        UpdateScaleValueText(Addon.LeifConsumesDB.scale)

        -- Script handler for the slider
        scaleSlider:SetScript("OnValueChanged", function(self, value)
        Addon.LeifConsumesDB.scale = value
        UpdateScaleValueText(value)

        -- Update button sizes and positions
        Addon.BUTTON_SIZE = 32 * Addon.LeifConsumesDB.scale -- Recalculate button size

        for i, buttonData in ipairs(Addon.horizontalButtons) do
            local button = buttonData.button
            button:SetSize(Addon.BUTTON_SIZE, Addon.BUTTON_SIZE) -- Update size
            button:SetPoint("TOPLEFT", Addon.buttonGroupHorizontal, "TOPLEFT", Addon.BUTTON_SIZE * i, 0) -- Update position
        end
        
        for i, buttonData in ipairs(Addon.verticalButtons) do
            local button = buttonData.button
            button:SetSize(Addon.BUTTON_SIZE, Addon.BUTTON_SIZE) -- Update size
            button:SetPoint("TOPLEFT", Addon.buttonGroupVertical, "TOPLEFT", 0, Addon.BUTTON_SIZE - Addon.BUTTON_SIZE * i) -- Update position
        end
    end)

    local editBoxHeader = -15  -- Spacing for headers
    local editBoxChild = 0   -- Spacing for child elements

    local function CreateEditBox(parent, prevBox, labelText, category, index)
    local label = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")

        if prevBox then
            if labelText == "Off Hand" then  -- Special case for "Off Hand"
                label:SetPoint("TOPLEFT", prevBox, "BOTTOMLEFT", 0, -10)  -- Manually adjusted offse
            elseif labelText ~= "" then
                label:SetPoint("TOPLEFT", prevBox, "BOTTOMLEFT", 0, editBoxHeader)
            else
                label:SetPoint("TOPLEFT", prevBox, "BOTTOMLEFT", 0, editBoxChild)
            end
        else
            label:SetPoint("TOPLEFT", parent, "TOPLEFT", 20, editBoxHeader - 125)  -- Adjust First Header (Elixirs)
        end

        label:SetText(labelText)

        local editBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
        editBox:SetAutoFocus(false)
        editBox:SetSize(260, 20)
        editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -5)

        if Addon.LeifConsumesDB[category][index] ~= nil then
            editBox:SetText(Addon.LeifConsumesDB[category][index])
        end

        table.insert(editBoxes, {editBox = editBox, category = category})

        return editBox
    end
    
    local prevBox = nil
  
    -- Elixirs
    prevBox = CreateEditBox(bgFrame, prevBox, "Elixirs", "elixirs", 1)
    prevBox = CreateEditBox(bgFrame, prevBox, "", "elixirs", 2)
    prevBox = CreateEditBox(bgFrame, prevBox, "", "elixirs", 3)
  
    -- Flask
    prevBox = CreateEditBox(bgFrame, prevBox, "Flask", "flask", 1)
  
    -- Weapons
    prevBox = CreateEditBox(bgFrame, prevBox, "Main Hand", "mainHandEnchants", 1)
    prevBox = CreateEditBox(bgFrame, prevBox, "Off Hand", "offHandEnchants", 1)

    -- Food
    prevBox = CreateEditBox(bgFrame, prevBox, "Food", "food", 1)
  
    -- Other
    prevBox = CreateEditBox(bgFrame, prevBox, "Other", "other", 1)
    prevBox = CreateEditBox(bgFrame, prevBox, "", "other", 2)
    prevBox = CreateEditBox(bgFrame, prevBox, "", "other", 3)
    prevBox = CreateEditBox(bgFrame, prevBox, "", "other", 4)
    prevBox = CreateEditBox(bgFrame, prevBox, "", "other", 5)
    prevBox = CreateEditBox(bgFrame, prevBox, "", "other", 6)

    local function AcceptInput()
        local categoryIndices = {
            elixirs = 1,
            flask = 1,
            food = 1,
            mainHandEnchants = 1,
            offHandEnchants = 1,
            other = 1
        }

        -- Clear existing data in LeifConsumesDB
        for _, category in ipairs({"elixirs", "flask", "food", "mainHandEnchants", "offHandEnchants", "other"}) do
            Addon.LeifConsumesDB[category] = {}  -- Clear the category table
        end


        for _, editBoxData in ipairs(editBoxes) do
            local category = editBoxData.category
            local editBox = editBoxData.editBox
            local newItemName = editBox:GetText()
    
            if newItemName and newItemName ~= "" then
                local index = categoryIndices[category]
                Addon.LeifConsumesDB[category][index] = newItemName
                categoryIndices[category] = index + 1 
            end
        end
    
        -- Call updateButton for each item in Addon.LeifConsumesDB  (Corrected loop)
        local index = 1
        for _, category in ipairs({"elixirs", "flask", "food", "mainHandEnchants", "offHandEnchants", "other"}) do  -- Loop through categories
            for _, itemName in ipairs(Addon.LeifConsumesDB[category]) do
                updateButton(itemName, category, index)
                index = index + 1
            end
        end

        bgFrame:Hide()
        dragHandleBg:Hide()
        dragText:Hide()
        dragHandle:SetMovable(false)
        dragHandle:Hide()

        Addon.areLeifEditBoxesVisible = false 
    end

    for _, editBoxData in ipairs(editBoxes) do
        editBoxData.editBox:SetScript("OnEnterPressed", AcceptInput)
    end

    local closeButton = CreateFrame("Button", nil, bgFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", bgFrame, "TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", AcceptInput)

    bgFrame:Show() 
    dragHandleBg:Show()
    dragText:Show()
    dragHandle:SetMovable(true)
    dragHandle:Show()
end

-- When the addon loads, restore the position (if it exists)
local function RestoreWrapperPosition()
    if Addon.LeifConsumesDB.mainFrameX and Addon.LeifConsumesDB.mainFrameY then
        local adjustedX = Addon.LeifConsumesDB.mainFrameX - (Addon.mainFrame:GetWidth() / 2)
        Addon.mainFrame:SetPoint("LEFT", UIParent, "BOTTOMLEFT", adjustedX, Addon.LeifConsumesDB.mainFrameY) -- Use the same anchor points
    else
        Addon.mainFrame:SetPoint("CENTER", UIParent, "CENTER", MAIN_FRAME_WIDTH, MAIN_FRAME_WIDTH) -- Default position
    end
end

C_Timer.After(1.5, RestoreWrapperPosition) -- Wait for the game to load

local function CheckRaidStatus()
    local IsInRaid = IsInRaid()

    for _, buttonData in ipairs(Addon.horizontalButtons) do
        local button = buttonData.button
        local itemName = buttonData.itemName
        local category = buttonData.category

        if Addon.LeifConsumesDB.isRaidOnly and not IsInRaid and not Addon.areLeifEditBoxesVisible then
            -- print("If buttonGroupHorizontal")
            button:Hide()
            Addon.buttonGroupHorizontal:Hide()
            Addon.buttonGroupVertical:Hide()
        elseif not Addon.LeifConsumesDB.isVerticalMode then
            -- print("Elif 1 buttonGroupHorizontal")
            updateButtonVisibility(button, Addon.verticalButtons[buttonData.index].button)  
            Addon.buttonGroupHorizontal:Show()
            Addon.buttonGroupVertical:Hide()
        else
            -- print("Else buttonGroupHorizontal")
            button:Hide()
            Addon.buttonGroupHorizontal:Hide()
            Addon.buttonGroupVertical:Show()
        end
    end

    for _, buttonData in ipairs(Addon.verticalButtons) do
        local button = buttonData.button
        local itemName = buttonData.itemName
        local category = buttonData.category

        if Addon.LeifConsumesDB.isRaidOnly and not IsInRaid and not Addon.areLeifEditBoxesVisible then
            -- print("If buttonGroupVertical")
            button:Hide()
            Addon.buttonGroupHorizontal:Hide()
            Addon.buttonGroupVertical:Hide()
        elseif Addon.LeifConsumesDB.isVerticalMode then
            -- Call updateButtonVisibility here'
            -- print("Elif 1 buttonGroupVertical")
            updateButtonVisibility(button, Addon.verticalButtons[buttonData.index].button)  
            Addon.buttonGroupHorizontal:Hide()
            Addon.buttonGroupVertical:Show()
        else
            -- print("Else buttonGroupVertical")
            button:Hide()
            Addon.buttonGroupHorizontal:Show()
            Addon.buttonGroupVertical:Hide()
        end
    end
end

local function StatusUpdate()
    for _, buttonData in ipairs(Addon.horizontalButtons) do
        local horizontalButton = buttonData.button
        local verticalButton = Addon.verticalButtons[buttonData.index].button
        local itemName = horizontalButton.itemName

        -- Call updateButtonVisibility with the correct button arguments
        local remainingDuration = updateButtonVisibility(horizontalButton, verticalButton)

        local formattedTime = FormatRemainingTime(remainingDuration)

        if formattedTime and itemName ~= "Supercharged Chronoboon Displacer" then  -- Skip for Chronoboon
            buttonData.button.timeText:SetText(formattedTime)
        else
            -- print("Chronoboon", formattedTime)
        end
    end
    CheckRaidStatus()
end

C_Timer.NewTicker(0.5, StatusUpdate)

local logoutFrame = CreateFrame("Frame") 
    logoutFrame:RegisterEvent("PLAYER_LOGOUT")
    logoutFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGOUT" then
        LeifConsumesDB = Addon.LeifConsumesDB 
    end
end)

        -- Unregister the event to avoid unnecessary processing
        addonLoadedFrame:UnregisterEvent("ADDON_LOADED") 
    end
end)