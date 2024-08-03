--spaghetti code awaits, I might optimise this further, but for now this should suffice
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
		
        local readoutstringstart = "‖color:100,100,200‖".."Affliction readout for ".."‖color:end‖".."‖color:125,125,225‖"..targetCharacter.Name.."‖color:end‖".."‖color:100,100,200‖".." on limb "..HF.LimbTypeToString(limbtype)..":\n".."‖color:end‖"
        local readoutstringplow = ""
        local readoutstringphigh = ""
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

			--vital afflictions
			ScannerVital = {

				"cardiacarrest",
				"ll_arterialcut",
				"rl_arterialcut",
				"la_arterialcut",
				"ra_arterialcut",
				"t_arterialcut",
				"h_arterialcut",
				"tra_amputation",
				"tla_amputation",
				"trl_amputation",
				"tll_amputation",
				"th_amputation", --ouch
				"eyesdead"
				
			}

			--organ removals
			ScannerRemoved = {
			
				"heartremoved",
				"brainremoved",
				"lungremoved",
				"kidneyremoved",
				"liverremoved",
				"noeye",
				"sra_amputation",
				"sla_amputation",
				"srl_amputation",
				"sll_amputation",
				"sh_amputation"

			}
			
			--blood pressure
			ScannerPressure = {
			
				"bloodpressure"
			
			}
		
            if (strength >= prefab.ShowInHealthScannerThreshold and afflimbtype==limbtype) then
                -- add the affliction to the readout


				if --low
					(strength < 25) 
					and not HF.TableContains(ScannerVital, value.Identifier) 
					and not HF.TableContains(ScannerRemoved, value.Identifier) 
					and not HF.TableContains(ScannerPressure, value.Identifier) 
				then
					readoutstringlow = readoutstringlow.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				
				if --mid
					strength >= 25 and (strength < 65) 
					and not HF.TableContains(ScannerVital, value.Identifier) 
					and not HF.TableContains(ScannerRemoved, value.Identifier) 
					and not HF.TableContains(ScannerPressure, value.Identifier) 
				then
					readoutstringmid = readoutstringmid.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				
				if --high
					strength >= 65 
					and not HF.TableContains(ScannerVital, value.Identifier) 
					and not HF.TableContains(ScannerRemoved, value.Identifier) 
					and not HF.TableContains(ScannerPressure, value.Identifier) 
				then 
					readoutstringhigh = readoutstringhigh.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
						
						
				if --vital
					HF.TableContains(ScannerVital, value.Identifier) 
				then 
					readoutstringvital = readoutstringvital.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				if 
					HF.TableContains(ScannerRemoved, value.Identifier) 
				then
					readoutstringremoved = readoutstringremoved.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				
				if --pressure
					HF.TableContains(ScannerPressure, value.Identifier) 
					and ((strength > 130) or (strength < 70)) 
				then 
					readoutstringphigh = readoutstringphigh.."\n"..value.Prefab.Name.Value..": "..strength.."%"
				
				elseif 
					HF.TableContains(ScannerPressure, value.Identifier) 
				then
					readoutstringplow = readoutstringplow.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
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
			  readoutstringstart --color values defined up there
			.."‖color:120,200,120‖"..readoutstringplow.."‖color:end‖"
			.."‖color:255,100,100‖"..readoutstringphigh.."‖color:end‖"
			.."‖color:100,200,100‖"..readoutstringlow.."‖color:end‖" 
			.."‖color:200,200,100‖"..readoutstringmid.."‖color:end‖"
			.."‖color:250,100,100‖"..readoutstringhigh.."‖color:end‖" 
			.."‖color:255,0,0‖"..readoutstringvital.."‖color:end‖" 
			.."‖color:0,255,255‖"..readoutstringremoved.."‖color:end‖" 
			
					)
        end, 2000)
    end
end



--this will probably get reworked depending on feedback
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
	local readoutstringstart = "‖color:100,100,200‖".."Affliction readout for the blood of ".."‖color:end‖".."‖color:125,125,225‖"..targetCharacter.Name..":\n".."‖color:end‖"
    local readoutstringbloodtype = "\nBloodtype: "..bloodtype
    local readoutstringplow = ""
    local readoutstringphigh = ""
    local readoutstringlow = ""
    local readoutstringmid = ""
    local readoutstringhigh = ""
    local readoutstringpoison = ""
	
    local afflictionlist = targetCharacter.CharacterHealth.GetAllAfflictions()
    local afflictionsdisplayed = 0
	
    for value in afflictionlist do
	
        local strength = HF.Round(value.Strength)
        local prefab = value.Prefab

		--poison afflictions
		AnalyzerPoison = {
		
			"morbusinepoisoning",
			"cyanidepoisoning",
			"sufforinpoisoning"
		
		} 

		--blood pressure 
		AnalyzerPressure = {
		
			"bloodpressure"
			
		}


        if (strength > 2 and HF.TableContains(NT.HematologyDetectable,prefab.Identifier.Value)) then
            -- add the affliction to the readout
				
				if --low
					(strength < 25) 
					and not HF.TableContains(AnalyzerPoison, value.Identifier)
					and not HF.TableContains(AnalyzerPressure, value.Identifier) 
				then 
					readoutstringlow = readoutstringlow.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				if --mid
					((strength >= 25) and (strength < 65))
					and not HF.TableContains(AnalyzerPoison, value.Identifier)
					and not HF.TableContains(AnalyzerPressure, value.Identifier)
				then 
					readoutstringmid = readoutstringmid.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				if --high
					(strength >= 65)
					and not HF.TableContains(AnalyzerPoison, value.Identifier) 
					and not HF.TableContains(AnalyzerPressure, value.Identifier)
				then 
					readoutstringhigh = readoutstringhigh.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				if --poison
					HF.TableContains(AnalyzerPoison, value.Identifier)
				then 
					readoutstringpoison = readoutstringpoison.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end
				
				if --pressure
					HF.TableContains(AnalyzerPressure, value.Identifier) 
					and ((strength > 130) or (strength < 70)) 
				then 
					readoutstringphigh = readoutstringphigh.."\n"..value.Prefab.Name.Value..": "..strength.."%"
				
				elseif 
					HF.TableContains(AnalyzerPressure, value.Identifier)
				then
					readoutstringplow = readoutstringplow.."\n"..value.Prefab.Name.Value..": "..strength.."%" 
				end

				afflictionsdisplayed = afflictionsdisplayed + 1
			
        end
    end

    -- add a message in case there is nothing to display
    if afflictionsdisplayed <= 0 then
        readoutstringphigh = readoutstringphigh.."\nNo blood pressure detected..." 
    end

    HF.DMClient(
			
			HF.CharacterToClient(usingCharacter),
			  readoutstringstart --values defined up there
			.."‖color:255,255,255‖"..readoutstringbloodtype.."‖color:end‖"
			.."‖color:120,200,120‖"..readoutstringplow.."‖color:end‖"
			.."‖color:255,100,100‖"..readoutstringphigh.."‖color:end‖"
			.."‖color:100,200,100‖"..readoutstringlow.."‖color:end‖" 
			.."‖color:200,200,100‖"..readoutstringmid.."‖color:end‖"
			.."‖color:250,100,100‖"..readoutstringhigh.."‖color:end‖" 
			.."‖color:255,0,0‖"..readoutstringpoison.."‖color:end‖" 
			
				)
	
end