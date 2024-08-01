NT.ItemMethods.healthscanner = function(item, usingCharacter, targetCharacter, limb) 
    local limbtype = HF.NormalizeLimbType(limb.type)

    local containedItem = item.OwnInventory.GetItemAt(0)
    if containedItem==nil then return end
    local hasVoltage = containedItem.Condition > 0

    if hasVoltage then 
        HF.GiveItem(targetCharacter,"ntsfx_selfscan")
        containedItem.Condition = containedItem.Condition-5
        HF.AddAffliction(targetCharacter,"radiationsickness",1,usingCharacter)

        -- print readout of afflictions
        local readoutstringstart = "Affliction readout for "..targetCharacter.Name.." on limb "..HF.LimbTypeToString(limbtype)..":\n"
        local readoutstringlow = ""
        local readoutstringmid = ""
        local readoutstringhigh = ""
        local afflictionlist = targetCharacter.CharacterHealth.GetAllAfflictions()
        local afflictionsdisplayed = 0
        for value in afflictionlist do
            local strength = HF.Round(value.Strength)
            local prefab = value.Prefab
            local limb = targetCharacter.CharacterHealth.GetAfflictionLimb(value)
            local afflimbtype = LimbType.Torso
            
            if(not prefab.LimbSpecific) then afflimbtype = prefab.IndicatorLimb 
            elseif(limb~=nil) then afflimbtype=limb.type end
            
            afflimbtype = HF.NormalizeLimbType(afflimbtype)

            if (strength >= prefab.ShowInHealthScannerThreshold and afflimbtype==limbtype) then
                -- add the affliction to the readout
				
				if (strength < 25) then 
                readoutstringlow = readoutstringlow.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if strength >= 25 and (strength < 65) then 
                readoutstringmid = readoutstringmid.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if strength >= 65 then 
                readoutstringhigh = readoutstringhigh.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
								
				afflictionsdisplayed = afflictionsdisplayed + 1
            end
        end

        -- add a message in case there is nothing to display
        if afflictionsdisplayed <= 0 then
            readoutstringlow = readoutstringlow.."\nNo afflictions! Good work!" 
        end

        Timer.Wait(function()
            HF.DMClient(
			
			HF.CharacterToClient(usingCharacter),
			  "‖color:100,100,200‖"..readoutstringstart.."‖color:end‖"
			.."‖color:50,255,0‖"..readoutstringlow.."‖color:end‖" 
			.."‖color:255,255,0‖"..readoutstringmid.."‖color:end‖"
			.."‖color:255,0,0‖"..readoutstringhigh.."‖color:end‖" 
			
					)
        end, 2000)
    end
end




NT.ItemMethods.bloodanalyzer = function(item, usingCharacter, targetCharacter, limb) 
    
    -- only work if no cooldown
    if item.Condition < 50 then return end
    
    local limbtype = limb.type

    local success = HF.GetSkillRequirementMet(usingCharacter,"medical",30)
    local bloodlossinduced = 1
    if(not success) then bloodlossinduced = 3 end
    HF.AddAffliction(targetCharacter,"bloodloss",bloodlossinduced,usingCharacter)

    -- spawn donor card
    local containedItem = item.OwnInventory.GetItemAt(0)
    local hasCartridge = containedItem ~= nil
    if hasCartridge then 
        HF.RemoveItem(containedItem)
        local bloodtype = NT.GetBloodtype(targetCharacter)
        local targetIDCard = targetCharacter.Inventory.GetItemAt(0)
        if targetIDCard ~= nil and targetIDCard.OwnInventory.GetItemAt(0) == nil then
            -- put the donor card into the id card
            HF.PutItemInsideItem(targetIDCard,bloodtype.."card")
        else
            -- put it in the analyzer instead
            HF.PutItemInsideItem(item,bloodtype.."card")
        end
    end

    -- print readout of afflictions
    local bloodtype = AfflictionPrefab.Prefabs[NT.GetBloodtype(targetCharacter)].Name.Value
	local readoutstringstart = "Affliction readout for the blood of "..targetCharacter.Name..":\n"
    local readoutstringbloodtype = "\nBloodtype: "..bloodtype
    local readoutstringpressure = ""
    local readoutstringlow = ""
    local readoutstringmid = ""
    local readoutstringhigh = ""
    local afflictionlist = targetCharacter.CharacterHealth.GetAllAfflictions()
    local afflictionsdisplayed = 0
    for value in afflictionlist do
        local strength = HF.Round(value.Strength)
        local prefab = value.Prefab

        if (strength > 2 and HF.TableContains(NT.HematologyDetectable,prefab.Identifier.Value)) then
            -- add the affliction to the readout
				
				if (strength < 25) then 
                readoutstringlow = readoutstringlow.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if strength >= 25 and (strength < 65) then 
                readoutstringmid = readoutstringmid.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if strength >= 65 then 
                readoutstringhigh = readoutstringhigh.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
            afflictionsdisplayed = afflictionsdisplayed + 1
        end
    end

    -- add a message in case there is nothing to display
    if afflictionsdisplayed <= 0 then
        readoutstringpressure = readoutstringpressure.."\nNo blood pressure detected..." 
    end

    HF.DMClient(
			
			HF.CharacterToClient(usingCharacter),
			  "‖color:100,100,200‖"..readoutstringstart.."‖color:end‖"
			.."‖color:255,255,255‖"..readoutstringbloodtype.."‖color:end‖"
			.."‖color:100,100,120‖"..readoutstringpressure.."‖color:end‖"
			.."‖color:50,255,0‖"..readoutstringlow.."‖color:end‖" 
			.."‖color:255,255,0‖"..readoutstringmid.."‖color:end‖"
			.."‖color:255,0,0‖"..readoutstringhigh.."‖color:end‖" 
			
				)
	
end