local TABS = {"main", "aimbot", "visuals", "player", "settings"}

local env = (typeof(getgenv) == "function" and getgenv()) or _G
if env.__MODULAR_HUB_UNLOAD then pcall(env.__MODULAR_HUB_UNLOAD) end

-- เปลี่ยนจาก require เป็น import ให้หมด
local Janitor = import("core/janitor")
local UI = import("core/ui")

local janitor = Janitor.new()
local ctx = {
	State = import("core/state"),
	Janitor = janitor,
}

-- ... โค้ดส่วนที่เหลือเหมือนเดิม ...

for _, name in ipairs(TABS) do
	local ok, err = pcall(function() import(name .. "/tab")(ctx) end)
	if not ok then warn("[ModularHub] tab '" .. name .. "' error: " .. tostring(err)) end
end