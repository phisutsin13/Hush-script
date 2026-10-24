local TABS = {"main", "aimbot", "visuals", "player", "settings"}

local env = (typeof(getgenv) == "function" and getgenv()) or _G
if env.__MODULAR_HUB_UNLOAD then pcall(env.__MODULAR_HUB_UNLOAD) end

local Janitor = import("core/janitor")
local UI = import("core/ui")

local janitor = Janitor.new()

-- ฟังก์ชันสำหรับถอนสคริปต์ (Unload)
local function unload()
	janitor:Cleanup()
	if UI and UI.Destroy then
		pcall(function() UI:Destroy() end)
	end
	env.__MODULAR_HUB_UNLOAD = nil
end

env.__MODULAR_HUB_UNLOAD = unload

local ctx = {
	State = import("core/state"),
	Janitor = janitor,
	UI = UI,
	Unload = unload, -- เพิ่ม Unload เข้าไปใน ctx เพื่อให้ปุ่มในแท็บ Main เรียกใช้ได้
}

for _, name in ipairs(TABS) do
	local ok, err = pcall(function() import(name .. "/tab")(ctx) end)
	if not ok then warn("[ModularHub] tab '" .. name .. "' error: " .. tostring(err)) end
end