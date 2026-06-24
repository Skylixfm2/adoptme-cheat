print("=== best adopte me cheat made by SkylixFM ===")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local player = Players.LocalPlayer

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Cheat Adopt Me | by SkylixFM",
    LoadingTitle = "Adopte me cheat",
    LoadingSubtitle = "v73 cheat made by SkylixFM",
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
            if entry.type ~= selectedType then
                Rayfield:Notify("❌", "Mauvais type de key", 4483362458)
                return false
            end

            local keyData = UsedKeys[inputKey]
            if keyData and keyData.userId and keyData.userId ~= player.UserId then
                Rayfield:Notify("🚫", "Key déjà utilisée par un autre compte", 4483362458)
                return false
            end

            local days = 9999
            if selectedType == "CAM1D" then days = 1
            elseif selectedType == "CAM7D" then days = 7
            elseif selectedType == "CAM15D" then days = 15
            elseif selectedType == "CAM30D" then days = 30 end

            if keyData and keyData.firstUse then
                local daysPassed = (os.time() - keyData.firstUse) / 86400
                if daysPassed > days then
                    Rayfield:Notify("⏰", "Key expirée", 4483362458)
                    return false
                end
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
    Name = "Put your key here",
    PlaceholderText = "PCAML_XXXXXXXXXXXXXXXX",
    RemoveTextAfterFocusLost = false,
    Callback = function(key)
        if key == "" then return end

        if IsKeyValid(key, selectedType) then
            if not UsedKeys[key] then
                UsedKeys[key] = { firstUse = os.time(), userId = player.UserId }
            end

            Rayfield:Notify("✅", "Key valide ! Chargement du panel...", 4483362458)
            task.wait(1)
            LoadFullCheat()
        end
    end,
})

-- ==================== CHEAT COMPLET (Ton ancien code) ====================
function LoadFullCheat()

-- =============================================
-- TP DEVANT MA MAISON
-- =============================================
Tab:CreateButton({
    Name = "TP in my house ( doesnt work)",
    Callback = function()
        local houseInteriors = Workspace:FindFirstChild("HouseInteriors")
        if not houseInteriors then
            Rayfield:Notify("Erreur", "HouseInteriors non trouvé", 4483362458)
            return
        end
        local myHouse = nil
        for _, house in ipairs(houseInteriors:GetChildren()) do
            if house.Name ~= "MainMap" and house:FindFirstChild("furniture") then
                myHouse = house
                break
            end
        end
        if not myHouse then
            Rayfield:Notify("Erreur", "Ta maison non trouvée", 4483362458)
            return
        end
        local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local door = myHouse:FindFirstChild("Door") or myHouse:FindFirstChildWhichIsA("BasePart")
            if door then
                root.CFrame = door.CFrame * CFrame.new(0, 4, -8)
                Rayfield:Notify("Succès", "Téléporté devant ta maison", 4483362458)
            else
                root.CFrame = myHouse:GetModelCFrame() * CFrame.new(0, 5, -15)
                Rayfield:Notify("Succès", "Téléporté près de ta maison", 4483362458)
            end
        end
    end,
})

-- =============================================
-- AUTO SHOWER (JOUEUR + PET)
-- =============================================
Tab:CreateButton({
    Name = "tp Shower",
    Callback = function()
        local EquippedPets = nil
        pcall(function()
            EquippedPets = require(ReplicatedStorage:WaitForChild("Fsys")).load("EquippedPets")
        end)
        local pet = EquippedPets and EquippedPets.choose_wrapper()
        local petRoot = pet and pet.char and pet.char:FindFirstChild("HumanoidRootPart")
        local playerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not playerRoot then
            Rayfield:Notify("Erreur", "Ton personnage n'est pas chargé", 4483362458)
            return
        end
        local shower = nil
        local houseInteriors = Workspace:FindFirstChild("HouseInteriors")
        if houseInteriors then
            shower = houseInteriors:FindFirstChild("ModernShower", true)
        end
        if not shower then
            Rayfield:Notify("Erreur", "ModernShower non trouvé dans ta maison", 4483362458)
            return
        end
        local center = shower:FindFirstChild("Center") or shower.PrimaryPart
        if not center then
            Rayfield:Notify("Erreur", "Center de la douche non trouvé", 4483362458)
            return
        end
        local cf = center.CFrame
        playerRoot.CFrame = cf * CFrame.new(0, 3, -6)
        if petRoot then
            petRoot.CFrame = cf * CFrame.new(0, 3, -3.5)
        end
        Rayfield:Notify("Auto Shower", "Joueur + Pet téléportés devant la douche", 4483362458)
        task.wait(1.2)
        Rayfield:Notify("Info", "Clique sur 'Take Shower'", 4483362458)
    end,
})

-- =============================================
-- SPEED HACK
-- =============================================
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

-- =============================================
-- TELEPORTS
-- =============================================
local tps = {
    ["Buy Water"] = CFrame.new(3020.41, 6960.26, -3002.70),
    ["Buy Food"] = CFrame.new(3020.41, 6960.26, -3042.36),
    ["Camping"] = CFrame.new(-18.79, 31.93, -1053.97),
    ["Playground"] = CFrame.new(-353.36, 30.89, -1759.09),
}
for name, cf in pairs(tps) do
    Tab:CreateButton({
        Name = "TP " .. name,
        Callback = function()
            local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = cf end
            Rayfield:Notify("TP", name, 4483362458)
        end
    })
end

-- =============================================
-- FOOD SYSTEM
-- =============================================
local ClientData = nil
local InventoryDB = nil
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

Rayfield:Notify("✅ Panel Chargé", "v73 Prêt !", 4483362458)
print("v73 chargé avec succès")
end

Rayfield:Notify("Key System", "Choisis le type puis entre ta key", 4483362458)
