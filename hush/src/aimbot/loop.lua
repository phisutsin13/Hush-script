-- src/aimbot/loop.lua — ลูปหลัก: หาเป้า → ล็อกกล้อง → ยิงออโต้
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local BIND_NAME = "ModularHubAimbot"

return function(ctx)
	local S = ctx.State.Aimbot
	if S.FireRate == nil then S.FireRate = 0.1 end

	local getTarget = import("src/aimbot/target.lua")
	local aimAt = import("src/aimbot/aim.lua")
	local autoFire = import("src/aimbot/autofire.lua")

	-- HoldToAim: กดเมาส์ขวาค้างเพื่อล็อกเป้า
	local holding = false
	ctx.Janitor:Add(UserInputService.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton2 then holding = true end
	end))
	ctx.Janitor:Add(UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton2 then holding = false end
	end))

	-- Bind หลังสคริปต์กล้องของ Roblox (Camera+1) ค่าจะไม่ถูกเขียนทับ
	RunService:BindToRenderStep(BIND_NAME, Enum.RenderPriority.Camera.Value + 1, function()
		if not S.Enabled or (S.HoldToAim and not holding) then return end
		local target = getTarget(S)
		if not target then return end
		local cam = workspace.CurrentCamera
		aimAt(S, cam, target)
		if S.AutoFire then autoFire(S, cam, target) end
	end)
	ctx.Janitor:Add(function() pcall(function() RunService:UnbindFromRenderStep(BIND_NAME) end) end)
end