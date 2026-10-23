local USER   = "phisutsin13"
local REPO   = "Hush-script"
local BRANCH = "main"

-- แก้ไขให้ BASE ชี้มาหยุดแค่ที่โฟลเดอร์ hush/ เท่านั้น
local BASE = ("https://raw.githubusercontent.com/%s/%s/%s/hush/"):format(USER, REPO, BRANCH)
local cache = {}

local function import(path)
	path = path:gsub("^%./", "")

	if cache[path] ~= nil then return cache[path] end

	-- เช็กเส้นทาง: ถ้าเป็น init ให้ดึงจากโฟลเดอร์ hush/ โดยตรง แต่ถ้าเป็นตัวอื่นให้เข้า src/
	local url
	if path == "init" then
		url = BASE .. "init.lua?t=" .. os.time()
	else
		url = BASE .. "src/" .. path .. ".lua?t=" .. os.time()
	end

	local ok, src = pcall(game.HttpGet, game, url)
	if not ok then error("[loader] โหลด " .. path .. " ไม่ได้: " .. tostring(src)) end

	local fn, err = loadstring("local import = ...; " .. src, "=" .. path)
	if not fn then error("[loader] syntax error ใน " .. path .. ": " .. tostring(err)) end

	local result = fn(import)
	if result == nil then result = true end
	cache[path] = result
	return result
end

return import("init")