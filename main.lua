print("=== AUTO QUEST ŒUF v63 - Fix TP + Food ===")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Cheat Adopt Me | by SkylixFM",
    LoadingTitle = "Auto Quest Œuf",
    LoadingSubtitle = "v63 - Fix TP + Food",
    ConfigurationSaving = { Enabled = true, FolderName = "AutoQuestOeuf", FileName = "Config" },
    KeySystem = false
})

local Tab = Window:CreateTab("Main", 4483362458)
local QuestTab = Window:CreateTab("Auto Quest Œuf", 4483362458)

-- === findItem ===
local function findItem(keyword)
    local success, inventory = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Fsys", 5)).load("Inventory")
    end)
    if not success or not inventory then return nil end
    for _, item in pairs(inventory) do
        if item and item.name and item.name:lower():find(keyword:lower()) then
            return item
        end
    end
    return nil
end

-- ==================== AUTO SHOWER PET (Fix TP Joueur) ====================
Tab:CreateButton({
    Name = "🛁 Auto Shower Pet (Pro TP)",
    Callback = function()
        local EquippedPets = nil
        pcall(function()
            EquippedPets = require(ReplicatedStorage:WaitForChild("Fsys")).load("EquippedPets")
        end)

        local pet = EquippedPets and EquippedPets.choose_wrapper()
        if not pet or not pet.char then
            Rayfield:Notify("Erreur", "Équipe un pet d'abord !", 4483362458)
            return
        end

        local petRoot = pet.char:FindFirstChild("HumanoidRootPart")
        if not petRoot then
            Rayfield:Notify("Erreur", "PetRoot non trouvé", 4483362458)
            return
        end

        -- Recherche ModernShower
        local shower = nil
        local houseInteriors = Workspace:FindFirstChild("HouseInteriors")
        if houseInteriors then
            shower = houseInteriors:FindFirstChild("ModernShower", true)
        end

        if shower then
            local center = shower:FindFirstChild("Center") or shower.PrimaryPart
            if center then
                -- TP UNIQUEMENT le pet (fix)
                petRoot.CFrame = center.CFrame * CFrame.new(0, 2, 0)
                Rayfield:Notify("Auto Shower", "Pet téléporté DIRECTEMENT dans la douche !", 4483362458)
                print("✅ Pet téléporté dans la douche")
                task.wait(2)
                Rayfield:Notify("Auto Shower", "Attends que le pet se lave...", 4483362458)
            else
                Rayfield:Notify("Erreur", "Center non trouvé", 4483362458)
            end
        else
            Rayfield:Notify("Erreur", "ModernShower non trouvé", 4483362458)
        end
    end,
})

-- ==================== SPEED HACK ====================
local speedValue = 100
local speedConnection = nil

Tab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Callback = function(Value)
        if Value then
            if speedConnection then speedConnection:Disconnect() end
            speedConnection = RunService.Heartbeat:Connect(function()
                local char = player.Character
                if char and char:FindFirstChild("Humanoid") then
                    char.Humanoid.WalkSpeed = speedValue
                end
            end)
            Rayfield:Notify("Speed Hack", "Activé ("..speedValue..")", 4483362458)
        else
            if speedConnection then speedConnection:Disconnect() end
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = 16
            end
            Rayfield:Notify("Speed Hack", "Désactivé", 4483362458)
        end
    end,
})

-- ==================== TELEPORTS ====================
local tps = {
    ["Buy Water"] = CFrame.new(3020.41, 6960.26, -3002.70),
    ["Buy Food"] = CFrame.new(3020.41, 6960.26, -3042.36),
    ["Camping"] = CFrame.new(-18.79, 31.93, -1053.97),
    ["Aire de Jeu"] = CFrame.new(-353.36, 30.89, -1759.09),
}

for name, cf in pairs(tps) do
    Tab:CreateButton({
        Name = "TP " .. name,
        Callback = function()
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then 
                root.CFrame = cf 
                Rayfield:Notify("TP", name, 4483362458)
            end
        end
    })
end

-- ==================== FOOD (Fixé) ====================
Tab:CreateButton({ 
    Name = "🍔 Équiper Sandwich (Hungry)", 
    Callback = function()
        local food = findItem("hungry")
        if food then
            pcall(function()
                local ctm = require(ReplicatedStorage:FindFirstChild("ClientToolManager", true))
                if ctm and ctm.backpack_equip then 
                    ctm.backpack_equip(food) 
                    Rayfield:Notify("Succès", "Sandwich équipé", 4483362458)
                end
            end)
        else
            Rayfield:Notify("Erreur", "Aucun sandwich trouvé", 4483362458)
        end
    end
})

Tab:CreateButton({ 
    Name = "🥤 Équiper Boisson (Thirsty)", 
    Callback = function()
        local drink = findItem("thirsty")
        if drink then
            pcall(function()
                local ctm = require(ReplicatedStorage:FindFirstChild("ClientToolManager", true))
                if ctm and ctm.backpack_equip then 
                    ctm.backpack_equip(drink) 
                    Rayfield:Notify("Succès", "Boisson équipée", 4483362458)
                end
            end)
        else
            Rayfield:Notify("Erreur", "Aucune boisson trouvée", 4483362458)
        end
    end
})

-- ==================== AUTO QUEST ŒUF ====================
local AutoQuestEnabled = false
local QuestConnection = nil

local function ClaimDailyRewards()
    pcall(function()
        local DailiesNet = require(ReplicatedStorage:FindFirstChild("DailiesNetService", true))
        if DailiesNet and DailiesNet.try_to_claim_daily_rewards then
            DailiesNet.try_to_claim_daily_rewards(player)
        end
    end)
end

local function AutoCompleteDailies()
    pcall(function()
        local DailiesClient = require(ReplicatedStorage:FindFirstChild("DailiesClient", true))
        if not DailiesClient then return end
        local manager = DailiesClient.get_manager()
        if not manager then return end

        for _, tabData in pairs(manager.serialized_tabs or {}) do
            for dailyId, _ in pairs(tabData.active_dailies or {}) do
                local daily = DailiesClient.get_local_daily(dailyId)
                if daily and not daily:is_action_running() then
                    pcall(function() daily:do_action() end)
                end
            end
        end
    end)
end

QuestTab:CreateToggle({
    Name = "🔄 Auto Quest Œuf (Dailies)",
    CurrentValue = false,
    Callback = function(Value)
        AutoQuestEnabled = Value
        if Value then
            Rayfield:Notify("Auto Quest Œuf", "Activé", 4483362458)
            QuestConnection = RunService.Heartbeat:Connect(AutoCompleteDailies)
            
            task.spawn(function()
                while AutoQuestEnabled do
                    ClaimDailyRewards()
                    task.wait(25)
                end
            end)
        else
            if QuestConnection then QuestConnection:Disconnect() end
            Rayfield:Notify("Auto Quest Œuf", "Désactivé", 4483362458)
        end
    end
})

Rayfield:Notify("Panel Chargé", "v63 - TP Fix + Food Fix", 4483362458)
print("v63 chargé avec succès !")
