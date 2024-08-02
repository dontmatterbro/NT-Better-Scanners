
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
        local readoutstringvital = ""
        local readoutstringremoved = ""
		
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

			--afflictions that don't make sense with % 
			function ScannerVital()
				if 
					value.Identifier=="cardiacarrest"
					or value.Identifier=="bloodpressure"
					or value.Identifier=="ll_arterialcut"
					or value.Identifier=="rl_arterialcut"
					or value.Identifier=="la_arterialcut"
					or value.Identifier=="ra_arterialcut"
					or value.Identifier=="t_arterialcut"
					or value.Identifier=="h_arterialcut"
					or value.Identifier=="tra_amputation"
					or value.Identifier=="tla_amputation"
					or value.Identifier=="trl_amputation"
					or value.Identifier=="tll_amputation"
					or value.Identifier=="th_amputation" --ouch
					or value.Identifier=="eyesdead"
					
					then return true
				end
			end

			--organ removal afflictions
			function ScannerRemoved()
				if 
					value.Identifier=="hearthremoved"
					or value.Identifier=="brainremoved"
					or value.Identifier=="lungremoved"
					or value.Identifier=="kidneyremoved"
					or value.Identifier=="liverremoved"
					or value.Identifier=="noeye"
					or value.Identifier=="sra_amputation"
					or value.Identifier=="sla_amputation"
					or value.Identifier=="srl_amputation"
					or value.Identifier=="sll_amputation"
					or value.Identifier=="sh_amputation"
					
					then return true
				end
			end

            if (strength >= prefab.ShowInHealthScannerThreshold and afflimbtype==limbtype) then
                -- add the affliction to the readout

				if (strength < 25) and not ScannerVital() and not ScannerRemoved() then 
                readoutstringlow = readoutstringlow.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if strength >= 25 and (strength < 65) and not ScannerVital() and not ScannerRemoved() then 
                readoutstringmid = readoutstringmid.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if strength >= 65 and not ScannerVital() and not ScannerRemoved() then 
                readoutstringhigh = readoutstringhigh.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
								
				if ScannerVital() then 
                readoutstringvital = readoutstringvital.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if ScannerRemoved() then 
                readoutstringremoved = readoutstringremoved.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
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
			.."‖color:100,200,100‖"..readoutstringlow.."‖color:end‖" 
			.."‖color:200,200,100‖"..readoutstringmid.."‖color:end‖"
			.."‖color:250,100,100‖"..readoutstringhigh.."‖color:end‖" 
			.."‖color:255,0,0‖"..readoutstringvital.."‖color:end‖" 
			.."‖color:0,255,255‖"..readoutstringremoved.."‖color:end‖" 
			
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
    local readoutstringpoison = ""
    local afflictionlist = targetCharacter.CharacterHealth.GetAllAfflictions()
    local afflictionsdisplayed = 0
    for value in afflictionlist do
        local strength = HF.Round(value.Strength)
        local prefab = value.Prefab

			--poisonings
			function AnalyzerPoison()
				if 
					value.Identifier=="morbusinepoisoning"
					or value.Identifier=="cyanidepoisoning"
					or value.Identifier=="sufforinpoisoning"

					
					then return true
				end
			end



        if (strength > 2 and HF.TableContains(NT.HematologyDetectable,prefab.Identifier.Value)) then
            -- add the affliction to the readout
				
				if (strength < 25) and not AnalyzerPoison() then 
                readoutstringlow = readoutstringlow.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if strength >= 25 and (strength < 65) and not AnalyzerPoison() then 
                readoutstringmid = readoutstringmid.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if strength >= 65 and not AnalyzerPoison() then 
                readoutstringhigh = readoutstringhigh.."\n"..value.Prefab.Name.Value..": "..strength.."%" end
				
				if AnalyzerPoison() then 
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
			.."‖color:100,200,100‖"..readoutstringlow.."‖color:end‖" 
			.."‖color:200,200,100‖"..readoutstringmid.."‖color:end‖"
			.."‖color:250,100,100‖"..readoutstringhigh.."‖color:end‖" 
			.."‖color:255,0,0‖"..readoutstringpoison.."‖color:end‖" 
			
				)
	
end