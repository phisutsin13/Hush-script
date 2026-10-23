-- src/player/speed.lua — WalkSpeed (เก็บค่าเดิม คืนค่าเมื่อปิด/unload)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local function getHumanoid()
	return localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Humanoid")
end

return function(ctx)
	local S = ctx.State.Speed
	local original
	local api = {}

	function api.Set(state)
		local hum = getHumanoid()
		if state and not S.Enabled then
			original = hum and hum.WalkSpeed or 16
		elseif not state and S.Enabled and hum then
			hum.WalkSpeed = original or 16
		end
		S.Enabled = state
	end

	-- ลูปคุมค่า (กันเกมรีเซ็ตกลับ)
	ctx.Janitor:Add(RunService.Heartbeat:Connect(function()
		if not S.Enabled then return end
		local hum = getHumanoid()
		if hum then hum.WalkSpeed = S.Value end
	end))
	ctx.Janitor:Add(function() api.Set(false) end)
	return api
end
