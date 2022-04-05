local AStructureUnit = import('/lua/defaultunits.lua').StructureUnit

local AIFParagonDeathWeapon = import('/lua/aeonweapons.lua').AIFParagonDeathWeapon

SEB1401 = Class(AStructureUnit) {

    Weapons = {
        DeathWeapon = Class(AIFParagonDeathWeapon) {},
    },
	
	-- prevent construction of a Paragon within 164 of an existing paragon owned by self or 100 owned by ally
	OnStartBeingBuilt = function(self, builder, layer)
	
		local GetUnitsAroundPoint = moho.aibrain_methods.GetUnitsAroundPoint
		local GetListOfUnits = moho.aibrain_methods.GetListOfUnits
		local aiBrain = self:GetAIBrain()
		
		-- all allied paragons within 120 radius --
		local paragons = GetUnitsAroundPoint( aiBrain, categories.xab1401 + categories.seb1401 + categories.srb1401 + categories.ssb1401, self:GetPosition(), 120, 'Ally')
		
		-- your own paragons (all of them) --
		local MyParagons = GetListOfUnits( aiBrain, categories.xab1401 + categories.seb1401 + categories.srb1401 + categories.ssb1401, true )
		
		local ParagonTooClose = false
		
		local MyPosition = self:GetPosition()

		if table.getn(paragons) > 1 then
		
			ParagonTooClose = true
			
		end

		-- check your own paragons now --
		if table.getn(MyParagons) > 0 then
		
			for key, paragon in MyParagons do
			
				if VDist3( MyPosition, paragon:GetPosition() ) < 168 then
					ParagonTooClose = true
					break	-- you have a paragon too close so you don’t need to check any others
				end
				
			end
		end

		-- if ok to build
		if ParagonTooClose == false then
		
			AStructureUnit.OnStartBeingBuilt(self, builder, layer)
			
		else
		
			ForkThread(FloatingEntityText, builder.Sync.id, 'Cannot be built this close to an existing Paragon')
			
			self:Destroy()
			
			AStructureUnit.OnFailedToBuild(builder)
		end
		
	end,
	
    OnStopBeingBuilt = function(self, builder, layer)
	
        AStructureUnit.OnStopBeingBuilt(self, builder, layer)

		self.Tesseract = CreateAnimator(self)
        self.Tesseract:PlayAnim(string.gsub(self:GetBlueprint().Source,'unit.bp','')..'ATesseract.sca', true):SetRate(1+math.random()*0.5)

        local army = self:GetArmy()
        for i = 1, 4 do
            for j, k in {{'A','B'},{'B','C'},{'C','D'},{'D','A'}} do
                if not self.BeamEffectsBag then self.BeamEffectsBag = {} end
                table.insert(self.BeamEffectsBag, AttachBeamEntityToEntity(self, 'Tesseract_'..k[1]..'_00'..i, self, 'Tesseract_'..k[1]..'_00'..(math.mod(i, 4) + 1), army, '/effects/emitters/build_beam_01_emit.bp'))
                table.insert(self.BeamEffectsBag, AttachBeamEntityToEntity(self, 'Tesseract_'..k[1]..'_00'..i, self, 'Tesseract_'..k[2]..'_00'..i, army, '/effects/emitters/build_beam_01_emit.bp'))
            end
        end

        self.Trash:Add(CreateRotator(self, 'Tesseract', 'x', nil, 0, 15, 40 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Tesseract', 'y', nil, 0, 15, 40 + Random(0, 20)))
        self.Trash:Add(CreateRotator(self, 'Tesseract', 'z', nil, 0, 15, 40 + Random(0, 20)))

    end,

}

TypeClass = SEB1401
