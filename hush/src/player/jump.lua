-- src/player/jump.lua — JumpPower (เก็บค่าเดิม คืนค่าเมื่อปิด/unload)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local function getHumanoid()
	return localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
end

return function(ctx)
	local S = ctx.State.Jump
	local originalPower, originalUse
	local api = {}

	function api.Set(state)
		local hum = getHumanoid()
		if state and not S.Enabled then
			originalPower = hum and hum.JumpPower or 50
			originalUse = hum and hum.UseJumpPower
		elseif not state and S.Enabled and hum then
			hum.JumpPower = originalPower or 50
			if originalUse ~= nil then hum.UseJumpPower = originalUse end
		end
		S.Enabled = state
	end

	ctx.Janitor:Add(RunService.Heartbeat:Connect(function()
		if not S.Enabled then return end
		local hum = getHumanoid()
		if hum then hum.UseJumpPower = true; hum.JumpPower = S.Value end
	end))
	ctx.Janitor:Add(function() api.Set(false) end)
	return api
end
