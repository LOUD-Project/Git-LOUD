--  /lua/sim/Prop.lua
-- This defines the behavior of props

local Entity = import('/lua/sim/Entity.lua').Entity

local PlayReclaimEndEffects = import('/lua/EffectUtilities.lua').PlayReclaimEndEffects
local RebuildBonusCheckCallback = import('/lua/sim/RebuildBonusCallback.lua').RunRebuildBonusCallback

local ForkThread = ForkThread

local LOUDCOPY = table.copy
local LOUDINSERT = table.insert
local LOUDMAX = math.max

local TrashBag = TrashBag
local TrashAdd = TrashBag.Add
local TrashDestroy = TrashBag.Destroy

local GetBlueprint = moho.entity_methods.GetBlueprint

Prop = Class(moho.prop_methods, Entity) {

    __init = false,
    
    __post_init = false,

    OnCreate = function(self)
    
        Entity.OnCreate(self)

		local bp = GetBlueprint(self).Economy
		
        self.MassReclaim = bp.ReclaimMassMax or 0
        self.EnergyReclaim = bp.ReclaimEnergyMax or 0
        self.ReclaimTimeMassMult = bp.ReclaimMassTimeMultiplier or 1
        self.ReclaimTimeEnergyMult = bp.ReclaimEnergyTimeMultiplier or 1
        self.MaxMassReclaim = bp.ReclaimMassMax or 0
        self.MaxEnergyReclaim = bp.ReclaimEnergyMax or 0
		
        self.CachePosition = LOUDCOPY(moho.entity_methods.GetPosition(self))

        local bp = GetBlueprint(self).Defense
		
        local maxHealth = 50
		
        if bp then
            maxHealth = LOUDMAX(maxHealth, bp.MaxHealth)
        end
		
        self:SetMaxHealth(maxHealth)
        self:SetHealth(self,maxHealth)
		
        if not EntityCategoryContains(categories.INVULNERABLE, self) then
            self.CanTakeDamage = true
        else
            self.CanTakeDamage = false
        end
        
        self.CanBeKilled = true
    end,
	
    ForkThread = function(self, fn, ...)

        local thread = ForkThread(fn, self, unpack(arg))
        
        if not self.Trash then
            self.Trash = TrashBag()
        end
		
        TrashAdd( self.Trash, thread )
		
        return thread
		
    end,
	
    GetCachePosition = function(self)
        return self.CachePosition
    end,
    
    SetCanTakeDamage = function(self, val)
        self.CanTakeDamage = val
    end,
    
    SetCanBeKilled = function(self, val)
        self.CanBeKilled = val
    end,

    CheckCanBeKilled = function(self,other)
        return self.CanBeKilled
    end,

    OnKilled = function(self, instigator, type, exceessDamageRatio )
        if not self.CanBeKilled then return end
        self:Destroy()
    end,
    
    OnReclaimed = function(self, entity)
        self.CreateReclaimEndEffects( entity, self )        
        self:Destroy()
    end,
    
    CreateReclaimEndEffects = function( self, target )
        PlayReclaimEndEffects( self, target )
    end,    
	
    Destroy = function(self)
        self.DestroyCalled = true
        moho.entity_methods.Destroy(self)
    end,
	
    OnDestroy = function(self)
        if self.IsWreckage and not self.DestroyCalled then
            RebuildBonusCheckCallback( self.CachePosition, self.AssociatedBP)
        end
        
        if self.Trash then
            TrashDestroy( self.Trash )
        end
    end,

    OnDamage = function(self, instigator, amount, direction, damageType)
    
        if not self.CanTakeDamage then
			return
		end
		
        local preAdjHealth = self:GetHealth()
		
        self:AdjustHealth(instigator, -amount)

        if self:GetHealth() <= 0 then
		
            if ( damageType == 'Reclaimed' ) then
                self:Destroy()
            else
                local excessDamageRatio = 0.0
				
                -- Calculate the excess damage amount
                local excess = preAdjHealth - amount
                local maxHealth = self:GetMaxHealth()
				
                if(excess < 0 and maxHealth > 0) then
                    excessDamageRatio = -excess / maxHealth
                end
                self:Kill(instigator, damageType, excessDamageRatio)
            end
        end
    end,

    OnCollisionCheck = function(self, other)
        return true
    end,

    SetReclaimValues = function(self, masstimemult, energytimemult, mass, energy)
        self.MassReclaim = LOUDMAX( 0, mass )
        self.EnergyReclaim = LOUDMAX( 0, energy )
        self.ReclaimTimeMassMult = masstimemult
        self.ReclaimTimeEnergyMult = energytimemult
    end,

    SetMaxReclaimValues = function(self, masstimemult, energytimemult, mass, energy)
        self.MaxMassReclaim = LOUDMAX( 0, mass )
        self.MaxEnergyReclaim = LOUDMAX( 0, energy )
        self.ReclaimTimeMassMult = masstimemult
        self.ReclaimTimeEnergyMult = energytimemult
    end,

    SetPropCollision = function(self, shape, centerx, centery, centerz, sizex, sizey, sizez, radius)
        self.CollisionRadius = radius
        self.CollisionSizeX = sizex
        self.CollisionSizeY = sizey
        self.CollisionSizeZ = sizez
        self.CollisionCenterX = centerx
        self.CollisionCenterY = centery
        self.CollisionCenterZ = centerz
        self.CollisionShape = shape
        
        if radius and shape == 'Sphere' then
            self:SetCollisionShape(shape, centerx, centery, centerz, sizex, sizey, sizez, radius)
        else
            self:SetCollisionShape(shape, centerx, centery, centerz, sizex, sizey, sizez)
        end
    end,

    -- Prop reclaiming
    -- time = the greater of either time to reclaim mass or energy
    -- time to reclaim mass or energy is defined as:
    -- Mass Time =  mass reclaim value / buildrate of thing reclaiming it * BP set mass mult
    -- Energy Time = energy reclaim value / buildrate of thing reclaiming it * BP set energy mult
    -- The time to reclaim is the highest of the two values above.
    GetReclaimCosts = function(self, reclaimer)

        local mtime = self.ReclaimTimeMassMult * (self.MassReclaim / reclaimer:GetBuildRate() )
        local etime = self.ReclaimTimeEnergyMult * (self.EnergyReclaim / reclaimer:GetBuildRate() )
		
        local time = mtime
		
        if mtime < etime then
		
            time = etime
        end
		
        return (time*.1), self.EnergyReclaim, self.MassReclaim
    end,

    -- Split this prop into multiple sub-props, placing one at each of our bone locations.
    -- The child prop names are taken from the names of the bones of this prop.
    --
    -- If this prop has bones named
    --           "one", "two", "two_01", "two_02"
    --
    -- We will create props named
    --           "../one_prop.bp", "../two_prop.bp", "../two_prop.bp", "../two_prop.bp"
    --
    -- Note that the optional _01, _02, _03 ending to the bone name is stripped off.
    --
    -- You can pass an optional 'dirprefix' arg saying where to look for the child props.
    -- If not given, it defaults to one directory up from this prop's blueprint location.
    SplitOnBonesByName = function(self, dirprefix)
	
        if not dirprefix then

            -- default dirprefix to parent dir of our own blueprint
            dirprefix = __blueprints[self.BlueprintId].SingleTreeDir or self:GetBlueprint().BlueprintId

            -- trim ".../groups/blah_prop.bp" to just ".../"
            dirprefix = string.gsub(dirprefix, "[^/]*/[^/]*$", "")

        end

        local newprops = {}

        for ibone=1, self:GetBoneCount()-1 do

            -- construct name of replacement mesh from name of bone, trimming off optional _01 _02 etc
            --local btrim = string.gsub( self:GetBoneName(ibone), "_?[0-9]+$", "")
            --local newbp = dirprefix .. string.gsub( self:GetBoneName(ibone), "_?[0-9]+$", "") .. "_prop.bp"

            local p = safecall("Creating prop", self.CreatePropAtBone, self, ibone, dirprefix .. string.gsub( self:GetBoneName(ibone), "_?[0-9]+$", "") .. "_prop.bp")
			
            if p then
                LOUDINSERT(newprops, p)
            end
        end

        self:Destroy()
        
        return newprops
    end,
    
    PlayPropSound = function(self, sound)
    
        local bp = self:GetBlueprint().Audio
        
        if bp and bp[sound] then
            self:PlaySound(bp[sound])
            return true
        end
        
        return false
    end,

	-- Play the specified ambient sound for the unit, and if it has
    -- AmbientRumble defined, play that too
    PlayPropAmbientSound = function(self, sound)
        if sound == nil then
            self:SetAmbientSound( nil, nil )
            return true
        else
            local bp = self:GetBlueprint().Audio
            if bp and bp[sound] then
                if bp.Audio['AmbientRumble'] then
                    self:SetAmbientSound( bp[sound], bp.Audio['AmbientRumble'] )
                else
                    self:SetAmbientSound( bp[sound], nil )
                end
                return true
            end
            return false
        end
    end,

}
