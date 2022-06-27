
	----------------------------------------------------------------------
	-- Leatrix Maps Icons
	----------------------------------------------------------------------

	local void, Leatrix_Maps = ...
	local L = Leatrix_Maps.L

	Leatrix_Maps["Icons"] = {

		-- pos for code then showinst on Encounter Journal for dungeon ID.

		----------------------------------------------------------------------
		--	World Of Warcraft: Eastern Kingdoms
		----------------------------------------------------------------------

		[27] =  --[[Dun Morogh]] {
			{"Dungeon", 31.1, 37.9, L["Gnomeregan"], L["Dungeon"], 231},
		},

		[15] =  --[[Badlands]] {
			{"Dungeon", 41.7, 11.6, L["Uldaman"], L["Dungeon"], 239},
		},

		[16] =  --[[Uldaman]] {
			{"Dungeon", 36.7, 29.4, L["Uldaman"], L["Dungeon"], 239},
		},

		[18] =  --[[Tirisfal Glades]] {
			{"Dungeon", 82.5, 33.3, L["Scarlet Halls"] .. ", " .. L["Scarlet Monastery"], L["Dungeon"], 316},
			{"PortalH", 61.9, 59.0, L["Stranglethorn Vale"], L["Portal"]},
			{"PortalH", 60.7, 58.7, L["Orgrimmar"], L["Portal"]},
			{"PortalH", 59.1, 58.9, L["Howling Fjord"], L["Portal"]},
			{"PortalH", 59.4, 67.4, L["Silvermoon City"], L["Orb of Translocation"]},
		},

		[19] =  --[[Scarlet Monastery]] {
			{"Dungeon", 69.2, 24.4, L["Scarlet Monastery"], L["Dungeon"], 316},
			{"Dungeon", 78.6, 58.9, L["Scarlet Halls"], L["Dungeon"], 311},
		},

		[21] =  --[[Silverpine Forest]] {
			{"Dungeon", 44.8, 67.8, L["Shadowfang Keep"], L["Dungeon"], 64},
		},

		[22] =  --[[Western Plaguelands]] {
			{"Dungeon", 69.6, 73.2, L["Scholomance"], L["Dungeon"], 246},
		},

		[23] =  --[[Eastern Plaguelands]] {
			{"Dungeon", 27.7, 11.6, L["Stratholme: Crusader's Square"], L["Dungeon"], 236},
			{"Dungeon", 43.5, 19.4, L["Stratholme: The Gauntlet"], L["Dungeon"], 236},
		},

		[30] =  --[[New Tinkertown]] {
			{"Dungeon", 30.2, 74.7, L["Gnomeregan"], L["Dungeon"], 231},
		},

		[32] =  --[[Searing Gorge]] {
			{"Dungeon", 34.9, 83.9, L["Blackrock Mountain"], L["Blackrock Caverns"] .. "," .. L["Blackrock Depths"] .. "|n" .. L["Blackrock Spire"] .. "," .. L["Blackwing Lair"] .. "," .. L["Molten Core"], 66},
		},

		[33] =  --[[Blackrock Mountain: Blackrock Spire]] {
			{"Dungeon", 66.5, 60.7, L["Blackrock Caverns"], L["Dungeon"], 66},
			{"Raid", 64.3, 70.9, L["Blackwing Lair"], L["Raid"], 742},
			{"Dungeon", 65.9, 41.9, L["Blackrock Spire"], L["Dungeon"], 229},
			{"Dungeon", 80.3, 40.7, L["Lower Blackrock Spire"], L["Dungeon"], 229},
			{"Dungeon", 79.0, 33.7, L["Upper Blackrock Spire"], L["Dungeon"], 559},
		},

		[34] =  --[[Blackrock Mountain: Blackrock Caverns]] {
			{"Dungeon", 71.9, 53.5, L["Blackrock Caverns"], L["Dungeon"], 66},
		},

		[35] =  --[[Blackrock Mountain: Blackrock Depths]] {
			{"Raid", 54.3, 83.4, L["Molten Core"], L["Raid"], 741},
			{"Dungeon", 39.0, 18.3, L["Blackrock Depths"], L["Dungeon"], 228},
		},

		[36] =  --[[Burning Steppes]] {
			{"Dungeon", 21.0, 37.9, L["Blackrock Mountain"], L["Blackrock Caverns"] .. "," .. L["Blackrock Depths"] .. "|n" .. L["Blackrock Spire"] .. "," .. L["Blackwing Lair"] .. "," .. L["Molten Core"], 66},
			{"Raid", 23.0, 26.3, L["Blackwing Descent"], L["Raid"], 73},
		},

		[37] =  --[[Elwynn Forest]] {
			{"Dungeon", 19.1, 36.9, L["The Stockade"], L["Dungeon"], 238},
		},

		[42] =  --[[Deadwind Pass]] {
			{"Raid", 46.9, 74.7, L["Karazhan"], L["Raid"], 745},
			{"Dungeon", 46.7, 70.2, L["Return to Karazhan"], L["Dungeon"], 860},
		},

		[50] =  --[[Northern Stranglethorn]] {
			{"Dungeon", 72.1, 32.9, L["Zul'Gurub"], L["Dungeon"], 76},
			{"PortalH", 37.6, 51.0, L["Undercity"], L["Portal"]},
		},

		[51] =  --[[Swamp of Sorrows]] {
			{"Dungeon", 69.7, 53.5, L["Temple of Atal'Hakkar"], L["Dungeon"], 237},
		},

		[52] =  --[[Westfall]] {
			{"Dungeon", 42.6, 71.8, L["The Deadmines"], L["Dungeon"], 63},
		},

		[55] =  --[[The Deadmines]] {
			{"Dungeon", 25.5, 51.1, L["The Deadmines"], L["Dungeon"], 63},
		},

		[84] =  --[[Stormwind City]] {
			{"Dungeon", 49.5, 69.5, L["The Stockade"], L["Dungeon"], 238},
			{"PortalA", 74.4, 18.4, L["Eastern Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Tol Barad"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"]},
		},

		[90] =  --[[Undercity]] {
			{"PortalH", 85.3, 17.1, L["Hellfire Peninsula"], L["Portal"]},
		},

		[224] =  --[[Stranglethorn Vale]] {
			{"Dungeon", 63.5, 21.6, L["Zul'Gurub"], L["Dungeon"], 76},
		},

		[243] =  --[[Blackrock Depths]] {
			{"Raid", 68.4, 38.3, L["Molten Core"], L["Raid"], 741},
		},

		[469] =  --[[New Tinkertown]] {
			{"Dungeon", 32.6, 37.0, L["Gnomeregan"], L["Dungeon"], 231},
		},

		----------------------------------------------------------------------
		--	World Of Warcraft: Kalimdor
		----------------------------------------------------------------------

		[10] =  --[[Northern Barrens]] {
			{"Dungeon", 38.9, 69.1, L["Wailing Caverns"], L["Dungeon"], 240},
		},

		[11] =  --[[Wailing Caverns]] {
			{"Dungeon", 55.1, 65.9, L["Wailing Caverns"], L["Dungeon"], 240},
		},

		[57] =  --[[Teldrassil]] {
			{"PortalA", 55.0, 93.7, L["Stormwind"], L["Portal"]},
			{"PortalA", 52.3, 89.5, L["Exodar"], L["Portal"]},
		},

		[63] =  --[[Ashenvale]] {
			{"Dungeon", 14.2, 13.9, L["Blackfathom Deeps"], L["Dungeon"], 227},
		},

		[64] =  --[[Thousand Needles]] {
			{"Dungeon", 41.5, 29.4, L["Razorfen Downs"], L["Dungeon"], 233},
		},

		[66] =  --[[Desolace]] {
			{"Dungeon", 29.1, 62.6, L["Maraudon"], L["Dungeon"], 232},
		},

		[67] =  --[[Maraudon: The Wicked Grotto]] {
			{"Dungeon", 78.2, 56.0, L["Maraudon: Foulspore Cavern"], L["Dungeon"], 232},
		},

		[68] =  --[[Maraudon: Foulspore Cavern]] {
			{"Dungeon", 44.4, 76.8, L["Maraudon: Earth Song Falls"], L["Dungeon"], 232},
			{"Dungeon", 52.0, 24.5, L["Maraudon: The Wicked Grotto"], L["Dungeon"], 232},
		},

		[69] =  --[[Feralas]] {
			{"Dungeon", 60.3, 31.3, L["Dire Maul: Capital Gardens"], L["Dungeon"], 230},
			{"Dungeon", 64.8, 30.2, L["Dire Maul: Warpwood Quarter"], L["Dungeon"], 230},
			{"Dungeon", 62.5, 24.9, L["Dire Maul: Gordok Commons"], L["Dungeon"], 230},
		},

		[70] =  --[[Dustwallow Marsh]] {
			{"Raid", 52.2, 75.7, L["Onyxia's Lair"], L["Raid"], 760},
		},

		[71] =  --[[Tanaris]] {
			{"Dungeon", 39.2, 21.3, L["Zul'Farrak"], L["Dungeon"], 241},
			{"Dungeon", 64.8, 50.0, L["Caverns of Time"], L["Black Morass"] .. ", " .. L["Culling of Stratholme"] .. ",|n" .. L["Dragon Soul"] .. ", " .. L["End Time"] .. ", " .. L["Hour of Twilight"] .. ",|n" .. L["Hyjal Summit"] .. ", " .. L["Old Hillsbrad Foothills"] .. ",|n" .. L["Well of Eternity"], 255},
		},

		[74] = 	--[[Caverns of Time: The Spiral]] {
			{"PortalA", 59.0, 26.8, L["Stormwind"], L["Portal"]},
			{"PortalH", 58.2, 26.7, L["Orgrimmar"], L["Portal"]},
		},

		[75] =  --[[Caverns of Time: Main Hub]] {
			{"Dungeon", 57.5, 82.6, L["The Culling of Stratholme"], L["Dungeon"], 279},
			{"Dungeon", 36.7, 83.0, L["The Black Morass"], L["Dungeon"], 255},
			{"Dungeon", 22.5, 64.4, L["Well of Eternity"], L["Dungeon"], 185},
			{"Dungeon", 26.9, 35.8, L["Old Hillsbrad Foothills"], L["Dungeon"], 251},
			{"Raid", 35.5, 15.6, L["Hyjal Summit"], L["Raid"], 750},
			{"Dungeon", 57.3, 29.6, L["End Time"], L["Dungeon"], 184},
			{"Raid", 61.6, 26.6, L["Dragon Soul"], L["Raid"], 187},
			{"Dungeon", 66.9, 29.4, L["Hour of Twilight"], L["Dungeon"], 186},
		},

		[81] =  --[[Silithus]] {
			{"PortalN", 43.2, 44.5, L["Chamber of Heart"], L["Titan Translocator"]},
			{"PortalA", 41.5, 44.9, L["Tiragarde Sound"], L["Portal"]},
			{"PortalH", 41.6, 45.2, L["Zuldazar"], L["Portal"]},
		},

		[85] =  --[[Orgrimmar: Main City]] {
			{"Dungeon", 55.2, 51.2, L["Ragefire Chasm"], L["Dungeon"], 226},
			{"PortalH", 50.1, 37.8, L["Western Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"]},
			{"PortalH", 47.4, 39.3, L["Tol Barad"], L["Portal"]},
			{"PortalH", 43.0, 65.0, L["Zeppelin to"] .." " .. L["Thunder Bluff"] .. ", " .. L["Mulgore"], ""},
			{"PortalH", 50.7, 55.5, L["Undercity"], L["Portal"]},
		},

		[86] =  --[[Orgrimmar: The Cleft Of Shadow]] {
			{"Dungeon", 70.0, 49.2, L["Ragefire Chasm"], L["Dungeon"], 226},
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

		[199] =  --[[Southern Barrens]] {
			{"Dungeon", 41.0, 94.6, L["Razorfen Kraul"], L["Dungeon"], 234},
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

		[327] =  --[[Ahn'Qiraj: The Fallen Kingdom]] {
			{"Raid", 46.8, 7.5, L["Temple of Ahn'Qiraj"], L["Raid"], 744},
			{"Raid", 58.9, 14.3, L["Ruins of Ahn'Qiraj"], L["Raid"], 743},
		},

		----------------------------------------------------------------------
		--	The Burning Crusade
		----------------------------------------------------------------------

		[95] =  --[[Ghostlands]] {
			{"Dungeon", 82.1, 64.3, L["Zul'Aman"], L["Dungeon"], 77},
		},

		[100] =  --[[Hellfire Peninsula]] {
			{"Raid", 46.6, 52.8, L["Magtheridon's Lair"], L["Raid"], 747},
			{"Dungeon", 47.7, 53.6, L["Hellfire Ramparts"], L["Dungeon"], 248},
			{"Dungeon", 47.7, 52.0, L["The Shattered Halls"], L["Dungeon"], 259},
			{"Dungeon", 46.0, 51.8, L["The Blood Furnace"], L["Dungeon"], 256},
			{"PortalH", 88.6, 47.7, L["Orgrimmar"], L["Portal"]},
			{"PortalA", 88.6, 52.8, L["Stormwind"], L["Portal"]},
		},

		[102] =  --[[Zangarmarsh]] {
			{"Dungeon", 50.4, 40.9, L["Coilfang Reservoir"], L["Serpentshrine Cavern"] .. ", " .. L["Slave Pens"] .. ",|n" .. L["Steamvault"] .. ", " .. L["Underbog"], 748},
		},

		[103] =  --[[The Exodar]] {
			{"PortalA", 48.3, 62.9, L["Stormwind"], L["Portal"]},
		},

		[104] =  --[[Shadowmoon Valley]] {
			{"Raid", 71.0, 46.4, L["Black Temple"], L["Raid"], 751},
		},

		[105] =  --[[Blade's Edge Mountains]] {
			{"Raid", 68.7, 24.3, L["Gruul's Lair"], L["Raid"], 746},
		},

		[108] =  --[[Terokkar Forest]] {
			{"Dungeon", 43.2, 65.6, L["Sethekk Halls"], L["Dungeon"], 252},
			{"Dungeon", 36.1, 65.6, L["Auchenai Crypts"], L["Dungeon"], 247},
			{"Dungeon", 39.6, 71.0, L["Shadow Labyrinth"], L["Dungeon"], 253},
			{"Dungeon", 39.7, 60.2, L["Mana-Tombs"], L["Dungeon"], 250},
		},

		[109] =  --[[Netherstorm]] {
			{"Dungeon", 70.6, 69.7, L["The Mechanar"], L["Dungeon"], 258},
			{"Raid", 73.7, 63.7, L["The Eye"], L["Raid"], 749},
			{"Dungeon", 71.7, 55.0, L["The Botanica"], L["Dungeon"], 257},
			{"Dungeon", 74.4, 57.7, L["The Arcatraz"], L["Dungeon"], 254},
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

		[122] =  --[[Isle of Quel'Danas]] {
			{"Dungeon", 61.2, 30.9, L["Magisters' Terrace"], L["Dungeon"], 249},
			{"Raid", 44.3, 45.6, L["Sunwell Plateau"], L["Raid"], 752},
		},

		[245] =  --[[Tol Barad Peninsula]] {
			{"PortalH", 56.3, 79.7, L["Orgrimmar"], L["Portal"]},
			{"PortalA", 75.3, 58.8, L["Stormwind"], L["Portal"]},},

		----------------------------------------------------------------------
		--	Wrath Of The Lich King
		----------------------------------------------------------------------

		[114] =  --[[Borean Tundra]] {
			{"Dungeon", 27.6, 26.6, L["The Nexus"], L["The Nexus"] .. ", " .. L["The Oculus"] .. ",|n" .. L["The Eye of Eternity"], 281},
		},

		[115] =  --[[Dragonblight]] {
			{"Raid", 59.6, 51.1, L["Wyrmrest Temple"], L["The Ruby Sanctum"] .. ", " .. L["The Obsidian Sanctum"], 761},
			{"Raid", 87.4, 51.1, L["Naxxramas"], L["Raid"], 754},
			{"Dungeon", 26.2, 49.6, L["Azjol-Nerub"], L["Azjol-Nerub"] .. ", " .. L["The Old Kingdom"], 272},
		},

		[116] =  --[[Grizzly Hills]] {
			{"Dungeon", 17.5, 27.0, L["Drak'Tharon Keep"], L["Dungeon"], 273},
		},

		[117] =  --[[Howling Fjord]] {
			{"Dungeon", 57.3, 46.8, L["Utgarde Keep"], L["Utgarde Keep"] .. ", " .. L["Utgarde Pinnacle"], 285},
		},

		[118] =  --[[Icecrown]] {
			{"Raid", 53.3, 85.5, L["Icecrown Citadel"], L["Raid"], 758},
			{"Dungeon", 52.6, 89.4, L["The Frozen Halls"], L["The Forge of Souls"] .. ", " .. L["The Pit of Saron"] .. ",|n" .. L["The Halls of Reflection"], 280},
			{"Dungeon", 74.2, 20.5, L["Trial of the Champion"], L["Dungeon"], 284},
			{"Raid", 75.1, 21.8, L["Trial of the Crusader"], L["Raid"], 757},
		},

		[120] =  --[[The Storm Peaks]] {
			{"Dungeon", 39.6, 26.9, L["Halls of Stone"], L["Dungeon"], 277},
			{"Dungeon", 45.4, 21.4, L["Halls of Lightning"], L["Dungeon"], 275},
			{"Raid", 41.6, 17.8, L["Ulduar"], L["Raid"], 759},
		},

		[121] =  --[[Zul'Drak]] {
			{"Dungeon", 29.0, 83.9, L["Drak'Tharon Keep"], L["Dungeon"], 273},
			{"Dungeon", 76.2, 21.1, L["Gundrak"], L["Dungeon"], 274},
			{"Dungeon", 81.2, 28.9, L["Gundrak (rear entrance)"], L["Dungeon"], 274},
		},

		[123] =  --[[Wintergrasp]] {
			{"Raid", 50.5, 16.4, L["Vault of Archavon"], L["Raid"], 753},
		},

		[125] =  --[[Dalaran]] {
			{"Dungeon", 66.8, 68.2, L["The Violet Hold"], L["Dungeon"], 283},
			{"PortalA", 40.1, 62.8, L["Stormwind"], L["Portal"]},
			{"PortalH", 55.3, 25.4, L["Orgrimmar"], L["Portal"]},
		},

		----------------------------------------------------------------------
		--	Cataclysm
		----------------------------------------------------------------------

		[198] =  --[[Mount Hyjal]] {
			{"Raid", 47.3, 78.0, L["Firelands"], L["Raid"], 78},
		},

		[203] =  --[[Vashj'ir]] {
			{"Dungeon", 49.1, 42.4, L["Throne of the Tides"], L["Dungeon"], 65},
		},

		[204] =  --[[Abyssal Depths]] {
			{"Dungeon", 70.8, 29.0, L["Throne of the Tides"], L["Dungeon"], 65},
		},

		[207] =  --[[Deepholm]] {
			{"Dungeon", 47.6, 52.0, L["The Stonecore"], L["Dungeon"], 67},
		},

		[241] =  --[[Twilight Highlands]] {
			{"Raid", 34.0, 78.0, L["The Bastion of Twilight"], L["Raid"], 72},
			{"Dungeon", 19.2, 54.0, L["Grim Batol"], L["Dungeon"], 71},
		},

		[244] =  --[[Tol Barad]] {
			{"Raid", 46.3, 47.9, L["Baradin Hold"], L["Raid"], 75},
		},

		[249] =  --[[Uldum]] {
			{"Dungeon", 71.6, 52.2, L["Halls of Origination"], L["Dungeon"], 70},
			{"Dungeon", 60.5, 64.2, L["Lost City of the Tol'vir"], L["Dungeon"], 69},
			{"Dungeon", 76.7, 84.4, L["The Vortex Pinnacle"], L["Dungeon"], 68},
			{"Raid", 38.4, 80.6, L["Throne of the Four Winds"], L["Raid"], 74},
		},

		----------------------------------------------------------------------
		--	Mists of Pandaria
		----------------------------------------------------------------------

		[371] =  --[[The Jade Forest]] {
			{"Dungeon", 56.2, 57.9, L["Temple of the Jade Serpent"], L["Dungeon"], 313},
		},

		[376] =  --[[Valley of the Four Winds]] {
			{"Dungeon", 36.1, 69.2, L["Stormstout Brewery"], L["Dungeon"], 302},
		},

		[379] =  --[[Kun-Lai Summit]] {
			{"Raid", 59.6, 39.2, L["Mogu'shan Vaults"], L["Raid"], 317},
			{"Dungeon", 36.7, 47.4, L["Shado-Pan Monastery"], L["Dungeon"], 312},
		},

		[388] =  --[[Townlong Steppes]] {
			{"Dungeon", 34.7, 81.5, L["Siege of Niuzao Temple"], L["Dungeon"], 324},
			{"RaidA", 49.7, 68.7, L["Throne of Thunder"], L["Raid"], 362},
			{"RaidH", 50.6, 73.4, L["Throne of Thunder"], L["Raid"], 362},
		},

		[390] =  --[[Vale of Eternal Blossoms]] {
			{"Dungeon", 80.9, 32.7, L["Mogu'shan Palace"], L["Dungeon"], 321},
			{"Raid", 72.4, 44.2, L["Siege of Orgrimmar"], L["Raid"], 369},
			{"Dungeon", 15.8, 74.3, L["Gate of the Setting Sun"], L["Dungeon"], 303},
		},

		[422] =  --[[Dread Wastes]] {
			{"Raid", 38.8, 35.0, L["Heart of Fear"], L["Raid"], 330},
		},

		[433] =  --[[The Veiled Stair]] {
			{"Raid", 48.4, 61.4, L["Terrace of Endless Spring"], L["Raid"], 320},
		},

		[504] =  --[[Isle of Thunder]] {
			{"Raid", 63.6, 32.3, L["Throne of Thunder"], L["Raid"], 362},
		},

		[392] =  --[[Shrine of Two Moons]] {
			{"PortalH", 73.3, 42.8, L["Orgrimmar"], L["Portal"]},
		},

		[394] =  --[[Shrine of Seven Stars]] {
			{"PortalA", 71.6, 36.0, L["Stormwind"], L["Portal"]},
		},

		----------------------------------------------------------------------
		--	Warlords of Draenor
		----------------------------------------------------------------------

		[525] =  --[[Frostfire Ridge]] {
			{"Dungeon", 49.8, 24.7, L["Bloodmaul Slag Mines"], L["Dungeon"], 385},
		},

		[534] =  --[[Tanaan Jungle]] {
			{"Raid", 45.7, 53.5, L["Hellfire Citadel"], L["Raid"], 669},
		},

		[535] =  --[[Talador]] {
			{"Dungeon", 46.3, 73.9, L["Auchindoun"], L["Dungeon"], 547},
		},

		[539] =  --[[Shadowmoon Valley]] {
			{"Dungeon", 31.9, 42.5, L["Shadowmoon Burial Grounds"], L["Dungeon"], 537},
		},

		[542] =  --[[Spires of Arak]] {
			{"Dungeon", 35.6, 33.6, L["Skyreach"], L["Dungeon"], 476},
		},

		[543] =  --[[Gorgrond]] {
			{"Raid", 51.3, 28.6, L["Blackrock Foundry"], L["Raid"], 457},
			{"Dungeon", 55.2, 31.9, L["Grimrail Depot"], L["Dungeon"], 536},
			{"Dungeon", 59.6, 45.5, L["The Everbloom"], L["Dungeon"], 556},
			{"Dungeon", 45.4, 13.5, L["Iron Docks"], L["Dungeon"], 558},
		},

		[550] =  --[[Nagrand]] {
			{"Raid", 32.9, 38.4, L["Highmaul"], L["Raid"], 477},
		},

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

		[885] =  --[[Antoran Wastes]] {
			{"Raid", 55.0, 62.4, L["Antorus, the Burning Throne"], L["Raid"], 946},
		},

		[630] =  --[[Azsuna]] {
			{"Dungeon", 61.1, 41.1, L["Eye of Azshara"], L["Dungeon"], 716},
			{"Dungeon", 48.1, 82.1, L["Vault of the Wardens"], L["Dungeon"], 707},
		},

		[646] =  --[[Broken Shore]] {
			{"Dungeon", 64.7, 16.6, L["Cathedral of Eternal Night"], L["Dungeon"], 900},
			{"Raid", 64.1, 21.3, L["Tomb of Sargeras"], L["Raid"], 875},
		},

		[627] =  --[[Dalaran]] {
			{"Dungeon", 66.5, 68.6, L["The Violet Hold"], L["Dungeon"], 777},
			{"PortalA", 39.6, 63.2, L["Stormwind"], L["Portal"]},
			{"PortalH", 55.2, 23.9, L["Orgrimmar"], L["Portal"]},
		},

		[682] =  --[[Felsoul Hold]] {
			{"PortalN", 53.6, 36.8, L["Shal'Aran"], L["Portal"], 0, 41575,},
		},

		[650] =  --[[Highmountain]] {
			{"Dungeon", 49.6, 68.7, L["Neltharion's Lair"], L["Dungeon"], 767},
		},

		[882] =  --[[Mac'Aree]] {
			{"Dungeon", 22.2, 56.2, L["Seat of the Triumvirate"], L["Dungeon"], 945},
		},

		[684] =  --[[Shattered Locus]] {
			{"PortalN", 40.9, 13.7, L["Shal'Aran"], L["Portal"], 0, 42230,},
		},

		[634] =  --[[Stormheim]] {
			{"Dungeon", 70.4, 69.5, L["Gates of Valor"], L["Halls of Valor"] .. "," .. L["Trial of Valor"], 721},
			{"Dungeon", 52.5, 45.3, L["Maw of Souls"], L["Dungeon"], 727},
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
			{"Dungeon", 43.3, 62.3, L["Sanctum of Order"], L["The Arcway"] .. "," .. L["The Nighthold"], 726},
			{"Dungeon", 50.9, 65.6, L["Court of Stars"], L["Dungeon"], 800},
		},

		[641] =  --[[Val'sharah]] {
			{"Dungeon", 38.6, 51.0, L["Black Rook Hold"], L["Dungeon"], 740},
			{"Dungeon", 59.0, 31.1, L["Darkheart Thicket"], L["Dungeon"], 762},
			{"Raid", 56.3, 36.9, L["The Emerald Nightmare"], L["Raid"], 768},
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

		[896] =  --[[Drustvar]] {
			{"Dungeon", 33.7, 12.6, L["Waycrest Manor"], L["Dungeon"], 1021},
		},

		[1462]=  --[[Mechagon Island]] {
			{"Dungeon", 73.2, 36.3, L["Operation: Mechagon"], L["Dungeon"], 1178},
		},

		[863] =  --[[Nazmir]] {
			{"Dungeon", 51.4, 64.9, L["The Underrot"], L["Dungeon"], 1022},
			{"Raid", 54.1, 63.0, L["Uldir"], L["Raid"], 1031},
		},

		[942] =  --[[Stormsong Valley]] {
			{"Raid", 83.9, 46.9, L["Crucible of Storms"], L["Raid"], 1177},
			{"Dungeon", 78.9, 26.5, L["Shrine of the Storm"], L["Dungeon"], 1036},
		},

		[895] =  --[[Tiragarde Sound]] {
			{"Dungeon", 84.5, 78.8, L["Freehold"], L["Dungeon"], 1001},
			{"RaidA", 74.4, 28.2, L["Battle of Dazar'alor"], L["Raid"], 1176},
			{"DungeonH", 88.3, 51.0, L["Siege of Boralus"], L["Dungeon"], 1023},
			{"DungeonA", 74.8, 24.1, L["Siege of Boralus"], L["Dungeon"], 1023},
		},

		[864] =  --[[Vol'dun]] {
			{"Dungeon", 51.9, 25.1, L["Temple of Sethraliss"], L["Dungeon"], 1030},
		},

		[862] =  --[[Zuldazar]] {
			{"Dungeon", 43.4, 39.5, L["Atal'Dazar"], L["Dungeon"], 968},
			{"Dungeon", 37.6, 39.5, L["Kings' Rest"], L["Dungeon"], 1041},
			{"DungeonA", 39.2, 71.5, L["The MOTHERLODE!!"], L["Dungeon"], 1012},
			{"RaidH", 54.3, 29.9, L["Battle of Dazar'alor"], L["Raid"], 1176},
			{"DungeonH", 56.1, 59.9, L["The MOTHERLODE!!"], L["Dungeon"], 1012},
		},

		[1527] =  --[[Uldum]] {
			{"Dungeon", 71.6, 52.2, L["Halls of Origination"], L["Dungeon"], 70},
			{"Dungeon", 60.5, 64.2, L["Lost City of the Tol'vir"], L["Dungeon"], 69},
			{"Dungeon", 76.7, 84.4, L["The Vortex Pinnacle"], L["Dungeon"], 68},
			{"Raid", 38.4, 80.6, L["Throne of the Four Winds"], L["Raid"], 74},
		},

		[1530] =  --[[Vale of Eternal Blossoms (N'Zoth)]] {
			{"Dungeon", 81.4, 30.2, L["Mogu'shan Palace"], L["Dungeon"], 321},
			{"Raid", 72.6, 42.0, L["Siege of Orgrimmar"], L["Raid"], 369},
			{"Dungeon", 15.5, 72.2, L["Gate of the Setting Sun"], L["Dungeon"], 303},
		},

		[1161] =  --[[Boralus Harbor]] {
			{"PortalA", 70.4, 17.7, L["Sanctum of the Sages"], L["Exodar"] .. ", " .. L["Ironforge"] .. ", " .. L["Nazjatar"] .. ", " .. L["Silithus"] .. ", " .. L["Stormwind"]},
			{"RaidA", 70.5, 35.4, L["Battle of Dazar'alor"], L["Raid"], 1176},
			{"DungeonA", 72.4, 19.0, L["Siege of Boralus"], L["Dungeon"], 1023},
		},

		[1163] =  --[[Dazar'alor (inside)]] {
			{"PortalH", 60.5, 70.3, L["Hall of Ancient Paths"], L["Nazjatar"] .. ", " .. L["Orgrimmar"] .. ", " .. L["Silithus"] .. ", " .. L["Silvermoon City"] .. ", " .. L["Thunder Bluff"]},
		},

		[1165] =  --[[Dazar'alor (outside)]] {
			{"RaidH", 38.9, 2.7, L["Battle of Dazar'alor"], L["Raid"], 1176},
			{"DungeonH", 44.3, 92.7, L["The MOTHERLODE!!"], L["Dungeon"], 1012},
		},

		[1473] =  --[[Chamber of Heart]] {
			{"PortalN", 50.1, 30.4, L["Silithus"], L["Titan Translocator"]},
		},

		----------------------------------------------------------------------
		--	Shadowlands
		----------------------------------------------------------------------

		[1525] =  --[[Revendreth]] {
			{"Dungeon", 78.3, 49.1, L["Halls of Atonement"], L["Dungeon"], 1185},
			{"Dungeon", 50.9, 29.9, L["Sanguine Depths"], L["Dungeon"], 1189},
			{"Raid", 46.2, 41.2, L["Castle Nathria"], L["Raid"], 1190},
		},

		[1533] =  --[[Bastion]] {
			{"Dungeon", 40.0, 55.3, L["The Necrotic Wake"], L["Dungeon"], 1182},
			{"Dungeon", 58.4, 28.7, L["Spires of Ascension"], L["Dungeon"], 1186},
		},

		[1536] =  --[[Maldraxxus]] {
			{"Dungeon", 59.2, 64.8, L["Plaguefall"], L["Dungeon"], 1183},
			{"Dungeon", 53.0, 53.0, L["Theater of Pain"], L["Dungeon"], 1187},
		},

		[1565] =  --[[Ardenweald]] {
			{"Dungeon", 68.7, 66.1, L["De Other Side"], L["Dungeon"], 1188},
			{"Dungeon", 35.4, 53.9, L["Mists of Tirna Scithe"], L["Dungeon"], 1184},
		},

		[2016] =  --[[Tazavesh, the Veiled Market]] {
			{"Dungeon", 88.9, 44.2, L["Tazavesh, the Veiled Market"], L["Dungeon"], 1194},
		},

		[1543] =  --[[The Maw]] {
			{"Raid", 69.7, 32.1, L["Sanctum of Domination"], L["Raid"], 1193},
		},

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
			{"Raid", 80.5, 53.4, L["Sepulcher of the First Ones"], L["Raid"], 1195},
			{"TaxiN", 34.9, 45.7, L["Exile's Hollow"], L["Sanctuary"]},
			{"TaxiN", 61.9, 58.9, L["Synthesis Forge"], L["Pet Crafting"]},
			{"TaxiN", 68.5, 30.2, L["Protoform Repository"], L["Mount Crafting"]},
		},

	}

	-- Function to check if dungeon is on a specific map ID (used for moving dungeons such as Ny'alotha)
	local function IsDungeonOnMapID(worldmapid, ejdungeonid)
		local dungeonEntrances = C_EncounterJournal.GetDungeonEntrancesForMap(worldmapid)
		for i, dungeonEntranceInfo in ipairs(dungeonEntrances) do
			local journalID = dungeonEntranceInfo.journalInstanceID
			if journalID and journalID == ejdungeonid then return true end
		end
	end

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

		-- Show Ny'alotha on correct map
		if IsDungeonOnMapID(1527, 1180) then
			-- Show Ny'alotha on Uldum map
			Leatrix_Maps["Icons"][1527] = Leatrix_Maps["Icons"][1527] or {}; tinsert(Leatrix_Maps["Icons"][1527],
				{"Raid", 55.1, 43.9, L["Ny'alotha, The Waking City"], L["Raid"], 1180}
			)
		end

		if IsDungeonOnMapID(1530, 1180) then
			-- Show Ny'alotha on Vale of Eternal Blossoms map
			Leatrix_Maps["Icons"][1530] = Leatrix_Maps["Icons"][1530] or {}; tinsert(Leatrix_Maps["Icons"][1530],
				{"Raid", 40.1, 45.5, L["Ny'alotha, The Waking City"], L["Raid"], 1180}
			)
		end

	end)
