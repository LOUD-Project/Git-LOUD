local Entity = import('/lua/sim/Entity.lua').Entity

local BlackOpsEffectTemplate = import('/mods/BlackOpsUnleashed/lua/BlackOpsEffectTemplates.lua')

local LOUDINSERT = table.insert
local LOUDSTATE = ChangeState
local LOUDENTITY = EntityCategoryContains
local LOUDEMITONENTITY = CreateEmitterOnEntity

local BeenDestroyed = moho.entity_methods.BeenDestroyed
local GetArmy = moho.entity_methods.GetArmy
local GetLauncher = moho.projectile_methods.GetLauncher
local SetCollisionShape = moho.entity_methods.SetCollisionShape
local SetDrawScale = moho.entity_methods.SetDrawScale

SeraLambdaFieldRedirector = Class(Entity) {

	LambdaEffects = BlackOpsEffectTemplate.EXLambdaRedirector,
    
    OnCreate = function(self, spec)
    
        Entity.OnCreate(self, spec)
        
        self.Army = GetArmy(self)
        self.Owner = spec.Owner
        
        self.Radius = spec.Radius
        self.RedirectRateOfFire = spec.RedirectRateOfFire or 1
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, self.Radius)
        SetDrawScale( self, self.Radius )
        
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
        
        LOUDSTATE( self, self.WaitingState)
        
		self.LambdaEffectsBag = {}
    end,

    OnDestroy = function(self)
        Entity.OnDestroy(self)
        LOUDSTATE(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    -- Return true to process this collision, false to ignore it.
    WaitingState = State{
    
        OnCollisionCheck = function(self, other)
            
            if other.lastRedirector and other.lastRedirector == self.Army then
                return false
            end

            if LOUDENTITY(categories.PROJECTILE, other)
            and not LOUDENTITY(categories.STRATEGIC, other) 
            and other != self.EnemyProj and IsEnemy( self.Army, GetArmy(other) ) then

                other.lastRedirector = self.Army                
                
                self.Enemy = GetLauncher(other)
                
                self.EnemyProj = other
				self.EXFiring = false
                
                if self.Enemy then
                
                    other:SetNewTarget(self.Enemy)
                    other:TrackTarget(true)
                    other:SetTurnRate(720)                
                    
					local targetspeed = other:GetCurrentSpeed()
                    
					other:SetVelocity( targetspeed * 2 )

					self.EXFiring = true
                end
                
				if self.EXFiring then
					LOUDSTATE(self, self.RedirectingState)
				end
                
            end
            
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)
		
            if not self or self:BeenDestroyed()
            or not self.EnemyProj or BeenDestroyed( self.EnemyProj )
            or not self.Owner or self.Owner.Dead then
                return
            end
            
            local beams = {}
            
            if self.RedirectBeams then
            
                for _, v in self.RedirectBeams do               
                    LOUDINSERT(beams, AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, self.Army, v))
                end
                
            end
            
            if self.Enemy then
                -- Set collision to friends active so that when the missile reaches its source it can deal damage. 
			    self.EnemyProj.DamageData.CollideFriendly = true         
			    self.EnemyProj.DamageData.DamageFriendly = true 
			    self.EnemyProj.DamageData.DamageSelf = true 
			end
            
            if self.Enemy and not self.Enemy:BeenDestroyed() then
			
			    for _, v in self.LambdaEffects do
                    LOUDINSERT( self.LambdaEffectsBag, LOUDEMITONENTITY( self.EnemyProj, self.EnemyProj.Army, v ):ScaleEmitter(0.2) )
				end
                
				WaitTicks(self.RedirectRateOfFire)
                
                if not BeenDestroyed( self.EnemyProj ) then
                    self.EnemyProj:TrackTarget(false)
                end
                
            else	-- just destroy the projectile
				self.EnemyProj:Destroy()
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

