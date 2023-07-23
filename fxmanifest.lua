fx_version 'adamant'

game 'gta5'

description 'ESX Cartel'
version '1.2'
lua54 'yes'
author 'Bro0kS#1624'

shared_script {
  '@es_extended/imports.lua',
  '@ox_lib/init.lua',
}
  
server_scripts {
  '@es_extended/locale.lua',
  '@mysql-async/lib/MySQL.lua',
  'locales/br.lua',,
  'locales/en.lua',
  'config.lua',
  'server/main.lua'
}

client_scripts {
  '@es_extended/locale.lua',
  'locales/br.lua',
  'locales/en.lua',
  'config.lua',
  'client/main.lua',
  'client/vehicle.lua'
}
