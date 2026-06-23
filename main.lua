print("=== AUTO QUEST ŒUF v66 - Key System + Full Features ===")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Cheat Adopt Me | by SkylixFM",
    LoadingTitle = "Key System",
    LoadingSubtitle = "v66",
    ConfigurationSaving = { Enabled = true, FolderName = "AutoQuestOeuf", FileName = "Config" },
})

local Tab = Window:CreateTab("Main", 4483362458)

-- ==================== KEY SYSTEM ====================
local KEYS_JSON_URL = "https://raw.githubusercontent.com/Skylixfm2/adoptme-cheat/refs/heads/main/keys.json"

local function GetValidKeys()
    local success, response = pcall(function()
        return game:HttpGet(KEYS_JSON_URL)
    end)
    if not success then return {} end

    local success2, data = pcall(function()
        return game:GetService("HttpService"):JSONDecode(response)
    end)
    if not success2 then return {} end

    local keys = {}
    for _, entry in ipairs(data) do
        if entry.fullKey then
            table.insert(keys, entry.fullKey)
        end
    end
    return keys
end

local authenticated = false

Tab:CreateInput({
    Name = "🔑 Entre ta Key",
    PlaceholderText = "PCAML_XXXXXXXXXXXXXXXX",
    RemoveTextAfterFocusLost = false,
    Callback = function(key)
        if key == "" then return end
        
        local validKeys = GetValidKeys()
        for _, valid in ipairs(validKeys) do
            if valid == key then
                authenticated = true
                Rayfield:Notify("✅ Key Valide", "Accès autorisé !", 4483362458)
                task.wait(1)
                LoadFullCheat()
                return
            end
        end
        Rayfield:Notify("❌ Key Invalide", "Cette key n'existe pas", 4483362458)
    end,
})

-- ==================== CHEAT COMPLET ====================
function LoadFullCheat()
    
    -- TP Devant Ma Maison
    Tab:CreateButton({
        Name = "🏠 TP Devant Ma Maison",
        Callback = function()
            local houseInteriors = Workspace:FindFirstChild("HouseInteriors")
            if not houseInteriors then return end
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(0, 5, 0) -- À ajuster si besoin
                Rayfield:Notify("Succès", "Téléporté devant ta maison", 4483362458)
            end
        end,
    })

    -- Auto Shower (Joueur + Pet)
    Tab:CreateButton({
        Name = "🛁 Auto Shower (Joueur + Pet)",
        Callback = function()
            local EquippedPets = nil
            pcall(function()
                EquippedPets = require(ReplicatedStorage:WaitForChild("Fsys")).load("EquippedPets")
            end)

            local pet = EquippedPets and EquippedPets.choose_wrapper()
            local petRoot = pet and pet.char and pet.char:FindFirstChild("HumanoidRootPart")
            local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

            if not playerRoot then
                Rayfield:Notify("Erreur", "Personnage non chargé", 4483362458)
                return
            end

            local shower = Workspace:FindFirstChild("HouseInteriors", true):FindFirstChild("ModernShower", true)
            if not shower then
                Rayfield:Notify("Erreur", "ModernShower non trouvé", 4483362458)
                return
            end

            local center = shower:FindFirstChild("Center") or shower.PrimaryPart
            if center then
                local cf = center.CFrame
                playerRoot.CFrame = cf * CFrame.new(0, 3, -6)
                if petRoot then petRoot.CFrame = cf * CFrame.new(0, 3, -3.5) end
                Rayfield:Notify("Succès", "Joueur + Pet devant la douche", 4483362458)
            end
        end,
    })

    -- Speed Hack
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
                Rayfield:Notify("Speed Hack", "Activé", 4483362458)
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

    -- Food System
    local ClientData, InventoryDB = nil, nil
    pcall(function()
        local load = require(ReplicatedStorage:WaitForChild("Fsys")).load
        ClientData = load("ClientData")
        InventoryDB = load("InventoryDB")
    end)

    local function findItem(ailmentType)
        if not ClientData or not InventoryDB then return nil end
        local inv = ClientData.get("inventory")
        if not (inv and inv.food) then return nil end
        for _, item in pairs(inv.food) do
            if item and item.kind then
                local db = InventoryDB.food[item.kind]
                if db and db.ailment_to_boost == ailmentType then
                    return item
                end
            end
        end
        return nil
    end

    Tab:CreateButton({ Name = "Equip Sandwich (Hungry)", Callback = function()
        local food = findItem("hungry")
        if food then
            pcall(function()
                local ctm = require(ReplicatedStorage:FindFirstChild("ClientToolManager", true))
                if ctm then ctm.backpack_equip(food) end
            end)
            Rayfield:Notify("Succès", "Sandwich équipé", 4483362458)
        else
            Rayfield:Notify("Erreur", "Aucun sandwich", 4483362458)
        end
    end})

    Tab:CreateButton({ Name = "Equip Drink (Thirsty)", Callback = function()
        local drink = findItem("thirsty")
        if drink then
            pcall(function()
                local ctm = require(ReplicatedStorage:FindFirstChild("ClientToolManager", true))
                if ctm then ctm.backpack_equip(drink) end
            end)
            Rayfield:Notify("Succès", "Boisson équipée", 4483362458)
        else
            Rayfield:Notify("Erreur", "Aucune boisson", 4483362458)
        end
    end})

    Rayfield:Notify("✅ Full Cheat Chargé", "Bon jeu !", 4483362458)
end

Rayfield:Notify("Key System", "Entre ta key pour débloquer le cheat", 4483362458)
print("v66 chargé avec succès")
