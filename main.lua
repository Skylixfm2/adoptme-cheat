print("=== AUTO QUEST ŒUF v61 - Rayfield UI + Auto Shower + Auto Dailies ===")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Cheat Adopt Me | by SkylixFM",
    LoadingTitle = "Auto Quest Œuf",
    LoadingSubtitle = "v61 - by SkylixFM",
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

-- ==================== AUTO QUEST ŒUF (Dailies) ====================
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
        if not manager or not manager.serialized_tabs then return end

        for _, tabData in pairs(manager.serialized_tabs) do
            for dailyId, _ in pairs(tabData.active_dailies or {}) do
                local daily = DailiesClient.get_local_daily(dailyId)
                if daily and not daily:is_action_running() then
                    pcall(function()
                        daily:do_action()
                    end)
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
            Rayfield:Notify("Auto Quest Œuf", "Activé - Complétion automatique", 4483362458)
            
            QuestConnection = RunService.Heartbeat:Connect(function()
                if not AutoQuestEnabled then return end
                AutoCompleteDailies()
            end)

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

QuestTab:CreateButton({
    Name = "🔍 Scanner Dailies Actuels",
    Callback = function()
        pcall(function()
            local DailiesClient = require(ReplicatedStorage:FindFirstChild("DailiesClient", true))
            local manager = DailiesClient.get_manager()
            print("=== DAILIES ACTUELS ===")
            for tabName, tab in pairs(manager.serialized_tabs or {}) do
                print("Tab:", tabName)
                for id, _ in pairs(tab.active_dailies or {}) do
                    print("   → Daily ID:", id)
                end
            end
            Rayfield:Notify("Scanner terminé", "Regarde la console F9", 4483362458)
        end)
    end
})

QuestTab:CreateButton({
    Name = "Claim All Rewards Now",
    Callback = function()
        ClaimDailyRewards()
        Rayfield:Notify("Récompenses", "Claimées manuellement", 4483362458)
    end
})

-- ==================== AUTO SHOWER PET ====================
Tab:CreateButton({
    Name = "🛁 Auto Shower Pet",
    Callback = function()
        local success, EquippedPets = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Fsys")).load("EquippedPets")
        end)
        if not success or not EquippedPets then
            Rayfield:Notify("Erreur", "Impossible de charger EquippedPets", 4483362458)
            return
        end

        local pet = EquippedPets.choose_wrapper()
        if not pet or not pet.char then
            Rayfield:Notify("Erreur", "Équipe un pet d'abord !", 4483362458)
            return
        end

        local petRoot = pet.char:FindFirstChild("HumanoidRootPart")
        if not petRoot then
            Rayfield:Notify("Erreur", "PetRoot non trouvé", 4483362458)
            return
        end

        -- Détection améliorée des douches
        local shower = nil
        local minDist = math.huge
        for _, obj in ipairs(Workspace:GetDescendants()) do
            local name = obj.Name:lower()
            if name:find("shower") or name:find("modernshower") or obj:FindFirstChild("Smoke") then
                local part = obj.PrimaryPart or obj:FindFirstChild("Center") or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = (part.Position - petRoot.Position).Magnitude
                    if dist < minDist and dist < 150 then
                        minDist = dist
                        shower = obj
                    end
                end
            end
        end

        if not shower then
            Rayfield:Notify("Erreur", "Aucune douche (ModernShower) trouvée", 4483362458)
            return
        end

        local showerPart = shower.PrimaryPart or shower:FindFirstChild("Center") or shower:FindFirstChildWhichIsA("BasePart")
        if showerPart then
            petRoot.CFrame = showerPart.CFrame * CFrame.new(0, 3, 0)
            Rayfield:Notify("Auto Shower", "Pet téléporté dans la douche !", 4483362458)
            task.wait(1)
            Rayfield:Notify("Auto Shower", "Le pet devrait commencer à se laver...", 4483362458)
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

-- ==================== AUTO HUNGRY / THIRSTY ====================
local AilmentsClient
for _, v in ipairs(game:GetDescendants()) do
    if v:IsA("ModuleScript") and v.Name == "AilmentsClient" then
        AilmentsClient = require(v)
        break
    end
end

if AilmentsClient then
    AilmentsClient.get_ailment_created_signal():Connect(function(ailment)
        if not ailment then return end
        if ailment.id == "hungry" then
            local food = findItem("hungry")
            if food then 
                pcall(function() 
                    local ctm = require(ReplicatedStorage:FindFirstChild("ClientToolManager", true))
                    if ctm and ctm.backpack_equip then ctm.backpack_equip(food) end 
                end) 
            end
        elseif ailment.id == "thirsty" then
            local drink = findItem("thirsty")
            if drink then 
                pcall(function() 
                    local ctm = require(ReplicatedStorage:FindFirstChild("ClientToolManager", true))
                    if ctm and ctm.backpack_equip then ctm.backpack_equip(drink) end 
                end) 
            end
        end
    end)
end

-- ==================== FOOD BUTTONS ====================
Tab:CreateButton({ 
    Name = "🍔 Équiper Sandwich (Hungry)", 
    Callback = function()
        local food = findItem("hungry")
        if food then
            pcall(function()
                local ctm = require(ReplicatedStorage:FindFirstChild("ClientToolManager", true))
                if ctm and ctm.backpack_equip then ctm.backpack_equip(food) end
            end)
            Rayfield:Notify("Succès", "Sandwich équipé", 4483362458)
        else
            Rayfield:Notify("Erreur", "Aucun sandwich", 4483362458)
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
                if ctm and ctm.backpack_equip then ctm.backpack_equip(drink) end
            end)
            Rayfield:Notify("Succès", "Boisson équipée", 4483362458)
        else
            Rayfield:Notify("Erreur", "Aucune boisson", 4483362458)
        end
    end
})

Rayfield:Notify("Panel Chargé", "v61 - Auto Quest Œuf + Shower", 4483362458)
print("v61 chargé avec succès !")
