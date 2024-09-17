-- https://wowwiki-archive.fandom.com/wiki/Events/Item
-- https://wowwiki-archive.fandom.com/wiki/World_of_Warcraft_API#Container_/_Bag
-- https://wowwiki-archive.fandom.com/wiki/BagId
-- https://stackoverflow.com/questions/48273776/vararg-function-parameters-dont-work-with-arg-variable
---
-- Debuging
local debug = false
local function printDebug(msg)
    if debug then
        print("LaggInvetoryScanner: ", msg)
    end
end

-- Loading Saved Variables
LaggInvetory = LaggInvetory or {}

local playerKey = GetRealmName() .. "/" .. UnitName("player")
LaggInvetory[playerKey] = LaggInvetory[playerKey] or {}
printDebug("playerKey: " .. playerKey)
-- return a table containing the numeric ids of your BAG slots
local function getBagSlotIds()
    local result = {};
    local first = 0;
    local last = NUM_BAG_SLOTS;
    local i = first
    while i <= last do
        table.insert(i);
        i = i + 1;
    end
    return result;
end
-- return a table containing the numeric ids of your BANK slots
local function getBankSlotIds()
    local result = {};
    local first = NUM_BAG_SLOTS + 1;
    local last = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS;
    local i = first
    while i <= last do
        table.insert(result, i);
        i = i + 1;
    end
    return result;
end
local function scanBag(bagId)
    -- https://wowwiki-archive.fandom.com/wiki/API_GetContainerNumSlots

    printDebug("scanBag: " .. bagId)
    local numSlots = GetContainerNumSlots(bagId);
    if (numSlots == nil) or (numSlots <= 0) then
        return;
    end
    local numFreeSlots = GetContainerNumFreeSlots(bagId);
    local numFilledSlots = numSlots - numFreeSlots;
    printDebug("scanBag.numFilledSlots: " .. numFilledSlots)

    local bagKey = "bag"
    if bagId < 10 then
        bagKey = bagKey .. "0" .. bagId
    else
        bagKey = bagKey .. bagId
    end

    if LaggInvetory[playerKey][bagKey] == nil then
        LaggInvetory[playerKey][bagKey] = {}
    end

    local i = 1;
    while i < numSlots do
        local slotKey = "slot";
        if i < 10 then
            slotKey = slotKey .. "0" .. i
        else
            slotKey = slotKey .. i
        end
        local itemLink = GetContainerItemLink(bagId, i);

        printDebug("updating [" .. playerKey .. "][" .. bagKey .. "][" .. slotKey .. "] = " .. (itemLink or "nil"))
        -- nil removed the value from the table so it all works out
        LaggInvetory[playerKey][bagKey][slotKey] = itemLink;
        i = i + 1;
    end
end
local function scanAllBags()
    for _, v in ipairs(getBagSlotIds()) do
        scanBag(v);
    end
end
local function scanBank()
    for _, v in ipairs(getBankSlotIds()) do
        scanBag(v);
    end
end
-- event handler for the "BAG_UPDATE" event
local bagUpdatesDone = {}
local function event_BAG_UPDATE(event, containerId, ...)
    local estr = containerId or "nil"
    printDebug("event_BAG_UPDATE: " .. estr)
    if event ~= "BAG_UPDATE" then
        return
    end
    if (bagUpdatesDone[containerId] == nil) or (bagUpdatesDone[containerId] == false) then
        scanBag(containerId);
        bagUpdatesDone[containerId] = true;
    end

end
-- event handler for the "BANKFRAME_OPENED" event
local function event_BANKFRAME_OPENED(event, ...)
    printDebug("event_BANKFRAME_OPENED")
    if event ~= "BANKFRAME_OPENED" then
        return
    end

    scanBank();
end
-- event handler for the "BANKFRAME_CLOSED" event
local function event_BANKFRAME_CLOSED(event, ...)
    local estr = containerId or "nil"
    printDebug("event_BANKFRAME_CLOSED")
    if event ~= "BANKFRAME_CLOSED" then
        return
    end

    scanBank();
end
-- event handler for the "BANKFRAME_CLOSED" event
local function event_UNIT_INVENTORY_CHANGED(event, unitId, ...)
    local estr = containerId or "nil"
    printDebug("event_UNIT_INVENTORY_CHANGED: " .. (unitId or "nil"))
    if event ~= "UNIT_INVENTORY_CHANGED" then
        return
    end

    if unitId == "player" then
        scanAllBags();
        -- TODO Scan Equipment
    end
end

-- global event handler
local function OnEvent(self, event, ...)
    local estr = event or "nil"
    printDebug("On_event: " .. estr)

    if event == "BAG_UPDATE" then
        event_BAG_UPDATE(event, ...)
    elseif event == "BANKFRAME_OPENED" then
        event_BANKFRAME_OPENED(event, ...)
    elseif event == "BANKFRAME_CLOSED" then
        event_BANKFRAME_CLOSED(event, ...)
    elseif event == "UNIT_INVENTORY_CHANGED" then
        event_UNIT_INVENTORY_CHANGED(event, ...)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("BANKFRAME_OPENED")
f:RegisterEvent("BANKFRAME_CLOSED")
f:RegisterEvent("BAG_UPDATE")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")

f:SetScript("OnEvent", OnEvent)

-- Load MSG
local loadedMsg = "LaggInvetoryScanner loaded.";
if debug then
    loadedMsg = loadedMsg .. " Debug enabled"
end
print(loadedMsg)
