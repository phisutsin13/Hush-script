local TABS = {"main", "aimbot", "visuals", "player", "settings"}

local env = (typeof(getgenv) == "function" and getgenv()) or _G
if env.__MODULAR_HUB_UNLOAD then pcall(env.__MODULAR_HUB_UNLOAD) end

-- ดึงโมดูลพื้นฐาน
local Janitor = import("src/core/janitor.lua")
local UIClass = import("src/core/ui.lua")
local State = import("src/core/state.lua")

local janitor = Janitor.new()

-- สร้าง Instance ของ UI หน้าต่างหลัก
local uiInstance = nil
if UIClass and typeof(UIClass.new) == "function" then
	uiInstance = UIClass.new({
		Title = "Hush Script Hub",
		ToggleKey = Enum.KeyCode.RightShift
	})
end

-- ฟังก์ชันสำหรับถอนสคริปต์ (Unload)
local function unload()
	janitor:Cleanup()
	if uiInstance and uiInstance.Destroy then
		pcall(function() uiInstance:Destroy() end)
	end
	env.__MODULAR_HUB_UNLOAD = nil
end

env.__MODULAR_HUB_UNLOAD = unload

local ctx = {
	State = State,
	Janitor = janitor,
	UI = uiInstance, -- ส่ง UI Instance ที่มีเมธอด AddTab ไปให้แท็บต่างๆ
	Unload = unload,
}

-- โหลดแท็บย่อยทั้งหมด
for _, name in ipairs(TABS) do
	local ok, err = pcall(function()
		local tabModule = import("src/" .. name .. "/tab.lua")
		if type(tabModule) == "function" then
			tabModule(ctx)
		elseif type(tabModule) == "table" and type(tabModule.Init) == "function" then
			tabModule.Init(ctx)
		end
	end)
	if not ok then
		warn("[ModularHub] tab '" .. name .. "' error: " .. tostring(err))
	end
end