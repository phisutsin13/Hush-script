-- src/player/tab.lua — UI แท็บ Player + เริ่ม Speed / Jump
return function(ctx)
	local ui = ctx.UI
	local SS, JS = ctx.State.Speed, ctx.State.Jump
	ui:AddTab("Player")

	local speed = require("player/speed")(ctx)
	local jump = require("player/jump")(ctx)

	ui:AddToggle("Player", "WalkSpeed", SS.Enabled, speed.Set)
	ui:AddSlider("Player", "Speed Value", 16, 200, SS.Value, function(v) SS.Value = v end)
	ui:AddToggle("Player", "JumpPower", JS.Enabled, jump.Set)
	ui:AddSlider("Player", "Jump Value", 50, 300, JS.Value, function(v) JS.Value = v end)
end
