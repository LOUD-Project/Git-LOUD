--**  File     :  /lua/defaultantimissile.lua
--**  Author(s):  Gordon Duclos
--**  Summary  :  Default definitions collision beams

local Entity = import('/lua/sim/Entity.lua').Entity

local LOUDENTITY = EntityCategoryContains
local LOUDINSERT = table.insert
local LOUDSTATE = ChangeState
local WaitSeconds = WaitSeconds

local GetArmy = moho.entity_methods.GetArmy

local WaitTicks = coroutine.yield

Flare = Class(Entity) {

    OnCreate = function(self, spec)

        self.Owner = spec.Owner
        self.Radius = spec.Radius or 5
        self:SetCollisionShape('Sphere', 0, 0, 0, self.Radius)
        self:SetDrawScale(self.Radius)
        self:AttachTo(spec.Owner, -1)
        self.RedirectCat = spec.Category or 'MISSILE'
		
    end,

    -- We only divert projectiles. The flare-projectile itself will be responsible for
    -- accepting the collision and causing the hostile projectile to impact.
    OnCollisionCheck = function(self,other)
	
        if LOUDENTITY(ParseEntityCategory(self.RedirectCat), other) and (GetArmy(self) != GetArmy(other)) then
            other:SetNewTarget(self.Owner)
        end
		
        return false
		
    end,
}

AAFlare = Class(Entity) {

	OnCreate = function(self, spec)
	
		LOG("*AI DEBUG AAFlare Created")

        self.Owner = spec.Owner
        self.Radius = spec.Radius or 3
        self.Army = spec.Owner.Sync.army		

        self:SetCollisionShape('Sphere', 0, 0, 0, self.Radius)
        self:SetDrawScale(self.Radius)
		
		self.RedirectCat = categories.MISSILE * categories.ANTIAIR

	end,
	
	OnCollisionCheck = function(self,other)
	
		LOG("*AI DEBUG FlareCollision")
		
        if LOUDENTITY(self.RedirectCat, other) and self.Army ~= other:GetArmy() and not other.Deflected then

			LOG("*AI DEBUG AAFlare Collision - New target")
			other:SetNewTarget(self.Owner)

			LOG("*AI DEBUG AAFlare Collision - New Turn")
			other:SetTurnRate(540)

			LOG("*AI DEBUG AAFlare Collision - deflected")
			other.Deflected = true

        end

		return false
	
	end,
}

DepthCharge = Class(Entity) {

    OnCreate = function(self, spec)
	
        self.Owner = spec.Owner
        self.Radius = spec.Radius
        self:SetCollisionShape('Sphere', 0, 0, 0, self.Radius)
        self:SetDrawScale(self.Radius)
        self:AttachTo(spec.Owner, -1)
		
    end,

    -- We only divert projectiles. The Owner will be responsible for
    -- accepting the collision and causing the hostile projectile to impact.
    OnCollisionCheck = function(self,other)
	
        if LOUDENTITY(categories.TORPEDO, other) and GetArmy(self) != GetArmy(other) then
		
			if not self.Owner.Dead then
				
				-- send enemy torpedoes at the projectile
				other:SetNewTarget(self.Owner)
				
			end
        end
		
        return false
    end,
}

MissileDetector = Class(Entity) {

    RedirectBeams = {'/effects/emitters/particle_cannon_beam_02_emit.bp'},
    EndPointEffects = {'/effects/emitters/particle_cannon_end_01_emit.bp',},

    OnCreate = function(self, spec)

		Entity.OnCreate(self, spec)

        self.Army = spec.Owner.Sync.army
		self.AttachBone = spec.AttachBone
        self.Owner = spec.Owner
		self.Radius = spec.Radius
		
		self.RateOfFire = 1	-- ticks
		
        self:SetCollisionShape('Sphere', 0, 0, 0, spec.Radius)
        self:SetDrawScale(spec.Radius)
		
        self:AttachTo(spec.Owner, spec.AttachBone)
		
		LOUDSTATE(self, self.WaitingState)

    end,

    OnDestroy = function(self)
        Entity.OnDestroy(self)
        LOUDSTATE(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    WaitingState = State{

	    -- Return true to process this collision, false to ignore it.
		OnCollisionCheck = function(self, other)

            if other != self.EnemyProj and IsEnemy( self.Army, other:GetArmy() ) then

                if EntityCategoryContains( categories.MISSILE * categories.ANTIAIR, other) then
					
					other:SetVelocity(1)
					
					-- ok we can touch the projectile
					self.Enemy = other:GetLauncher()
					self.EnemyProj = other
				
					if self.Enemy then

						other:SetNewTarget(self.Enemy)
						other:TrackTarget(true)
						other:SetTurnRate(540)

						ChangeState(self, self.RedirectingState)
					end
				end
            end
			
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)

            if not self or self:BeenDestroyed() 
				or not self.EnemyProj or self.EnemyProj:BeenDestroyed() 
				or not self.Owner or self.Owner:IsDead() then
				
                return
            end

            local beams = {}
            local army = self.Army
            
            for _, v in self.RedirectBeams do               
                LOUDINSERT(beams, AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, army, v))
            end
            
            if self.Enemy then
                -- Set collision to friends active so that when the missile reaches its source it can deal damage. 
			    self.EnemyProj.DamageData.CollideFriendly = true         
			    self.EnemyProj.DamageData.DamageFriendly = true 
			    self.EnemyProj.DamageData.DamageSelf = true 
			end
			
            if self.Enemy and not self.Enemy:BeenDestroyed() then

                WaitTicks( self.RateOfFire )
				
                if not self.EnemyProj:BeenDestroyed() then
                    self.EnemyProj:TrackTarget(false)
                end
				
            else
				
                local vectordam = {}
                vectordam.x = 0
                vectordam.y = 1
                vectordam.z = 0
				
				--LOG("*AI DEBUG Missile Destroy")
				
                self.EnemyProj:Destroy()	--DoTakeDamage(self.Owner, 30, vectordam,'Fire')

                WaitTicks( self.RateOfFire )

            end
			
            for _, v in beams do
                v:Destroy()
            end
			
            LOUDSTATE(self, self.WaitingState)
        end,

        OnCollisionCheck = function(self, other)

            return false
        end,
    },
	
}


