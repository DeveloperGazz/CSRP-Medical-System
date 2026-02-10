fx_version 'cerulean'
game 'gta5'

author 'CSRP Development'
description 'Comprehensive Medical System for FiveM UK RP Server'
version '1.0.0'

-- Client Scripts
client_scripts {
    'config.lua',
    'modules/injuries.lua',
    'modules/treatments.lua',
    'modules/equipment.lua',
    'client/main.lua',
    'client/injury.lua',
    'client/vitals.lua',
    'client/progression.lua',
    'client/treatments.lua',
    'client/ui.lua'
}

-- Server Scripts
server_scripts {
    'config.lua',
    'modules/injuries.lua',
    'modules/treatments.lua',
    'modules/equipment.lua',
    'server/main.lua',
    'server/sync.lua',
    'server/admin.lua'
}

-- UI Files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/style.css',
    'html/js/app.js',
    'html/assets/*.png',
    'html/assets/*.svg'
}
