local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local PlayerGui = Player:WaitForChild("PlayerGui")
local MainUI = PlayerGui:WaitForChild("Everything")

local Remote = game:GetService("ReplicatedStorage"):WaitForChild("Settings")

local Humanoid : Humanoid = Character:WaitForChild("Humanoid")
Humanoid.UseJumpPower = true

local SetUpHumanProps = function(Prompt : string, Property : string)
	local Prompt : TextBox = MainUI:WaitForChild(Prompt)
	Prompt:GetPropertyChangedSignal("Text"):Connect(function()
		Prompt.Text = string.gsub(Prompt.Text, "[^%d.]", "")
	end)
	Prompt.FocusLost:Connect(function()
		local Text = string.gsub(Prompt.Text, "[^%d.]", "")
		if #Text == 0 then
			Text = Humanoid[Property]
		else
			Remote:FireServer(Property, tonumber(Text) or Humanoid[Property])
		end
		Prompt.Text = Text
	end)
end
SetUpHumanProps("WS", "WalkSpeed")
SetUpHumanProps("JP", "JumpPower")