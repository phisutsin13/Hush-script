-- src/core/ui.lua — ไลบรารี GUI (หน้าต่าง, แท็บ, Toggle, Slider, Button, Label)
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local UI = {}
UI.__index = UI

local WIDTH, HEIGHT, HEADER_H, SIDEBAR_W = 470, 320, 36, 110

local THEME = {
	Bg = Color3.fromRGB(18, 18, 22),
	Header = Color3.fromRGB(26, 26, 32),
	Sidebar = Color3.fromRGB(22, 22, 27),
	Element = Color3.fromRGB(30, 30, 37),
	Accent = Color3.fromRGB(88, 140, 255),
	Off = Color3.fromRGB(55, 55, 66),
	Text = Color3.fromRGB(235, 235, 240),
	SubText = Color3.fromRGB(150, 150, 165),
	Danger = Color3.fromRGB(235, 80, 80),
}

local TWEEN_FAST = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local function tween(obj, props, info)
	local t = TweenService:Create(obj, info or TWEEN_FAST, props)
	t:Play()
	return t
end

local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end

local function newLabel(parent, text, size, color, font)
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextSize = size or 13
	l.TextColor3 = color or THEME.Text
	l.Font = font or Enum.Font.GothamMedium
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end

-- เลือกที่วาง GUI: gethui > CoreGui > PlayerGui
local function getGuiParent()
	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and hui then return hui end
	if pcall(function() return #CoreGui:GetChildren() end) then return CoreGui end
	return Players.LocalPlayer:WaitForChild("PlayerGui")
end

function UI:_connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(self._conns, c)
	return c
end

function UI.new(opts)
	opts = opts or {}
	local self = setmetatable({}, UI)
	self._conns, self._pages, self._tabButtons = {}, {}, {}
	self._minimized, self._destroyed = false, false
	self.OnClose = opts.OnClose

	local parent = getGuiParent()
	-- ลบ GUI เก่าที่ค้างอยู่ (กันซ้อน)
	for _, p in ipairs({parent, Players.LocalPlayer:WaitForChild("PlayerGui")}) do
		local old = p:FindFirstChild("ModularHubGui")
		if old then old:Destroy() end
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "ModularHubGui"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 999
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = parent
	self._gui = gui

	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.fromOffset(WIDTH, 0) -- เริ่มที่ 0 แล้ว tween เปิด
	main.Position = UDim2.new(0.5, -WIDTH / 2, 0.5, -HEIGHT / 2)
	main.BackgroundColor3 = THEME.Bg
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Parent = gui
	corner(main, 10)
	self._main = main

	-- ===== Header =====
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, HEADER_H)
	header.BackgroundColor3 = THEME.Header
	header.BorderSizePixel = 0
	header.Parent = main

	local title = newLabel(header, opts.Title or "Hub", 14, THEME.Text, Enum.Font.GothamBold)
	title.Position = UDim2.fromOffset(14, 0)
	title.Size = UDim2.new(1, -90, 1, 0)

	local function headerButton(text, offsetX)
		local b = Instance.new("TextButton")
		b.Size = UDim2.fromOffset(28, 24)
		b.AnchorPoint = Vector2.new(1, 0.5)
		b.Position = UDim2.new(1, offsetX, 0.5, 0)
		b.BackgroundColor3 = THEME.Element
		b.Text = text
		b.TextColor3 = THEME.Text
		b.TextSize = 14
		b.Font = Enum.Font.GothamBold
		b.AutoButtonColor = false
		b.Parent = header
		corner(b, 6)
		return b
	end
	local closeBtn = headerButton("X", -8)
	local minBtn = headerButton("-", -42)

	for btn, hover in pairs({[closeBtn] = THEME.Danger, [minBtn] = THEME.Accent}) do
		btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = hover}) end)
		btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = THEME.Element}) end)
	end

	-- ลากหน้าต่างจาก header (รองรับเมาส์และมือถือ)
	local dragging, dragStart, startPos = false, nil, nil
	self:_connect(header.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging, dragStart, startPos = true, input.Position, main.Position
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
				startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	-- Minimize: tween ความสูงเหลือแค่ header (ClipsDescendants ซ่อนส่วนที่เหลือ)
	minBtn.Activated:Connect(function()
		self._minimized = not self._minimized
		minBtn.Text = self._minimized and "+" or "-"
		tween(main, {Size = UDim2.fromOffset(WIDTH, self._minimized and HEADER_H or HEIGHT)}, TWEEN_SMOOTH)
	end)

	-- Close: ให้ main จัดการ teardown ทั้งหมด
	closeBtn.Activated:Connect(function()
		if self.OnClose then self.OnClose() else self:Destroy() end
	end)

	-- ===== Body =====
	local body = Instance.new("Frame")
	body.Position = UDim2.fromOffset(0, HEADER_H)
	body.Size = UDim2.new(1, 0, 0, HEIGHT - HEADER_H)
	body.BackgroundTransparency = 1
	body.Parent = main

	local sidebar = Instance.new("Frame")
	sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, 0)
	sidebar.BackgroundColor3 = THEME.Sidebar
	sidebar.BorderSizePixel = 0
	sidebar.Parent = body
	local sl = Instance.new("UIListLayout")
	sl.Padding = UDim.new(0, 4)
	sl.Parent = sidebar
	local sp = Instance.new("UIPadding")
	sp.PaddingTop, sp.PaddingLeft, sp.PaddingRight = UDim.new(0, 8), UDim.new(0, 8), UDim.new(0, 8)
	sp.Parent = sidebar
	self._sidebar = sidebar

	local content = Instance.new("Frame")
	content.Position = UDim2.fromOffset(SIDEBAR_W, 0)
	content.Size = UDim2.new(1, -SIDEBAR_W, 1, 0)
	content.BackgroundTransparency = 1
	content.Parent = body
	self._content = content

	-- คีย์ลัดซ่อน/แสดง UI
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
	self:_connect(UserInputService.InputBegan, function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			gui.Enabled = not gui.Enabled
		end
	end)

	tween(main, {Size = UDim2.fromOffset(WIDTH, HEIGHT)}, TWEEN_SMOOTH) -- เปิดแบบนุ่มนวล
	return self
