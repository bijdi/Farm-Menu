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

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        MySQL.Async.execute([[
            CREATE TABLE IF NOT EXISTS farms (
                id INT AUTO_INCREMENT PRIMARY KEY,
                name VARCHAR(50),
                nameTraitement VARCHAR(50),
                coords_recolte VARCHAR(255),
                coords_traitement VARCHAR(255),
                coords_vente VARCHAR(255),
                vente_prix INT
            );
        ]], {}, function(affectedRows)
            MySQL.Async.fetchAll('SELECT * FROM farms', {}, function(farms)
                TriggerClientEvent('receiveFarms', -1, farms)
            end)
        end)
    end
end)

-- Ajouter un farm à la base de données
RegisterNetEvent('addFarm')
AddEventHandler('addFarm', function(farmData)
    local src = source
    MySQL.Async.execute('INSERT INTO farms (name, nameTraitement, coords_recolte, coords_traitement, coords_vente, vente_prix) VALUES (@name, @nameTraitement, @coords_recolte, @coords_traitement, @coords_vente, @vente_prix)', {
        ['@name'] = farmData.name,
        ['@nameTraitement'] = farmData.nameTraitement,
        ['@coords_recolte'] = json.encode(farmData.coords_recolte), 
        ['@coords_traitement'] = json.encode(farmData.coords_traitement),  
        ['@coords_vente'] = json.encode(farmData.coords_vente),  
        ['@vente_prix'] = farmData.vente_prix
    }, function(rowsChanged)
        if rowsChanged > 0 then
            BridgesShowNotification(src, 'Le farm a été ajouté avec succès.')
        end
    end)
end)

RegisterNetEvent('getAllFarms')
AddEventHandler('getAllFarms', function()
    local _source = source
    MySQL.Async.fetchAll('SELECT * FROM farms', {}, function(farms)
        for i = 1, #farms do
            farms[i].coords_recolte = json.decode(farms[i].coords_recolte)
            farms[i].coords_traitement = json.decode(farms[i].coords_traitement)
            farms[i].coords_vente = json.decode(farms[i].coords_vente)
        end
        TriggerClientEvent('receiveFarms', _source, farms)
    end)
end)

RegisterServerEvent('collectItem')
AddEventHandler('collectItem', function(farmName)
    local xPlayer = BridgesGetPlayerFromId(source)
    if xPlayer then
        BridgesAddInventoryItem(xPlayer, farmName, 1)  
        BridgesShowNotification(source, 'Vous avez récolté 1 ' .. farmName)
    end
end)

RegisterServerEvent('processItem')
AddEventHandler('processItem', function(farmData, farmName)
    local xPlayer = BridgesGetPlayerFromId(source)
    
    if farmData then
        local itemName = farmName
        local itemProcessedName = farmData.nameTraitement

        if xPlayer.getInventoryItem(itemName).count > 0 then
            BridgesRemoveInventoryItem(xPlayer, itemName, 1)
            BridgesAddInventoryItem(xPlayer, itemProcessedName, 1)
            BridgesShowNotification(source, 'Vous avez traité 1 ' .. itemName .. ' et obtenu 1 ' .. itemProcessedName)
        else
            BridgesShowNotification(source, 'Vous n\'avez pas assez de ' .. itemName)
        end
    else
        BridgesShowNotification(source, 'Erreur: données de farm invalides.')
    end
end)

RegisterServerEvent('sellItem')
AddEventHandler('sellItem', function(farmData)
    local xPlayer = BridgesGetPlayerFromId(source)
    local itemProcessedName = farmData.nameTraitement
    local ventePrix = farmData.vente_prix

    if xPlayer.getInventoryItem(itemProcessedName).count > 0 then
        BridgesRemoveInventoryItem(xPlayer, itemProcessedName, 1)
        BridgesAddMoney(xPlayer, ventePrix)
        BridgesShowNotification(source, 'Vous avez vendu 1 ' .. itemProcessedName .. ' pour ' .. ventePrix .. '$')
    else
        BridgesShowNotification(source, 'Vous n\'avez pas assez de ' .. itemProcessedName)
    end
end)

RegisterNetEvent('updateFarm')
AddEventHandler('updateFarm', function(farmData)
    MySQL.Async.execute('UPDATE farms SET name = @name, nameTraitement = @nameTraitement, coords_recolte = @coords_recolte, coords_traitement = @coords_traitement, coords_vente = @coords_vente, vente_prix = @vente_prix WHERE id = @id', {
        ['@id'] = farmData.id,
        ['@name'] = farmData.name,
        ['@nameTraitement'] = farmData.nameTraitement,
        ['@coords_recolte'] = json.encode(farmData.coords_recolte),
        ['@coords_traitement'] = json.encode(farmData.coords_traitement),
        ['@coords_vente'] = json.encode(farmData.coords_vente),
        ['@vente_prix'] = farmData.vente_prix
    }, function(rowsChanged)
        if rowsChanged > 0 then
        end
    end)
end)

RegisterNetEvent('createItem')
AddEventHandler('createItem', function(item)
    if item and item.name and item.label then
        MySQL.Async.execute('INSERT INTO items (name, label) VALUES (@name, @label)', {
            ['@name'] = item.name,
            ['@label'] = item.label
        }, function(affectedRows)
            if affectedRows > 0 then
            end
        end)
    else
        print("Item invalide reçu du client")
    end
end)

RegisterServerEvent('deleteFarm')
AddEventHandler('deleteFarm', function(farmId)
    local xPlayer = source
    MySQL.Async.execute('DELETE FROM farms WHERE id = @id', {
        ['@id'] = farmId
    }, function(rowsChanged)
        if rowsChanged > 0 then
            print("Le farm avec l'ID " .. farmId .. " a été supprimé avec succès.")
            MySQL.Async.fetchAll('SELECT * FROM farms', {}, function(farms)
                TriggerClientEvent('receiveFarms', -1, farms)
            end)
        end
    end)
end)


