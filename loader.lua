local USER   = "phisutsin13"
local REPO   = "Hush-script"
local BRANCH = "main"

local ROOT = ("https://raw.githubusercontent.com/%s/%s/%s/"):format(USER, REPO, BRANCH)
local cache = {}

local function import(path)
	path = path:gsub("^%./", "")
	if cache[path] ~= nil then return cache[path] end

	local url
	if path == "init" or path == "init.lua" then
		url = ROOT .. "init.lua"
	else
		if not path:find("%.lua$") then path = path .. ".lua" end
		if not path:find("^src/") then path = "src/" .. path end
		url = ROOT .. "hush/" .. path
	end
	url = url .. "?t=" .. os.time()
	print("[import] " .. url)

	local ok, src = pcall(game.HttpGet, game, url)
	if not ok then error("[loader] โหลด " .. path .. " ไม่ได้: " .. tostring(src)) end
	if src:sub(1, 3) == "404" then error("[loader] 404: " .. url) end

	local fn, err = loadstring("local import = ...; " .. src, "=" .. path)
	if not fn then error("[loader] syntax error ใน " .. path .. ": " .. tostring(err)) end

	local result = fn(import)
	if result == nil then result = true end
	cache[path] = result
	return result
end

return import("init")