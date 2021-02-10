config = {
	{
		default = 1,
		label = 'Experimental Resource Storage',
		key = 'ExpStorage',
		help = "Disable to exclude the Experimental Resource Storage building this mod normally adds to each faction.",
		values = {
			{
				text = 'Enabled',
				key = 'include',
			},
			{
				text = 'Disabled',
				key = 'ExpStorage',
			},
		},
	},
	{   default = 1,
		label = "<LOC CityscapesSpawn_LOB>Cityscapes: Player Slots",
		help = "<LOC CityscapesSpawn_LOB_D>Defines which player spawn locations cities can spawn at.",
		key = 'CityscapesSpawn',
		values = {
			{
				text = "<LOC CityscapesSpawn_LOB_EmptySpots>Empty slots",
				help = "<LOC CityscapesSpawn_LOB_EmptySpotsD>Cities can spawn in empty player spawn locations.",
				key = 'EmptySpots',
			},
			{
				text = "<LOC CityscapesSpawn_LOB_AllSlots>All slots",
				help = "<LOC CityscapesSpawn_LOB_AllSlotsD>Cities can spawn in any player spawn location.",
				key = 'AllSlots',
			},
			{
				text = "<LOC CityscapesSpawn_LOB_OccupiedSlots>Occupied slots",
				help = "<LOC CityscapesSpawn_LOB_OccupiedSlotsD>Cities can spawn around players.",
				key = 'OccupiedSlots',
			},
			{
				text = "<LOC CityscapesSpawn_LOB_false>No Slots",
				help = "<LOC CityscapesSpawn_LOB_falseD>Cities won't spawn at player spawn location.",
				key = 'false',
			},
		},
	},
}