--**  File     :  /lua/DefaultBuffField.lua

local BuffField = import('/lua/sim/BuffField.lua').BuffField

DefaultBuffField = Class(BuffField) {

    FieldVisualEmitter = '/effects/emitters/seraphim_regenerative_aura_01_emit.bp',

    OnCreate = function(self,spec)

        BuffField.OnCreate(self,spec)
		
    end,

}