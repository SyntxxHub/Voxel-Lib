local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local coreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

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
		CurrentTab = nil
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
				Label["30"]["Size"] = UDim2.new(0.95565, 0, 0, 50); -- Start with pixel height
				Label["30"]["BorderColor3"] = Color3.fromRGB(0, 0, 0);
				Label["30"]["Name"] = [[Info]];
				Label["30"]["AutomaticSize"] = Enum.AutomaticSize.Y; -- ENABLE AUTOMATIC SIZING

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
				Label["36"]["Size"] = UDim2.new(1, 0, 0, 0); -- Width 100%, height auto
				Label["36"]["AutomaticSize"] = Enum.AutomaticSize.Y; -- ENABLE AUTO HEIGHT
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

		return Tab
	end
	
	return GUI
end
