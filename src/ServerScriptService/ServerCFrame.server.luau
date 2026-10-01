--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// Constants
const IsStudio = RunService:IsStudio()
const CharacterRCParams = setmetatable({}, {__mode = "k"})
const AllPlayers = Players:GetPlayers() do
	Players.PlayerAdded:Connect(function(Player)
		AllPlayers[#AllPlayers+1] = Player
		
		Player:SetAttribute("NetworkPing", IsStudio and 0.1 or Player:GetNetworkPing())
		
		Player.CharacterAdded:Connect(function(Character)
			local CharacterRCParam = RaycastParams.new() do
				CharacterRCParam.FilterType = Enum.RaycastFilterType.Exclude
				CharacterRCParam.FilterDescendantsInstances = {Character}
				CharacterRCParam.RespectCanCollide = true
				CharacterRCParam.IgnoreWater = true
			end
			CharacterRCParams[Character] = CharacterRCParam; CharacterRCParam = nil
			
			Character.Destroying:Wait() do
				CharacterRCParams[Character] = nil
			end
		end)
		Player.CharacterRemoving:Connect(game.Destroy)
		
		Player.Destroying:Wait() do
			local Index = table.find(AllPlayers, Player)
			if Index then
				table.remove(AllPlayers, Index)
			end
		end
	end)
end

--// Main
if not IsStudio then
	task.spawn(function()
		while true do
			local DeltaTime = task.wait(10)
			for Index, Player in next, AllPlayers do
				Player:SetAttribute("NetworkPing", Player:GetNetworkPing())
			end
		end
	end)
end

game:GetService("ReplicatedStorage").Settings.OnServerEvent:Connect(function(Player, Property : "WalkSpeed" | "JumpPower", Value : number)
	local Character = Player.Character
	if Character then
		local Humanoid : Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			local Value = tonumber(Value)
			if Property == "WalkSpeed" then
				Humanoid.WalkSpeed = Value or 16
			elseif Property == "JumpPower" then
				Humanoid.JumpPower = Value or 50
			end
		end
	end
end)

while true do
	local DeltaTime = task.wait()
	for Index, Player in next, AllPlayers do
		local Character = Player.Character
		local Root = Character and Character.PrimaryPart
		if Root then
			do -- Server
				local Hurtbox : typeof(script.Server) do
					local Name = `{Character}_Server`
					Hurtbox = workspace.Hurtboxes:FindFirstChild(Name) or Instance.fromExisting(script.Server) do
						Hurtbox.Name = Name
						Hurtbox.Size = Root.Size
						Hurtbox.CFrame = Root.CFrame
						Hurtbox.Parent = workspace.Hurtboxes
					end
				end
			end

			do -- Predicted
				const CompensationPing = math.clamp((Player:GetAttribute("NetworkPing") or Player:GetNetworkPing())*2000, 75, 180)/75

				local Walkspeed : number do
					local BodyMover : BodyMover = Root:FindFirstChildWhichIsA("BodyMover", true)
					if BodyMover then
						if BodyMover.ClassName == "BodyPosition" then
							Walkspeed = (BodyMover.Position-Root.Position).Magnitude
						elseif BodyMover.ClassName == "BodyVelocity" then
							Walkspeed = BodyMover.Velocity.Magnitude
						end
					else
						local Constraint : Constraint = Root:FindFirstChildWhichIsA("Constraint", true)
						if Constraint then
							if Constraint.ClassName == "AlignPosition" then
								local Destination = Constraint.Mode.Name == "OneAttachment" and Constraint.Position or Constraint.Attachment1 and Constraint.Attachment1.Position or nil
								if Destination then
									Walkspeed = (Destination-Root.Position).Magnitude
								end
							elseif Constraint.ClassName == "LinearVelocity" then
								Walkspeed = Constraint.LinearVelocity.Magnitude
							end
						else
							Walkspeed = (Character:FindFirstChildOfClass("Humanoid")::Humanoid).WalkSpeed
						end
					end
				end
				if Walkspeed < 1 then
					Walkspeed = 1
				end

				local Hurtbox : typeof(script.Predicted) do
					local Name = `{Character}_Predicted`
					Hurtbox = workspace.Hurtboxes:FindFirstChild(Name) or Instance.fromExisting(script.Predicted) do
						Hurtbox.Name = Name
						Hurtbox.Size = Root.Size
					end
				end

				local Product do
					const Delta = DeltaTime*CompensationPing*6
					local Direction = Root.AssemblyLinearVelocity*Delta do
						const Interval = Walkspeed*Delta
						const Magnitude = Direction ~= Vector3.zero and Direction.Magnitude
						if Magnitude and Magnitude <= Interval then
							Product = CFrame.new(Root.Position+Direction)*Root.CFrame.Rotation
						else
							if Magnitude then
								--warn(Direction, "|", Magnitude, "|", Interval, "|", Interval/Magnitude)
								Direction *= Interval/Magnitude
							end
							Product = Root.CFrame+Direction
						end
					end

					local MoveDelta = Product.Position-Root.Position
					if MoveDelta.Magnitude >= 1024/2 then
						MoveDelta = MoveDelta.Unit*(1024/2-1)
					end
					if MoveDelta.Magnitude > 1e-4 then
						const CastOrigin = Root.Position-MoveDelta
						const Blockcast = workspace:Blockcast(CFrame.new(CastOrigin)*Product.Rotation, Hurtbox.Size, MoveDelta*2, CharacterRCParams[Character])
						if Blockcast then
							Product = CFrame.new(CastOrigin+MoveDelta.Unit*Blockcast.Distance)*Product.Rotation
						end
					end
				end
				
				do -- Set
					Hurtbox.CFrame = Product
					Hurtbox.Parent = workspace.Hurtboxes
				end
			end
		end
	end
end