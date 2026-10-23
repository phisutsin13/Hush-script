local USER   = "phisutsin13"
local REPO   = "Hush-script"
local BRANCH = "main"

local BASE = ("https://raw.githubusercontent.com/phisutsin13/Hush-script/refs/heads/main/hush/src/init.lua"):format(USER, REPO, BRANCH)
local cache = {}

local function req(path)
	if cache[path] ~= nil then return cache[path] end

	local ok, src = pcall(game.HttpGet, game, BASE .. "src/" .. path .. ".lua?t=" .. os.time())
	if not ok then error("[loader] โหลด src/" .. path .. ".lua ไม่ได้: " .. tostring(src)) end

	
	local fn, err = loadstring("local require = ...; " .. src, "=" .. path)
	if not fn then error("[loader] syntax error ใน " .. path .. ": " .. tostring(err)) end

	local result = fn(req)
	if result == nil then result = true end
	cache[path] = result
	return result
end

return req("init")
