NTSCAN = {} -- Neurotrauma Better Scanner
NTSCAN.Name="Better Scanner"
NTSCAN.Version = "A1.0.1h4"
NTSCAN.VersionNum = 01000104
NTSCAN.MinNTVersion = "A1.9.4h1"
NTSCAN.MinNTVersionNum = 01090401
NTSCAN.Path = table.pack(...)[1]
Timer.Wait(function() if NTC ~= nil then NTC.RegisterExpansion(NTSCAN) end end,1)

if 
	NT.VersionNum >= 01110000 
then 
	print("NT Better Scanner has been integrated into base Neurotrauma and has been disabled to prevent conflicts.")
return end

Timer.Wait(function()
	if (SERVER or (CLIENT and not Game.IsMultiplayer)) and (NTC==nil) then --checks if NT is installed
		print("Error loading NT Better Scanner: It seems Neurotrauma isn't loaded!")
		return
	end
	
		--server side scripts
	if SERVER or (CLIENT and not Game.IsMultiplayer) then
		dofile(NTSCAN.Path.."/Lua/Scripts/Server/healthscanner.lua")
	end
	
end,1)