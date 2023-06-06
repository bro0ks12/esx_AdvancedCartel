Config                            = {}
Config.DrawDistance               = 100.0
Config.MarkerType                 = 22
Config.MarkerSize                 = { x = 1.5, y = 1.5, z = 1.0 }
Config.MarkerColor                = { r = 50, g = 50, b = 204 }
Config.EnablePlayerManagement     = true
Config.EnableESXIdentity          = true -- only turn this on if you are using esx_identity
Config.EnableSocietyOwnedVehicles = false
Config.MaxInService               = -1
Config.Locale                     = 'br'

Config.JobId                      = "MafiaCartel" -- Name without spaces
Config.JobName                    = "Mafia Cartel" -- Name of the job (can use spaces)
Config.StashWeight                = 200 -- Max weight that the stash can have
Config.StashGroups                = "mafia" -- Can add multiples ({["police"] = 0, ["ambulance"] = 2})

Config.MafiaStations = {

  Mafia = {

    AuthorizedVehicles = {
      { name = 'hexer',          label = 'Hexer' },
      { name = 'innovation',     label = 'Innovation' },
      { name = 'daemon',         label = 'Daemon' },
      { name = 'Zombieb',        label = 'Zombie Chopper' },
      { name = 'slamvan',        label = 'Slamvan' },
      { name = 'GBurrito',       label = 'Gang Burrito' },
      { name = 'sovereign',      label = 'Sovereign' },
      { name = 'benson',         label = 'Benson' },		  
    },

    Armories = {
      vec3(986.77, -92.75, 74.85),
    },

    Vehicles = {
      {
        Spawner    = { x = 969.87, y = -113.54, z = 74.35 },
        SpawnPoint = { x = 967.89, y = -127.17, z = 74.37 },
        Heading    = 147.03,
      }
    },

    VehicleDeleters = {
      { x = 965.03, y = -118.7, z = 74.35 },
    },

    BossActions = {
      { x = 977.03, y = -103.92, z = 74.85 },
    },
	
  },
  
}
