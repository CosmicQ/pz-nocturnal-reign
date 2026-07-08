--[[
    NocturnalReign_Client.lua

    Client-side flavour layer for Nocturnal Reign. Files under
    media/lua/client/ only ever run on the client (including the local
    client of a single-player game), so this file never touches the
    authoritative simulation - it only *reads* state the server already
    wrote (via ModData, which the engine syncs on IsoGameCharacter/IsoObject
    automatically) and turns it into on-screen feedback.

    Nothing here mutates gameplay state: worst case if this file's checks
    are ever wrong, the player sees a missing/incorrect warning banner, not
    a broken simulation.
]]

require "NocturnalReign_SandboxOptions"

NocturnalReign = NocturnalReign or {}
NocturnalReign.Client = NocturnalReign.Client or {}
local Client = NocturnalReign.Client
local Options = NocturnalReign.Options
local Keys = NocturnalReign.ModDataKeys

local lastPeriod = nil
local scanCounter = 0
local lordWarningCooldownTicks = 0

-- Purely a UI polling cadence, not a gameplay one: ~60 OnPlayerUpdate calls
-- is roughly 2 seconds at 30fps. Cheap enough to run unconditionally since
-- it only ever looks at the local player and their already-loaded cell.
local SCAN_EVERY_TICKS = 60
local LORD_WARNING_COOLDOWN_TICKS = SCAN_EVERY_TICKS * 5

local function announce(player, text)
    -- HaloTextHelper floats a short-lived label over the character - a
    -- lightweight way to surface a transition notice without building a
    -- dedicated UI panel for what is a purely cosmetic cue. Signature
    -- verified against the decompiled 42.19 HaloTextHelper class: every
    -- colored overload is (player, text, separator, color) - there is NO
    -- (player, text, color) form, and passing one throws "No implementation
    -- found". "[br/]" is the separator active vanilla callers use.
    if HaloTextHelper and HaloTextHelper.addText then
        pcall(function() HaloTextHelper.addText(player, text, "[br/]", HaloTextHelper.getColorRed()) end)
    else
        print("[NocturnalReign] " .. text)
    end
end

local function checkDayNightTransition(player)
    local hour = getGameTime():getHour()
    local daytime = Options.isDaytimeHour(hour)
    local period = daytime and "day" or "night"
    if period == lastPeriod then return end
    lastPeriod = period

    if daytime then
        if Options.isPhotophobiaEnabled() then
            announce(player, "The sun rises - exposed zombies will burn in the open.")
        end
    else
        if Options.isNightMutationEnabled() then
            announce(player, "Nightfall falls - the horde grows fast and sharp-eyed.")
        end
    end
end

local function scanForNearbyLord(player)
    if not Options.isZombieLordEnabled() then return end

    if lordWarningCooldownTicks > 0 then
        lordWarningCooldownTicks = lordWarningCooldownTicks - 1
        return
    end

    local cell = player:getCell()
    if not cell then return end
    local list = cell:getZombieList()
    if not list then return end

    local px, py = player:getX(), player:getY()
    local warnRadiusSq = 30 * 30

    for i = 0, list:size() - 1 do
        local zombie = list:get(i)
        if zombie and not zombie:isDead() and zombie:getModData()[Keys.IS_LORD] then
            local dx, dy = zombie:getX() - px, zombie:getY() - py
            if (dx * dx + dy * dy) <= warnRadiusSq then
                announce(player, "Something huge is commanding the dead nearby...")
                lordWarningCooldownTicks = LORD_WARNING_COOLDOWN_TICKS
                break
            end
        end
    end
end

local function onPlayerUpdate(player)
    if player ~= getPlayer() then return end -- ignore any non-local-player callback quirks

    scanCounter = scanCounter + 1
    if scanCounter < SCAN_EVERY_TICKS then return end
    scanCounter = 0

    checkDayNightTransition(player)
    scanForNearbyLord(player)
end

Events.OnPlayerUpdate.Add(onPlayerUpdate)
