config = {
	{
		default = 1,
		label = 'Alert When: Issuing a Ferry order',
		key = 'Ferry',
		tooltip = "Whenver you give a transport a ferry order, a voiceover alert will play if this is set to enabled.",
		values = {
			{
				text = 'Enabled',
				key = 'on',
			},
			{
				text = 'Disabled',
				key = 'off',
			},
		}
	},
	{
		default = 1,
		label = 'Alert When: Own Mass Extractor Attacked',
		key = 'MexAttack',
		tooltip = "Whenver one of your own mass extractors takes damage, a voiceover alert will play if this is set to enabled.",
		values = {
			{
				text = 'Enabled',
				key = 'on',
			},
			{
				text = 'Disabled',
				key = 'off',
			},
		}
	},
	{
		default = 1,
		label = 'Alert When: Enemy Commander Spotted',
		key = 'EnemyCom',
		tooltip = "Whenever an enemy ACU comes into vision, a voiceover alert will play if this is set to enabled enabled.",
		values = {
			{
				text = 'Enabled',
				key = 'on',
			},
			{
				text = 'Disabled',
				key = 'off',
			},
		}
	},
}