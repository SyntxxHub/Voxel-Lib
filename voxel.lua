
-- Voxel UI Library (Glossy Blue-Gray Theme) - Injection-ready single-file
-- Features:
--  * Vertical left tabs, top header bar, glossy panel content area (matches provided reference)
--  * Button, Label, Slider, Toggle, Dropdown components (functional)
--  * Draggable window, RightControl toggle, injector-safe parenting (gethui / PlayerGui / CoreGui)
--  * Single-file ready for executors

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local Library = {}

-- Helper: validate options
function Library:validate(default, options)
	local options = options or {}
	for i, v in pairs(default) do
		if options[i] == nil then options[i] = v end
	end
	return options
end

-- Tween wrapper
function Library:tween(object, goal, callback)
	pcall(function()
		local tw = TweenService:Create(object, tweenInfo, goal)
		if callback then tw.Completed:Connect(callback) end
		tw:Play()
	end)
end

-- Injector parenting helper: tries gethui, get_hidden_gui, PlayerGui, CoreGui
local function chooseParent(gui)
	local tried = {}

	if type(gethui) == "function" then
		pcall(function() table.insert(tried, gethui()) end)
	end
	if type(get_hidden_gui) == "function" then
		pcall(function() table.insert(tried, get_hidden_gui()) end)
	end
	pcall(function()
		local plr = Players.LocalPlayer
		if plr then
			local pg = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui", 1)
			if pg then table.insert(tried, pg) end
		end
	end)
	table.insert(tried, CoreGui)

	for _, cand in ipairs(tried) do
		if cand and typeof(cand) == "Instance" then
			local ok = pcall(function() gui.Parent = cand end)
			if ok then
				pcall(function() gui.ResetOnSpawn = false end)
				pcall(function() gui.Enabled = true end)
				return true
			end
		end
	end
	-- final attempt set to PlayerGui
	local ok, _ = pcall(function() gui.Parent = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui") end)
	return ok
end

-- Build the UI
function Library:Init(options)
	options = options or {}
	options = Library:validate({ name = "VOXEL.GG" }, options)

	local GUI = {
		Visible = true,
		CurrentTab = nil,
		_components = {}
	}

	-- ScreenGui
	GUI.ScreenGui = Instance.new("ScreenGui")
	GUI.ScreenGui.Name = "Voxel.UI"
	GUI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	GUI.ScreenGui.IgnoreGuiInset = true
	pcall(function() GUI.ScreenGui.ResetOnSpawn = false end)
	pcall(function() GUI.ScreenGui.Enabled = true end)

	-- Parent robustly (for injectors)
	local ok = chooseParent(GUI.ScreenGui)
	if not ok then
		for i=1,3 do
			wait(0.05)
			if chooseParent(GUI.ScreenGui) then break end
		end
	end

	-- Main container (centered)
	GUI.Main = Instance.new("Frame")
	GUI.Main.Name = "Main"
	GUI.Main.Size = UDim2.new(0, 520, 0, 340)
	GUI.Main.Position = UDim2.new(0.5, -260, 0.5, -170)
	GUI.Main.BackgroundColor3 = Color3.fromRGB(22, 26, 31) -- base panel
	GUI.Main.BorderSizePixel = 0
	GUI.Main.Parent = GUI.ScreenGui
	pcall(function() local c = Instance.new("UICorner", GUI.Main); c.CornerRadius = UDim.new(0, 8) end)

	-- subtle outer stroke (frame behind to create border)
	local outer = Instance.new("Frame", GUI.Main)
	outer.Name = "OuterStroke"
	outer.Size = UDim2.new(1,0,1,0)
	outer.Position = UDim2.new(0,0,0,0)
	outer.BackgroundTransparency = 1
	outer.BorderSizePixel = 0
	outer.ZIndex = 0
	-- inner glossy overlay
	local overlay = Instance.new("Frame", GUI.Main)
	overlay.Name = "Overlay"
	overlay.Size = UDim2.new(1, -10, 1, -10)
	overlay.Position = UDim2.new(0, 5, 0, 5)
	overlay.BackgroundTransparency = 0.85
	overlay.BackgroundColor3 = Color3.fromRGB(18, 22, 26)
	overlay.BorderSizePixel = 0
	overlay.ZIndex = 1
	pcall(function() Instance.new("UICorner", overlay).CornerRadius = UDim.new(0,6) end)

	-- left tabs column
	local left = Instance.new("Frame", GUI.Main)
	left.Name = "Left"
	left.Size = UDim2.new(0, 120, 1, 0)
	left.Position = UDim2.new(0, 0, 0, 0)
	left.BackgroundTransparency = 0.9
	left.BorderSizePixel = 0
	left.ZIndex = 2
	pcall(function() Instance.new("UICorner", left).CornerRadius = UDim.new(0,6) end)
	local leftGrad = Instance.new("UIGradient", left)
	leftGrad.Rotation = -10
	leftGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20,24,30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(25,30,36))
	}

	local leftInner = Instance.new("Frame", left)
	leftInner.Size = UDim2.new(1, 0, 1, 0)
	leftInner.BackgroundTransparency = 1
	leftInner.BorderSizePixel = 0

	local leftList = Instance.new("UIListLayout", leftInner)
	leftList.Padding = UDim.new(0,6)
	leftList.SortOrder = Enum.SortOrder.LayoutOrder
	leftList.VerticalAlignment = Enum.VerticalAlignment.Top

	-- top header row (tabs like first image)
	local topBar = Instance.new("Frame", GUI.Main)
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, -120, 0, 46)
	topBar.Position = UDim2.new(0, 120, 0, 0)
	topBar.BackgroundTransparency = 1
	topBar.BorderSizePixel = 0
	topBar.ZIndex = 3

	-- header tab container (inside topBar)
	local headerTabs = Instance.new("Frame", topBar)
	headerTabs.Size = UDim2.new(1, -20, 1, -10)
	headerTabs.Position = UDim2.new(0, 10, 0, 6)
	headerTabs.BackgroundTransparency = 1
	headerTabs.BorderSizePixel = 0

	local headerLayout = Instance.new("UIListLayout", headerTabs)
	headerLayout.FillDirection = Enum.FillDirection.Horizontal
	headerLayout.Padding = UDim.new(0, 8)
	headerLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- content area (right)
	local content = Instance.new("Frame", GUI.Main)
	content.Name = "Content"
	content.Size = UDim2.new(1, -120, 1, -46)
	content.Position = UDim2.new(0, 120, 0, 46)
	content.BackgroundTransparency = 1
	content.BorderSizePixel = 0
	content.ZIndex = 3

	-- content inner frame with stroke and gradient (glassy)
	local contentInner = Instance.new("Frame", content)
	contentInner.Name = "ContentInner"
	contentInner.Size = UDim2.new(1, -20, 1, -20)
	contentInner.Position = UDim2.new(0, 10, 0, 10)
	contentInner.BackgroundColor3 = Color3.fromRGB(18, 23, 28)
	contentInner.BorderSizePixel = 0
	contentInner.ZIndex = 4
	pcall(function() Instance.new("UICorner", contentInner).CornerRadius = UDim.new(0,6) end)
	local contentGrad = Instance.new("UIGradient", contentInner)
	contentGrad.Rotation = 10
	contentGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(22,28,34)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(17,21,26))
	}
	local contentStroke = Instance.new("UIStroke", contentInner)
	contentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	contentStroke.Color = Color3.fromRGB(60,80,95)
	contentStroke.Thickness = 1

