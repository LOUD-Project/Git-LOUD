--  Loud_AI_Naval_Platoons.lua

PlatoonTemplate { Name = 'T1WaterScoutForm',
    FactionSquads = {
        UEF = {
            { categories.FRIGATE, 1, 3, 'Guard', 'none' },
			{ categories.SUBMARINE + categories.LIGHTBOAT, 0, 3, 'Guard', 'none' },
			{ categories.DESTROYER, 0, 1, 'Attack', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
			{ categories.xes0205, 0, 1, 'Guard', 'none' },
        },
        Aeon = {
            { categories.FRIGATE, 1, 3, 'Guard', 'none' },
			{ categories.SUBMARINE, 0, 3, 'Guard', 'none' },
			{ categories.DESTROYER, 0, 1, 'Attack', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
			{ categories.LIGHTBOAT, 0, 2, 'Guard', 'none' },
        },
        Cybran = {
            { categories.FRIGATE, 1, 3, 'Guard', 'none' },
			{ categories.SUBMARINE, 0, 3, 'Guard', 'none' },
			{ categories.DESTROYER, 0, 1, 'Attack', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
			{ categories.DEFENSIVEBOAT, 0, 1, 'Guard', 'none' },
        },
        Seraphim = {
            { categories.FRIGATE, 1, 3, 'Guard', 'none' },
			{ categories.SUBMARINE, 0, 3, 'Guard', 'none' },
			{ categories.DESTROYER, 0, 1, 'Attack', 'none' },
			{ categories.CRUISER, 0, 1, 'Guard', 'none' },
        },
    }
}

PlatoonTemplate { Name = 'MassAttackNaval',

    GlobalSquads = {
        { (categories.SUBMARINE), 4, 12, 'Attack', 'none' },			# Submarines		
    },
	
}


PlatoonTemplate { Name = 'SeaAttack Small',
	
	FactionSquads = {
	
		UEF = {
	
			{ (categories.BATTLESHIP), 0, 1, 'Attack', 'none' },								# Capital Ships
			{ (categories.DESTROYER), 1, 6, 'Attack', 'none' },									# Destroyers
			{ (categories.CRUISER), 1, 5, 'Attack', 'none' },									# Cruisers
			{ (categories.FRIGATE), 4, 10, 'Attack', 'none' },									# Frigates
			{ (categories.SUBMARINE) + categories.LIGHTBOAT, 7, 16, 'Attack', 'none' },			# Submarines & Coopers
			{ (categories.DEFENSIVEBOAT), 1, 1, 'Guard', 'none' },								# UEF Shield

        },
		
        Aeon = {
	
			{ (categories.BATTLESHIP), 0, 1, 'Attack', 'none' },								# Capital Ships
			{ (categories.DESTROYER), 1, 6, 'Attack', 'none' },									# Destroyers
			{ (categories.CRUISER), 1, 5, 'Attack', 'none' },									# Cruisers
			{ (categories.FRIGATE), 4, 10, 'Attack', 'none' },									# Frigates
			{ (categories.SUBMARINE), 4, 12, 'Attack', 'none' },								# Submarines
			{ (categories.DEFENSIVEBOAT), 6, 6, 'Guard', 'none' },								# T1 Shard AA boat
		
        },
		
        Cybran = {
	
			{ (categories.BATTLESHIP), 0, 1, 'Attack', 'none' },								# Capital Ships
			{ (categories.DESTROYER), 1, 6, 'Attack', 'none' },									# Destroyers
			{ (categories.CRUISER), 1, 5, 'Attack', 'none' },									# Cruisers
			{ (categories.FRIGATE), 4, 10, 'Attack', 'none' },									# Frigates
			{ (categories.SUBMARINE), 4, 12, 'Attack', 'none' },								# Submarines
			{ (categories.DEFENSIVEBOAT), 1, 1, 'Guard', 'none' },								# Cyb CounterIntel
			
        },
		
        Seraphim = {
	
			{ (categories.BATTLESHIP), 0, 1, 'Attack', 'none' },								# Capital Ships
			{ (categories.DESTROYER), 1, 6, 'Attack', 'none' },									# Destroyers
			{ (categories.CRUISER), 1, 5, 'Attack', 'none' },									# Cruisers
			{ (categories.FRIGATE), 4, 10, 'Attack', 'none' },									# Frigates
			{ (categories.SUBMARINE), 4, 12, 'Attack', 'none' },								# Submarines
			
        },	
	
	},

}

PlatoonTemplate { Name = 'SeaAttack Medium',

	FactionSquads = {
	
		UEF = {

			{ (categories.BATTLESHIP), 1, 4, 'Attack', 'none' },												# Capital Ships
			{ (categories.DESTROYER), 3, 6, 'Attack', 'none' },													# Destroyers
			{ (categories.CRUISER), 4, 10, 'Attack', 'none' },													# Cruisers
			{ (categories.FRIGATE), 4, 10, 'Attack', 'none' },													# Frigates
			{ (categories.SUBMARINE) + categories.LIGHTBOAT, 7, 21, 'Attack', 'none' },							# Submarines and UEF Torp Boat
			{ (categories.MOBILE * categories.NAVAL * categories.CARRIER), 0, 1, 'Guard', 'none' },				# Carriers		
			{ (categories.DEFENSIVEBOAT), 0, 4, 'Guard', 'none' },												# UEF Shield
			
		},
		
		Aeon = {

			{ (categories.BATTLESHIP), 1, 4, 'Attack', 'none' },												# Capital Ships
			{ (categories.DESTROYER), 2, 6, 'Attack', 'none' },													# Destroyers
			{ (categories.CRUISER), 5, 10, 'Attack', 'none' },													# Cruisers
			{ (categories.FRIGATE), 4, 10, 'Attack', 'none' },													# Frigates
			{ (categories.SUBMARINE), 5, 16, 'Attack', 'none' },												# Submarines
			{ (categories.MOBILE * categories.NAVAL * categories.CARRIER), 0, 1, 'Guard', 'none' },				# Carriers		
			{ (categories.DEFENSIVEBOAT), 6, 8, 'Guard', 'none' },												# T1 Shard AA Boat
			
		},
		
		Cybran = {

			{ (categories.BATTLESHIP), 1, 4, 'Attack', 'none' },												# Capital Ships
			{ (categories.DESTROYER), 2, 6, 'Attack', 'none' },													# Destroyers
			{ (categories.CRUISER), 4, 10, 'Attack', 'none' },													# Cruisers
			{ (categories.FRIGATE), 4, 10, 'Attack', 'none' },													# Frigates
			{ (categories.SUBMARINE), 5, 16, 'Attack', 'none' },												# Submarines
			{ (categories.MOBILE * categories.NAVAL * categories.CARRIER), 0, 1, 'Guard', 'none' },				# Carriers		
			{ (categories.DEFENSIVEBOAT), 2, 3, 'Guard', 'none' },												# CounterIntel
			
		},
	
		Seraphim = {

			{ (categories.BATTLESHIP), 1, 4, 'Attack', 'none' },												# Capital Ships
			{ (categories.DESTROYER), 3, 6, 'Attack', 'none' },													# Destroyers
			{ (categories.CRUISER), 4, 10, 'Attack', 'none' },													# Cruisers
			{ (categories.FRIGATE), 6, 10, 'Attack', 'none' },													# Frigates
			{ (categories.SUBMARINE), 6, 16, 'Attack', 'none' },												# Submarines
			{ (categories.MOBILE * categories.NAVAL * categories.CARRIER), 0, 1, 'Guard', 'none' },				# Carriers		
			
		},
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Medium - Base Patrol',

    GlobalSquads = {
	
        { (categories.DESTROYER), 0, 2, 'Attack', 'none' },									# Destroyers
        { (categories.CRUISER), 0, 2, 'Attack', 'none' },									# Cruisers
        { (categories.FRIGATE), 3, 4, 'Attack', 'none' },									# Frigates
        { (categories.DEFENSIVEBOAT), 0, 1, 'Guard', 'none' },								# UEF Shield and Cyb CounterIntel
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Submarine - Base Patrol',

    GlobalSquads = {
	
        { (categories.SUBMARINE) + categories.LIGHTBOAT, 5, 16, 'Attack', 'none' },			# Submarines		
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Large',

    FactionSquads = {
	
		UEF = {

			{ (categories.BATTLESHIP), 3, 8, 'Attack', 'none' },												# Capital Ships
			{ (categories.DESTROYER), 5, 12, 'Attack', 'none' },												# Destroyers
			{ (categories.CRUISER), 5, 12, 'Attack', 'none' },													# Cruisers
			{ (categories.FRIGATE), 4, 12, 'Attack', 'none' },													# Frigates
			{ (categories.SUBMARINE) + categories.LIGHTBOAT, 7, 35, 'Attack', 'none' },							# Submarines & Coopers
			{ (categories.MOBILE * categories.NAVAL * categories.CARRIER), 0, 1, 'Guard', 'none' },				# Carriers
			{ (categories.DEFENSIVEBOAT), 6, 8, 'Guard', 'none' },												# UEF Shield
			
		},
	
		Aeon = {

			{ (categories.BATTLESHIP - categories.xas0306), 3, 8, 'Attack', 'none' },							# Capital Ships
			{ (categories.xas0306), 0, 3, 'Artillery', 'none' },												# Missile Cruisers
			{ (categories.DESTROYER), 5, 12, 'Attack', 'none' },												# Destroyers
			{ (categories.CRUISER), 6, 12, 'Attack', 'none' },													# Cruisers
			{ (categories.FRIGATE), 4, 12, 'Attack', 'none' },													# Frigates
			{ (categories.SUBMARINE), 7, 25, 'Attack', 'none' },												# Submarines
			{ (categories.MOBILE * categories.NAVAL * categories.CARRIER), 0, 1, 'Guard', 'none' },				# Carriers
			{ (categories.DEFENSIVEBOAT), 6, 10, 'Guard', 'none' },												# T1 AA Shard
			
		},
	
		Cybran = {

			{ (categories.BATTLESHIP), 3, 8, 'Attack', 'none' },												# Capital Ships
			{ (categories.DESTROYER), 5, 12, 'Attack', 'none' },												# Destroyers
			{ (categories.CRUISER), 5, 12, 'Attack', 'none' },													# Cruisers
			{ (categories.FRIGATE), 4, 12, 'Attack', 'none' },													# Frigates
			{ (categories.SUBMARINE), 7, 25, 'Attack', 'none' },												# Submarines
			{ (categories.MOBILE * categories.NAVAL * categories.CARRIER), 0, 1, 'Guard', 'none' },				# Carriers
			{ (categories.DEFENSIVEBOAT), 4, 6, 'Guard', 'none' },												# Cyb CounterIntel
			
		},
	
		Seraphim = {

			{ (categories.BATTLESHIP), 3, 8, 'Attack', 'none' },												# Capital Ships
			{ (categories.DESTROYER), 5, 12, 'Attack', 'none' },												# Destroyers
			{ (categories.CRUISER), 5, 12, 'Attack', 'none' },													# Cruisers
			{ (categories.FRIGATE), 4, 12, 'Attack', 'none' },													# Frigates
			{ (categories.SUBMARINE), 7, 25, 'Attack', 'none' },												# Submarines
			{ (categories.MOBILE * categories.NAVAL * categories.CARRIER), 0, 1, 'Guard', 'none' },				# Carriers
			
		},		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Bombardment',

    FactionSquads = {
	
		UEF = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												# Bombardment capable ships
			{ (categories.CRUISER), 5, 8, 'Support', 'none' },													# Cruisers
			{ (categories.DEFENSIVEBOAT), 3, 4, 'Guard', 'none' },												# Shield
			
		},
		
		Aeon = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												# Bombardment capable ships
			{ (categories.CRUISER), 5, 6, 'Support', 'none' },													# Cruisers
			{ (categories.DEFENSIVEBOAT), 4, 8, 'Guard', 'none' },												# AA
		
		},
		
		Cybran = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												# Bombardment capable ships
			{ (categories.CRUISER), 5, 8, 'Support', 'none' },													# Cruisers
			{ (categories.DEFENSIVEBOAT), 2, 3, 'Guard', 'none' },												# CounterIntel
		
		},
		
		Seraphim = {
	
			{ categories.BOMBARDMENT, 4, 8, 'Artillery', 'none' },												# Bombardment capable ships
			{ (categories.CRUISER), 5, 8, 'Support', 'none' },													# Cruisers
		
		},
		
    },
	
}

PlatoonTemplate { Name = 'SeaAttack Reinforcement',

    GlobalSquads = {
	
		{ (categories.MOBILE * categories.NAVAL * categories.CARRIER), 0, 1, 'Support', 'none' },			# Carriers
        { (categories.BATTLESHIP), 0, 4, 'Attack', 'none' },												# Capital Ships	
        { (categories.DESTROYER), 1, 6, 'Attack', 'none' },													# Destroyers
        { (categories.CRUISER), 1, 5, 'Attack', 'none' },													# Cruisers
        { (categories.FRIGATE), 4, 10, 'Attack', 'none' },													# Frigates
        { (categories.SUBMARINE), 5, 16, 'Attack', 'none' },												# Submarines		
        { (categories.DEFENSIVEBOAT), 0, 12, 'Guard', 'none' },												# Shield CounterIntel AA
        { (categories.LIGHTBOAT), 0, 12, 'Guard', 'none' },													# UEF Torp Boat
		
    },
	
}


PlatoonTemplate { Name = 'SeaNuke',
    GlobalSquads = {
        { categories.NAVAL * categories.NUKE, 1, 1, 'Attack', 'none' }
    },
}

PlatoonTemplate { Name = 'T4ExperimentalSea',
    Plan = 'ExperimentalAIHub',
	GlobalSquads = {
        { categories.NAVAL * categories.EXPERIMENTAL * categories.MOBILE, 1, 1, 'Attack', 'none' },
    },
}