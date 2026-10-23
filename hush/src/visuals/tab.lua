-- src/visuals/tab.lua — UI แท็บ Visuals + เริ่ม ESP / Fullbright
return function(ctx)
	local ui, S = ctx.UI, ctx.State.Esp
	ui:AddTab("Visuals")

	require("visuals/esp")(ctx)
	local fullbright = require("visuals/fullbright")(ctx)

	ui:AddToggle("Visuals", "Player ESP", S.Enabled, function(v) S.Enabled = v end)
	ui:AddSlider("Visuals", "ESP Distance (studs)", 50, 2000, S.Distance, function(v) S.Distance = v end, 10)
	ui:AddToggle("Visuals", "Fullbright", false, fullbright.Set)
end
