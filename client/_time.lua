-- ====================================================================================--
--  MIT License 2020 : Twiitchter
-- ====================================================================================--
c.time = {}
--[[
NOTES:
    -
    -
    -
]] --
math.randomseed(c.Seed)
-- ====================================================================================--
-- I miss NetworkOverrideClockMillisecondsPerGameMinute() - It broke.

local time = {0,0}

function c.time.GetTime()
    local time = GetConvar("Time", "00:00")
    local hour = tonumber(time:sub(1,2))
    local min  = tonumber(time:sub(4,5))
    return {hour, min}
end

function c.time.UpdateTime()
    local function Do()
        time = c.time.GetTime()
        SetTimeout(c.min, Do)
    end
    SetTimeout(c.min, Do)
end

Citizen.CreateThread(function() 
    while true do
        Wait(1250)
        NetworkOverrideClockTime(time[1], time[2])
    end
end)