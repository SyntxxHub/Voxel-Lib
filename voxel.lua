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
		Visible = true
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
		GUI["7"]["SortOrder"] = Enum.SortOrder.LayoutOrder;
	end
	
	-- Draggable functionality
	do
		local dragging = false
		local dragInput
		local dragStart
		local startPos

		local function update(input)
			local delta = input.Position - dragStart
			Library:tween(GUI["2"], {
				Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			})
		end

		GUI["2"].InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
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
	end
	
	-- Insert key toggle
	UIS.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Enum.KeyCode.Insert then
			GUI.Visible = not GUI.Visible
			Library:tween(GUI["1"], {
				BackgroundTransparency = GUI.Visible and 0 or 1
			})
			
			for _, child in pairs(GUI["1"]:GetDescendants()) do
				if child:IsA("GuiObject") then
					if child:IsA("TextLabel") or child:IsA("TextButton") then
						Library:tween(child, {
							TextTransparency = GUI.Visible and 0 or 1
						})
					end
					if child:IsA("ImageLabel") or child:IsA("ImageButton") then
						Library:tween(child, {
							ImageTransparency = GUI.Visible and 0 or 1
						})
					end
					Library:tween(child, {
						BackgroundTransparency = GUI.Visible and (child.BackgroundTransparency == 1 and 1 or 0) or 1
					})
				end
			end
		end
	end)
	
	function GUI:CreateTab(options)
		options = Library:validate({
			name = "Tab",
		}, options or {})

		local Tab = {
			Hover = false,
			Active = false
		}

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
		Tab["a"].Size = UDim2.new(1, 0, 0.10976, 0)
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
		
		-- StarterGui.Library.VoxelUI.Main.Frames
		Tab["10"] = Instance.new("Frame", GUI["2"]);
		Tab["10"]["BorderSizePixel"] = 0;
		Tab["10"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
		Tab["10"]["Size"] = UDim2.new(0.76944, 0, 1, 0);
		Tab["10"]["Position"] = UDim2.new(0.23056, 0, 0, 0);
		Tab["10"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
		Tab["10"]["Name"] = [[Frames]];
		Tab["10"]["BackgroundTransparency"] = 1;
		
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
			end
		end)

		Tab["a"].MouseLeave:Connect(function()
			if not Tab.Active then
				Library:tween(Tab["a"], {
					BackgroundTransparency = 1,
					BackgroundColor3 = defaultColor
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
		function Tab:Activate()
			Tab.Active = true
			GUI.CurrentTab = Tab

			for _, child in pairs(GUI["2"]:GetChildren()) do
				if child:IsA("Frame") and child.Name == "Frames" then
					child.Visible = false
				end
			end

			Tab["10"].Visible = true
			Tab["1a"].Visible = true

			Library:tween(Tab["a"], {
				BackgroundTransparency = 0.3,
				BackgroundColor3 = activeColor
			})
		end

		function Tab:Deactivate()
			Tab.Active = false
			Tab["10"].Visible = false
			Tab["1a"].Visible = false
			Library:tween(Tab["a"], {
				BackgroundTransparency = 1,
				BackgroundColor3 = defaultColor
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
					0.2,
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
						Library:tween(Toggle["53"], {BackgroundColor3 = Color3.fromRGB(69, 79, 94)})
						Library:tween(Toggle["53"], {BackgroundTransparency = 0})
						Library:tween(Toggle["55"], {Color = Color3.fromRGB(69, 79, 94)})
						Library:tween(Toggle["56"], {ImageTransparency = 0})
					else
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

				Toggle["57"].MouseLeave:Connect(function()
					Toggle.Hover = false
					if not Toggle.MouseDown then
						Library:tween(Toggle["5a"], {Color = Color3.fromRGB(70, 80, 95)})
						Library:tween(Toggle["5b"], {TextColor3 = Color3.fromRGB(140, 155, 175)})
						Library:tween(Toggle["60"], {Color = Color3.fromRGB(70, 80, 95)})
					end
				end)

				UIS.InputBegan:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 and Toggle.Hover then
						Toggle.MouseDown = true
						Library:tween(Toggle["5a"], {Color = Color3.fromRGB(55, 65, 80)})
						Library:tween(Toggle["5b"], {TextColor3 = Color3.fromRGB(120, 135, 155)})
						Library:tween(Toggle["60"], {Color = Color3.fromRGB(55, 65, 80)})
						Toggle:Toggle()
					end
				end)

				UIS.InputEnded:Connect(function(input, gpe)
					if gpe then return end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						Toggle.MouseDown = false
						if Toggle.Hover then
							Library:tween(Toggle["5a"], {Color = Color3.fromRGB(70, 80, 95)})
							Library:tween(Toggle["5b"], {TextColor3 = Color3.fromRGB(70, 80, 95)})
							Library:tween(Toggle["60"], {Color = Color3.fromRGB(70, 80, 95)})
						else
							Library:tween(Toggle["5a"], {Color = Color3.fromRGB(55, 65, 80)})
							Library:tween(Toggle["5b"], {TextColor3 = Color3.fromRGB(55, 65, 80)})
							Library:tween(Toggle["60"], {Color = Color3.fromRGB(55, 65, 80)})
						end
					end
				end)
			end
			
			return Toggle
		end
		
		function Tab:Dropdown(options)
			options = Library:validate({
				name = "Dropdown",
				options = {"Option 1", "Option 2", "Option 3"},
				default = "Option 1",
				callback = function(v) print(v) end
			}, options or {})

			local Dropdown = {
				Hover = false,
				Open = false,
				Options = {},
				Selected = options.default
			}

			do
				-- Main Dropdown Frame
				Dropdown["1b"] = Instance.new("Frame", Tab["1a"]);
				Dropdown["1b"]["BorderSizePixel"] = 0;
				Dropdown["1b"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Dropdown["1b"]["ClipsDescendants"] = true;
				Dropdown["1b"]["Size"] = UDim2.new(0.95565, 0, 0.09684, 0);
				Dropdown["1b"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Dropdown["1b"]["Name"] = [[Dropdown]];

				-- Gradient
				Dropdown["1c"] = Instance.new("UIGradient", Dropdown["1b"]);
				Dropdown["1c"]["Rotation"] = 25;
				Dropdown["1c"]["Color"] = ColorSequence.new{
					ColorSequenceKeypoint.new(0.000, Color3.fromRGB(29, 33, 39)),
					ColorSequenceKeypoint.new(0.500, Color3.fromRGB(35, 40, 48)),
					ColorSequenceKeypoint.new(1.000, Color3.fromRGB(29, 33, 39))
				};

				-- Corner
				Dropdown["1d"] = Instance.new("UICorner", Dropdown["1b"]);
				Dropdown["1d"]["CornerRadius"] = UDim.new(0.1, 0);

				-- Stroke
				Dropdown["1e"] = Instance.new("UIStroke", Dropdown["1b"]);
				Dropdown["1e"]["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				Dropdown["1e"]["Color"] = Color3.fromRGB(70, 80, 95);

				-- Name Label
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
				Dropdown["1f"]["Size"] = UDim2.new(0.42078, 0, 0.65996, 0);
				Dropdown["1f"]["Text"] = options.name;
				Dropdown["1f"]["Name"] = [[Name]];
				Dropdown["1f"]["Position"] = UDim2.new(0.02491, 0, 0.11646, 0);

				Dropdown["20"] = Instance.new("UITextSizeConstraint", Dropdown["1f"]);
				Dropdown["20"]["MaxTextSize"] = 50;

				-- Options Container
				Dropdown["21"] = Instance.new("Frame", Dropdown["1b"]);
				Dropdown["21"]["BorderSizePixel"] = 0;
				Dropdown["21"]["BackgroundColor3"] = Color3.fromRGB(255, 255, 255);
				Dropdown["21"]["Size"] = UDim2.new(0.99935, 0, 0, 0);
				Dropdown["21"]["Position"] = UDim2.new(0, 0, 1.08699, 0);
				Dropdown["21"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Dropdown["21"]["Name"] = [[Options]];
				Dropdown["21"]["BackgroundTransparency"] = 1;
				Dropdown["21"]["Visible"] = false;

				-- UIListLayout for options
				Dropdown["26"] = Instance.new("UIListLayout", Dropdown["21"]);
				Dropdown["26"]["HorizontalAlignment"] = Enum.HorizontalAlignment.Center;
				Dropdown["26"]["Padding"] = UDim.new(0.1, 0);
				Dropdown["26"]["SortOrder"] = Enum.SortOrder.LayoutOrder;

				-- Dropdown Icon
				Dropdown["2f"] = Instance.new("ImageButton", Dropdown["1b"]);
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
			end

			-- Create option buttons
			for i, option in ipairs(options.options) do
				local OptionButton = {}
				
				OptionButton["btn"] = Instance.new("TextButton", Dropdown["21"]);
				OptionButton["btn"]["TextWrapped"] = true;
				OptionButton["btn"]["BorderSizePixel"] = 0;
				OptionButton["btn"]["TextSize"] = 17;
				OptionButton["btn"]["TextScaled"] = true;
				OptionButton["btn"]["BackgroundColor3"] = Color3.fromRGB(20, 23, 27);
				OptionButton["btn"]["FontFace"] = Font.new([[rbxasset://fonts/families/SourceSansPro.json]], Enum.FontWeight.Regular, Enum.FontStyle.Italic);
				OptionButton["btn"]["TextColor3"] = Color3.fromRGB(186, 218, 255);
				OptionButton["btn"]["Size"] = UDim2.new(0.95529, 0, 0, 25);
				OptionButton["btn"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				OptionButton["btn"]["Text"] = option;
				OptionButton["btn"]["Name"] = option;
				OptionButton["btn"]["AutoButtonColor"] = false;

				local btnCorner = Instance.new("UICorner", OptionButton["btn"]);
				btnCorner["CornerRadius"] = UDim.new(0.1, 0);

				local btnStroke = Instance.new("UIStroke", OptionButton["btn"]);
				btnStroke["ApplyStrokeMode"] = Enum.ApplyStrokeMode.Border;
				btnStroke["Color"] = Color3.fromRGB(44, 50, 59);

				local btnConstraint = Instance.new("UITextSizeConstraint", OptionButton["btn"]);
				btnConstraint["MaxTextSize"] = 50;

				-- Set initial state
				if option == Dropdown.Selected then
					OptionButton["btn"]["BackgroundColor3"] = Color3.fromRGB(25, 33, 47);
					btnStroke["Color"] = Color3.fromRGB(70, 80, 95);
				end

				-- Hover effects
				OptionButton["btn"].MouseEnter:Connect(function()
					if option ~= Dropdown.Selected then
						Library:tween(OptionButton["btn"], {BackgroundColor3 = Color3.fromRGB(38, 50, 71)})
						Library:tween(btnStroke, {Color = Color3.fromRGB(70, 80, 95)})
					end
				end)

				OptionButton["btn"].MouseLeave:Connect(function()
					if option ~= Dropdown.Selected then
						Library:tween(OptionButton["btn"], {BackgroundColor3 = Color3.fromRGB(20, 23, 27)})
						Library:tween(btnStroke, {Color = Color3.fromRGB(44, 50, 59)})
					end
				end)

				-- Click event
				OptionButton["btn"].MouseButton1Click:Connect(function()
					Dropdown:Select(option)
				end)

				table.insert(Dropdown.Options, OptionButton)
			end

			-- Dropdown functions
			function Dropdown:Select(option)
				Dropdown.Selected = option
				Dropdown["1f"].Text = options.name .. ": " .. option
				
				-- Update all option buttons
				for _, opt in ipairs(Dropdown.Options) do
					if opt["btn"].Text == option then
						Library:tween(opt["btn"], {BackgroundColor3 = Color3.fromRGB(25, 33, 47)})
						local stroke = opt["btn"]:FindFirstChildOfClass("UIStroke")
						if stroke then
							Library:tween(stroke, {Color = Color3.fromRGB(70, 80, 95)})
						end
					else
						Library:tween(opt["btn"], {BackgroundColor3 = Color3.fromRGB(20, 23, 27)})
						local stroke = opt["btn"]:FindFirstChildOfClass("UIStroke")
						if stroke then
							Library:tween(stroke, {Color = Color3.fromRGB(44, 50, 59)})
						end
					end
				end

				options.callback(option)
				Dropdown:Close()
			end

			function Dropdown:Open()
				if Dropdown.Open then return end
				Dropdown.Open = true
				Dropdown["21"].Visible = true
				
				local optionCount = #options.options
				local optionHeight = 25
				local spacing = optionHeight * 0.1
				local totalHeight = (optionHeight * optionCount) + (spacing * (optionCount - 1))
				
				Dropdown["21"]["Size"] = UDim2.new(0.99935, 0, 0, totalHeight)
				
				Library:tween(Dropdown["1b"], {
					Size = UDim2.new(0.95565, 0, 0, Dropdown["1b"].AbsoluteSize.Y + totalHeight + 10)
				})
				
				Library:tween(Dropdown["2f"], {Rotation = 180})
			end

			function Dropdown:Close()
				if not Dropdown.Open then return end
				Dropdown.Open = false
				
				Library:tween(Dropdown["1b"], {
					Size = UDim2.new(0.95565, 0, 0.09684, 0)
				}, function()
					Dropdown["21"].Visible = false
				end)
				
				Library:tween(Dropdown["2f"], {Rotation = 0})
			end

			function Dropdown:Toggle()
				if Dropdown.Open then
					Dropdown:Close()
				else
					Dropdown:Open()
				end
			end

			-- Hover effects for main dropdown
			Dropdown["1b"].MouseEnter:Connect(function()
				Dropdown.Hover = true
				Library:tween(Dropdown["1e"], {Color = Color3.fromRGB(97, 110, 131)})
				Library:tween(Dropdown["1f"], {TextColor3 = Color3.fromRGB(97, 110, 131)})
				Library:tween(Dropdown["2f"], {ImageColor3 = Color3.fromRGB(127, 143, 163)})
			end)

			Dropdown["1b"].MouseLeave:Connect(function()
				Dropdown.Hover = false
				Library:tween(Dropdown["1e"], {Color = Color3.fromRGB(70, 80, 95)})
				Library:tween(Dropdown["1f"], {TextColor3 = Color3.fromRGB(102, 119, 140)})
				Library:tween(Dropdown["2f"], {ImageColor3 = Color3.fromRGB(97, 113, 132)})
			end)

			-- Click to toggle
			Dropdown["2f"].MouseButton1Click:Connect(function()
				Dropdown:Toggle()
			end)

			-- Set initial text
			Dropdown["1f"].Text = options.name .. ": " .. Dropdown.Selected

			return Dropdown
		end
		
		return Tab
	end
	
	return GUI
end

return Library
