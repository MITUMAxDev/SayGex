-- Cache services to improve performance
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Cache the player's CombatFramework
local player = Players.LocalPlayer
local CombatFramework = require(player.PlayerScripts.CombatFramework)

-- Cache the CameraShaker module and stop it
local CameraShaker = require(ReplicatedStorage.Util.CameraShaker)
CameraShaker:Stop()

-- Function to safely access getupvalues
local function safeGetUpvalue(tbl, index)
    return tbl and tbl[index] or nil
end

-- Cache active controller for faster access
local activeController = safeGetUpvalue(getupvalues(CombatFramework), 2) and getupvalues(CombatFramework)[2]['activeController']

-- Check if the activeController is valid before proceeding
if activeController then
    coroutine.wrap(function()
        -- Use Stepped instead of Connect to avoid creating multiple listeners
        RunService.Stepped:Connect(function()
            -- Ensure timeToNextAttack exists to prevent errors
            if activeController.timeToNextAttack then
                -- Reset attack cooldown and increase hitbox size
                activeController.timeToNextAttack = 0
                activeController.hitboxMagnitude = 25

                -- Call attack method
                activeController:attack()
            end
        end)
    end)()
end
