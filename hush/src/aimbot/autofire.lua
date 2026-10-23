-- src/aimbot/autofire.lua — ยิงอัตโนมัติ เมื่อเล็งตรงเป้าหมายแล้ว
local localPlayer = game:GetService("Players").LocalPlayer
local lastFire = 0

return function(S, cam, head)
	local toTarget = (head.Position - cam.CFrame.Position).Unit
	if cam.CFrame.LookVector:Dot(toTarget) < 0.998 then return end -- ต้องเล็งตรง (~3.6°)

	local now = os.clock()
	if now - lastFire < S.FireRate then return end

	local tool = localPlayer.Character and localPlayer.Character:FindFirstChildOfClass("Tool")
	if tool then
		lastFire = now
		tool:Activate()
	end
end
