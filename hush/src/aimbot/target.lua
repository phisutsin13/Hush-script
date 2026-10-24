-- src/aimbot/target.lua — หา Head ที่ใกล้ที่สุดในระยะ และต้องอยู่ในวง FOV
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer
local isVisible = import("src/aimbot/visible.lua")

return function(S)
	local cam = workspace.CurrentCamera
	local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
	local origin = myRoot and myRoot.Position or cam.CFrame.Position
	local mouse = UserInputService:GetMouseLocation()
	local fovRadius = S.FovRadius or 150

	local best, bestDist = nil, S.Range
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr == localPlayer then continue end
		if S.TeamCheck and plr.Team ~= nil and plr.Team == localPlayer.Team then continue end

		local char = plr.Character
		local head = char and char:FindFirstChild("Head")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not head or not hum or hum.Health <= 0 then continue end

		-- เช็คว่าอยู่ในวง FOV บนหน้าจอ
		local pos, onScreen = cam:WorldToViewportPoint(head.Position)
		if not onScreen then continue end
		if (Vector2.new(pos.X, pos.Y) - mouse).Magnitude > fovRadius then continue end

		local dist = (head.Position - origin).Magnitude
		if dist < bestDist and (not S.WallCheck or isVisible(cam.CFrame.Position, head)) then
			best, bestDist = head, dist
		end
	end
	return best
end