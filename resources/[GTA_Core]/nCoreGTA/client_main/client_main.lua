--@Super.Cool.Ninja
local departItemList = {}
local camSpawn = nil
local cam = nil
local cam2 = nil

local function GetDepartItemList()
    for i=1, #config.itemDepart, 1 do
        table.insert(departItemList, {name = config.itemDepart[i]["item_name"], qty = config.itemDepart[i]["item_qty"]})
    end
end

local function DrawMissionText(m_text, showtime)
    ClearPrints()
	SetTextScale(0.5, 0.5)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextColour(255, 255, 255, 255)
	SetTextDropshadow(0, 0, 0, 0, 255)
	SetTextEdge(2, 0, 0, 0, 150)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(m_text)
	DrawText(0.5, 0.9)
end

--> Création/Load du player :
Citizen.CreateThread(function()
    TriggerServerEvent("GTA:CreationJoueur") 
end)

--[=====[
        Synchro toute les 5 minute des donnée du player sauvegarder dans la table PlayerSource :
]=====]
Citizen.CreateThread(function()
    while true do
        TriggerServerEvent("GTA:SyncPlayer")
		TriggerEvent("NUI-Notification", {"Synchronisation éfféctué."})
        Wait(config.timerPlayerSynchronisation)
    end
end)

--> On refresh les donnée de notre player  :
RegisterNetEvent("GTA:LoadPlayerData")
AddEventHandler("GTA:LoadPlayerData", function(playersInfo, itemsList)
    config.Player = playersInfo
    config.itemList = itemsList

    TriggerServerEvent("GTA:TelephoneLoaded") --> Load le phone au spawn :
    --TriggerEvent("GTA:LoadWeaponPlayer")
end)


RegisterNetEvent("GTA:SpawnPlayer")
AddEventHandler("GTA:SpawnPlayer", function()
    Citizen.CreateThread(function()
        if  (GetIsFirstConnexion() == false) then
            cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA",config.Player.pos+200, 300.00,0.00,0.00, 100.00, false, 0)
            PointCamAtCoord(cam,config.Player.pos+2)
            SetCamActiveWithInterp(cam, camSpawn, 500, true, true)
            Citizen.Wait(500)
            PlaySoundFrontend(-1, "Zoom_Out", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
            RenderScriptCams(false, true, 500, true, true)
            PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
            Citizen.Wait(100)
            SetCamActive(cam, false)
            DestroyCam(cam, true)

            SetEntityCoords(GetPlayerPed(-1), config.Player.pos, 0.0, 0.0, 0.0, 0)
            SetEntityVisible(PlayerPedId(), false, 0)

            FreezeEntityPosition(GetPlayerPed(-1), false)
            SetEntityVisible(PlayerPedId(), true, 0)
            
            DisplayRadar(true)
            DisplayHud(true)
            TriggerEvent('EnableDisableHUDFS', true)
        else
            GetDepartItemList()
            TriggerEvent("GTA:BeginCreation")
            for _, v in pairs(departItemList) do
                TriggerServerEvent("GTA:ReceiveItem", v.name, v.qty)
            end
        end

        exports.spawnmanager:setAutoSpawn(false)
    end)
end)


Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        if GetLastInputMethod(0) then
            DrawMissionText("~h~APPUYER SUR~g~ ENTRER ~w~ POUR REJOINDRE LA VILLE.")
        else
            DrawMissionText("~h~APPUYER SUR~r~ A ~w~ POUR REJOINDRE LA VILLE.")
        end

        camSpawn = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", -1355.93,-1487.78,520.75, 300.00,0.00,0.00, 100.00, false, 0)
        SetCamActive(camSpawn, true)
        RenderScriptCams(true, false, 1, true, true)

        DisplayRadar(false)
        DisplayHud(false)
        TriggerEvent('EnableDisableHUDFS', false)

        if IsControlJustPressed(0, 18) then
            PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
            TriggerEvent("GTA:SpawnPlayer")
            break
        end
	end
end)


 --> Main Thread :
Citizen.CreateThread(function()

    --> PVP :
    if config.activerPvp == true then
        for _, v in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(v)
            SetCanAttackFriendly(ped, true, true)
            NetworkSetFriendlyFireOption(true)
        end
    end

    --> IPL :
    local ipls = {'facelobby', 'farm', 'farmint', 'farm_lod', 'farm_props', 
    'des_farmhouse', 'post_hiest_unload', 'v_tunnel_hole',
    'rc12b_default', 'refit_unload', 'shr_int', 'Coroner_Int_on'}

    for _,v in pairs(ipls) do
        if not IsIplActive(v) then
            RequestIpl(v)
        end
    end

    --> COPS :
    if config.activerPoliceWanted == false then
        Citizen.CreateThread(function()
            while true do
                Citizen.Wait(0)
                local myPlayer = GetEntityCoords(PlayerPedId())	
                --> Permet de ne pas recevoir d'indice de recherche :
                if (GetPlayerWantedLevel(PlayerId()) > 0) then
                    SetPlayerWantedLevel(PlayerId(), 0, false)
                    SetPlayerWantedLevelNow(PlayerId(), false)
                end

                --> Permet de ne pas spawn les véhicule de cops prés du poste de police :
                ClearAreaOfCops(myPlayer.x, myPlayer.y, myPlayer.z, 5000.0)
            end
        end)
    end

    --> Salaire :
    Citizen.CreateThread(function ()
        while true do
            Citizen.Wait(config.salaireTime)
            TriggerServerEvent("GTA:salaire")
        end
    end)

    --> Position Save :
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(config.timerPlayerSyncPos)
            local pPed = GetPlayerPed(-1)
            local pCoords = GetEntityCoords(pPed)
            TriggerServerEvent("GTA:SavePos", pCoords)
        end
    end)
end)



--- System de distance de voix : 
local distance_voix = {}
local currentdistancevoice = 0
distance_voix.Grande = 12.001
distance_voix.Normal = 8.001
distance_voix.Faible = 2.001

RegisterCommand('+changevoice', function()
    currentdistancevoice = (currentdistancevoice + 1) % 3
	if currentdistancevoice == 0 then
		NetworkSetTalkerProximity(distance_voix.Normal) -- 5 meters range
	    TriggerEvent("NUI-Notification", {"Niveau vocal : normal."})

	elseif currentdistancevoice == 1 then
		NetworkSetTalkerProximity(distance_voix.Grande) -- 12 meters range
	    TriggerEvent("NUI-Notification", {"Niveau vocal : crier."})
	elseif currentdistancevoice == 2 then
        NetworkSetTalkerProximity(distance_voix.Faible) -- 1 meters range
	    TriggerEvent("NUI-Notification", {"Niveau vocal : chuchoter."})
	end
end, false)
AddEventHandler('onClientMapStart', function()
	if currentdistancevoice == 0 then
		NetworkSetTalkerProximity(distance_voix.Normal) -- 5 meters range
	elseif currentdistancevoice == 1 then
		NetworkSetTalkerProximity(distance_voix.Grande) -- 12 meters range
	elseif currentdistancevoice == 2 then
		NetworkSetTalkerProximity(distance_voix.Faible) -- 1 meters range
	end
end)
RegisterCommand('-changevoice', function() end, false)
RegisterKeyMapping('+changevoice', 'Distance de voix', 'keyboard', 'F1')




--> Executer une fois la ressource restart : 
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
	end

	PlaySoundFrontend(-1, "Whistle", "DLC_TG_Running_Back_Sounds", 0)
    TriggerServerEvent("GTA:CreationJoueur")
	exports.spawnmanager:setAutoSpawn(false)
end)