local AShieldHoverLandUnit = import('/lua/aeonunits.lua').AShieldHoverLandUnit

local AAMSaintWeapon = import('/lua/aeonweapons.lua').AAMSaintWeapon
local nukeFiredOnGotTarget = false

UALX401 = Class(AShieldHoverLandUnit) {

	Weapons = {
        --AntiMissile01 = Class(SAMElectrumMissileDefense) {},
        --AntiMissile02 = Class(SAMElectrumMissileDefense) {},
        --AntiMissile03 = Class(SAMElectrumMissileDefense) {},
        --AntiMissile04 = Class(SAMElectrumMissileDefense) {},
		
        MissileRack = Class(AAMSaintWeapon) {
            IdleState = State(AAMSaintWeapon.IdleState) {
                OnGotTarget = function(self)
                    local bp = self:GetBlueprint()
                    #only say we've fired if the parent fire conditions are met
                    if (bp.CountedProjectile == false) or self:CanFire() then
                         nukeFiredOnGotTarget = true
                    end
                    AAMSaintWeapon.IdleState.OnGotTarget(self)
                end,
                # uses OnGotTarget, so we shouldn't do this.
                OnFire = function(self)
                    if not nukeFiredOnGotTarget then
                        AAMSaintWeapon.IdleState.OnFire(self)
                    end
                    nukeFiredOnGotTarget = false
                    
                    self:ForkThread(function()
                        self.unit:SetBusy(true)
                        WaitSeconds(1/self.unit:GetBlueprint().Weapon[1].RateOfFire + .2)
                        self.unit:SetBusy(false)
                    end)
                end,
            },
        },
    },
    
    ShieldEffects = {
        '/effects/emitters/aeon_shield_generator_t2_01_emit.bp',
		'/effects/emitters/aeon_shield_generator_mobile_01_emit.bp',
        '/effects/emitters/aeon_shield_generator_t3_04_emit.bp',
    },
    
    OnStopBeingBuilt = function(self,builder,layer)
        AShieldHoverLandUnit.OnStopBeingBuilt(self,builder,layer)
		self.ShieldEffectsBag = {}
        self.Trash:Add(CreateRotator(self, 'Spinner01', 'y', nil, 0, 24, 120))
        self.Trash:Add(CreateRotator(self, 'Spinner02', 'y', nil, 0, -64, -160))
        self.Trash:Add(CreateRotator(self, 'Spinner03', 'y', nil, 0, 12, 230))
        self.Trash:Add(CreateRotator(self, 'Spinner04', 'y', nil, 0, -33, -280))
        self.Trash:Add(CreateRotator(self, 'Spinner05', 'y', nil, 0, 44, 450))
        self.Trash:Add(CreateRotator(self, 'Spinner06', 'y', nil, 0, -59, -310))
        self.Trash:Add(CreateRotator(self, 'Spinner07', 'y', nil, 0, 17, 140))
        self.Trash:Add(CreateRotator(self, 'Spinner08', 'y', nil, 0, -51, -360))
        self.Trash:Add(CreateRotator(self, 'Spinner09', 'y', nil, 0, 41, 210))
        self.Trash:Add(CreateRotator(self, 'Spinner10', 'y', nil, 0, -32, -250))
        self.Trash:Add(CreateRotator(self, 'Spinner11', 'y', nil, 0, 57, 160))
        self.Trash:Add(CreateRotator(self, 'Spinner12', 'y', nil, 0, -23, -180))
        self.Trash:Add(CreateRotator(self, 'Spinner13', 'y', nil, 0, 32, 300))
        self.Trash:Add(CreateRotator(self, 'Spinner14', 'y', nil, 0, -76, -360))
        self.Trash:Add(CreateRotator(self, 'Spinner15', 'y', nil, 0, 12, 440))
        self.Trash:Add(CreateRotator(self, 'Spinner16', 'y', nil, 0, -15, -500))
    end,
    
    OnShieldEnabled = function(self)
        AShieldHoverLandUnit.OnShieldEnabled(self)
        if not self.Animator then
            self.Animator = CreateAnimator(self)
            self.Trash:Add(self.Animator)
            self.Animator:PlayAnim(self:GetBlueprint().Display.AnimationOpen)
        end
        self.Animator:SetRate(1)
                
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
        for k, v in self.ShieldEffects do
            table.insert( self.ShieldEffectsBag, CreateAttachedEmitter( self, 0, self:GetArmy(), v ) )
        end
    end,

    OnShieldDisabled = function(self)
        AShieldHoverLandUnit.OnShieldDisabled(self)
        if self.Animator then
            self.Animator:SetRate(-1)
        end
         
        if self.ShieldEffectsBag then
            for k, v in self.ShieldEffectsBag do
                v:Destroy()
            end
		    self.ShieldEffectsBag = {}
		end
    end,


}

TypeClass = UALX401