end

-- ========== Tabs ==========
function UI:AddTab(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 30)
	btn.BackgroundColor3 = THEME.Element
	btn.BackgroundTransparency = 1
	btn.Text = name
	btn.TextColor3 = THEME.SubText
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamMedium
	btn.AutoButtonColor = false
	btn.Parent = self._sidebar
	corner(btn, 6)

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.fromScale(1, 1)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 3
	page.CanvasSize = UDim2.new()
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false
	page.Parent = self._content
	local pl = Instance.new("UIListLayout")
	pl.Padding = UDim.new(0, 6)
	pl.Parent = page
	local pp = Instance.new("UIPadding")
	pp.PaddingTop, pp.PaddingLeft = UDim.new(0, 8), UDim.new(0, 8)
	pp.PaddingRight, pp.PaddingBottom = UDim.new(0, 12), UDim.new(0, 8)
	pp.Parent = page

	self._pages[name] = page
	self._tabButtons[name] = btn
	btn.Activated:Connect(function() self:SelectTab(name) end)
	if not self._current then self:SelectTab(name) end
	return page
end

function UI:SelectTab(name)
	self._current = name
	for n, page in pairs(self._pages) do
		local active = (n == name)
		page.Visible = active
		local b = self._tabButtons[n]
		tween(b, {
			BackgroundTransparency = active and 0 or 1,
			TextColor3 = active and THEME.Accent or THEME.SubText,
		})
	end
end

local function makeRow(page, height)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, height)
	row.BackgroundColor3 = THEME.Element
	row.BorderSizePixel = 0
	row.Parent = page
	corner(row, 8)
	return row
end

