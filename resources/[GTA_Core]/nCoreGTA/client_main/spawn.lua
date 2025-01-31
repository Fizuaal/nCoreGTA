--@Super.Cool.Ninja

local function spawnPlayerLastPos(PosX, PosY)
	--Definit la position du joueur : 
	for height = 1, 1000 do
		SetPedCoordsKeepVehicle(GetPlayerPed(-1), tonumber(PosX), tonumber(PosY), height + 0.0)

		local foundGround, zPos = GetGroundZFor_3dCoord(tonumber(PosX), tonumber(PosY), height + 0.0)

		if foundGround then
			SetPedCoordsKeepVehicle(GetPlayerPed(-1), tonumber(PosX), tonumber(PosY), height + 0.0)
			break
		end
		Citizen.Wait(1)
	end
end


RegisterNetEvent("GTA:LASTPOS")
AddEventHandler("GTA:LASTPOS", function(PosX, PosY, PosZ)
	spawnPlayerLastPos(PosX,PosY) 
end)

RegisterNetEvent("GTA:NewPlayerPosition")
AddEventHandler("GTA:NewPlayerPosition", function(PosX, PosY, PosZ)
	SetEntityVisible(PlayerPedId(), false, 0)
	
	--> On charge les donné du player : 
	TriggerServerEvent("GTA:CheckAdmin")
	TriggerServerEvent("GTA_Notif:OnPlayerJoin")
	TriggerServerEvent('GTA:LoadArgent')
	TriggerEvent("GTA:LoadWeaponPlayer")

	spawnPlayerLastPos(PosX, PosY) 
	NetworkResurrectLocalPlayer(tonumber(PosX), tonumber(PosY), tonumber(PosZ) + 0.0, 0, true, true, false)

	Wait(3000)

	--> Rend controlable notre player :
	TriggerServerEvent("GTA:CreationPersonnage")
	FreezeEntityPosition(GetPlayerPed(-1), false)
	SetEntityVisible(PlayerPedId(), true, 0)
	Wait(500)
	RenderScriptCams(false, true, 500, true, true)
	exports.spawnmanager:setAutoSpawn(false)


	Wait(3000)
	
	SetEntityVisible(PlayerPedId(), true, 0)

	DisplayRadar(true)
	DisplayHud(true)
	TriggerEvent('EnableDisableHUDFS', true)
	TriggerServerEvent("GTA:CheckAdmin")

	PlaySoundFrontend(-1, "Zoom_Out", "DLC_HEIST_PLANNING_BOARD_SOUNDS", 1)
	PlaySoundFrontend(-1, "CAR_BIKE_WHOOSH", "MP_LOBBY_SOUNDS", 1)
end)


--> Executer une fois la ressource restart : 
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
	end

	PlaySoundFrontend(-1, "Whistle", "DLC_TG_Running_Back_Sounds", 0)
	TriggerServerEvent('GTA:LoadArgent')
	TriggerEvent('EnableDisableHUDFS', true)
	TriggerServerEvent("GTA:SPAWNPLAYER")
	local pos = GetEntityCoords(GetPlayerPed(-1))
	NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, 0, true, true, false)
	SetEntityVisible(PlayerPedId(), true, 0)
	exports.spawnmanager:setAutoSpawn(false)
end)

Citizen.CreateThread(function ()
	while true do
		Citizen.Wait(config.savePosTime)
		LastPosX, LastPosY, LastPosZ = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
		TriggerServerEvent("GTA:SAVEPOS", LastPosX , LastPosY , LastPosZ)
	    TriggerEvent("NUI-Notification", {"Position synchronisée."})
	end
end)