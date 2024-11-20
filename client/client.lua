local isOpen = false
local farmList = {}
local farmData = {
    id = nil,
    name = nil,
    nameTraitement = nil,
    coords_recolte = nil,
    coords_traitement = nil,
    coords_vente = nil,
    vente_prix = nil
}




Citizen.CreateThread(function()
    TriggerServerEvent('getAllFarms')
    local refreshInterval = 60
    while true do
        Citizen.Wait(refreshInterval)
        TriggerServerEvent('getAllFarms')
    end
end)
----------------------------------------------------------------------------------Menu principal----------------------------------------------------------------------------------

function openMenuJib()
    if not isOpen then
        isOpen = true

        local main = RageUI.CreateMenu('Gestion des Farms', 'Actions disponibles')
        local subMenu = RageUI.CreateSubMenu(main, 'Créer un farm', 'Définir les propriétés du farm')
        local modifyMenu = RageUI.CreateSubMenu(main, 'Modifier un farm', 'Modifier les farms existants')
        local deleteMenu = RageUI.CreateSubMenu(main, 'Supprimer un farm', 'Supprimer les farms existants')

        RageUI.Visible(main, not RageUI.Visible(main))

        Citizen.CreateThread(function()
            while isOpen do 
                RageUI.IsVisible(main, function()
                    RageUI.Button('Créer un farm', 'Créer un nouveau farm', { RightLabel = '>>>' }, true, {}, subMenu)
                    RageUI.Button('Modifier un farm existant', 'Modifier les farms déjà créés', { RightLabel = '>>>' }, true, {
                        onSelected = function()
                            TriggerServerEvent('getAllFarms')
                        end
                    }, modifyMenu)
                    RageUI.Button('Supprimer un farm existant', 'Supprimer les farms déjà créés', { RightLabel = '>>>' }, true, {
                        onSelected = function()
                            TriggerServerEvent('getAllFarms')
                        end
                    }, deleteMenu)
                end)

                RageUI.IsVisible(subMenu, function()
                    RageUI.Button("Définir le nom du recolte", 'Nom du recolte', { RightLabel = farmData.name and '~g~Défini' or '~r~Non défini' }, true, {
                        onSelected = function()
                            nameFarm()
                        end,
                    })
                    RageUI.Button("Définir le nom du traitement", 'Nom du traitement', { RightLabel = farmData.nameTraitement and '~g~Défini' or '~r~Non défini' }, true, {
                        onSelected = function()
                            nameTraitement()
                        end,
                    })
                    RageUI.Button('Définir les coords de la récolte', 'Coordonnées de la récolte', { RightLabel = farmData.coords_recolte and '~g~Défini' or '~r~Non défini' }, true, {
                        onSelected = function()
                            coordsRecolte()
                        end,
                    })
                    RageUI.Button('Définir les coords du traitement', 'Coordonnées du traitement', { RightLabel = farmData.coords_traitement and '~g~Défini' or '~r~Non défini' }, true, {
                        onSelected = function()
                            coordsTraitement()
                        end,
                    })
                    RageUI.Button('Définir les coords de la vente', 'Coordonnées de la vente', { RightLabel = farmData.coords_vente and '~g~Défini' or '~r~Non défini' }, true, {
                        onSelected = function()
                            coordsVente()
                        end,
                    })
                    RageUI.Button('Définir le prix de la vente', 'Prix par unité vendue', { RightLabel = farmData.vente_prix and '~g~Défini' or '~r~Non défini' }, true, {
                        onSelected = function()
                            ventePrix()
                        end,
                    })
                    RageUI.Button('Sauvegarder le farm', 'Enregistrer le farm dans la base de données', { RightLabel = '>>>' }, true, {
                        onSelected = function()
                            saveFarmToDB()
                        end,
                    })
                end)

                RageUI.IsVisible(modifyMenu, function()
                    if farmList and #farmList > 0 then
                        for _, farm in pairs(farmList) do
                            RageUI.Button(farm.name, nil, { RightLabel = '>>>' }, true, {
                                onSelected = function()
                                    farmData = farm
                                    editFarm(farmData)
                                end
                            })
                        end
                    else
                        RageUI.Separator("~r~Aucun farm disponible")
                    end
                end)

                RageUI.IsVisible(deleteMenu, function()
                    if farmList and #farmList > 0 then
                        for _, farm in pairs(farmList) do
                            RageUI.Button(farm.name, 'Supprimer ce farm', { RightLabel = '>>>' }, true, {
                                onSelected = function()
                                    deleteFarm(farm)
                                end
                            })
                        end
                    else
                        RageUI.Separator("~r~Aucun farm disponible")
                    end
                end)

                if not RageUI.Visible(main) and not RageUI.Visible(subMenu) and not RageUI.Visible(modifyMenu) and not RageUI.Visible(deleteMenu) then
                    RMenu:DeleteType(main)
                    isOpen = false
                end
                Citizen.Wait(0)
            end
        end)
    else
    end
