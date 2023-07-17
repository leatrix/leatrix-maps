
	----------------------------------------------------------------------
	-- Leatrix Maps Icons
	----------------------------------------------------------------------

	local void, Leatrix_Maps = ...
	local L = Leatrix_Maps.L

	Leatrix_Maps["Icons"] = {

		----------------------------------------------------------------------
		--	World Of Warcraft: Eastern Kingdoms
		----------------------------------------------------------------------

		[18] =  --[[Tirisfal Glades]] {
			{"PortalH", 61.9, 59.0, L["Stranglethorn Vale"], L["Portal"]},
			{"PortalH", 60.7, 58.7, L["Orgrimmar"], L["Portal"]},
			{"PortalH", 59.1, 58.9, L["Howling Fjord"], L["Portal"]},
			{"PortalH", 59.4, 67.4, L["Silvermoon City"], L["Orb of Translocation"]},
		},

		[50] =  --[[Northern Stranglethorn]] {
			{"PortalH", 37.6, 51.0, L["Undercity"], L["Portal"]},
		},

		[84] =  --[[Stormwind City]] {
			{"PortalA", 74.4, 18.4, L["Eastern Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Tol Barad"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"]},
		},

		[90] =  --[[Undercity]] {
			{"PortalH", 85.3, 17.1, L["Hellfire Peninsula"], L["Portal"]},
		},

		----------------------------------------------------------------------
		--	World Of Warcraft: Kalimdor
		----------------------------------------------------------------------

		[57] =  --[[Teldrassil]] {
			{"PortalA", 55.0, 93.7, L["Stormwind"], L["Portal"]},
			{"PortalA", 52.3, 89.5, L["Exodar"], L["Portal"]},
		},

		[74] = 	--[[Caverns of Time: The Spiral]] {
			{"PortalA", 59.0, 26.8, L["Stormwind"], L["Portal"]},
			{"PortalH", 58.2, 26.7, L["Orgrimmar"], L["Portal"]},
		},

		[81] =  --[[Silithus]] {
			{"PortalN", 43.2, 44.5, L["Chamber of Heart"], L["Titan Translocator"]},
			{"PortalA", 41.5, 44.9, L["Tiragarde Sound"], L["Portal"]},
			{"PortalH", 41.6, 45.2, L["Zuldazar"], L["Portal"]},
		},

		[85] =  --[[Orgrimmar: Main City]] {
			{"PortalH", 50.1, 37.8, L["Western Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"]},
			{"PortalH", 47.4, 39.3, L["Tol Barad"], L["Portal"]},
			{"PortalH", 43.0, 65.0, L["Zeppelin to"] .." " .. L["Thunder Bluff"] .. ", " .. L["Mulgore"], ""},
			{"PortalH", 50.7, 55.5, L["Undercity"], L["Portal"]},
		},

		[86] =  --[[Orgrimmar: The Cleft Of Shadow]] {
			{"PortalH", 50.1, 37.8, L["Western Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"]},
			{"PortalH", 47.4, 39.3, L["Tol Barad"], L["Portal"]},
			{"PortalH", 43.0, 65.0, L["Zeppelin to"] .." " .. L["Thunder Bluff"] .. ", " .. L["Mulgore"], ""},
			{"PortalH", 50.7, 55.5, L["Undercity"], L["Portal"]},
		},

		[88] =  --[[Thunder Bluff]] {
			{"PortalH", 14.6, 26.4, L["Zeppelin to"] .. " " .. L["Orgrimmar"] .. ", " .. L["Durotar"], ""},
		},

		[89] =  --[[Darnassus]] {
			{"PortalA", 44.1, 78.5, L["Temple of the Moon"], L["Exodar"] .. ", " .. L["Hellfire Peninsula"]},
		},

		[97] =  --[[Azuremyst Isle]] {
			{"PortalA", 20.4, 54.1, L["Darnassus"], L["Portal"]},
		},

		[247] =  --[[Ruins of Ahn'Qiraj]] {
			{"Chest", 59.3, 28.7, L["Scarab Coffer"], L["Chest"]},
			{"Chest", 60.8, 51.0, L["Scarab Coffer"], L["Chest"]},
			{"Chest", 73.0, 66.4, L["Scarab Coffer"], L["Chest"]},
			{"Chest", 57.4, 78.3, L["Scarab Coffer"], L["Chest"]},
			{"Chest", 54.8, 87.5, L["Scarab Coffer"], L["Chest"]},
			{"Chest", 41.0, 76.9, L["Scarab Coffer"], L["Chest"]},
			{"Chest", 34.0, 53.0, L["Scarab Coffer"], L["Chest"]},
			{"Chest", 41.1, 32.2, L["Scarab Coffer"], L["Chest"]},
			{"Chest", 41.6, 46.3, L["Scarab Coffer"], L["Chest"]},
			{"Chest", 46.7, 42.0, L["Scarab Coffer"], L["Chest"]},
		},

		[319] =  --[[Temple of Ahn'Qiraj]] {
			{"Chest", 33.1, 48.4, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 64.5, 25.5, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 58.4, 49.9, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 47.5, 54.7, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 56.2, 66.0, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 50.7, 78.1, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 51.4, 83.2, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 48.4, 85.4, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 48.0, 81.1, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 34.2, 83.5, L["Large Scarab Coffer"], L["Chest"]},
			{"Chest", 39.2, 68.4, L["Large Scarab Coffer"], L["Chest"]},
		},

		----------------------------------------------------------------------
		--	The Burning Crusade
		----------------------------------------------------------------------

		[100] =  --[[Hellfire Peninsula]] {
			{"PortalH", 88.6, 47.7, L["Orgrimmar"], L["Portal"]},
			{"PortalA", 88.6, 52.8, L["Stormwind"], L["Portal"]},
		},

		[103] =  --[[The Exodar]] {
			{"PortalA", 48.3, 62.9, L["Stormwind"], L["Portal"]},
		},

		[110] =  --[[Silvermoon City]] {
			{"PortalH", 58.5, 18.7, L["Orgrimmar"], L["Portal"]},
			{"PortalH", 49.5, 14.8, L["Undercity"], L["Orb of Translocation"]},
			{"PortalH", 58.5, 18.7, L["Orgrimmar"], L["Portal"]},
		},

		[111] =  --[[Shattrath City]] {
			{"PortalN", 48.5, 42.0, L["Isle of Quel'Danas"], L["Portal"]},
			{"PortalH", 56.8, 48.9, L["Orgrimmar"], L["Portal"]},
			{"PortalA", 57.2, 48.3, L["Stormwind"], L["Portal"]},
		},

		[245] =  --[[Tol Barad Peninsula]] {
			{"PortalH", 56.3, 79.7, L["Orgrimmar"], L["Portal"]},
			{"PortalA", 75.3, 58.8, L["Stormwind"], L["Portal"]},},

		----------------------------------------------------------------------
		--	Wrath Of The Lich King
		----------------------------------------------------------------------

		[114] =  --[[Borean Tundra]] {
			{"PortalN", 78.9, 53.7, L["Boat to"] .. " " .. L["Moa'ki Harbor"] .. ", " .. L["Dragonblight"]},
		},

		[115] =  --[[Dragonblight]] {
			{"PortalN", 49.6, 78.4, L["Boat to"] .. " " .. L["Kamagua"] .. ", " .. L["Howling Fjord"]},
			{"PortalN", 47.9, 78.7, L["Boat to"] .. " " .. L["Unu'pe"] .. ", " .. L["Borean Tundra"]},
		},

		[117] =  --[[Howling Fjord]] {
			{"PortalN", 23.5, 57.8, L["Boat to"] .. " " .. L["Moa'ki Harbor"] .. ", " .. L["Dragonblight"]},
		},

		[125] =  --[[Dalaran]] {
			{"PortalA", 40.1, 62.8, L["Stormwind"], L["Portal"]},
			{"PortalH", 55.3, 25.4, L["Orgrimmar"], L["Portal"]},
		},

		----------------------------------------------------------------------
		--	Cataclysm
		----------------------------------------------------------------------

		----------------------------------------------------------------------
		--	Mists of Pandaria
		----------------------------------------------------------------------

		[392] =  --[[Shrine of Two Moons]] {
			{"PortalH", 73.3, 42.8, L["Orgrimmar"], L["Portal"]},
		},

		[394] =  --[[Shrine of Seven Stars]] {
			{"PortalA", 71.6, 36.0, L["Stormwind"], L["Portal"]},
		},

		----------------------------------------------------------------------
		--	Warlords of Draenor
		----------------------------------------------------------------------

		[622] =  --[[Stormshield]] {
			{"PortalA", 60.8, 38.0, L["Stormwind"], L["Portal"]},
			{"PortalA", 36.4, 41.1, L["Lion's Watch"], L["Portal"], 0, 38445},
		},

		[624] =  --[[Warspear]] {
			{"PortalH", 60.6, 51.6, L["Orgrimmar"], L["Portal"]},
			{"PortalH", 53.0, 43.9, L["Vol'mar"], L["Portal"], 0, 37935},
		},

		----------------------------------------------------------------------
		--	Legion
		----------------------------------------------------------------------

		[627] =  --[[Dalaran]] {
			{"PortalA", 39.6, 63.2, L["Stormwind"], L["Portal"]},
			{"PortalH", 55.2, 23.9, L["Orgrimmar"], L["Portal"]},
		},

		[682] =  --[[Felsoul Hold]] {
			{"PortalN", 53.6, 36.8, L["Shal'Aran"], L["Portal"], 0, 41575,},
		},

		[684] =  --[[Shattered Locus]] {
			{"PortalN", 40.9, 13.7, L["Shal'Aran"], L["Portal"], 0, 42230,},
		},

		[680] =  --[[Suramar]] {
			{"PortalN", 21.6, 28.5, L["Falanaar"], L["Portal"], 0, 42230,},
			{"PortalN", 39.7, 76.2, L["Felsoul Hold"], L["Portal"], 0, 41575,},
			{"PortalN", 30.8, 11.0, L["Moon Guard Stronghold"], L["Portal"], 0, 43808,},
			{"PortalN", 43.7, 79.2, L["Lunastre Estate"], L["Portal"], 0, 43811,},
			{"PortalN", 36.1, 47.2, L["Ruins of Elune'eth"], L["Portal"], 0, 40956,},
			{"PortalN", 52.0, 78.8, L["Evermoon Terrace"], L["Portal"], 0, 42889,},
			{"PortalN", 43.4, 60.6, L["Sanctum of Order"], L["Portal"], 0, 43813,},
			{"PortalN", 42.0, 35.2, L["Tel'anor"], L["Portal"], 0, 43809,},
			{"PortalN", 64.0, 60.4, L["Twilight Vineyards"], L["Portal"], 0, 44084,},
			{"PortalN", 54.5, 69.4, L["Astravar Harbor"], L["Portal"], 0, 44740,},
			{"PortalN", 47.7, 81.4, L["The Waning Crescent"], L["Portal"], 0, 42487, 38649,},
		},

		[761] =  --[[Dungeon: Court of Stars]] {

			{"Arrow", 42.5, 76.8, L["Step 1"], L["Start here."], 5.5},
			{"Arrow", 42.4, 65.2, L["Step 2"], L["Enter this building and go upstairs."], 0.1},
			{"Arrow", 41.3, 53.0, L["Step 3"], L["Click the Arcane Beacon then go across the bridge to the left."], 0.7},
			{"Arrow", 36.2, 47.1, L["Step 4"], L["Kill the Construct then turn left before the bridge."], 1.1},
			{"Arrow", 32.0, 41.2, L["Step 5"], L["Go over this bridge."], 5.9},
			{"Arrow", 33.5, 30.8, L["Step 6"], L["Pull Patrol Captain Gerdo here and kill."], 6.1},
			{"Arrow", 38.5, 24.5, L["Step 7"], L["Go up these steps."], 4.5},
			{"Arrow", 42.6, 26.7, L["Step 8"], L["Enter this building and go up the stairs."], 4.5},
			{"Arrow", 46.4, 34.9, L["Step 9"], L["Enter this building and go down the stairs."], 2.7},
			{"Arrow", 48.4, 39.7, L["Step 10"], L["Look at the map.  Find and kill 3 Enforcers (yellow dots).|nAfter each Enforcer, wait and kill the Covenant.|n|nThen kill Talixae Flamewreath."], 5.9},
			{"Arrow", 60.4, 61.6, L["Step 11"], L["After killing Talixae, talk to Ly'leth Lunastre to get a disguise."], 4.0},
			{"Arrow", 64.0, 67.0, L["Step 12"], L["Enter this building and talk to Chatty Rumormongers to get a description of the spy."], 4.0},
		},

		[763] =  --[[Dungeon: Court of Stars (The Balconies)]] {
			{"Arrow", 27.1, 77.8, L["Step 13 (1)"], L["Once identified, kill the spy either here or at the opposite side.|nThen pick up the Arcane Keys."], 2.3},
			{"Arrow", 66.7, 18.7, L["Step 13 (2)"], L["Once identified, kill the spy either here or at the opposite side.|nThen pick up the Arcane Keys."], 5.5},
			{"Arrow", 60.0, 69.3, L["Step 14"], L["Unlock the Skyward Terrace doors using the Arcane Keys.|nKill Advisor Melandrus."], 4.0},
		},

		----------------------------------------------------------------------
		--	Battle For Azeroth
		----------------------------------------------------------------------

		[1161] =  --[[Boralus Harbor]] {
			{"PortalA", 70.4, 17.7, L["Sanctum of the Sages"], L["Exodar"] .. ", " .. L["Ironforge"] .. ", " .. L["Nazjatar"] .. ", " .. L["Silithus"] .. ", " .. L["Stormwind"]},
		},

		[1163] =  --[[Dazar'alor (inside)]] {
			{"PortalH", 60.5, 70.3, L["Hall of Ancient Paths"], L["Nazjatar"] .. ", " .. L["Orgrimmar"] .. ", " .. L["Silithus"] .. ", " .. L["Silvermoon City"] .. ", " .. L["Thunder Bluff"]},
		},

		[1473] =  --[[Chamber of Heart]] {
			{"PortalN", 50.1, 30.4, L["Silithus"], L["Titan Translocator"]},
		},

		----------------------------------------------------------------------
		--	Shadowlands
		----------------------------------------------------------------------

		[1670] =  --[[Oribos]] {
			{"PortalH", 20.9, 54.8, L["Orgrimmar"], L["Portal"]},
			{"PortalA", 20.9, 45.9, L["Stormwind"], L["Portal"]},
		},

		[1961] =  --[[Korthia]] {
			{"PortalN", 64.5, 24.1, L["Oribos"], L["Portal"]},
			{"TaxiN", 49.3, 63.9, L["Flayedwing Transporter"], L["Taxi to Scholar's Den"]},
			{"TaxiN", 60.8, 28.5, L["Flayedwing Transporter"], L["Taxi to Vault of Secrets"]},
		},

		[1970] =  --[[Zereth Mortis]] {
			{"TaxiN", 34.9, 45.7, L["Exile's Hollow"], L["Sanctuary"]},
			{"TaxiN", 61.9, 58.9, L["Synthesis Forge"], L["Pet Crafting"]},
			{"TaxiN", 68.5, 30.2, L["Protoform Repository"], L["Mount Crafting"]},
		},

		----------------------------------------------------------------------
		--	Dragonflight
		----------------------------------------------------------------------

		[2112] =  --[[Valdrakken]] {
			{"PortalN", 53.9, 55.0, L["Valdrakken Portals"]},
			{"PortalH", 56.6, 38.4, L["Orgrimmar"], L["Portal"]},
			{"PortalA", 59.7, 41.8, L["Stormwind"], L["Portal"]},
		},

	}

	local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", function()

		-- Add Caverns of Time portal to Shattrath if reputation with Keepers of Time is revered or higher
		local name, description, standingID = GetFactionInfoByID(989)
		if standingID and standingID >= 7 then
			Leatrix_Maps["Icons"][111] = Leatrix_Maps["Icons"][111] or {}; tinsert(Leatrix_Maps["Icons"][111],
				{"PortalN", 74.7, 31.4, L["Caverns of Time"], L["Portal from Zephyr"]}
			)
		end

	end)