-- layout inside contentInner
local contentList = Instance.new("UIListLayout", contentInner)
contentList.Padding = UDim.new(0,10)
contentList.FillDirection = Enum.FillDirection.Vertical
contentList.SortOrder = Enum.SortOrder.LayoutOrder
contentList.HorizontalAlignment = Enum.HorizontalAlignment.Left

-- utility to create header tabs (top)
local function createHeaderTab(text)
	local h = Instance.new("TextButton", headerTabs)
	h.AutoButtonColor = false
	h.BackgroundTransparency = 1
	h.Size = UDim2.new(0, 140, 1, 0)
	h.Text = ""
	local label = Instance.new("TextLabel", h)
	label.Size = UDim2.new(1, -8, 1, 0)
	label.Position = UDim2.new(0,4,0,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.SourceSansItalic
	label.TextColor3 = Color3.fromRGB(136,154,170)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = true
	return h, label
end

-- utility to create left tab buttons
local function createLeftTab(name)
	local btn = Instance.new("TextButton", leftInner)
	btn.Size = UDim2.new(1, -12, 0, 36)
	btn.BackgroundTransparency = 1
	btn.AutoButtonColor = false
	btn.BorderSizePixel = 0
	btn.Text = ""
	local overlay = Instance.new("Frame", btn)
	overlay.Size = UDim2.new(1,0,1,0)
	overlay.BackgroundColor3 = Color3.fromRGB(23,28,35)
	overlay.BackgroundTransparency = 0.9
	overlay.BorderSizePixel = 0
	pcall(function() Instance.new("UICorner", overlay).CornerRadius = UDim.new(0,6) end)
	local label = Instance.new("TextLabel", btn)
	label.Size = UDim2.new(1, -12, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = name
	label.Font = Enum.Font.SourceSansBold
	label.TextColor3 = Color3.fromRGB(130,145,160)
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextScaled = true
	return btn, label, overlay
end

-- Simple internal tab system mapping
GUI._tabObjects = {}
GUI._headerObjects = {}

function GUI:CreateTab(options)
	options = Library:validate({ name = "Tab" }, options or {})
	local tabName = options.name

	-- left tab
	local leftBtn, leftLabel, leftOverlay = createLeftTab(tabName)
	-- header top tab (simple)
	local topBtn, topLabel = createHeaderTab(tabName)

	-- content frame inside contentInner
	local tabFrame = Instance.new("Frame", contentInner)
	tabFrame.Size = UDim2.new(1, -10, 1, -10)
	tabFrame.BackgroundTransparency = 1
	tabFrame.Visible = false

	local tabLayout = Instance.new("UIListLayout", tabFrame)
	tabLayout.Padding = UDim.new(0,8)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder

	local tabObj = {
		LeftButton = leftBtn,
		LeftLabel = leftLabel,
		LeftOverlay = leftOverlay,
		TopButton = topBtn,
		TopLabel = topLabel,
		Frame = tabFrame,
		_active = false,
		_components = {}
	}

	-- activation logic
	local function activate()
		-- deactivate others
		for _, t in pairs(GUI._tabObjects) do
			if t ~= tabObj and t._active then
				t:Deactivate()
			end
		end
		tabObj._active = true
		tabFrame.Visible = true
		-- visual highlight left
		pcall(function() Library:tween(leftOverlay, {BackgroundTransparency = 0.0}) end)
		leftLabel.TextColor3 = Color3.fromRGB(210,225,240)
		topLabel.TextColor3 = Color3.fromRGB(210,225,240)
		GUI.CurrentTab = tabObj
	end

	function tabObj:Deactivate()
		tabObj._active = false
		tabFrame.Visible = false
		pcall(function() Library:tween(leftOverlay, {BackgroundTransparency = 0.9}) end)
		leftLabel.TextColor3 = Color3.fromRGB(130,145,160)
		topLabel.TextColor3 = Color3.fromRGB(136,154,170)
	end

	-- events: clicking left or top toggles active
	leftBtn.MouseButton1Click:Connect(function() activate() end)
	topBtn.MouseButton1Click:Connect(function() activate() end)

	-- default active if first
	if #GUI._tabObjects == 0 then
		activate()
	end

	-- API: add components to tab
	function tabObj:Label(options)
		options = Library:validate({ name = "Label" }, options or {})
		local frame = Instance.new("Frame", tabFrame)
		frame.Size = UDim2.new(1, -20, 0, 34)
		frame.BackgroundTransparency = 1
		local text = Instance.new("TextLabel", frame)
		text.Size = UDim2.new(1,0,1,0)
		text.BackgroundTransparency = 1
		text.Text = options.name
		text.Font = Enum.Font.SourceSansItalic
		text.TextColor3 = Color3.fromRGB(180,195,205)
		text.TextXAlignment = Enum.TextXAlignment.Left
		text.TextScaled = true
		table.insert(tabObj._components, frame)
		return {
			SetText = function(self, v) text.Text = v end,
			Destroy = function(self) if frame and frame.Parent then frame:Destroy() end
		}
	end

	function tabObj:Button(options)
		options = Library:validate({ name = "Button", callback = function() end }, options or {})
		local frame = Instance.new("Frame", tabFrame)
		frame.Size = UDim2.new(1, -20, 0, 36)
		frame.BackgroundTransparency = 1
		local btn = Instance.new("TextButton", frame)
		btn.Size = UDim2.new(1,0,1,0)
		btn.BackgroundColor3 = Color3.fromRGB(28,34,42)
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		pcall(function() Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6) end)
		local grad = Instance.new("UIGradient", btn)
		grad.Rotation = 10
		grad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(35,44,53)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(20,26,33))
		}
		local stroke = Instance.new("UIStroke", btn)
		stroke.Color = Color3.fromRGB(70,95,120)
		stroke.Thickness = 1

		local label = Instance.new("TextLabel", btn)
		label.Size = UDim2.new(1,-12,1,0)
		label.Position = UDim2.new(0,8,0,0)
		label.BackgroundTransparency = 1
		label.Text = options.name
		label.Font = Enum.Font.SourceSansBold
		label.TextColor3 = Color3.fromRGB(200,215,230)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextScaled = true

		btn.MouseEnter:Connect(function()
			pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(100,140,170)}) end)
			pcall(function() Library:tween(label, {TextColor3 = Color3.fromRGB(230,245,255)}) end)
		end)
		btn.MouseLeave:Connect(function()
			pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(70,95,120)}) end)
			pcall(function() Library:tween(label, {TextColor3 = Color3.fromRGB(200,215,230)}) end)
		end)
		btn.MouseButton1Click:Connect(function() pcall(function() options.callback() end) end)

		table.insert(tabObj._components, frame)
		return {
			SetText = function(self, v) label.Text = v end,
			OnClick = function(self, fn) options.callback = fn end,
			Destroy = function(self) if frame and frame.Parent then frame:Destroy() end
		}
	end

	function tabObj:Slider(options)
		options = Library:validate({ title = "Slider", min = 0, max = 100, default = 50, callback = function() end }, options or {})
		local frame = Instance.new("Frame", tabFrame)
		frame.Size = UDim2.new(1, -20, 0, 64)
		frame.BackgroundTransparency = 1

		local title = Instance.new("TextLabel", frame)
		title.Position = UDim2.new(0, 8, 0, 0)
		title.Size = UDim2.new(0.7, -8, 0, 20)
		title.BackgroundTransparency = 1
		title.Text = options.title
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Font = Enum.Font.SourceSansItalic
		title.TextColor3 = Color3.fromRGB(190,205,215)
		title.TextScaled = true

		local valueText = Instance.new("TextLabel", frame)
		valueText.Size = UDim2.new(0.2, -8, 0, 20)
		valueText.Position = UDim2.new(0.8, 0, 0, 0)
		valueText.BackgroundTransparency = 1
		valueText.Text = tostring(options.default)
		valueText.TextScaled = true
		valueText.Font = Enum.Font.SourceSansBold
		valueText.TextColor3 = Color3.fromRGB(200,215,230)
		valueText.TextXAlignment = Enum.TextXAlignment.Right

		local back = Instance.new("Frame", frame)
		back.Position = UDim2.new(0,8,0,28)
		back.Size = UDim2.new(1, -16, 0, 12)
		back.BackgroundColor3 = Color3.fromRGB(32,38,44)
		back.BorderSizePixel = 0
		pcall(function() Instance.new("UICorner", back).CornerRadius = UDim.new(0,6) end)
		local backStroke = Instance.new("UIStroke", back)
		backStroke.Color = Color3.fromRGB(60,80,95)

		local fill = Instance.new("Frame", back)
		fill.Size = UDim2.new(0, 0, 1, 0)
		fill.Position = UDim2.new(0,0,0,0)
		fill.BackgroundColor3 = Color3.fromRGB(90,120,150)
		pcall(function() Instance.new("UICorner", fill).CornerRadius = UDim.new(0,6) end)
		local fillGrad = Instance.new("UIGradient", fill)
		fillGrad.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(140,170,200)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(80,110,140))
		}

		-- state
		local minv, maxv = options.min, options.max
		local cur = math.clamp(options.default, minv, maxv)
		local dragging = false

		local function updateFillFromValue(v)
			cur = math.clamp(v, minv, maxv)
			local fraction = (cur - minv) / math.max(1, (maxv - minv))
			local w = back.AbsoluteSize.X
			fill.Size = UDim2.new(0, math.floor(w * fraction), 1, 0)
			valueText.Text = tostring(math.floor(cur))
		end

		-- defer until sizes ready
		spawn(function()
			wait()
			pcall(function() updateFillFromValue(cur) end)
		end)

		-- input handling
		local connB = UIS.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local m = UIS:GetMouseLocation()
				local pos = back.AbsolutePosition
				local size = back.AbsoluteSize
				if m.X >= pos.X and m.X <= pos.X + size.X and m.Y >= pos.Y and m.Y <= pos.Y + size.Y then
					dragging = true
					local rel = math.clamp(m.X - pos.X, 0, size.X)
					local frac = rel / math.max(1, size.X)
					updateFillFromValue(minv + frac * (maxv - minv))
					pcall(function() options.callback(math.floor(cur)) end)
				end
			end
		end)
		local connE = UIS.InputEnded:Connect(function(input, gp)
			if gp then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if dragging then
					dragging = false
					pcall(function() options.callback(math.floor(cur)) end)
				end
			end
		end)
		local connM = UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local m = UIS:GetMouseLocation()
				local pos = back.AbsolutePosition
				local size = back.AbsoluteSize
				local rel = math.clamp(m.X - pos.X, 0, size.X)
				local frac = rel / math.max(1, size.X)
				updateFillFromValue(minv + frac * (maxv - minv))
				pcall(function() options.callback(math.floor(cur)) end)
			end
		end)

		table.insert(tabObj._components, frame)
		return {
			SetValue = function(self, v) updateFillFromValue(v) end,
			GetValue = function(self) return math.floor(cur) end,
			Destroy = function(self)
				if frame and frame.Parent then frame:Destroy() end
				if connB and connB.Disconnect then pcall(function() connB:Disconnect() end) end
				if connE and connE.Disconnect then pcall(function() connE:Disconnect() end) end
				if connM and connM.Disconnect then pcall(function() connM:Disconnect() end) end
			end
		}
	end

	function tabObj:Toggle(options)
		options = Library:validate({ title = "Toggle", default = false, callback = function() end }, options or {})
		local frame = Instance.new("Frame", tabFrame)
		frame.Size = UDim2.new(1, -20, 0, 38)
		frame.BackgroundTransparency = 1

		local title = Instance.new("TextLabel", frame)
		title.Size = UDim2.new(0.75, 0, 1, 0)
		title.Position = UDim2.new(0,8,0,0)
		title.BackgroundTransparency = 1
		title.Text = options.title
		title.Font = Enum.Font.SourceSansItalic
		title.TextColor3 = Color3.fromRGB(190,205,215)
		title.TextScaled = true
		title.TextXAlignment = Enum.TextXAlignment.Left

		local box = Instance.new("ImageButton", frame)
		box.Size = UDim2.new(0, 24, 0, 24)
		box.Position = UDim2.new(0.92, -24, 0.12, 0)
		box.BackgroundColor3 = Color3.fromRGB(36,42,50)
		box.BorderSizePixel = 0
		pcall(function() Instance.new("UICorner", box).CornerRadius = UDim.new(0,5) end)
		local boxStroke = Instance.new("UIStroke", box)
		boxStroke.Color = Color3.fromRGB(70,80,95)
		local check = Instance.new("Frame", box)
		check.Size = UDim2.new(1, -6, 1, -6)
		check.Position = UDim2.new(0,3,0,3)
		check.BackgroundColor3 = options.default and Color3.fromRGB(90,120,150) or Color3.fromRGB(40,46,53)
		pcall(function() Instance.new("UICorner", check).CornerRadius = UDim.new(0,4) end)

		local state = options.default

		box.MouseButton1Click:Connect(function()
			state = not state
			pcall(function()
				if state then
					Library:tween(check, {BackgroundColor3 = Color3.fromRGB(90,120,150)})
				else
					Library:tween(check, {BackgroundColor3 = Color3.fromRGB(40,46,53)})
				end
			end)
			pcall(function() options.callback(state) end)
		end)

		table.insert(tabObj._components, frame)
		return {
			Set = function(self, s)
				state = s and true or false
				pcall(function()
					if state then check.BackgroundColor3 = Color3.fromRGB(90,120,150) else check.BackgroundColor3 = Color3.fromRGB(40,46,53) end
				end)
			end,
			Get = function(self) return state end,
			Destroy = function(self) if frame and frame.Parent then frame:Destroy() end end
		}
	end

	function tabObj:Dropdown(options)
		options = Library:validate({ title = "Dropdown", options = {"One","Two"}, callback = function() end }, options or {})
		local frame = Instance.new("Frame", tabFrame)
		frame.Size = UDim2.new(1, -20, 0, 44)
		frame.BackgroundTransparency = 1

		local title = Instance.new("TextLabel", frame)
		title.Position = UDim2.new(0, 8, 0, 0)
		title.Size = UDim2.new(0.6, 0, 0, 20)
		title.BackgroundTransparency = 1
		title.Text = options.title
		title.Font = Enum.Font.SourceSansItalic
		title.TextColor3 = Color3.fromRGB(190,205,215)
		title.TextScaled = true
		title.TextXAlignment = Enum.TextXAlignment.Left

		local display = Instance.new("TextButton", frame)
		display.Size = UDim2.new(0.9, -8, 0, 24)
		display.Position = UDim2.new(0,8,0,20)
		display.BackgroundColor3 = Color3.fromRGB(30,36,42)
		display.BorderSizePixel = 0
		display.AutoButtonColor = false
		pcall(function() Instance.new("UICorner", display).CornerRadius = UDim.new(0,6) end)
		local dispStroke = Instance.new("UIStroke", display)
		dispStroke.Color = Color3.fromRGB(60,80,95)
		local dispText = Instance.new("TextLabel", display)
		dispText.Size = UDim2.new(1, -24, 1, 0)
		dispText.Position = UDim2.new(0,8,0,0)
		dispText.BackgroundTransparency = 1
		dispText.Text = options.options[1] or ""
		dispText.TextColor3 = Color3.fromRGB(200,220,240)
		dispText.Font = Enum.Font.SourceSansBold
		dispText.TextScaled = true
		dispText.TextXAlignment = Enum.TextXAlignment.Left

		local arrow = Instance.new("ImageLabel", display)
		arrow.Size = UDim2.new(0, 18, 0, 18)
		arrow.Position = UDim2.new(1, -22, 0.5, -9)
		arrow.BackgroundTransparency = 1
		arrow.Image = "" -- optional arrow asset

		local optsFrame = Instance.new("Frame", frame)
		optsFrame.Position = UDim2.new(0,8,0,44)
		optsFrame.Size = UDim2.new(0.9, -8, 0, #options.options * 26)
		optsFrame.BackgroundTransparency = 1
		optsFrame.Visible = false
		local optsLayout = Instance.new("UIListLayout", optsFrame)
		optsLayout.Padding = UDim.new(0,4)
		optsLayout.SortOrder = Enum.SortOrder.LayoutOrder

		local function rebuild()
			for _,c in ipairs(optsFrame:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
			for i,v in ipairs(options.options) do
				local t = Instance.new("TextLabel", optsFrame)
				t.Size = UDim2.new(1,0,0,22)
				t.BackgroundTransparency = 1
				t.Text = v
				t.TextColor3 = Color3.fromRGB(190,215,235)
				t.Font = Enum.Font.SourceSansItalic
				t.TextScaled = true
				t.TextXAlignment = Enum.TextXAlignment.Left
				t.InputBegan:Connect(function(inp, gp)
					if gp then return end
					if inp.UserInputType == Enum.UserInputType.MouseButton1 then
						dispText.Text = v
						optsFrame.Visible = false
						pcall(function() options.callback(v) end)
					end
				end)
			end
		end
		rebuild()

		display.MouseButton1Click:Connect(function() optsFrame.Visible = not optsFrame.Visible end)

		table.insert(tabObj._components, frame)
		return {
			Get = function(self) return dispText.Text end,
			SetOptions = function(self, tbl) options.options = tbl or {}; optsFrame.Size = UDim2.new(0.9, -8, 0, #options.options * 26); rebuild() end,
			Destroy = function(self) if frame and frame.Parent then frame:Destroy() end end
		}
	end

	-- register and return tabObj
	table.insert(GUI._tabObjects, tabObj)
	table.insert(GUI._headerObjects, topBtn)
	return tabObj
end

-- Dragging main window (using top area near header)
do
	local dragging = false
	local dragStart = nil
	local startPos = nil

	GUI.Main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = GUI.Main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			local newPos = startPos + UDim2.new(0, delta.X, 0, delta.Y)
			-- clamp to viewport if available
			local scr = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
			local x = math.clamp(newPos.X.Offset, 0, scr.X - GUI.Main.AbsoluteSize.X)
			local y = math.clamp(newPos.Y.Offset, 0, scr.Y - GUI.Main.AbsoluteSize.Y)
			GUI.Main.Position = UDim2.fromOffset(x, y)
		end
	end)
end

-- Toggle visibility with RightControl
pcall(function()
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.RightControl then
			GUI.Visible = not GUI.Visible
			pcall(function() GUI.ScreenGui.Enabled = GUI.Visible end)
		end
	end)
end)

-- Return the library table so loadstring(...)() returns Library
return Library
