-- src/aimbot/target.lua — หา Head ของผู้เล่นที่ "ใกล้ที่สุด" ในระยะ (ใช้ .Magnitude)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local isVisible = import("aimbot/visible")

return function(S)
	local cam = workspace.CurrentCamera
	local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local origin = myRoot and myRoot.Position or cam.CFrame.Position

	local best, bestDist = nil, S.Range
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == localPlayer then continue end
		if S.TeamCheck and plr.Team ~= nil and plr.Team == localPlayer.Team then continue end

		local char = plr.Character
		local head = char and char:FindFirstChild("Head")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not head or not hum or hum.Health <= 0 then continue end

		local dist = (head.Position - origin).Magnitude
		if dist < bestDist and (not S.WallCheck or isVisible(cam.CFrame.Position, head)) then
			best, bestDist = head, dist
		end
	end
	return best
end
