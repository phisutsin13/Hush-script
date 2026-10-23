local USER   = "phisutsin13"
local REPO   = "Hush-script"
local BRANCH = "main"

local BASE = ("https://raw.githubusercontent.com/%s/%s/%s/hush/"):format(USER, REPO, BRANCH)
local cache = {}

local function import(path)
	path = path:gsub("^%./", "")

	if cache[path] ~= nil then return cache[path] end

	-- เนื่องจาก init.lua และไฟล์อื่นๆ อยู่ใน src/ ให้ดึงผ่านเส้นทาง src/ ทั้งหมด
	local url = BASE .. "src/" .. path .. ".lua?t=" .. os.time()

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