end

RegisterCommand('essaiejib', function()
    openMenuJib()
end)



------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------Créations du farm----------------------------------------------------------------------------------


function deleteFarm(farm)
    local confirm = lib.inputDialog('Supprimer le farm', {'Tapez "SUPPRIMER" pour confirmer la suppression de ' .. farm.name})
    if confirm and confirm[1] == "SUPPRIMER" then
        TriggerServerEvent('deleteFarm', farm.id)

    end
end

function coordsRecolte()
    local playerPed = PlayerPedId()
    local playerCoordsRecolte = GetEntityCoords(playerPed)
    farmData.coords_recolte = playerCoordsRecolte
end

function coordsTraitement()
    local playerPed = PlayerPedId()
    local playerCoordsTraitement = GetEntityCoords(playerPed)
    farmData.coords_traitement = playerCoordsTraitement
end

function coordsVente()
    local playerPed = PlayerPedId()
    local playerCoordsVente = GetEntityCoords(playerPed)
    farmData.coords_vente = playerCoordsVente
end

function createItem(itemName)
    local item = {
        name = itemName,  
        label = itemName,  
    }
    
    TriggerServerEvent('createItem', item)
end

function nameFarm()
    local name = lib.inputDialog('Nom du farm', {'Nom du farm'})
    if not name then return end
    farmData.name = name[1]
    createItem(farmData.name)
end

function nameTraitement()
    local namet = lib.inputDialog('Nom du Traitement', {'Nom du Traitement'})
    if not namet then return end
    farmData.nameTraitement = namet[1]
    createItem(farmData.nameTraitement)
end

function ventePrix()
    local price = lib.inputDialog('Prix de vente', {'Prix de la vente'})
    if not price then return end
    farmData.vente_prix = tonumber(price[1])
end


function saveFarmToDB()
    if farmData.name and farmData.coords_recolte and farmData.coords_traitement and farmData.coords_vente and farmData.vente_prix then
        TriggerServerEvent('addFarm', farmData)
        farmData = { id = nil, name = nil, coords_recolte = nil, coords_traitement = nil, coords_vente = nil, vente_prix = nil }
    end
end


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


