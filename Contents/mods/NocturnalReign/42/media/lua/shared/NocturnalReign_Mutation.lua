--[[
    NocturnalReign_Mutation.lua  (shared)

    The photophobia / nightfall stat rules, factored out of the server
    module so BOTH sides can apply them.

    WHY THIS IS SHARED - THE MULTIPLAYER ZOMBIE OWNERSHIP MODEL:
    Project Zomboid multiplayer gives authority over each zombie's
    moment-to-moment simulation to the CLIENT nearest to it, not to the
    server (see the developers' "Zed Clients" and "OwnerZhip" blog posts;
    B42's unstable MP keeps this model). A speed change applied only on the
    server therefore never reaches the zombies that matter most - the ones
    right next to a remote player, which that player's own client is
    simulating. The classic, proven fix (used by every B41-era zombie-stat
    mod) is to make the rule DETERMINISTIC from state every machine already
    shares - the world clock and the climate - and run the same pass on the
    server (for its zombies, and for single-player) and on every client
    (for theirs). No per-zombie state ever needs to cross the network, and
    all machines agree by construction.

    Everything here is stat/gait application only. Pathing decisions
    (shade-seeking, shelter-holding, Lord orders) stay server-side in
    NocturnalReign_Server.lua: they are one-shot orders, not per-zombie
    persistent stats, and duplicating them per client would make zombies
    dance between conflicting paths.

    B42 GAIT API NOTE:
    Build 42.18 added official public speed methods on IsoZombie -
    doShambler(), doFastShambler(), doSprinter(), doCrawlerSpeed(),
    getSpeedType() (see the wiki's "Build 42.18.0 modding news"). These are
    the sanctioned way to change a zombie's gait and are preferred here;
    the legacy setSpeedType/setZombieSpeedType probes remain as fallbacks
    for slightly older 42.x builds.
]]

require "NocturnalReign_SandboxOptions"

NocturnalReign = NocturnalReign or {}
NocturnalReign.Mutation = NocturnalReign.Mutation or {}
local Mutation = NocturnalReign.Mutation
local Options = NocturnalReign.Options
local Keys = NocturnalReign.ModDataKeys

----------------------------------------------------------------------------
-- Small utility: try a list of candidate setter names on `obj` until one of
-- them exists and doesn't error. Returns the name that worked, or nil.
-- Exists because a few B42-unstable per-zombie setters (raw sight/hearing/
-- memory floats) are still in flux across builds; probing a short list
-- beats hard-coding a name that silently doesn't exist on some build.
----------------------------------------------------------------------------
function Mutation.trySetters(obj, methodNames, ...)
    for i = 1, #methodNames do
        local fn = obj[methodNames[i]]
        if type(fn) == "function" then
            local ok = pcall(fn, obj, ...)
            if ok then return methodNames[i] end
        end
    end
    return nil
end

--- Same idea, but for getters: tries each candidate method name and
--- returns the first non-nil result instead of just a success flag.
function Mutation.tryGetters(obj, methodNames, ...)
    for i = 1, #methodNames do
        local fn = obj[methodNames[i]]
        if type(fn) == "function" then
            local ok, result = pcall(fn, obj, ...)
            if ok and result ~= nil then return result end
        end
    end
    return nil
end

local trySetters = Mutation.trySetters

-- The no-argument official methods can't go through trySetters (it would
-- pass them stray arguments); call them directly, legacy index fallback
-- after. Indices: 0 = shambler, 2 = fast shambler, 3 = sprinter - the
-- same convention every speed-enum revision we've seen uses.
local GAITS = {
    shamble     = { official = "doShambler",     legacyIndex = 0 },
    fastShamble = { official = "doFastShambler", legacyIndex = 2 },
    sprint      = { official = "doSprinter",     legacyIndex = 3 },
}

--- Set a zombie's gait: "shamble" | "fastShamble" | "sprint".
function Mutation.setGait(zombie, gaitName)
    local gait = GAITS[gaitName]
    if not gait then return end
    local fn = zombie[gait.official]
    if type(fn) == "function" and pcall(fn, zombie) then return end
    trySetters(zombie, { "setSpeedType", "setZombieSpeedType" }, gait.legacyIndex)
end

----------------------------------------------------------------------------
-- Shared environment tests: every machine computes these from the world
-- clock and its own (engine-synced) climate, so they agree everywhere.
----------------------------------------------------------------------------

--- A zombie is "in direct sunlight" if its current square has no roof
--- overhead (isOutside) AND the world's ambient daylight is actually bright
--- (getDayLightStrength ~1 at noon, ~0 at night/heavy overcast dusk) - this
--- keeps zombies safe under deep dusk/dawn gloom even while technically
--- outdoors and inside the configured day window.
function Mutation.isZombieInDirectSunlight(zombie)
    local square = zombie:getCurrentSquare()
    if not square or not square:isOutside() then return false end

    local climate = getClimateManager()
    local daylight = climate and climate:getDayLightStrength() or 1.0
    return daylight > 0.35
end

--- Whether the sun currently threatens outdoor zombies: inside the
--- configured day window AND not shielded by heavy fog. Reading the actual
--- climate value (vanilla-verified getFogIntensity, same threshold family
--- vanilla fishing/foraging use) means both the Zombie Lord's called fog
--- AND naturally-occurring heavy fog grant the protection.
function Mutation.isSunThreatNow()
    local daytime = Options.isDaytimeHour(getGameTime():getHour())
    if not daytime then return false end
    local fogShield = false
    pcall(function() fogShield = getClimateManager():getFogIntensity() >= 0.5 end)
    return not fogShield
end

----------------------------------------------------------------------------
-- MODULE 1 stats: photophobia (daytime sun-slow).
-- ModData flags here are per-machine idempotence markers, nothing more -
-- they are never synced and never need to be.
----------------------------------------------------------------------------

function Mutation.applySunSlow(zombie)
    local md = zombie:getModData()
    if md[Keys.IS_SUNSICK] then return end
    md[Keys.IS_SUNSICK] = true

    Mutation.setGait(zombie, "shamble")
    zombie:setRunning(false)
    if zombie.setSprinting then pcall(zombie.setSprinting, zombie, false) end
end

function Mutation.revertSunSlow(zombie)
    local md = zombie:getModData()
    if not md[Keys.IS_SUNSICK] then return end
    md[Keys.IS_SUNSICK] = nil
    -- Restore the normal daytime gait so a zombie that reached shelter
    -- behaves normally again. (If it's actually nighttime, the night pass
    -- immediately after this one upgrades it to a sprinter anyway.)
    Mutation.setGait(zombie, "fastShamble")
end

----------------------------------------------------------------------------
-- MODULE 2 stats: nightfall mutation.
----------------------------------------------------------------------------

function Mutation.applyNight(zombie)
    local md = zombie:getModData()
    if md[Keys.IS_SPRINTER] then return end
    md[Keys.IS_SPRINTER] = true

    Mutation.setGait(zombie, "sprint")
    -- Probe for a direct multiplier setter so the SprinterSpeedMultiplier
    -- sandbox option does something concrete on builds that expose one;
    -- it's a harmless no-op otherwise.
    trySetters(zombie, { "setSpeedMultiplier" }, Options.getSprinterSpeedMultiplier())
    zombie:setRunning(true)
    if zombie.setSprinting then pcall(zombie.setSprinting, zombie, true) end

    -- Maximise senses. Every name probed maps to "as sharp as the engine
    -- allows" rather than a tunable magnitude, since B42 does not yet expose
    -- granular per-zombie sensory floats in a stable, documented way.
    trySetters(zombie, { "setSight", "setVisionStrength" }, 1.0)
    trySetters(zombie, { "setHearing", "setHearingStrength" }, 1.0)
    trySetters(zombie, { "setMemory", "setTrackingMemory" }, 100)
end

function Mutation.revertNight(zombie)
    local md = zombie:getModData()
    if not md[Keys.IS_SPRINTER] then return end
    md[Keys.IS_SPRINTER] = nil

    Mutation.setGait(zombie, "fastShamble") -- back to a "normal" baseline
    trySetters(zombie, { "setSight", "setVisionStrength" }, 0.5)
    trySetters(zombie, { "setHearing", "setHearingStrength" }, 0.5)
    trySetters(zombie, { "setMemory", "setTrackingMemory" }, 50)
end
