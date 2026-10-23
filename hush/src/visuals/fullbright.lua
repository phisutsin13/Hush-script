-- src/visuals/fullbright.lua — Fullbright: เซฟค่า Lighting เดิม และคืนค่าเมื่อปิด/unload
local Lighting = game:GetService("Lighting")

local FULLBRIGHT = {
	Brightness = 2,
	ClockTime = 14,
	GlobalShadows = false,
	Ambient = Color3.fromRGB(200, 200, 200),
}
local PROPS = {"Brightness", "ClockTime", "GlobalShadows", "Ambient"}

return function(ctx)
	local active, original, conns = false, nil, {}
	local api = {}

	function api.Set(state)
		if state == active then return end
		active = state
		if state then
			original = {}
			for _, p in ipairs(PROPS) do original[p] = Lighting[p] end
			for _, p in ipairs(PROPS) do
				Lighting[p] = FULLBRIGHT[p]
				-- ถ้าเกมเปลี่ยนค่ากลับ ให้บังคับกลับเป็น Fullbright
				table.insert(conns, Lighting:GetPropertyChangedSignal(p):Connect(function()
					if active and Lighting[p] ~= FULLBRIGHT[p] then Lighting[p] = FULLBRIGHT[p] end
				end))
			end
		else
			for _, c in ipairs(conns) do c:Disconnect() end
			table.clear(conns)
			if original then
				for _, p in ipairs(PROPS) do Lighting[p] = original[p] end
				original = nil
			end
		end
	end

	ctx.Janitor:Add(function() api.Set(false) end) -- unload → คืนค่า Lighting เดิม
	return api
end
