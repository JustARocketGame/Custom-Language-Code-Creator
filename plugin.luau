assert(plugin, "Run this plugin as Roblox Studio Plugin")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local SelectionService = game:GetService("Selection")

local PluginToolbar = plugin:CreateToolbar("Custom Language (v 1.0)")

local CreateCodeButton = PluginToolbar:CreateButton("Create Code", "Custom Language Code Creator - Create Code", "rbxassetid://11252798119")
local CreateLanguageButton = PluginToolbar:CreateButton("Create Language", "Custom Language Code Creator - Create Language", "rbxassetid://18209589139")
local BuildCodeButton = PluginToolbar:CreateButton("Build Code", "Custom Language Code Creator - Build Language", "rbxassetid://12845081")

local CreateCodeWidget = plugin:CreateDockWidgetPluginGui("cc", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 400, 500, 250, 250))
local CreateLanguageWidget = plugin:CreateDockWidgetPluginGui("cl", DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 400, 500, 250, 250))


spawn(function()
	while task.wait() do

		local LanguagesFolder = ReplicatedStorage:FindFirstChild("Languages")
		if not LanguagesFolder then
			LanguagesFolder = Instance.new("Folder", ReplicatedStorage)
			LanguagesFolder.Name = "Languages"
		end		

		local ArteLanguage = LanguagesFolder:FindFirstChild("ArteLanguage")
		if not ArteLanguage then
			script.ArteLanguage:Clone().Parent = LanguagesFolder
		end
		
		local ReadFolder = ReplicatedStorage:FindFirstChild("Read")
		if not ReadFolder then
			ReadFolder = Instance.new("Folder", ReplicatedStorage)
			ReadFolder.Name = "Read"		
		end
		
		local BuildFolder = ReplicatedStorage:FindFirstChild("Build")
		if not BuildFolder then
			BuildFolder = Instance.new("Folder", ReplicatedStorage)
			BuildFolder.Name = "Build"
		end
		
		local BuildScript = ServerScriptService:FindFirstChild("BuildScript")
		if not BuildScript then
			BuildScript = script.BuildScript:Clone()
			BuildScript.Parent = ServerScriptService
			BuildScript.Enabled = true
		end
		
		if not game.Players.LocalPlayer then
			for index, read_object in pairs(ReadFolder:GetChildren()) do
				if read_object then
					
					local Code = read_object.Source
					local Language = read_object:WaitForChild("Language").Value
					
					local NeedLanguage = ReplicatedStorage.Languages:WaitForChild(Language)
					require(NeedLanguage.Main).Run(Code)
					
					wait(0.1)
					
					read_object:Destroy()

				end
			end
		end

	end
end)


local function Log(Message)

	print("[Custom Language Code Creator] ".. Message)

end


CreateCodeButton.ClickableWhenViewportHidden = true
CreateLanguageButton.ClickableWhenViewportHidden = true
BuildCodeButton.ClickableWhenViewportHidden = true

CreateCodeWidget.Title = "Create Code"
CreateLanguageWidget.Title = "Create Language"

local CreateCodeFrame = script.CreateCode.Frame
local CreateLanguageFrame = script.CreateLanguage.Frame

CreateCodeFrame.Parent = CreateCodeWidget
CreateLanguageFrame.Parent = CreateLanguageWidget

CreateCodeButton.Click:Connect(function()

	CreateCodeWidget.Enabled = not CreateCodeWidget.Enabled

	local Selected = "ArteLanguage"

	local LanguagesFolder = ReplicatedStorage:FindFirstChild("Languages")
	local Languages = LanguagesFolder:GetChildren()

	for languageIndex, language in pairs(CreateCodeFrame.ScrollingFrame:GetChildren()) do
		if language then
			language:Destroy()
		end
	end

	local UiListLayout = Instance.new("UIListLayout", CreateCodeFrame.ScrollingFrame)
	UiListLayout.Padding = UDim.new(0, 15)

	for languageIndex, language in pairs(Languages) do

		local Button = script.CreateCode.LANGUAGE:Clone()
		Button.Text = language.Name
		Button.Parent = CreateCodeFrame.ScrollingFrame

		Button.MouseButton1Up:Connect(function()
			Selected = Button.Text
		end)

	end

	CreateCodeFrame.CreateButton.MouseButton1Up:Connect(function()

		local SelectedObjects = SelectionService:Get()
		local Objects = {}
		for index, object in pairs(SelectedObjects) do

			local SelectedObject = object
			if not SelectedObject then
				SelectedObject = game.ReplicatedStorage
			end

			local Code = script.Bros:Clone()
			Code.Name = "code.".. Selected
			Code.Enabled = true
			Code.Parent = object
			
			local LanguageFolder = ReplicatedStorage.Languages:FindFirstChild(Selected):Clone()
			LanguageFolder.Parent = Code
			LanguageFolder:SetAttribute("Language", ReplicatedStorage.Languages:FindFirstChild(Selected).Name)
			LanguageFolder.Name = "LanguageFolder"
			
			Code.HeBros.Parent = Code.Scripts
			Code.Scripts.HeBros.Name = "code.".. Selected

			table.insert(Objects, Code)

		end

		SelectionService:Set(Objects)
		
		Log("Succes To Create Code For Language ".. Selected.. "!")

	end)

end)

CreateLanguageButton.Click:Connect(function()
	
	CreateLanguageWidget.Enabled = not CreateLanguageWidget.Enabled
	CreateLanguageFrame.CreateButton.MouseButton1Up:Connect(function()
		
		local NewLanguage = script.ArteLanguage:Clone()
		NewLanguage.Name = CreateLanguageFrame.TextBox.Text
		NewLanguage.Parent = game.ReplicatedStorage.Languages
		
		SelectionService:Set({NewLanguage})
		
		CreateLanguageFrame.TextBox.Text = "LanguageName"
		
	end)
	
end)

BuildCodeButton.Click:Connect(function()
	local Select2 = SelectionService:Get()
	if not Select2 then
		warn("To build script please select script")
	else
		if #Select2 ~= 1 then
			warn("To build script please select only one script")
		else
			
			Log("Building Script, Please wait...")
			
			local Select = Select2[1]
			Select.Enabled = false
			
			local BuildCodeFolder = Instance.new("Folder", ReplicatedStorage.Build)
			BuildCodeFolder.Name = Select.Name
			
			local BuildCodeLanguage = Instance.new("StringValue", BuildCodeFolder)
			
			local s = ""
			local nextv = false

			for i=1, string.len(Select.Name) do

				local a = string.sub(Select.Name, i, i)
				local aa = s

				if nextv == false then
					if a == "." then
						nextv = true
					end
				else

					s = aa.. a

				end

			end
			
			BuildCodeLanguage.Value = s
			BuildCodeLanguage.Name = "Language"
			
			local ScriptsFolder = Instance.new("Folder", BuildCodeFolder)
			ScriptsFolder.Name = "Scripts"
			
			for index, script2 in pairs(Select.Scripts:GetChildren()) do
				
				local ScriptValue = Instance.new("StringValue", ScriptsFolder)
				ScriptValue.Value = script2.Source
				
			end
			
			Log("Succes!")
			
		end
	end
end)
