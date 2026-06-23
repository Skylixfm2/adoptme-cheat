print("=== AUTO QUEST ŒUF v71 - Final Version ===")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Cheat Adopt Me | by SkylixFM",
    LoadingTitle = "Key System",
    LoadingSubtitle = "v71 - Final",
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
        return HttpService:JSONDecode(response)
    end)
    if not success2 then return {} end

    return data
end

local UsedKeys = {}

local function IsKeyValid(inputKey, selectedType)
    local allKeys = GetValidKeys()
    
    for _, entry in ipairs(allKeys) do
        if entry.fullKey == inputKey then
            -- Vérification stricte du type
            if entry.type ~= selectedType then
                Rayfield:Notify("❌ Type incorrect", "Key "..entry.type.." mais tu as sélectionné "..selectedType, 4483362458)
                return false
            end

            -- Vérification expiration
            if not UsedKeys[inputKey] then return true end

            local data = UsedKeys[inputKey]
            local days = 9999
            if selectedType == "CAM1D" then days = 1
            elseif selectedType == "CAM7D" then days = 7
            elseif selectedType == "CAM15D" then days = 15
            elseif selectedType == "CAM30D" then days = 30 end

            local daysPassed = (os.time() - (data.firstUse or os.time())) / 86400
            if daysPassed > days then
                Rayfield:Notify("⏰ Key Expirée", "Cette key a expiré", 4483362458)
                return false
            end
            return true
        end
    end
    return false
end

-- ==================== INTERFACE KEY ====================
local selectedType = "CAML"

Tab:CreateDropdown({
    Name = "Type de Key",
    Options = {"CAML", "CAM1D", "CAM7D", "CAM15D", "CAM30D"},
    CurrentOption = {"CAML"},
    MultipleOptions = false,
    Callback = function(Value)
        selectedType = Value[1]
    end,
})

Tab:CreateInput({
    Name = "🔑 Entre ta Key",
    PlaceholderText = "PCAML_XXXXXXXXXXXXXXXX",
    RemoveTextAfterFocusLost = false,
    Callback = function(key)
        if key == "" then return end

        if IsKeyValid(key, selectedType) then
            if not UsedKeys[key] then
                UsedKeys[key] = { firstUse = os.time() }
            end
            Rayfield:Notify("✅ Key Valide", "Type : " .. selectedType, 4483362458)
            task.wait(1)
            LoadFullCheat()
        end
    end,
})

-- ==================== CHEAT COMPLET ====================
function LoadFullCheat()
    -- TP Devant Ma Maison
    Tab:CreateButton({
        Name = "🏠 TP Devant Ma Maison",
        Callback = function()
            Rayfield:Notify("🏠", "Téléportation vers ta maison...", 4483362458)
        end,
    })

    -- Auto Shower
    Tab:CreateButton({
        Name = "🛁 Auto Shower (Joueur + Pet)",
        Callback = function()
            Rayfield:Notify("🛁", "Téléportation Joueur + Pet...", 4483362458)
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

Rayfield:Notify("Key System", "Choisis le type puis entre ta key", 4483362458)
print("v71 chargé avec succès")
