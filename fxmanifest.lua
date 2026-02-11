fx_version 'cerulean'
game 'gta5'

author 'DeveloperGazz'
description 'CSRP Medical System - Comprehensive Medical RP System'
version '1.0.0'

lua54 'yes'

-- Client Scripts
client_scripts {
    'config.lua',
    'modules/*.lua',
    'client/main.lua',
    'client/injury.lua',
    'client/vitals.lua',
    'client/progression.lua',
    'client/treatments.lua',
    'client/ui.lua',
    'client/death.lua',
    'client/scenarios.lua',
    'client/bystanders.lua',
    'client/psychological.lua',
    'client/mci.lua',
    'client/complications.lua',
    'client/equipment.lua',
    'client/patient_experience.lua'
}

-- Server Scripts
server_scripts {
    'config.lua',
    'modules/*.lua',
    'server/main.lua',
    'server/sync.lua',
    'server/admin.lua',
    'server/logging.lua'
}

-- UI Files
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/patient.html',
    'html/paramedic.html',
    'html/mci.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/assets/**/*'
}

dependencies {
    -- Standalone - No dependencies!
}