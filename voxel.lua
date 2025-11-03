
-- Voxel UI Library (injection-ready single-file)
-- Drop this into an executor as a string loader or save locally and run in an environment with game:GetService and Instance.new.
-- Features: Button, Label, Slider, Toggle, Dropdown, draggable window, RightControl toggle, safe parenting, Close()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
local tweenInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local Library = {}

-- Simple validate helper
function Library:validate(default, options)
	local options = options or {}
	for i, v in pairs(default) do
		if options[i] == nil then
			options[i] = v
		end
	end
	return options
end

-- Tween helper (uses shared tweenInfo)
function Library:tween(object, goal, callback)
	local ok, err = pcall(function()
		local tween = TweenService:Create(object, tweenInfo, goal)
		if callback then
			tween.Completed:Connect(callback)
		end
		tween:Play()
	end)
	if not ok then
		-- silent fail to avoid executor crashes
	end
end

-- Safe parent helper: prefer PlayerGui, fallback to CoreGui if allowed
local function safeParent(gui)
	local parent = nil
	local success, err = pcall(function()
		local plr = Players.LocalPlayer
		if plr then
			parent = plr:FindFirstChild("PlayerGui") or plr:WaitForChild("PlayerGui", 1)
		end
	end)
	if parent and parent.Parent ~= nil then
		pcall(function() gui.Parent = parent end)
		return true
	end
	-- fallback to CoreGui if possible (some games prevent it)
	local ok = pcall(function() gui.Parent = CoreGui end)
	return ok
end

