

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')

TeleportSpinner02 = Class(NullShell) {
    OnCreate = function(self)
        NullShell.OnCreate(self)
        local army = self:GetArmy()
		local CreateEmitterOnEntity = CreateEmitterOnEntity
		
        for k, v in EffectTemplate.CSGTestSpinner2 do
            CreateEmitterOnEntity( self, army, v )
        end
    end,
}

TypeClass = TeleportSpinner02