SeraLambdaFieldDestroyer = Class(Entity) {

	LambdaEffects = BlackOpsEffectTemplate.EXLambdaDestoyer,
    
    OnCreate = function(self, spec)
        Entity.OnCreate(self, spec)
        
        self.Army = GetArmy(self)
        self.Owner = spec.Owner
        
        self.Radius = spec.Radius
        self.RedirectRateOfFire = spec.RedirectRateOfFire or 1

        SetCollisionShape( self, 'Sphere', 0, 0, 0, self.Radius)
        SetDrawScale( self, self.Radius )
        
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
		
        LOUDSTATE(self, self.WaitingState)
		
		--self.lambdaemitter = self
		self.LambdaEffectsBag = {}
    end,

    OnDestroy = function(self)
        Entity.OnDestroy(self)
        LOUDSTATE(self, self.DeadState)
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    -- Return true to process this collision, false to ignore it.
    WaitingState = State{
	
        OnCollisionCheck = function(self, other)

            if other.lastRedirector and other.lastRedirector == self.Army then
                return false
            end
        
            if LOUDENTITY(categories.PROJECTILE, other)
            and not LOUDENTITY(categories.STRATEGIC, other)
            and not LOUDENTITY(categories.ANTINAVY, other) 
            and other != self.EnemyProj and IsEnemy( self.Army, GetArmy(other) ) then
                
                self.Enemy = GetLauncher(other)
                self.EnemyProj = other
                
                if self.Enemy and (not other.lastRedirector or other.lastRedirector != self.Army) then
                
                    other.lastRedirector = self.Army
                    
					other:SetVelocity( 2 )
                    
                    other:SetNewTarget(self.Enemy)
                    
                    other:TrackTarget(true)
                    other:SetTurnRate(720)

					LOUDSTATE(self, self.RedirectingState)
				end
                
            end
            
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)
		
            if not self or self:BeenDestroyed()
            or not self.EnemyProj or BeenDestroyed(self.EnemyProj)
            or not self.Owner or self.Owner.Dead then
                return
            end

		    for _, v in self.LambdaEffects do
				LOUDINSERT( self.LambdaEffectsBag, CreateEmitterAtEntity( self.EnemyProj, self.Army, v ):ScaleEmitter(0.2) )
			end

			self.EnemyProj:Destroy()
            
            WaitTicks(self.RedirectRateOfFire)
            
            for _,v in self.LambdaEffectsBag do
                v:Destroy()
            end
			
            LOUDSTATE(self, self.WaitingState)
        end,

        OnCollisionCheck = function(self, other)
            return false
        end,
    },
}

TorpRedirectField = Class(Entity) {

    RedirectBeams = {'/mods/BlackOpsUnleashed/effects/emitters/Torp_beam_02_emit.bp'},
    EndPointEffects = {'/effects/emitters/particle_cannon_end_01_emit.bp',},

    OnCreate = function(self, spec)
	
        Entity.OnCreate(self, spec)
		
        self.Army = GetArmy(self)
        self.Owner = spec.Owner
        self.Radius = spec.Radius
        self.RedirectRateOfFire = spec.RedirectRateOfFire or 1
        
        SetCollisionShape( self, 'Sphere', 0, 0, 0, self.Radius)
        SetDrawScale( self, self.Radius )
        
        self.AttachBone = spec.AttachBone
        self:AttachTo(spec.Owner, spec.AttachBone)
		
        LOUDSTATE(self, self.WaitingState)
		
		self.LambdaEffectsBag = {}
		
    end,

    OnDestroy = function(self)
	
        Entity.OnDestroy(self)
		
        LOUDSTATE(self, self.DeadState)
		
    end,

    DeadState = State {
        Main = function(self)
        end,
    },

    -- Return true to process this collision, false to ignore it.
    WaitingState = State{
	
        OnCollisionCheck = function(self, other)

            if LOUDENTITY(categories.TORPEDO, other) and not LOUDENTITY(categories.STRATEGIC, other) 
                and other != self.EnemyProj and IsEnemy( self.Army, GetArmy(other) ) then

                self.Enemy = GetLauncher(other)
                self.EnemyProj = other
                self.EXFiring = false
                
                if self.Enemy and (not other.lastRedirector or other.lastRedirector != self.Army) then
                
                    other.lastRedirector = self.Army
                    
					local targetspeed = other:GetCurrentSpeed()
					other:SetVelocity(targetspeed * 3)
                    other:SetNewTarget(self.Enemy)
                    other:TrackTarget(true)
                    other:SetTurnRate(720)
					self.EXFiring = true
                end
                
				if self.EXFiring then
					LOUDSTATE(self, self.RedirectingState)
				end
                
            end
            
            return false
        end,
    },

    RedirectingState = State{

        Main = function(self)
		
            if not self or self:BeenDestroyed()
            or not self.EnemyProj or BeenDestroyed(self.EnemyProj)
            or not self.Owner or self.Owner.Dead then
                return
            end
            
            local beams = {}
            
            for _, v in self.RedirectBeams do               
                LOUDINSERT(beams, AttachBeamEntityToEntity(self.EnemyProj, -1, self.Owner, self.AttachBone, self.Army, v))
            end
            
            if self.Enemy then
                -- Set collision to friends active so that when the missile reaches its source it can deal damage. 
			    self.EnemyProj.DamageData.CollideFriendly = true         
			    self.EnemyProj.DamageData.DamageFriendly = true 
			    self.EnemyProj.DamageData.DamageSelf = true 
			end
            
            if self.Enemy and not self.Enemy:BeenDestroyed() then

				WaitTicks(self.RedirectRateOfFire)
                
                if not BeenDestroyed(self.EnemyProj) then
                    self.EnemyProj:TrackTarget(false)
                end
				
            else
			
				WaitTicks(self.RedirectRateOfFire)
				
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