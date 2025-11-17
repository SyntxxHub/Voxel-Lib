local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local LocalPlayer = players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local viewport = workspace.CurrentCamera.ViewportSize
local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)

local Library = {}

function Library:validate(default, options)
	local options = options or {}
	for i, v in pairs(default) do
		if options[i] == nil then
			options[i] = v
		end
	end
	return options
end

function Library:tween(object, goal, callback)
	local tween = tweenService:Create(object, tweenInfo, goal)
	tween.Completed:Connect(callback or function() end)
	tween:Play()
end

function Library:Init(options)
	local options = options or {}
	options = Library:validate({
		name = "Voxel UI"
	}, options or {})
	
	local GUI = {
		CurrentTab = nil,
		OpenDropdowns = {}
	}
	
	-- Main
	do
		-- StarterGui.Library.VoxelUI
		GUI["1"] = Instance.new("ScreenGui", RunService:IsStudio() and players.LocalPlayer:WaitForChild("PlayerGui") or coreGui);
		GUI["1"]["Name"] = [[Library.VoxelUI]];
		GUI["1"]["ZIndexBehavior"] = Enum.ZIndexBehavior.Sibling;
		GUI["1"]["IgnoreGuiInset"] = true;


		-- StarterGui.Library.VoxelUI.Main
		GUI["2"] = Instance.new("Frame", GUI["1"]);
		GUI["2"]["BorderSizePixel"] = 0;
		GUI["2"]["BackgroundColor3"] = Color3.fromRGB(20, 23, 27);
		GUI["2"]["Size"] = UDim2.new(0, 492, 0, 318);
		GUI["2"]["Position"] = UDim2.fromOffset((viewport.X/2) - (GUI["2"].Size.X.Offset / 2), (viewport.Y/2) - (GUI["2"].Size.Y.Offset / 2));
		GUI["2"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["2"]["Name"] = [[Main]];

		-- StarterGui.Library.VoxelUI.Main.Ignore
		GUI["c"] = Instance.new("Frame", GUI["2"]);
		GUI["c"]["BorderSizePixel"] = 0;
		GUI["c"]["BackgroundColor3"] = Color3.fromRGB(159, 188, 255);
		GUI["c"]["Size"] = UDim2.new(0.002, 0, 1, 0);
		GUI["c"]["Position"] = UDim2.new(0.22917, 0, 0, 0);
		GUI["c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["c"]["Name"] = [[Ignore]];

		-- StarterGui.Library.VoxelUI.Main.UICorner
		GUI["d"] = Instance.new("UICorner", GUI["2"]);
		GUI["d"]["CornerRadius"] = UDim.new(0.02, 0);

		-- StarterGui.Library.VoxelUI.Main.Name
		GUI["e"] = Instance.new("TextLabel", GUI["2"]);
		GUI["e"]["TextWrapped"] = true;
		GUI["e"]["BorderSizePixel"] = 0;
		GUI["e"]["TextSize"] = 14;
		GUI["e"]["TextScaled"] = true;
		GUI["e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		GUI["e"]["FontFace"] = Font.new([[rbxassetid://12187375422]], Enum.FontWeight.Bold, Enum.FontStyle.Normal);
		GUI["e"]["TextColor3"] = Color3.fromRGB(102, 119, 140);
		GUI["e"]["BackgroundTransparency"] = 1;
		GUI["e"]["Size"] = UDim2.new(0.2, 0, 0.06452, 0);
		GUI["e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["e"]["Text"] = options.name;
		GUI["e"]["Name"] = options.name;
		GUI["e"]["ZIndex"] = 2;
		GUI["e"]["Position"] = UDim2.new(0.01528, 0, 0.02366, 0);


		-- StarterGui.Library.VoxelUI.Main.Name.UITextSizeConstraint
		GUI["f"] = Instance.new("UITextSizeConstraint", GUI["e"]);
		GUI["f"]["MaxTextSize"] = 50;
	end
	
	-- Draggable
	do
		local dragging = false  -- Keep this
		local dragInput
		local dragStart
		local startPos

		local function update(input)
			-- Remove the ignoreDrag check, we'll handle it differently
			local delta = input.Position - dragStart
			GUI["2"].Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end

		GUI["2"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not dragging then  -- Add check
				dragging = true
				dragStart = input.Position
				startPos = GUI["2"].Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		GUI["2"].InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				update(input)
			end
		end)

		-- ADD THIS: Make dragging accessible to other parts
		function GUI:IsDragging()
			return dragging
		end

		function GUI:StopDragging()
			dragging = false
		end
	-- Insert-key UI toggle
	-- Insert-key UI toggle (fade in/out)
do
	local ui_open = true
	local main_frame = GUI["2"]
	
	-- Store original states for checkboxes and sliders
	local originalStates = {}
	
	local function set_visuals(transparency)
		for _, v in ipairs(main_frame:GetDescendants()) do
			if v:IsA("TextLabel") or v:IsA("TextButton") then
				Library:tween(v, {TextTransparency = transparency})
			elseif v:IsA("ImageLabel") then
				-- Handle checkmark images separately
				if v.Name == "Image" then
					-- Store/restore original transparency for checkmarks
					if transparency == 1 then
						originalStates[v] = v.ImageTransparency
					end
					Library:tween(v, {ImageTransparency = transparency == 0 and (originalStates[v] or v.ImageTransparency) or 1})
				else
					Library:tween(v, {ImageTransparency = transparency})
				end
			elseif v:IsA("Frame") then
				-- Don't tween the separator line, checkbox fills, or slider fills
				if v.Name == "Ignore" then
					-- Keep separator line always visible
					v.BackgroundTransparency = 0
				elseif v.Name == "Fill" then
					-- Store and restore checkbox fill states
					if transparency == 1 then
						originalStates[v] = {
							bg = v.BackgroundTransparency,
							color = v.BackgroundColor3
						}
					end
					if transparency == 0 and originalStates[v] then
						Library:tween(v, {
							BackgroundTransparency = originalStates[v].bg,
							BackgroundColor3 = originalStates[v].color
						})
					else
						Library:tween(v, {BackgroundTransparency = transparency})
					end
				elseif v.Name == "FillDraggable" then
					-- Store and restore slider fill states
					if transparency == 1 then
						originalStates[v] = {
							bg = v.BackgroundTransparency,
							color = v.BackgroundColor3
						}
					end
					if transparency == 0 and originalStates[v] then
						Library:tween(v, {
							BackgroundTransparency = originalStates[v].bg,
							BackgroundColor3 = originalStates[v].color
						})
					else
						Library:tween(v, {BackgroundTransparency = transparency})
					end
				elseif v.BackgroundTransparency < 1 then
					Library:tween(v, {BackgroundTransparency = transparency})
				end
			elseif v:IsA("UIStroke") then
				-- Store and restore stroke states for both checkboxes and sliders
				if v.Parent and (v.Parent.Name == "Fill" or v.Parent.Name == "FillDraggable") then
					if transparency == 1 then
						originalStates[v] = {
							trans = v.Transparency,
							color = v.Color
						}
					end
					if transparency == 0 and originalStates[v] then
						Library:tween(v, {
							Transparency = originalStates[v].trans,
							Color = originalStates[v].color
						})
					else
						Library:tween(v, {Transparency = transparency})
					end
				else
					Library:tween(v, {Transparency = transparency})
				end
			elseif v:IsA("ScrollingFrame") then
				Library:tween(v, {ScrollBarImageTransparency = transparency})
			end
		end
	end

	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.Insert then
			ui_open = not ui_open
			
			if ui_open then
				-- Show frame first, then fade in
				main_frame.Visible = true
				task.wait(0.05)
				set_visuals(0)
			else
				-- Fade out, then hide
				set_visuals(1)
				task.wait(0.22)
				if not ui_open then
					main_frame.Visible = false
				end
			end
		end
	end)
end

	end

	-- Tabs
	do
		-- StarterGui.Library.VoxelUI.Main.Tabs
		GUI["3"] = Instance.new("Frame", GUI["2"]);
		GUI["3"]["BorderSizePixel"] = 0;
		GUI["3"]["BackgroundColor3"] = Color3.fromRGB(189, 216, 255);
		GUI["3"]["Size"] = UDim2.new(0.22917, 0, 1, 0);
		GUI["3"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["3"]["Name"] = [[Tabs]];


		-- StarterGui.Library.VoxelUI.Main.Tabs.UICorner
		GUI["4"] = Instance.new("UICorner", GUI["3"]);
		GUI["4"]["CornerRadius"] = UDim.new(0.08, 0);


		-- StarterGui.Library.VoxelUI.Main.Tabs.UIGradient
		GUI["5"] = Instance.new("UIGradient", GUI["3"]);
		GUI["5"]["Rotation"] = 25;
		GUI["5"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))};


		-- StarterGui.Library.VoxelUI.Main.Tabs.Buttons
		GUI["6"] = Instance.new("Frame", GUI["3"]);
		GUI["6"]["BorderSizePixel"] = 0;
		GUI["6"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		GUI["6"]["Size"] = UDim2.new(1, 0, 0.88172, 0);
		GUI["6"]["Position"] = UDim2.new(0, 0, 0.11828, 0);
		GUI["6"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		GUI["6"]["Name"] = [[Buttons]];
		GUI["6"]["BackgroundTransparency"] = 1;


		-- StarterGui.Library.VoxelUI.Main.Tabs.Buttons.UIListLayout
		GUI["7"] = Instance.new("UIListLayout", GUI["6"]);
		GUI["7"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
		GUI["7"]["Padding"] = UDim.new(0.02, 0);
		GUI["7"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
	end
	
	function GUI:CreateTab(options)
		options = Library:validate({
			name = "Tab",
		}, options or {})

		local Tab = {
			Hover = false,
			Active = false,
			Dropdowns = {}
		}
		
		Tab["j"] = Instance.new("UIListLayout", GUI["6"]);

		Tab["a"] = Instance.new("TextButton", GUI["6"])
		Tab["a"].TextWrapped = true
		Tab["a"].BorderSizePixel = 0
		Tab["a"].TextColor3 = Color3.fromRGB(255, 255, 255)
		Tab["a"].TextSize = 16
		Tab["a"].TextScaled = true
		Tab["a"].BackgroundColor3 = Color3.fromRGB(58, 66, 79)
		Tab["a"].BackgroundTransparency = 1
		Tab["a"].AutoButtonColor = false
		Tab["a"].FontFace = Font.new([[rbxassetid://12187375422]], Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		Tab["a"].Size = UDim2.new(0.90909, 0, 0.11, 0)
		Tab["a"].BorderColor3 = Color3.fromRGB(0, 0, 0)
		Tab["a"].Text = ""
		Tab["a"].Name = options.name

		Tab["b"] = Instance.new("TextLabel", Tab["a"])
		Tab["b"].TextWrapped = true
		Tab["b"].BorderSizePixel = 0
		Tab["b"].TextScaled = true
		Tab["b"].BackgroundTransparency = 1
		Tab["b"].FontFace = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic)
		Tab["b"].TextColor3 = Color3.fromRGB(103, 121, 142)
		Tab["b"].Size = UDim2.new(1, 0, 0.5, 0)
		Tab["b"].Position = UDim2.new(0, 0, 0.25, 0)
		Tab["b"].Text = options.name
		
		-- StarterGui.VoxelUI.Main.Tabs.Buttons.Button_Pressed.UICorner
		Tab["g"] = Instance.new("UICorner", Tab["a"]);
		Tab["g"]["CornerRadius"] = UDim.new(0.1, 0);


		-- StarterGui.VoxelUI.Main.Tabs.Buttons.Button_Pressed.UIStroke
		Tab["h"] = Instance.new("UIStroke", Tab["a"]);
		Tab["h"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
		Tab["h"]["Thickness"] = 0;
		Tab["h"]["Color"] = Color3.fromRGB(70, 80, 95);

		-- StarterGui.Library.VoxelUI.Main.Frames
		Tab["10"] = Instance.new("Frame", GUI["2"]);
		Tab["10"]["BorderSizePixel"] = 0;
		Tab["10"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Tab["10"]["Size"] = UDim2.new(0.76944, 0, 1, 0);
		Tab["10"]["Position"] = UDim2.new(0.23056, 0, 0, 0);
		Tab["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Tab["10"]["Name"] = "Frames_" .. options.name;
		Tab["10"]["BackgroundTransparency"] = 1;
		Tab["10"]["Visible"] = false;
		
		-- StarterGui.VoxelUI.Main.Frames.MainFrames
		Tab["1a"] = Instance.new("Frame", Tab["10"]);
		Tab["1a"]["BorderSizePixel"] = 0;
		Tab["1a"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Tab["1a"]["Size"] = UDim2.new(0.99772, 0, 0.8522, 0);
		Tab["1a"]["Position"] = UDim2.new(0, 0, 0.1478, 0);
		Tab["1a"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Tab["1a"]["Name"] = [[MainFrames]];
		Tab["1a"]["BackgroundTransparency"] = 1;
		
		-- StarterGui.VoxelUI.Main.Frames.MainFrames.UIListLayout
		Tab["48"] = Instance.new("UIListLayout", Tab["1a"]);
		Tab["48"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
		Tab["48"]["Padding"] = UDim.new(0.03, 0);
		Tab["48"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
		
		-- StarterGui.VoxelUI.Main.Frames.MainFrames.UIPadding
		Tab["47"] = Instance.new("UIPadding", Tab["1a"]);
		Tab["47"]["PaddingTop"] = UDim.new(0, 5);

		-- Colors
		local defaultColor = Color3.fromRGB(19, 22, 26)
		local hoverColor = Color3.fromRGB(49, 56, 67)
		local activeColor = Color3.fromRGB(58, 66, 79)

		-- Hover effects
		Tab["a"].MouseEnter:Connect(function()
			if not Tab.Active then
				Library:tween(Tab["a"], {
					BackgroundTransparency = 0,
					BackgroundColor3 = hoverColor
				})
				Library:tween(Tab["h"], {
					Thickness = 1.5
				})
			end
		end)

		Tab["a"].MouseLeave:Connect(function()
			if not Tab.Active then
				Library:tween(Tab["a"], {
					BackgroundTransparency = 1,
					BackgroundColor3 = defaultColor
				})
				Library:tween(Tab["h"], {
					Thickness = 0
				})
			end
		end)

		-- Click (activate)
		Tab["a"].MouseButton1Click:Connect(function()
			if GUI.CurrentTab ~= Tab then
				if GUI.CurrentTab then
					GUI.CurrentTab:Deactivate()
				end
				Tab:Activate()
			end
		end)

		-- Activation
		-- Activation
		function Tab:Activate()
			Tab.Active = true

			-- Close all open dropdowns
			for i = #GUI.OpenDropdowns, 1, -1 do
				local dropdown = GUI.OpenDropdowns[i]
				if dropdown and dropdown.Open then
					dropdown:Toggle()
				end
			end

			GUI.CurrentTab = Tab

			for _, child in pairs(GUI["2"]:GetChildren()) do
				if child:IsA("Frame") and child.Name:match("^Frames_") then
					child.Visible = false
				end
			end

			Tab["10"].Visible = true
			Tab["1a"].Visible = true

			for _, descendant in pairs(Tab["1a"]:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
					descendant.TextTransparency = 1
				end
				if descendant:IsA("ImageLabel") and descendant.Name ~= "Image" then
					descendant.ImageTransparency = 1
				end
				if descendant:IsA("UIStroke") then
					descendant.Transparency = 1
				end
			end

			-- Fade in
			task.wait(0.05)
			for _, descendant in pairs(Tab["1a"]:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
					Library:tween(descendant, {TextTransparency = 0})
				end
				if descendant:IsA("ImageLabel") and descendant.Name ~= "Image" then
					Library:tween(descendant, {ImageTransparency = 0})
				end
				if descendant:IsA("UIStroke") then
					Library:tween(descendant, {Transparency = 0})
				end
			end

			Library:tween(Tab["a"], {
				BackgroundTransparency = 0.3,
				BackgroundColor3 = activeColor
			})
			Library:tween(Tab["h"], {
				Thickness = 1.5
			})
		end

		function Tab:Deactivate()
			Tab.Active = false

			for _, descendant in pairs(Tab["1a"]:GetDescendants()) do
				if descendant:IsA("TextLabel") or descendant:IsA("TextButton") then
					Library:tween(descendant, {TextTransparency = 1})
				end
				if descendant:IsA("ImageLabel") and descendant.Name ~= "Image" then
					Library:tween(descendant, {ImageTransparency = 1})
				end
				if descendant:IsA("UIStroke") then
					Library:tween(descendant, {Transparency = 1})
				end
			end

			task.wait(0.2) -- Wait for fade out to complete
			Tab["10"].Visible = false
			Tab["1a"].Visible = false

			Library:tween(Tab["a"], {
				BackgroundTransparency = 1,
				BackgroundColor3 = defaultColor
			})
			Library:tween(Tab["h"], {
				Thickness = 0
			})
		end

		-- Make first tab active automatically
		if GUI.CurrentTab == nil then
			Tab:Activate()
		end

		
		function Tab:Button(options)
			options = Library:validate({
				name = "Voxel",
				callback = function() end
			}, options or {})
			
			local Button = {
				Hover = false,
				MouseDown = false
			}
			
			do
				-- Create main button frame inside the tab's content frame
				Button["61"] = Instance.new("Frame", Tab["1a"]);
				Button["61"]["BorderSizePixel"] = 0;
				Button["61"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Button["61"]["ClipsDescendants"] = true;
				Button["61"]["Size"] = UDim2.new(0.95565, 0, 0.09505, 0);
				Button["61"]["Position"] = UDim2.new(0.02218, 0, 0.19404, 0);
				Button["61"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Button["61"]["Name"] = [[Button]];

				-- Gradient
				Button["62"] = Instance.new("UIGradient", Button["61"]);
				Button["62"]["Rotation"] = 25;
				Button["62"]["Color"] = ColorSequence.new{
					ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),
					ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),
					ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))
				};

				-- Corner
				Button["63"] = Instance.new("UICorner", Button["61"]);
				Button["63"]["CornerRadius"] = UDim.new(0.1, 0);

				-- Stroke
				Button["64"] = Instance.new("UIStroke", Button["61"]);
				Button["64"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Button["64"]["Color"] = Color3.fromRGB(70, 80, 95);

				-- Label
				Button["65"] = Instance.new("TextLabel", Button["61"]);
				Button["65"]["TextWrapped"] = true;
				Button["65"]["BorderSizePixel"] = 0;
				Button["65"]["TextSize"] = 14;
				Button["65"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Button["65"]["TextYAlignment"] = Enum.TextYAlignment.Bottom;
				Button["65"]["TextScaled"] = true;
				Button["65"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Button["65"]["FontFace"] = Font.new(
					[[rbxasset://fonts/families/SourceSansPro.json]],
					Enum.FontWeight.Regular,
					Enum.FontStyle.Italic
				);
				Button["65"]["TextColor3"] = Color3.fromRGB(102, 119, 140);
				Button["65"]["BackgroundTransparency"] = 1;
				Button["65"]["Size"] = UDim2.new(0.42078, 0, 0.67237, 0);
				Button["65"]["Position"] = UDim2.new(0.02491, 0, 0.11865, 0);
				Button["65"]["Text"] = options.name;
				Button["65"]["Name"] = [[Name]];

				Button["66"] = Instance.new("UITextSizeConstraint", Button["65"]);
				Button["66"]["MaxTextSize"] = 50;
			end
			
			do
				-- Gradients
				local defaultGradient = ColorSequence.new{
					ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),
					ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),
					ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))
				}

				local hoverGradient = ColorSequence.new{
					ColorSequenceKeypoint.new(0.000, Color3.fromRGB(49, 56, 67)),
					ColorSequenceKeypoint.new(0.500, Color3.fromRGB(58, 66, 79)),
					ColorSequenceKeypoint.new(1.000, Color3.fromRGB(49, 56, 67))
				}

				local pressedGradient = ColorSequence.new{
					ColorSequenceKeypoint.new(0.000, Color3.fromRGB(19, 22, 26)),
					ColorSequenceKeypoint.new(0.500, Color3.fromRGB(25, 29, 34)),
					ColorSequenceKeypoint.new(1.000, Color3.fromRGB(19, 22, 26))
				}

				-- Initial state
				Button["62"].Color = defaultGradient
				Button["65"].TextColor3 = Color3.fromRGB(101, 118, 139)
				Button["64"].Color = Color3.fromRGB(70, 80, 95)

				-- Hover enter
				Button["61"].MouseEnter:Connect(function()
					Button.Hover = true
					Button["62"].Color = hoverGradient
					Library:tween(Button["64"], {Color = Color3.fromRGB(97, 110, 131)})
					Library:tween(Button["65"], {TextColor3 = Color3.fromRGB(97, 110, 131)})
				end)

				-- Hover leave
				Button["61"].MouseLeave:Connect(function()
					Button.Hover = false
					if not Button.MouseDown then
						Button["62"].Color = defaultGradient
						Library:tween(Button["64"], {Color = Color3.fromRGB(70, 80, 95)})
						Library:tween(Button["65"], {TextColor3 = Color3.fromRGB(101, 118, 139)})
					end
				end)

				-- Mouse down (pressed)
				UIS.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 and Button.Hover then
						Button.MouseDown = true
						Button["62"].Color = pressedGradient
						Library:tween(Button["64"], {Color = Color3.fromRGB(55, 65, 80)})
						Library:tween(Button["65"], {TextColor3 = Color3.fromRGB(55, 65, 80)})
						options.callback()
					end
				end)

				-- Mouse release (click)
				UIS.InputEnded:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Button.MouseDown = false
						if Button.Hover then
							Button["62"].Color = hoverGradient
							Library:tween(Button["64"], {Color = Color3.fromRGB(97, 110, 131)})
							Library:tween(Button["65"], {TextColor3 = Color3.fromRGB(97, 110, 131)})
						else
							Button["62"].Color = defaultGradient
							Library:tween(Button["64"], {Color = Color3.fromRGB(70, 80, 95)})
							Library:tween(Button["65"], {TextColor3 = Color3.fromRGB(101, 118, 139)})
						end
					end
				end)
			end
			
			function Button:SetText(text)
				Button["65"].Text = text
				options.name = text
			end
			
			function Button:SetCallback(fn)
				options.callback = fn
			end
			
			return Button
		end

		function Tab:Label(options)
			options = Library:validate({
				name = "Label",
				description = "Text 1 2 3",
			}, options or {})

			local Label = {}

			do
				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Info
				Label["30"] = Instance.new("Frame", Tab["1a"]);
				Label["30"]["BorderSizePixel"] = 0;
				Label["30"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Label["30"]["Size"] = UDim2.new(0.95565, 0, 0, 50);
				Label["30"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Label["30"]["Name"] = [[Info]];
				Label["30"]["AutomaticSize"] = Enum.AutomaticSize.Y;

				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Info.UIGradient
				Label["31"] = Instance.new("UIGradient", Label["30"]);
				Label["31"]["Rotation"] = 25;
				Label["31"]["Color"] = ColorSequence.new{
					ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),
					ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),
					ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))
				};

				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Info.UICorner
				Label["32"] = Instance.new("UICorner", Label["30"]);
				Label["32"]["CornerRadius"] = UDim.new(0.06, 0);

				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Info.UIStroke
				Label["33"] = Instance.new("UIStroke", Label["30"]);
				Label["33"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Label["33"]["Color"] = Color3.fromRGB(70, 80, 95);

				-- ADD UILISTLAYOUT FOR AUTOMATIC SPACING
				Label["layout"] = Instance.new("UIListLayout", Label["30"]);
				Label["layout"]["Padding"] = UDim.new(0, 5);
				Label["layout"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

				-- ADD PADDING
				Label["padding"] = Instance.new("UIPadding", Label["30"]);
				Label["padding"]["PaddingTop"] = UDim.new(0, 8);
				Label["padding"]["PaddingBottom"] = UDim.new(0, 8);
				Label["padding"]["PaddingLeft"] = UDim.new(0, 10);
				Label["padding"]["PaddingRight"] = UDim.new(0, 10);

				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Info.Name
				Label["34"] = Instance.new("TextLabel", Label["30"]);
				Label["34"]["TextWrapped"] = true;
				Label["34"]["BorderSizePixel"] = 0;
				Label["34"]["TextSize"] = 18;
				Label["34"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Label["34"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Label["34"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Italic);
				Label["34"]["TextColor3"] = Color3.fromRGB(102, 119, 140);
				Label["34"]["BackgroundTransparency"] = 1;
				Label["34"]["Size"] = UDim2.new(1, 0, 0, 0);
				Label["34"]["AutomaticSize"] = Enum.AutomaticSize.Y;
				Label["34"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Label["34"]["Text"] = options.name;
				Label["34"]["Name"] = [[Name]];
				Label["34"]["TextYAlignment"] = Enum.TextYAlignment.Top;
				Label["34"]["LayoutOrder"] = 1;

				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Info.Description
				Label["36"] = Instance.new("TextLabel", Label["30"]);
				Label["36"]["TextWrapped"] = true;
				Label["36"]["BorderSizePixel"] = 0;
				Label["36"]["TextSize"] = 14;
				Label["36"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Label["36"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Label["36"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
				Label["36"]["TextColor3"] = Color3.fromRGB(102, 119, 140);
				Label["36"]["BackgroundTransparency"] = 1;
				Label["36"]["Size"] = UDim2.new(1, 0, 0, 0);
				Label["36"]["AutomaticSize"] = Enum.AutomaticSize.Y;
				Label["36"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Label["36"]["Text"] = options.description;
				Label["36"]["Name"] = [[Description]];
				Label["36"]["TextYAlignment"] = Enum.TextYAlignment.Top;
				Label["36"]["RichText"] = true;
				Label["36"]["LayoutOrder"] = 2;
			end

			function Label:SetText(name, description)
				options.name = name
				options.description = description
				Label["34"].Text = name
				Label["36"].Text = description
			end

			return Label
		end
		
		function Tab:Slider(options)
			options = Library:validate({
				title = "Slider",
				min = 0,
				max = 100,
				default = 50,
				callback = function(v) print(v) end
			}, options or {})

			local Slider = {
				MouseDown = false,
				Hover = false,
				Connection = nil
			}
			
			do
				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider
				Slider["38"] = Instance.new("Frame", Tab["1a"]);
				Slider["38"]["BorderSizePixel"] = 0;
				Slider["38"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Slider["38"]["Size"] = UDim2.new(0.95565, 0, 0.15804, 0);
				Slider["38"]["Position"] = UDim2.new(0.01848, 0, 0.16645, 0);
				Slider["38"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["38"]["Name"] = [[Slider]];


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.UIGradient
				Slider["39"] = Instance.new("UIGradient", Slider["38"]);
				Slider["39"]["Rotation"] = 25;
				Slider["39"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))};


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.UICorner
				Slider["3a"] = Instance.new("UICorner", Slider["38"]);
				Slider["3a"]["CornerRadius"] = UDim.new(0.1, 0);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.UIStroke
				Slider["3b"] = Instance.new("UIStroke", Slider["38"]);
				Slider["3b"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Slider["3b"]["Color"] = Color3.fromRGB(70, 80, 95);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.Name
				Slider["3c"] = Instance.new("TextLabel", Slider["38"]);
				Slider["3c"]["TextWrapped"] = true;
				Slider["3c"]["BorderSizePixel"] = 0;
				Slider["3c"]["TextSize"] = 14;
				Slider["3c"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Slider["3c"]["TextYAlignment"] = Enum.TextYAlignment.Bottom;
				Slider["3c"]["TextScaled"] = true;
				Slider["3c"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Slider["3c"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
				Slider["3c"]["TextColor3"] = Color3.fromRGB(102, 119, 140);
				Slider["3c"]["BackgroundTransparency"] = 1;
				Slider["3c"]["Size"] = UDim2.new(0.42096, 0, 0.41232, 0);
				Slider["3c"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["3c"]["Text"] = options.title;
				Slider["3c"]["Name"] = [[Name]];
				Slider["3c"]["Position"] = UDim2.new(0.025, 0, 0.035, 0);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.Name.UITextSizeConstraint
				Slider["3d"] = Instance.new("UITextSizeConstraint", Slider["3c"]);
				Slider["3d"]["MaxTextSize"] = 50;


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.SliderBack
				Slider["3e"] = Instance.new("Frame", Slider["38"]);
				Slider["3e"]["BorderSizePixel"] = 0;
				Slider["3e"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Slider["3e"]["Size"] = UDim2.new(0.95565, 0, 0.16575, 0);
				Slider["3e"]["Position"] = UDim2.new(0.024, 0, 0.69767, 0);
				Slider["3e"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["3e"]["Name"] = [[SliderBack]];


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.SliderBack.UIGradient
				Slider["3f"] = Instance.new("UIGradient", Slider["3e"]);
				Slider["3f"]["Rotation"] = 25;
				Slider["3f"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))};


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.SliderBack.UICorner
				Slider["40"] = Instance.new("UICorner", Slider["3e"]);
				Slider["40"]["CornerRadius"] = UDim.new(0.5, 0);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.SliderBack.UIStroke
				Slider["41"] = Instance.new("UIStroke", Slider["3e"]);
				Slider["41"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Slider["41"]["Color"] = Color3.fromRGB(70, 80, 95);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.SliderBack.FillDraggable
				Slider["42"] = Instance.new("Frame", Slider["3e"]);
				Slider["42"]["BorderSizePixel"] = 0;
				Slider["42"]["BackgroundColor3"] = Color3.fromRGB(70, 80, 95);
				Slider["42"]["Size"] = UDim2.new(0.70519, 0, 1, 0);
				Slider["42"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["42"]["Name"] = [[FillDraggable]];


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.SliderBack.FillDraggable.UICorner
				Slider["43"] = Instance.new("UICorner", Slider["42"]);
				Slider["43"]["CornerRadius"] = UDim.new(0.5, 0);

				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.Value
				Slider["45"] = Instance.new("TextLabel", Slider["38"]);
				Slider["45"]["TextWrapped"] = true;
				Slider["45"]["BorderSizePixel"] = 0;
				Slider["45"]["TextSize"] = 14;
				Slider["45"]["TextXAlignment"] = Enum.TextXAlignment.Right;
				Slider["45"]["TextYAlignment"] = Enum.TextYAlignment.Bottom;
				Slider["45"]["TextScaled"] = true;
				Slider["45"]["BackgroundColor3"] = Color3.fromRGB(70, 80, 95);
				Slider["45"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Bold, Enum.FontStyle.Italic);
				Slider["45"]["TextColor3"] = Color3.fromRGB(102, 119, 140);
				Slider["45"]["BackgroundTransparency"] = 1;
				Slider["45"]["Size"] = UDim2.new(0.16686, 0, 0.41232, 0);
				Slider["45"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Slider["45"]["Text"] = tostring(options.default);
				Slider["45"]["Name"] = [[Value]];
				Slider["45"]["Position"] = UDim2.new(0.81216, 0, 0.035, 0);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.Slider.Value.UITextSizeConstraint
				Slider["46"] = Instance.new("UITextSizeConstraint", Slider["45"]);
				Slider["46"]["MaxTextSize"] = 50;
			end
			
			function Slider:SetValue(v)
				local percentage
				local value

				if v == nil then
					percentage = math.clamp((Mouse.X - Slider["38"].AbsolutePosition.X) / (Slider["38"].AbsoluteSize.X), 0, 1)
					value = math.floor(((options.max - options.min) * percentage) + options.min)
				else
					value = math.clamp(v, options.min, options.max)
					percentage = (value - options.min) / (options.max - options.min)
				end

				Slider["45"].Text = tostring(value)

				local tweenInfo = TweenInfo.new(
					0.2, -- duration
					Enum.EasingStyle.Quad,
					Enum.EasingDirection.Out
				)
				local tween = tweenService:Create(Slider["42"], tweenInfo, {Size = UDim2.fromScale(percentage, 1)})
				tween:Play()

				if not Slider.IsLocked then
					options.callback(value)
				end
			end

			do
				Slider["38"].MouseEnter:Connect(function()
					if Slider.IsLocked then return end
					Slider.Hover = true
					Library:tween(Slider["3b"], {Color = Color3.fromRGB(97, 110, 131)})
					Library:tween(Slider["41"], {Color = Color3.fromRGB(97, 110, 131)})
					Library:tween(Slider["42"], {BackgroundColor3 = Color3.fromRGB(97, 110, 131)})
					Library:tween(Slider["3c"], {TextColor3 = Color3.fromRGB(97, 110, 131)})
				end)

				Slider["38"].MouseLeave:Connect(function()
					if Slider.IsLocked then return end
					Slider.Hover = false
					if not Slider.MouseDown then
						Library:tween(Slider["3b"], {Color = Color3.fromRGB(70, 80, 95)})
						Library:tween(Slider["41"], {Color = Color3.fromRGB(70, 80, 95)})
						Library:tween(Slider["42"], {BackgroundColor3 = Color3.fromRGB(70, 80, 95)})
						Library:tween(Slider["3c"], {TextColor3 = Color3.fromRGB(101, 118, 139)})
					end
				end)

				UIS.InputBegan:Connect(function(input, gpe)
					if gpe or Slider.IsLocked then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 and Slider.Hover then
						GUI:StopDragging()
						Slider.MouseDown = true
						Library:tween(Slider["3b"], {Color = Color3.fromRGB(55, 65, 80)})
						Library:tween(Slider["41"], {Color = Color3.fromRGB(55, 65, 80)})
						Library:tween(Slider["42"], {BackgroundColor3 = Color3.fromRGB(55, 65, 80)})
						Library:tween(Slider["3c"], {TextColor3 = Color3.fromRGB(55, 65, 80)})

						if not Slider.Connection then
							Slider.Connection = RunService.RenderStepped:Connect(function()
								Slider:SetValue(nil)
							end)
						end
					end
				end)

				UIS.InputEnded:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Slider.MouseDown = false
						if Slider.Hover then
							Library:tween(Slider["3b"], {Color = Color3.fromRGB(97, 110, 131)})
							Library:tween(Slider["41"], {Color = Color3.fromRGB(97, 110, 131)})
							Library:tween(Slider["42"], {BackgroundColor3 = Color3.fromRGB(97, 110, 131)})
							Library:tween(Slider["3c"], {TextColor3 = Color3.fromRGB(97, 110, 131)})
						else
							Library:tween(Slider["3b"], {Color = Color3.fromRGB(70, 80, 95)})
							Library:tween(Slider["41"], {Color = Color3.fromRGB(70, 80, 95)})
							Library:tween(Slider["42"], {BackgroundColor3 = Color3.fromRGB(70, 80, 95)})
							Library:tween(Slider["3c"], {TextColor3 = Color3.fromRGB(101, 118, 139)})
						end

						if Slider.Connection then
							Slider.Connection:Disconnect()
							Slider.Connection = nil
						end
					end
				end)
			end

			return Slider
		end
		
		function Tab:Toggle(options)
			options = Library:validate({
				title = "Toggle",
				callback = function() end
				
			}, options or {})
			

			local Toggle = {
				Hover = false,
				MouseDown = false,
				State = false
			}
			
			do
				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive
				Toggle["57"] = Instance.new("Frame", Tab["1a"]);
				Toggle["57"]["BorderSizePixel"] = 0;
				Toggle["57"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Toggle["57"]["ClipsDescendants"] = true;
				Toggle["57"]["Size"] = UDim2.new(0.95565, 0, 0.09505, 0);
				Toggle["57"]["Position"] = UDim2.new(0.02218, 0, 0.19404, 0);
				Toggle["57"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Toggle["57"]["Name"] = [[ToggleInactive]];


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive.UIGradient
				Toggle["58"] = Instance.new("UIGradient", Toggle["57"]);
				Toggle["58"]["Rotation"] = 25;
				Toggle["58"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))};


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive.UICorner
				Toggle["59"] = Instance.new("UICorner", Toggle["57"]);
				Toggle["59"]["CornerRadius"] = UDim.new(0.1, 0);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive.UIStroke
				Toggle["5a"] = Instance.new("UIStroke", Toggle["57"]);
				Toggle["5a"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Toggle["5a"]["Color"] = Color3.fromRGB(70, 80, 95);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive.Name
				Toggle["5b"] = Instance.new("TextLabel", Toggle["57"]);
				Toggle["5b"]["TextWrapped"] = true;
				Toggle["5b"]["BorderSizePixel"] = 0;
				Toggle["5b"]["TextSize"] = 14;
				Toggle["5b"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Toggle["5b"]["TextYAlignment"] = Enum.TextYAlignment.Bottom;
				Toggle["5b"]["TextScaled"] = true;
				Toggle["5b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Toggle["5b"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
				Toggle["5b"]["TextColor3"] = Color3.fromRGB(102, 119, 140);
				Toggle["5b"]["BackgroundTransparency"] = 1;
				Toggle["5b"]["Size"] = UDim2.new(0.42078, 0, 0.67237, 0);
				Toggle["5b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Toggle["5b"]["Text"] = options.title;
				Toggle["5b"]["Name"] = [[Name]];
				Toggle["5b"]["Position"] = UDim2.new(0.02491, 0, 0.11865, 0);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive.Name.UITextSizeConstraint
				Toggle["5c"] = Instance.new("UITextSizeConstraint", Toggle["5b"]);
				Toggle["5c"]["MaxTextSize"] = 50;


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive.Checkbox
				Toggle["5d"] = Instance.new("Frame", Toggle["57"]);
				Toggle["5d"]["BorderSizePixel"] = 0;
				Toggle["5d"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Toggle["5d"]["Size"] = UDim2.new(0.03876, 0, 0.55371, 0);
				Toggle["5d"]["Position"] = UDim2.new(0.93845, 0, 0.23, 0);
				Toggle["5d"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Toggle["5d"]["Name"] = [[Checkbox]];


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive.Checkbox.UICorner
				Toggle["5e"] = Instance.new("UICorner", Toggle["5d"]);
				Toggle["5e"]["CornerRadius"] = UDim.new(0.1, 0);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive.Checkbox.UIGradient
				Toggle["5f"] = Instance.new("UIGradient", Toggle["5d"]);
				Toggle["5f"]["Rotation"] = 25;
				Toggle["5f"]["Color"] = ColorSequence.new{ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))};


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleInactive.Checkbox.UIStroke
				Toggle["60"] = Instance.new("UIStroke", Toggle["5d"]);
				Toggle["60"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Toggle["60"]["Color"] = Color3.fromRGB(70, 80, 95);
				
				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleActive.Checkbox.Fill
				Toggle["53"] = Instance.new("Frame", Toggle["5d"]);
				Toggle["53"]["BorderSizePixel"] = 0;
				Toggle["53"]["BackgroundColor3"] = Color3.fromRGB(70, 80, 95);
				Toggle["53"]["BackgroundTransparency"] = 1;
				Toggle["53"]["Size"] = UDim2.new(1, 0, 1, 0);
				Toggle["53"]["Position"] = UDim2.new(0.00987, 0, 0.008, 0);
				Toggle["53"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Toggle["53"]["Name"] = [[Fill]];


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleActive.Checkbox.Fill.UICorner
				Toggle["54"] = Instance.new("UICorner", Toggle["53"]);
				Toggle["54"]["CornerRadius"] = UDim.new(0.1, 0);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleActive.Checkbox.Fill.UIStroke
				Toggle["55"] = Instance.new("UIStroke", Toggle["53"]);
				Toggle["55"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Toggle["55"]["Color"] = Color3.fromRGB(70, 80, 95);


				-- StarterGui.VoxelUI.Main.Frames.MainFrames.ToggleActive.Checkbox.Fill.Image
				Toggle["56"] = Instance.new("ImageLabel", Toggle["53"]);
				Toggle["56"]["BorderSizePixel"] = 0;
				Toggle["56"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Toggle["56"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
				Toggle["56"]["Image"] = [[rbxassetid://107176071390364]];
				Toggle["56"]["Size"] = UDim2.new(1, 0, 1, 0);
				Toggle["56"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Toggle["56"]["BackgroundTransparency"] = 1;
				Toggle["56"]["ImageTransparency"] = 1;
				Toggle["56"]["Name"] = [[Image]];
				Toggle["56"]["Position"] = UDim2.new(0.5, 0, 0.5, 0);

			end
			
			do
				function Toggle:Toggle(b)
					if b == nil then
						Toggle.State = not Toggle.State
					else
						Toggle.State = b
					end

					if Toggle.State then
						-- When toggled ON: show checkmark and color the fill
						Library:tween(Toggle["53"], {BackgroundColor3 = Color3.fromRGB(69, 79, 94)})
						Library:tween(Toggle["53"], {BackgroundTransparency = 0})
						Library:tween(Toggle["55"], {Color = Color3.fromRGB(69, 79, 94)})
						Library:tween(Toggle["56"], {ImageTransparency = 0})
					else
						-- When toggled OFF: hide checkmark and reset fill color
						Library:tween(Toggle["53"], {BackgroundColor3 = Color3.fromRGB(29, 33, 39)})
						Library:tween(Toggle["53"], {BackgroundTransparency = 1})
						Library:tween(Toggle["55"], {Color = Color3.fromRGB(70, 80, 95)})
						Library:tween(Toggle["56"], {ImageTransparency = 1})
					end

					options.callback(Toggle.State)
				end
			end
			
			do
				Toggle["57"].MouseEnter:Connect(function()
					Toggle.Hover = true
					Library:tween(Toggle["5a"], {Color = Color3.fromRGB(97, 110, 131)})
					Library:tween(Toggle["5b"], {TextColor3 = Color3.fromRGB(97, 110, 131)})
					Library:tween(Toggle["60"], {Color = Color3.fromRGB(97, 110, 131)})
				end)

				-- Hover leave
				Toggle["57"].MouseLeave:Connect(function()
					Toggle.Hover = false
					if not Toggle.MouseDown then
						Library:tween(Toggle["5a"], {Color = Color3.fromRGB(70, 80, 95)})
						Library:tween(Toggle["5b"], {TextColor3 = Color3.fromRGB(101, 118, 139)})
						Library:tween(Toggle["60"], {Color = Color3.fromRGB(70, 80, 95)})
					end
				end)

				-- Mouse down (pressed)
				UIS.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 and Toggle.Hover then
						Toggle.MouseDown = true
						Library:tween(Toggle["5a"], {Color = Color3.fromRGB(55, 65, 80)})
						Library:tween(Toggle["5b"], {TextColor3 = Color3.fromRGB(55, 65, 80)})
						Library:tween(Toggle["60"], {Color = Color3.fromRGB(55, 65, 80)})
						Toggle:Toggle()
					end
				end)

				-- Mouse release (click)
				UIS.InputEnded:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Toggle.MouseDown = false
						if Toggle.Hover then
							Library:tween(Toggle["5a"], {Color = Color3.fromRGB(97, 110, 131)})
							Library:tween(Toggle["5b"], {TextColor3 = Color3.fromRGB(97, 110, 131)})
							Library:tween(Toggle["60"], {Color = Color3.fromRGB(97, 110, 131)})
						else
							Library:tween(Toggle["5a"], {Color = Color3.fromRGB(70, 80, 95)})
							Library:tween(Toggle["5b"], {TextColor3 = Color3.fromRGB(101, 118, 139)})
							Library:tween(Toggle["60"], {Color = Color3.fromRGB(70, 80, 95)})
						end
					end
				end)
			end
			
			return Toggle
		end
		
		function Tab:Dropdown(options)
			options = Library:validate({
				title = "Dropdown",
				options = {"Option 1", "Option 2", "Option 3"},
				default = "Option 1",
				callback = function(v) print(v) end
			}, options or {})

			local Dropdown = {
				Hover = false,
				MouseDown = false,
				Open = false,
				Selected = options.default
			}
			
			table.insert(GUI.OpenDropdowns, Dropdown)

			do
				-- Main dropdown frame (now a button)
				Dropdown["1b"] = Instance.new("TextButton", Tab["1a"]);
				Dropdown["1b"]["BorderSizePixel"] = 0;
				Dropdown["1b"]["BackgroundColor3"] = Color3.fromRGB(29, 33, 39);
				Dropdown["1b"]["ClipsDescendants"] = false;
				Dropdown["1b"]["Size"] = UDim2.new(0.95565, 0, 0.09505, 0);
				Dropdown["1b"]["Position"] = UDim2.new(0.02218, 0, 0.19404, 0);
				Dropdown["1b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Dropdown["1b"]["Name"] = [[Dropdown]];
				Dropdown["1b"]["ZIndex"] = 10;
				Dropdown["1b"]["Text"] = "";
				Dropdown["1b"]["AutoButtonColor"] = false;

				-- UIGradient
				Dropdown["1c"] = Instance.new("UIGradient", Dropdown["1b"]);
				Dropdown["1c"]["Rotation"] = 25;
				Dropdown["1c"]["Color"] = ColorSequence.new{
					ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),
					ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),
					ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))
				};

				-- UICorner
				Dropdown["1d"] = Instance.new("UICorner", Dropdown["1b"]);
				Dropdown["1d"]["CornerRadius"] = UDim.new(0.1, 0);

				-- UIStroke
				Dropdown["1e"] = Instance.new("UIStroke", Dropdown["1b"]);
				Dropdown["1e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Dropdown["1e"]["Color"] = Color3.fromRGB(70, 80, 95);

				-- Name label
				Dropdown["1f"] = Instance.new("TextLabel", Dropdown["1b"]);
				Dropdown["1f"]["TextWrapped"] = true;
				Dropdown["1f"]["BorderSizePixel"] = 0;
				Dropdown["1f"]["TextSize"] = 14;
				Dropdown["1f"]["TextXAlignment"] = Enum.TextXAlignment.Left;
				Dropdown["1f"]["TextYAlignment"] = Enum.TextYAlignment.Bottom;
				Dropdown["1f"]["TextScaled"] = true;
				Dropdown["1f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Dropdown["1f"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
				Dropdown["1f"]["TextColor3"] = Color3.fromRGB(102, 119, 140);
				Dropdown["1f"]["BackgroundTransparency"] = 1;
				Dropdown["1f"]["Size"] = UDim2.new(0.42078, 0, 0.67237, 0);
				Dropdown["1f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Dropdown["1f"]["Text"] = options.title .. ": " .. Dropdown.Selected;
				Dropdown["1f"]["Name"] = [[Name]];
				Dropdown["1f"]["Position"] = UDim2.new(0.02491, 0, 0.11865, 0);
				Dropdown["1f"]["ZIndex"] = 11;
				Dropdown["1f"]["Active"] = false;

				Dropdown["20"] = Instance.new("UITextSizeConstraint", Dropdown["1f"]);
				Dropdown["20"]["MaxTextSize"] = 50;

				-- Icon
				Dropdown["2f"] = Instance.new("ImageLabel", Dropdown["1b"]);
				Dropdown["2f"]["BorderSizePixel"] = 0;
				Dropdown["2f"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Dropdown["2f"]["ImageColor3"] = Color3.fromRGB(97, 113, 132);
				Dropdown["2f"]["AnchorPoint"] = Vector2.new(0.5, 0.5);
				Dropdown["2f"]["Image"] = [[rbxassetid://93112416374362]];
				Dropdown["2f"]["Size"] = UDim2.new(0.039, 0, 0.533, 0);
				Dropdown["2f"]["BackgroundTransparency"] = 1;
				Dropdown["2f"]["Name"] = [[Icon]];
				Dropdown["2f"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Dropdown["2f"]["Position"] = UDim2.new(0.957, 0, 0.5, 0);
				Dropdown["2f"]["ZIndex"] = 11;
				Dropdown["2f"]["Active"] = false;

				-- Options container
				Dropdown["21"] = Instance.new("ScrollingFrame", Dropdown["1b"]);
				Dropdown["21"]["BorderSizePixel"] = 0;
				Dropdown["21"]["BackgroundColor3"] = Color3.fromRGB(20, 23, 27);
				Dropdown["21"]["Size"] = UDim2.new(1, 0, 0, 0);
				Dropdown["21"]["Position"] = UDim2.new(0, 0, 1, 2);
				Dropdown["21"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Dropdown["21"]["Name"] = [[Options]];
				Dropdown["21"]["ScrollBarThickness"] = 4;
				Dropdown["21"]["ScrollBarImageColor3"] = Color3.fromRGB(97, 113, 132);
				Dropdown["21"]["Visible"] = false;
				Dropdown["21"]["ZIndex"] = 15;
				Dropdown["21"]["CanvasSize"] = UDim2.new(0, 0, 0, 0);
				Dropdown["21"]["Active"] = true;

				-- Options background styling
				local optionsCorner = Instance.new("UICorner", Dropdown["21"]);
				optionsCorner["CornerRadius"] = UDim.new(0.04, 0);

				local optionsStroke = Instance.new("UIStroke", Dropdown["21"]);
				optionsStroke["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				optionsStroke["Color"] = Color3.fromRGB(70, 80, 95);

				-- UIListLayout for options
				Dropdown["26"] = Instance.new("UIListLayout", Dropdown["21"]);
				Dropdown["26"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
				Dropdown["26"]["Padding"] = UDim.new(0, 5);
				Dropdown["26"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

				-- Padding for options
				local optionsPadding = Instance.new("UIPadding", Dropdown["21"]);
				optionsPadding["PaddingTop"] = UDim.new(0, 3);
				optionsPadding["PaddingBottom"] = UDim.new(0, 3);
				optionsPadding["PaddingLeft"] = UDim.new(0, 3);
				optionsPadding["PaddingRight"] = UDim.new(0, 3);

				-- Create option buttons
				Dropdown.OptionButtons = {}
				for i, option in ipairs(options.options) do
					local optionButton = Instance.new("TextButton", Dropdown["21"]);
					optionButton["TextWrapped"] = true;
					optionButton["BorderSizePixel"] = 0;
					optionButton["TextSize"] = 13;
					optionButton["TextScaled"] = false;
					optionButton["BackgroundColor3"] = option == Dropdown.Selected and Color3.fromRGB(25, 33, 47) or Color3.fromRGB(29, 33, 39);
					optionButton["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
					optionButton["TextColor3"] = Color3.fromRGB(186, 218, 255);
					optionButton["Size"] = UDim2.new(0.97, 0, 0, 22);
					optionButton["BorderColor3"] = Color3.fromRGB(0, 0, 0);
					optionButton["Text"] = option;
					optionButton["AutoButtonColor"] = false;
					optionButton["ZIndex"] = 16;

					local corner = Instance.new("UICorner", optionButton);
					corner["CornerRadius"] = UDim.new(0.15, 0);

					local stroke = Instance.new("UIStroke", optionButton);
					stroke["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
					stroke["Color"] = option == Dropdown.Selected and Color3.fromRGB(70, 80, 95) or Color3.fromRGB(44, 50, 59);

					-- Hover effects
					optionButton.MouseEnter:Connect(function()
						if option ~= Dropdown.Selected then
							Library:tween(optionButton, {BackgroundColor3 = Color3.fromRGB(38, 50, 71)})
							Library:tween(stroke, {Color = Color3.fromRGB(70, 80, 95)})
						end
					end)

					optionButton.MouseLeave:Connect(function()
						if option ~= Dropdown.Selected then
							Library:tween(optionButton, {BackgroundColor3 = Color3.fromRGB(29, 33, 39)})
							Library:tween(stroke, {Color = Color3.fromRGB(44, 50, 59)})
						end
					end)

					-- Click handler
					optionButton.MouseButton1Click:Connect(function()
						-- Deselect previous
						if Dropdown.OptionButtons[Dropdown.Selected] then
							Library:tween(Dropdown.OptionButtons[Dropdown.Selected].button, {BackgroundColor3 = Color3.fromRGB(29, 33, 39)})
							Library:tween(Dropdown.OptionButtons[Dropdown.Selected].stroke, {Color = Color3.fromRGB(44, 50, 59)})
						end

						-- Select new
						Dropdown.Selected = option
						Library:tween(optionButton, {BackgroundColor3 = Color3.fromRGB(25, 33, 47)})
						Library:tween(stroke, {Color = Color3.fromRGB(70, 80, 95)})
						Dropdown["1f"].Text = options.title .. ": " .. Dropdown.Selected

						-- Close dropdown
						Dropdown:Toggle()

						-- Callback
						options.callback(option)
					end)

					Dropdown.OptionButtons[option] = {button = optionButton, stroke = stroke}
				end

				-- Update canvas size
				Dropdown["26"]:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					Dropdown["21"].CanvasSize = UDim2.new(0, 0, 0, Dropdown["26"].AbsoluteContentSize.Y + 6)
				end)

				-- Initial colors
				local defaultBg = Color3.fromRGB(29, 33, 39)
				local hoverBg = Color3.fromRGB(49, 56, 67)
				local pressedBg = Color3.fromRGB(19, 22, 26)

				-- Hover enter
				Dropdown["1b"].MouseEnter:Connect(function()
					Dropdown.Hover = true
					Library:tween(Dropdown["1b"], {BackgroundColor3 = hoverBg})
					Library:tween(Dropdown["1e"], {Color = Color3.fromRGB(97, 110, 131)})
					Library:tween(Dropdown["1f"], {TextColor3 = Color3.fromRGB(97, 110, 131)})
					Library:tween(Dropdown["2f"], {ImageColor3 = Color3.fromRGB(97, 110, 131)})
				end)

				-- Hover leave
				Dropdown["1b"].MouseLeave:Connect(function()
					Dropdown.Hover = false
					if not Dropdown.MouseDown then
						Library:tween(Dropdown["1b"], {BackgroundColor3 = defaultBg})
						Library:tween(Dropdown["1e"], {Color = Color3.fromRGB(70, 80, 95)})
						Library:tween(Dropdown["1f"], {TextColor3 = Color3.fromRGB(101, 118, 139)})
						Library:tween(Dropdown["2f"], {ImageColor3 = Color3.fromRGB(97, 113, 132)})
					end
				end)

				-- Mouse down (pressed)
				UIS.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 and Dropdown.Hover then
						Dropdown.MouseDown = true
						Library:tween(Dropdown["1b"], {BackgroundColor3 = pressedBg})
						Library:tween(Dropdown["1e"], {Color = Color3.fromRGB(55, 65, 80)})
						Library:tween(Dropdown["1f"], {TextColor3 = Color3.fromRGB(55, 65, 80)})
						Library:tween(Dropdown["2f"], {ImageColor3 = Color3.fromRGB(55, 65, 80)})
					end
				end)

				-- Mouse release (click)
				UIS.InputEnded:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dropdown.MouseDown = false
						if Dropdown.Hover then
							Library:tween(Dropdown["1b"], {BackgroundColor3 = hoverBg})
							Library:tween(Dropdown["1e"], {Color = Color3.fromRGB(97, 110, 131)})
							Library:tween(Dropdown["1f"], {TextColor3 = Color3.fromRGB(97, 110, 131)})
							Library:tween(Dropdown["2f"], {ImageColor3 = Color3.fromRGB(97, 110, 131)})
						else
							Library:tween(Dropdown["1b"], {BackgroundColor3 = defaultBg})
							Library:tween(Dropdown["1e"], {Color = Color3.fromRGB(70, 80, 95)})
							Library:tween(Dropdown["1f"], {TextColor3 = Color3.fromRGB(101, 118, 139)})
							Library:tween(Dropdown["2f"], {ImageColor3 = Color3.fromRGB(97, 113, 132)})
						end
					end
				end)

				-- Click to toggle
				Dropdown["1b"].MouseButton1Click:Connect(function()
					Dropdown:Toggle()
				end)
			end

			do
				function Dropdown:Toggle()
					Dropdown.Open = not Dropdown.Open

					if Dropdown.Open then
						-- Calculate height (max 5 items visible)
						local optionCount = #options.options
						local maxVisible = math.min(optionCount, 5)
						local optionHeight = 22
						local padding = 3
						local totalHeight = (optionHeight * maxVisible) + (padding * (maxVisible + 1))

						Dropdown["21"].Visible = true
						Library:tween(Dropdown["21"], {Size = UDim2.new(1, 0, 0, totalHeight)})
						Library:tween(Dropdown["2f"], {Rotation = 180})
					else
						Library:tween(Dropdown["21"], {Size = UDim2.new(1, 0, 0, 0)})
						Library:tween(Dropdown["2f"], {Rotation = 0})
						task.wait(0.2)
						Dropdown["21"].Visible = false
					end
				end
			end

			function Dropdown:SetValue(value)
				if Dropdown.OptionButtons[value] then
					-- Deselect previous
					if Dropdown.OptionButtons[Dropdown.Selected] then
						Library:tween(Dropdown.OptionButtons[Dropdown.Selected].button, {BackgroundColor3 = Color3.fromRGB(29, 33, 39)})
						Library:tween(Dropdown.OptionButtons[Dropdown.Selected].stroke, {Color = Color3.fromRGB(44, 50, 59)})
					end

					-- Select new
					Dropdown.Selected = value
					Library:tween(Dropdown.OptionButtons[value].button, {BackgroundColor3 = Color3.fromRGB(25, 33, 47)})
					Library:tween(Dropdown.OptionButtons[value].stroke, {Color = Color3.fromRGB(70, 80, 95)})
					Dropdown["1f"].Text = options.title .. ": " .. Dropdown.Selected

					options.callback(value)
				end
			end

			return Dropdown
		end
		
		
		function Tab:Keybind(options)
			options = Library:validate({
				title = "Keybind",
				default = Enum.KeyCode.One,
				mode = "once", -- "once" or "toggle"
				callback = function() end
			}, options or {})

			local Keybind = {
				Listening = false,
				Key = options.default or Enum.KeyCode.One,
				State = false
			}

			-- Create UI (matches your style & placement inside Tab["1a"])
			Keybind["kb_frame"] = Instance.new("Frame", Tab["1a"]);
			Keybind["kb_frame"].BorderSizePixel = 0;
			Keybind["kb_frame"].BackgroundColor3 = Color3.fromRGB(255,255,255);
			Keybind["kb_frame"].ClipsDescendants = true;
			Keybind["kb_frame"].Size = UDim2.new(0.95565, 0, 0.09684, 0);
			Keybind["kb_frame"].Position = UDim2.new(0.02218, 0, 0.19404, 0);
			Keybind["kb_frame"].BorderColor3 = Color3.fromRGB(0,0,0);
			Keybind["kb_frame"].Name = "Keybind";

			Keybind["kb_grad"] = Instance.new("UIGradient", Keybind["kb_frame"]);
			Keybind["kb_grad"].Rotation = 25;
			Keybind["kb_grad"].Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39))
			}

			Keybind["kb_corner"] = Instance.new("UICorner", Keybind["kb_frame"]);
			Keybind["kb_corner"].CornerRadius = UDim.new(0.1, 0);

			Keybind["kb_stroke"] = Instance.new("UIStroke", Keybind["kb_frame"]);
			Keybind["kb_stroke"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			Keybind["kb_stroke"].Color = Color3.fromRGB(70,80,95);

			Keybind["kb_name"] = Instance.new("TextLabel", Keybind["kb_frame"]);
			Keybind["kb_name"].TextWrapped = true;
			Keybind["kb_name"].BorderSizePixel = 0;
			Keybind["kb_name"].TextSize = 14;
			Keybind["kb_name"].TextXAlignment = Enum.TextXAlignment.Left;
			Keybind["kb_name"].TextYAlignment = Enum.TextYAlignment.Bottom;
			Keybind["kb_name"].TextScaled = true;
			Keybind["kb_name"].BackgroundColor3 = Color3.fromRGB(255,255,255);
			Keybind["kb_name"].Font = Enum.Font.SourceSansItalic;
			Keybind["kb_name"].TextColor3 = Color3.fromRGB(102,119,140);
			Keybind["kb_name"].BackgroundTransparency = 1;
			Keybind["kb_name"].Size = UDim2.new(0.42078, 0, 0.65996, 0);
			Keybind["kb_name"].BorderColor3 = Color3.fromRGB(0,0,0);
			Keybind["kb_name"].Text = options.title;
			Keybind["kb_name"].Name = "Name";
			Keybind["kb_name"].Position = UDim2.new(0.02491, 0, 0.11646, 0);

			Keybind["kb_keyframe"] = Instance.new("Frame", Keybind["kb_frame"]);
			Keybind["kb_keyframe"].BorderSizePixel = 0;
			Keybind["kb_keyframe"].BackgroundColor3 = Color3.fromRGB(255,255,255);
			Keybind["kb_keyframe"].Size = UDim2.new(0.08585, 0, 0.5435, 0);
			Keybind["kb_keyframe"].Position = UDim2.new(0.89135, 0, 0.23, 0);
			Keybind["kb_keyframe"].BorderColor3 = Color3.fromRGB(0,0,0);
			Keybind["kb_keyframe"].Name = "Key";

			Keybind["kb_keycorner"] = Instance.new("UICorner", Keybind["kb_keyframe"]);
			Keybind["kb_keycorner"].CornerRadius = UDim.new(0.1, 0);

			Keybind["kb_keygrad"] = Instance.new("UIGradient", Keybind["kb_keyframe"]);
			Keybind["kb_keygrad"].Rotation = 25;
			Keybind["kb_keygrad"].Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(29,33,39)),
				ColorSequenceKeypoint.new(0.5, Color3.fromRGB(35,40,48)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(29,33,39))
			}

			Keybind["kb_keystroke"] = Instance.new("UIStroke", Keybind["kb_keyframe"]);
			Keybind["kb_keystroke"].ApplyStrokeMode = Enum.ApplyStrokeMode.Border;
			Keybind["kb_keystroke"].Color = Color3.fromRGB(70,80,95);

			Keybind["kb_bind"] = Instance.new("TextButton", Keybind["kb_keyframe"]);
			Keybind["kb_bind"].TextWrapped = true;
			Keybind["kb_bind"].BorderSizePixel = 0;
			Keybind["kb_bind"].TextColor3 = Color3.fromRGB(97,111,132);
			Keybind["kb_bind"].TextStrokeColor3 = Color3.fromRGB(70,80,95);
			Keybind["kb_bind"].TextSize = 14;
			Keybind["kb_bind"].TextScaled = true;
			Keybind["kb_bind"].BackgroundColor3 = Color3.fromRGB(255,255,255);
			Keybind["kb_bind"].RichText = true;
			Keybind["kb_bind"].Font = Enum.Font.SourceSansBold;
			Keybind["kb_bind"].AnchorPoint = Vector2.new(0.5, 0.5);
			Keybind["kb_bind"].Size = UDim2.new(1.26554, 0, 1, 0);
			Keybind["kb_bind"].BackgroundTransparency = 1;
			Keybind["kb_bind"].Name = "Bind";
			Keybind["kb_bind"].BorderColor3 = Color3.fromRGB(0,0,0);
			Keybind["kb_bind"].Text = Keybind.Key.Name;
			Keybind["kb_bind"].Position = UDim2.new(0.47142, 0, 0.5, 0);

			-- Clicking bind enters listening mode
			Keybind["kb_bind"].MouseButton1Click:Connect(function()
				if Keybind.Listening then
					Keybind.Listening = false
					Keybind["kb_bind"].Text = Keybind.Key.Name
				else
					Keybind.Listening = true
					Keybind["kb_bind"].Text = "..."
				end
			end)

			-- Detect new key selection
			local conn_select
			conn_select = UIS.InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if Keybind.Listening and input.KeyCode and input.KeyCode ~= Enum.KeyCode.Unknown then
					Keybind.Key = input.KeyCode
					Keybind["kb_bind"].Text = Keybind.Key.Name
					Keybind.Listening = false
				end
			end)

			-- Execution
			local conn_exec
			conn_exec = UIS.InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if input.KeyCode == Keybind.Key then
					if options.mode == "toggle" then
						Keybind.State = not Keybind.State
						pcall(options.callback, Keybind.State)
					else
						pcall(options.callback)
					end
				end
			end)

			-- Provide API
			function Keybind:SetKey(key)
				if typeof(key) == "EnumItem" then
					Keybind.Key = key
					Keybind["kb_bind"].Text = key.Name
				end
			end

			function Keybind:SetMode(m)
				if m == "toggle" or m == "once" then
					options.mode = m
				end
			end

			function Keybind:SetCallback(fn)
				if type(fn) == "function" then
					options.callback = fn
				end
			end

			function Keybind:GetState()
				return Keybind.State
			end

			function Keybind:Destroy()
				if conn_select then conn_select:Disconnect() end
				if conn_exec then conn_exec:Disconnect() end
				if Keybind["kb_frame"] then Keybind["kb_frame"]:Destroy() end
			end

			return Keybind
		end
return Tab
	end
	
	return GUI
end

return Library
