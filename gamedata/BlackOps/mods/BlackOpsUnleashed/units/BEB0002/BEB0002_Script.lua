local TShieldStructureUnit = import('/lua/terranunits.lua').TShieldStructureUnit

BEB0002 = Class(TShieldStructureUnit) {

Parent = nil,

SetParent = function(self, parent, droneName)
    self.Parent = parent
    self.Drone = droneName
end,

	OnStopBeingBuilt = function(self,builder,layer)

    self.ShieldEmitterTable = {}
    self:ForkThread(self.ShieldEmitter)
        TShieldStructureUnit.OnStopBeingBuilt(self,builder,layer)
    end,
    -- Make this unit invulnerable
    OnDamage = function()
    end,

    ShieldEmitter = function(self)
    -- Are we dead yet, if not then wait 0.5 second
    if not self.Dead then
        WaitSeconds(0.5)
        -- Are we dead yet, if not spawn ShieldEmitter
        if not self.Dead then

            -- Gets the platforms current orientation
            local platOrient = self:GetOrientation()

            -- Gets the current position of the platform in the game world
            local location = self:GetPosition('Shield02')

            -- Creates our ShieldEmitter over the platform with a ranomly generated Orientation
            local ShieldEmitter = CreateUnit('beb0006', self:GetArmy(), location[1], location[2], location[3], platOrient[1], platOrient[2], platOrient[3], platOrient[4], 'Air') 

            -- Adds the newly created ShieldEmitter to the parent platforms ShieldEmitter table
            table.insert (self.ShieldEmitterTable, ShieldEmitter)

            ShieldEmitter:AttachTo(self, 'Shield02')

            -- Sets the platform unit as the ShieldEmitter parent
            ShieldEmitter:SetParent(self, 'beb0002')
            ShieldEmitter:SetCreator(self)  
            -- ShieldEmitter clean up scripts
            self.Trash:Add(ShieldEmitter)
        end
    end 
end,

KillShieldEmitter = function(self, instigator, type, overkillRatio)
    -- Small bit of table manipulation to sort thru all of the avalible rebulder bots and remove them after the platform is dead
    if table.getn({self.ShieldEmitterTable}) > 0 then
        for k, v in self.ShieldEmitterTable do 
            IssueClearCommands({self.ShieldEmitterTable[k]}) 
            IssueKillSelf({self.ShieldEmitterTable[k]})
        end
    end
end,
    DeathThread = function(self)
        self:Destroy()
    end,
}
TypeClass = BEB0002

