local PlayerData                = {}
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local ox_inventory              = exports.ox_inventory
local model = "g_m_m_casrn_01"

Citizen.CreateThread(function()
  ox_inventory:addSphereZone({
    coords = Config.CartelStations.Cartel.Armories,
    radius = 0.3,
    distance = 1.5,
    options = {
        {
            name = 'Cartel1',
            onSelect = function()
              exports["esx_AdvancedCartel"]:OpenArmoryMenu()
            end,
            icon = 'fa-solid fa-magnifying-glass',
            label = TranslateCap("open_storage"),
        }
    }
  })
  ox_inventory:addSphereZone({
    coords = Config.CartelStations.Cartel.BossActions,
    radius = 0.3,
    distance = 1.5,
    options = {
			{
				name = 'box',
				event = 'esx_society:openBossMenu',
				icon = 'fas fa-bars-progress',
				groups = {['cartel'] = 3},
				distance = 2,
				label = TranslateCap("open_company"),
				menuOptions = {
					society = "cartel",
					close = function(data, menu)
						CurrentAction = "menu_boss_actions"
						CurrentActionMsg = TranslateCap("open_bossmenu")
						CurrentActionData = {}
					end,
					options = { wash = false }
				}
			}
		}
  })

  for k,v in pairs(Config.PedBlips) do
		for i=1, #v.Pos, 1 do
			lib.requestModel(model)

			local ped = CreatePed(0, model, v.Pos[i].x, v.Pos[i].y, v.Pos[i].z, v.Pos[i].w, false, true)
			SetEntityAlpha(ped, 0, false)
			Wait(50)
			SetEntityAlpha(ped, 255, false)

			SetPedFleeAttributes(ped, 2)
			SetBlockingOfNonTemporaryEvents(ped, true)
			SetPedCanRagdollFromPlayerImpact(ped, false)
			SetPedDiesWhenInjured(ped, false)
			FreezeEntityPosition(ped, true)
			SetEntityInvincible(ped, true)
			SetPedCanPlayAmbientAnims(ped, false)
		end
	end

	ox_inventory:addSphereZone({
		coords = Config.CartelStations.Cartel.OpenGarage,
		radius = 0.7,
		options = {
			{
				name = 'box4',
				icon = 'fas fa-bars-progress',
				groups = 'cartel',
				label = TranslateCap("open_garage"),
				distance = 1.5,
				event = 'esx_AdvancedCartel:OpenVehicleSpawnerMenu',
				menuOptions = {
					type = 'car',
					station = 'Cartel',
					part = 'Vehicles',
					partNum = 1,
				},
			}
		}
	})
end)

function OpenArmoryMenu()
  TriggerServerEvent('ox:loadStashes')
  ox_inventory:openInventory('stash', {id=Config.JobId, groups=Config.StashGroups})
end

exports("OpenArmoryMenu",OpenArmoryMenu)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)