-- ========== Elements ==========
function UI:AddToggle(tab, text, default, callback)
	local row = makeRow(self._pages[tab], 34)
	local label = newLabel(row, text, 13)
	label.Position = UDim2.fromOffset(12, 0)
	label.Size = UDim2.new(1, -70, 1, 0)

	local sw = Instance.new("Frame")
	sw.Size = UDim2.fromOffset(38, 18)
	sw.AnchorPoint = Vector2.new(1, 0.5)
	sw.Position = UDim2.new(1, -10, 0.5, 0)
	sw.BackgroundColor3 = THEME.Off
	sw.BorderSizePixel = 0
	sw.Parent = row
	corner(sw, 9)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(14, 14)
	knob.Position = UDim2.new(0, 2, 0.5, -7)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.Parent = sw
	corner(knob, 7)

	local hit = Instance.new("TextButton")
	hit.Size = UDim2.fromScale(1, 1)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.Parent = row

	local state = false
	local function set(v, silent)
		state = v and true or false
		tween(sw, {BackgroundColor3 = state and THEME.Accent or THEME.Off})
		tween(knob, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
		if not silent and callback then task.spawn(callback, state) end
	end
	set(default, true)
	hit.Activated:Connect(function() set(not state) end)

	return {Set = set, Get = function() return state end}
end

function UI:AddSlider(tab, text, min, max, default, callback, step)
	step = step or 1
	local row = makeRow(self._pages[tab], 48)

	local label = newLabel(row, text, 13)
	label.Position = UDim2.fromOffset(12, 5)
	label.Size = UDim2.new(1, -90, 0, 18)

	local valueLabel = newLabel(row, "", 12, THEME.SubText)
	valueLabel.AnchorPoint = Vector2.new(1, 0)
	valueLabel.Position = UDim2.new(1, -12, 0, 5)
	valueLabel.Size = UDim2.fromOffset(70, 18)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local bar = Instance.new("Frame")
	bar.Position = UDim2.new(0, 12, 0, 33)
	bar.Size = UDim2.new(1, -24, 0, 6)
	bar.BackgroundColor3 = THEME.Off
	bar.BorderSizePixel = 0
	bar.Parent = row
	corner(bar, 3)

	local fill = Instance.new("Frame")
	fill.BackgroundColor3 = THEME.Accent
	fill.BorderSizePixel = 0
	fill.Parent = bar
	corner(fill, 3)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.fromOffset(12, 12)
	knob.AnchorPoint = Vector2.new(0.5, 0.5)
	knob.BackgroundColor3 = Color3.new(1, 1, 1)
	knob.BorderSizePixel = 0
	knob.ZIndex = 2
	knob.Parent = bar
	corner(knob, 6)

	-- พื้นที่คลิกที่ใหญ่กว่าแถบ เพื่อให้จับง่าย
	local hit = Instance.new("Frame")
	hit.Position = UDim2.new(0, 0, 0, 24)
	hit.Size = UDim2.new(1, 0, 0, 24)
	hit.BackgroundTransparency = 1
	hit.Parent = row

	local value = default
	local function setValue(v, silent)
		v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
		if v == value and silent ~= true and fill.Size.X.Scale > 0 then return end
		value = v
		local a = (v - min) / (max - min)
		fill.Size = UDim2.new(a, 0, 1, 0)
		knob.Position = UDim2.new(a, 0, 0.5, 0)
		valueLabel.Text = tostring(math.round(v * 100) / 100)
		if not silent and callback then task.spawn(callback, v) end
	end
	setValue(default, true)

	local sliding = false
	local function fromX(x)
		local w = bar.AbsoluteSize.X
		if w <= 0 then return end
		local a = math.clamp((x - bar.AbsolutePosition.X) / w, 0, 1)
		setValue(min + a * (max - min))
	end

	self:_connect(hit.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			sliding = true
			fromX(input.Position.X)
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			fromX(input.Position.X)
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			sliding = false
		end
	end)

	return {Set = setValue, Get = function() return value end}
end

function UI:AddButton(tab, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 32)
	btn.BackgroundColor3 = THEME.Element
	btn.Text = text
	btn.TextColor3 = THEME.Text
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamMedium
	btn.AutoButtonColor = false
	btn.Parent = self._pages[tab]
	corner(btn, 8)
	btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = THEME.Accent}) end)
	btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = THEME.Element}) end)
	btn.Activated:Connect(function()
		if callback then task.spawn(callback) end
	end)
	return btn
end

function UI:AddLabel(tab, text)
	local l = newLabel(self._pages[tab], text, 12, THEME.SubText)
	l.Size = UDim2.new(1, 0, 0, 22)
	l.TextWrapped = true
	return {SetText = function(t) l.Text = t end}
end

-- ปิดการเชื่อมต่อทั้งหมด + เล่นแอนิเมชันปิด แล้วทำลาย GUI
function UI:Destroy()
	if self._destroyed then return end
	self._destroyed = true
	for _, c in ipairs(self._conns) do c:Disconnect() end
	table.clear(self._conns)
	if self._main and self._main.Parent then
		tween(self._main, {Size = UDim2.fromOffset(WIDTH, 0)}, TweenInfo.new(0.2))
	end
	task.delay(0.22, function()
		if self._gui then self._gui:Destroy() end
	end)
end

return UI
