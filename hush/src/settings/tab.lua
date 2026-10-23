-- src/settings/tab.lua — แท็บ Settings
return function(ctx)
	local ui = ctx.UI
	ui:AddTab("Settings")
	ui:AddLabel("Settings", "Toggle key: RightShift")
	ui:AddButton("Settings", "Unload & Cleanup", ctx.Unload)
end
