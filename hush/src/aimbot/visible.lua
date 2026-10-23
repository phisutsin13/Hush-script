-- src/aimbot/visible.lua — เช็คว่ามีสิ่งกีดขวางระหว่าง origin กับหัวเป้าหมายไหม
local localPlayer = game:GetService("Players").LocalPlayer

return function(origin, head)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {localPlayer.Character}
	params.IgnoreWater = true
	local result = workspace:Raycast(origin, head.Position - origin, params)
	return result == nil or result.Instance:IsDescendantOf(head.Parent)
end
