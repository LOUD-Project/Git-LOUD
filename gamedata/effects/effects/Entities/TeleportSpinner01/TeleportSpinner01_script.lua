

local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local EffectTemplate = import('/lua/EffectTemplates.lua')

TeleportSpinner01 = Class(NullShell) {
    OnCreate = function(self)
        NullShell.OnCreate(self)
        local army = self:GetArmy()
		local CreateEmitterOnEntity = CreateEmitterOnEntity
       
        for k, v in EffectTemplate.CSGTestSpinner1 do
            CreateEmitterOnEntity( self, army, v )
        end
    end,
}

TypeClass = TeleportSpinner01

