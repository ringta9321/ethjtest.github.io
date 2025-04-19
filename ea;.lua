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
local unicornFound = false -- Track whether Unicorn is found
local fallbackUsed = false -- Track whether fallback was used

-- Function for tweening
local function tweenTo(targetPosition, duration)
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out) -- Proper arguments for TweenInfo.new
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

-- Attempt to sit on a target's seat
local function trySit(target, seatName)
    local seat = target:FindFirstChild(seatName)
    if seat then
        -- Check if the seat is occupied
        if seat.Occupant then
            print(target.Name .. "'s seat is occupied! Cannot sit down.")
            return false -- Seat is occupied
        else
            -- Sit on the seat
            tweenTo(seat.Position, duration)
            seat:Sit(humanoid)
            print("Successfully seated on " .. target.Name .. "!")
            return true -- Successfully seated
        end
    else
        print(target.Name .. " found, but it does not have a valid seat!")
        return false -- No valid seat
    end
end

-- Step-based tweening to locate Unicorn
for z = startZ, endZ, stepZ do
    -- Tween smoothly to the next position
    tweenTo(Vector3.new(x, y, z), duration)

    -- Locate Unicorn in the specified folder
    print("Searching for Unicorn...")
    local unicorn = game.Workspace.Baseplates.Baseplate.CenterBaseplate.Animals:FindFirstChild("Unicorn")
    if unicorn and unicorn:IsA("Model") then
        logEntity("Unicorn", unicorn.PrimaryPart.Position)

        local unicornSeat = unicorn:FindFirstChild("VehicleSeat")
        if unicornSeat then
            if trySit(unicorn, "VehicleSeat") then
                unicornFound = true
                break -- Successfully seated on Unicorn, exit loop
            end
        else
            print("Unicorn does not have a seat! Moving to fallback options...")
            unicornFound = true
            break -- Exit loop since Unicorn is found but has no seat
        end
    end
end

-- If Unicorn has no seat, search fallback options
if unicornFound and not fallbackUsed then
    print("Unicorn found, but fallback options are required.")

    -- Fallback Option 1: Locate Model_Horse
    local horse = game.Workspace.Baseplates.Baseplate.CenterBaseplate.Animals:FindFirstChild("Model_Horse")
    if horse and horse:IsA("Model") then
        logEntity("Horse", horse.PrimaryPart.Position)

        if trySit(horse, "VehicleSeat") then
            fallbackUsed = true
        else
            print("Unable to sit on Horse! Checking further fallback...")
        end
    end

    -- Fallback Option 2: Locate Chair in Workspace.RuntimeItems
    local chair = game.Workspace.RuntimeItems:FindFirstChild("Chair")
    if chair then
        local seat = chair:FindFirstChild("Seat")
        if seat then
            if trySit(chair, "Seat") then
                fallbackUsed = true
            else
                print("Unable to sit on Chair!")
            end
        else
            print("Chair found, but it does not have a Seat!")
        end
    end
end

-- Final check after all options are exhausted
if not unicornFound then
    print("Couldn't find Unicorn after reaching the end Z-coordinate.")
elseif unicornFound and not fallbackUsed then
    print("Couldn't find a suitable fallback seat after finding the Unicorn without a seat.")
end
