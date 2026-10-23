local USER   = "phisutsin13"
local REPO   = "Hush-script"
local BRANCH = "main"

local BASE = ("https://raw.githubusercontent.com/%s/%s/%s/hush/"):format(USER, REPO, BRANCH)
local cache = {}

local function req(path)
	-- รองรับกรณีที่มีคนเผลอใส่ ./ นำหน้า เช่น require("./core/janitor")
	path = path:gsub("^%./", "")

	if cache[path] ~= nil then return cache[path] end

	local ok, src = pcall(game.HttpGet, game, BASE .. "src/" .. path .. ".lua?t=" .. os.time())
	if not ok then error("[loader] โหลด src/" .. path .. ".lua ไม่ได้: " .. tostring(src)) end

	-- โหลดโค้ดเข้ามาโดยไม่ต้องส่ง parameter ผ่าน loadstring แบบเดิม
	local fn, err = loadstring(src, "=" .. path)
	if not fn then error("[loader] syntax error ใน " .. path .. ": " .. tostring(err)) end

	-- ใช้ setfenv ล็อกสเปซให้คำสั่ง require ในไฟล์นี้วิ่งมาหาฟังก์ชัน req ของเราโดยตรง 100%
	setfenv(fn, setmetatable({ require = req }, { __index = getfenv() }))

	local result = fn()
	if result == nil then result = true end
	cache[path] = result
	return result
end

return req("init")