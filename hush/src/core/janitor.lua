-- src/core/janitor.lua — เก็บ connection/Instance/function ไว้ล้างทีเดียวตอน unload
local Janitor = {}
Janitor.__index = Janitor

function Janitor.new() return setmetatable({_items = {}}, Janitor) end

function Janitor:Add(item)
	table.insert(self._items, item)
	return item
end

function Janitor:Cleanup()
	for i = #self._items, 1, -1 do -- ย้อนหลัง (ใส่ทีหลัง ล้างก่อน)
		local item = self._items[i]
		local t = typeof(item)
		pcall(function()
			if t == "RBXScriptConnection" then item:Disconnect()
			elseif t == "Instance" then item:Destroy()
			elseif t == "function" then item()
			elseif t == "table" and item.Destroy then item:Destroy() end
		end)
	end
	table.clear(self._items)
end

return Janitor