----------------------------------------------------------------------------------Modif des farm----------------------------------------------------------------------------------
function editFarm(farm)
    local editMenu = RageUI.CreateMenu('Modifier le farm', 'Actions disponibles')
    RageUI.Visible(editMenu, not RageUI.Visible(editMenu))

    Citizen.CreateThread(function()
        while true do 
            
            RageUI.IsVisible(editMenu, function()
                RageUI.Button('Modifier le nom', 'Nom actuel : ' .. (farm.name or 'Non défini'), { RightLabel = '>>>' }, true, {
                    onSelected = function()
                        local name = lib.inputDialog('Modifier le nom', {'Nom du farm'})
                        if name and name ~= '' then
                            farm.name = name[1]
                        end
                    end
                })
                RageUI.Button('Modifier le nom du traitement', 'Nom actuel : ' .. (farmData.nameTraitement or 'Non défini'), { RightLabel = '>>>' }, true, {
                    onSelected = function()
                        local namet = lib.inputDialog('Modifier le nom du traitement', {'Nom du farm'})
                        if namet and namet ~= '' then
                            farmData.nameTraitement = namet[1]
                        end
                    end
                })
                RageUI.Button('Modifier les coords de la récolte', 'Coords actuelles : ' .. (farm.coords_recolte and json.encode(farm.coords_recolte) or 'Non défini'), { RightLabel = '>>>' }, true, {
                    onSelected = function()
                        coordsRecolte()
                        farm.coords_recolte = farmData.coords_recolte
                    end
                })
                RageUI.Button('Modifier les coords du traitement', 'Coords actuelles : ' .. (farm.coords_traitement and json.encode(farm.coords_traitement) or 'Non défini'), { RightLabel = '>>>' }, true, {
                    onSelected = function()
                        coordsTraitement()
                        farm.coords_traitement = farmData.coords_traitement
                    end
                })
                RageUI.Button('Modifier les coords de la vente', 'Coords actuelles : ' .. (farm.coords_vente and json.encode(farm.coords_vente) or 'Non défini'), { RightLabel = '>>>' }, true, {
                    onSelected = function()
                        coordsVente()
                        farm.coords_vente = farmData.coords_vente
                    end
                })
                RageUI.Button('Modifier le prix de vente', 'Prix actuel : ' .. (farm.vente_prix or 'Non défini'), { RightLabel = '>>>' }, true, {
                    onSelected = function()
                        local price = lib.inputDialog('Modifier le prix', {'Prix de vente'})
                        if price and price ~= '' then
                            farm.vente_prix = tonumber(price[1])
                        end
                    end
                })
                RageUI.Button('Sauvegarder les modifications', 'Enregistrer les changements', { RightLabel = '>>>' }, true, {
                    onSelected = function()
                        TriggerServerEvent('updateFarm', farm)
                    end
                })
            end)

            if not RageUI.Visible(editMenu) then
                RMenu:DeleteType(editMenu)
                break
            end
            Citizen.Wait(0)
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('receiveFarms')
AddEventHandler('receiveFarms', function(farms)
    farmList = farms
end)



local isBusy = false  -- Variable pour empêcher le spam

Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local closestDistance = 10000  
        local waitTime = 1000  

        for _, farm in pairs(farmList) do
            local distanceRecolte = #(playerCoords - vector3(farm.coords_recolte.x, farm.coords_recolte.y, farm.coords_recolte.z))
            local distanceTraitement = #(playerCoords - vector3(farm.coords_traitement.x, farm.coords_traitement.y, farm.coords_traitement.z))
            local distanceVente = #(playerCoords - vector3(farm.coords_vente.x, farm.coords_vente.y, farm.coords_vente.z))

            closestDistance = math.min(closestDistance, distanceRecolte, distanceTraitement, distanceVente)

            if distanceRecolte < 5.0 then
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour récolter.')
                DrawMarker(25, farm.coords_recolte.x, farm.coords_recolte.y, farm.coords_recolte.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, false, false, false, false)
                if IsControlJustReleased(0, 38) and not isBusy then
                    isBusy = true 
                    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                    Citizen.SetTimeout(50, function()
                        TriggerServerEvent('collectItem', farm.name)
                        Citizen.SetTimeout(5000, function()  
                            ClearPedTasks(playerPed)
                            isBusy = false  
                        end)
                    end)
                end
                waitTime = 0
            end

            if distanceTraitement < 5.0 then
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour traiter.')
                DrawMarker(25, farm.coords_traitement.x, farm.coords_traitement.y, farm.coords_traitement.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, false, false, false, false)
                if IsControlJustReleased(0, 38) and not isBusy then
                    isBusy = true 
                    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
                    Citizen.SetTimeout(50, function()
                        TriggerServerEvent('processItem', farm, farm.name)
                        Citizen.SetTimeout(5000, function()  
                            ClearPedTasks(playerPed)
                            isBusy = false  
                        end)
                    end)
                end
                waitTime = 0
            end

            if distanceVente < 5.0 then
                ESX.ShowHelpNotification('Appuyez sur ~INPUT_CONTEXT~ pour vendre.')
                DrawMarker(25, farm.coords_vente.x, farm.coords_vente.y, farm.coords_vente.z - 1, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, false, false, false, false)
                if IsControlJustReleased(0, 38) and not isBusy then
                    isBusy = true  
                    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_IMPATIENT", 0, true)
                    Citizen.SetTimeout(50, function()
                        TriggerServerEvent('sellItem', farm)
                        Citizen.SetTimeout(5000, function()  
                            ClearPedTasks(playerPed)
                            isBusy = false 
                        end)
                    end)
                end
                waitTime = 0
            end
        end

        if closestDistance > 50 then
            waitTime = 1500  
        elseif closestDistance > 20 then
            waitTime = 500 
        elseif closestDistance > 5 then
            waitTime = 200 
        end

        Citizen.Wait(waitTime)
    end
end)


