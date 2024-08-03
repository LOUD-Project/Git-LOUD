--**  File     :  /lua/buildingtemplates.lua

-- This file contains all the Platoon Template References for building structures
-- I have enhanced it to provide additional categories
-- mostly to support unique units from 3rd party mods

BuildingTemplates = {

-- UEF Building List
-- with included T3ArtilleryDefenseShield
    {
    -- Power Structures
        { 'T1EnergyProduction', 'ueb1101' },
        { 'T1HydroCarbon',      'ueb1102' },
        { 'T2EnergyProduction', 'ueb1201' },
        { 'T3EnergyProduction', 'ueb1301' },
	-- Mass Structures
        { 'T1Resource', 'ueb1103' 		  },
        { 'T2Resource', 'ueb1202'         },
        { 'T3Resource', 'ueb1302'         },
		{ 'T1MassCreation', 'ueb1104'     },
        { 'T3MassCreation', 'ueb1303'     },
    -- Land Factory Structures
        { 'T1LandFactory', 'ueb0101'      },
        { 'T2LandFactory', 'ueb0201'      },
        { 'T3LandFactory', 'ueb0301'      },
        { 'T3QuantumGate', 'ueb0304'      },
	-- Engineer Stations
        { 'T2EngineerSupport', 'xeb0104'  },
        { 'T3EngineerSupport', 'xeb0204'  },
    -- Air Factory Structures
        { 'T1AirFactory', 'ueb0102'       },
        { 'T2AirFactory', 'ueb0202'       },
        { 'T3AirFactory', 'ueb0302'       },
	-- Sea Factory Structures
        { 'T1SeaFactory', 'ueb0103'       },
        { 'T2SeaFactory', 'ueb0203'       },
        { 'T3SeaFactory', 'ueb0303'       },
    -- Storage Structures
        { 'MassStorage', 'ueb1106'        },
        { 'EnergyStorage','ueb1105'       },
        { 'T3Storage', 'ueb1105'          },
        { 'T4Storage', 'beb1106'          },
	-- Wall
        { 'Wall', 'ueb5101'        },
        { 'T2Wall', 'uem0006'      },
    -- Point Defense
        { 'T1GroundDefense', 'ueb2101'     },
        { 'T2GroundDefense', 'ueb2301'     },
		{ 'T2GroundDefenseAmphibious', 'ueb2301'	},
        { 'T3GroundDefense', 'xeb2306'     },		
        { 'T4GroundDefense', 'xeb2306'     },
    -- AA Defense
		{ 'T1AADefense', 'ueb2104'        },
        { 'T2AADefense', 'ueb2204'        },
		{ 'T2AADefenseAmphibious', 'ueb2204'        },
        { 'T3AADefense', 'ueb2304'        },
        { 'T4AADefense', },
	-- Naval Defense
        { 'T1NavalDefense', 'ueb2109'},
        { 'T2NavalDefense', 'ueb2205'},
        { 'T3NavalDefense',		},
    -- Shields
        { 'T2ShieldDefense', 'ueb4202'    },
        { 'T3ShieldDefense', 'ueb4301'    },
        { 'T3ArtilleryDefenseShield',      },
        { 'T4ShieldDefense', },
    -- Missile Defense
        { 'T2MissileDefense','ueb4201'    },
        { 'T3MissileDefense','ueb4201'    },
    -- Radar Structures
        { 'T1Radar', 'ueb3101'     },
        { 'T2Radar', 'ueb3201'     },
        { 'T3Radar', 'ueb3104'     },
	-- Jammers
        { 'T2RadarJammer', 'ueb4203'    },
        { 'T2TeleportJammer', 'beb4209'           },
		{ 'T3TeleportJammer', 'beb4209'          },
	-- Sonars
        { 'T1Sonar', 'ueb3102'      },
        { 'T2Sonar', 'ueb3202'      },
        { 'T3Sonar', 'ues0305'      },
    -- Artillery Structures
		{ 'T1Artillery',	},
        { 'T2Artillery', 'ueb2303'  },
        { 'T3Artillery', 'ueb2302'  },
        { 'T4Artillery', 'ueb2401'  },
    -- Strategic Missile Structures
        { 'T2StrategicMissile', 'ueb2108' },
        { 'T3StrategicMissile', 'ueb2305' },
        { 'T4StrategicMissile', 'ueb2305' },		
        { 'T3StrategicMissileDefense', 'ueb4302' },
	-- Air Staging
        { 'T1AirStagingPlatform', 'seb5104' },
        { 'T2AirStagingPlatform', 'ueb5202' },
		{ 'T3AirStagingPlatform',           },
    -- Experimentals
	-- Land
		{ 'T4LandExperimental1', 'uel0401'	},
        { 'T4LandExperimental2', 'uel0401'	},	-- fatboy	
		{ 'T4LandExperimental3', 'uel0401'	},
		{ 'T4LandExperimental4',            },
	-- Air
		{ 'T4AirExperimental1',	},
        { 'T4AirExperimentalTransport'},
		{ 'T4AirExperimental2',	},
		{ 'T4AirExperimental3', },		
	-- Naval
        { 'T4SeaExperimental1', 'ues0401' },	-- Atlantis
		{ 'T4SeaExperimental2', },
	-- Satellites
        { 'T4SatelliteExperimental', 'xeb2402'  },
	-- Economic
        { 'T4EconExperimental', 'seb1401' },
    },

-- Aeon Building List
    {
	-- Power Structures
        { 'T3EnergyProduction', 'uab1301' },
        { 'T1EnergyProduction', 'uab1101' },
        { 'T1HydroCarbon', 'uab1102'      },
        { 'T2EnergyProduction', 'uab1201' },
	-- Mass Structures
        { 'T1Resource', 'uab1103' 	   },
        { 'T1MassCreation', 'uab1104'  },
        { 'T2Resource', 'uab1202'      },
        { 'T3Resource', 'uab1302'      },
        { 'T3MassCreation', 'uab1303'  },
    -- Land Factory Structures
        { 'T1LandFactory', 'uab0101'  },
        { 'T2LandFactory', 'uab0201'  },
        { 'T3LandFactory', 'uab0301'  },
        { 'T3QuantumGate', 'uab0304'  },
	-- Engineer Stations
        { 'T2EngineerSupport', },
        { 'T3EngineerSupport', },
    -- Air Factory Structures
        { 'T1AirFactory', 'uab0102'   },
        { 'T2AirFactory', 'uab0202'   },
        { 'T3AirFactory', 'uab0302'   },
    -- Sea Factory Structures
        { 'T1SeaFactory', 'uab0103'   },
        { 'T2SeaFactory', 'uab0203'   },
        { 'T3SeaFactory', 'uab0303'   },
    -- Storage Structures
        { 'MassStorage',  'uab1106'   },
        { 'EnergyStorage', 'uab1105'  },
        { 'T3Storage', 'uab1105'	  },
        { 'T4Storage', 'bab1106'      },
	-- Walls
        { 'Wall', 'uab5101'     },
        { 'T2Wall', 'uam0004'   },
	-- Point Defense
        { 'T1GroundDefense', 'uab2101'  },
        { 'T2GroundDefense', 'uab2301'  },
        { 'T2GroundDefenseAmphibious', 'uab2301'  },
		{ 'T3GroundDefense', 'uab2301'  },
		{ 'T4GroundDefense', 'uab2301'  },
    -- Naval Defense
        { 'T1NavalDefense', 'uab2109'   },
        { 'T2NavalDefense', 'uab2205'   },
        { 'T3NavalDefense',				},
	-- AA Defense
        { 'T1AADefense', 'uab2104'   },
        { 'T2AADefense', 'uab2204'   },
		{ 'T2AADefenseAmphibious', 'uab2204'        },
        { 'T3AADefense', 'uab2304'   },
        { 'T4AADefense',    },
    -- Shields
        { 'T2ShieldDefense', 'uab4202'  },
        { 'T3ShieldDefense', 'uab4301'  },
        { 'T4ShieldDefense',   },
    -- Missile Defense
        { 'T2MissileDefense', 'uab4201'  },
        { 'T3MissileDefense', 'uab4201'  },
	-- Radars
        { 'T1Radar', 'uab3101'    },
        { 'T2Radar', 'uab3201'    },
        { 'T3Radar', 'uab3104'    },
        { 'T3Optics', 'xab3301'   },
	-- Jammers 
        { 'T2RadarJammer', 'uab4203'     },
        { 'T2TeleportJammer', 'bab4209'  },
		{ 'T3TeleportJammer', 'bab4209'  },
	-- Sonars
        { 'T1Sonar', 'uab3102'      },
        { 'T2Sonar', 'uab3202'      },
        { 'T3Sonar', 'uas0305'      },
	-- Artillery
		{ 'T1Artillery',	},
        { 'T2Artillery', 'uab2303'		},
        { 'T3Artillery', 'uab2302'      },
        { 'T3RapidArtillery', 'xab2307' },		
		{ 'T4Artillery', 'xab2307'		},
	-- Strategic Missile Structures
        { 'T2StrategicMissile', 'uab2108'			},
        { 'T3StrategicMissile', 'uab2305'   		},
        { 'T3StrategicMissileDefense', 'uab4302'	},
	-- Air Staging
        { 'T1AirStagingPlatform', 'sab5104' },
        { 'T2AirStagingPlatform', 'uab5202' },
		{ 'T3AirStagingPlatform',},
	-- Experimentals
	-- Land
		{'T4LandExperimental1', 'ual0401'	},
		{'T4LandExperimental2', 'ual0401'	},
        {'T4LandExperimental3', 'ual0401'	},	-- Ernie
		{'T4LandExperimental4', },
	-- Air
        {'T4AirExperimental1', 'uaa0310'	},	-- Czar
        { 'T4AirExperimentalTransport'},        
		{'T4AirExperimental2', 'uaa0310'	},
		{'T4AirExperimental3', 'uaa0310'	},
	-- Naval
        {'T4SeaExperimental1', 'uas0401'	},	-- Tempest
		{'T4SeaExperimental2',	},
	-- Economic
        {'T4EconExperimental', 'xab1401'	},
	-- Satellite
        {'T4SatelliteExperimental', 'xab2404'	},
    },

-- Cybran Building List
    {
    -- Power Structures
        { 'T1EnergyProduction', 'urb1101'	},
        { 'T1HydroCarbon', 'urb1102'        },
        { 'T2EnergyProduction', 'urb1201'   },
        { 'T3EnergyProduction', 'urb1301'   },
    -- Mass Structures
        { 'T1Resource', 'urb1103'  			},
        { 'T1MassCreation', 'urb1104'       },
        { 'T2Resource', 'urb1202'			},
        { 'T3Resource', 'urb1302'			},
        { 'T3MassCreation', 'urb1303'		},
	-- Factory Structures
        { 'T1LandFactory', 'urb0101'	},
        { 'T2LandFactory', 'urb0201'	},
        { 'T3LandFactory', 'urb0301'	},
        { 'T3QuantumGate', 'urb0304'	},
        { 'T1AirFactory', 'urb0102'		},
        { 'T2AirFactory', 'urb0202'		},
        { 'T3AirFactory', 'urb0302'		},
        { 'T1SeaFactory', 'urb0103'		},
        { 'T2SeaFactory', 'urb0203'		},
        { 'T3SeaFactory', 'urb0303'		},
	-- Engineer Stations
        { 'T2EngineerSupport', 'xrb0104'	},
        { 'T3EngineerSupport', 'xrb0204'	},
	-- Storage Structures
        { 'MassStorage', 'urb1106'	},
        { 'EnergyStorage','urb1105'	},
        { 'T3Storage','urb1105'     },
        { 'T4Storage','brb1106'     },
	-- Defense Structures
        { 'Wall', 'urb5101'		},
        { 'T2Wall','urm0004'	},
	-- Point Defense
        { 'T1GroundDefense', 'urb2101'      },
        { 'T2GroundDefense', 'urb2301'      },
		{ 'T2GroundDefenseAmphibious', 'urb2301'      },
        { 'T3GroundDefense', 'urb2301'      },
        { 'T4GroundDefense', 'urb2301'      },
	-- Naval Defense
        { 'T1NavalDefense', 'urb2109'		},
        { 'T2NavalDefense', 'urb2205'		},
        { 'T3NavalDefense', 'xrb2308'		},
	-- AA Defense
        { 'T1AADefense', 'urb2104'	},
        { 'T2AADefense', 'urb2204'	},
		{ 'T2AADefenseAmphibious', 'urb2204'        },
        { 'T3AADefense', 'urb2304'	},
        { 'T4AADefense',   },
	-- Shield Defense
        { 'T2ShieldDefense', 'urb4202'	},
        { 'T3ShieldDefense', 'urb4207'	},
        { 'T4ShieldDefense',   },
	-- Missile Defense
        { 'T2MissileDefense', 'urb4201'	},
        { 'T3MissileDefense', 'urb4201'	},
	-- Radars
		{ 'T1Radar', 'urb3101'	},
        { 'T2Radar', 'urb3201'	},
        { 'T3Radar', 'urb3104'	},
        { 'T3Optics', 'xrb3301'	},
	-- Jammers
        { 'T2RadarJammer', 'urb4203'	},
        { 'T2TeleportJammer', 'brb4209' },
		{ 'T3TeleportJammer', 'brb4209' },
	-- Sonars
        { 'T1Sonar', 'urb3102'	},
        { 'T2Sonar', 'urb3202'	},
        { 'T3Sonar', 'urs0305'	},
	-- Artillery
		{ 'T1Artillery',	},
        { 'T2Artillery', 'urb2303'	},
        { 'T3Artillery', 'urb2302'	},
        { 'T4Artillery', 'url0401'	},	-- Scathis
	-- Strat Missiles
        { 'T2StrategicMissile', 'urb2108'			},
        { 'T3StrategicMissile', 'urb2305'			},
        { 'T3StrategicMissileDefense', 'urb4302'	},
	-- Air Staging
	    { 'T1AirStagingPlatform', 'srb5104' },
        { 'T2AirStagingPlatform', 'urb5202'	},
		{ 'T3AirStagingPlatform', },
	-- Experimentals
	-- Land
		{ 'T4LandExperimental1', 'url0402'	},
        { 'T4LandExperimental2', 'url0402'	},	-- MonkeyLord
		{ 'T4LandExperimental3', 'xrl0403'	},	-- Megalith
        { 'T4LandExperimental4', },
	-- Air
        { 'T4AirExperimental1', 'ura0401'	},	-- Ripper
        { 'T4AirExperimentalTransport'},        
		{ 'T4AirExperimental2', 'ura0401'	},
		{ 'T4AirExperimental3', 'ura0401'	},
	-- Naval
		{ 'T4SeaExperimental1',	},
		{ 'T4SeaExperimental2',	},
	-- Economic
        { 'T4EconExperimental', 'srb1401'   },
    },

-- Seraphim Building List
    {
	-- Power Structures
        {'T1EnergyProduction', 'xsb1101'	},
        {'T1HydroCarbon','xsb1102'			},
        {'T2EnergyProduction','xsb1201'		},
        {'T3EnergyProduction','xsb1301'		},
	-- Mass Structures
        {'T1Resource','xsb1103'		},
        {'T1MassCreation','xsb1104' },
        {'T2Resource','xsb1202'		},
        {'T3Resource','xsb1302'		},
        {'T3MassCreation','xsb1303' },
	-- Factories
        { 'T1LandFactory', 'xsb0101'	},
        { 'T2LandFactory', 'xsb0201'    },
        { 'T3LandFactory', 'xsb0301'    },
        { 'T3QuantumGate', 'xsb0304'    },
        { 'T1AirFactory',  'xsb0102'    },
        { 'T2AirFactory',  'xsb0202'	},
        { 'T3AirFactory',  'xsb0302'	},
        { 'T1SeaFactory',  'xsb0103'	},
        { 'T2SeaFactory',  'xsb0203'	},
        { 'T3SeaFactory',  'xsb0303'	},
	-- Engineer Stations
        { 'T2EngineerSupport', },
        { 'T3EngineerSupport', },
	-- Storage Structures
        { 'MassStorage', 'xsb1106'		},
        { 'EnergyStorage', 'xsb1105'	},
        { 'T3Storage', 'xsb1105'		},
        { 'T4Storage', 'bsb1106'		},
	-- Defense Structures
        { 'Wall', 'xsb5101'		},
        { 'T2Wall', 'xsm0001'	},		
	-- Point Defense
        { 'T1GroundDefense', 'xsb2101'  },
        { 'T2GroundDefense', 'xsb2301'  },
		{ 'T2GroundDefenseAmphibious', 'xsb2301'  },
        { 'T3GroundDefense', 'xsb2301'  },
        { 'T4GroundDefense', 'xsb2301'  },
	-- Naval Defense
        { 'T1NavalDefense', 'xsb2109'  },
        { 'T2NavalDefense', 'xsb2205'  },
        { 'T3NavalDefense',	},
	-- AA Defense
		{ 'T1AADefense', 'xsb2104'     },
        { 'T2AADefense', 'xsb2204'     },
		{ 'T2AADefenseAmphibious', 'xsb2204' },
        { 'T3AADefense', 'xsb2304'     },
        { 'T4AADefense', },
	-- Shields
        { 'T2ShieldDefense', 'xsb4202'      },
        { 'T3ShieldDefense', 'xsb4301'		},
        { 'T4ShieldDefense', },
	-- Missile Defense
        { 'T2MissileDefense', 'xsb4201'	},
        { 'T3MissileDefense', 'xsb4201' },
	-- Radars 
        { 'T1Radar', 'xsb3101'	},
        { 'T2Radar', 'xsb3201'	},
        { 'T3Radar', 'xsb3104'	},
	-- Jammers
		{ 'T2RadarJammer', 'xsb4203'	},
        { 'T2TeleportJammer', 'bsb4209' },
		{ 'T3TeleportJammer', 'bsb4209' },
	-- Sonars
        { 'T1Sonar', 'xsb3102'	},
        { 'T2Sonar', 'xsb3202'	},
        { 'T3Sonar', 'xrs0305'  },
	-- Artillery
		{ 'T1Artillery',	},
        { 'T2Artillery', 'xsb2303'	},
        { 'T3Artillery', 'xsb2302'  },
        { 'T4Artillery', 'xsb2401'	},	-- Ylona Oss Nuke Launcher
	-- Strat Missiles
        { 'T2StrategicMissile','xsb2108'		},
        { 'T3StrategicMissile','xsb2305'		},
        { 'T3StrategicMissileDefense','xsb4302'	},
		{ 'T4StrategicMissile', 'xsb2401'		},
	-- Air Staging
        { 'T1AirStagingPlatform', 'ssb5104' },
        { 'T2AirStagingPlatform', 'xsb5202' },
		{ 'T3AirStagingPlatform', },

	-- Experimentals
	-- Land
        {'T4LandExperimental1', 'xsl0401'	},	-- Ythotha
        {'T4LandExperimental2', 'xsl0401'	},
        {'T4LandExperimental3', 'xsl0401'	},
        {'T4LandExperimental4', },
	-- Air
        {'T4AirExperimental1', 'xsa0402'	},	-- Ahwassa Bomber
        {'T4AirExperimentalTransport'},      
        {'T4AirExperimental2', 'xsa0402'	},
        {'T4AirExperimental3', 'xsa0402'	},
	-- Naval
		{ 'T4SeaExperimental1',	},
		{ 'T4SeaExperimental2',	},
	-- Economic
        {'T4EconExperimental', 'ssb1401'	},
    }
}


-- RebuildStructuresTemplate

-- The code that used this table seems to no longer be used - if it ever was
-- Actually appears to be something from the initial SupCom

RebuildStructuresTemplate = {}
