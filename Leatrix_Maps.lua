
	----------------------------------------------------------------------
	-- 	Leatrix Maps 1.15.65.alpha.1 (5th December 2024)
	----------------------------------------------------------------------

	-- 10:Func, 20:Comm, 30:Evnt, 40:Panl

	-- Create global table
	_G.LeaMapsDB = _G.LeaMapsDB or {}

	-- Create local tables
	local LeaMapsLC, LeaMapsCB, LeaDropList, LeaConfigList, LeaLockList = {}, {}, {}, {}, {}

	-- Version
	LeaMapsLC["AddonVer"] = "1.15.65.alpha.1"

	-- Get locale table
	local void, Leatrix_Maps = ...
	local L = Leatrix_Maps.L

	-- Check Wow version is valid
	do
		local gameversion, gamebuild, gamedate, gametocversion = GetBuildInfo()
		if gametocversion and gametocversion > 19999 then
			-- Game client is not Wow Classic
			C_Timer.After(2, function()
				print(L["LEATRIX MAPS: WRONG VERSION INSTALLED!"])
			end)
			return
		end
		if gametocversion and gametocversion == 11504 then
			LeaMapsLC.NewPatch = true
		end
	end

	-- Check for ElvUI
	if IsAddOnLoaded("ElvUI") then LeaMapsLC.ElvUI = unpack(ElvUI) end

	-- Set bindings translations
	_G.BINDING_NAME_LEATRIX_MAPS_GLOBAL_TOGGLE = L["Toggle panel"]

	----------------------------------------------------------------------
	-- L00: Leatrix Maps
	----------------------------------------------------------------------

	-- Main function
	function LeaMapsLC:MainFunc()

		-- Replace map toggle function
		WorldMapFrame.HandleUserActionToggleSelf = function()
			if WorldMapFrame:IsShown() then WorldMapFrame:Hide() else WorldMapFrame:Show() end
		end

		-- Handle open and close the map for sticky map frame
		if LeaMapsLC["UseDefaultMap"] == "On" or LeaMapsLC["StickyMapFrame"] == "Off" then
			table.insert(UISpecialFrames, "WorldMapFrame")
		end

		-- Make the map bigger
		if LeaMapsLC["UseDefaultMap"] == "Off" then
			SetCVar("miniWorldMap", 1)
			WorldMapFrame.minimizedWidth = 1024
			WorldMapFrame.minimizedHeight = 712
			-- Resizing the map makes Questie icons smaller but works with GatherMate2
			WorldMapFrame:SetSize(WorldMapFrame.minimizedWidth, WorldMapFrame.minimizedHeight) -- Needed for Classic Era
			WorldMapFrame:OnFrameSizeChanged()
		end

		-- Hide the default map blackout frame
		if LeaMapsLC["UseDefaultMap"] == "On" then
			hooksecurefunc(WorldMapFrame.BlackoutFrame, "Show", function()
				WorldMapFrame.BlackoutFrame:Hide()
			end)
		end

		-- Disable built-in map opacity
		if LeaMapsLC["UseDefaultMap"] == "Off" then
			WorldMapFrame_SetOpacity(0)
			WorldMapFrame_SaveOpacity()
			SetCVar("worldMapOpacity", 0)
		end

		-- Unlock map frame
		if LeaMapsLC["UseDefaultMap"] == "Off" then
			-- Temporary for toggle lock
			WorldMapFrame:SetMovable(true)
			WorldMapFrame:RegisterForDrag("LeftButton")
			WorldMapFrame:SetScript("OnDragStart", function()
				if LeaMapsLC["UnlockMapFrame"] == "On" then
					-- WorldMapFrame:StartMoving()
					WorldMapTitleButton_OnDragStart()
				end
			end)
			WorldMapFrame:SetScript("OnDragStop", function()
				if LeaMapsLC["UnlockMapFrame"] == "On" then
					-- WorldMapFrame:StopMovingOrSizing()
					WorldMapTitleButton_OnDragStop()
					WorldMapFrame:SetUserPlaced(false)
					-- Save map frame position
					LeaMapsLC["MapPosA"], void, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = WorldMapFrame:GetPoint()
				end
			end)
		end

		-- Remove right-click from title bar
		if LeaMapsLC["UseDefaultMap"] == "Off" then
			WorldMapTitleButton:RegisterForClicks("LeftButtonDown")
		end

		-- Hide title bar if default map with menus or custom map
		if LeaMapsLC["UseDefaultMap"] == "On" and LeaMapsLC["ShowZoneMenu"] == "On" or LeaMapsLC["UseDefaultMap"] == "Off" then
			MiniWorldMapTitle:Hide()
		end

		-- Load Battlefield addon
		if not IsAddOnLoaded("Blizzard_BattlefieldMap") then
			RunScript('UIParentLoadAddOn("Blizzard_BattlefieldMap")')
		end

		-- Get player faction
		local playerFaction = UnitFactionGroup("player")

		-- Hide default world map dropdown menus
		local menuTempFrame = CreateFrame("FRAME")
		menuTempFrame:Hide()
		WorldMapContinentDropdown:SetParent(menuTempFrame)
		WorldMapZoneDropdown:SetParent(menuTempFrame)
		WorldMapZoomOutButton:SetParent(menuTempFrame)
		WorldMapZoneMinimapDropdown:SetParent(menuTempFrame)

		-- Function to show world map title button if default windowed map is showing
		local function SetWorldMapTitleButton()
			if LeaMapsLC["UseDefaultMap"] == "On" then
				if GetCVar("miniWorldMap") == "0" then
					-- Default maximised map so hide title button
					WorldMapTitleButton:Hide()
				else
					-- Default windowed map so hide title button
					WorldMapTitleButton:Show()
				end
			else
				-- Custom map so hide title button
				WorldMapTitleButton:Hide()
			end
		end

		-- Run function when maximised map is toggled and on startup
		hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", SetWorldMapTitleButton)
		SetWorldMapTitleButton()

		-- Hide right-click to zoom out button and message
		WorldMapZoomOutButton:Hide()
		WorldMapMagnifyingGlassButton:Hide()

		-- Set map frame strata to ensure other windows can interleave with it
		if LeaMapsLC["UseDefaultMap"] == "Off" then
			WorldMapFrame:SetFrameStrata("MEDIUM")
			WorldMapFrame.BorderFrame:SetFrameStrata("MEDIUM")
			WorldMapFrame.BorderFrame:SetFrameLevel(1)
		end

		----------------------------------------------------------------------
		-- Remove map border
		----------------------------------------------------------------------

		if LeaMapsLC["UseDefaultMap"] == "Off" then

			-- Reposition Krowi's World Map Buttons if installed
			if LibStub("Krowi_WorldMapButtons-1.4", true) then
				local lib = LibStub:GetLibrary("Krowi_WorldMapButtons-1.4")
				if lib and lib.SetOffsets then
					lib:SetOffsets(40, 0)
				end
			end

			-- Hide border frame
			MiniBorderLeft:Hide()
			MiniBorderRight:Hide()

			-- Hide maximise and minimise buttons
			WorldMapFrame.MaximizeMinimizeFrame.MaximizeButton:Hide()
			hooksecurefunc(WorldMapFrame.MaximizeMinimizeFrame.MaximizeButton, "Show", function()
				WorldMapFrame.MaximizeMinimizeFrame.MaximizeButton:Hide()
			end)

			-- Move close button inside scroll container
			WorldMapFrameCloseButton:ClearAllPoints()
			WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame.ScrollContainer, "TOPRIGHT", 0, 0)
			WorldMapFrameCloseButton:SetFrameLevel(5000)
			WorldMapFrameCloseButton.SetPoint = function() return end

			-- Function to set world map clickable area
			local function SetBorderClickInset()
				if LeaMapsLC["UnlockMapFrame"] == "On" then
					-- Map is unlocked so increase clickable area around map
					WorldMapFrame:SetHitRectInsets(-20, -20, -20, 0)
				else
					-- Map is locked so remove clickable area around map
					WorldMapFrame:SetHitRectInsets(6, 6, 65, 25)
				end
			end

			-- Set world map clickable area when unlock map frame option is clicked and on startup
			LeaMapsCB["UnlockMapFrame"]:HookScript("OnClick", SetBorderClickInset)
			SetBorderClickInset()

			-- Create black border around map
			local border = WorldMapFrame.ScrollContainer:CreateTexture(nil, "BACKGROUND")
			border:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
			border:SetPoint("TOPLEFT", -5, 5)
			border:SetPoint("BOTTOMRIGHT", 5, -5)
			border:SetVertexColor(0, 0, 0, 0.5)

		end

		----------------------------------------------------------------------
		-- Show zone dropdown menu
		----------------------------------------------------------------------

		if LeaMapsLC["ShowZoneMenu"] == "On" then

			-- Continent translations
			L["Eastern Kingdoms"] = POSTMASTER_PIPE_EASTERNKINGDOMS
			L["Kalimdor"] = POSTMASTER_PIPE_KALIMDOR
			L["Azeroth"] = AZEROTH

			-- Create outer frame for dropdown menus
			local outerFrame = CreateFrame("FRAME", nil, WorldMapFrame)
			outerFrame:SetSize(360, 20)

			if LeaMapsLC["UseDefaultMap"] == "Off" then
				outerFrame:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 16, 0)
			else
				outerFrame:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 14, 20)
			end

			-- Create No zones available dropdown menu
			LeaMapsLC["ZoneMapNoneMenu"] = 1

			local nodd = LeaMapsLC:CreateDropdown("ZoneMapNoneMenu", nil, 184, "TOPLEFT", outerFrame, "TOPLEFT", 184, -20, {{"---"}})
			nodd:SetFrameLevel(30)
			nodd:Disable()

			-- Create Eastern Kingdoms dropdown menu
			LeaMapsLC["ZoneMapEasternMenu"] = 1

			local mapEasternTable, mapEasternString = {}, {}
			local zones = C_Map.GetMapChildrenInfo(1415)
			if (zones) then
				for i, zoneInfo in ipairs(zones) do
					tinsert(mapEasternTable, {zonename = zoneInfo.name, mapid = zoneInfo.mapID})
					tinsert(mapEasternString, {zoneInfo.name, i + 1})
				end
			end

			table.sort(mapEasternString, function(k, v) return k[1] < v[1] end)

			tinsert(mapEasternString, 1, {L["Eastern Kingdoms"], 1})
			tinsert(mapEasternTable, 1, {zonename = L["Eastern Kingdoms"], mapid = 1415})

			local ekdd = LeaMapsLC:CreateDropdown("ZoneMapEasternMenu", nil, 184, "TOPLEFT", outerFrame, "TOPLEFT", 184, -20, mapEasternString)
			ekdd:SetFrameLevel(30)

			LeaMapsCB["ZoneMapEasternMenu"]:RegisterCallback("OnMenuClose", function()
				if not IsInInstance() then
					WorldMapFrame:SetMapID(mapEasternTable[LeaMapsLC["ZoneMapEasternMenu"]].mapid)
				end
			end)

			-- Create Kalimdor dropdown menu
			LeaMapsLC["ZoneMapKalimdorMenu"] = 1

			local mapKalimdorTable, mapKalimdorString = {}, {}
			local zones = C_Map.GetMapChildrenInfo(1414)
			if (zones) then
				for i, zoneInfo in ipairs(zones) do
					tinsert(mapKalimdorTable, {zonename = zoneInfo.name, mapid = zoneInfo.mapID})
					tinsert(mapKalimdorString, {zoneInfo.name, i + 1})
				end
			end

			table.sort(mapKalimdorString, function(k, v) return k[1] < v[1] end)

			tinsert(mapKalimdorString, 1, {L["Kalimdor"], 1})
			tinsert(mapKalimdorTable, 1, {zonename = L["Kalimdor"], mapid = 1414})

			local kmdd = LeaMapsLC:CreateDropdown("ZoneMapKalimdorMenu", nil, 184, "TOPLEFT", outerFrame, "TOPLEFT", 184, -20, mapKalimdorString)
			kmdd:SetFrameLevel(30)

			LeaMapsCB["ZoneMapKalimdorMenu"]:RegisterCallback("OnMenuClose", function()
				if not IsInInstance() then
					WorldMapFrame:SetMapID(mapKalimdorTable[LeaMapsLC["ZoneMapKalimdorMenu"]].mapid)
				end
			end)

			-- Create continent dropdown menu
			LeaMapsLC["ZoneMapContinentMenu"] = 1

			local mapContinentTable, mapContinentString = {}, {}

			tinsert(mapContinentString, 1, {L["Eastern Kingdoms"], 1})
			tinsert(mapContinentTable, 1, {zonename = L["Eastern Kingdoms"], mapid = 1415})
			tinsert(mapContinentString, 2, {L["Kalimdor"], 2})
			tinsert(mapContinentTable, 2, {zonename = L["Kalimdor"], mapid = 1414})
			tinsert(mapContinentString, 3, {L["Azeroth"], 3})
			tinsert(mapContinentTable, 3, {zonename = L["Azeroth"], mapid = 947})

			local cond = LeaMapsLC:CreateDropdown("ZoneMapContinentMenu", nil, 184, "TOPLEFT", outerFrame, "TOPLEFT", 0, -20, mapContinentString)
			cond:SetFrameLevel(30)

			LeaMapsCB["ZoneMapContinentMenu"]:RegisterCallback("OnMenuClose", function()
				ekdd:Hide(); kmdd:Hide(); nodd:Hide()
				if not IsInInstance() then
					if LeaMapsLC["ZoneMapContinentMenu"] == 1 then
						ekdd:Show()
						WorldMapFrame:SetMapID(mapEasternTable[LeaMapsLC["ZoneMapEasternMenu"]].mapid)
					elseif LeaMapsLC["ZoneMapContinentMenu"] == 2 then
						kmdd:Show()
						WorldMapFrame:SetMapID(mapKalimdorTable[LeaMapsLC["ZoneMapKalimdorMenu"]].mapid)
					elseif LeaMapsLC["ZoneMapContinentMenu"] == 3 then
						nodd:Show()
						WorldMapFrame:SetMapID(947)
					end
				end
			end)

			-- Create Azeroth lists
			local mapAzerothTable, mapAzerothString = {}, {}
			tinsert(mapAzerothString, 1, {L["Azeroth"], i})
			tinsert(mapAzerothTable, 1, {zonename = L["Azeroth"], mapid = 947})

			-- Function to set dropdown menu
			local function SetMapControls()

				-- Hide dropdown menus
				ekdd:Hide(); kmdd:Hide(); cond:Hide(); nodd:Hide()

				-- Eastern Kingdoms
				for k, v in pairs(mapEasternTable) do
					if v.mapid == WorldMapFrame.mapID then
						LeaMapsLC["ZoneMapEasternMenu"] = k
						ekdd:Show()
						LeaMapsLC["ZoneMapContinentMenu"] = 1; cond:Show()
						return
					end
				end

				-- Kalimdor
				for k, v in pairs(mapKalimdorTable) do
					if v.mapid == WorldMapFrame.mapID then
						LeaMapsLC["ZoneMapKalimdorMenu"] = k
						kmdd:Show()
						LeaMapsLC["ZoneMapContinentMenu"] = 2; cond:Show()
						return
					end
				end

				-- Azeroth
				if WorldMapFrame.mapID == 947 then
					nodd:Show()
					LeaMapsLC["ZoneMapContinentMenu"] = 3; cond:Show()
					return
				end

			end

			-- Set dropdown menu when map changes and when map is shown
			hooksecurefunc(WorldMapFrame, "OnMapChanged", SetMapControls)
			WorldMapFrame:HookScript("OnShow", SetMapControls)

			-- Move dropdown menus if using default map
			if LeaMapsLC["UseDefaultMap"] == "On" then

				hooksecurefunc(WorldMapFrame, "Minimize", function()
					outerFrame:ClearAllPoints()
					outerFrame:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 14, 20)
				end)

				hooksecurefunc(WorldMapFrame, "Maximize", function()
					outerFrame:ClearAllPoints()
					outerFrame:SetPoint("TOP", WorldMapFrame, "TOP", 0, -12)
				end)
			end

			-- ElvUI fixes
			if LeaMapsLC.ElvUI then
				local E, S = LeaMapsLC.ElvUI
				local S = E:GetModule('Skins')
				if E.private.skins.blizzard.enable and E.private.skins.blizzard.worldmap then
					S:HandleDropDownBox(cond)
					S:HandleDropDownBox(ekdd); ekdd:ClearAllPoints(); ekdd:SetPoint("LEFT", cond, "RIGHT", 4, 0)
					S:HandleDropDownBox(kmdd); kmdd:ClearAllPoints(); kmdd:SetPoint("LEFT", cond, "RIGHT", 4, 0)
					S:HandleDropDownBox(nodd); nodd:ClearAllPoints(); nodd:SetPoint("LEFT", cond, "RIGHT", 4, 0)
				end
			end

		end

		----------------------------------------------------------------------
		-- Enhance battlefield map
		----------------------------------------------------------------------

		if LeaMapsLC["EnhanceBattleMap"] == "On" then

			-- Show teammates
			RunScript('BattlefieldMapOptions.showPlayers = true')

			-- Group icon texture
			local partyTexture = "Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps_Icon.blp"

			-- Create configuraton panel
			local battleFrame = LeaMapsLC:CreatePanel("Enhance battlefield map", "battleFrame")

			-- Add controls
			LeaMapsLC:MakeTx(battleFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(battleFrame, "UnlockBattlefield", "Unlock battlefield map", 16, -92, false, "If checked, you can move the battlefield map by dragging any of its borders.|n|nYou can resize the battlefield map by dragging the bottom-right corner.")
			LeaMapsLC:MakeCB(battleFrame, "BattleCenterOnPlayer", "Center map on player", 16, -112, false, "If checked, the battlefield map will stay centered on your location as long as you are not in a dungeon.|n|nYou can hold shift while panning the map to temporarily prevent it from centering.")

			LeaMapsLC:MakeSL(battleFrame, "BattleGroupIconSize", "Group Icons", "Drag to set the group icon size.", 12, 48, 1, 206, -172, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattlePlayerArrowSize", "Player Arrow", "Drag to set the player arrow size.", 12, 48, 1, 36, -172, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleMapSize", "Map Size", "Drag to set the battlefield map size.|n|nIf the map is unlocked, you can also resize the battlefield map by dragging the bottom-right corner.", 150, 1200, 1, 36, -232, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleMapOpacity", "Map Opacity", "Drag to set the battlefield map opacity.", 0.1, 1, 0.1, 206, -232, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleMaxZoom", "Max Zoom", "Drag to set the maximum zoom level.|n|nOpen the battlefield map to see the maximum zoom level change as you drag the slider.", 1, 6, 0.1, 36, -292, "%.0f")

			-- Add preview texture
			local prevIcon = battleFrame:CreateTexture(nil, "ARTWORK")
			prevIcon:SetPoint("CENTER", battleFrame, "TOPLEFT", 400, -182)
			prevIcon:SetTexture(partyTexture)
			prevIcon:SetSize(30, 30)
			prevIcon:SetVertexColor(0.78, 0.61, 0.43, 1)

			-- Hide battlefield tab button when it's shown and on startup
			hooksecurefunc(BattlefieldMapTab, "Show", function() BattlefieldMapTab:Hide() end)

			-- Make battlefield map movable
			BattlefieldMapFrame:SetMovable(true)
			BattlefieldMapFrame:SetUserPlaced(true)
			BattlefieldMapFrame:SetDontSavePosition(true)
			BattlefieldMapFrame:SetClampedToScreen(true)

			-- Set battleifeld map position at startup
			BattlefieldMapFrame:ClearAllPoints()
			BattlefieldMapFrame:SetPoint(LeaMapsLC["BattleMapA"], UIParent, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"])

			-- Unlock battlefield map frame
			local eFrame = CreateFrame("Frame", nil, BattlefieldMapFrame.ScrollContainer)
			eFrame:SetPoint("TOPLEFT", 0, 0)
			eFrame:SetPoint("BOTTOMRIGHT", 0, 0)
			eFrame:SetFrameLevel(BattlefieldMapFrame:GetFrameLevel() - 1)
			eFrame:SetHitRectInsets(-15, -15, -15, -15)
			eFrame:SetAlpha(0)
			eFrame:EnableMouse(true)
			eFrame:RegisterForDrag("LeftButton")
			eFrame:SetScript("OnMouseDown", function()
				if LeaMapsLC["UnlockBattlefield"] == "On" then
					BattlefieldMapFrame:StartMoving()
				end
			end)
			eFrame:SetScript("OnMouseUp", function()
				-- Save frame positions
				BattlefieldMapFrame:StopMovingOrSizing()
				LeaMapsLC["BattleMapA"], void, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"] = BattlefieldMapFrame:GetPoint()
				BattlefieldMapFrame:SetMovable(true)
				BattlefieldMapFrame:ClearAllPoints()
				BattlefieldMapFrame:SetPoint(LeaMapsLC["BattleMapA"], UIParent, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"])
			end)

			-- Enable unlock border only when unlock is enabled
			local function SetUnlockBorder()
				if LeaMapsLC["UnlockBattlefield"] == "On" then
					eFrame:Show()
				else
					eFrame:Hide()
				end
			end

			-- Set unlock border when option is clicked and on startup
			LeaMapsCB["UnlockBattlefield"]:HookScript("OnClick", SetUnlockBorder)
			SetUnlockBorder()

			-- Toggle battlefield map frame with configuration panel
			battleFrame:HookScript("OnShow", function()
				if BattlefieldMapFrame:IsShown() then LeaMapsLC.BFMapWasShown = true else LeaMapsLC.BFMapWasShown = false end
				RunScript('BattlefieldMapFrame:Show()')
			end)
			battleFrame:HookScript("OnHide", function()
				if not LeaMapsLC.BFMapWasShown then RunScript('BattlefieldMapFrame:Hide()') end
			end)

			----------------------------------------------------------------------
			-- Battlefield map: Maximum zoom
			----------------------------------------------------------------------

			-- Function to set maximum zoom level
			local function SetZoomFunc()
				BattlefieldMapFrame.ScrollContainer:CreateZoomLevels()
				BattlefieldMapFrame.ScrollContainer:SetZoomTarget(BattlefieldMapFrame.ScrollContainer:GetScaleForMaxZoom())
				LeaMapsCB["BattleMaxZoom"].f:SetFormattedText("%.0f%%", LeaMapsLC["BattleMaxZoom"] / 1 * 100)
			end

			-- Set zoom level when options are changed
			LeaMapsCB["BattleMaxZoom"]:HookScript("OnValueChanged", SetZoomFunc)
			battleFrame.r:HookScript("OnClick", function()
				LeaMapsLC["BattleMaxZoom"] = 1
			end)
			LeaMapsCB["EnhanceBattleMapBtn"]:HookScript("OnClick", function()
				if not BattlefieldMapFrame:IsShown() then BattlefieldMapFrame:Show() end
				if IsShiftKeyDown() and IsControlKeyDown() then
					LeaMapsLC["BattleMaxZoom"] = 2
				end
			end)

			-- Set zoom level
			hooksecurefunc(BattlefieldMapFrame.ScrollContainer, "CreateZoomLevels", function(self)
				if LeaMapsLC["BattleMaxZoom"] == 1 then return end
				local layers = C_Map.GetMapArtLayers(self.mapID)
				local widthScale = self:GetWidth() / layers[1].layerWidth
				local heightScale = self:GetHeight() / layers[1].layerHeight
				self.baseScale = math.min(widthScale, heightScale)
				local currentScale = 0
				local MIN_SCALE_DELTA = 0.01
				self.zoomLevels = {}
				for layerIndex, layerInfo in ipairs(layers) do
					layerInfo.maxScale = layerInfo.maxScale * LeaMapsLC["BattleMaxZoom"]
					local zoomDeltaPerStep, numZoomLevels
					local zoomDelta = layerInfo.maxScale - layerInfo.minScale
					if zoomDelta > 0 then
						numZoomLevels = 2 + layerInfo.additionalZoomSteps * LeaMapsLC["BattleMaxZoom"]
						zoomDeltaPerStep = zoomDelta / (numZoomLevels - 1)
					else
						numZoomLevels = 1
						zoomDeltaPerStep = 1
					end
					for zoomLevelIndex = 0, numZoomLevels - 1 do
						currentScale = math.max(layerInfo.minScale + zoomDeltaPerStep * zoomLevelIndex, currentScale + MIN_SCALE_DELTA)
						table.insert(self.zoomLevels, {scale = currentScale * self.baseScale, layerIndex = layerIndex})
					end
				end
			end)

			----------------------------------------------------------------------
			-- Battlefield map: Resize map
			----------------------------------------------------------------------

			do

				BattlefieldMapFrame:SetResizable(true)

				-- Create scale handle
				local scaleHandle = CreateFrame("Frame", nil, BattlefieldMapFrame)
				scaleHandle:SetWidth(20)
				scaleHandle:SetHeight(20)
				scaleHandle:SetAlpha(0.5)
				scaleHandle:SetPoint("BOTTOMRIGHT", BattlefieldMapFrame, "BOTTOMRIGHT", 0, 0)
				scaleHandle:SetFrameStrata(BattlefieldMapFrame:GetFrameStrata())
				scaleHandle:SetFrameLevel(BattlefieldMapFrame:GetFrameLevel() + 15)

				scaleHandle.t = scaleHandle:CreateTexture(nil, "OVERLAY")
				scaleHandle.t:SetAllPoints()
				scaleHandle.t:SetTexture([[Interface\Buttons\UI-AutoCastableOverlay]])
				scaleHandle.t:SetTexCoord(0.619, 0.760, 0.612, 0.762)
				scaleHandle.t:SetDesaturated(true)

				-- Create scale frame
				local scaleMouse = CreateFrame("Frame", nil, BattlefieldMapFrame)
				scaleMouse:SetFrameStrata(BattlefieldMapFrame:GetFrameStrata())
				scaleMouse:SetFrameLevel(BattlefieldMapFrame:GetFrameLevel() + 20)
				scaleMouse:SetAllPoints(scaleHandle)
				scaleMouse:EnableMouse(true)
				scaleMouse:SetScript("OnEnter", function() scaleHandle.t:SetDesaturated(false) end)
				scaleMouse:SetScript("OnLeave", function() scaleHandle.t:SetDesaturated(true) end)

				-- Increase scale handle clickable area (left and top)
				scaleMouse:SetHitRectInsets(-20, 0, -20, 0)

				-- Click handlers
				scaleMouse:SetScript("OnMouseDown", function(frame)
					BattlefieldMapFrame:StartSizing()
					local mapTime = -1
					frame:SetScript("OnUpdate", function(self, elapsed)
						if BattlefieldMapFrame:GetWidth() > 1200 then BattlefieldMapFrame:SetWidth(1200) end
						if BattlefieldMapFrame:GetWidth() < 150 then BattlefieldMapFrame:SetWidth(150) end
						BattlefieldMapFrame:SetHeight(BattlefieldMapFrame:GetWidth() / 1.5)
						if mapTime > 0.5 or mapTime == -1 then
							BattlefieldMapFrame:OnFrameSizeChanged()
							LeaMapsLC["BattleMapSize"] = BattlefieldMapFrame:GetWidth()
							LeaMapsCB["BattleMapSize"]:Hide(); LeaMapsCB["BattleMapSize"]:Show()
							mapTime = 0
						end
						mapTime = mapTime + elapsed
					end)
				end)

				scaleMouse:SetScript("OnMouseUp", function(frame)
					frame:SetScript("OnUpdate", nil)
					BattlefieldMapFrame:StopMovingOrSizing()
					BattlefieldMapFrame:SetHeight(BattlefieldMapFrame:GetWidth() / 1.5)
					BattlefieldMapFrame:OnFrameSizeChanged()
					LeaMapsLC["BattleMapSize"] = BattlefieldMapFrame:GetWidth()
					LeaMapsLC["BattleMapA"], void, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"] = BattlefieldMapFrame:GetPoint()
					LeaMapsCB["BattleMapSize"]:Hide(); LeaMapsCB["BattleMapSize"]:Show()
				end)

				-- Function to set scale handle
				local function SetScaleHandle()
					if LeaMapsLC["UnlockBattlefield"] == "On" then
						scaleHandle:Show(); scaleMouse:Show()
					else
						scaleHandle:Hide(); scaleMouse:Hide()
					end
					BattlefieldMapFrame:SetWidth(LeaMapsLC["BattleMapSize"])
					BattlefieldMapFrame:SetHeight(LeaMapsLC["BattleMapSize"] / 1.5)
					BattlefieldMapFrame:OnFrameSizeChanged()
				end

				-- Set scale handle when option is clicked and on startup
				LeaMapsCB["UnlockBattlefield"]:HookScript("OnClick", SetScaleHandle)
				SetScaleHandle()

				-- Hook reset button click
				battleFrame.r:HookScript("OnClick", function()
					LeaMapsLC["BattleMapSize"] = 300
					SetScaleHandle()
					battleFrame:Hide(); battleFrame:Show()
				end)

				-- Hook configuration panel for preset profile
				LeaMapsCB["EnhanceBattleMapBtn"]:HookScript("OnClick", function()
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaMapsLC["BattleMapSize"] = 300
						SetScaleHandle()
						if battleFrame:IsShown() then battleFrame:Hide(); battleFrame:Show(); end
					end
				end)

				-- Set map size and show width percentage when slider changes
				LeaMapsCB["BattleMapSize"]:HookScript("OnValueChanged", function()
					SetScaleHandle()
					LeaMapsCB["BattleMapSize"].f:SetFormattedText("%.0f%%", LeaMapsLC["BattleMapSize"] / 300 * 100)
				end)
			end

			----------------------------------------------------------------------
			-- Battlefield map: Center map on player
			----------------------------------------------------------------------

			do

				local cTime = -1

				-- Function to update map
				local function cUpdate(self, elapsed)
					if cTime > 2 or cTime == -1 then
						if BattlefieldMapFrame.ScrollContainer:IsPanning() then return end
						if IsShiftKeyDown() then cTime = -2000 return end
						local position = C_Map.GetPlayerMapPosition(BattlefieldMapFrame.mapID, "player")
						if position then
							local x, y = position.x, position.y
							if x then
								local minX, maxX, minY, maxY = BattlefieldMapFrame.ScrollContainer:CalculateScrollExtentsAtScale(BattlefieldMapFrame.ScrollContainer:GetCanvasScale())
								local cx = Clamp(x, minX, maxX)
								local cy = Clamp(y, minY, maxY)
								BattlefieldMapFrame.ScrollContainer:SetPanTarget(cx, cy)
							end
							cTime = 0
						end
					end
					cTime = cTime + elapsed
				end

				-- Create frame for update
				local cFrame = CreateFrame("FRAME", nil, BattlefieldMapFrame)

				-- Function to set update state
				local function SetUpdateFunc()
					cTime = -1
					if LeaMapsLC["BattleCenterOnPlayer"] == "On" then
						cFrame:SetScript("OnUpdate", cUpdate)
					else
						cFrame:SetScript("OnUpdate", nil)
					end
				end

				-- Set update state when option is clicked and on startup
				LeaMapsCB["BattleCenterOnPlayer"]:HookScript("OnClick", SetUpdateFunc)
				SetUpdateFunc()

				-- Hook reset button click
				battleFrame.r:HookScript("OnClick", function()
					LeaMapsLC["BattleCenterOnPlayer"] = "Off"
					SetUpdateFunc()
					battleFrame:Hide(); battleFrame:Show()
				end)

				-- Hook configuration panel for preset profile
				LeaMapsCB["EnhanceBattleMapBtn"]:HookScript("OnClick", function()
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaMapsLC["BattleCenterOnPlayer"] = "On"
						SetUpdateFunc()
						if battleFrame:IsShown() then battleFrame:Hide(); battleFrame:Show(); end
					end
				end)

				-- Update location immediately or after a very short delay
				local function SetCenterNow()
					if LeaMapsLC["BattleCenterOnPlayer"] == "On" then
						if IsShiftKeyDown() then cTime = -2000 else	cTime = -1 end
					end
				end
				local function SetCenterSoon()
					if LeaMapsLC["BattleCenterOnPlayer"] == "On" then
						if IsShiftKeyDown() then cTime = -2000 else cTime = 1.7 end
					end
				end

				BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseUp", SetCenterSoon)
				BattlefieldMapFrame:HookScript("OnShow", SetCenterNow)
				BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseWheel", SetCenterSoon)

			end

			----------------------------------------------------------------------
			-- Battlefield map: Map opacity
			----------------------------------------------------------------------

			local function DoMapOpacity()
				LeaMapsCB["BattleMapOpacity"].f:SetFormattedText("%.0f%%", LeaMapsLC["BattleMapOpacity"] * 100)
				BattlefieldMapOptions.opacity = 1-LeaMapsLC["BattleMapOpacity"]
				RunScript('BattlefieldMapFrame:RefreshAlpha()')
			end

			-- Set opacity when slider is changed and on startup
			LeaMapsCB["BattleMapOpacity"]:HookScript("OnValueChanged", DoMapOpacity)
			DoMapOpacity()

			----------------------------------------------------------------------
			-- Battlefield map: Player arrow
			----------------------------------------------------------------------

			-- Function to set player arrow size
			local function SetPlayerArrow()
				for pin in BattlefieldMapFrame:EnumerateAllPins() do
					if pin.UpdateAppearanceData then
						BattlefieldMapFrame.groupMembersDataProvider:SetUnitPinSize("player", LeaMapsLC["BattlePlayerArrowSize"])
						pin:SynchronizePinSizes()
					end
				end
			end

			-- Set player arrow when option is changed and on startup
			LeaMapsCB["BattlePlayerArrowSize"]:HookScript("OnValueChanged", SetPlayerArrow)
			SetPlayerArrow()

			----------------------------------------------------------------------
			-- Battlefield map: Group icons
			----------------------------------------------------------------------

			-- Function to set group icons
			local function FixGroupPin(firstRun)
				for pin in BattlefieldMapFrame:EnumerateAllPins() do
					if pin.UpdateAppearanceData then

						-- Set icon texture
						pin:SetPinTexture("raid", partyTexture)
						pin:SetPinTexture("party", partyTexture)
						pin:SetAppearanceField("party", "useClassColor", true)
						pin:SetAppearanceField("raid", "useClassColor", true)

						-- Icons should be under the player arrow
						pin:SetAppearanceField("party", "sublevel", 0)
						pin:SetAppearanceField("raid", "sublevel", 0)

						-- Icon size
						local bfUnitPinSizes = pin.dataProvider:GetUnitPinSizesTable()
						bfUnitPinSizes.party = LeaMapsLC["BattleGroupIconSize"]
						bfUnitPinSizes.raid = LeaMapsLC["BattleGroupIconSize"]
						pin:SynchronizePinSizes()

						-- Hook update appearance function on first run only
						if firstRun then
							hooksecurefunc(pin, "UpdateAppearanceData", function(self)
								self:SetPinTexture("raid", partyTexture)
								self:SetPinTexture("party", partyTexture)
							end)
						end

					end
				end
			end

			-- Function to refresh size slider and update battlefield map
			local function SetIconSize()
				LeaMapsCB["BattleGroupIconSize"].f:SetText(LeaMapsLC["BattleGroupIconSize"] .. " (" .. string.format("%.0f%%", LeaMapsLC["BattleGroupIconSize"] / 12 * 100) .. ")")
				FixGroupPin()
				prevIcon:SetSize(LeaMapsLC["BattleGroupIconSize"], LeaMapsLC["BattleGroupIconSize"])
			end

			-- Set group icons when option is changed and on startup
			LeaMapsCB["BattleGroupIconSize"]:HookScript("OnValueChanged", SetIconSize)
			FixGroupPin(true)

			----------------------------------------------------------------------
			-- Battlefield map: Rest of configuration panel
			----------------------------------------------------------------------

			-- Back to Main Menu button click
			battleFrame.b:HookScript("OnClick", function()
				battleFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			battleFrame.r:HookScript("OnClick", function()
				LeaMapsLC["UnlockBattlefield"] = "On"
				LeaMapsLC["BattleMapSize"] = 300
				LeaMapsLC["BattleGroupIconSize"] = 12
				LeaMapsLC["BattlePlayerArrowSize"] = 12
				LeaMapsLC["BattleMapOpacity"] = 1
				LeaMapsLC["BattleMapA"], LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"] = "BOTTOMRIGHT", "BOTTOMRIGHT", -47, 83
				BattlefieldMapFrame:ClearAllPoints()
				BattlefieldMapFrame:SetPoint(LeaMapsLC["BattleMapA"], UIParent, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"])
				SetIconSize()
				SetPlayerArrow()
				DoMapOpacity()
				SetUnlockBorder()
				battleFrame:Hide(); battleFrame:Show()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["EnhanceBattleMapBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["UnlockBattlefield"] = "On"
					LeaMapsLC["BattleMapSize"] = 300
					LeaMapsLC["BattleGroupIconSize"] = 12
					LeaMapsLC["BattlePlayerArrowSize"] = 12
					LeaMapsLC["BattleMapOpacity"] = 1
					LeaMapsLC["BattleMapA"], LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"] = "BOTTOMRIGHT", "BOTTOMRIGHT", -47, 83
					BattlefieldMapFrame:ClearAllPoints()
					BattlefieldMapFrame:SetPoint(LeaMapsLC["BattleMapA"], UIParent, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"])
					SetIconSize()
					SetPlayerArrow()
					DoMapOpacity()
					SetUnlockBorder()
					if battleFrame:IsShown() then battleFrame:Hide(); battleFrame:Show(); end
				else
					battleFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Auto change zones
		----------------------------------------------------------------------

		if LeaMapsLC["AutoChangeZones"] == "On" then

			local constMapZone, constPlayerZone

			-- Store map zone and player zone when map changes
			hooksecurefunc(WorldMapFrame, "OnMapChanged", function()
				constMapZone = WorldMapFrame.mapID
				constPlayerZone = C_Map.GetBestMapForUnit("player")
			end)

			-- If map zone was player zone before zone change, set map zone to player zone after zone change
			local zoneEvent = CreateFrame("FRAME")
			zoneEvent:RegisterEvent("ZONE_CHANGED_NEW_AREA")
			zoneEvent:RegisterEvent("ZONE_CHANGED")
			zoneEvent:RegisterEvent("ZONE_CHANGED_INDOORS")
			zoneEvent:SetScript("OnEvent", function()
				local newMapID = WorldMapFrame.mapID
				local newPlayerZone = C_Map.GetBestMapForUnit("player")
				if newMapID and newMapID > 0 and newPlayerZone and newPlayerZone > 0 and constPlayerZone and constPlayerZone > 0 and newMapID == constPlayerZone then
					if C_Map.MapHasArt(newPlayerZone) then -- Needed for possible future dungeons
						WorldMapFrame:SetMapID(newPlayerZone)
					end
				end
				constPlayerZone = C_Map.GetBestMapForUnit("player")
			end)

		end

		----------------------------------------------------------------------
		-- Hide town and city icons
		----------------------------------------------------------------------

		if LeaMapsLC["HideTownCityIcons"] == "On" then
			hooksecurefunc(BaseMapPoiPinMixin, "OnAcquired", function(self)
				local wmapID = WorldMapFrame.mapID
				if wmapID and wmapID == 1414 or wmapID == 1415 or wmapID == 947 then
					if self.Texture and self.Texture:GetTexture() == 136441 then
						local a, b, c, d, e, f, g, h = self.Texture:GetTexCoord()
						if a == 0.5 and b == 0 and c == 0.5 and d == 0.125 and e == 0.625 and f == 0 and g == 0.625 and h == 0.125 then
							-- Hide town icons
							self:Hide()
						elseif a == 0.625 and b == 0 and c == 0.625 and d == 0.125 and e == 0.75 and f == 0 and g == 0.75 and h == 0.125 then
							-- Hide city icons
							self:Hide()
						end
					end
				end
			end)
		end

		----------------------------------------------------------------------
		-- Center map on player (no reload required)
		----------------------------------------------------------------------

		do

			local cTime = -1

			-- Function to update map
			local function cUpdate(self, elapsed)
				if cTime > 2 or cTime == -1 then
					if WorldMapFrame.ScrollContainer:IsPanning() then return end
					if IsShiftKeyDown() then cTime = -2000 return end
					local position = C_Map.GetPlayerMapPosition(WorldMapFrame.mapID, "player")
					if position then
						local x, y = position.x, position.y
						if x then
							local minX, maxX, minY, maxY = WorldMapFrame.ScrollContainer:CalculateScrollExtentsAtScale(WorldMapFrame.ScrollContainer:GetCanvasScale())
							local cx = Clamp(x, minX, maxX)
							local cy = Clamp(y, minY, maxY)
							WorldMapFrame.ScrollContainer:SetPanTarget(cx, cy)
						end
						cTime = 0
					end
				end
				cTime = cTime + elapsed
			end

			-- Create frame for update
			local cFrame = CreateFrame("FRAME", nil, WorldMapFrame)

			-- Function to set update state
			local function SetUpdateFunc()
				cTime = -1
				if LeaMapsLC["CenterMapOnPlayer"] == "On" then
					cFrame:SetScript("OnUpdate", cUpdate)
				else
					cFrame:SetScript("OnUpdate", nil)
				end
			end

			-- Set update state when option is clicked and on startup
			LeaMapsCB["CenterMapOnPlayer"]:HookScript("OnClick", SetUpdateFunc)
			SetUpdateFunc()

			-- Update location immediately or after a very short delay
			local function SetCenterNow()
				if LeaMapsLC["CenterMapOnPlayer"] == "On" then
					if IsShiftKeyDown() then cTime = -2000 else	cTime = -1 end
				end
			end
			local function SetCenterSoon()
				if LeaMapsLC["CenterMapOnPlayer"] == "On" then
					if IsShiftKeyDown() then cTime = -2000 else cTime = 1.7 end
				end
			end

			WorldMapFrame.ScrollContainer:HookScript("OnMouseUp", SetCenterSoon)
			WorldMapFrame:HookScript("OnShow", SetCenterNow)
			WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", SetCenterSoon)

		end

		----------------------------------------------------------------------
		-- Class colored icons
		----------------------------------------------------------------------

		if LeaMapsLC["UseClassIcons"] == "On" then

			local WorldMapUnitPin, WorldMapUnitPinSizes
			local partyTexture = "Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps_Icon.blp"

			-- Set group icon textures
			for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
				WorldMapUnitPin = pin
				WorldMapUnitPinSizes = pin.dataProvider:GetUnitPinSizesTable()
				WorldMapUnitPin:SetPinTexture("raid", partyTexture)
				WorldMapUnitPin:SetPinTexture("party", partyTexture)
				hooksecurefunc(WorldMapUnitPin, "UpdateAppearanceData", function(self)
					self:SetPinTexture("raid", partyTexture)
					self:SetPinTexture("party", partyTexture)
				end)
				break
			end

			-- Enable class colors
			WorldMapUnitPin:SetAppearanceField("party", "useClassColor", true)
			WorldMapUnitPin:SetAppearanceField("raid", "useClassColor", true)

			-- Create configuraton panel
			local classFrame = LeaMapsLC:CreatePanel("Class colored icons", "classFrame")

			-- Add controls
			LeaMapsLC:MakeTx(classFrame, "Settings", 16, -72)
			LeaMapsLC:MakeWD(classFrame, "Set the group icon size.", 16, -92)
			LeaMapsLC:MakeSL(classFrame, "ClassIconSize", "Group Icons", "Drag to set the group icon size.", 20, 80, 1, 36, -142, "%.0f")

			-- Add preview texture
			local prevIcon = classFrame:CreateTexture(nil, "ARTWORK")
			prevIcon:SetPoint("CENTER", classFrame, "TOPLEFT", 240, -152)
			prevIcon:SetTexture(partyTexture)
			prevIcon:SetSize(30,30)
			prevIcon:SetVertexColor(0.78, 0.61, 0.43, 1)

			-- Function to set class icon size
			local function SetIconSize()
				LeaMapsCB["ClassIconSize"].f:SetText(LeaMapsLC["ClassIconSize"] .. " (" .. string.format("%.0f%%", LeaMapsLC["ClassIconSize"] / 20 * 100) .. ")")
				WorldMapUnitPinSizes.party = LeaMapsLC["ClassIconSize"]
				WorldMapUnitPinSizes.raid = LeaMapsLC["ClassIconSize"]
				WorldMapUnitPin:SynchronizePinSizes()
				prevIcon:SetSize(LeaMapsLC["ClassIconSize"], LeaMapsLC["ClassIconSize"])
			end

			-- Set group icon size when options are changed and on startup
			LeaMapsCB["ClassIconSize"]:HookScript("OnValueChanged", SetIconSize)
			SetIconSize()

			-- Back to Main Menu button click
			classFrame.b:HookScript("OnClick", function()
				classFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			classFrame.r:HookScript("OnClick", function()
				LeaMapsLC["ClassIconSize"] = 20
				SetIconSize()
				classFrame:Hide(); classFrame:Show()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["UseClassIconsBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["ClassIconSize"] = 27
					SetIconSize()
					if classFrame:IsShown() then classFrame:Hide(); classFrame:Show(); end
				else
					classFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Unlock map frame
		----------------------------------------------------------------------

		if LeaMapsLC["UseDefaultMap"] == "Off" then

			-- Replace function to account for frame scale
			WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
				local x,y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
				local s = WorldMapFrame:GetScale() * UIParent:GetEffectiveScale()
				return x/s, y/s
			end

			-- Create configuraton panel
			local UnlockMapPanel = LeaMapsLC:CreatePanel("Unlock map frame", "UnlockMapPanel")

			-- Add controls
			LeaMapsLC:MakeTx(UnlockMapPanel, "Settings", 16, -72)
			LeaMapsLC:MakeSL(UnlockMapPanel, "MapScale", "Map Scale", "Drag to set the world map scale.|n|nYou can also rescale the world map by dragging the bottom-right corner.", 0.2, 3, 0.001, 16, -112, "%.1f")

			LeaMapsCB["MapScale"]:HookScript("OnValueChanged", function()
				WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
				LeaMapsCB["MapScale"].f:SetText(string.format("%.1f%%", LeaMapsLC["MapScale"] / 1 * 100))
				WorldMapFrame:OnFrameSizeChanged()
			end)

			-- Back to Main Menu button click
			UnlockMapPanel.b:HookScript("OnClick", function()
				UnlockMapPanel:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			UnlockMapPanel.r:HookScript("OnClick", function()
				LeaMapsCB["resetMapPosBtn"]:Click()
				UnlockMapPanel:Hide(); UnlockMapPanel:Show()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["UnlockMapFrameBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["MapScale"] = 1
					WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
					if UnlockMapPanel:IsShown() then UnlockMapPanel:Hide(); UnlockMapPanel:Show(); end
				else
					UnlockMapPanel:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

			-- Scale handle
			local moveDistance, mapX, mapY, mapLeft, mapTop, mapNormalScale, mapEffectiveScale = 0, 0, 0, 0, 0, 1

			-- Function to get movement distance
			local function GetScaleDistance()
				local left, top = mapLeft, mapTop
				local scale = mapEffectiveScale
				local x, y = GetCursorPosition()
				x = x / scale - left
				y = top - y / scale
				return sqrt(x * x + y * y)
			end

			-- Create scale handle
			local scaleHandle = CreateFrame("Frame", nil, WorldMapFrame)
			scaleHandle:SetWidth(20)
			scaleHandle:SetHeight(20)
			scaleHandle:SetAlpha(0.5)
			scaleHandle:ClearAllPoints()
			scaleHandle:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", -10, 28)
			scaleHandle:SetFrameStrata(WorldMapFrame:GetFrameStrata())
			scaleHandle:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 15)

			scaleHandle.t = scaleHandle:CreateTexture(nil, "OVERLAY")
			scaleHandle.t:SetAllPoints()
			scaleHandle.t:SetTexture([[Interface\Buttons\UI-AutoCastableOverlay]])
			scaleHandle.t:SetTexCoord(0.619, 0.760, 0.612, 0.762)
			scaleHandle.t:SetDesaturated(true)

			-- Create scale frame
			local scaleMouse = CreateFrame("Frame", nil, WorldMapFrame)
			scaleMouse:SetFrameStrata(WorldMapFrame:GetFrameStrata())
			scaleMouse:SetFrameLevel(WorldMapFrame:GetFrameLevel() + 20)
			scaleMouse:SetAllPoints(scaleHandle)
			scaleMouse:EnableMouse(true)
			scaleMouse:SetScript("OnEnter", function() scaleHandle.t:SetDesaturated(false) end)
			scaleMouse:SetScript("OnLeave", function() scaleHandle.t:SetDesaturated(true) end)

			-- Increase scale handle clickable area (left and top)
			scaleMouse:SetHitRectInsets(-20, 0, -20, 0)

			-- Click handlers
			scaleMouse:SetScript("OnMouseDown",function(frame)
				mapLeft, mapTop = WorldMapFrame:GetLeft(), WorldMapFrame:GetTop()
				mapNormalScale = WorldMapFrame:GetScale()
				mapX, mapY = mapLeft, mapTop - (UIParent:GetHeight() / mapNormalScale)
				mapEffectiveScale = WorldMapFrame:GetEffectiveScale()
				moveDistance = GetScaleDistance()
				frame:SetScript("OnUpdate", function()
					local scale = GetScaleDistance() / moveDistance * mapNormalScale
					if scale < 0.2 then	scale = 0.2	elseif scale > 3.0 then	scale = 3.0	end
					WorldMapFrame:SetScale(scale)
					local s = mapNormalScale / WorldMapFrame:GetScale()
					local x = mapX * s
					local y = mapY * s
					WorldMapFrame:ClearAllPoints()
					WorldMapFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
					LeaMapsLC["MapScale"] = WorldMapFrame:GetScale()
					LeaMapsCB["MapScale"]:Hide(); LeaMapsCB["MapScale"]:Show()
				end)
				frame:SetAllPoints(UIParent)
			end)

			scaleMouse:SetScript("OnMouseUp", function(frame)
				frame:SetScript("OnUpdate", nil)
				frame:SetAllPoints(scaleHandle)
				LeaMapsLC["MapScale"] = WorldMapFrame:GetScale()
				WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
				LeaMapsLC["MapPosA"], void, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = WorldMapFrame:GetPoint()
				WorldMapFrame:OnFrameSizeChanged()
			end)

			-- Function to set scale handle
			local function SetScaleHandle()
				if LeaMapsLC["UnlockMapFrame"] == "On" then
					scaleHandle:Show(); scaleMouse:Show()
				else
					scaleHandle:Hide(); scaleMouse:Hide()
				end
				WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
			end

			-- Set scale handle when option is clicked and on startup
			LeaMapsCB["UnlockMapFrame"]:HookScript("OnClick", SetScaleHandle)
			SetScaleHandle()

		end

		----------------------------------------------------------------------
		-- Enlarge player arrow
		----------------------------------------------------------------------

		do

			local WorldMapUnitPin, WorldMapUnitPinSizes

			-- Get unit provider
			for pin in WorldMapFrame:EnumeratePinsByTemplate("GroupMembersPinTemplate") do
				WorldMapUnitPin = pin
				WorldMapUnitPinSizes = pin.dataProvider:GetUnitPinSizesTable()
				break
			end

			-- Create panel
			local arrowFrame = LeaMapsLC:CreatePanel("Enlarge player arrow", "arrowFrame")

			-- Add controls
			LeaMapsLC:MakeTx(arrowFrame, "Settings", 16, -72)
			LeaMapsLC:MakeWD(arrowFrame, "Set the player arrow size.", 16, -92)
			LeaMapsLC:MakeSL(arrowFrame, "PlayerArrowSize", "Player Arrow", "Drag to set the player arrow size.", 16, 64, 1, 36, -142, "%.0f")

			-- Function to set player arrow size
			local function SetArrowSize()
				LeaMapsCB["PlayerArrowSize"].f:SetText(LeaMapsLC["PlayerArrowSize"] .. " (" .. string.format("%.0f%%", LeaMapsLC["PlayerArrowSize"] / 16 * 100) .. ")")
				if LeaMapsLC["EnlargePlayerArrow"] == "On" then
					WorldMapUnitPinSizes.player = LeaMapsLC["PlayerArrowSize"]
				else
					WorldMapUnitPinSizes.player = 16
				end
				WorldMapUnitPin:SynchronizePinSizes()
			end

			-- Set arrow size when options are changed and on startup
			LeaMapsCB["PlayerArrowSize"]:HookScript("OnValueChanged", SetArrowSize)
			LeaMapsCB["EnlargePlayerArrow"]:HookScript("OnClick", SetArrowSize)
			SetArrowSize()

			-- Back to Main Menu button click
			arrowFrame.b:HookScript("OnClick", function()
				arrowFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			arrowFrame.r:HookScript("OnClick", function()
				LeaMapsLC["PlayerArrowSize"] = 27
				SetArrowSize()
				arrowFrame:Hide(); arrowFrame:Show()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["EnlargePlayerArrowBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["PlayerArrowSize"] = 27
					SetArrowSize()
					if arrowFrame:IsShown() then arrowFrame:Hide(); arrowFrame:Show(); end
				else
					arrowFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show zone levels (must be before show dungeons and raids)
		----------------------------------------------------------------------

		do

			-- Create level range table
			local mapTable = {

				-- Eastern Kingdoms
				--[[Alterac Mountains]]		[1416] = {minLevel = 30, 	maxLevel = 40,		minFish = "130",},
				--[[Arathi Highlands]]		[1417] = {minLevel = 30, 	maxLevel = 40,		minFish = "130",},
				--[[Badlands]]				[1418] = {minLevel = 35, 	maxLevel = 45,},
				--[[Blasted Lands]]			[1419] = {minLevel = 45, 	maxLevel = 55},
				--[[Burning Steppes]]		[1428] = {minLevel = 50, 	maxLevel = 58,		minFish = "330",},
				--[[Deadwind Pass]]			[1430] = {minLevel = 55, 	maxLevel = 60,		minFish = "330",},
				--[[Dun Morogh]]			[1426] = {minLevel = 1, 	maxLevel = 10,		minFish = "1",},
				--[[Duskwood]]				[1431] = {minLevel = 18, 	maxLevel = 30,		minFish = "55",},
				--[[Eastern Plaguelands]]	[1423] = {minLevel = 53, 	maxLevel = 60,		minFish = "330",},
				--[[Elwynn Forest]]			[1429] = {minLevel = 1, 	maxLevel = 10,		minFish = "1",},
				--[[Hillsbrad Foothills]]	[1424] = {minLevel = 20, 	maxLevel = 30,		minFish = "55",},
				--[[Ironforge]]				[1455] = {minFish = 1,},
				--[[Loch Modan]]			[1432] = {minLevel = 10,	maxLevel = 20,		minFish = "1",},
				--[[Redridge Mountains]]	[1433] = {minLevel = 15, 	maxLevel = 25,		minFish = "55",},
				--[[Searing Gorge]]			[1427] = {minLevel = 43, 	maxLevel = 50},
				--[[Silverpine Forest]]		[1421] = {minLevel = 10, 	maxLevel = 20,		minFish = "1",},
				--[[Stormwind City]]		[1453] = {minFish = 1,},
				--[[Stranglethorn Vale]]	[1434] = {minLevel = 30, 	maxLevel = 45,		minFish = "130 (205)",},
				--[[Swamp of Sorrows]]		[1435] = {minLevel = 35, 	maxLevel = 45,		minFish = "130",},
				--[[The Hinterlands]]		[1425] = {minLevel = 40, 	maxLevel = 50,		minFish = "205",},
				--[[Tirisfal Glades]]		[1420] = {minLevel = 1, 	maxLevel = 10,		minFish = "1",},
				--[[Undercity]]				[1458] = {minFish = 1,},
				--[[Westfall]]				[1436] = {minLevel = 10, 	maxLevel = 20,		minFish = "1",},
				--[[Western Plaguelands]]	[1422] = {minLevel = 51, 	maxLevel = 58,		minFish = "205",},
				--[[Wetlands]]				[1437] = {minLevel = 20, 	maxLevel = 30,		minFish = "55",},

				-- Kalimdor
				--[[Ashenvale]]				[1440] = {minLevel = 18, 	maxLevel = 30,		minFish = "55",},
				--[[Azshara]]				[1447] = {minLevel = 45, 	maxLevel = 55,		minFish = "205 (330)",},
				--[[Darkshore]]				[1439] = {minLevel = 10,	maxLevel = 20,		minFish = "1",},
				--[[Darnassus]]				[1457] = {minFish = 1,},
				--[[Desolace]]				[1443] = {minLevel = 30, 	maxLevel = 40,		minFish = "130",},
				--[[Durotar]]				[1411] = {minLevel = 1, 	maxLevel = 10,		minFish = "1",},
				--[[Dustwallow Marsh]]		[1445] = {minLevel = 35, 	maxLevel = 45,		minFish = "130",},
				--[[Felwood]]				[1448] = {minLevel = 48, 	maxLevel = 55,		minFish = "205",},
				--[[Feralas]]				[1444] = {minLevel = 40, 	maxLevel = 50,		minFish = "205 (330)",},
				--[[Moonglade]]				[1450] = {minFish = 205,},
				--[[Mulgore]]				[1412] = {minLevel = 1, 	maxLevel = 10,		minFish = "1",},
				--[[Orgrimmar]]				[1454] = {minFish = 1,},
				--[[Silithus]]				[1451] = {minLevel = 55, 	maxLevel = 60,		minFish = "330",},
				--[[Stonetalon Mountains]]	[1442] = {minLevel = 15, 	maxLevel = 27,		minFish = "55",},
				--[[Tanaris]]				[1446] = {minLevel = 40, 	maxLevel = 50,		minFish = "205",},
				--[[Teldrassil]]			[1438] = {minLevel = 1, 	maxLevel = 10,		minFish = "1",},
				--[[The Barrens]]			[1413] = {minLevel = 10, 	maxLevel = 25,		minFish = "1",},
				--[[Thousand Needles]]		[1441] = {minLevel = 25, 	maxLevel = 35,		minFish = "130",},
				--[[Thunder Bluff]]			[1456] = {minFish = 1,},
				--[[Un'Goro Crater]]		[1449] = {minLevel = 48, 	maxLevel = 55,		minFish = "205",},
				--[[Winterspring]]			[1452] = {minLevel = 55, 	maxLevel = 60,		minFish = "330",},

			}

			-- Replace AreaLabelFrameMixin.OnUpdate
			local function AreaLabelOnUpdate(self)
				self:ClearLabel(MAP_AREA_LABEL_TYPE.AREA_NAME)
				local map = self.dataProvider:GetMap()
				if map:IsCanvasMouseFocus() then
					local name, description
					local mapID = map:GetMapID()
					local normalizedCursorX, normalizedCursorY = map:GetNormalizedCursorPosition()
					local positionMapInfo = C_Map.GetMapInfoAtPosition(mapID, normalizedCursorX, normalizedCursorY)
					if positionMapInfo and positionMapInfo.mapID ~= mapID then
						-- print(positionMapInfo.mapID)
						name = positionMapInfo.name
						-- Get level range from table
						local playerMinLevel, playerMaxLevel, minFish
						if mapTable[positionMapInfo.mapID] then
							playerMinLevel = mapTable[positionMapInfo.mapID]["minLevel"]
							playerMaxLevel = mapTable[positionMapInfo.mapID]["maxLevel"]
							minFish = mapTable[positionMapInfo.mapID]["minFish"]
						end
						-- Show level range if map zone exists in table
						if name and playerMinLevel and playerMaxLevel and playerMinLevel > 0 and playerMaxLevel > 0 then
							local playerLevel = UnitLevel("player")
							local color
							if playerLevel < playerMinLevel then
								color = GetQuestDifficultyColor(playerMinLevel)
							elseif playerLevel > playerMaxLevel then
								-- Subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
								color = GetQuestDifficultyColor(playerMaxLevel - 2)
							else
								color = QuestDifficultyColors["difficult"]
							end
							color = ConvertRGBtoColorString(color)
							if playerMinLevel ~= playerMaxLevel then
								name = name..color.." ("..playerMinLevel.."-"..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE
							else
								name = name..color.." ("..playerMaxLevel..")"..FONT_COLOR_CODE_CLOSE
							end
						end
						if minFish and LeaMapsLC["ShowFishingLevels"] == "On" then
							description = L["Fishing"] .. ": " .. minFish
						end
					else
						name = MapUtil.FindBestAreaNameAtMouse(mapID, normalizedCursorX, normalizedCursorY)
					end
					if name then
						self:SetLabel(MAP_AREA_LABEL_TYPE.AREA_NAME, name, description)
					end
				end
				self:EvaluateLabels()
			end

			-- Get original script name
			local origScript
			for provider in next, WorldMapFrame.dataProviders do
				if provider.setAreaLabelCallback then
					origScript = provider.Label:GetScript("OnUpdate")
				end
			end

			-- Toggle zone levels
			local function SetZoneLevelScript()
				for provider in next, WorldMapFrame.dataProviders do
					if provider.setAreaLabelCallback then
						if LeaMapsLC["ShowZoneLevels"] == "On" then
							provider.Label:SetScript("OnUpdate", AreaLabelOnUpdate)
						else
							provider.Label:SetScript("OnUpdate", origScript)
						end
					end
				end
			end

			-- Set zone levels when option is clicked and on startup
			LeaMapsCB["ShowZoneLevels"]:HookScript("OnClick", SetZoneLevelScript)
			SetZoneLevelScript()

			-- Create configuraton panel
			local levelFrame = LeaMapsLC:CreatePanel("Show zone levels", "levelFrame")

			-- Add controls
			LeaMapsLC:MakeTx(levelFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(levelFrame, "ShowFishingLevels", "Show minimum fishing skill levels", 16, -92, false, "If checked, the minimum fishing skill levels will be shown.")

			-- Back to Main Menu button click
			levelFrame.b:HookScript("OnClick", function()
				levelFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			levelFrame.r:HookScript("OnClick", function()
				LeaMapsLC["ShowFishingLevels"] = "On"
				levelFrame:Hide(); levelFrame:Show()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["ShowZoneLevelsBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["ShowFishingLevels"] = "On"
					if levelFrame:IsShown() then levelFrame:Hide(); levelFrame:Show(); end
				else
					levelFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show coordinates (no reload required)
		----------------------------------------------------------------------

		do

			-- Create cursor coordinates frame
			local cCursor = CreateFrame("Frame", nil, WorldMapFrame)
			cCursor:SetPoint("BOTTOMLEFT", 73, 7)
			cCursor:SetSize(200, 16)
			cCursor.x = cCursor:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
			cCursor.x:SetJustifyH"LEFT"
			cCursor.x:SetAllPoints()
			cCursor.x:SetText(L["Cursor"] .. ": 88.8, 88.8")
			cCursor:SetWidth(cCursor.x:GetStringWidth() + 30)

			-- Create player coordinates frame
			local cPlayer = CreateFrame("Frame", nil, WorldMapFrame)
			cPlayer:SetPoint("BOTTOMRIGHT", -46, 7)
			cPlayer:SetSize(200, 16)
			cPlayer.x = cPlayer:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
			cPlayer.x:SetJustifyH"LEFT"
			cPlayer.x:SetAllPoints()
			cPlayer.x:SetText(L["Player"] .. ": 88.8, 88.8")
			cPlayer:SetWidth(cPlayer.x:GetStringWidth() + 30)

			-- Update timer
			local cPlayerTime = -1

			-- Update function
			cPlayer:SetScript("OnUpdate", function(self, elapsed)
				if cPlayerTime > 0.1 or cPlayerTime == -1 then
					-- Cursor coordinates
					local x, y = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
					if x and y and x > 0 and y > 0 and MouseIsOver(WorldMapFrame.ScrollContainer) then
						cCursor.x:SetFormattedText("%s: %.1f, %.1f", L["Cursor"], ((floor(x * 1000 + 0.5)) / 10), ((floor(y * 1000 + 0.5)) / 10))
					else
						cCursor.x:SetFormattedText("%s:", L["Cursor"])
					end
				end
				if cPlayerTime > 0.2 or cPlayerTime == -1 then
					-- Player coordinates
					local mapID = C_Map.GetBestMapForUnit("player")
					if not mapID then
						cPlayer.x:SetFormattedText("%s:", L["Player"])
						return
					end
					local position = C_Map.GetPlayerMapPosition(mapID,"player")
					if position and position.x ~= 0 and position.y ~= 0 then
						cPlayer.x:SetFormattedText("%s: %.1f, %.1f", L["Player"], position.x * 100, position.y * 100)
					else
						cPlayer.x:SetFormattedText("%s: %.1f, %.1f", L["Player"], 0, 0)
					end
					cPlayerTime = 0
				end
				cPlayerTime = cPlayerTime + elapsed
			end)

			-- Function to show or hide coordinates
			local function SetupCoords()
				if LeaMapsLC["ShowCoords"] == "On" then
					-- Show coordinaes
					cCursor:Show(); cPlayer:Show()
				else
					cCursor:Hide(); cPlayer:Hide()
				end
			end

			-- Set coordinates when option is clicked and on startp
			LeaMapsCB["ShowCoords"]:HookScript("OnClick", SetupCoords)
			SetupCoords()

			-- Create background frame and move coordinates into it
			if LeaMapsLC["UseDefaultMap"] == "Off" then

				-- Create background frame
				local cFrame = CreateFrame("FRAME", nil, WorldMapFrame.ScrollContainer)
				cFrame:SetSize(WorldMapFrame:GetWidth(), 17)
				cFrame:SetPoint("BOTTOMLEFT", 17)
				cFrame:SetPoint("BOTTOMRIGHT", 0)

				cFrame.t = cFrame:CreateTexture(nil, "BACKGROUND")
				cFrame.t:SetAllPoints()
				cFrame.t:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
				cFrame.t:SetVertexColor(0, 0, 0, 0.5)

				-- Move coordinates up into the background frame
				cCursor:SetParent(cFrame)
				cCursor:ClearAllPoints()
				cCursor:SetPoint("BOTTOMLEFT", 102, 0)
				cPlayer:SetParent(cFrame)
				cPlayer:ClearAllPoints()
				cPlayer:SetPoint("BOTTOMRIGHT", -82, 0)

				-- Function to toggle background frame
				local function SetCoordsBackground()
					if LeaMapsLC["ShowCoords"] == "On" then
						cFrame:Show()
					else
						cFrame:Hide()
					end
				end

				-- Set background frame when option is clicked and startup
				LeaMapsCB["ShowCoords"]:HookScript("OnClick", SetCoordsBackground)
				SetCoordsBackground()

			end

		end

		----------------------------------------------------------------------
		-- Map zoom
		----------------------------------------------------------------------

		do

			WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", function(self, delta)
				local x, y = self:GetNormalizedCursorPosition()
				local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange()
				if delta == 1 then
					if nextZoomInScale > self:GetCanvasScale() then
						self:InstantPanAndZoom(nextZoomInScale, x, y)
					end
				else
					if nextZoomOutScale < self:GetCanvasScale() then
						self:InstantPanAndZoom(nextZoomOutScale, x, y)
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Increase zoom level (no reload required)
		----------------------------------------------------------------------

		do

			-- Create configuraton panel
			local IncreaseZoomFrame = LeaMapsLC:CreatePanel("Increase zoom level", "IncreaseZoomFrame")

			-- Add controls
			LeaMapsLC:MakeTx(IncreaseZoomFrame, "Settings", 16, -72)
			LeaMapsLC:MakeWD(IncreaseZoomFrame, "Set the maximum zoom scale.", 16, -92)
			LeaMapsLC:MakeSL(IncreaseZoomFrame, "IncreaseZoomMax", "Maximum", "Drag to set the maximum zoom level.|n|nOpen the map to see the maximum zoom level change as you drag the slider.", 1, 6, 0.1, 36, -142, "%.1f")

			-- Function to set maximum zoom level
			local function SetZoomFunc()
				WorldMapFrame.ScrollContainer:CreateZoomLevels()
				if WorldMapFrame:IsShown() then
					WorldMapFrame.ScrollContainer:SetZoomTarget(WorldMapFrame.ScrollContainer:GetScaleForMaxZoom())
				end
				LeaMapsCB["IncreaseZoomMax"].f:SetFormattedText("%.0f%%", LeaMapsLC["IncreaseZoomMax"] / 1 * 100)
			end

			-- Set zoom level when options are changed
			LeaMapsCB["IncreaseZoomMax"]:HookScript("OnValueChanged", SetZoomFunc)
			LeaMapsCB["IncreaseZoom"]:HookScript("OnClick", SetZoomFunc)

			-- Back to Main Menu button click
			IncreaseZoomFrame.b:HookScript("OnClick", function()
				IncreaseZoomFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			IncreaseZoomFrame.r:HookScript("OnClick", function()
				LeaMapsLC["IncreaseZoomMax"] = 2
				SetZoomFunc()
				IncreaseZoomFrame:Hide(); IncreaseZoomFrame:Show()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["IncreaseZoomBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["IncreaseZoomMax"] = 2
					SetZoomFunc()
				else
					IncreaseZoomFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

			-- Set zoom level
			hooksecurefunc(WorldMapFrame.ScrollContainer, "CreateZoomLevels", function(self)
				if LeaMapsLC["IncreaseZoom"] == "Off" then return end
				local layers = C_Map.GetMapArtLayers(self.mapID)
				local widthScale = self:GetWidth() / layers[1].layerWidth
				local heightScale = self:GetHeight() / layers[1].layerHeight
				self.baseScale = math.min(widthScale, heightScale)
				local currentScale = 0
				local MIN_SCALE_DELTA = 0.01
				self.zoomLevels = {}
				for layerIndex, layerInfo in ipairs(layers) do
					layerInfo.maxScale = layerInfo.maxScale * LeaMapsLC["IncreaseZoomMax"]
					local zoomDeltaPerStep, numZoomLevels
					local zoomDelta = layerInfo.maxScale - layerInfo.minScale
					if zoomDelta > 0 then
						numZoomLevels = 2 + layerInfo.additionalZoomSteps * LeaMapsLC["IncreaseZoomMax"]
						zoomDeltaPerStep = zoomDelta / (numZoomLevels - 1)
					else
						numZoomLevels = 1
						zoomDeltaPerStep = 1
					end
					for zoomLevelIndex = 0, numZoomLevels - 1 do
						currentScale = math.max(layerInfo.minScale + zoomDeltaPerStep * zoomLevelIndex, currentScale + MIN_SCALE_DELTA)
						table.insert(self.zoomLevels, {scale = currentScale * self.baseScale, layerIndex = layerIndex})
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Remember zoom level
		----------------------------------------------------------------------

		do

			-- Store initial pan and zoom settings
			local lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
			local lastHorizontal = WorldMapFrame.ScrollContainer:GetNormalizedHorizontalScroll()
			local lastVertical = WorldMapFrame.ScrollContainer:GetNormalizedVerticalScroll()
			local lastMapID = WorldMapFrame.mapID

			-- Store pan and zoom settings when map is hidden
			WorldMapFrame:HookScript("OnHide", function()
				if LeaMapsLC["RememberZoom"] == "On" then
					lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
					lastHorizontal = WorldMapFrame.ScrollContainer:GetNormalizedHorizontalScroll()
					lastVertical = WorldMapFrame.ScrollContainer:GetNormalizedVerticalScroll()
					lastMapID = WorldMapFrame.mapID
				end
			end)

			-- Restore pan and zoom settings when map is shown
			WorldMapFrame:HookScript("OnShow", function()
				if LeaMapsLC["RememberZoom"] == "On" then
					if WorldMapFrame.mapID == lastMapID then
						WorldMapFrame.ScrollContainer:InstantPanAndZoom(lastZoomLevel, lastHorizontal, lastVertical)
						WorldMapFrame.ScrollContainer:SetPanTarget(lastHorizontal, lastVertical)
						WorldMapFrame.ScrollContainer:Hide(); WorldMapFrame.ScrollContainer:Show()
					end
				end
			end)

		end

		----------------------------------------------------------------------
		-- Map position
		----------------------------------------------------------------------

		if LeaMapsLC["UseDefaultMap"] == "Off" then

			-- Remove frame management
			WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
			WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
			WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
			WorldMapFrame:SetIgnoreParentScale(false)
			WorldMapFrame.ScrollContainer:SetIgnoreParentScale(false)
			--WorldMapFrame.BlackoutFrame:Hide()
			--WorldMapFrame.IsMaximized = function() return false end

			-- Enable movement
			WorldMapFrame:SetMovable(true)
			WorldMapFrame:RegisterForDrag("LeftButton")
			WorldMapFrame:SetScript("OnDragStart", function()
				if LeaMapsLC["UnlockMapFrame"] == "On" then
					-- WorldMapFrame:StartMoving()
					-- WorldMapTitleButton_OnDragStart does nothing if map is locked
					WorldMapScreenAnchor:ClearAllPoints()
					WorldMapFrame:ClearAllPoints()
					WorldMapFrame:StartMoving()
				end
			end)
			WorldMapFrame:SetScript("OnDragStop", function()
				if LeaMapsLC["UnlockMapFrame"] == "On" then
					-- WorldMapFrame:StopMovingOrSizing()
					-- WorldMapTitleButton_OnDragStop does nothing if map is locked
					WorldMapFrame:StopMovingOrSizing()
					-- move the anchor
					WorldMapScreenAnchor:StartMoving()
					WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame)
					WorldMapScreenAnchor:StopMovingOrSizing()
					WorldMapFrame:SetUserPlaced(false)
					-- Save map frame position
					LeaMapsLC["MapPosA"], void, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = WorldMapFrame:GetPoint()
				end
			end)

			-- Set position on startup
			WorldMapFrame:HookScript("OnShow", function()
				if not LeaMapsLC.MapLoadPositioned then
					WorldMapFrame:ClearAllPoints()
					WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
					WorldMapTitleButton_OnDragStop()
					LeaMapsLC.MapLoadPositioned = true
				end
			end)

			-- Fix for Demodal clamping the map frame to the screen
			EventUtil.ContinueOnAddOnLoaded("Demodal",function()
				if WorldMapFrame:IsClampedToScreen() then
					WorldMapFrame:SetClampedToScreen(false)
				end
			end)

		end

		----------------------------------------------------------------------
		-- Set map opacity
		----------------------------------------------------------------------

		if LeaMapsLC["SetMapOpacity"] == "On" and not LeaLockList["SetMapOpacity"] then

			if LeaMapsLC["UseDefaultMap"] == "Off" then

				-- Create configuraton panel
				local alphaFrame = LeaMapsLC:CreatePanel("Set map opacity", "alphaFrame")

				-- Add controls
				LeaMapsLC:MakeTx(alphaFrame, "Settings", 16, -72)
				LeaMapsLC:MakeWD(alphaFrame, "Set map opacity while stationary and while moving.", 16, -92)
				LeaMapsLC:MakeSL(alphaFrame, "stationaryOpacity", "Stationary", "Drag to set the map opacity for when your character is stationary.", 0.1, 1, 0.1, 36, -142, "%.1f")
				LeaMapsLC:MakeSL(alphaFrame, "movingOpacity", "Moving", "Drag to set the map opacity for when your character is moving.", 0.1, 1, 0.1, 206, -142, "%.1f")
				LeaMapsLC:MakeCB(alphaFrame, "NoFadeCursor", "Use stationary opacity while pointing at map", 16, -182, false, "If checked, pointing at the map while your character is moving will cause the stationary opacity setting to be applied.")

				-- Function to set map opacity
				local function SetMapOpacity()
					LeaMapsCB["stationaryOpacity"].f:SetFormattedText("%.0f%%", LeaMapsLC["stationaryOpacity"] * 100)
					LeaMapsCB["movingOpacity"].f:SetFormattedText("%.0f%%", LeaMapsLC["movingOpacity"] * 100)
					-- Set opacity level as frame fader only takes effect when player moves
					if IsPlayerMoving() then
						WorldMapFrame:SetAlpha(LeaMapsLC["movingOpacity"])
					else
						WorldMapFrame:SetAlpha(LeaMapsLC["stationaryOpacity"])
					end
					-- Setup frame fader
					PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, LeaMapsLC["movingOpacity"], LeaMapsLC["stationaryOpacity"], 0.5, function() return not WorldMapFrame:IsMouseOver() or LeaMapsLC["NoFadeCursor"] == "Off" end)
				end

				-- Set map opacity when options are changed and on startup
				LeaMapsCB["stationaryOpacity"]:HookScript("OnValueChanged", SetMapOpacity)
				LeaMapsCB["movingOpacity"]:HookScript("OnValueChanged", SetMapOpacity)
				SetMapOpacity()

				-- Back to Main Menu button click
				alphaFrame.b:HookScript("OnClick", function()
					alphaFrame:Hide()
					LeaMapsLC["PageF"]:Show()
				end)

				-- Reset button click
				alphaFrame.r:HookScript("OnClick", function()
					LeaMapsLC["stationaryOpacity"] = 1.0
					LeaMapsLC["movingOpacity"] = 0.5
					LeaMapsLC["NoFadeCursor"] = "On"
					SetMapOpacity()
					alphaFrame:Hide(); alphaFrame:Show()
				end)

				-- Show configuration panel when configuration button is clicked
				LeaMapsCB["SetMapOpacityBtn"]:HookScript("OnClick", function()
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaMapsLC["stationaryOpacity"] = 1.0
						LeaMapsLC["movingOpacity"] = 0.5
						LeaMapsLC["NoFadeCursor"] = "On"
						SetMapOpacity()
						if alphaFrame:IsShown() then alphaFrame:Hide(); alphaFrame:Show(); end
					else
						alphaFrame:Show()
						LeaMapsLC["PageF"]:Hide()
					end
				end)

			end

		end

		----------------------------------------------------------------------
		-- Show points of interest (must be after zone levels)
		----------------------------------------------------------------------

		do

			-- Get table from file
			local PinData = Leatrix_Maps["Icons"]

			local LeaMix = CreateFromMixins(MapCanvasDataProviderMixin)

			function LeaMix:RefreshAllData()

				-- Remove all pins created by Leatrix Maps
				self:GetMap():RemoveAllPinsByTemplate("LeaMapsGlobalPinTemplate")

				-- Show new pins if option is enabled
				if LeaMapsLC["ShowPointsOfInterest"] == "On" then

					-- Make new pins
					local pMapID = WorldMapFrame.mapID
					if PinData[pMapID] then
						local count = #PinData[pMapID]
						for i = 1, count do

							-- Do nothing if pinInfo has no entry for zone we are looking at
							local pinInfo = PinData[pMapID][i]
							if not pinInfo then return nil end

							-- Get POI if any quest requirements have been met
							if LeaMapsLC["ShowDungeonIcons"] == "On" and (pinInfo[1] == "Dungeon" or pinInfo[1] == "Raid" or pinInfo[1] == "Dunraid")
							or LeaMapsLC["ShowTravelPoints"] == "On" and playerFaction == "Alliance" and (pinInfo[1] == "FlightA" or pinInfo[1] == "FlightN" or pinInfo[1] == "TravelA" or pinInfo[1] == "TravelN")
							or LeaMapsLC["ShowTravelPoints"] == "On" and playerFaction == "Horde" and (pinInfo[1] == "FlightH" or pinInfo[1] == "FlightN" or pinInfo[1] == "TravelH" or pinInfo[1] == "TravelN")
							or LeaMapsLC["ShowTravelOpposing"] == "On" and playerFaction == "Alliance" and (pinInfo[1] == "FlightH" or pinInfo[1] == "FlightN" or pinInfo[1] == "TravelH" or pinInfo[1] == "TravelN")
							or LeaMapsLC["ShowTravelOpposing"] == "On" and playerFaction == "Horde" and (pinInfo[1] == "FlightA" or pinInfo[1] == "FlightN" or pinInfo[1] == "TravelA" or pinInfo[1] == "TravelN")
							or LeaMapsLC["ShowSpiritHealers"] == "On" and (pinInfo[1] == "Spirit")
							or LeaMapsLC["ShowZoneCrossings"] == "On" and (pinInfo[1] == "Arrow")
							then
								local myPOI = {}
								myPOI["position"] = CreateVector2D(pinInfo[2] / 100, pinInfo[3] / 100)
								if LeaMapsLC["ShowZoneLevels"] == "On" and pinInfo[7] and pinInfo[8] then
									-- Set dungeon level in title
									local playerLevel = UnitLevel("player")
									local color
									local name = ""
									local dungeonMinLevel, dungeonMaxLevel = pinInfo[7], pinInfo[8]
									if playerLevel < dungeonMinLevel then
										color = GetQuestDifficultyColor(dungeonMinLevel)
									elseif playerLevel > dungeonMaxLevel then
										-- Subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
										color = GetQuestDifficultyColor(dungeonMaxLevel - 2)
									else
										color = QuestDifficultyColors["difficult"]
									end
									color = ConvertRGBtoColorString(color)
									if dungeonMinLevel ~= dungeonMaxLevel then
										name = name..color.." (" .. dungeonMinLevel .. "-" .. dungeonMaxLevel .. ")" .. FONT_COLOR_CODE_CLOSE
									else
										name = name..color.." (" .. dungeonMaxLevel .. ")" .. FONT_COLOR_CODE_CLOSE
									end
									myPOI["name"] = pinInfo[4] .. name
								else
									-- Show zone levels is disabled or dungeon has no level range
									myPOI["name"] = pinInfo[4]
								end

								-- Show zone crossings
								if LeaMapsLC["ShowZoneCrossings"] == "On" then
									myPOI["ZoneCrossing"] = pinInfo[13]
								end

								myPOI["description"] = pinInfo[5]
								myPOI["atlasName"] = pinInfo[6]
								local pin = self:GetMap():AcquirePin("LeaMapsGlobalPinTemplate", myPOI)
								pin.Texture:SetRotation(0)
								pin.HighlightTexture:SetRotation(0)
								-- Set pin scale (needed because changing map size affects other addons such as Questie)
								-- Not currently used as map is resized
								if LeaMapsLC["UseDefaultMap"] == "Off" then
									--pin.Texture:SetScale(0.7)
									--pin.HighlightTexture:SetScale(0.7)
								end
								-- Override travel textures
								if pinInfo[1] == "TravelA" then
									pin.Texture:SetTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
									pin.Texture:SetTexCoord(0, 0.25, 0.75, 1)
									pin.HighlightTexture:SetTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
									pin.HighlightTexture:SetTexCoord(0, 0.25, 0.75, 1)
								elseif pinInfo[1] == "TravelH" then
									pin.Texture:SetTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
									pin.HighlightTexture:SetTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
									pin.Texture:SetTexCoord(0.25, 0.5, 0.75, 1)
									pin.HighlightTexture:SetTexCoord(0.25, 0.5, 0.75, 1)
								elseif pinInfo[1] == "TravelN" then
									pin.Texture:SetTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
									pin.HighlightTexture:SetTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
									pin.Texture:SetTexCoord(0.5, 0.75, 0.75, 1)
									pin.HighlightTexture:SetTexCoord(0.5, 0.75, 0.75, 1)
								elseif pinInfo[1] == "Dunraid" then
									pin.Texture:SetTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
									pin.HighlightTexture:SetTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
									pin.Texture:SetTexCoord(0.75, 1, 0.75, 1)
									pin.Texture:SetSize(32, 32)
									pin.HighlightTexture:SetTexCoord(0.75, 1, 0.75, 1)
									pin.HighlightTexture:SetSize(32, 32)
								elseif pinInfo[1] == "Spirit" then
									pin.Texture:SetSize(20, 20)
									pin.HighlightTexture:SetSize(20, 20)
								elseif pinInfo[1] == "Arrow" then
									pin.Texture:SetRotation(pinInfo[12])
									pin.HighlightTexture:SetRotation(pinInfo[12])
								end
							end

						end
					end

				end
			end

			_G.LeaMapsGlobalPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")

			function LeaMapsGlobalPinMixin:OnAcquired(myInfo)
				BaseMapPoiPinMixin.OnAcquired(self, myInfo)
				self.ZoneCrossing = myInfo.ZoneCrossing
			end

			function LeaMapsGlobalPinMixin:OnMouseUp(btn)
				if btn == "LeftButton" then
					if self.ZoneCrossing then WorldMapFrame:SetMapID(self.ZoneCrossing) end
				elseif btn == "RightButton" then
					WorldMapFrame:NavigateToParentMap()
				end
			end

			WorldMapFrame:AddDataProvider(LeaMix)

			----------------------------------------------------------------------
			-- Configuration panel
			----------------------------------------------------------------------

			-- Create configuraton panel
			local poiFrame = LeaMapsLC:CreatePanel("Show points of interest", "poiFrame")

			-- Add controls
			LeaMapsLC:MakeTx(poiFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(poiFrame, "ShowDungeonIcons", "Show dungeons and raids", 16, -92, false, "If checked, dungeons and raids will be shown.")
			LeaMapsLC:MakeCB(poiFrame, "ShowTravelPoints", "Show travel points for same faction", 16, -112, false, "If checked, travel points for the same faction will be shown.|n|nThis includes flight points, boat harbors, zeppelin towers and tram stations.")
			LeaMapsLC:MakeCB(poiFrame, "ShowTravelOpposing", "Show travel points for opposing faction", 16, -132, false, "If checked, travel points for the opposing faction will be shown.|n|nThis includes flight points, boat harbors, zeppelin towers and tram stations.")
			LeaMapsLC:MakeCB(poiFrame, "ShowSpiritHealers", "Show spirit healers", 16, -152, false, "If checked, spirit healers will be shown.")
			LeaMapsLC:MakeCB(poiFrame, "ShowZoneCrossings", "Show zone crossings", 16, -172, false, "If checked, zone crossings will be shown.|n|nThese are clickable arrows that indicate the zone exit pathways.")

			-- Function to refresh points of interest
			local function SetPointsOfInterest()
				LeaMix:RefreshAllData()
			end

			-- Set points of interest when options are clicked (including show zone levels)
			LeaMapsCB["ShowPointsOfInterest"]:HookScript("OnClick", SetPointsOfInterest)
			LeaMapsCB["ShowDungeonIcons"]:HookScript("OnClick", SetPointsOfInterest)
			LeaMapsCB["ShowTravelPoints"]:HookScript("OnClick", SetPointsOfInterest)
			LeaMapsCB["ShowTravelOpposing"]:HookScript("OnClick", SetPointsOfInterest)
			LeaMapsCB["ShowSpiritHealers"]:HookScript("OnClick", SetPointsOfInterest)
			LeaMapsCB["ShowZoneCrossings"]:HookScript("OnClick", SetPointsOfInterest)
			LeaMapsCB["ShowZoneLevels"]:HookScript("OnClick", SetPointsOfInterest)

			-- Back to Main Menu button click
			poiFrame.b:HookScript("OnClick", function()
				poiFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			poiFrame.r:HookScript("OnClick", function()
				LeaMapsLC["ShowDungeonIcons"] = "On"
				LeaMapsLC["ShowTravelPoints"] = "On"
				LeaMapsLC["ShowTravelOpposing"] = "Off"
				LeaMapsLC["ShowSpiritHealers"] = "On"
				LeaMapsLC["ShowZoneCrossings"] = "On"
				SetPointsOfInterest()
				poiFrame:Hide(); poiFrame:Show()
			end)

			-- Show configuration panel when configuration button is clicked
			LeaMapsCB["ShowPointsOfInterestBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["ShowDungeonIcons"] = "On"
					LeaMapsLC["ShowTravelPoints"] = "On"
					LeaMapsLC["ShowTravelOpposing"] = "Off"
					LeaMapsLC["ShowSpiritHealers"] = "On"
					LeaMapsLC["ShowZoneCrossings"] = "On"
					SetPointsOfInterest()
					if poiFrame:IsShown() then poiFrame:Hide(); poiFrame:Show(); end
				else
					poiFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show unexplored areas
		----------------------------------------------------------------------

		if LeaMapsLC["RevealMap"] == "On" then

			-- Create table to store revealed overlays
			local overlayTextures = {}
			local bfoverlayTextures = {}
			local tex = {}

			-- Function to refresh overlays (Blizzard_SharedMapDataProviders\MapExplorationDataProvider)
			local function MapExplorationPin_RefreshOverlays(pin, fullUpdate)

				-- Remove existing textures
				for k, v in pairs(tex) do
					v:SetVertexColor(1, 1, 1, 1)
				end
				wipe(tex)

				overlayTextures = {}
				local mapID = WorldMapFrame.mapID; if not mapID then return end
				local artID = C_Map.GetMapArtID(mapID); if not artID or not Leatrix_Maps["Reveal"][artID] then return end
				local LeaMapsZone = Leatrix_Maps["Reveal"][artID]

				-- Store already explored tiles in a table so they can be ignored
				local TileExists = {}
				local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
				if exploredMapTextures then
					for i, exploredTextureInfo in ipairs(exploredMapTextures) do
						local key = exploredTextureInfo.textureWidth .. ":" .. exploredTextureInfo.textureHeight .. ":" .. exploredTextureInfo.offsetX .. ":" .. exploredTextureInfo.offsetY
						TileExists[key] = true
					end
				end

				-- Get the sizes
				pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
				local layers = C_Map.GetMapArtLayers(mapID)
				local layerInfo = layers and layers[pin.layerIndex]
				if not layerInfo then return end
				local TILE_SIZE_WIDTH = layerInfo.tileWidth
				local TILE_SIZE_HEIGHT = layerInfo.tileHeight

				-- Show textures if they are in database and have not been explored
				for key, files in pairs(LeaMapsZone) do
					if not TileExists[key] then
						local width, height, offsetX, offsetY = strsplit(":", key)
						local fileDataIDs = { strsplit(",", files) }
						local numTexturesWide = ceil(width/TILE_SIZE_WIDTH)
						local numTexturesTall = ceil(height/TILE_SIZE_HEIGHT)
						local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
						for j = 1, numTexturesTall do
							if ( j < numTexturesTall ) then
								texturePixelHeight = TILE_SIZE_HEIGHT
								textureFileHeight = TILE_SIZE_HEIGHT
							else
								texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
								if ( texturePixelHeight == 0 ) then
									texturePixelHeight = TILE_SIZE_HEIGHT
								end
								textureFileHeight = 16
								while(textureFileHeight < texturePixelHeight) do
									textureFileHeight = textureFileHeight * 2
								end
							end
							for k = 1, numTexturesWide do
								local texture = pin.overlayTexturePool:Acquire()
								tinsert(tex, texture)
								if ( k < numTexturesWide ) then
									texturePixelWidth = TILE_SIZE_WIDTH
									textureFileWidth = TILE_SIZE_WIDTH
								else
									texturePixelWidth = mod(width, TILE_SIZE_WIDTH)
									if ( texturePixelWidth == 0 ) then
										texturePixelWidth = TILE_SIZE_WIDTH
									end
									textureFileWidth = 16
									while(textureFileWidth < texturePixelWidth) do
										textureFileWidth = textureFileWidth * 2
									end
								end
								texture:SetSize(texturePixelWidth, texturePixelHeight)
								texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
								texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k-1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
								texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
								texture:SetDrawLayer("ARTWORK", -1)
								if LeaMapsLC["RevealMap"] == "On" then
									texture:Show()
									if fullUpdate then
										pin.textureLoadGroup:AddTexture(texture)
									end
								else
									texture:Hide()
								end
								if LeaMapsLC["RevTint"] == "On" then
									texture:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
								end
								tinsert(overlayTextures, texture)
							end
						end
					end
				end
			end

			-- Reset texture color and alpha
			local function TexturePool_ResetVertexColor(pool, texture)
				texture:SetVertexColor(1, 1, 1)
				texture:SetAlpha(1)
				return TexturePool_HideAndClearAnchors(pool, texture)
			end

			-- Show overlays on startup
			for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
				hooksecurefunc(pin, "RefreshOverlays", MapExplorationPin_RefreshOverlays)
				pin.overlayTexturePool.resetterFunc = TexturePool_ResetVertexColor
			end

			local bftex = {}

			-- Repeat refresh overlays function for Battlefield map
			local function bfMapExplorationPin_RefreshOverlays(pin, fullUpdate)

				-- Remove existing textures
				for k, v in pairs(bftex) do
					v:SetVertexColor(1, 1, 1, 1)
				end
				wipe(bftex)

				bfoverlayTextures = {}
				local mapID = BattlefieldMapFrame.mapID; if not mapID then return end
				local artID = C_Map.GetMapArtID(mapID); if not artID or not Leatrix_Maps["Reveal"][artID] then return end
				local LeaMapsZone = Leatrix_Maps["Reveal"][artID]

				-- Store already explored tiles in a table so they can be ignored
				local TileExists = {}
				local exploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures(mapID)
				if exploredMapTextures then
					for i, exploredTextureInfo in ipairs(exploredMapTextures) do
						local key = exploredTextureInfo.textureWidth .. ":" .. exploredTextureInfo.textureHeight .. ":" .. exploredTextureInfo.offsetX .. ":" .. exploredTextureInfo.offsetY
						TileExists[key] = true
					end
				end

				-- Get the sizes
				pin.layerIndex = pin:GetMap():GetCanvasContainer():GetCurrentLayerIndex()
				local layers = C_Map.GetMapArtLayers(mapID)
				local layerInfo = layers and layers[pin.layerIndex]
				if not layerInfo then return end
				local TILE_SIZE_WIDTH = layerInfo.tileWidth
				local TILE_SIZE_HEIGHT = layerInfo.tileHeight

				-- Show textures if they are in database and have not been explored
				for key, files in pairs(LeaMapsZone) do
					if not TileExists[key] then
						local width, height, offsetX, offsetY = strsplit(":", key)
						local fileDataIDs = { strsplit(",", files) }
						local numTexturesWide = ceil(width/TILE_SIZE_WIDTH)
						local numTexturesTall = ceil(height/TILE_SIZE_HEIGHT)
						local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight
						for j = 1, numTexturesTall do
							if ( j < numTexturesTall ) then
								texturePixelHeight = TILE_SIZE_HEIGHT
								textureFileHeight = TILE_SIZE_HEIGHT
							else
								texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
								if ( texturePixelHeight == 0 ) then
									texturePixelHeight = TILE_SIZE_HEIGHT
								end
								textureFileHeight = 16
								while(textureFileHeight < texturePixelHeight) do
									textureFileHeight = textureFileHeight * 2
								end
							end
							for k = 1, numTexturesWide do
								local texture = pin.overlayTexturePool:Acquire()
								tinsert(bftex, texture)
								if ( k < numTexturesWide ) then
									texturePixelWidth = TILE_SIZE_WIDTH
									textureFileWidth = TILE_SIZE_WIDTH
								else
									texturePixelWidth = mod(width, TILE_SIZE_WIDTH)
									if ( texturePixelWidth == 0 ) then
										texturePixelWidth = TILE_SIZE_WIDTH
									end
									textureFileWidth = 16
									while(textureFileWidth < texturePixelWidth) do
										textureFileWidth = textureFileWidth * 2
									end
								end
								texture:SetSize(texturePixelWidth, texturePixelHeight)
								texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
								texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k-1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
								texture:SetTexture(tonumber(fileDataIDs[((j - 1) * numTexturesWide) + k]), nil, nil, "TRILINEAR")
								texture:SetDrawLayer("ARTWORK", -1)
								texture:Show()
								if fullUpdate then
									pin.textureLoadGroup:AddTexture(texture)
								end
								if LeaMapsLC["RevTint"] == "On" then
									texture:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
								end
								tinsert(bfoverlayTextures, texture)
							end
						end
					end
				end
			end

			for pin in BattlefieldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
				hooksecurefunc(pin, "RefreshOverlays", bfMapExplorationPin_RefreshOverlays)
				pin.overlayTexturePool.resetterFunc = TexturePool_ResetVertexColor
			end

			-- Create tint frame
			local tintFrame = LeaMapsLC:CreatePanel("Show unexplored areas", "tintFrame")

			-- Add controls
			LeaMapsLC:MakeTx(tintFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(tintFrame, "RevTint", "Tint unexplored areas", 16, -92, false, "If checked, unexplored areas will be tinted.")
			LeaMapsLC:MakeSL(tintFrame, "tintRed", "Red", "Drag to set the amount of red.", 0, 1, 0.1, 36, -152, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintGreen", "Green", "Drag to set the amount of green.", 0, 1, 0.1, 36, -202, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintBlue", "Blue", "Drag to set the amount of blue.", 0, 1, 0.1, 206, -152, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintAlpha", "Opacity", "Drag to set the opacity.", 0.1, 1, 0.1, 206, -202, "%.1f")

			-- Add preview color block
			local prvTitle = LeaMapsLC:MakeWD(tintFrame, "Preview", 386, -130); prvTitle:Hide()
			tintFrame.preview = tintFrame:CreateTexture(nil, "ARTWORK")
			tintFrame.preview:SetSize(50, 50)
			tintFrame.preview:SetPoint("TOPLEFT", prvTitle, "TOPLEFT", 0, -20)

			-- Function to set tint color
			local function SetTintCol()
				tintFrame.preview:SetColorTexture(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
				-- Set slider values
				LeaMapsCB["tintRed"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintRed"] * 100)
				LeaMapsCB["tintGreen"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintGreen"] * 100)
				LeaMapsCB["tintBlue"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintBlue"] * 100)
				LeaMapsCB["tintAlpha"].f:SetFormattedText("%.0f%%", LeaMapsLC["tintAlpha"] * 100)
				-- Set tint
				if LeaMapsLC["RevTint"] == "On" then
					-- Enable tint
					for i = 1, #overlayTextures do
						overlayTextures[i]:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
					end
					for i = 1, #bfoverlayTextures do
						bfoverlayTextures[i]:SetVertexColor(LeaMapsLC["tintRed"], LeaMapsLC["tintGreen"], LeaMapsLC["tintBlue"], LeaMapsLC["tintAlpha"])
					end
					-- Enable controls
					LeaMapsCB["tintRed"]:Enable(); LeaMapsCB["tintRed"]:SetAlpha(1.0)
					LeaMapsCB["tintGreen"]:Enable(); LeaMapsCB["tintGreen"]:SetAlpha(1.0)
					LeaMapsCB["tintBlue"]:Enable(); LeaMapsCB["tintBlue"]:SetAlpha(1.0)
					LeaMapsCB["tintAlpha"]:Enable(); LeaMapsCB["tintAlpha"]:SetAlpha(1.0)
					prvTitle:SetAlpha(1.0); tintFrame.preview:SetAlpha(1.0)
				else
					-- Disable tint
					for i = 1, #overlayTextures do
						overlayTextures[i]:SetVertexColor(1, 1, 1)
						overlayTextures[i]:SetAlpha(1.0)
					end
					for i = 1, #bfoverlayTextures do
						bfoverlayTextures[i]:SetVertexColor(1, 1, 1)
						bfoverlayTextures[i]:SetAlpha(1.0)
					end
					-- Disable controls
					LeaMapsCB["tintRed"]:Disable(); LeaMapsCB["tintRed"]:SetAlpha(0.3)
					LeaMapsCB["tintGreen"]:Disable(); LeaMapsCB["tintGreen"]:SetAlpha(0.3)
					LeaMapsCB["tintBlue"]:Disable(); LeaMapsCB["tintBlue"]:SetAlpha(0.3)
					LeaMapsCB["tintAlpha"]:Disable(); LeaMapsCB["tintAlpha"]:SetAlpha(0.3)
					prvTitle:SetAlpha(0.3); tintFrame.preview:SetAlpha(0.3)
				end
			end

			-- Set tint properties when controls are changed and on startup
			LeaMapsCB["RevTint"]:HookScript("OnClick", SetTintCol)
			LeaMapsCB["tintRed"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintGreen"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintBlue"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintAlpha"]:HookScript("OnValueChanged", SetTintCol)
			SetTintCol()

			-- Back to Main Menu button click
			tintFrame.b:HookScript("OnClick", function()
				tintFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			tintFrame.r:HookScript("OnClick", function()
				LeaMapsLC["RevTint"] = "On"
				LeaMapsLC["tintRed"] = 0.6
				LeaMapsLC["tintGreen"] = 0.6
				LeaMapsLC["tintBlue"] = 1
				LeaMapsLC["tintAlpha"] = 1
				SetTintCol()
				tintFrame:Hide(); tintFrame:Show()
			end)

			-- Show tint configuration panel when configuration button is clicked
			LeaMapsCB["RevTintBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["RevTint"] = "On"
					LeaMapsLC["tintRed"] = 0.6
					LeaMapsLC["tintGreen"] = 0.6
					LeaMapsLC["tintBlue"] = 1
					LeaMapsLC["tintAlpha"] = 1
					SetTintCol()
					if tintFrame:IsShown() then tintFrame:Hide(); tintFrame:Show(); end
				else
					tintFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show minimap icon
		----------------------------------------------------------------------

		do

			-- Minimap button click function
			local function MiniBtnClickFunc(arg1)
				-- Prevent options panel from showing if chat configuration panel is showing
				if ChatConfigFrame:IsShown() then return end
				-- No modifier key toggles the options panel
				if LeaMapsLC:IsMapsShowing() then
					LeaMapsLC["PageF"]:Hide()
					LeaMapsLC:HideConfigPanels()
				else
					LeaMapsLC["PageF"]:Show()
				end

			end

			-- Create minimap button using LibDBIcon
			local miniButton = LibStub("LibDataBroker-1.1"):NewDataObject("Leatrix_Maps", {
				type = "data source",
				text = "Leatrix Maps",
				icon = "Interface\\HELPFRAME\\HelpIcon-Bug",
				OnClick = function(self, btn)
					MiniBtnClickFunc(btn)
				end,
				OnTooltipShow = function(tooltip)
					if not tooltip or not tooltip.AddLine then return end
					tooltip:AddLine("Leatrix Maps")
				end,
			})

			local icon = LibStub("LibDBIcon-1.0", true)
			icon:Register("Leatrix_Maps", miniButton, LeaMapsDB)

			-- Function to toggle LibDBIcon
			local function SetLibDBIconFunc()
				if LeaMapsLC["ShowMinimapIcon"] == "On" then
					LeaMapsDB["hide"] = false
					icon:Show("Leatrix_Maps")
				else
					LeaMapsDB["hide"] = true
					icon:Hide("Leatrix_Maps")
				end
			end

			-- Set LibDBIcon when option is clicked and on startup
			LeaMapsCB["ShowMinimapIcon"]:HookScript("OnClick", SetLibDBIconFunc)
			SetLibDBIconFunc()

		end

		----------------------------------------------------------------------
		-- Show memory usage
		----------------------------------------------------------------------

		do

			-- Show memory usage stat
			local function ShowMemoryUsage(frame, anchor, x, y)

				-- Create frame
				local memframe = CreateFrame("FRAME", nil, frame)
				memframe:ClearAllPoints()
				memframe:SetPoint(anchor, x, y)
				memframe:SetWidth(100)
				memframe:SetHeight(20)

				-- Create labels
				local pretext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				pretext:SetPoint("TOPLEFT", 0, 0)
				pretext:SetText(L["Memory Usage"])

				local memtext = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				memtext:SetPoint("TOPLEFT", 0, 0 - 30)

				-- Create stat
				local memstat = memframe:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
				memstat:SetPoint("BOTTOMLEFT", memtext, "BOTTOMRIGHT")
				memstat:SetText("(calculating...)")

				-- Create update script
				local memtime = -1
				memframe:SetScript("OnUpdate", function(self, elapsed)
					if memtime > 2 or memtime == -1 then
						UpdateAddOnMemoryUsage()
						memtext = GetAddOnMemoryUsage("Leatrix_Maps")
						memtext = math.floor(memtext + .5) .. " KB"
						memstat:SetText(memtext)
						memtime = 0
					end
					memtime = memtime + elapsed
				end)

			end

			-- ShowMemoryUsage(LeaMapsLC["PageF"], "TOPLEFT", 16, -242)

		end

		----------------------------------------------------------------------
		-- Use default map
		----------------------------------------------------------------------

		if LeaMapsLC["UseDefaultMap"] == "On" then
			-- Maximise world map and set to 100% scale
			-- MaximizeUIPanel(WorldMapFrame) -- Not used for Classic since it prevents map movement
			WorldMapFrame:SetScale(1)
			-- Lock some incompatible options
			LeaMapsLC:LockItem(LeaMapsCB["SetMapOpacity"], true)
			LeaMapsCB["SetMapOpacity"].tiptext = LeaMapsCB["SetMapOpacity"].tiptext .. "|n|n|cff00AAFF" .. L["Cannot be used with Use default map."]

			LeaMapsLC:LockItem(LeaMapsCB["UnlockMapFrame"], true)
			LeaMapsCB["UnlockMapFrame"].tiptext = LeaMapsCB["UnlockMapFrame"].tiptext .. "|n|n|cff00AAFF" .. L["Cannot be used with Use default map."]

			LeaMapsLC:LockItem(LeaMapsCB["StickyMapFrame"], true)
			LeaMapsCB["StickyMapFrame"].tiptext = LeaMapsCB["StickyMapFrame"].tiptext .. "|n|n|cff00AAFF" .. L["Cannot be used with Use default map."]

			-- Hide default map maximised right-click to zoom out text
			WorldMapMagnifyingGlassButton:HookScript("OnShow", function()
				WorldMapMagnifyingGlassButton:Hide()
			end)
		end

		----------------------------------------------------------------------
		-- Third party fixes
		----------------------------------------------------------------------

		-- ElvUI: Fix map movement and scale
		if LeaMapsLC.ElvUI then
			hooksecurefunc(WorldMapFrame, "Show", function()
				if not WorldMapFrame:IsMouseEnabled() then
					WorldMapFrame:EnableMouse(true)
					if LeaMapsLC["UseDefaultMap"] == "Off" then
						WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
					end
				end
			end)
			-- Hide ElvUI border backdrop
			if LeaMapsLC["UseDefaultMap"] == "Off" and WorldMapFrame.MiniBorderFrame.backdrop then
				WorldMapFrame.MiniBorderFrame.backdrop:Hide()
			end
		end

		----------------------------------------------------------------------
		-- Create panel in game options panel
		----------------------------------------------------------------------

		do

			local interPanel = CreateFrame("FRAME")
			interPanel.name = "Leatrix Maps"

			local maintitle = LeaMapsLC:MakeTx(interPanel, "Leatrix Maps", 0, 0)
			maintitle:SetFont(maintitle:GetFont(), 72)
			maintitle:ClearAllPoints()
			maintitle:SetPoint("TOP", 0, -72)

			local expTitle = LeaMapsLC:MakeTx(interPanel, L["World of Warcraft Classic"], 0, 0)
			expTitle:SetFont(expTitle:GetFont(), 32)
			expTitle:ClearAllPoints()
			expTitle:SetPoint("TOP", 0, -152)

			local subTitle = LeaMapsLC:MakeTx(interPanel, "www.leatrix.com", 0, 0)
			subTitle:SetFont(subTitle:GetFont(), 20)
			subTitle:ClearAllPoints()
			subTitle:SetPoint("BOTTOM", 0, 72)

			local slashTitle = LeaMapsLC:MakeTx(interPanel, "/ltm", 0, 0)
			slashTitle:SetFont(slashTitle:GetFont(), 72)
			slashTitle:ClearAllPoints()
			slashTitle:SetPoint("BOTTOM", subTitle, "TOP", 0, 40)
			slashTitle:SetScript("OnMouseUp", function(self, button)
				if button == "LeftButton" then
					SlashCmdList["Leatrix_Maps"]("")
				end
			end)
			slashTitle:SetScript("OnEnter", function()
				slashTitle.r,  slashTitle.g, slashTitle.b = slashTitle:GetTextColor()
				slashTitle:SetTextColor(1, 1, 0)
			end)
			slashTitle:SetScript("OnLeave", function()
				slashTitle:SetTextColor(slashTitle.r, slashTitle.g, slashTitle.b)
			end)

			local pTex = interPanel:CreateTexture(nil, "BACKGROUND")
			pTex:SetAllPoints()
			pTex:SetTexture("Interface\\GLUES\\Models\\UI_MainMenu\\swordgradient2")
			pTex:SetAlpha(0.2)
			pTex:SetTexCoord(0, 1, 1, 0)

			local category = Settings.RegisterCanvasLayoutCategory(interPanel, L["Leatrix Maps"])
			Settings.RegisterAddOnCategory(category)

		end

		----------------------------------------------------------------------
		-- Add zone map dropdown to main panel
		----------------------------------------------------------------------

		do

			LeaMapsLC:CreateDropdown("ZoneMapMenu", "Zone Map", 170, "TOPLEFT", LeaMapsLC["PageF"], "TOPLEFT", 16, -392, {{L["Never"], 1}, {L["Battlegrounds"], 2}, {L["Always"], 3}}, L["Choose where the zone map should be shown."])

			-- Set zone map visibility
			local function SetZoneMapStyle()
				-- Get dropdown menu value
				local zoneMapSetting = LeaMapsLC["ZoneMapMenu"] -- Numeric value
				-- Set chain style according to value
				SetCVar("showBattlefieldMinimap", zoneMapSetting - 1)
				-- From WorldMapZoneMinimapDropDown_OnClick in Blizzard_WorldMap
				_G.SHOW_BATTLEFIELD_MINIMAP = zoneMapSetting - 1
				if (DoesInstanceTypeMatchBattlefieldMapSettings()) then
					if (not BattlefieldMapFrame) then
						BattlefieldMap_LoadUI()
					end
					BattlefieldMapFrame:Show()
				else
					if (BattlefieldMapFrame) then
						BattlefieldMapFrame:Hide()
					end
				end
			end

			-- Set style on startup
			SetZoneMapStyle()

			-- Set style when a drop menu is selected
			LeaMapsCB["ZoneMapMenu"]:RegisterCallback("OnMenuClose", SetZoneMapStyle)

		end

		----------------------------------------------------------------------
		-- Final code
		----------------------------------------------------------------------

		-- Hide the battlefield map tab because it's shown even when enhance battlefield map is disabled
		BattlefieldMapTab:Hide()

		-- Show first run message
		if not LeaMapsDB["FirstRunMessageSeen"] then
			LeaMapsLC:Print(L["Enter"] .. " |cff00ff00" .. "/ltm" .. "|r " .. L["or click the minimap button to open Leatrix Maps."])
			LeaMapsDB["FirstRunMessageSeen"] = true
		end

		-- Release memory
		LeaMapsLC.MainFunc = nil

	end

	----------------------------------------------------------------------
	-- L10: Functions
	----------------------------------------------------------------------

	-- Function to add textures to panels
	function LeaMapsLC:CreateBar(name, parent, width, height, anchor, r, g, b, alp, tex)
		local ft = parent:CreateTexture(nil, "BORDER")
		ft:SetTexture(tex)
		ft:SetSize(width, height)
		ft:SetPoint(anchor)
		ft:SetVertexColor(r ,g, b, alp)
		if name == "MainTexture" then
			ft:SetTexCoord(0.09, 1, 0, 1)
		end
	end

	-- Create a configuration panel
	function LeaMapsLC:CreatePanel(title, globref)

		-- Create the panel
		local Side = CreateFrame("Frame", nil, UIParent)

		-- Make it a system frame
		_G["LeaMapsGlobalPanel_" .. globref] = Side
		table.insert(UISpecialFrames, "LeaMapsGlobalPanel_" .. globref)

		-- Store it in the configuration panel table
		tinsert(LeaConfigList, Side)

		-- Set frame parameters
		Side:Hide()
		Side:SetSize(470, 480)
		Side:SetClampedToScreen(true)
		Side:SetFrameStrata("FULLSCREEN_DIALOG")
		Side:SetFrameLevel(20)

		-- Set the background color
		Side.t = Side:CreateTexture(nil, "BACKGROUND")
		Side.t:SetAllPoints()
		Side.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

		-- Add a close Button
		Side.c = CreateFrame("Button", nil, Side, "UIPanelCloseButton")
		Side.c:SetSize(30, 30)
		Side.c:SetPoint("TOPRIGHT", 0, 0)
		Side.c:SetScript("OnClick", function() Side:Hide() end)

		-- Add reset, help and back buttons
		Side.r = LeaMapsLC:CreateButton("ResetButton", Side, "Reset", "BOTTOMLEFT", 16, 60, 25, "Click to reset the settings on this page.")
		Side.b = LeaMapsLC:CreateButton("BackButton", Side, "Back to Main Menu", "BOTTOMRIGHT", -16, 60, 25, "Click to return to the main menu.")

		-- Add a reload button and synchronise it with the main panel reload button
		local reloadb = LeaMapsLC:CreateButton("ConfigReload", Side, "Reload", "BOTTOMRIGHT", -16, 10, 25, LeaMapsCB["ReloadUIButton"].tiptext)
		LeaMapsLC:LockItem(reloadb, true)
		reloadb:SetScript("OnClick", ReloadUI)

		reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
		reloadb.f:SetHeight(32)
		reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
		reloadb.f:SetText(LeaMapsCB["ReloadUIButton"].f:GetText())
		reloadb.f:Hide()

		LeaMapsCB["ReloadUIButton"]:HookScript("OnEnable", function()
			LeaMapsLC:LockItem(reloadb, false)
			reloadb.f:Show()
		end)

		LeaMapsCB["ReloadUIButton"]:HookScript("OnDisable", function()
			LeaMapsLC:LockItem(reloadb, true)
			reloadb.f:Hide()
		end)

		-- Set textures
		LeaMapsLC:CreateBar("FootTexture", Side, 470, 48, "BOTTOM", 0.5, 0.5, 0.5, 1.0, "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
		LeaMapsLC:CreateBar("MainTexture", Side, 470, 433, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

		-- Allow movement
		Side:EnableMouse(true)
		Side:SetMovable(true)
		Side:RegisterForDrag("LeftButton")
		Side:SetScript("OnDragStart", Side.StartMoving)
		Side:SetScript("OnDragStop", function ()
			Side:StopMovingOrSizing()
			Side:SetUserPlaced(false)
			-- Save panel position
			LeaMapsLC["MainPanelA"], void, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = Side:GetPoint()
		end)

		-- Set panel attributes when shown
		Side:SetScript("OnShow", function()
			Side:ClearAllPoints()
			Side:SetPoint(LeaMapsLC["MainPanelA"], UIParent, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"])
		end)

		-- Add title
		Side.f = Side:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
		Side.f:SetPoint('TOPLEFT', 16, -16)
		Side.f:SetText(L[title])

		-- Add description
		Side.v = Side:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
		Side.v:SetHeight(32)
		Side.v:SetPoint('TOPLEFT', Side.f, 'BOTTOMLEFT', 0, -8)
		Side.v:SetPoint('RIGHT', Side, -32, 0)
		Side.v:SetJustifyH('LEFT'); Side.v:SetJustifyV('TOP')
		Side.v:SetText(L["Configuration Panel"])

		-- Prevent options panel from showing while side panel is showing
		LeaMapsLC["PageF"]:HookScript("OnShow", function()
			if Side:IsShown() then LeaMapsLC["PageF"]:Hide(); end
		end)

		-- Return the frame
		return Side

	end

	-- Hide configuration panels
	function LeaMapsLC:HideConfigPanels()
		for k, v in pairs(LeaConfigList) do
			v:Hide()
		end
	end

	-- Find out if Leatrix Maps is showing (main panel or config panel)
	function LeaMapsLC:IsMapsShowing()
		if LeaMapsLC["PageF"]:IsShown() then return true end
		for k, v in pairs(LeaConfigList) do
			if v:IsShown() then
				return true
			end
		end
	end

	-- Load a string variable or set it to default if it's not set to "On" or "Off"
	function LeaMapsLC:LoadVarChk(var, def)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "string" and LeaMapsDB[var] == "On" or LeaMapsDB[var] == "Off" then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Load a numeric variable and set it to default if it's not within a given range
	function LeaMapsLC:LoadVarNum(var, def, valmin, valmax)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "number" and LeaMapsDB[var] >= valmin and LeaMapsDB[var] <= valmax then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Load an anchor point variable and set it to default if the anchor point is invalid
	function LeaMapsLC:LoadVarAnc(var, def)
		if LeaMapsDB[var] and type(LeaMapsDB[var]) == "string" and LeaMapsDB[var] == "CENTER" or LeaMapsDB[var] == "TOP" or LeaMapsDB[var] == "BOTTOM" or LeaMapsDB[var] == "LEFT" or LeaMapsDB[var] == "RIGHT" or LeaMapsDB[var] == "TOPLEFT" or LeaMapsDB[var] == "TOPRIGHT" or LeaMapsDB[var] == "BOTTOMLEFT" or LeaMapsDB[var] == "BOTTOMRIGHT" then
			LeaMapsLC[var] = LeaMapsDB[var]
		else
			LeaMapsLC[var] = def
			LeaMapsDB[var] = def
		end
	end

	-- Show tooltips for checkboxes
	function LeaMapsLC:TipSee()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		local parent = self:GetParent()
		local pscale = parent:GetEffectiveScale()
		local gscale = UIParent:GetEffectiveScale()
		local tscale = GameTooltip:GetEffectiveScale()
		local gap = ((UIParent:GetRight() * gscale) - (parent:GetRight() * pscale))
		if gap < (250 * tscale) then
			GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
		else
			GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
		end
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	end

	-- Show tooltips for configuration buttons and dropdown menus
	function LeaMapsLC:ShowTooltip()
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		local parent = LeaMapsLC["PageF"]
		local pscale = parent:GetEffectiveScale()
		local gscale = UIParent:GetEffectiveScale()
		local tscale = GameTooltip:GetEffectiveScale()
		local gap = ((UIParent:GetRight() * gscale) - (LeaMapsLC["PageF"]:GetRight() * pscale))
		if gap < (250 * tscale) then
			GameTooltip:SetPoint("TOPRIGHT", parent, "TOPLEFT", 0, 0)
		else
			GameTooltip:SetPoint("TOPLEFT", parent, "TOPRIGHT", 0, 0)
		end
		GameTooltip:SetText(self.tiptext, nil, nil, nil, nil, true)
	end

	-- Print text
	function LeaMapsLC:Print(text)
		DEFAULT_CHAT_FRAME:AddMessage(L[text], 1.0, 0.85, 0.0)
	end

	-- Lock and unlock an item
	function LeaMapsLC:LockItem(item, lock)
		if lock then
			item:Disable()
			item:SetAlpha(0.3)
		else
			item:Enable()
			item:SetAlpha(1.0)
		end
	end

	-- Function to set lock state for configuration buttons
	function LeaMapsLC:LockOption(option, item, reloadreq)
		if reloadreq then
			-- Option change requires UI reload
			if LeaMapsLC[option] ~= LeaMapsDB[option] or LeaMapsLC[option] == "Off" then
				LeaMapsLC:LockItem(LeaMapsCB[item], true)
			else
				LeaMapsLC:LockItem(LeaMapsCB[item], false)
			end
		else
			-- Option change does not require UI reload
			if LeaMapsLC[option] == "Off" then
				LeaMapsLC:LockItem(LeaMapsCB[item], true)
			else
				LeaMapsLC:LockItem(LeaMapsCB[item], false)
			end
		end
	end

	-- Set lock state for configuration buttons
	function LeaMapsLC:SetDim()
		LeaMapsLC:LockOption("IncreaseZoom", "IncreaseZoomBtn", false) -- Increase zoom level
		LeaMapsLC:LockOption("RevealMap", "RevTintBtn", true) -- Reveal map
		LeaMapsLC:LockOption("EnlargePlayerArrow", "EnlargePlayerArrowBtn", false) -- Enlarge player arrow
		LeaMapsLC:LockOption("UseClassIcons", "UseClassIconsBtn", true) -- Class colored icons
		LeaMapsLC:LockOption("UnlockMapFrame", "UnlockMapFrameBtn", false) -- Unlock map frame
		LeaMapsLC:LockOption("SetMapOpacity", "SetMapOpacityBtn", true) -- Set map opacity
		LeaMapsLC:LockOption("ShowPointsOfInterest", "ShowPointsOfInterestBtn", false) -- Show points of interest
		LeaMapsLC:LockOption("ShowZoneLevels", "ShowZoneLevelsBtn", false) -- Show zone levels
		LeaMapsLC:LockOption("EnhanceBattleMap", "EnhanceBattleMapBtn", true) -- Enhance battlefield map
		-- Ensure locked but enabled options remain locked
		if LeaMapsLC["UseDefaultMap"] == "On" then
			LeaMapsCB["SetMapOpacityBtn"]:Disable()
			LeaMapsCB["UnlockMapFrameBtn"]:Disable()
		end
	end

	-- Create a standard button
	function LeaMapsLC:CreateButton(name, frame, label, anchor, x, y, height, tip)
		local mbtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
		LeaMapsCB[name] = mbtn
		mbtn:SetHeight(height)
		mbtn:SetPoint(anchor, x, y)
		mbtn:SetHitRectInsets(0, 0, 0, 0)
		mbtn:SetText(L[label])

		-- Create fontstring and set button width based on it
		mbtn.f = mbtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		mbtn.f:SetText(L[label])
		mbtn:SetWidth(mbtn.f:GetStringWidth() + 20)

		-- Tooltip handler
		mbtn.tiptext = L[tip]
		mbtn:SetScript("OnEnter", LeaMapsLC.TipSee)
		mbtn:SetScript("OnLeave", GameTooltip_Hide)

		-- Set skinned button textures
		mbtn:SetNormalTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
		mbtn:GetNormalTexture():SetTexCoord(0, 1, 0.25, 0.5)
		mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
		mbtn:GetHighlightTexture():SetTexCoord(0, 1, 0, 0.25)

		-- Hide the default textures
		mbtn:HookScript("OnShow", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnEnable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnDisable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseDown", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseUp", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)

		return mbtn
	end

	-- Create a dropdown menu (using standard dropdown template)
	function LeaMapsLC:CreateDropdown(frame, label, width, anchor, parent, relative, x, y, items)

		local RadioDropdown = CreateFrame("DropdownButton", nil, parent, "WowStyle1DropdownTemplate")
		LeaMapsCB[frame] = RadioDropdown
		RadioDropdown:SetPoint(anchor, parent, relative, x, y)
		RadioDropdown:SetWidth(width)

		local function IsSelected(value)
			return value == LeaMapsLC[frame]
		end

		local function SetSelected(value)
			LeaMapsLC[frame] = value
		end

		MenuUtil.CreateRadioMenu(RadioDropdown, IsSelected, SetSelected, unpack(items))

		if label then
			local lf = RadioDropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal"); lf:SetPoint("TOPLEFT", RadioDropdown, 0, 20); lf:SetPoint("TOPRIGHT", RadioDropdown, -5, 20); lf:SetJustifyH("LEFT"); lf:SetText(L[label])
		end

		return RadioDropdown

	end

	-- Set reload button status
	function LeaMapsLC:ReloadCheck()
		if	(LeaMapsLC["ShowZoneMenu"] ~= LeaMapsDB["ShowZoneMenu"])			-- Show zone menu
		or	(LeaMapsLC["SetMapOpacity"] ~= LeaMapsDB["SetMapOpacity"])			-- Set map opacity
		or	(LeaMapsLC["UseClassIcons"] ~= LeaMapsDB["UseClassIcons"])			-- Use class colors
		or	(LeaMapsLC["StickyMapFrame"] ~= LeaMapsDB["StickyMapFrame"])		-- Sticky map frame
		or	(LeaMapsLC["AutoChangeZones"] ~= LeaMapsDB["AutoChangeZones"])		-- Auto change zones
		or	(LeaMapsLC["UseDefaultMap"] ~= LeaMapsDB["UseDefaultMap"])			-- Use default map
		or	(LeaMapsLC["RevealMap"] ~= LeaMapsDB["RevealMap"])					-- Show unexplored areas
		or	(LeaMapsLC["HideTownCityIcons"] ~= LeaMapsDB["HideTownCityIcons"])	-- Hide town and city icons
		or	(LeaMapsLC["EnhanceBattleMap"] ~= LeaMapsDB["EnhanceBattleMap"])	-- Enhance battlefield map
		then
			-- Enable the reload button
			LeaMapsLC:LockItem(LeaMapsCB["ReloadUIButton"], false)
			LeaMapsCB["ReloadUIButton"].f:Show()
		else
			-- Disable the reload button
			LeaMapsLC:LockItem(LeaMapsCB["ReloadUIButton"], true)
			LeaMapsCB["ReloadUIButton"].f:Hide()
		end
	end

	-- Create a subheading
	function LeaMapsLC:MakeTx(frame, title, x, y)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
		text:SetPoint("TOPLEFT", x, y)
		text:SetText(L[title])
		return text
	end

	-- Create text
	function LeaMapsLC:MakeWD(frame, title, x, y, width)
		local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		text:SetPoint("TOPLEFT", x, y)
		text:SetJustifyH("LEFT")
		text:SetText(L[title])
		if width then
			text:SetWidth(width)
		else
			if text:GetWidth() > 402 then
				text:SetWidth(402)
				text:SetWordWrap(false)
			end
		end
		return text
	end

	-- Create a checkbox control
	function LeaMapsLC:MakeCB(parent, field, caption, x, y, reload, tip)

		-- Create the checkbox
		local Cbox = CreateFrame('CheckButton', nil, parent, "ChatConfigCheckButtonTemplate")
		LeaMapsCB[field] = Cbox
		Cbox:SetPoint("TOPLEFT",x, y)
		Cbox:SetScript("OnEnter", LeaMapsLC.TipSee)
		Cbox:SetScript("OnLeave", GameTooltip_Hide)

		-- Add label and tooltip
		Cbox.f = Cbox:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
		Cbox.f:SetPoint('LEFT', 24, 0)
		if reload then
			-- Checkbox requires UI reload
			Cbox.f:SetText(L[caption] .. "*")
			Cbox.tiptext = L[tip] .. "|n|n* " .. L["Requires UI reload."]
		else
			-- Checkbox does not require UI reload
			Cbox.f:SetText(L[caption])
			Cbox.tiptext = L[tip]
		end

		-- Set label parameters
		Cbox.f:SetJustifyH("LEFT")
		Cbox.f:SetWordWrap(false)

		-- Set maximum label width
		if parent == LeaMapsLC["PageF"] then
			-- Main panel checkbox labels
			if Cbox.f:GetWidth() > 156 then
				Cbox.f:SetWidth(156)
			end
			-- Set checkbox click width
			if Cbox.f:GetStringWidth() > 156 then
				Cbox:SetHitRectInsets(0, -146, 0, 0)
			else
				Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
			end
		else
			-- Configuration panel checkbox labels (other checkboxes either have custom functions or blank labels)
			if Cbox.f:GetWidth() > 322 then
				Cbox.f:SetWidth(322)
			end
			-- Set checkbox click width
			if Cbox.f:GetStringWidth() > 322 then
				Cbox:SetHitRectInsets(0, -312, 0, 0)
			else
				Cbox:SetHitRectInsets(0, -Cbox.f:GetStringWidth() + 4, 0, 0)
			end
		end

		-- Set default checkbox state and click area
		Cbox:SetScript('OnShow', function(self)
			if LeaMapsLC[field] == "On" then
				self:SetChecked(true)
			else
				self:SetChecked(false)
			end
		end)

		-- Process clicks
		Cbox:SetScript('OnClick', function()
			if Cbox:GetChecked() then
				LeaMapsLC[field] = "On"
			else
				LeaMapsLC[field] = "Off"
			end
			LeaMapsLC:SetDim() -- Lock invalid options
			LeaMapsLC:ReloadCheck()
		end)
	end

	-- Create configuration button
	function LeaMapsLC:CfgBtn(name, parent)
		local CfgBtn = CreateFrame("BUTTON", nil, parent)
		LeaMapsCB[name] = CfgBtn
		CfgBtn:SetWidth(20)
		CfgBtn:SetHeight(20)
		CfgBtn:SetPoint("LEFT", parent.f, "RIGHT", 0, 0)

		CfgBtn.t = CfgBtn:CreateTexture(nil, "BORDER")
		CfgBtn.t:SetAllPoints()
		CfgBtn.t:SetTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn.t:SetTexCoord(0, 0.50, 0, 0.50);
		CfgBtn.t:SetVertexColor(1.0, 0.82, 0, 1.0)

		CfgBtn:SetHighlightTexture("Interface\\WorldMap\\Gear_64.png")
		CfgBtn:GetHighlightTexture():SetTexCoord(0, 0.50, 0, 0.50)

		CfgBtn.tiptext = L["Click to configure the settings for this option."]
		CfgBtn:SetScript("OnEnter", LeaMapsLC.ShowTooltip)
		CfgBtn:SetScript("OnLeave", GameTooltip_Hide)
	end

	-- Create a slider control
	function LeaMapsLC:MakeSL(frame, field, label, caption, low, high, step, x, y, form)

		-- Create slider control
		local Slider = CreateFrame("Slider", "LeaMapsGlobalSlider" .. field, frame, "UISliderTemplate")
		LeaMapsCB[field] = Slider
		Slider:SetMinMaxValues(low, high)
		Slider:SetValueStep(step)
		Slider:EnableMouseWheel(true)
		Slider:SetPoint('TOPLEFT', x,y)
		Slider:SetWidth(100)
		Slider:SetHeight(20)
		Slider:SetHitRectInsets(0, 0, 0, 0)
		Slider.tiptext = L[caption]
		Slider:SetScript("OnEnter", LeaMapsLC.TipSee)
		Slider:SetScript("OnLeave", GameTooltip_Hide)

		-- Set label
		local labelfrm = Slider:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		labelfrm:SetPoint("TOP", Slider, "TOP", 0, 12)
		labelfrm:SetText(L[label])

		-- Create slider label
		Slider.f = Slider:CreateFontString(nil, 'BACKGROUND')
		Slider.f:SetFontObject('GameFontHighlight')
		Slider.f:SetPoint('LEFT', Slider, 'RIGHT', 12, 0)
		Slider.f:SetFormattedText("%.2f", Slider:GetValue())

		-- Process mousewheel scrolling
		Slider:SetScript("OnMouseWheel", function(self, arg1)
			if Slider:IsEnabled() then
				local step = step * arg1
				local value = self:GetValue()
				if step > 0 then
					self:SetValue(min(value + step, high))
				else
					self:SetValue(max(value + step, low))
				end
			end
		end)

		-- Process value changed
		Slider:SetScript("OnValueChanged", function(self, value)
			local value = floor((value - low) / step + 0.5) * step + low
			Slider.f:SetFormattedText(form, value)
			LeaMapsLC[field] = value
		end)

		-- Set slider value when shown
		Slider:SetScript("OnShow", function(self)
			self:SetValue(LeaMapsLC[field])
		end)

	end

	----------------------------------------------------------------------
	-- Stop error frame
	----------------------------------------------------------------------

	-- Create stop error frame
	local stopFrame = CreateFrame("FRAME", nil, UIParent)
	stopFrame:ClearAllPoints()
	stopFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	stopFrame:SetSize(370, 150)
	stopFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	stopFrame:SetFrameLevel(500)
	stopFrame:SetClampedToScreen(true)
	stopFrame:EnableMouse(true)
	stopFrame:SetMovable(true)
	stopFrame:Hide()
	stopFrame:RegisterForDrag("LeftButton")
	stopFrame:SetScript("OnDragStart", stopFrame.StartMoving)
	stopFrame:SetScript("OnDragStop", function()
		stopFrame:StopMovingOrSizing()
		stopFrame:SetUserPlaced(false)
	end)

	-- Add background color
	stopFrame.t = stopFrame:CreateTexture(nil, "BACKGROUND")
	stopFrame.t:SetAllPoints()
	stopFrame.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

	-- Add textures
	stopFrame.mt = stopFrame:CreateTexture(nil, "BORDER")
	stopFrame.mt:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	stopFrame.mt:SetSize(370, 103)
	stopFrame.mt:SetPoint("TOPRIGHT")
	stopFrame.mt:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	stopFrame.ft = stopFrame:CreateTexture(nil, "BORDER")
	stopFrame.ft:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	stopFrame.ft:SetSize(370, 48)
	stopFrame.ft:SetPoint("BOTTOM")
	stopFrame.ft:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	LeaMapsLC:MakeTx(stopFrame, "Leatrix Maps", 16, -12)
	LeaMapsLC:MakeWD(stopFrame, "A stop error has occurred but no need to worry.  It can happen from time to time.  Click the reload button to resolve it.", 16, -32, 338)

	-- Add reload UI Button
	local stopRelBtn = LeaMapsLC:CreateButton("StopReloadButton", stopFrame, "Reload", "BOTTOMRIGHT", -16, 10, 25, "")
	stopRelBtn:SetScript("OnClick", ReloadUI)
	stopRelBtn.f = stopRelBtn:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	stopRelBtn.f:SetHeight(32)
	stopRelBtn.f:SetPoint('RIGHT', stopRelBtn, 'LEFT', -10, 0)
	stopRelBtn.f:SetText(L["Your UI needs to be reloaded."])
	stopRelBtn:Hide(); stopRelBtn:Show()

	-- Add close Button
	local stopFrameClose = CreateFrame("Button", nil, stopFrame, "UIPanelCloseButton")
	stopFrameClose:SetSize(30, 30)
	stopFrameClose:SetPoint("TOPRIGHT", 0, 0)

	----------------------------------------------------------------------
	-- L20: Commands
	----------------------------------------------------------------------

	-- Slash command function
	local function SlashFunc(str)
		local str, arg1, arg2, arg3 = strsplit(" ", string.lower(str:gsub("%s+", " ")))
		if str and str ~= "" then
			-- Traverse parameters
			if str == "reset" then
				-- Reset the configuration panel position
				LeaMapsLC["MainPanelA"], LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = "CENTER", "CENTER", 0, 0
				if LeaMapsLC["PageF"]:IsShown() then LeaMapsLC["PageF"]:Hide() LeaMapsLC["PageF"]:Show() end
				return
			elseif str == "wipe" then
				-- Wipe all settings
				wipe(LeaMapsDB)
				LeaMapsLC["NoSaveSettings"] = true
				ReloadUI()
			elseif str == "nosave" then
				-- Prevent Leatrix Maps from overwriting LeaMapsDB at next logout
				LeaMapsLC.EventFrame:UnregisterEvent("PLAYER_LOGOUT")
				LeaMapsLC:Print("Leatrix Maps will not overwrite LeaMapsDB at next logout.")
				return
			elseif str == "setmap" then
				-- Set map to map ID
				arg1 = tonumber(arg1)
				if arg1 and arg1 > 0 and arg1 < 99999 and C_Map.GetMapArtLayers(arg1) then
					WorldMapFrame:SetMapID(arg1)
				else
					LeaMapsLC:Print("Invalid map ID.")
				end
				return
			elseif str == "hadmin" then
				-- List all commands
				LeaMapsLC:Print("reset - Reset panel position")
				LeaMapsLC:Print("wipe - Wipe addon settings")
				LeaMapsLC:Print("setmap <id> - Set map to map ID <id>")
				LeaMapsLC:Print("admin - Load admin settings")
				LeaMapsLC:Print("hadmin - Show admin help")
				LeaMapsLC:Print("help - Show help")
				return
			elseif str == "dbf" then
				-- Show battlefield map for debugging
				if not IsAddOnLoaded("Blizzard_BattlefieldMap") then
					LoadAddOn("Blizzard_BattlefieldMap")
				end
				BattlefieldMapFrame:Show()
				return
			elseif str == "map" then
				-- Set map by ID, print currently showing map ID or print character map ID
				if not arg1 then
					-- Print map ID
					if WorldMapFrame:IsShown() then
						-- Show world map ID
						local mapID = WorldMapFrame.mapID or nil
						local artID = C_Map.GetMapArtID(mapID) or nil
						local mapName = C_Map.GetMapInfo(mapID).name or nil
						if mapID and artID and mapName then
							LeaMapsLC:Print(mapID .. " (" .. artID .. "): " .. mapName .. " (map)")
						end
					else
						-- Show character map ID
						local mapID = C_Map.GetBestMapForUnit("player") or nil
						local artID = C_Map.GetMapArtID(mapID) or nil
						local mapName = C_Map.GetMapInfo(mapID).name or nil
						if mapID and artID and mapName then
							LeaMapsLC:Print(mapID .. " (" .. artID .. "): " .. mapName .. " (player)")
						end
					end
					return
				elseif not tonumber(arg1) or not C_Map.GetMapInfo(arg1) then
					-- Invalid map ID
					LeaMapsLC:Print("Invalid map ID.")
				else
					-- Set map by ID
					WorldMapFrame:SetMapID(tonumber(arg1))
				end
				return
			elseif str == "admin" then
				-- Preset profile (reload required)
				LeaMapsLC["NoSaveSettings"] = true
				wipe(LeaMapsDB)

				-- Mechanics
				LeaMapsDB["ShowZoneMenu"] = "On"
				LeaMapsDB["RememberZoom"] = "On"
				LeaMapsDB["IncreaseZoom"] = "On"
				LeaMapsDB["EnlargePlayerArrow"] = "On"
				LeaMapsDB["PlayerArrowSize"] = 27
				LeaMapsDB["UseClassIcons"] = "On"
				LeaMapsDB["ClassIconSize"] = 27
				LeaMapsDB["UnlockMapFrame"] = "On"
				LeaMapsDB["MapPosA"] = "CENTER"
				LeaMapsDB["MapPosR"] = "CENTER"
				LeaMapsDB["MapPosX"] = 0
				LeaMapsDB["MapPosY"] = 0
				LeaMapsDB["MapScale"] = 0.9
				LeaMapsDB["SetMapOpacity"] = "Off"
				LeaMapsDB["stationaryOpacity"] = 1.0
				LeaMapsDB["movingOpacity"] = 0.5
				LeaMapsDB["NoFadeCursor"] = "On"
				LeaMapsDB["StickyMapFrame"] = "Off"
				LeaMapsDB["AutoChangeZones"] = "Off"
				LeaMapsDB["CenterMapOnPlayer"] = "On"
				LeaMapsDB["UseDefaultMap"] = "Off"

				-- Elements
				LeaMapsDB["RevealMap"] = "On"
				LeaMapsDB["RevTint"] = "On"
				LeaMapsDB["tintRed"] = 0.6
				LeaMapsDB["tintGreen"] = 0.6
				LeaMapsDB["tintBlue"] = 1.0
				LeaMapsDB["tintAlpha"] = 1.0
				LeaMapsDB["ShowPointsOfInterest"] = "On"
				LeaMapsDB["ShowDungeonIcons"] = "On"
				LeaMapsDB["ShowTravelPoints"] = "On"
				LeaMapsDB["ShowTravelOpposing"] = "Off"
				LeaMapsDB["ShowSpiritHealers"] = "On"
				LeaMapsDB["ShowZoneCrossings"] = "On"
				LeaMapsDB["ShowZoneLevels"] = "On"
				LeaMapsDB["ShowFishingLevels"] = "On"
				LeaMapsDB["ShowCoords"] = "On"
				LeaMapsDB["HideTownCityIcons"] = "On"

				-- More
				LeaMapsDB["EnhanceBattleMap"] = "On"
				LeaMapsDB["UnlockBattlefield"] = "On"
				LeaMapsDB["BattleMapSize"] = 300
				LeaMapsDB["BattleCenterOnPlayer"] = "On"
				LeaMapsDB["BattleGroupIconSize"] = 12
				LeaMapsDB["BattlePlayerArrowSize"] = 12
				LeaMapsDB["BattleMapOpacity"] = 1
				LeaMapsDB["BattleMaxZoom"] = 2
				LeaMapsDB["BattleMapA"] = "BOTTOMRIGHT"
				LeaMapsDB["BattleMapR"] = "BOTTOMRIGHT"
				LeaMapsDB["BattleMapX"] = -47
				LeaMapsDB["BattleMapY"] = 83

				LeaMapsDB["ZoneMapMenu"] = 1
				LeaMapsDB["ShowMinimapIcon"] = "On"
				LeaMapsDB["minimapPos"] = 204 -- LeaMapsDB

				ReloadUI()
			elseif str == "help" then
				-- Show available commands
				LeaMapsLC:Print("Leatrix Maps" .. "|n")
				LeaMapsLC:Print(L["Classic"] .. " " .. LeaMapsLC["AddonVer"] .. "|n|n")
				LeaMapsLC:Print("/ltm reset - Reset the panel position.")
				LeaMapsLC:Print("/ltm wipe - Wipe all settings and reload.")
				LeaMapsLC:Print("/ltm help - Show this information.")
				return
			else
				-- Invalid command entered
				LeaMapsLC:Print("Invalid command.  Enter /ltm help for help.")
				return
			end
		else
			-- Prevent options panel from showing if the chat configuration panel is showing
			if ChatConfigFrame:IsShown() then return end
			-- Toggle the options panel
			if LeaMapsLC:IsMapsShowing() then
				LeaMapsLC["PageF"]:Hide()
				LeaMapsLC:HideConfigPanels()
			else
				LeaMapsLC["PageF"]:Show()
			end
		end
	end

	-- Add slash commands
	_G.SLASH_Leatrix_Maps1 = "/ltm"
	_G.SLASH_Leatrix_Maps2 = "/leamaps"
	SlashCmdList["Leatrix_Maps"] = function(self)
		-- Run slash command function
		SlashFunc(self)
		-- Redirect tainted variables
		RunScript('ACTIVE_CHAT_EDIT_BOX = ACTIVE_CHAT_EDIT_BOX')
		RunScript('LAST_ACTIVE_CHAT_EDIT_BOX = LAST_ACTIVE_CHAT_EDIT_BOX')
	end

	----------------------------------------------------------------------
	-- L30: Events
	----------------------------------------------------------------------

	-- Create event frame
	local eFrame = CreateFrame("FRAME")
	LeaMapsLC.EventFrame = eFrame -- Used with nosave command
	eFrame:RegisterEvent("ADDON_LOADED")
	eFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eFrame:RegisterEvent("PLAYER_LOGOUT")
	eFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	eFrame:SetScript("OnEvent", function(self, event, arg1)

		if event == "ADDON_LOADED" and arg1 == "Leatrix_Maps" then

			-- Mechanics
			LeaMapsLC:LoadVarChk("ShowZoneMenu", "On")					-- Show zone menu
			LeaMapsLC:LoadVarChk("RememberZoom", "On")					-- Remember zoom level
			LeaMapsLC:LoadVarChk("IncreaseZoom", "Off")					-- Increase zoom level
			LeaMapsLC:LoadVarNum("IncreaseZoomMax", 2, 1, 6)			-- Increase zoom level maximum
			LeaMapsLC:LoadVarChk("EnlargePlayerArrow", "On")			-- Enlarge player arrow
			LeaMapsLC:LoadVarNum("PlayerArrowSize", 27, 16, 64)			-- Player arrow size
			LeaMapsLC:LoadVarChk("UseClassIcons", "On")					-- Use class icons
			LeaMapsLC:LoadVarNum("ClassIconSize", 20, 20, 80)			-- Class icon size
			LeaMapsLC:LoadVarChk("UnlockMapFrame", "On")				-- Unlock map frame
			LeaMapsLC:LoadVarAnc("MapPosA", "CENTER")					-- Map anchor
			LeaMapsLC:LoadVarAnc("MapPosR", "CENTER")					-- Map relative
			LeaMapsLC:LoadVarNum("MapPosX", 0, -5000, 5000)				-- Map X axis
			LeaMapsLC:LoadVarNum("MapPosY", 20, -5000, 5000)			-- Map Y axis
			LeaMapsLC:LoadVarNum("MapScale", 0.9, 0.2, 3)				-- Map scale
			LeaMapsLC:LoadVarChk("SetMapOpacity", "Off")				-- Set map opacity
			LeaMapsLC:LoadVarNum("stationaryOpacity", 1, 0.1, 1)		-- Stationary opacity
			LeaMapsLC:LoadVarNum("movingOpacity", 0.5, 0.1, 1)			-- Moving opacity
			LeaMapsLC:LoadVarChk("NoFadeCursor", "On")					-- Use stationary opacity
			LeaMapsLC:LoadVarChk("StickyMapFrame", "Off")				-- Sticky map frame
			LeaMapsLC:LoadVarChk("AutoChangeZones", "Off")				-- Auto change zones
			LeaMapsLC:LoadVarChk("CenterMapOnPlayer", "Off")			-- Center map on player
			LeaMapsLC:LoadVarChk("UseDefaultMap", "Off")				-- Use default map

			-- Elements
			LeaMapsLC:LoadVarChk("RevealMap", "On")						-- Reveal unexplored areas
			LeaMapsLC:LoadVarChk("RevTint", "On")						-- Tint revealed unexplored areas
			LeaMapsLC:LoadVarNum("tintRed", 0.6, 0, 1)					-- Tint red
			LeaMapsLC:LoadVarNum("tintGreen", 0.6, 0, 1)				-- Tint green
			LeaMapsLC:LoadVarNum("tintBlue", 1, 0, 1)					-- Tint blue
			LeaMapsLC:LoadVarNum("tintAlpha", 1, 0, 1)					-- Tint opacity
			LeaMapsLC:LoadVarChk("ShowPointsOfInterest", "On")			-- Show points of interest
			LeaMapsLC:LoadVarChk("ShowDungeonIcons", "On")				-- Show dungeons and raids
			LeaMapsLC:LoadVarChk("ShowTravelPoints", "On")				-- Show travel points for same faction
			LeaMapsLC:LoadVarChk("ShowTravelOpposing", "Off")			-- Show travel points for opposing faction
			LeaMapsLC:LoadVarChk("ShowSpiritHealers", "On")				-- Show spirit healers
			LeaMapsLC:LoadVarChk("ShowZoneCrossings", "On")				-- Show zone crossings
			LeaMapsLC:LoadVarChk("ShowZoneLevels", "On")				-- Show zone levels
			LeaMapsLC:LoadVarChk("ShowFishingLevels", "On")				-- Show fishing levels
			LeaMapsLC:LoadVarChk("ShowCoords", "On")					-- Show coordinates
			LeaMapsLC:LoadVarChk("HideTownCityIcons", "On")				-- Hide town and city icons

			-- More
			LeaMapsLC:LoadVarChk("EnhanceBattleMap", "Off")				-- Enhance battlefield map
			LeaMapsLC:LoadVarChk("UnlockBattlefield", "On")				-- Unlock battlefield map
			LeaMapsLC:LoadVarNum("BattleMapSize", 300, 150, 1200)		-- Resize battlefield map
			LeaMapsLC:LoadVarChk("BattleCenterOnPlayer", "Off")			-- Center map on player
			LeaMapsLC:LoadVarNum("BattleGroupIconSize", 12, 12, 48)		-- Battlefield group icon size
			LeaMapsLC:LoadVarNum("BattlePlayerArrowSize", 12, 12, 48)	-- Battlefield player arrow size
			LeaMapsLC:LoadVarNum("BattleMapOpacity", 1, 0.1, 1)			-- Battlefield map opacity
			LeaMapsLC:LoadVarNum("BattleMaxZoom", 1, 1, 6)				-- Battlefield map zoom
			LeaMapsLC:LoadVarAnc("BattleMapA", "BOTTOMRIGHT")			-- Battlefield map anchor
			LeaMapsLC:LoadVarAnc("BattleMapR", "BOTTOMRIGHT")			-- Battlefield map relative
			LeaMapsLC:LoadVarNum("BattleMapX", -47, -5000, 5000)		-- Battlefield map X axis
			LeaMapsLC:LoadVarNum("BattleMapY", 83, -5000, 5000)			-- Battlefield map Y axis

			LeaMapsLC:LoadVarNum("ZoneMapMenu", 1, 1, 3)				-- Zone map dropdown menu
			LeaMapsLC:LoadVarChk("ShowMinimapIcon", "On")				-- Show minimap button

			-- Panel
			LeaMapsLC:LoadVarAnc("MainPanelA", "CENTER")				-- Panel anchor
			LeaMapsLC:LoadVarAnc("MainPanelR", "CENTER")				-- Panel relative
			LeaMapsLC:LoadVarNum("MainPanelX", 0, -5000, 5000)			-- Panel X axis
			LeaMapsLC:LoadVarNum("MainPanelY", 0, -5000, 5000)			-- Panel Y axis

			LeaMapsLC:SetDim()

			-- Set initial minimum button position
			if not LeaMapsDB["minimapPos"] then
				LeaMapsDB["minimapPos"] = 204
			end

			-- Lock conflicting options
			do

				-- Function to disable and lock an option and add a note to the tooltip
				local function Lock(option, reason, optmodule)
					LeaLockList[option] = LeaMapsLC[option]
					LeaMapsLC:LockItem(LeaMapsCB[option], true)
					LeaMapsCB[option].tiptext = LeaMapsCB[option].tiptext .. "|n|n|cff00AAFF" .. reason
					if optmodule then
						LeaMapsCB[option].tiptext = LeaMapsCB[option].tiptext .. " " .. optmodule .. " " .. L["module"]
					end
					LeaMapsCB[option].tiptext = LeaMapsCB[option].tiptext .. "."
					-- Remove hover from configuration button if there is one
					local temp = {LeaMapsCB[option]:GetChildren()}
					if temp and temp[1] and temp[1].t and temp[1].t:GetTexture() == "Interface\\WorldMap\\Gear_64.png" then
						temp[1]:SetHighlightTexture(0)
						temp[1]:SetScript("OnEnter", nil)
					end
				end

				-- Disable items that conflict with ElvUI
				if LeaMapsLC.ElvUI then
					local E = LeaMapsLC.ElvUI
					if E and E.private then
						local reason = L["Cannot be used with ElvUI"]
						if E.private.general.worldMap then
							Lock("SetMapOpacity", reason, "Maps") -- Set map opacity
						end
						EnableAddOn("Leatrix_Maps")
					end
				end
			end

			-- Lock and disable use default map option due to a bug in the game which prevents map movement
			LeaMapsLC:LockItem(LeaMapsCB["UseDefaultMap"], true)
			LeaMapsCB["UseDefaultMap"].tiptext = LeaMapsCB["UseDefaultMap"].tiptext .. "|n|n|cff00AAFF" .. "This setting cannot be used at the moment."
			LeaMapsLC["UseDefaultMap"] = "Off"
			LeaMapsDB["UseDefaultMap"] = "Off"

		elseif event == "PLAYER_ENTERING_WORLD" then
			-- Run main function
			LeaMapsLC:MainFunc()
			eFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")

		elseif event == "PLAYER_LOGOUT" and not LeaMapsLC["NoSaveSettings"] then
			-- Mechanics
			LeaMapsDB["ShowZoneMenu"] = LeaMapsLC["ShowZoneMenu"]
			LeaMapsDB["RememberZoom"] = LeaMapsLC["RememberZoom"]
			LeaMapsDB["IncreaseZoom"] = LeaMapsLC["IncreaseZoom"]
			LeaMapsDB["IncreaseZoomMax"] = LeaMapsLC["IncreaseZoomMax"]
			LeaMapsDB["EnlargePlayerArrow"] = LeaMapsLC["EnlargePlayerArrow"]
			LeaMapsDB["PlayerArrowSize"] = LeaMapsLC["PlayerArrowSize"]
			LeaMapsDB["UseClassIcons"] = LeaMapsLC["UseClassIcons"]
			LeaMapsDB["ClassIconSize"] = LeaMapsLC["ClassIconSize"]
			LeaMapsDB["UnlockMapFrame"] = LeaMapsLC["UnlockMapFrame"]
			LeaMapsDB["MapPosA"] = LeaMapsLC["MapPosA"]
			LeaMapsDB["MapPosR"] = LeaMapsLC["MapPosR"]
			LeaMapsDB["MapPosX"] = LeaMapsLC["MapPosX"]
			LeaMapsDB["MapPosY"] = LeaMapsLC["MapPosY"]
			LeaMapsDB["MapScale"] = LeaMapsLC["MapScale"]
			LeaMapsDB["SetMapOpacity"] = LeaMapsLC["SetMapOpacity"]
			LeaMapsDB["stationaryOpacity"] = LeaMapsLC["stationaryOpacity"]
			LeaMapsDB["movingOpacity"] = LeaMapsLC["movingOpacity"]
			LeaMapsDB["NoFadeCursor"] = LeaMapsLC["NoFadeCursor"]
			LeaMapsDB["StickyMapFrame"] = LeaMapsLC["StickyMapFrame"]
			LeaMapsDB["AutoChangeZones"] = LeaMapsLC["AutoChangeZones"]
			LeaMapsDB["CenterMapOnPlayer"] = LeaMapsLC["CenterMapOnPlayer"]
			LeaMapsDB["UseDefaultMap"] = LeaMapsLC["UseDefaultMap"]

			-- Elements
			LeaMapsDB["RevealMap"] = LeaMapsLC["RevealMap"]
			LeaMapsDB["RevTint"] = LeaMapsLC["RevTint"]
			LeaMapsDB["tintRed"] = LeaMapsLC["tintRed"]
			LeaMapsDB["tintGreen"] = LeaMapsLC["tintGreen"]
			LeaMapsDB["tintBlue"] = LeaMapsLC["tintBlue"]
			LeaMapsDB["tintAlpha"] = LeaMapsLC["tintAlpha"]
			LeaMapsDB["ShowPointsOfInterest"] = LeaMapsLC["ShowPointsOfInterest"]
			LeaMapsDB["ShowDungeonIcons"] = LeaMapsLC["ShowDungeonIcons"]
			LeaMapsDB["ShowTravelPoints"] = LeaMapsLC["ShowTravelPoints"]
			LeaMapsDB["ShowTravelOpposing"] = LeaMapsLC["ShowTravelOpposing"]
			LeaMapsDB["ShowSpiritHealers"] = LeaMapsLC["ShowSpiritHealers"]
			LeaMapsDB["ShowZoneCrossings"] = LeaMapsLC["ShowZoneCrossings"]
			LeaMapsDB["ShowZoneLevels"] = LeaMapsLC["ShowZoneLevels"]
			LeaMapsDB["ShowFishingLevels"] = LeaMapsLC["ShowFishingLevels"]
			LeaMapsDB["ShowCoords"] = LeaMapsLC["ShowCoords"]
			LeaMapsDB["HideTownCityIcons"] = LeaMapsLC["HideTownCityIcons"]

			-- More
			LeaMapsDB["EnhanceBattleMap"] = LeaMapsLC["EnhanceBattleMap"]
			LeaMapsDB["UnlockBattlefield"] = LeaMapsLC["UnlockBattlefield"]
			LeaMapsDB["BattleMapSize"] = LeaMapsLC["BattleMapSize"]
			LeaMapsDB["BattleCenterOnPlayer"] = LeaMapsLC["BattleCenterOnPlayer"]
			LeaMapsDB["BattleGroupIconSize"] = LeaMapsLC["BattleGroupIconSize"]
			LeaMapsDB["BattlePlayerArrowSize"] = LeaMapsLC["BattlePlayerArrowSize"]
			LeaMapsDB["BattleMapOpacity"] = LeaMapsLC["BattleMapOpacity"]
			LeaMapsDB["BattleMaxZoom"] = LeaMapsLC["BattleMaxZoom"]
			LeaMapsDB["BattleMapA"] = LeaMapsLC["BattleMapA"]
			LeaMapsDB["BattleMapR"] = LeaMapsLC["BattleMapR"]
			LeaMapsDB["BattleMapX"] = LeaMapsLC["BattleMapX"]
			LeaMapsDB["BattleMapY"] = LeaMapsLC["BattleMapY"]

			LeaMapsDB["ZoneMapMenu"] = LeaMapsLC["ZoneMapMenu"]
			LeaMapsDB["ShowMinimapIcon"] = LeaMapsLC["ShowMinimapIcon"]

			-- Panel
			LeaMapsDB["MainPanelA"] = LeaMapsLC["MainPanelA"]
			LeaMapsDB["MainPanelR"] = LeaMapsLC["MainPanelR"]
			LeaMapsDB["MainPanelX"] = LeaMapsLC["MainPanelX"]
			LeaMapsDB["MainPanelY"] = LeaMapsLC["MainPanelY"]

		elseif event == "ADDON_ACTION_FORBIDDEN" and arg1 == "Leatrix_Maps" then
			-- Stop error has occured
			StaticPopup_Hide("ADDON_ACTION_FORBIDDEN")
			stopFrame:Show()

		end
	end)

	----------------------------------------------------------------------
	-- L40: Panel
	----------------------------------------------------------------------

	-- Create the panel
	local PageF = CreateFrame("Frame", nil, UIParent)

	-- Make it a system frame
	_G["LeaMapsGlobalPanel"] = PageF
	table.insert(UISpecialFrames, "LeaMapsGlobalPanel")

	-- Set frame parameters
	LeaMapsLC["PageF"] = PageF
	PageF:SetSize(470, 480)
	PageF:Hide()
	PageF:SetFrameStrata("FULLSCREEN_DIALOG")
	PageF:SetFrameLevel(20)
	PageF:SetClampedToScreen(true)
	PageF:EnableMouse(true)
	PageF:SetMovable(true)
	PageF:RegisterForDrag("LeftButton")
	PageF:SetScript("OnDragStart", PageF.StartMoving)
	PageF:SetScript("OnDragStop", function()
		PageF:StopMovingOrSizing()
		PageF:SetUserPlaced(false)
		-- Save panel position
		LeaMapsLC["MainPanelA"], void, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"] = PageF:GetPoint()
	end)

	-- Add background color
	PageF.t = PageF:CreateTexture(nil, "BACKGROUND")
	PageF.t:SetAllPoints()
	PageF.t:SetColorTexture(0.05, 0.05, 0.05, 0.9)

	-- Add textures
	local MainTexture = PageF:CreateTexture(nil, "BORDER")
	MainTexture:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	MainTexture:SetSize(470, 433)
	MainTexture:SetPoint("TOPRIGHT")
	MainTexture:SetVertexColor(0.7, 0.7, 0.7, 0.7)
	MainTexture:SetTexCoord(0.09, 1, 0, 1)

	local FootTexture = PageF:CreateTexture(nil, "BORDER")
	FootTexture:SetTexture("Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")
	FootTexture:SetSize(470, 48)
	FootTexture:SetPoint("BOTTOM")
	FootTexture:SetVertexColor(0.5, 0.5, 0.5, 1.0)

	-- Set panel position when shown
	PageF:SetScript("OnShow", function()
		PageF:ClearAllPoints()
		PageF:SetPoint(LeaMapsLC["MainPanelA"], UIParent, LeaMapsLC["MainPanelR"], LeaMapsLC["MainPanelX"], LeaMapsLC["MainPanelY"])
	end)

	-- Add main title
	PageF.mt = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	PageF.mt:SetPoint('TOPLEFT', 16, -16)
	PageF.mt:SetText("Leatrix Maps")

	-- Add version text
	PageF.v = PageF:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	PageF.v:SetHeight(32)
	PageF.v:SetPoint('TOPLEFT', PageF.mt, 'BOTTOMLEFT', 0, -8)
	PageF.v:SetPoint('RIGHT', PageF, -32, 0)
	PageF.v:SetJustifyH('LEFT'); PageF.v:SetJustifyV('TOP')
	PageF.v:SetNonSpaceWrap(true); PageF.v:SetText(L["Classic"] .. " " .. LeaMapsLC["AddonVer"])

	-- Add reload UI Button
	local reloadb = LeaMapsLC:CreateButton("ReloadUIButton", PageF, "Reload", "BOTTOMRIGHT", -16, 10, 25, "Your UI needs to be reloaded for some of the changes to take effect.|n|nYou don't have to click the reload button immediately but you do need to click it when you are done making changes and you want the changes to take effect.")
	LeaMapsLC:LockItem(reloadb, true)
	reloadb:SetScript("OnClick", ReloadUI)

	reloadb.f = reloadb:CreateFontString(nil, 'ARTWORK', 'GameFontNormalSmall')
	reloadb.f:SetHeight(32)
	reloadb.f:SetPoint('RIGHT', reloadb, 'LEFT', -10, 0)
	reloadb.f:SetText(L["Your UI needs to be reloaded."])
	reloadb.f:Hide()

	-- Add close Button
	local CloseB = CreateFrame("Button", nil, PageF, "UIPanelCloseButton")
	CloseB:SetSize(30, 30)
	CloseB:SetPoint("TOPRIGHT", 0, 0)

	-- Add content
	LeaMapsLC:MakeTx(PageF, "Appearance", 16, -72)
	LeaMapsLC:MakeCB(PageF, "ShowZoneMenu", "Show zone menus", 16, -92, true, "If checked, zone and continent dropdown menus will be shown in the map frame.")
	LeaMapsLC:MakeCB(PageF, "SetMapOpacity", "Set map opacity", 16, -112, true, "If checked, you will be able to set the opacity of the map.")

	LeaMapsLC:MakeTx(PageF, "Icons", 16, -152)
	LeaMapsLC:MakeCB(PageF, "EnlargePlayerArrow", "Enlarge player arrow", 16, -172, false, "If checked, you will be able to enlarge the player arrow.")
	LeaMapsLC:MakeCB(PageF, "UseClassIcons", "Class colored icons", 16, -192, true, "If checked, group icons will use a modern, class-colored design.")

	LeaMapsLC:MakeTx(PageF, "Zoom", 16, -232)
	LeaMapsLC:MakeCB(PageF, "RememberZoom", "Remember zoom level", 16, -252, false, "If checked, opening the map will use the same zoom level from when you last closed it as long as the map zone has not changed.")
	LeaMapsLC:MakeCB(PageF, "IncreaseZoom", "Increase zoom level", 16, -272, false, "If checked, you will be able to zoom further into the world map.")
	LeaMapsLC:MakeCB(PageF, "CenterMapOnPlayer", "Center map on player", 16, -292, false, "If checked, the map will stay centered on your location as long as you are not in a dungeon.|n|nYou can hold shift while panning the map to temporarily prevent it from centering.")

	LeaMapsLC:MakeTx(PageF, "System", 225, -72)
	LeaMapsLC:MakeCB(PageF, "UnlockMapFrame", "Unlock map frame", 225, -92, false, "If checked, you will be able to scale and move the map.|n|nScale the map by dragging the scale handle in the bottom-right corner.|n|nMove the map by dragging the border and frame edges.")
	LeaMapsLC:MakeCB(PageF, "AutoChangeZones", "Auto change zones", 225, -112, true, "If checked, when your character changes zones, the map will automatically change to the new zone.")
	LeaMapsLC:MakeCB(PageF, "StickyMapFrame", "Sticky map frame", 225, -132, true, "If checked, the map frame will remain open until you close it.")
	LeaMapsLC:MakeCB(PageF, "UseDefaultMap", "Use default map", 225, -152, true, "If checked, the default fullscreen map will be used.|n|nNote that enabling this option will lock out some of the other options.")

	LeaMapsLC:MakeTx(PageF, "Elements", 225, -192)
	LeaMapsLC:MakeCB(PageF, "RevealMap", "Show unexplored areas", 225, -212, true, "If checked, unexplored areas of the map will be shown on the world map and the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "ShowPointsOfInterest", "Show points of interest", 225, -232, false, "If checked, points of interest will be shown.")
	LeaMapsLC:MakeCB(PageF, "ShowZoneLevels", "Show zone levels", 225, -252, false, "If checked, zone, dungeon and fishing skill levels will be shown.")
	LeaMapsLC:MakeCB(PageF, "ShowCoords", "Show coordinates", 225, -272, false, "If checked, coordinates will be shown.")
	LeaMapsLC:MakeCB(PageF, "HideTownCityIcons", "Hide town and city icons", 225, -292, true, "If checked, town and city icons will not be shown on the continent maps.")

	LeaMapsLC:MakeTx(PageF, "More", 225, -332)
	LeaMapsLC:MakeCB(PageF, "EnhanceBattleMap", "Enhance battlefield map", 225, -352, true, "If checked, you will be able to customise the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "ShowMinimapIcon", "Show minimap button", 225, -372, false, "If checked, the minimap button will be shown.")

	LeaMapsLC:CfgBtn("IncreaseZoomBtn", LeaMapsCB["IncreaseZoom"])
	LeaMapsLC:CfgBtn("RevTintBtn", LeaMapsCB["RevealMap"])
	LeaMapsLC:CfgBtn("EnlargePlayerArrowBtn", LeaMapsCB["EnlargePlayerArrow"])
	LeaMapsLC:CfgBtn("UseClassIconsBtn", LeaMapsCB["UseClassIcons"])
	LeaMapsLC:CfgBtn("UnlockMapFrameBtn", LeaMapsCB["UnlockMapFrame"])
	LeaMapsLC:CfgBtn("SetMapOpacityBtn", LeaMapsCB["SetMapOpacity"])
	LeaMapsLC:CfgBtn("ShowPointsOfInterestBtn", LeaMapsCB["ShowPointsOfInterest"])
	LeaMapsLC:CfgBtn("ShowZoneLevelsBtn", LeaMapsCB["ShowZoneLevels"])
	LeaMapsLC:CfgBtn("EnhanceBattleMapBtn", LeaMapsCB["EnhanceBattleMap"])

	-- Add reset map position button
	local resetMapPosBtn = LeaMapsLC:CreateButton("resetMapPosBtn", PageF, "Reset Map Layout", "BOTTOMLEFT", 16, 10, 25, "Click to reset the position and scale of the map frame.")
	resetMapPosBtn:HookScript("OnClick", function()
		if not WorldMapFrame:IsMaximized() then
			-- Reset map position
			LeaMapsLC["MapPosA"], LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = "CENTER", "CENTER", 0, 20
			WorldMapFrame:ClearAllPoints()
			WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
			WorldMapTitleButton_OnDragStop()
			-- Reset map scale
			LeaMapsLC["MapScale"] = 1
			LeaMapsLC:SetDim()
			LeaMapsLC["PageF"]:Hide(); LeaMapsLC["PageF"]:Show()
			WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
			WorldMapFrame:OnFrameSizeChanged()
		end
	end)
