Config                            = {}
Config.DrawDistance               = 100.0
Config.MarkerType                 = 22
Config.MarkerSize                 = { x = 1.5, y = 1.5, z = 1.0 }
Config.MarkerColor                = { r = 50, g = 50, b = 204 }

Config.Locale                     = 'br'
Config.UsePefcl                   = true -- True uses Pefcl, false uses esx

Config.JobId                      = "Cartel1" -- Name without spaces
Config.JobName                    = "Cartel" -- Name of the job (can use spaces)
Config.StashWeight                = 200000 -- Max weight that the stash can have
Config.StashGroups                = "cartel" -- Can add multiples ({["police"] = 0, ["ambulance"] = 2})

Config.PedBlips = {
	PedLocs = {
		Pos = {
			vector4(1403.103, 1123.331, 113.826, 189.921265),
		}
	}
}

Config.CartelStations = {

  Cartel = {

    AuthorizedVehicles = {
      { model = 'adder', name = 'Addder', price = 20000},
      { model = 't20', name = 'FDD', price = 20000},	  
    },

    OpenGarage = vec3(1403.103, 1123.331, 114.826),

    Armories = vec3(1406.695, 1137.753, 109.550),

    Vehicles = {
			{
				InsideShop = vector3(1450.219, 1068.540, 115.582),
				SpawnPoints = {
					{coords = vector3(1413.718628, 1116.316528, 114.421997), heading = 87.874016, radius = 6.0},
					{coords = vector3(1413.982422, 1120.931885, 114.421997), heading = 87.874016, radius = 6.0},
				}
			},
		},

    BossActions = vec3(1393.768, 1160.991, 114.103),
	
  },
  
}