-- Init: builds main GUI and returns GUI object with CreateTab
function Library:Init(options)
	options = options or {}
	options = Library:validate({
		name = "Voxel UI"
	}, options)

	local GUI = {
		CurrentTab = nil,
		_components = {}, -- track created components (for cleanup if needed)
		_visible = true
	}

	-- Create ScreenGui
	GUI.ScreenGui = Instance.new("ScreenGui")
	GUI.ScreenGui.Name = "Library.VoxelUI"
	GUI.ScreenGui.IgnoreGuiInset = true
	GUI.ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	local parentOk = safeParent(GUI.ScreenGui)
	if not parentOk then
		-- last resort: try PlayerGui again, may error; wrap pcall
		pcall(function() GUI.ScreenGui.Parent = Players.LocalPlayer and Players.LocalPlayer:WaitForChild("PlayerGui") end)
	end

	-- Main frame
	GUI.Main = Instance.new("Frame", GUI.ScreenGui)
	GUI.Main.Name = "Main"
	GUI.Main.Size = UDim2.new(0, 492, 0, 318)
	GUI.Main.Position = UDim2.fromOffset((viewport.X/2) - (492 / 2), (viewport.Y/2) - (318 / 2))
	GUI.Main.BackgroundColor3 = Color3.fromRGB(20, 23, 27)
	GUI.Main.BorderSizePixel = 0
	GUI.Main.ClipsDescendants = true

	local ok = pcall(function() Instance.new("UICorner", GUI.Main).CornerRadius = UDim.new(0.02, 0) end)

	-- vertical separator / accent
	GUI.Ignore = Instance.new("Frame", GUI.Main)
	GUI.Ignore.Name = "Ignore"
	GUI.Ignore.Size = UDim2.new(0.002, 0, 1, 0)
	GUI.Ignore.Position = UDim2.new(0.22917, 0, 0, 0)
	GUI.Ignore.BackgroundColor3 = Color3.fromRGB(159, 188, 255)
	GUI.Ignore.BorderSizePixel = 0

	-- Title label (used as drag handle)
	GUI.Title = Instance.new("TextLabel", GUI.Main)
	GUI.Title.Name = "Title"
	GUI.Title.Size = UDim2.new(0.2, 0, 0.06452, 0)
	GUI.Title.Position = UDim2.new(0.01528, 0, 0.02366, 0)
	GUI.Title.BackgroundTransparency = 1
	GUI.Title.Text = options.name
	GUI.Title.TextColor3 = Color3.fromRGB(102, 119, 140)
	GUI.Title.TextScaled = true
	GUI.Title.Font = Enum.Font.SourceSans -- fallback; your font is optional
	-- preserve text scaling constraint
	pcall(function()
		local txtConstraint = Instance.new("UITextSizeConstraint", GUI.Title)
		txtConstraint.MaxTextSize = 50
	end)

	-- Tabs column
	GUI.Tabs = Instance.new("Frame", GUI.Main)
	GUI.Tabs.Name = "Tabs"
	GUI.Tabs.Size = UDim2.new(0.22917, 0, 1, 0)
	GUI.Tabs.BackgroundColor3 = Color3.fromRGB(29, 33, 39)
	GUI.Tabs.BorderSizePixel = 0
	GUI.Tabs.ClipsDescendants = true
	pcall(function() Instance.new("UICorner", GUI.Tabs).CornerRadius = UDim.new(0.08, 0) end)
	pcall(function()
		local gradient = Instance.new("UIGradient", GUI.Tabs)
		gradient.Rotation = 25
		gradient.Color = ColorSequence.new{
			ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39)),
		}
	end)

	GUI.TabButtons = Instance.new("Frame", GUI.Tabs)
	GUI.TabButtons.Name = "Buttons"
	GUI.TabButtons.Size = UDim2.new(1, 0, 0.88, 0)
	GUI.TabButtons.Position = UDim2.new(0,0,0.118,0)
	GUI.TabButtons.BackgroundTransparency = 1
	GUI.TabButtons.BorderSizePixel = 0

	local tabListLayout = Instance.new("UIListLayout", GUI.TabButtons)
	tabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabListLayout.Padding = UDim.new(0, 6)

	-- Frames container (for tab contents)
	GUI.Frames = Instance.new("Frame", GUI.Main)
	GUI.Frames.Name = "Frames"
	GUI.Frames.Size = UDim2.new(0.76944, 0, 1, 0)
	GUI.Frames.Position = UDim2.new(0.23056, 0, 0, 0)
	GUI.Frames.BackgroundTransparency = 1
	GUI.Frames.BorderSizePixel = 0

	-- Draggable window implementation (drag via Title)
	do
		local dragging = false
		local dragStart = nil
		local startPos = nil

		GUI.Title.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = input.Position
				startPos = GUI.Main.Position

				-- capture movement while dragging
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local delta = input.Position - dragStart
				local newPos = startPos + UDim2.new(0, delta.X, 0, delta.Y)
				-- clamp so window isn't lost offscreen (basic clamp)
				local screenSize = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or viewport
				local x = math.clamp(newPos.X.Offset, 0, screenSize.X - GUI.Main.AbsoluteSize.X)
				local y = math.clamp(newPos.Y.Offset, 0, screenSize.Y - GUI.Main.AbsoluteSize.Y)
				GUI.Main.Position = UDim2.fromOffset(x, y)
			end
		end)
	end

	-- Close function: destroys GUI and disconnects tracked connections
	function GUI:Close()
		-- destroy top-level ScreenGui safely
		pcall(function()
			if self.ScreenGui and self.ScreenGui.Parent then
				self.ScreenGui:Destroy()
			end
		end)
		-- mark not visible
		self._visible = false
	end

	-- Toggle visibility (used by keybind)
	function GUI:ToggleVisibility()
		if not self.ScreenGui then return end
		self._visible = not self._visible
		pcall(function() self.ScreenGui.Enabled = self._visible end)
		-- fallback if Enabled not supported
		if not pcall(function() return self.ScreenGui.Enabled end) then
			if self._visible then
				pcall(function() self.ScreenGui.Parent = Players.LocalPlayer:FindFirstChild("PlayerGui") or CoreGui end)
			else
				-- move to nil
				pcall(function() self.ScreenGui.Parent = nil end)
			end
		end
	end

	-- CreateTab function
	function GUI:CreateTab(options)
		options = Library:validate({
			name = "Tab",
		}, options or {})

		local Tab = {
			Hover = false,
			Active = false,
			_connections = {}
		}

		-- Create tab button
		Tab.Button = Instance.new("TextButton", GUI.TabButtons)
		Tab.Button.Name = options.name
		Tab.Button.Size = UDim2.new(1, 0, 0.11, 0)
		Tab.Button.BackgroundTransparency = 1
		Tab.Button.Text = ""
		Tab.Button.AutoButtonColor = false
		Tab.Button.BorderSizePixel = 0

		Tab.Label = Instance.new("TextLabel", Tab.Button)
		Tab.Label.Size = UDim2.new(1,0,0.5,0)
		Tab.Label.Position = UDim2.new(0,0,0.25,0)
		Tab.Label.BackgroundTransparency = 1
		Tab.Label.Text = options.name
		Tab.Label.TextScaled = true
		Tab.Label.Font = Enum.Font.SourceSansItalic
		Tab.Label.TextColor3 = Color3.fromRGB(103,121,142)

		-- Tab content frame (parented to GUI.Frames)
		Tab.Content = Instance.new("Frame", GUI.Frames)
		Tab.Content.Name = options.name .. "_Frames"
		Tab.Content.Size = UDim2.new(1,0,1,0)
		Tab.Content.BackgroundTransparency = 1
		Tab.Content.Visible = false

		-- layout inside Tab.Content for components
		local contentList = Instance.new("UIListLayout", Tab.Content)
		contentList.Padding = UDim.new(0, 8)
		contentList.SortOrder = Enum.SortOrder.LayoutOrder
		contentList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		contentList.FillDirection = Enum.FillDirection.Vertical

		-- Colors for tab button hover/active
		local defaultColor = Color3.fromRGB(19, 22, 26)
		local hoverColor = Color3.fromRGB(49, 56, 67)
		local activeColor = Color3.fromRGB(58, 66, 79)

		-- overlay for visual background
		local btnOverlay = Instance.new("Frame", Tab.Button)
		btnOverlay.Size = UDim2.new(1,0,1,0)
		btnOverlay.BackgroundColor3 = defaultColor
		btnOverlay.BorderSizePixel = 0
		btnOverlay.BackgroundTransparency = 1 -- default hidden
		btnOverlay.ZIndex = 1

		-- hover/leave
		local connEnter = Tab.Button.MouseEnter:Connect(function()
			if not Tab.Active then
				Tab.Hover = true
				pcall(function() Library:tween(btnOverlay, {BackgroundTransparency = 0, BackgroundColor3 = hoverColor}) end)
			end
		end)
		table.insert(Tab._connections, connEnter)

		local connLeave = Tab.Button.MouseLeave:Connect(function()
			if not Tab.Active then
				Tab.Hover = false
				pcall(function() Library:tween(btnOverlay, {BackgroundTransparency = 1, BackgroundColor3 = defaultColor}) end)
			end
		end)
		table.insert(Tab._connections, connLeave)

		Tab.Button.MouseButton1Click:Connect(function()
			if GUI.CurrentTab ~= Tab then
				if GUI.CurrentTab then
					GUI.CurrentTab:Deactivate()
				end
				Tab:Activate()
			end
		end)

		function Tab:Activate()
			Tab.Active = true
			GUI.CurrentTab = Tab
			-- hide other frames
			for _, child in pairs(GUI.Frames:GetChildren()) do
				if child:IsA("Frame") then
					child.Visible = false
				end
			end
			Tab.Content.Visible = true
			pcall(function() Library:tween(btnOverlay, {BackgroundTransparency = 0.3, BackgroundColor3 = activeColor}) end)
		end

		function Tab:Deactivate()
			Tab.Active = false
			Tab.Content.Visible = false
			pcall(function() Library:tween(btnOverlay, {BackgroundTransparency = 1, BackgroundColor3 = defaultColor}) end)
		end

		-- Activate first tab automatically if none active
		if GUI.CurrentTab == nil then
			Tab:Activate()
		end

		-- COMPONENT: Button
		function Tab:Button(options)
			options = Library:validate({
				name = "Voxel",
				callback = function() end
			}, options or {})

			local ButtonObj = {}
			ButtonObj._connections = {}

			local container = Instance.new("Frame", Tab.Content)
			container.Name = "Button"
			container.Size = UDim2.new(0.95565, 0, 0.09505, 0)
			container.ClipsDescendants = true
			container.BorderSizePixel = 0
			pcall(function() Instance.new("UICorner", container).CornerRadius = UDim.new(0.1, 0) end)
			local gradient = Instance.new("UIGradient", container)
			gradient.Rotation = 25
			gradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39)),
			}
			local stroke = Instance.new("UIStroke", container)
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Color = Color3.fromRGB(70,80,95)

			local label = Instance.new("TextLabel", container)
			label.Name = "Name"
			label.Size = UDim2.new(0.42, 0, 0.67, 0)
			label.Position = UDim2.new(0.025, 0, 0.118, 0)
			label.BackgroundTransparency = 1
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.TextYAlignment = Enum.TextYAlignment.Bottom
			label.TextScaled = true
			label.Text = options.name
			label.Font = Enum.Font.SourceSansItalic
			label.TextColor3 = Color3.fromRGB(102,119,140)

			-- hover/press state variables
			local hover = false
			local mouseDown = false

			-- safe hover
			local connEnter = container.MouseEnter:Connect(function()
				hover = true
				gradient.Color = ColorSequence.new{
					ColorSequenceKeypoint.new(0, Color3.fromRGB(49,56,67)),
					ColorSequenceKeypoint.new(0.5, Color3.fromRGB(58,66,79)),
					ColorSequenceKeypoint.new(1, Color3.fromRGB(49,56,67)),
				}
				pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(97,110,131)}) end)
				pcall(function() Library:tween(label, {TextColor3 = Color3.fromRGB(97,110,131)}) end)
			end)
			table.insert(ButtonObj._connections, connEnter)

			local connLeave = container.MouseLeave:Connect(function()
				hover = false
				if not mouseDown then
					gradient.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39)),
					}
					pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(70,80,95)}) end)
					pcall(function() Library:tween(label, {TextColor3 = Color3.fromRGB(101,118,139)}) end)
				end
			end)
			table.insert(ButtonObj._connections, connLeave)

			-- Mouse input handled globally but scoped via hover flag
			local connBegin = UIS.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 and hover then
					mouseDown = true
					gradient.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(19,22,26)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25,29,34)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(19,22,26)),
					}
					pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(55,65,80)}) end)
					pcall(function() Library:tween(label, {TextColor3 = Color3.fromRGB(55,65,80)}) end)
					-- run callback (async-protected)
					pcall(function() options.callback() end)
				end
			end)
			table.insert(ButtonObj._connections, connBegin)

			local connEnd = UIS.InputEnded:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					mouseDown = false
					if hover then
						gradient.Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0, Color3.fromRGB(49,56,67)),
							ColorSequenceKeypoint.new(0.5, Color3.fromRGB(58,66,79)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(49,56,67)),
						}
						pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(97,110,131)}) end)
						pcall(function() Library:tween(label, {TextColor3 = Color3.fromRGB(97,110,131)}) end)
					else
						gradient.Color = ColorSequence.new{
							ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
							ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39)),
						}
						pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(70,80,95)}) end)
						pcall(function() Library:tween(label, {TextColor3 = Color3.fromRGB(101,118,139)}) end)
					end
				end
			end)
			table.insert(ButtonObj._connections, connEnd)

			function ButtonObj:SetText(text)
				label.Text = text
			end

			function ButtonObj:SetCallback(fn)
				options.callback = fn
			end

			function ButtonObj:Destroy()
				for _, c in pairs(ButtonObj._connections) do
					if c and c.Disconnect then pcall(function() c:Disconnect() end) end
				end
				if container and container.Parent then container:Destroy() end
			end

			return ButtonObj
		end

		-- COMPONENT: Label (simple)
		function Tab:Label(options)
			options = Library:validate({
				name = "Label",
			}, options or {})

			local LabelObj = {}

			local container = Instance.new("Frame", Tab.Content)
			container.Name = "Label"
			container.Size = UDim2.new(0.95565, 0, 0.07, 0)
			container.BorderSizePixel = 0
			container.BackgroundTransparency = 1

			local textLabel = Instance.new("TextLabel", container)
			textLabel.Size = UDim2.new(1,0,1,0)
			textLabel.BackgroundTransparency = 1
			textLabel.Text = options.name
			textLabel.TextXAlignment = Enum.TextXAlignment.Left
			textLabel.TextYAlignment = Enum.TextYAlignment.Center
			textLabel.TextScaled = true
			textLabel.Font = Enum.Font.SourceSansItalic
			textLabel.TextColor3 = Color3.fromRGB(102, 119, 140)

			function LabelObj:SetText(t)
				textLabel.Text = t
			end

			function LabelObj:Destroy()
				if container and container.Parent then container:Destroy() end
			end

			return LabelObj
		end

		-- COMPONENT: Slider
		function Tab:Slider(options)
			options = Library:validate({
				title = "Slider",
				min = 0,
				max = 100,
				default = 50,
				callback = function(v) end
			}, options or {})

			local SliderObj = {}
			SliderObj._connections = {}

			-- Container
			local container = Instance.new("Frame", Tab.Content)
			container.Name = "Slider"
			container.Size = UDim2.new(0.95565, 0, 0.16, 0)
			container.BorderSizePixel = 0
			container.ClipsDescendants = true
			pcall(function() Instance.new("UICorner", container).CornerRadius = UDim.new(0.1, 0) end)
			local gradient = Instance.new("UIGradient", container)
			gradient.Rotation = 25
			gradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39)),
			}
			local stroke = Instance.new("UIStroke", container)
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Color = Color3.fromRGB(70,80,95)

			-- Title label
			local title = Instance.new("TextLabel", container)
			title.Name = "Name"
			title.Size = UDim2.new(0.42, 0, 0.42, 0)
			title.Position = UDim2.new(0.025, 0, 0.035, 0)
			title.BackgroundTransparency = 1
			title.Text = options.title
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.TextYAlignment = Enum.TextYAlignment.Bottom
			title.TextScaled = true
			title.Font = Enum.Font.SourceSansItalic
			title.TextColor3 = Color3.fromRGB(102,119,140)

			-- value display
			local valueLabel = Instance.new("TextLabel", container)
			valueLabel.Name = "Value"
			valueLabel.Size = UDim2.new(0.166, 0, 0.42, 0)
			valueLabel.Position = UDim2.new(0.812, 0, 0.035, 0)
			valueLabel.BackgroundTransparency = 1
			valueLabel.Text = tostring(options.default)
			valueLabel.TextScaled = true
			valueLabel.Font = Enum.Font.SourceSansBold
			valueLabel.TextColor3 = Color3.fromRGB(102,119,140)
			valueLabel.TextXAlignment = Enum.TextXAlignment.Right
			valueLabel.TextYAlignment = Enum.TextYAlignment.Bottom

			-- slider back
			local sliderBack = Instance.new("Frame", container)
			sliderBack.Name = "SliderBack"
			sliderBack.Size = UDim2.new(0.95565, 0, 0.16575, 0)
			sliderBack.Position = UDim2.new(0.024, 0, 0.69767, 0)
			sliderBack.BackgroundTransparency = 1
			sliderBack.BorderSizePixel = 0
			pcall(function() Instance.new("UICorner", sliderBack).CornerRadius = UDim.new(0.5, 0) end)
			local backGradient = Instance.new("UIGradient", sliderBack)
			backGradient.Rotation = 25
			backGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39)),
			}
			local backStroke = Instance.new("UIStroke", sliderBack)
			backStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			backStroke.Color = Color3.fromRGB(70,80,95)

			-- fill draggable
			local fill = Instance.new("Frame", sliderBack)
			fill.Name = "FillDraggable"
			fill.Size = UDim2.new(0, 0, 0.9157, 0) -- will be set by value
			fill.Position = UDim2.new(0, 0, 0.04, 0)
			fill.BorderSizePixel = 0
			pcall(function() Instance.new("UICorner", fill).CornerRadius = UDim.new(0.5, 0) end)
			local fillGradient = Instance.new("UIGradient", fill)
			fillGradient.Rotation = 25
			fillGradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(123,140,166)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(167,193,231)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(123,140,166)),
			}

			-- internal state
			local minVal = options.min
			local maxVal = options.max
			local curVal = math.clamp(options.default, minVal, maxVal)
			local dragging = false

			-- helper to set from value to fill size
			local function setValueFromNumber(v)
				curVal = math.clamp(v, minVal, maxVal)
				local fraction = (curVal - minVal) / math.max(1, (maxVal - minVal))
				-- set fill size in pixels relative to sliderBack absolute size
				local backSizeX = sliderBack.AbsoluteSize.X
				local fillPx = math.clamp(math.floor(backSizeX * fraction), 0, backSizeX)
				fill.Size = UDim2.new(0, fillPx, fill.Size.Y.Scale, fill.Size.Y.Offset)
				valueLabel.Text = tostring(math.floor(curVal))
			end

			-- set initial (defer small wait)
			spawn(function()
				wait()
				pcall(function() setValueFromNumber(curVal) end)
			end)

			-- input handlers: begin drag when mouse down over sliderBack (or fill)
			local connInputBegan = UIS.InputBegan:Connect(function(input, gp)
				if gp then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					local mousePos = UIS:GetMouseLocation()
					local absPos = sliderBack.AbsolutePosition
					local absSize = sliderBack.AbsoluteSize
					-- check if mouse is inside sliderBack rect
					if mousePos.X >= absPos.X and mousePos.X <= (absPos.X + absSize.X) and
					   mousePos.Y >= absPos.Y and mousePos.Y <= (absPos.Y + absSize.Y) then
						dragging = true
						-- immediately set value
						local relX = math.clamp(mousePos.X - absPos.X, 0, absSize.X)
						local fraction = relX / math.max(1, absSize.X)
						local newVal = minVal + fraction * (maxVal - minVal)
						pcall(function() setValueFromNumber(newVal) end)
						-- callback
						pcall(function() options.callback(math.floor(curVal)) end)
					end
				end
			end)
			table.insert(SliderObj._connections, connInputBegan)

			local connInputEnded = UIS.InputEnded:Connect(function(input, gp)
				if gp then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if dragging then
						dragging = false
						-- final callback
						pcall(function() options.callback(math.floor(curVal)) end)
					end
				end
			end)
			table.insert(SliderObj._connections, connInputEnded)

			-- track mouse movement while dragging
			local connMove = UIS.InputChanged:Connect(function(input)
				if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
					local mousePos = UIS:GetMouseLocation()
					local absPos = sliderBack.AbsolutePosition
					local absSize = sliderBack.AbsoluteSize
					local relX = math.clamp(mousePos.X - absPos.X, 0, absSize.X)
					local fraction = relX / math.max(1, absSize.X)
					local newVal = minVal + fraction * (maxVal - minVal)
					pcall(function() setValueFromNumber(newVal) end)
					-- callback during drag
					pcall(function() options.callback(math.floor(curVal)) end)
				end
			end)
			table.insert(SliderObj._connections, connMove)

			-- Hover visuals on slider container
			local hovered = false
			local connEnter = container.MouseEnter:Connect(function()
				hovered = true
				pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(97,110,131)}) end)
				pcall(function() Library:tween(title, {TextColor3 = Color3.fromRGB(97,110,131)}) end)
			end)
			table.insert(SliderObj._connections, connEnter)

			local connLeave = container.MouseLeave:Connect(function()
				hovered = false
				if not dragging then
					pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(70,80,95)}) end)
					pcall(function() Library:tween(title, {TextColor3 = Color3.fromRGB(102,119,140)}) end)
				end
			end)
			table.insert(SliderObj._connections, connLeave)

			function SliderObj:SetValue(v)
				pcall(function() setValueFromNumber(v) end)
			end

			function SliderObj:GetValue()
				return math.floor(curVal)
			end

			function SliderObj:Destroy()
				for _, c in pairs(SliderObj._connections) do
					if c and c.Disconnect then pcall(function() c:Disconnect() end) end
				end
				if container and container.Parent then container:Destroy() end
			end

			return SliderObj
		end

		-- COMPONENT: Toggle (click to switch)
		function Tab:Toggle(options)
			options = Library:validate({
				title = "Toggle",
				default = false,
				callback = function(state) end
			}, options or {})

			local ToggleObj = {}
			ToggleObj._connections = {}
			local state = options.default

			local container = Instance.new("Frame", Tab.Content)
			container.Name = "Toggle"
			container.Size = UDim2.new(0.95565, 0, 0.09684, 0)
			container.BorderSizePixel = 0
			container.ClipsDescendants = true
			pcall(function() Instance.new("UICorner", container).CornerRadius = UDim.new(0.1, 0) end)
			local gradient = Instance.new("UIGradient", container)
			gradient.Rotation = 25
			gradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39)),
			}
			local stroke = Instance.new("UIStroke", container)
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Color = Color3.fromRGB(70,80,95)

			local title = Instance.new("TextLabel", container)
			title.Name = "Name"
			title.Size = UDim2.new(0.42, 0, 0.66, 0)
			title.Position = UDim2.new(0.025, 0, 0.116, 0)
			title.BackgroundTransparency = 1
			title.Text = options.title
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.TextScaled = true
			title.Font = Enum.Font.SourceSansItalic
			title.TextColor3 = Color3.fromRGB(102,119,140)

			local checkbox = Instance.new("Frame", container)
			checkbox.Name = "Checkbox"
			checkbox.Size = UDim2.new(0.03876, 0, 0.5435, 0)
			checkbox.Position = UDim2.new(0.93845, 0, 0.23, 0)
			checkbox.BackgroundTransparency = 1
			checkbox.BorderSizePixel = 0

			local checkboxInner = Instance.new("Frame", checkbox)
			checkboxInner.Name = "Fill"
			checkboxInner.Size = UDim2.new(1, 0, 1, 0)
			checkboxInner.Position = UDim2.new(0, 0, 0, 0)
			checkboxInner.BackgroundColor3 = state and Color3.fromRGB(70,80,95) or Color3.fromRGB(44,50,59)
			checkboxInner.BorderSizePixel = 0
			pcall(function() Instance.new("UICorner", checkboxInner).CornerRadius = UDim.new(0.1,0) end)
			local innerStroke = Instance.new("UIStroke", checkboxInner)
			innerStroke.Color = Color3.fromRGB(70,80,95)

			local icon = Instance.new("ImageLabel", checkboxInner)
			icon.Name = "Image"
			icon.Size = UDim2.new(1,0,1,0)
			icon.Position = UDim2.new(0,0,0,0)
			icon.BackgroundTransparency = 1
			icon.Image = ""
			icon.Visible = false

			-- handle toggle on click
			local hovered = false
			local connEnter = container.MouseEnter:Connect(function()
				hovered = true
				pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(97,110,131)}) end)
				pcall(function() Library:tween(title, {TextColor3 = Color3.fromRGB(97,110,131)}) end)
			end)
			table.insert(ToggleObj._connections, connEnter)

			local connLeave = container.MouseLeave:Connect(function()
				hovered = false
				pcall(function() Library:tween(stroke, {Color = Color3.fromRGB(70,80,95)}) end)
				pcall(function() Library:tween(title, {TextColor3 = Color3.fromRGB(102,119,140)}) end)
			end)
			table.insert(ToggleObj._connections, connLeave)

			local function setState(s)
				state = s and true or false
				-- visual feedback
				if state then
					pcall(function() Library:tween(checkboxInner, {BackgroundColor3 = Color3.fromRGB(70,80,95)}) end)
				else
					pcall(function() Library:tween(checkboxInner, {BackgroundColor3 = Color3.fromRGB(44,50,59)}) end)
				end
				-- call callback
				pcall(function() options.callback(state) end)
			end

			local connClick = container.InputBegan:Connect(function(input, gp)
				if gp then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					setState(not state)
				end
			end)
			table.insert(ToggleObj._connections, connClick)

			-- set default visual
			setState(state)

			function ToggleObj:Set(state)
				setState(state)
			end

			function ToggleObj:Get()
				return state
			end

			function ToggleObj:Destroy()
				for _, c in pairs(ToggleObj._connections) do
					if c and c.Disconnect then pcall(function() c:Disconnect() end) end
				end
				if container and container.Parent then container:Destroy() end
			end

			return ToggleObj
		end

		-- COMPONENT: Dropdown
		function Tab:Dropdown(options)
			options = Library:validate({
				title = "Dropdown",
				options = {"Option 1", "Option 2"},
				callback = function(choice) end
			}, options or {})

			local DropObj = {}
			DropObj._connections = {}

			local container = Instance.new("Frame", Tab.Content)
			container.Name = "Dropdown"
			container.Size = UDim2.new(0.95565, 0, 0.09684, 0)
			container.BorderSizePixel = 0
			container.ClipsDescendants = true
			pcall(function() Instance.new("UICorner", container).CornerRadius = UDim.new(0.1, 0) end)
			local gradient = Instance.new("UIGradient", container)
			gradient.Rotation = 25
			gradient.Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39)),
			}
			local stroke = Instance.new("UIStroke", container)
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			stroke.Color = Color3.fromRGB(70,80,95)

			local title = Instance.new("TextLabel", container)
			title.Name = "Name"
			title.Size = UDim2.new(0.42, 0, 0.66, 0)
			title.Position = UDim2.new(0.025, 0, 0.116, 0)
			title.BackgroundTransparency = 1
			title.Text = options.title
			title.TextXAlignment = Enum.TextXAlignment.Left
			title.TextScaled = true
			title.Font = Enum.Font.SourceSansItalic
			title.TextColor3 = Color3.fromRGB(102,119,140)

			local activeText = Instance.new("TextLabel", container)
			activeText.Name = "Active"
			activeText.Size = UDim2.new(0.5, 0, 0.66, 0)
			activeText.Position = UDim2.new(0.42, 0, 0.116, 0)
			activeText.BackgroundTransparency = 1
			activeText.TextXAlignment = Enum.TextXAlignment.Right
			activeText.TextScaled = true
			activeText.Font = Enum.Font.SourceSansBold
			activeText.Text = options.options[1] or ""
			activeText.TextColor3 = Color3.fromRGB(186,218,255)

			-- icon / arrow
			local icon = Instance.new("ImageButton", container)
			icon.Name = "Icon"
			icon.Size = UDim2.new(0.04, 0, 0.55, 0)
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.new(0.96, 0, 0.5, 0)
			icon.BackgroundTransparency = 1
			icon.AutoButtonColor = false
			icon.Image = "" -- optional arrow asset

			-- options frame (hidden initially)
			local optFrame = Instance.new("Frame", container)
			optFrame.Name = "Options"
			optFrame.Size = UDim2.new(0.999, 0, 0, #options.options * 28)
			optFrame.Position = UDim2.new(0, 0, 1.1, 0)
			optFrame.BorderSizePixel = 0
			optFrame.BackgroundTransparency = 1
			optFrame.ClipsDescendants = true
			optFrame.Visible = false

			local optList = Instance.new("UIListLayout", optFrame)
			optList.SortOrder = Enum.SortOrder.LayoutOrder
			optList.Padding = UDim.new(0, 4)

			-- create option labels inside optFrame
			local function buildOptions()
				for i, v in ipairs(options.options) do
					local t = Instance.new("TextLabel", optFrame)
					t.Size = UDim2.new(1,0,0,28)
					t.BackgroundTransparency = 1
					t.Text = v
					t.TextScaled = true
					t.Font = Enum.Font.SourceSansItalic
					t.TextColor3 = Color3.fromRGB(186,218,255)
					t.Name = "Opt_" .. tostring(i)
					t.TextXAlignment = Enum.TextXAlignment.Left
					-- click handler using InputBegan
					t.InputBegan:Connect(function(inp, gp)
						if gp then return end
						if inp.UserInputType == Enum.UserInputType.MouseButton1 then
							activeText.Text = v
							optFrame.Visible = false
							pcall(function() options.callback(v) end)
						end
					end)
				end
			end

			buildOptions()

			-- toggle open/close on click
			local opened = false
			local function toggleOptions()
				opened = not opened
				optFrame.Visible = opened
			end

			local connIcon = icon.MouseButton1Click:Connect(toggleOptions)
			table.insert(DropObj._connections, connIcon)
			local connContainer = container.InputBegan:Connect(function(inp, gp)
				if gp then return end
				if inp.UserInputType == Enum.UserInputType.MouseButton1 then
					toggleOptions()
				end
			end)
			table.insert(DropObj._connections, connContainer)

			function DropObj:Get()
				return activeText.Text
			end
			function DropObj:SetOptions(tbl)
				-- clear existing
				for _, c in pairs(optFrame:GetChildren()) do
					if c:IsA("TextLabel") then c:Destroy() end
				end
				options.options = tbl or {}
				optFrame.Size = UDim2.new(0.999,0,0,#options.options * 28)
				buildOptions()
			end

			function DropObj:Destroy()
				for _, c in pairs(DropObj._connections) do
					if c and c.Disconnect then pcall(function() c:Disconnect() end) end
				end
				if container and container.Parent then container:Destroy() end
			end

			return DropObj
		end

		-- expose Deactivate/Activate and return Tab
		return Tab
	end

	-- Keybind: RightControl toggles UI visibility
	pcall(function()
		UIS.InputBegan:Connect(function(input, gp)
			if gp then return end
			if input.KeyCode == Enum.KeyCode.RightControl then
				pcall(function() GUI:ToggleVisibility() end)
			end
		end)
	end)

	-- Return GUI (the Library:Init user pattern expects object)
	return GUI
end

return Library
