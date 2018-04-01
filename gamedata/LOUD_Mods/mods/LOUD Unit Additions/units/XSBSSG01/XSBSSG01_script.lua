local SShieldStructureUnit = import('/lua/seraphimunits.lua').SShieldStructureUnit

local Entity = import('/lua/sim/Entity.lua').Entity
local EffectTemplate = import('/lua/EffectTemplates.lua')
local Util = import('/lua/utilities.lua')

XSBSSG01 = Class(SShieldStructureUnit) {
    ShieldEffects1 = {
        '/effects/emitters/seraphim_shield_generator_t2_01_emit.bp',
    },
    ShieldEffects2 = {
        '/effects/emitters/seraphim_shield_generator_t2_03_emit.bp',
        '/effects/emitters/seraphim_shield_generator_t3_03_emit.bp',
    },
	OnStopBeingBuilt = function(self,builder,layer)
		SShieldStructureUnit.OnStopBeingBuilt(self,builder,layer)
		self.ShieldEffectsBag = {}
		
		local OldCreateShieldMesh = self.MyShield.CreateShieldMesh
		self.MyShield.CreateShieldMesh = function(self)
			OldCreateShieldMesh(self)
			self:SetCollisionShape( 'Box', 0,0,0,self.Size/2,self.Size/2,self.Size/2)
	    end
		local OldCreateImpactEffect = self.MyShield.CreateImpactEffect
	    self.MyShield.CreateImpactEffect = function(self, vector)
	        local army = self:GetArmy()
			local ImpactMesh = Entity { Owner = self.Owner }
			Warp( ImpactMesh, Vector(self:GetPosition().x-vector.x,self:GetPosition().y-vector.y,self:GetPosition().z-vector.z))
			
			if self.ImpactMeshBp != '' then
				ImpactMesh:SetMesh(self.ImpactMeshBp)
				ImpactMesh:SetDrawScale(self.Size)
				if math.floor(vector.x+0.5) == self.Size/2 then
					ImpactMesh:SetOrientation(OrientFromDir(Vector(-1,0,0)),true)
				elseif math.floor(vector.x+0.5) == -self.Size/2 then
					ImpactMesh:SetOrientation(OrientFromDir(Vector(1,0,0)),true)
				elseif math.floor(vector.y+0.5) == self.Size/2 then
					ImpactMesh:SetOrientation(OrientFromDir(Vector(0,-1,0)),true)
				elseif math.floor(vector.y+0.5) == -self.Size/2 then
					ImpactMesh:SetOrientation(OrientFromDir(Vector(0,1,0)),true)
				elseif math.floor(vector.z+0.5) == self.Size/2 then
					ImpactMesh:SetOrientation(OrientFromDir(Vector(0,0,-1)),true)
				elseif math.floor(vector.z+0.5) == -self.Size/2 then
					ImpactMesh:SetOrientation(OrientFromDir(Vector(0,0,1)),true)
				else
					-- wasn't a projectile, going for beams now
					
					local xscale = self.Size/2 / math.abs(vector.x)
					local yscale = self.Size/2 / math.abs(vector.y)
					local zscale = self.Size/2 / math.abs(vector.z)
					local vectorscale = math.min(xscale, yscale, zscale)
					local vector = Vector(vector.x*vectorscale, vector.y*vectorscale, vector.z*vectorscale)
					
					local vecmax = math.max(math.abs(vector.x), math.abs(vector.y), math.abs(vector.z))
					if vecmax == math.abs(vector.x) then
						-- it's coming from x
						if vector.x > 0 then
							ImpactMesh:SetOrientation(OrientFromDir(Vector(-1,0,0)),true)
						else
							ImpactMesh:SetOrientation(OrientFromDir(Vector(1,0,0)),true)
						end
					elseif vecmax == math.abs(vector.y) then
						-- y
						if vector.y > 0 then
							ImpactMesh:SetOrientation(OrientFromDir(Vector(0,-1,0)),true)
						else
							ImpactMesh:SetOrientation(OrientFromDir(Vector(0,1,0)),true)
						end
					elseif vecmax == math.abs(vector.z) then
						-- z
						if vector.z > 0 then
							ImpactMesh:SetOrientation(OrientFromDir(Vector(0,0,-1)),true)
						else
							ImpactMesh:SetOrientation(OrientFromDir(Vector(0,0,1)),true)
						end
					end
					
					Warp( ImpactMesh, Vector(
						self:GetPosition().x - vector.x,
						self:GetPosition().y - vector.y,
						self:GetPosition().z - vector.z
						))
				end
				
					
					
			end
	
			for k, v in self.ImpactEffects do
				CreateEmitterAtBone( ImpactMesh, -1, army, v )--:OffsetEmitter(0,0,OffsetLength)
			end
	
			WaitSeconds(5)
			ImpactMesh:Destroy()
	    end
    end,
    
	OnShieldDisabled = function(self)
		SShieldStructureUnit.OnShieldDisabled(self)
		
		if self.ShieldEffectsBag then
			for k, v in self.ShieldEffectsBag do
				v:Destroy()
			end
			self.ShieldEffectsBag = {}
		end
	end,
	
	OnShieldEnabled = function(self)
		SShieldStructureUnit.OnShieldEnabled(self)
		
		if self.ShieldEffectsBag then
			for k, v in self.ShieldEffectsBag do
				v:Destroy()
			end
			self.ShieldEffectsBag = {}
		end
		for k, v in self.ShieldEffects1 do
			local ThisEmitter = CreateAttachedEmitter( self, 0, self:GetArmy(), v ):OffsetEmitter(0,-0.55,0.55):ScaleEmitter(0.75*0.25)
			table.insert( self.ShieldEffectsBag, ThisEmitter  )
		end
		for k, v in self.ShieldEffects2 do
			local ThisEmitter = CreateAttachedEmitter( self, 0, self:GetArmy(), v ):OffsetEmitter(0,0.0,0.1):ScaleEmitter(0.75*0.25)
			table.insert( self.ShieldEffectsBag, ThisEmitter  )
		end
	end,
}

TypeClass = XSBSSG01