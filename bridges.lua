

ESX = exports["es_extended"]:getSharedObject()

function BridgesGetPlayerFromId(source)
    return ESX.GetPlayerFromId(source)
end

function BridgesAddInventoryItem(xPlayer, item, count)
    xPlayer.addInventoryItem(item, count)
end

function BridgesRemoveInventoryItem(xPlayer, item, count)
    xPlayer.removeInventoryItem(item, count)
end

function BridgesGetPlayerWeight(xPlayer)
    return xPlayer.getWeight()
end

function BridgesGetMaxWeight(xPlayer)
    return xPlayer.getMaxWeight()
end

function BridgesAddMoney(xPlayer, amount)
    xPlayer.addAccountMoney('money', amount)
end

function BridgesShowNotification(source, message)
    TriggerClientEvent('esx:showNotification', source, message)
end

