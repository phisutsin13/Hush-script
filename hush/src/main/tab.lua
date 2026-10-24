-- src/main/tab.lua — แท็บ Main
local Players = game:GetService("Players")

return function(ctx)
	-- ป้องกัน Error กรณี ctx หรือ UI ส่งมาไม่ครบ
	if not ctx or not ctx.UI then return end
	local ui = ctx.UI

	ui:AddTab("Main")
	ui:AddLabel("Main", "Welcome, " .. Players.LocalPlayer.DisplayName)
	ui:AddLabel("Main", "RightShift = ซ่อน/แสดงหน้าต่าง  |  X = ถอนสคริปต์")
	ui:AddButton("Main", "Unload Script", ctx.Unload)
end