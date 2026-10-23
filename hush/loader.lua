-- loader.lua — ตัวโหลดหลัก (ไม่ต้องใช้ Node.js / build)
-- require("aimbot/target") = โหลดไฟล์ src/aimbot/target.lua จาก GitHub

-- *** แก้ค่าเหล่านี้เป็นของคุณ ***
local USER   = "ชื่อGitHubของคุณ"
local REPO   = "ModularHub"
local BRANCH = "main"

local BASE = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(USER, REPO, BRANCH)
local cache = {}

local function req(path)
	if cache[path] ~= nil then return cache[path] end

	local ok, src = pcall(game.HttpGet, game, BASE .. "src/" .. path .. ".lua?t=" .. os.time())
	if not ok then error("[loader] โหลด src/" .. path .. ".lua ไม่ได้: " .. tostring(src)) end

	-- ใส่ require ของเราบรรทัดเดียวกัน → เลขบรรทัด error ตรงกับไฟล์จริง
	local fn, err = loadstring("local require = ...; " .. src, "=" .. path)
	if not fn then error("[loader] syntax error ใน " .. path .. ": " .. tostring(err)) end

	local result = fn(req)
	if result == nil then result = true end
	cache[path] = result
	return result
end

return req("init")
