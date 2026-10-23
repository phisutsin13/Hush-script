-- src/init.lua — จุดเริ่มต้น: สร้าง ctx, UI, โหลดแต่ละแท็บ, จัดการ unload
-- ลำดับใน TABS = ลำดับแท็บที่แสดงใน GUI
local TABS = {"main", "aimbot", "visuals", "player", "settings"}

local env = (typeof(getgenv) == "function" and getgenv()) or _G
if env.__MODULAR_HUB_UNLOAD then pcall(env.__MODULAR_HUB_UNLOAD) end -- กันรันซ้ำ

local Janitor = require("core/janitor")
local UI = require("core/ui")

local janitor = Janitor.new()
local ctx = {
	State = require("core/state"), -- ค่าตั้งทั้งหมด
	Janitor = janitor,             -- ที่เก็บของที่ต้องล้างตอน unload
}

local unloaded = false
function ctx.Unload()
	if unloaded then return end
	unloaded = true
	janitor:Cleanup() -- ล้างย้อนหลัง: ฟีเจอร์ (คืนค่าเดิม) → UI
	env.__MODULAR_HUB_UNLOAD = nil
end
env.__MODULAR_HUB_UNLOAD = ctx.Unload

ctx.UI = UI.new({Title = "MODULAR HUB", ToggleKey = Enum.KeyCode.RightShift, OnClose = ctx.Unload})
janitor:Add(ctx.UI)

for _, name in ipairs(TABS) do
	-- แท็บไหนพัง จะไม่ทำให้แท็บอื่นพังตาม
	local ok, err = pcall(function() require(name .. "/tab")(ctx) end)
	if not ok then warn("[ModularHub] tab '" .. name .. "' error: " .. tostring(err)) end
end
