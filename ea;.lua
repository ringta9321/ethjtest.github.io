local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Variables for tweening along Z-coordinate
local x = 57
local y = 3
local startZ = 30000
local endZ = -49032.99
local stepZ = -2000
local duration = 0.5
local loggedEntities = {}

-- Function for tweening
local function tweenTo(targetPosition, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
    local goal = {CFrame = CFrame.new(targetPosition)}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
    tween.Completed:Wait()
end

-- Helper function to log unique entities
local function logEntity(name, position)
    local roundedX = math.floor(position.X)
    local roundedY = math.floor(position.Y)
    local roundedZ = math.floor(position.Z)
    local key = name .. "_" .. roundedX .. "_" .. roundedY .. "_" .. roundedZ

    if not loggedEntities[key] then
        print(name, "found at coordinates: X =", roundedX, "Y =", roundedY, "Z =", roundedZ)
        loggedEntities[key] = true
    end
end

-- Step-based tweening to locate Unicorn
for z = startZ, endZ, stepZ do
    -- Tween smoothly to the next position
    tweenTo(Vector3.new(x, y, z), duration)

    -- Locate Unicorn in the specified folder
    local unicorn = game.Workspace.Baseplates.Baseplate.CenterBaseplate.Animals:FindFirstChild("Unicorn")
    if unicorn and unicorn:IsA("Model") then
        logEntity("Unicorn", unicorn.PrimaryPart.Position)

        local unicornSeat = unicorn:FindFirstChild("VehicleSeat")
        if unicornSeat then
            -- Sit on the Unicorn's seat immediately
            tweenTo(unicornSeat.Position, duration)
            unicornSeat:Sit(humanoid)
            print("Successfully seated on Unicorn!")
            break
        else
            print("Unicorn found, but it does not have a seat!")
            break
        end
    end
end
