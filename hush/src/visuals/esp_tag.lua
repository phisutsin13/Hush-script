-- src/visuals/esp_tag.lua — สร้างป้ายชื่อ+ระยะ (BillboardGui ขนาดเล็ก) เหนือหัว
return function(folder, plr, head)
	local gui = Instance.new("BillboardGui")
	gui.Name = plr.Name
	gui.Adornee = head
	gui.AlwaysOnTop = true
	gui.Size = UDim2.fromOffset(120, 16)
	gui.StudsOffset = Vector3.new(0, 2.2, 0)
	gui.Parent = folder

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.TextColor3 = Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0.4
	label.Parent = gui

	return {Gui = gui, Label = label, Head = head, LastDist = -1}
end
