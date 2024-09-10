-- Fast Attack Optimization
task.spawn(function()
	local Data = Combat
	local RigEvent = game:GetService("ReplicatedStorage").RigControllerEvent
	local Animation = Instance.new("Animation")
	local AttackCD, RecentlyFired, TryLag, lastFireValid = 0, 0, 0, 0
	local MaxLag, MinDelay = 350, 0.00075
	local Controller, Cooldown = nil, { combat = 0.07 }

	-- Reset Cooldown based on weapon type
	local function resetCD()
		local WeaponName = Controller.currentWeaponModel.Name:lower()
		AttackCD = tick() + (Cooldown[WeaponName] or 0.285) + ((TryLag / MaxLag) * 0.3)
		RigEvent:FireServer(RigEvent, "weaponChange", WeaponName)
		TryLag += 1
		task.delay(Cooldown[WeaponName] or 0.285 + (TryLag + 0.5 / MaxLag) * 0.3, function()
			TryLag -= 1
		end)
	end

	-- Shared variables for attack mechanics
	shared.orl = shared.orl or RL.wrapAttackAnimationAsync
	shared.cpc = shared.cpc or PC.play
	shared.dnew = shared.dnew or DMG.new
	shared.attack = shared.attack or RigC.attack

	-- Override attack animation for FastAttack
	RL.wrapAttackAnimationAsync = function(a, b, c, d, func)
		if not _G.FastAttack then
			PC.play = shared.cpc
			return shared.orl(a, b, c, d, func)
		end

		local Radius = _G.FastAttack or 65
		if #canHits > 0 then
			PC.play = function() end
			a:Play(MinDelay, 0.01, 0.01)
			func(canHits)
			wait(a.length * 0.5)
			a:Stop()
		end
	end

	-- Main loop for handling fast attacks
	while task.wait() do
		pcall(function()
			if #canHits > 0 then
				Controller = Data.activeController
				if Controller and Controller.equipped and not Char.Busy.Value and not LocalPlayer.PlayerGui.Main.Dialogue.Visible and Char.Stun.Value == 0 and Controller.currentWeaponModel then
					if _G.FastAttack and tick() > AttackCD then
						resetCD()
					end

					if tick() - lastFireValid > 0.5 then
						Controller.timeToNextAttack = 0
						Controller.increment = 1
						Controller.hitboxMagnitude = 65
						pcall(task.spawn, Controller.attack, Controller)
						lastFireValid = tick()
					end

					local AID = Controller.anims.basic[3] or Controller.anims.basic[2]
					Animation.AnimationId = AID
					local Playing = Controller.humanoid:LoadAnimation(Animation)
					Playing:Play(MinDelay, 0.01, 0.01)
					RigEvent:FireServer(RigEvent, "hit", canHits, AID and 1 or 2, "")
				end
			end
		end)
	end
end)
