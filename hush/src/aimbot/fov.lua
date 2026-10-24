-- src/aimbot/fov.lua — วงกลม FOV ที่ตามเมาส์
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

return function(ctx)
	local S = ctx.State.Aimbot

	if not Drawing then
		warn("[fov] executor นี้ไม่รองรับ Drawing API")
		return
	end

	local circle = Drawing.new("Circle")
	circle.Thickness = 1
	circle.NumSides = 64
	circle.Filled = false
	circle.Color = Color3.fromRGB(255, 255, 255)
	circle.Visible = false

	ctx.Janitor:Add(RunService.RenderStepped:Connect(function()
		local show = S.ShowFov == true
		circle.Visible = show
		if show then
			circle.Radius = S.FovRadius or 150
			circle.Position = UserInputService:GetMouseLocation()
		end
	end))

	ctx.Janitor:Add(function()
		pcall(function() circle:Remove() end)
	end)
end