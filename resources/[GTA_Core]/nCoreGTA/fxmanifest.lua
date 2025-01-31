fx_version 'cerulean'
game 'gta5'

ui_page 'progressBar/progressbar.html'

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config/config.lua',
    'server/player.lua',
    'server/whitelist.lua',
    'server/admin_command.lua',
    'server/player_pos.lua',
    'synchronisation/server.lua',
    'services/server.lua'
}

client_scripts {
    'config/config.lua',
    'utils/functionsExported.lua',
    'client_main/admin_main.lua',
    'client_main/main.lua',
    'client_main/spawn.lua',
    'client_main/public_event.lua',
    'client_main/coma.lua',
    'synchronisation/client.lua',
    'services/client.lua'
}

files {
    'progressBar/progressbar.html'
}

export 'progression'

--@Super.Cool.Ninja