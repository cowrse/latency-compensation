local Player = game:GetService("Players").LocalPlayer

local RenderStepped = game:GetService("RunService").RenderStepped
while true do
	local DeltaTime = RenderStepped:Wait()
	
	local Character = Player.Character
	local Root = Character and Character.PrimaryPart
	if Root then
		local Hurtbox : typeof(script.Client) do
			local Name = `{Character}_Client`
			Hurtbox = workspace.Hurtboxes:FindFirstChild(Name) or Instance.fromExisting(script.Client) do
				Hurtbox.Name = Name
				Hurtbox.Size = Root.Size
				Hurtbox.CFrame = Root.CFrame
				Hurtbox.Parent = workspace.Hurtboxes
			end
		end
	end
end