fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'TonNom'
description 'Système de récolte et vente de pêches'
version '1.0.0'


shared_scripts {
    'config.lua',     
    'bridges.lua',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua',


    --- RageUI
    "RageUI/RMenu.lua",
    "RageUI/menu/RageUI.lua",
    "RageUI/menu/Menu.lua",
    "RageUI/menu/MenuController.lua",
    "RageUI/components/*.lua",
    "RageUI/menu/elements/*.lua",
    "RageUI/menu/items/*.lua",
    "RageUI/menu/panels/*.lua",
    "RageUI/menu/windows/*.lua",
  
}


server_scripts {
    'server/server.lua',
    '@mysql-async/lib/MySQL.lua'
         
}

client_scripts {
    'client/client.lua',
}

dependencies {
    'es_extended', 
    'mysql-async',
}
