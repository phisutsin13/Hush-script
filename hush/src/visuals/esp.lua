-- src/visuals/esp.lua — ระบบ ESP: อัปเดตทุกเฟรม + กรองระยะแบบ Dynamic
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer
local createTag = require("visuals/esp_tag")

return function(ctx)
	local S = ctx.State.Esp
	local tags = {} -- [Player] = tag

	local folder = Instance.new("Folder")
	folder.Name = "ESPTags"
	folder.Parent = localPlayer:WaitForChild("PlayerGui")
	ctx.Janitor:Add(folder)

	local function remove(plr)
		local tag = tags[plr]
		if tag then tag.Gui:Destroy(); tags[plr] = nil end
	end

	ctx.Janitor:Add(Players.PlayerRemoving:Connect(remove))
	ctx.Janitor:Add(RunService.RenderStepped:Connect(function()
		if not S.Enabled then
			for _, tag in pairs(tags) do tag.Gui.Enabled = false end
			return
		end

		local cam = workspace.CurrentCamera
		local myRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
		local origin = myRoot and myRoot.Position or cam.CFrame.Position

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == localPlayer then continue end
			local head = plr.Character and plr.Character:FindFirstChild("Head")
			if not head then remove(plr) continue end

			local tag = tags[plr]
			if tag and tag.Head ~= head then remove(plr); tag = nil end -- respawn

			local dist = (head.Position - origin).Magnitude
			if dist <= S.Distance then
				if not tag then tag = createTag(folder, plr, head); tags[plr] = tag end
				tag.Gui.Enabled = true
				local d = math.floor(dist)
				if d ~= tag.LastDist then
					tag.LastDist = d
					tag.Label.Text = string.format("%s [%d]", plr.DisplayName, d)
				end
			elseif tag then
				tag.Gui.Enabled = false
			end
		end
	end))
end