MissileRedirect = Class(Entity) {

    RedirectBeams = {'/effects/emitters/particle_cannon_beam_02_emit.bp'},
    EndPointEffects = {'/effects/emitters/particle_cannon_end_01_emit.bp',},

    OnCreate = function(self, spec)
	
        Entity.OnCreate(self, spec)
		
        self.Owner = spec.Owner
        self.Radius = spec.Radius
        self.RedirectRateOfFire = spec.RedirectRateOfFire or 1
        self:SetCollisionShape('Sphere', 0, 0, 0, self.Radius)
        self:SetDrawScale(self.Radius)
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
		
        LOUDSTATE(self, self.WaitingState)
		
        -- rest of the code is for loyalist tactical missile deflection fix   [161]
        local bp = self:GetBlueprint()
        local ProjectileCategories = bp.ProjectileCategories or { 'MISSILE -STRATEGIC' }
        local ParsedProjectileCategories = {}

        for k, category in ProjectileCategories do
		
            if type(category) == 'string' then
			
                LOUDINSERT(ParsedProjectileCategories, ParseEntityCategory(category) )
				
            else
			
                LOUDINSERT(ParsedProjectileCategories, category)
				
            end
			
        end

        self.ProjectileCategories = ParsedProjectileCategories
		
    end,
	
    GetBlueprint = function(self)
        return self.Owner:GetBlueprint().Defense.AntiMissile
    end,
	
    OnDestroy = function(self)
        Entity.OnDestroy(self)
        LOUDSTATE(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    WaitingState = State{
	
	    -- Return true to process this collision, false to ignore it.
		OnCollisionCheck = function(self, other)

            if other != self.EnemyProj and IsEnemy( self:GetArmy(), other:GetArmy() ) then

                -- check if we can touch the projectile  [161]
                local match = false
				
                for k, cat in self.ProjectileCategories do
				
                    if EntityCategoryContains(cat, other) then
                        match = true
                        break
                    end
					
                end
				
                if not match then
                    return false
                end

                -- ok we can touch the projectile
                self.Enemy = other:GetLauncher()
                self.EnemyProj = other
				
                if self.Enemy then
				
                    other:SetNewTarget(self.Enemy)
                    other:TrackTarget(true)
                    other:SetTurnRate(720)
					
                end
				
                ChangeState(self, self.RedirectingState)
            end
			
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)
		
            if not self or self:BeenDestroyed() 
            or not self.EnemyProj or self.EnemyProj:BeenDestroyed() 
            or not self.Owner or self.Owner:IsDead() then
                return
            end
            
            local beams = {}
            local army = GetArmy(self)
            
            for _, v in self.RedirectBeams do               
                LOUDINSERT(beams, AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, army, v))
            end
            
            if self.Enemy then
                -- Set collision to friends active so that when the missile reaches its source it can deal damage. 
			    self.EnemyProj.DamageData.CollideFriendly = true         
			    self.EnemyProj.DamageData.DamageFriendly = true 
			    self.EnemyProj.DamageData.DamageSelf = true 
			end
			
            if self.Enemy and not self.Enemy:BeenDestroyed() then
			
                WaitTicks( (1/self.RedirectRateOfFire) * 10)
				
                if not self.EnemyProj:BeenDestroyed() then
                    self.EnemyProj:TrackTarget(false)
                end
				
            else
			
                WaitTicks( (1/self.RedirectRateOfFire) * 10)
				
                local vectordam = {}
                vectordam.x = 0
                vectordam.y = 1
                vectordam.z = 0
				
                self.EnemyProj:DoTakeDamage(self.Owner, 30, vectordam,'Fire')
            end
			
            for _, v in beams do
                v:Destroy()
            end
			
            LOUDSTATE(self, self.WaitingState)
        end,

        OnCollisionCheck = function(self, other)
            return false
        end,
    },

}
