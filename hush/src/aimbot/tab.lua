-- src/aimbot/tab.lua — UI แท็บ Aimbot + เริ่มระบบ aimbot
return function(ctx)
	local ui, S = ctx.UI, ctx.State.Aimbot

	if S.ShowFov == nil then S.ShowFov = false end
	if S.FovRadius == nil then S.FovRadius = 150 end

	ui:AddTab("Aimbot")
	ui:AddToggle("Aimbot", "Enable Aimbot", S.Enabled, function(v) S.Enabled = v end)
	ui:AddToggle("Aimbot", "Hold Right Mouse to Aim", S.HoldToAim, function(v) S.HoldToAim = v end)
	ui:AddToggle("Aimbot", "Auto-Fire", S.AutoFire, function(v) S.AutoFire = v end)
	ui:AddToggle("Aimbot", "Team Check", S.TeamCheck, function(v) S.TeamCheck = v end)
	ui:AddToggle("Aimbot", "Wall Check", S.WallCheck, function(v) S.WallCheck = v end)
	ui:AddToggle("Aimbot", "Show FOV", S.ShowFov, function(v) S.ShowFov = v end)
	ui:AddSlider("Aimbot", "FOV Radius (px)", 20, 600, S.FovRadius, function(v) S.FovRadius = v end, 5)
	ui:AddSlider("Aimbot", "Range (studs)", 50, 1500, S.Range, function(v) S.Range = v end, 10)
	ui:AddSlider("Aimbot", "Smoothness", 1, 100, S.Smoothness, function(v) S.Smoothness = v end)

	import("src/aimbot/loop.lua")(ctx)
	import("src/aimbot/fov.lua")(ctx)
end