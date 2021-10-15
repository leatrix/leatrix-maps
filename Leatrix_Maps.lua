
	----------------------------------------------------------------------
	-- 	Leatrix Maps 9.1.15.alpha.6 (15th October 2021)
	----------------------------------------------------------------------

	-- 10:Func, 20:Comm, 30:Evnt, 40:Panl

	-- Create global table
	_G.LeaMapsDB = _G.LeaMapsDB or {}

	-- Create local tables
	local LeaMapsLC, LeaMapsCB, LeaConfigList = {}, {}, {}

	-- Version
	LeaMapsLC["AddonVer"] = "9.1.15.alpha.6"

	-- Get locale table
	local void, Leatrix_Maps = ...
	local L = Leatrix_Maps.L

	-- Check Wow version is valid
	do
		local gameversion, gamebuild, gamedate, gametocversion = GetBuildInfo()
		if gametocversion and gametocversion < 90000 then
			-- Game client is Wow Classic
			C_Timer.After(2, function()
				print(L["LEATRIX MAPS: WRONG VERSION INSTALLED!"])
			end)
			return
		end
	end

	----------------------------------------------------------------------
	-- L00: Leatrix Maps
	----------------------------------------------------------------------

	-- Main function
	function LeaMapsLC:MainFunc()

		-- Load Battlefield addon
		if not IsAddOnLoaded("Blizzard_BattlefieldMap") then
			RunScript('UIParentLoadAddOn("Blizzard_BattlefieldMap")')
		end

		-- Get player faction
		local playerFaction = UnitFactionGroup("player")

		-- Remove blackout frame
		WorldMapFrame.BlackoutFrame:SetAlpha(0)
		WorldMapFrame.BlackoutFrame:EnableMouse(false)

		-- Hide the world map tutorial button
		WorldMapFrame.BorderFrame.Tutorial:HookScript("OnShow", WorldMapFrame.BorderFrame.Tutorial.Hide)
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)

		-- Replace function to account for frame scale (needs to be here because map is scaled regardless of unlock map frame)
		WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
			local x,y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
			local s = WorldMapFrame:GetScale()
			return x/s, y/s
		end

		----------------------------------------------------------------------
		-- Enhance battlefield map
		----------------------------------------------------------------------

		if LeaMapsLC["EnhanceBattleMap"] == "On" then

			-- Show teammates
			RunScript('BattlefieldMapOptions.showPlayers = true')

			-- Create configuraton panel
			local battleFrame = LeaMapsLC:CreatePanel("Enhance battlefield map", "battleFrame")

			-- Add controls
			LeaMapsLC:MakeTx(battleFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(battleFrame, "UnlockBattlefield", "Unlock battlefield map", 16, -92, false, "If checked, you can move the battlefield map by dragging any of its borders.|n|nYou can resize the battlefield map by dragging the bottom-right corner.")
			LeaMapsLC:MakeCB(battleFrame, "BattleCenterOnPlayer", "Center map on player", 16, -112, false, "If checked, the battlefield map will stay centered on your location as long as you are not dragging the map or in a dungeon.")

			LeaMapsLC:MakeSL(battleFrame, "BattleGroupIconSize", "Group Icons", "Drag to set the group icon size.", 8, 16, 1, 206, -172, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattlePlayerArrowSize", "Player Arrow", "Drag to set the player arrow size.", 12, 24, 1, 36, -172, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleMapOpacity", "Map Opacity", "Drag to set the battlefield map opacity.", 0.1, 1, 0.1, 36, -232, "%.0f")

			-- Add preview texture
			local prevIcon = battleFrame:CreateTexture(nil, "ARTWORK")
			prevIcon:SetPoint("CENTER", battleFrame, "TOPLEFT", 400, -182)
			prevIcon:SetTexture("Interface\\MINIMAP\\partyraidblipsv2")
			prevIcon:SetTexCoord(0.015625, 0.3125, 0.03125, 0.59375)
			prevIcon:SetSize(19, 18)
			prevIcon:SetVertexColor(0.78, 0.61, 0.43, 1)

			-- Hide battlefield tab button
			hooksecurefunc(BattlefieldMapTab, "Show", function() BattlefieldMapTab:Hide() end)

			-- Fix tab frame strata so it matches the battlefield map frame
			BattlefieldMapTab:SetFrameStrata(BattlefieldMapFrame:GetFrameStrata())

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
			-- Resize battlefield map
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
						if BattlefieldMapFrame:GetWidth() > 900 then BattlefieldMapFrame:SetWidth(900) end
						if BattlefieldMapFrame:GetWidth() < 150 then BattlefieldMapFrame:SetWidth(150) end
						BattlefieldMapFrame:SetHeight(BattlefieldMapFrame:GetWidth() / 1.5)
						if mapTime > 0.5 or mapTime == -1 then
							BattlefieldMapFrame:OnFrameSizeChanged()
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
					LeaMapsLC["BattleMapWidth"] = BattlefieldMapFrame:GetWidth()
					LeaMapsLC["BattleMapA"], void, LeaMapsLC["BattleMapR"], LeaMapsLC["BattleMapX"], LeaMapsLC["BattleMapY"] = BattlefieldMapFrame:GetPoint()
				end)

				-- Function to set scale handle
				local function SetScaleHandle()
					if LeaMapsLC["UnlockBattlefield"] == "On" then
						scaleHandle:Show(); scaleMouse:Show()
					else
						scaleHandle:Hide(); scaleMouse:Hide()
					end
					BattlefieldMapFrame:SetWidth(LeaMapsLC["BattleMapWidth"])
					BattlefieldMapFrame:SetHeight(LeaMapsLC["BattleMapWidth"] / 1.5)
					BattlefieldMapFrame:OnFrameSizeChanged()
				end

				-- Set scale handle when option is clicked and on startup
				LeaMapsCB["UnlockBattlefield"]:HookScript("OnClick", SetScaleHandle)
				SetScaleHandle()

				-- Hook reset button click
				battleFrame.r:HookScript("OnClick", function()
					LeaMapsLC["BattleMapWidth"] = 300
					SetScaleHandle()
					battleFrame:Hide(); battleFrame:Show()
				end)

				-- Hook configuration panel for preset profile
				LeaMapsCB["EnhanceBattleMapBtn"]:HookScript("OnClick", function()
					if IsShiftKeyDown() and IsControlKeyDown() then
						-- Preset profile
						LeaMapsLC["BattleMapWidth"] = 300
						SetScaleHandle()
						if battleFrame:IsShown() then battleFrame:Hide(); battleFrame:Show(); end
					end
				end)

			end

			----------------------------------------------------------------------
			-- Center map on player
			----------------------------------------------------------------------

			do

				local cTime = -1

				-- Function to update map
				local function cUpdate(self, elapsed)
					if cTime > 2 or cTime == -1 then
						if IsMouseButtonDown("LeftButton") and BattlefieldMapFrame.ScrollContainer:IsMouseOver() then return end
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

				-- Update location immediately when map is shown
				BattlefieldMapFrame:HookScript("OnShow", function()
					if LeaMapsLC["BattleCenterOnPlayer"] == "On" then
						cTime = -1
					end
				end)

			end

			----------------------------------------------------------------------
			-- Map opacity
			----------------------------------------------------------------------

			local function DoMapOpacity()
				LeaMapsCB["BattleMapOpacity"].f:SetFormattedText("%.0f%%", LeaMapsLC["BattleMapOpacity"] * 100)
				BattlefieldMapOptions.opacity = 1 - LeaMapsLC["BattleMapOpacity"]
				RunScript('BattlefieldMapFrame:RefreshAlpha()')
			end

			-- Set opacity when slider is changed and on startup
			LeaMapsCB["BattleMapOpacity"]:HookScript("OnValueChanged", DoMapOpacity)
			DoMapOpacity()

			----------------------------------------------------------------------
			-- Player arrow
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
			-- Group icons
			----------------------------------------------------------------------

			-- Function to set group icons
			local function FixGroupPin()
				for pin in BattlefieldMapFrame:EnumerateAllPins() do
					if pin.UpdateAppearanceData then

						-- Icons should be under the player arrow
						pin:SetAppearanceField("party", "sublevel", 0)
						pin:SetAppearanceField("raid", "sublevel", 0)

						-- Icon size
						local bfUnitPinSizes = pin.dataProvider:GetUnitPinSizesTable()
						bfUnitPinSizes.party = LeaMapsLC["BattleGroupIconSize"]
						bfUnitPinSizes.raid = LeaMapsLC["BattleGroupIconSize"]
						pin:SynchronizePinSizes()

					end
				end
			end

			-- Function to refresh size slider and update battlefield map
			local function SetIconSize()
				LeaMapsCB["BattleGroupIconSize"].f:SetText(LeaMapsLC["BattleGroupIconSize"] .. " (" .. string.format("%.0f%%", LeaMapsLC["BattleGroupIconSize"] / 8 * 100) .. ")")
				FixGroupPin()
				prevIcon:SetSize(LeaMapsLC["BattleGroupIconSize"], LeaMapsLC["BattleGroupIconSize"])
			end

			-- Set group icons when option is changed and on startup
			LeaMapsCB["BattleGroupIconSize"]:HookScript("OnValueChanged", SetIconSize)
			FixGroupPin()

			----------------------------------------------------------------------
			-- Rest of configuration panel
			----------------------------------------------------------------------

			-- Back to Main Menu button click
			battleFrame.b:HookScript("OnClick", function()
				battleFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			battleFrame.r:HookScript("OnClick", function()
				LeaMapsLC["UnlockBattlefield"] = "On"
				LeaMapsLC["BattleMapWidth"] = 300
				LeaMapsLC["BattleGroupIconSize"] = 8
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
					LeaMapsLC["BattleMapWidth"] = 300
					LeaMapsLC["BattleGroupIconSize"] = 8
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
		-- Hide town and city icons
		----------------------------------------------------------------------

		if LeaMapsLC["HideTownCity"] == "On" then
			hooksecurefunc(BaseMapPoiPinMixin, "OnAcquired", function(self)
				local wmapID = WorldMapFrame.mapID
				if wmapID then
					local minfo = C_Map.GetMapInfo(wmapID)
					if minfo then
						local mType = minfo.mapType
						if mType then
							if mType == 1 or mType == 2 then
								-- Map type is world or continent
								if self.Texture and self.Texture:GetTexture() == 136441 then 
									local a, b, c, d, e, f, g, h = self.Texture:GetTexCoord()
									if a == 0.35546875 and b == 0.001953125 and c == 0.35546875 and d == 0.03515625 and e == 0.421875 and f == 0.001953125 and g == 0.421875 and h == 0.03515625 then
										-- Hide home icons
										self:Hide()
									elseif a == 0.28515625 and b == 0.107421875 and c == 0.28515625 and d == 0.140625 and e == 0.3515625 and f == 0.107421875 and g == 0.3515625 and h == 0.140625 then
										-- Hide faction icons
										self:Hide()
										-- Hide city icons
									elseif a == 0.42578125 and b == 0.107421875 and c == 0.42578125 and d == 0.140625 and e == 0.4921875 and f == 0.107421875 and g == 0.4921875 and h == 0.140625 then
										self:Hide()
									end
								end
							end
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
					if IsMouseButtonDown("LeftButton") and WorldMapFrame.ScrollContainer:IsMouseOver() then return end
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

			-- Update location immediately when map is shown
			WorldMapFrame:HookScript("OnShow", function()
				if LeaMapsLC["CenterMapOnPlayer"] == "On" then
					cTime = -1
				end
			end)

		end

		----------------------------------------------------------------------
		-- Show coordinates
		----------------------------------------------------------------------

		do

			-- Create background frame
			local cFrame = CreateFrame("FRAME", nil, WorldMapFrame.ScrollContainer)
			cFrame:SetSize(WorldMapFrame:GetWidth(), 17)
			cFrame:SetPoint("BOTTOMLEFT", 17)
			cFrame:SetPoint("BOTTOMRIGHT", 0)

			cFrame.t = cFrame:CreateTexture(nil, "BACKGROUND")
			cFrame.t:SetAllPoints()
			cFrame.t:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
			cFrame.t:SetVertexColor(0, 0, 0, 0.5)

			-- Create cursor coordinates frame
			local cCursor = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
			cCursor:SetSize(200, 16)
			cCursor:SetParent(cFrame)
			cCursor:ClearAllPoints()
			cCursor:SetPoint("BOTTOMLEFT", 152, 1)
			cCursor.x = cCursor:CreateFontString(nil, "ARTWORK", "GameFontNormal") 
			cCursor.x:SetJustifyH"LEFT"
			cCursor.x:SetAllPoints()
			cCursor.x:SetText(L["Cursor"] .. ": 88.8, 88.8")
			cCursor:SetWidth(cCursor.x:GetStringWidth() + 50)

			-- Create player coordinates frame
			local cPlayer = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer)
			cPlayer:SetSize(200, 16)
			cPlayer:SetParent(cFrame)
			cPlayer:ClearAllPoints()
			cPlayer:SetPoint("BOTTOMRIGHT", -132, 1)
			cPlayer.x = cPlayer:CreateFontString(nil, "ARTWORK", "GameFontNormal") 
			cPlayer.x:SetJustifyH"LEFT"
			cPlayer.x:SetAllPoints()
			cPlayer.x:SetText(L["Player"] .. ": 88.8, 88.8")
			cPlayer:SetWidth(cPlayer.x:GetStringWidth() + 50)

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

			-- Function to show or hide coordinates frames
			local function SetupCoords()
				if LeaMapsLC["ShowCoords"] == "On" then	cFrame:Show() else cFrame:Hide() end
			end

			LeaMapsCB["ShowCoords"]:HookScript("OnClick", SetupCoords)
			SetupCoords()

			-- Create configuration panel
			local cPanel = LeaMapsLC:CreatePanel("Show coordinates", "cPanel")

			-- Add controls
			LeaMapsLC:MakeTx(cPanel, "Settings", 16, -72)
			LeaMapsLC:MakeCB(cPanel, "CoordsLargeFont", "Use large font", 16, -92, false, "If checked, coordinates will use a large font.")
			LeaMapsLC:MakeCB(cPanel, "CoordsBackground", "Show background", 16, -112, false, "If checked, coordinates will have a dark background texture.")

			-- Function to apply settings
			local function SetCoordFunc()
				if LeaMapsLC["CoordsLargeFont"] == "On" then
					cCursor.x:SetFont(cCursor.x:GetFont(), 16)
					cPlayer.x:SetFont(cPlayer.x:GetFont(), 16)
				else
					cCursor.x:SetFont(cCursor.x:GetFont(), 12)
					cPlayer.x:SetFont(cPlayer.x:GetFont(), 12)
				end
				if LeaMapsLC["CoordsBackground"] == "On" then
					cFrame.t:Show()
				else
					cFrame.t:Hide()
				end
			end

			-- Set coordinates settings when options are clicked and on startup
			LeaMapsCB["CoordsLargeFont"]:HookScript("OnClick", SetCoordFunc)
			LeaMapsCB["CoordsBackground"]:HookScript("OnClick", SetCoordFunc)
			SetCoordFunc()

			-- Back to Main Menu button click
			cPanel.b:HookScript("OnClick", function()
				cPanel:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			cPanel.r:HookScript("OnClick", function()
				LeaMapsLC["CoordsLargeFont"] = "Off"
				LeaMapsLC["CoordsBackground"] = "On"
				SetCoordFunc()
				cPanel:Hide(); cPanel:Show()
			end)

			-- Show scale panel when configuration button is clicked
			LeaMapsCB["ShowCoordsBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["CoordsLargeFont"] = "On"
					LeaMapsLC["CoordsBackground"] = "On"
					SetCoordFunc()
					if cPanel:IsShown() then cPanel:Hide(); cPanel:Show(); end
				else
					cPanel:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		end

		----------------------------------------------------------------------
		-- Remember zoom level
		----------------------------------------------------------------------

		do

			-- Set initial values
			local lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
			local lastScale = WorldMapFrame.ScrollContainer.currentScale
			local lastHorizontal = WorldMapFrame.ScrollContainer.targetScrollX
			local lastVertical = WorldMapFrame.ScrollContainer.targetScrollY
			local lastMapID = WorldMapFrame.mapID
			local lastMapSize = WorldMapFrame.isMaximized

			-- Function to save zoom level
			local function SaveZoomLevel()
				lastZoomLevel = WorldMapFrame.ScrollContainer:GetCanvasScale()
				lastScale = WorldMapFrame.ScrollContainer.currentScale
				lastHorizontal = WorldMapFrame.ScrollContainer.targetScrollX
				lastVertical = WorldMapFrame.ScrollContainer.targetScrollY
				lastMapID = WorldMapFrame.mapID
				lastMapSize = WorldMapFrame.isMaximized
			end

			-- Give function a file level scope (it's used in Remove map border)
			LeaMapsLC.SaveZoomLevel = SaveZoomLevel

			-- Save zoom level when changed
			WorldMapFrame.ScrollContainer:HookScript("OnMouseUp", SaveZoomLevel)
			WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", SaveZoomLevel)

			-- Function to set zoom level
			local function SetZoomLevel(fullUpdate)
				if LeaMapsLC["RememberZoom"] == "On" and WorldMapFrame:IsShown() then
					WorldMapFrame:ResetZoom()
					if lastMapID and lastScale and lastHorizontal and lastVertical and WorldMapFrame.mapID == lastMapID and WorldMapFrame.isMaximized == lastMapSize then
						if fullUpdate then
							-- Prevent pointer ring glitch with toggle quest log button
							WorldMapFrame.ScrollContainer:InstantPanAndZoom(lastZoomLevel, 0.5, 0.5)
						end
						WorldMapFrame.ScrollContainer.currentScale = lastScale
						WorldMapFrame.ScrollContainer.targetScale = lastScale
						WorldMapFrame.ScrollContainer.currentScrollX = lastHorizontal
						WorldMapFrame.ScrollContainer.targetScrollX = lastHorizontal
						WorldMapFrame.ScrollContainer.currentScrollY = lastVertical
						WorldMapFrame.ScrollContainer.targetScrollY = lastVertical
						WorldMapFrame:OnMapChanged()
					end
				end
			end

			-- Set zoom level when map is shown
			hooksecurefunc("ToggleWorldMap", SetZoomLevel)
			hooksecurefunc("ToggleQuestLog", SetZoomLevel)
			hooksecurefunc(WorldMapFrame, "HandleUserActionToggleSidePanel", SetZoomLevel)

		end

		----------------------------------------------------------------------
		-- Unlock map frame (must be before Remove map border)
		----------------------------------------------------------------------

		if LeaMapsLC["UnlockMap"] == "On" then

			-- Create configuration panel
			local scaleFrame = LeaMapsLC:CreatePanel("Unlock map frame", "scaleFrame")

			-- Add controls
			LeaMapsLC:MakeTx(scaleFrame, "Settings", 16, -72)
			LeaMapsLC:MakeCB(scaleFrame, "EnableMovement", "Allow frame movement", 16, -92, false, "If checked, you will be able to move the frame by dragging the border.")
			LeaMapsLC:MakeCB(scaleFrame, "StickyMapFrame", "Sticky map frame", 16, -112, false, "If checked, the map frame will remain open until you close it.")
			LeaMapsLC:MakeTx(scaleFrame, "Scale", 16, -152)
			LeaMapsLC:MakeSL(scaleFrame, "MapScale", "Windowed", "Drag to set the scale for the windowed map.", 0.5, 2, 0.05, 36, -192, "%.1f")
			LeaMapsLC:MakeSL(scaleFrame, "MaxMapScale", "Maximised", "Drag to set the scale for the maximised map.", 0.5, 2, 0.05, 206, -192, "%.1f")

			----------------------------------------------------------------------
			-- Allow map frame movement
			----------------------------------------------------------------------

			-- Remove frame management
			WorldMapFrame:SetAttribute("UIPanelLayout-area", nil)
			WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
			WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)

			-- Enable movement
			WorldMapFrame:SetMovable(true)
			WorldMapFrame:RegisterForDrag("LeftButton")
			WorldMapFrame:SetScript("OnDragStart", function()
				if LeaMapsLC["EnableMovement"] == "On" then
					WorldMapFrame:StartMoving()
				end
			end)
			WorldMapFrame:SetScript("OnDragStop", function()
				WorldMapFrame:StopMovingOrSizing()
				WorldMapFrame:SetUserPlaced(false)
				-- Save map frame position
				if WorldMapFrame:IsMaximized() then
					LeaMapsLC["MaxMapPosA"], void, LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"] = WorldMapFrame:GetPoint()
				else
					LeaMapsLC["MapPosA"], void, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = WorldMapFrame:GetPoint()
				end
			end)

			-- Set position when map size is toggled
			hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", function()
				WorldMapFrame:ClearAllPoints()
				if not WorldMapFrame:IsMaximized() then
					WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
				else
					WorldMapFrame:SetPoint(LeaMapsLC["MaxMapPosA"], UIParent, LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"])
				end
			end)

			-- Set position on startup
			WorldMapFrame:ClearAllPoints()
			if not WorldMapFrame:IsMaximized() then
				WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
			else
				WorldMapFrame:SetPoint(LeaMapsLC["MaxMapPosA"], UIParent, LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"])
			end

			----------------------------------------------------------------------
			-- Map scale
			----------------------------------------------------------------------

			-- Function to set map frame scale
			local function SetMapScale()
				LeaMapsCB["MapScale"].f:SetFormattedText("%.0f%%", LeaMapsLC["MapScale"] * 100)
				LeaMapsCB["MaxMapScale"].f:SetFormattedText("%.0f%%", LeaMapsLC["MaxMapScale"] * 100)
				if not WorldMapFrame:IsMaximized() then
					WorldMapFrame:SetScale(LeaMapsLC["MapScale"])
				else
					WorldMapFrame:SetScale(LeaMapsLC["MaxMapScale"])
				end
			end

			-- Set scale properties when controls are changed and on startup
			LeaMapsCB["MapScale"]:HookScript("OnValueChanged", SetMapScale)
			LeaMapsCB["MaxMapScale"]:HookScript("OnValueChanged", SetMapScale)
			SetMapScale()

			-- Set scale when map size is toggled
			hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", SetMapScale)

			----------------------------------------------------------------------
			-- Sticky map frame
			----------------------------------------------------------------------

			-- Function to set sticky map frame mode
			local function StickyMapFunc()
				if LeaMapsLC["StickyMapFrame"] == "On" then
					for k, v in pairs(UISpecialFrames) do
						if v == "WorldMapFrame" then
							table.remove(UISpecialFrames, k)
						end
					end
				else
					if not tContains(UISpecialFrames, "WorldMapFrame") then
						table.insert(UISpecialFrames, "WorldMapFrame")
					end
				end
			end

			-- Set sticky map frame mode when option is clicked and on startup
			LeaMapsCB["StickyMapFrame"]:HookScript("OnClick", StickyMapFunc)
			StickyMapFunc()

			----------------------------------------------------------------------
			-- Panel button handlers
			----------------------------------------------------------------------

			-- Back to Main Menu button click
			scaleFrame.b:HookScript("OnClick", function()
				scaleFrame:Hide()
				LeaMapsLC["PageF"]:Show()
			end)

			-- Reset button click
			scaleFrame.r:HookScript("OnClick", function()
				-- Reset map position
				LeaMapsLC["EnableMovement"] = "On"
				LeaMapsLC["MapPosA"], LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"] = "TOPLEFT", "TOPLEFT", 16, -94
				LeaMapsLC["MaxMapPosA"], LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"] = "CENTER", "CENTER", 0, 0
				WorldMapFrame:ClearAllPoints()
				if WorldMapFrame:IsMaximized() then
					WorldMapFrame:SetPoint(LeaMapsLC["MaxMapPosA"], UIParent, LeaMapsLC["MaxMapPosR"], LeaMapsLC["MaxMapPosX"], LeaMapsLC["MaxMapPosY"])
				else
					WorldMapFrame:SetPoint(LeaMapsLC["MapPosA"], UIParent, LeaMapsLC["MapPosR"], LeaMapsLC["MapPosX"], LeaMapsLC["MapPosY"])
				end
				-- Reset map scale
				LeaMapsLC["MapScale"] = 1.0
				LeaMapsLC["MaxMapScale"] = 0.9
				SetMapScale()
				-- Reset sticky map frame
				LeaMapsLC["StickyMapFrame"] = "Off"
				StickyMapFunc()
				-- Refresh panel
				scaleFrame:Hide(); scaleFrame:Show()
			end)

			-- Assign file level scope to reset button (needed for Remove map border)
			LeaMapsCB["UnlockMapPanelResetButton"] = scaleFrame.r

			-- Show scale panel when configuration button is clicked
			LeaMapsCB["UnlockMapBtn"]:HookScript("OnClick", function()
				if IsShiftKeyDown() and IsControlKeyDown() then
					-- Preset profile
					LeaMapsLC["EnableMovement"] = "On"
					LeaMapsLC["MapScale"] = 1.0
					LeaMapsLC["MaxMapScale"] = 0.9
					SetMapScale()
					LeaMapsLC["StickyMapFrame"] = "Off"
					StickyMapFunc()
					if scaleFrame:IsShown() then scaleFrame:Hide(); scaleFrame:Show(); end
				else
					scaleFrame:Show()
					LeaMapsLC["PageF"]:Hide()
				end
			end)

		else

			-- Unlock map is disabled so set maximised world map position and scale on startup and when map size is toggled
			hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", function()
				if WorldMapFrame:IsMaximized() then
					WorldMapFrame:ClearAllPoints()
					if LeaMapsLC["NoMapBorder"] == "On" then
						WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 34)
					else
						WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
					end
					WorldMapFrame:SetScale(0.9)
				else
					WorldMapFrame:SetScale(1.0)
				end
			end)

		end

		----------------------------------------------------------------------
		-- Remove map border (must be after Unlock map and Remember zoom)
		----------------------------------------------------------------------

		if LeaMapsLC["NoMapBorder"] == "On" then

			-- Hide border frame elements
			WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Hide()
			WorldMapFrame.BorderFrame.NineSlice:Hide()
			WorldMapFrame.BorderFrame.TitleBg:Hide()
			WorldMapFrame.BorderFrame.InsetBorderTop:Hide()
			WorldMapFrame.NavBar:Hide()
			WorldMapFrame.TitleCanvasSpacerFrame:Hide()
			WorldMapFramePortrait:SetTexture("")
			WorldMapFrameBg:Hide()
			WorldMapFrameTitleText:Hide()

			-- Reposition close button
			WorldMapFrameCloseButton:ClearAllPoints()
			WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame:GetCanvasContainer(), "TOPRIGHT", -84, -1)

			-- Create border for world map frame
			local border = WorldMapFrame.ScrollContainer:CreateTexture(nil, "BACKGROUND"); border:SetTexture("Interface\\ChatFrame\\ChatFrameBackground"); border:SetPoint("TOPLEFT", -5, 5); border:SetPoint("BOTTOMRIGHT", 5, -5); border:SetVertexColor(0, 0, 0, 0.7)

			-- Create border for quest map frame
			local qborderTop = QuestMapFrame:CreateTexture(nil, "BACKGROUND")
			qborderTop:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
			qborderTop:SetPoint("TOPLEFT", 1, 8)
			qborderTop:SetPoint("TOPRIGHT", 6, 6)
			qborderTop:SetVertexColor(0, 0, 0, 0.7)

			local qborderBot = QuestMapFrame:CreateTexture(nil, "BACKGROUND")
			qborderBot:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
			qborderBot:SetPoint("BOTTOMLEFT", 1, -6)
			qborderBot:SetPoint("BOTTOMRIGHT", 6, -6)
			qborderBot:SetVertexColor(0, 0, 0, 0.7)

			local qborderRgt = QuestMapFrame:CreateTexture(nil, "BACKGROUND")
			qborderRgt:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
			qborderRgt:SetPoint("TOPRIGHT", 6, -6)
			qborderRgt:SetPoint("BOTTOMRIGHT", 6, -6)
			qborderRgt:SetVertexColor(0, 0, 0, 0.7)

			-- Position and size quest map frame
			QuestMapFrame:ClearAllPoints()
			QuestMapFrame:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -3, -70)
			QuestMapFrame:SetHeight(461)

			-- Position and size quest detail frame
			QuestMapFrame.DetailsFrame:ClearAllPoints()
			QuestMapFrame.DetailsFrame:SetPoint("BOTTOMLEFT", QuestMapFrame, "BOTTOMLEFT", 0, 2)

			-- Hide quest map frame top overlay
			local regions = {QuestMapFrame.DetailsFrame:GetRegions()}
			regions[2]:Hide()

			-- Hide quest map frame back button
			QuestMapFrame.DetailsFrame.BackButton:Hide()

			-- Set quest map frame background height
			hooksecurefunc("QuestLogQuests_Update", function()
				QuestMapFrame.Background:SetHeight(465)
			end)

			-- Lower quest model scene frame
			hooksecurefunc(QuestModelScene, "Show", function()
				if WorldMapFrame:IsShown() then
					QuestModelScene:ClearAllPoints()
					QuestModelScene:SetPoint("TOPLEFT", WorldMapFrame, "TOPRIGHT", -2, -81)
				end
			end)

			-- Redesign quest model scene frame
			QuestNPCCornerTopLeft:Hide()
			QuestNPCCornerTopRight:SetVertexColor(0,0,0)
			QuestNPCCornerTopRight:Hide()
			QuestNPCCornerBottomLeft:Hide()
			QuestNPCCornerBottomRight:Hide()
			QuestNPCModelTopBorder:SetVertexColor(0, 0, 0, 0.7)
			QuestNPCModelRightBorder:SetVertexColor(0, 0, 0, 0.7)
			QuestNPCModelBottomBorder:SetVertexColor(0, 0, 0, 0.7)
			QuestNPCModelTextLeftBorder:SetVertexColor(0, 0, 0, 0.7)
			QuestNPCModelTextRightBorder:SetVertexColor(0, 0, 0, 0.7)
			QuestNPCModelTextBottomBorder:SetVertexColor(0, 0, 0, 0.7)
			QuestNPCModelTextBotLeftCorner:SetVertexColor(0, 0, 0, 0.7)
			QuestNPCModelTextBotRightCorner:SetVertexColor(0,0,0)
			QuestNPCModelTopBorder:SetVertexColor(0,0,0)
			QuestNPCModelNameplate:SetVertexColor(0,0,0)
			QuestNPCModelTopBorder:SetVertexColor(0,0,0)
			QuestNPCModelTopBg:ClearAllPoints()
			QuestNPCModelTopBg:SetPoint("TOPLEFT", QuestModelScene, "TOPLEFT", -6, 16)
			QuestNPCModelTopBg:SetWidth(205)
			QuestNPCModelTopBg:SetVertexColor(0, 0, 0, 0.7)
			QuestNPCModelBg:ClearAllPoints()
			QuestNPCModelBg:SetPoint("TOPLEFT", QuestModelScene, "TOPLEFT", 0, 16)
			QuestNPCModelBg:SetHeight(246)

			-- Add map maximise and minimise toggle button
			local maxBtn = CreateFrame("BUTTON", nil, WorldMapFrame)
			maxBtn:ClearAllPoints()
			maxBtn:SetPoint("LEFT", WorldMapFrameCloseButton, "LEFT", -43, 0)
			maxBtn:SetSize(30, 30)
			maxBtn:SetFrameStrata("HIGH")
			maxBtn:HookScript("OnClick", function(self, btn)
				if WorldMapFrame.isMaximized then
					WorldMapFrame:HandleUserActionMinimizeSelf()
				else
					WorldMapFrame:HandleUserActionMaximizeSelf()
				end
				WorldMapFrame:OnMapChanged()
				LeaMapsLC:SaveZoomLevel()
			end)

			-- Reposition close button if HandyNotes: Shadowlands is installed
			if IsAddOnLoaded("HandyNotes") and IsAddOnLoaded("HandyNotes_Shadowlands") then
				WorldMapFrameCloseButton:ClearAllPoints()
				WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame:GetCanvasContainer(), "TOPRIGHT", -118, -1)
			end

			-- Set maximise minimise toggle button texture
			hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", function()
				if WorldMapFrame.isMaximized then
					maxBtn:SetNormalTexture("Interface\\BUTTONS\\UI-Panel-SmallerButton-Up")
					maxBtn:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-SmallerButton-Up")
				else
					maxBtn:SetNormalTexture("Interface\\BUTTONS\\UI-Panel-BiggerButton-Up")
					maxBtn:SetHighlightTexture("Interface\\BUTTONS\\UI-Panel-BiggerButton-Up")
				end
			end)

			-- Function to set map border clickable area
			local function SetMapHitRect()
				if LeaMapsLC["EnableMovement"] == "On" then
					-- Map is unlocked so increase clickable area around map
					WorldMapFrame:SetHitRectInsets(-20, -20, 38, -20)
				else
					-- Map is locked so remove clickable area around map
					WorldMapFrame:SetHitRectInsets(6, 6, 65, 25)
				end
			end

			-- Set clickable area around map
			if LeaMapsLC["UnlockMap"] == "On" then
				-- Map is unlocked so increase clickable area when movement is toggled and on startup
				LeaMapsCB["EnableMovement"]:HookScript("OnClick", SetMapHitRect)
				LeaMapsCB["UnlockMapPanelResetButton"]:HookScript("OnClick", SetMapHitRect)
				LeaMapsCB["UnlockMapBtn"]:HookScript("OnClick", function()
					if IsShiftKeyDown() and IsControlKeyDown() then
						SetMapHitRect()
					end
				end)
				SetMapHitRect()
			else
				-- Map is locked so reduce clickable area
				WorldMapFrame:SetHitRectInsets(6, 6, 65, 25)
			end

			-- Function to fix third party addons
			local function thirdPartyFunc(thirdPartyAddOn)
				if thirdPartyAddOn == "ElvUI" then
					-- ElvUI
					if WorldMapFrame.backdrop then WorldMapFrame.backdrop:Hide() end
					QuestMapFrame:ClearAllPoints()
					QuestMapFrame:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", -5, -70)
					QuestMapFrame:SetHeight(458)
					QuestMapFrame.DetailsFrame:ClearAllPoints()
					QuestMapFrame.DetailsFrame:SetPoint("BOTTOMLEFT", QuestMapFrame, "BOTTOMLEFT", 2, -7)
				end
			end

			-- Run function when third party addon has loaded
			if IsAddOnLoaded("ElvUI") then
				thirdPartyFunc("ElvUI")
			else
				local waitFrame = CreateFrame("FRAME")
				waitFrame:RegisterEvent("ADDON_LOADED")
				waitFrame:SetScript("OnEvent", function(self, event, arg1)
					if arg1 == "ElvUI" then
						thirdPartyFunc("ElvUI")
						waitFrame:UnregisterAllEvents()
					end
				end)
			end

		end

		----------------------------------------------------------------------
		-- Disable map fade while moving
		----------------------------------------------------------------------

		-- Function to set map fade
		local function SetMapFade()
			if LeaMapsLC["NoMapFade"] == "On" then
				SetCVar("mapFade", "0")
			else
				SetCVar("mapFade", "1")
			end
		end

		-- Set map fade when option is clicked and on startup
		LeaMapsCB["NoMapFade"]:HookScript("OnClick", SetMapFade)
		SetMapFade()

		----------------------------------------------------------------------
		-- Disable map emote when opening the map
		----------------------------------------------------------------------

		hooksecurefunc("DoEmote", function(emote)
			if emote == "READ" and WorldMapFrame:IsShown() then
				if LeaMapsLC["NoMapEmote"] == "On" then
					CancelEmote()
				end
			end
		end)

		----------------------------------------------------------------------
		-- Show dungeons and raids (/ltp pos)
		----------------------------------------------------------------------

		if LeaMapsLC["ShowIcons"] == "On" then

			-- Disable integrated dungeon icons
			SetCVar("showDungeonEntrancesOnMap", "0")
			local cFrame = CreateFrame("FRAME")
			cFrame:RegisterEvent("CVAR_UPDATE")
			cFrame:SetScript("OnEvent", function(self, event, cset)
				if cset == "SHOW_DUNGEON_ENTRANCES" and GetCVar("showDungeonEntrancesOnMap") ~= "0" then
					if not LeaMapsLC["DebugMode"] then
						SetCVar("showDungeonEntrancesOnMap", "0")
					end
				end
			end)

			local dnTex, rdTex = "Dungeon", "Raid"
			local pATex, pHTex, pNTex = "TaxiNode_Continent_Alliance", "TaxiNode_Continent_Horde", "TaxiNode_Continent_Neutral"
			local chTex = "ChallengeMode-icon-chest"

			local PinData = {

				-- World Of Warcraft: Eastern Kingdoms
				[27] =  --[[Dun Morogh]] {{31.1, 37.9, L["Gnomeregan"], L["Dungeon"], 231, dnTex},},
				[15] =  --[[Badlands]] {{41.7, 11.6, L["Uldaman"], L["Dungeon"], 239, dnTex},},
				[16] =  --[[Uldaman]] {{36.7, 29.4, L["Uldaman"], L["Dungeon"], 239, dnTex},},
				[18] =  --[[Tirisfal Glades]] {{82.5, 33.3, L["Scarlet Halls"] .. ", " .. L["Scarlet Monastery"], L["Dungeon"], 316, dnTex}, {61.9, 59.0, L["Stranglethorn Vale"], L["Portal"], 0, pHTex}, {60.7, 58.7, L["Orgrimmar"], L["Portal"], 0, pHTex}, {59.1, 58.9, L["Howling Fjord"], L["Portal"], 0, pHTex}, {59.4, 67.4, L["Silvermoon City"], L["Orb of Translocation"], 0, pHTex},},
				[19] =  --[[Scarlet Monastery]] {{69.2, 24.4, L["Scarlet Monastery"], L["Dungeon"], 316, dnTex}, {78.6, 58.9, L["Scarlet Halls"], L["Dungeon"], 311, dnTex},},
				[21] =  --[[Silverpine Forest]] {{44.8, 67.8, L["Shadowfang Keep"], L["Dungeon"], 64, dnTex},},
				[22] =  --[[Western Plaguelands]] {{69.6, 73.2, L["Scholomance"], L["Dungeon"], 246, dnTex},},
				[23] =  --[[Eastern Plaguelands]] {{27.7, 11.6, L["Stratholme: Crusader's Square"], L["Dungeon"], 236, dnTex}, {43.5, 19.4, L["Stratholme: The Gauntlet"], L["Dungeon"], 236, dnTex},},
				[30] =  --[[New Tinkertown]] {{30.2, 74.7, L["Gnomeregan"], L["Dungeon"], 231, dnTex},},
				[32] =  --[[Searing Gorge]] {{34.9, 83.9, L["Blackrock Mountain"], L["Blackrock Caverns"] .. "," .. L["Blackrock Depths"] .. "|n" .. L["Blackrock Spire"] .. "," .. L["Blackwing Lair"] .. "," .. L["Molten Core"], 66, dnTex},},
				[33] =  --[[Blackrock Mountain: Blackrock Spire]] {{66.5, 60.7, L["Blackrock Caverns"], L["Dungeon"], 66, dnTex}, {64.3, 70.9, L["Blackwing Lair"], L["Raid"], 742, rdTex}, {65.9, 41.9, L["Blackrock Spire"], L["Dungeon"], 229, dnTex}, {80.3, 40.7, L["Lower Blackrock Spire"], L["Dungeon"], 229, dnTex}, {79.0, 33.7, L["Upper Blackrock Spire"], L["Dungeon"], 559, dnTex},},
				[34] =  --[[Blackrock Mountain: Blackrock Caverns]] {{71.9, 53.5, L["Blackrock Caverns"], L["Dungeon"], 66, dnTex},},
				[35] =  --[[Blackrock Mountain: Blackrock Depths]] {{54.3, 83.4, L["Molten Core"], L["Raid"], 741, rdTex}, {39.0, 18.3, L["Blackrock Depths"], L["Dungeon"], 228, dnTex},},
				[36] =  --[[Burning Steppes]] {{21.0, 37.9, L["Blackrock Mountain"], L["Blackrock Caverns"] .. "," .. L["Blackrock Depths"] .. "|n" .. L["Blackrock Spire"] .. "," .. L["Blackwing Lair"] .. "," .. L["Molten Core"], 66, dnTex}, {23.0, 26.3, L["Blackwing Descent"], L["Raid"], 73, rdTex},},
				[37] =  --[[Elwynn Forest]] {{19.1, 36.9, L["The Stockade"], L["Dungeon"], 238, dnTex},},
				[42] =  --[[Deadwind Pass]] {{46.9, 74.7, L["Karazhan"], L["Raid"], 745, rdTex}, {46.7, 70.2, L["Return to Karazhan"], L["Dungeon"], 860, dnTex},},
				[50] =  --[[Northern Stranglethorn]] {{72.1, 32.9, L["Zul'Gurub"], L["Dungeon"], 76, dnTex}, {37.6, 51.0, L["Undercity"], L["Portal"], 0, pHTex},},
				[51] =  --[[Swamp of Sorrows]] {{69.7, 53.5, L["Temple of Atal'Hakkar"], L["Dungeon"], 237, dnTex},},
				[52] =  --[[Westfall]] {{42.6, 71.8, L["The Deadmines"], L["Dungeon"], 63, dnTex},},
				[55] =  --[[The Deadmines]] {{25.5, 51.1, L["The Deadmines"], L["Dungeon"], 63, dnTex},},
				[84] =  --[[Stormwind City]] {{49.5, 69.5, L["The Stockade"], L["Dungeon"], 238, dnTex}, {74.4, 18.4, L["Eastern Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Tol Barad"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"], 0, pATex, nil, nil, nil, nil},},
				[90] =  --[[Undercity]] {{85.3, 17.1, L["Hellfire Peninsula"], L["Portal"], 0, pHTex},},
				[224] =  --[[Stranglethorn Vale]] {{63.5, 21.6, L["Zul'Gurub"], L["Dungeon"], 76, dnTex},},
				[243] =  --[[Blackrock Depths]] {{68.4, 38.3, L["Molten Core"], L["Raid"], 741, rdTex},},
				[469] =  --[[New Tinkertown]] {{32.6, 37.0, L["Gnomeregan"], L["Dungeon"], 231, dnTex},},

				-- World Of Warcraft: Kalimdor
				[10] =  --[[Northern Barrens]] {{38.9, 69.1, L["Wailing Caverns"], L["Dungeon"], 240, dnTex},},
				[11] =  --[[Wailing Caverns]] {{55.1, 65.9, L["Wailing Caverns"], L["Dungeon"], 240, dnTex},},
				[57] =  --[[Teldrassil]] {{55.0, 93.7, L["Stormwind"], L["Portal"], 0, pATex}, {52.3, 89.5, L["Exodar"], L["Portal"], 0, pATex},},
				[63] =  --[[Ashenvale]] {{14.2, 13.9, L["Blackfathom Deeps"], L["Dungeon"], 227, dnTex},},
				[64] =  --[[Thousand Needles]] {{41.5, 29.4, L["Razorfen Downs"], L["Dungeon"], 233, dnTex},},
				[66] =  --[[Desolace]] {{29.1, 62.6, L["Maraudon"], L["Dungeon"], 232, dnTex},},
				[67] =  --[[Maraudon: The Wicked Grotto]] {{78.2, 56.0, L["Maraudon: Foulspore Cavern"], L["Dungeon"], 232, dnTex},},
				[68] =  --[[Maraudon: Foulspore Cavern]] {{44.4, 76.8, L["Maraudon: Earth Song Falls"], L["Dungeon"], 232, dnTex}, {52.0, 24.5, L["Maraudon: The Wicked Grotto"], L["Dungeon"], 232, dnTex},},
				[69] =  --[[Feralas]] {{60.3, 31.3, L["Dire Maul: Capital Gardens"], L["Dungeon"], 230, dnTex}, {64.8, 30.2, L["Dire Maul: Warpwood Quarter"], L["Dungeon"], 230, dnTex}, {62.5, 24.9, L["Dire Maul: Gordok Commons"], L["Dungeon"], 230, dnTex},},
				[70] =  --[[Dustwallow Marsh]] {{52.2, 75.7, L["Onyxia's Lair"], L["Raid"], 760, rdTex},},
				[71] =  --[[Tanaris]] {{39.2, 21.3, L["Zul'Farrak"], L["Dungeon"], 241, dnTex}, {64.8, 50.0, L["Caverns of Time"], L["Black Morass"] .. ", " .. L["Culling of Stratholme"] .. ",|n" .. L["Dragon Soul"] .. ", " .. L["End Time"] .. ", " .. L["Hour of Twilight"] .. ",|n" .. L["Hyjal Summit"] .. ", " .. L["Old Hillsbrad Foothills"] .. ",|n" .. L["Well of Eternity"], 255, dnTex},},
				[74] = 	--[[Caverns of Time: The Spiral]] {{59.0, 26.8, L["Stormwind"], L["Portal"], 0, pATex}, {58.2, 26.7, L["Orgrimmar"], L["Portal"], 0, pHTex},},
				[75] =  --[[Caverns of Time: Main Hub]] {{57.5, 82.6, L["The Culling of Stratholme"], L["Dungeon"], 279, dnTex}, {36.7, 83.0, L["The Black Morass"], L["Dungeon"], 255, dnTex}, {22.5, 64.4, L["Well of Eternity"], L["Dungeon"], 185, dnTex}, {26.9, 35.8, L["Old Hillsbrad Foothills"], L["Dungeon"], 251, dnTex}, {35.5, 15.6, L["Hyjal Summit"], L["Raid"], 750, rdTex}, {57.3, 29.6, L["End Time"], L["Dungeon"], 184, dnTex}, {61.6, 26.6, L["Dragon Soul"], L["Raid"], 187, rdTex}, {66.9, 29.4, L["Hour of Twilight"], L["Dungeon"], 186, dnTex},},
				[81] =  --[[Silithus]] {{43.2, 44.5, L["Chamber of Heart"], L["Titan Translocator"], 0, pNTex}, {41.5, 44.9, L["Tiragarde Sound"], L["Portal"], 0, pATex}, {41.6, 45.2, L["Zuldazar"], L["Portal"], 0, pHTex},},
				[85] =  --[[Orgrimmar: Main City]] {{55.2, 51.2, L["Ragefire Chasm"], L["Dungeon"], 226, dnTex}, {50.1, 37.8, L["Western Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"], 0, pHTex, nil, nil, nil, nil}, {47.4, 39.3, L["Tol Barad"], L["Portal"], 0, pHTex, nil, nil, nil, nil}, {43.0, 65.0, L["Zeppelin to"] .." " .. L["Thunder Bluff"] .. ", " .. L["Mulgore"], "", 0, pHTex}, {50.7, 55.5, L["Undercity"], L["Portal"], 0, pHTex},},
				[86] =  --[[Orgrimmar: The Cleft Of Shadow]] {{70.0, 49.2, L["Ragefire Chasm"], L["Dungeon"], 226, dnTex}, {50.1, 37.8, L["Western Earthshrine"], L["Deepholm"] .. ", " .. L["Hyjal"] .. ", " .. L["Twilight Highlands"] .. ", " .. L["Uldum"] .. ", " .. L["Vashj'ir"], 0, pHTex, nil, nil, nil, nil}, {47.4, 39.3, L["Tol Barad"], L["Portal"], 0, pHTex, nil, nil, nil, nil}, {43.0, 65.0, L["Zeppelin to"] .." " .. L["Thunder Bluff"] .. ", " .. L["Mulgore"], "", 0, pHTex}, {50.7, 55.5, L["Undercity"], L["Portal"], 0, pHTex},},
				[88] =  --[[Thunder Bluff]] {{14.6, 26.4, L["Zeppelin to"] .. " " .. L["Orgrimmar"] .. ", " .. L["Durotar"], "", 0, pHTex},},
				[89] =  --[[Darnassus]] {{44.1, 78.5, L["Temple of the Moon"], L["Exodar"] .. ", " .. L["Hellfire Peninsula"], 0, pATex},},
				[97] =  --[[Azuremyst Isle]] {{20.4, 54.1, L["Darnassus"], L["Portal"], 0, pATex},},
				[199] =  --[[Southern Barrens]] {{41.0, 94.6, L["Razorfen Kraul"], L["Dungeon"], 234, dnTex},},
				[247] =  --[[Ruins of Ahn'Qiraj]] {{59.3, 28.7, L["Scarab Coffer"], L["Chest"], 0, chTex}, {60.8, 51.0, L["Scarab Coffer"], L["Chest"], 0, chTex}, {73.0, 66.4, L["Scarab Coffer"], L["Chest"], 0, chTex},  {57.4, 78.3, L["Scarab Coffer"], L["Chest"], 0, chTex}, {54.8, 87.5, L["Scarab Coffer"], L["Chest"], 0, chTex}, {41.0, 76.9, L["Scarab Coffer"], L["Chest"], 0, chTex}, {34.0, 53.0, L["Scarab Coffer"], L["Chest"], 0, chTex}, {41.1, 32.2, L["Scarab Coffer"], L["Chest"], 0, chTex}, {41.6, 46.3, L["Scarab Coffer"], L["Chest"], 0, chTex}, {46.7, 42.0, L["Scarab Coffer"], L["Chest"], 0, chTex},}, 
				[319] =  --[[Temple of Ahn'Qiraj]] {{33.1, 48.4, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {64.5, 25.5, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {58.4, 49.9, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {47.5, 54.7, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {56.2, 66.0, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {50.7, 78.1, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {51.4, 83.2, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {48.4, 85.4, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {48.0, 81.1, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {34.2, 83.5, L["Large Scarab Coffer"], L["Chest"], 0, chTex}, {39.2, 68.4, L["Large Scarab Coffer"], L["Chest"], 0, chTex},}, 
				[327] =  --[[Ahn'Qiraj: The Fallen Kingdom]] {{46.8, 7.5, L["Temple of Ahn'Qiraj"], L["Raid"], 744, rdTex}, {58.9, 14.3, L["Ruins of Ahn'Qiraj"], L["Raid"], 743, rdTex},},

				-- The Burning Crusade
				[95] =  --[[Ghostlands]] {{82.1, 64.3, L["Zul'Aman"], L["Dungeon"], 77, dnTex},},
				[100] =  --[[Hellfire Peninsula]] {{46.6, 52.8, L["Magtheridon's Lair"], L["Raid"], 747, rdTex}, {47.7, 53.6, L["Hellfire Ramparts"], L["Dungeon"], 248, dnTex}, {47.7, 52.0, L["The Shattered Halls"], L["Dungeon"], 259, dnTex}, {46.0, 51.8, L["The Blood Furnace"], L["Dungeon"], 256, dnTex}, {88.6, 47.7, L["Orgrimmar"], L["Portal"], 0, pHTex}, {88.6, 52.8, L["Stormwind"], L["Portal"], 0, pATex},},
				[102] =  --[[Zangarmarsh]] {{50.4, 40.9, L["Coilfang Reservoir"], L["Serpentshrine Cavern"] .. ", " .. L["Slave Pens"] .. ",|n" .. L["Steamvault"] .. ", " .. L["Underbog"], 748, dnTex},},
				[103] =  --[[The Exodar]] {{48.3, 62.9, L["Stormwind"], L["Portal"], 0, pATex},},
				[104] =  --[[Shadowmoon Valley]] {{71.0, 46.4, L["Black Temple"], L["Raid"], 751, rdTex},},
				[105] =  --[[Blade's Edge Mountains]] {{68.7, 24.3, L["Gruul's Lair"], L["Raid"], 746, rdTex},},
				[108] =  --[[Terokkar Forest]] {{43.2, 65.6, L["Sethekk Halls"], L["Dungeon"], 252, dnTex}, {36.1, 65.6, L["Auchenai Crypts"], L["Dungeon"], 247, dnTex}, {39.6, 71.0, L["Shadow Labyrinth"], L["Dungeon"], 253, dnTex}, {39.7, 60.2, L["Mana-Tombs"], L["Dungeon"], 250, dnTex},},
				[109] =  --[[Netherstorm]] {{70.6, 69.7, L["The Mechanar"], L["Dungeon"], 258, dnTex}, {73.7, 63.7, L["The Eye"], L["Raid"], 749, rdTex}, {71.7, 55.0, L["The Botanica"], L["Dungeon"], 257, dnTex}, {74.4, 57.7, L["The Arcatraz"], L["Dungeon"], 254, dnTex},},
				[110] =  --[[Silvermoon City]] {{58.5, 18.7, L["Orgrimmar"], L["Portal"], 0, pHTex}, {49.5, 14.8, L["Undercity"], L["Orb of Translocation"], 0, pHTex}, {58.5, 18.7, L["Orgrimmar"], L["Portal"], 0, pHTex},},
				[111] =  --[[Shattrath City]] {{48.5, 42.0, L["Isle of Quel'Danas"], L["Portal"], 0, pNTex}, {56.8, 48.9, L["Orgrimmar"], L["Portal"], 0, pHTex}, {57.2, 48.3, L["Stormwind"], L["Portal"], 0, pATex},},
				[122] =  --[[Isle of Quel'Danas]] {{61.2, 30.9, L["Magisters' Terrace"], L["Dungeon"], 249, dnTex}, {44.3, 45.6, L["Sunwell Plateau"], L["Raid"], 752, rdTex},},
				[245] =  --[[Tol Barad Peninsula]] {{56.3, 79.7, L["Orgrimmar"], L["Portal"], 0, pHTex}, {75.3, 58.8, L["Stormwind"], L["Portal"], 0, pATex},},

				-- Wrath Of The Lich King
				[114] =  --[[Borean Tundra]] {{27.6, 26.6, L["The Nexus"], L["The Nexus"] .. ", " .. L["The Oculus"] .. ",|n" .. L["The Eye of Eternity"], 281, dnTex},},
				[115] =  --[[Dragonblight]] {{59.6, 51.1, L["Wyrmrest Temple"], L["The Ruby Sanctum"] .. ", " .. L["The Obsidian Sanctum"], 761, dnTex}, {87.4, 51.1, L["Naxxramas"], L["Raid"], 754, rdTex}, {26.2, 49.6, L["Azjol-Nerub"], L["Azjol-Nerub"] .. ", " .. L["The Old Kingdom"], 272, dnTex},},
				[116] =  --[[Grizzly Hills]] {{17.5, 27.0, L["Drak'Tharon Keep"], L["Dungeon"], 273, dnTex},},
				[117] =  --[[Howling Fjord]] {{57.3, 46.8, L["Utgarde Keep"], L["Utgarde Keep"] .. ", " .. L["Utgarde Pinnacle"], 285, dnTex},},
				[118] =  --[[Icecrown]] {{53.3, 85.5, L["Icecrown Citadel"], L["Raid"], 758, rdTex}, {52.6, 89.4, L["The Frozen Halls"], L["The Forge of Souls"] .. ", " .. L["The Pit of Saron"] .. ",|n" .. L["The Halls of Reflection"], 280, dnTex}, {74.2, 20.5, L["Trial of the Champion"], L["Dungeon"], 284, dnTex}, {75.1, 21.8, L["Trial of the Crusader"], L["Raid"], 757, rdTex},},
				[120] =  --[[The Storm Peaks]] {{39.6, 26.9, L["Halls of Stone"], L["Dungeon"], 277, dnTex}, {45.4, 21.4, L["Halls of Lightning"], L["Dungeon"], 275, dnTex}, {41.6, 17.8, L["Ulduar"], L["Raid"], 759, rdTex},},
				[121] =  --[[Zul'Drak]] {{29.0, 83.9, L["Drak'Tharon Keep"], L["Dungeon"], 273, dnTex}, {76.2, 21.1, L["Gundrak"], L["Dungeon"], 274, dnTex}, {81.2, 28.9, L["Gundrak (rear entrance)"], L["Dungeon"], 274, dnTex},},
				[123] =  --[[Wintergrasp]] {{50.5, 16.4, L["Vault of Archavon"], L["Raid"], 753, rdTex},},
				[125] =  --[[Dalaran]] {{66.8, 68.2, L["The Violet Hold"], L["Dungeon"], 283, dnTex}, {40.1, 62.8, L["Stormwind"], L["Portal"], 0, pATex}, {55.3, 25.4, L["Orgrimmar"], L["Portal"], 0, pHTex},},

				-- Cataclysm
				[198] =  --[[Mount Hyjal]] {{47.3, 78.0, L["Firelands"], L["Raid"], 78, rdTex},},
				[203] =  --[[Vashj'ir]] {{49.1, 42.4, L["Throne of the Tides"], L["Dungeon"], 65, dnTex},},
				[204] =  --[[Abyssal Depths]] {{70.8, 29.0, L["Throne of the Tides"], L["Dungeon"], 65, dnTex},},
				[207] =  --[[Deepholm]] {{47.6, 52.0, L["The Stonecore"], L["Dungeon"], 67, dnTex},},
				[241] =  --[[Twilight Highlands]] {{34.0, 78.0, L["The Bastion of Twilight"], L["Raid"], 72, rdTex}, {19.2, 54.0, L["Grim Batol"], L["Dungeon"], 71, dnTex},},
				[244] =  --[[Tol Barad]] {{46.3, 47.9, L["Baradin Hold"], L["Raid"], 75, rdTex},},
				[249] =  --[[Uldum]] {{71.6, 52.2, L["Halls of Origination"], L["Dungeon"], 70, dnTex}, {60.5, 64.2, L["Lost City of the Tol'vir"], L["Dungeon"], 69, dnTex}, {76.7, 84.4, L["The Vortex Pinnacle"], L["Dungeon"], 68, dnTex}, {38.4, 80.6, L["Throne of the Four Winds"], L["Raid"], 74, rdTex},},

				-- Mists Of Pandaria
				[371] =  --[[The Jade Forest]] {{56.2, 57.9, L["Temple of the Jade Serpent"], L["Dungeon"], 313, dnTex},},
				[376] =  --[[Valley of the Four Winds]] {{36.1, 69.2, L["Stormstout Brewery"], L["Dungeon"], 302, dnTex},},
				[379] =  --[[Kun-Lai Summit]] {{59.6, 39.2, L["Mogu'shan Vaults"], L["Raid"], 317, rdTex}, {36.7, 47.4, L["Shado-Pan Monastery"], L["Dungeon"], 312, dnTex},},
				[388] =  --[[Townlong Steppes]] {{34.7, 81.5, L["Siege of Niuzao Temple"], L["Dungeon"], 324, dnTex},},
				[390] =  --[[Vale of Eternal Blossoms]] {{80.9, 32.7, L["Mogu'shan Palace"], L["Dungeon"], 321, dnTex}, {72.4, 44.2, L["Siege of Orgrimmar"], L["Raid"], 369, rdTex}, {15.8, 74.3, L["Gate of the Setting Sun"], L["Dungeon"], 303, dnTex},},
				[422] =  --[[Dread Wastes]] {{38.8, 35.0, L["Heart of Fear"], L["Raid"], 330, rdTex},},
				[433] =  --[[The Veiled Stair]] {{48.4, 61.4, L["Terrace of Endless Spring"], L["Raid"], 320, rdTex},},
				[504] =  --[[Isle of Thunder]] {{63.6, 32.3, L["Throne of Thunder"], L["Raid"], 362, rdTex},},
				[392] =  --[[Shrine of Two Moons]] {{73.3, 42.8, L["Orgrimmar"], L["Portal"], 0, pHTex},},
				[394] =  --[[Shrine of Seven Stars]] {{71.6, 36.0, L["Stormwind"], L["Portal"], 0, pATex},},

				-- Warlords Of Draenor
				[525] =  --[[Frostfire Ridge]] {{49.8, 24.7, L["Bloodmaul Slag Mines"], L["Dungeon"], 385, dnTex},},
				[534] =  --[[Tanaan Jungle]] {{45.7, 53.5, L["Hellfire Citadel"], L["Raid"], 669, rdTex},},
				[535] =  --[[Talador]] {{46.3, 73.9, L["Auchindoun"], L["Dungeon"], 547, dnTex},},
				[539] =  --[[Shadowmoon Valley]] {{31.9, 42.5, L["Shadowmoon Burial Grounds"], L["Dungeon"], 537, dnTex},},
				[542] =  --[[Spires of Arak]] {{35.6, 33.6, L["Skyreach"], L["Dungeon"], 476, dnTex},},
				[543] =  --[[Gorgrond]] {{51.3, 28.6, L["Blackrock Foundry"], L["Raid"], 457, rdTex}, {55.2, 31.9, L["Grimrail Depot"], L["Dungeon"], 536, dnTex}, {59.6, 45.5, L["The Everbloom"], L["Dungeon"], 556, dnTex}, {45.4, 13.5, L["Iron Docks"], L["Dungeon"], 558, dnTex},},
				[550] =  --[[Nagrand]] {{32.9, 38.4, L["Highmaul"], L["Raid"], 477, rdTex},},
				[622] =  --[[Stormshield]] {{60.8, 38.0, L["Stormwind"], L["Portal"], 0, pATex}, {36.4, 41.1, L["Lion's Watch"], L["Portal"], 0, pATex, 38445},},
				[624] =  --[[Warspear]] {{60.6, 51.6, L["Orgrimmar"], L["Portal"], 0, pHTex}, {53.0, 43.9, L["Vol'mar"], L["Portal"], 0, pHTex, 37935},},

				-- Legion
				[885] =  --[[Antoran Wastes]] {{55.0, 62.4, L["Antorus, the Burning Throne"], L["Raid"], 946, rdTex},},
				[630] =  --[[Azsuna]] {{61.1, 41.1, L["Eye of Azshara"], L["Dungeon"], 716, dnTex}, {48.1, 82.1, L["Vault of the Wardens"], L["Dungeon"], 707, dnTex},},
				[646] =  --[[Broken Shore]] {{64.7, 16.6, L["Cathedral of Eternal Night"], L["Dungeon"], 900, dnTex}, {64.1, 21.3, L["Tomb of Sargeras"], L["Raid"], 875, rdTex},},
				[627] =  --[[Dalaran]] {{66.5, 68.6, L["The Violet Hold"], L["Dungeon"], 777, dnTex}, {39.6, 63.2, L["Stormwind"], L["Portal"], 0, pATex}, {55.2, 23.9, L["Orgrimmar"], L["Portal"], 0, pHTex},},
				[682] =  --[[Felsoul Hold]] {{53.6, 36.8, L["Shal'Aran"], L["Portal"], 0, pNTex, 41575,},},
				[650] =  --[[Highmountain]] {{49.6, 68.7, L["Neltharion's Lair"], L["Dungeon"], 767, dnTex},},
				[882] =  --[[Mac'Aree]] {{22.2, 56.2, L["Seat of the Triumvirate"], L["Dungeon"], 945, dnTex},},
				[684] =  --[[Shattered Locus]] {{40.9, 13.7, L["Shal'Aran"], L["Portal"], 0, pNTex, 42230,},},
				[634] =  --[[Stormheim]] {{70.4, 69.5, L["Gates of Valor"], L["Halls of Valor"] .. "," .. L["Trial of Valor"], 721, dnTex}, {52.5, 45.3, L["Maw of Souls"], L["Dungeon"], 727, dnTex},},
				[680] =  --[[Suramar]] {{21.6, 28.5, L["Falanaar"], L["Portal"], 0, pNTex, 42230,}, {39.7, 76.2, L["Felsoul Hold"], L["Portal"], 0, pNTex, 41575,}, {30.8, 11.0, L["Moon Guard Stronghold"], L["Portal"], 0, pNTex, 43808,}, {43.7, 79.2, L["Lunastre Estate"], L["Portal"], 0, pNTex, 43811,}, {36.1, 47.2, L["Ruins of Elune'eth"], L["Portal"], 0, pNTex, 40956,}, {52.0, 78.8, L["Evermoon Terrace"], L["Portal"], 0, pNTex, 42889,}, {43.4, 60.6, L["Sanctum of Order"], L["Portal"], 0, pNTex, 43813,}, {42.0, 35.2, L["Tel'anor"], L["Portal"], 0, pNTex, 43809,}, {64.0, 60.4, L["Twilight Vineyards"], L["Portal"], 0, pNTex, 44084,}, {54.5, 69.4, L["Astravar Harbor"], L["Portal"], 0, pNTex, 44740,}, {47.7, 81.4, L["The Waning Crescent"], L["Portal"], 0, pNTex, 42487, 38649,}, {43.3, 62.3, L["Sanctum of Order"], L["The Arcway"] .. "," .. L["The Nighthold"], 726, dnTex}, {50.9, 65.6, L["Court of Stars"], L["Dungeon"], 800, dnTex},},
				[641] =  --[[Val'sharah]] {{38.6, 51.0, L["Black Rook Hold"], L["Dungeon"], 740, dnTex}, {59.0, 31.1, L["Darkheart Thicket"], L["Dungeon"], 762, dnTex}, {56.3, 36.9, L["The Emerald Nightmare"], L["Raid"], 768, rdTex},},

				-- Battle For Azeroth
				[896] =  --[[Drustvar]] {{33.7, 12.6, L["Waycrest Manor"], L["Dungeon"], 1021, dnTex},},
				[1462]=  --[[Mechagon Island]] {{73.2, 36.3, L["Operation: Mechagon"], L["Dungeon"], 1178, dnTex},},
				[863] =  --[[Nazmir]] {{51.4, 64.9, L["The Underrot"], L["Dungeon"], 1022, dnTex}, {54.1, 63.0, L["Uldir"], L["Raid"], 1031, rdTex},},
				[942] =  --[[Stormsong Valley]] {{83.9, 46.9, L["Crucible of Storms"], L["Raid"], 1177, rdTex}, {78.9, 26.5, L["Shrine of the Storm"], L["Dungeon"], 1036, dnTex},},
				[895] =  --[[Tiragarde Sound]] {{84.5, 78.8, L["Freehold"], L["Dungeon"], 1001, dnTex},},
				[864] =  --[[Vol'dun]] {{51.9, 25.1, L["Temple of Sethraliss"], L["Dungeon"], 1030, dnTex},},
				[862] =  --[[Zuldazar]] {{43.4, 39.5, L["Atal'Dazar"], L["Dungeon"], 968, dnTex}, {37.6, 39.5, L["Kings' Rest"], L["Dungeon"], 1041, dnTex},},
				[1527] =  --[[Uldum]] {{71.6, 52.2, L["Halls of Origination"], L["Dungeon"], 70, dnTex}, {60.5, 64.2, L["Lost City of the Tol'vir"], L["Dungeon"], 69, dnTex}, {76.7, 84.4, L["The Vortex Pinnacle"], L["Dungeon"], 68, dnTex}, {38.4, 80.6, L["Throne of the Four Winds"], L["Raid"], 74, rdTex},},
				[1530] =  --[[Vale of Eternal Blossoms (N'Zoth)]] {{81.4, 30.2, L["Mogu'shan Palace"], L["Dungeon"], 321, dnTex}, {72.6, 42.0, L["Siege of Orgrimmar"], L["Raid"], 369, rdTex}, {15.5, 72.2, L["Gate of the Setting Sun"], L["Dungeon"], 303, dnTex},},
				[1161] =  --[[Boralus Harbor]] {{70.4, 17.7, L["Sanctum of the Sages"], L["Exodar"] .. ", " .. L["Ironforge"] .. ", " .. L["Nazjatar"] .. ", " .. L["Silithus"] .. ", " .. L["Stormwind"], 0, pATex},},
				[1163] =  --[[Dazar'alor]] {{60.5, 70.3, L["Hall of Ancient Paths"], L["Nazjatar"] .. ", " .. L["Orgrimmar"] .. ", " .. L["Silithus"] .. ", " .. L["Silvermoon City"] .. ", " .. L["Thunder Bluff"], 0, pHTex},},
				[1473] =  --[[Chamber of Heart]] {{50.1, 30.4, L["Silithus"], L["Titan Translocator"], 0, pNTex},},

				-- Shadowlands
				[1525] =  --[[Revendreth]] {{78.3, 49.1, L["Halls of Atonement"], L["Dungeon"], 1185, dnTex, nil, nil, nil, nil}, {50.9, 29.9, L["Sanguine Depths"], L["Dungeon"], 1189, dnTex, nil, nil, nil, nil}, --[[{46.2, 41.2, L["Castle Nathria"], L["Raid"], 1190, rdTex, nil, nil, nil, nil},]]},
				[1533] =  --[[Bastion]] {{40.0, 55.3, L["The Necrotic Wake"], L["Dungeon"], 1182, dnTex, nil, nil, nil, nil}, {58.4, 28.7, L["Spires of Ascension"], L["Dungeon"], 1186, dnTex, nil, nil, nil, nil},},
				[1536] =  --[[Maldraxxus]] {{59.2, 64.8, L["Plaguefall"], L["Dungeon"], 1183, dnTex, nil, nil, nil, nil}, {53.0, 53.0, L["Theater of Pain"], L["Dungeon"], 1187, dnTex, nil, nil, nil, nil},},
				[1565] =  --[[Ardenweald]] {{68.7, 66.1, L["De Other Side"], L["Dungeon"], 1188, dnTex, nil, nil, nil, nil}, {35.4, 53.9, L["Mists of Tirna Scithe"], L["Dungeon"], 1184, dnTex, nil, nil, nil, nil},},

			}

			-- Faction specific dungeon and raid entrances
			if playerFaction == "Alliance" then
				--[[Boralus]] 			PinData[1161] = PinData[1161] or {}; 	tinsert(PinData[1161], {70.5, 35.4, L["Battle of Dazar'alor"], L["Raid"], 1176, rdTex, nil, nil, nil, nil})
				--[[Boralus]] 			PinData[1161] = PinData[1161] or {}; 	tinsert(PinData[1161], {72.4, 19.0, L["Siege of Boralus"], L["Dungeon"], 1023, dnTex, nil, nil, nil, nil})
				--[[Tiragarde Snd]]		PinData[895] = PinData[895] or {}; 		tinsert(PinData[895], {74.4, 28.2, L["Battle of Dazar'alor"], L["Raid"], 1176, rdTex, nil, nil, nil, nil})
				--[[Tiragarde Snd]]		PinData[895] = PinData[895] or {}; 		tinsert(PinData[895], {74.8, 24.1, L["Siege of Boralus"], L["Dungeon"], 1023, dnTex, nil, nil, nil, nil})
				--[[Zuldazar]] 			PinData[862] = PinData[862] or {}; 		tinsert(PinData[862], {39.2, 71.5, L["The MOTHERLODE!!"], L["Dungeon"], 1012, dnTex, nil, nil, nil, nil})
				--[[Townlong Steppes]] 	PinData[388] = PinData[388] or {}; 		tinsert(PinData[388], {49.7, 68.7, L["Throne of Thunder"], L["Raid"], 362, rdTex, nil, nil, nil, nil})

			elseif playerFaction == "Horde" then
				--[[Dazar'alor]] 		PinData[1165] = PinData[1165] or {}; 	tinsert(PinData[1165], {38.9, 2.7, L["Battle of Dazar'alor"], L["Raid"], 1176, rdTex, nil, nil, nil, nil})
				--[[Dazar'alor]] 		PinData[1165] = PinData[1165] or {}; 	tinsert(PinData[1165], {44.3, 92.7, L["The MOTHERLODE!!"], L["Dungeon"], 1012, dnTex, nil, nil, nil, nil})
				--[[Tiragarde Snd]]		PinData[895] = PinData[895] or {}; 		tinsert(PinData[895], {88.3, 51.0, L["Siege of Boralus"], L["Dungeon"], 1023, dnTex, nil, nil, nil, nil})
				--[[Zuldazar]] 			PinData[862] = PinData[862] or {}; 		tinsert(PinData[862], {54.3, 29.9, L["Battle of Dazar'alor"], L["Raid"], 1176, rdTex, nil, nil, nil, nil})
				--[[Zuldazar]] 			PinData[862] = PinData[862] or {}; 		tinsert(PinData[862], {56.1, 59.9, L["The MOTHERLODE!!"], L["Dungeon"], 1012, dnTex, nil, nil, nil, nil})
				--[[Townlong Steppes]] 	PinData[388] = PinData[388] or {}; 		tinsert(PinData[388], {50.6, 73.4, L["Throne of Thunder"], L["Raid"], 362, rdTex, nil, nil, nil, nil})

			end

			-- Add Caverns of Time portal to Shattrath if reputation with Keepers of Time is revered or higher
			local name, description, standingID = GetFactionInfoByID(989) 
			if standingID and standingID >= 7 then
				PinData[111] = PinData[111] or {}; tinsert(PinData[111], {74.7, 31.4, L["Caverns of Time"], L["Portal from Zephyr"], 0, pNTex})
			end

			-- Function to check if dungeon is on a specific map ID (used for moving dungeons such as Ny'alotha)
			local function IsDungeonOnMapID(worldmapid, ejdungeonid)
				local dungeonEntrances = C_EncounterJournal.GetDungeonEntrancesForMap(worldmapid)
				for i, dungeonEntranceInfo in ipairs(dungeonEntrances) do
					local journalID = dungeonEntranceInfo.journalInstanceID
					if journalID and journalID == ejdungeonid then return true end
				end
			end

			-- Show Ny'alotha on correct map
			if IsDungeonOnMapID(1527, 1180) then
				-- Show Ny'alotha on Uldum map
				PinData[1527] = PinData[1527] or {}; tinsert(PinData[1527], {55.1, 43.9, L["Ny'alotha, The Waking City"], L["Raid"], 1180, rdTex})
			end

			if IsDungeonOnMapID(1530, 1180) then
				-- Show Ny'alotha on Vale of Eternal Blossoms map
				PinData[1530] = PinData[1530] or {}; tinsert(PinData[1530], {40.1, 45.5, L["Ny'alotha, The Waking City"], L["Raid"], 1180, rdTex})
			end

			local LeaMix = CreateFromMixins(MapCanvasDataProviderMixin)

			function LeaMix:RefreshAllData()

				-- Disable integrated dungeon icons
				if GetCVar("showDungeonEntrancesOnMap") ~= "0" then
					if not LeaMapsLC["DebugMode"] then
						SetCVar("showDungeonEntrancesOnMap", "0")
					end
				end

				-- Remove all pins created by Leatrix Maps
				self:GetMap():RemoveAllPinsByTemplate("LeaMapsGlobalPinTemplate")

				-- Show new pins if option is enabled
				do

					-- Make new pins
					local pMapID = WorldMapFrame.mapID
					if PinData[pMapID] then
						local count = #PinData[pMapID]
						for i = 1, count do

							-- Do nothing if pinInfo has no entry for zone we are looking at
							local pinInfo = PinData[pMapID][i]
							if not pinInfo then return nil end

							-- Get POI if any quest requirements have been met
							if not pinInfo[7] or pinInfo[7] and not pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) or pinInfo[7] and pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then
								if playerFaction == "Alliance" and pinInfo[6] ~= pHTex or playerFaction == "Horde" and pinInfo[6] ~= pATex then
									local myPOI = {}
									myPOI["position"] = CreateVector2D(pinInfo[1] / 100, pinInfo[2] / 100)
									myPOI["name"] = pinInfo[3]
									myPOI["description"] = pinInfo[4]
									myPOI["journalID"] = pinInfo[5]
									myPOI["atlasName"] = pinInfo[6]
									self:GetMap():AcquirePin("LeaMapsGlobalPinTemplate", myPOI)
								end
							end
						end
					end

				end

			end

			LeaMapsGlobalPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")

			function LeaMapsGlobalPinMixin:OnAcquired(myInfo)
				BaseMapPoiPinMixin.OnAcquired(self, myInfo)
				self.journalID = myInfo.journalID
			end

			function LeaMapsGlobalPinMixin:OnMouseDown(btn)
				if IsControlKeyDown() and btn == "LeftButton" then return end -- Do nothing if placing map pin
				if LeaMapsLC["UnlockMap"] == "On" or not WorldMapFrame:IsMaximized() then
					if not LeaMapsLC:PlayerInCombat() and self.journalID and self.journalID ~= 0 then
						if not IsAddOnLoaded("Blizzard_EncounterJournal") then
							EncounterJournal_LoadUI()
						end
						EncounterJournal_OpenJournal(nil, self.journalID)
					end
				end
			end

			WorldMapFrame:AddDataProvider(LeaMix)

		end

		----------------------------------------------------------------------
		-- Show unexplored areas
		----------------------------------------------------------------------

		if LeaMapsLC["RevealMap"] == "On" then

			-- Dont reveal garrisons for player faction
			if playerFaction == "Alliance" then
				-- Remove Alliance garrison texture
				Leatrix_Maps["Reveal"][556]["223:279:194:0"] = string.gsub(Leatrix_Maps["Reveal"][556]["223:279:194:0"], "1037663", "")
			elseif playerFaction == "Horde" then
				-- Remove Horde garrison texture
				Leatrix_Maps["Reveal"][542]["267:257:336:327"] = string.gsub(Leatrix_Maps["Reveal"][542]["267:257:336:327"], "1003342", "")
			end

			-- Dont reveal specific areas
			Leatrix_Maps["Reveal"][521] = nil -- Throne of Thunder
			Leatrix_Maps["Reveal"][1176] = nil -- The Dredge (Darkshore)
			Leatrix_Maps["Reveal"][67]["453:340:0:0"] = nil -- Veiled Sea (Darkshore)

			-- Shadowlands
			--[[ Bastion ]] 	Leatrix_Maps["Reveal"][1321] = {["1115:704:881:993"] = "3192874, 3192881, 3192882, 3192883, 3192884, 3192885, 3192886, 3192887, 3192888, 3192875, 3192876, 3192877, 3192878, 3192879, 3192880", ["1357:856:495:250"] = "3192889, 3192900, 3192906, 3192907, 3192908, 3192909, 3192910, 3192911, 3192912, 3192890, 3192891, 3192892, 3192893, 3192894, 3192895, 3192896, 3192897, 3192898, 3192899, 3192901, 3192902, 3192903, 3192904, 3192905", ["591:503:1566:1551"] = "3192856, 3192857, 3192858, 3192859, 3192860, 3192861", ["746:528:1793:1220"] = "3192941, 3192942, 3192943, 3192944, 3192945, 3192946, 3192947, 3192948, 3192949", ["783:542:1167:1387"] = "3192986, 3192990, 3192991, 3192992, 3192993, 3192994, 3192995, 3192996, 3192997, 3192987, 3192988, 3192989", ["804:564:1626:1949"] = "3192862, 3192866, 3192867, 3192868, 3192869, 3192870, 3192871, 3192872, 3192873, 3192863, 3192864, 3192865", ["826:494:2004:1590"] = "3192962, 3192963, 3192964, 3192965, 3192966, 3192967, 3192968, 3192969", ["839:558:1068:1768"] = "3192998, 3193002, 3193003, 3193004, 3193005, 3193006, 3193007, 3193008, 3193009, 3192999, 3193000, 3193001", ["881:911:2110:588"] = "3192970, 3192978, 3192979, 3192980, 3192981, 3192982, 3192983, 3192984, 3192985, 3192971, 3192972, 3192973, 3192974, 3192975, 3192976, 3192977", ["892:763:1975:155"] = "3192913, 3192917, 3192918, 3192919, 3192920, 3192921, 3192922, 3192923, 3192924, 3192914, 3192915, 3192916", ["984:847:1400:48"] = "3192925, 3192933, 3192934, 3192935, 3192936, 3192937, 3192938, 3192939, 3192940, 3192926, 3192927, 3192928, 3192929, 3192930, 3192931, 3192932", ["985:652:1475:706"] = "3192950, 3192954, 3192955, 3192956, 3192957, 3192958, 3192959, 3192960, 3192961, 3192951, 3192952, 3192953",}
			--[[ Ardenweald ]]	Leatrix_Maps["Reveal"][1338] = {["1179:1340:379:811"] = "3604311, 3604322, 3604333, 3604335, 3604336, 3604337, 3604338, 3604339, 3604340, 3604312, 3604313, 3604314, 3604315, 3604316, 3604317, 3604318, 3604319, 3604320, 3604321, 3604323, 3604324, 3604325, 3604326, 3604327, 3604328, 3604329, 3604330, 3604331, 3604332, 3604334", ["563:685:2107:638"] = "3604377, 3604378, 3604379, 3604380, 3604381, 3604382, 3604383, 3604384, 3604385", ["669:747:1993:885"] = "3604302, 3604303, 3604304, 3604305, 3604306, 3604307, 3604308, 3604309, 3604310", ["686:742:1487:945"] = "3604293, 3604294, 3604295, 3604296, 3604297, 3604298, 3604299, 3604300, 3604301", ["688:1139:1679:54"] = "3604262, 3604269, 3604270, 3604271, 3604272, 3604273, 3604274, 3604275, 3604276, 3604263, 3604264, 3604265, 3604266, 3604267, 3604268", ["770:603:1736:1234"] = "3604341, 3604345, 3604346, 3604347, 3604348, 3604349, 3604350, 3604351, 3604352, 3604342, 3604343, 3604344", ["798:896:1701:1607"] = "3604277, 3604285, 3604286, 3604287, 3604288, 3604289, 3604290, 3604291, 3604292, 3604278, 3604279, 3604280, 3604281, 3604282, 3604283, 3604284", ["803:645:2211:168"] = "3604353, 3604357, 3604358, 3604359, 3604360, 3604361, 3604362, 3604363, 3604364, 3604354, 3604355, 3604356", ["845:1048:1190:1242"] = "3604226, 3604237, 3604239, 3604240, 3604241, 3604242, 3604243, 3604244, 3604245, 3604227, 3604228, 3604229, 3604230, 3604231, 3604232, 3604233, 3604234, 3604235, 3604236, 3604238", ["847:783:1036:316"] = "3604198, 3604206, 3604207, 3604208, 3604209, 3604210, 3604211, 3604212, 3604213, 3604199, 3604200, 3604201, 3604202, 3604203, 3604204, 3604205", ["864:650:946:723"] = "3604365, 3604369, 3604370, 3604371, 3604372, 3604373, 3604374, 3604375, 3604376, 3604366, 3604367, 3604368", ["886:821:2339:1049"] = "3604246, 3604254, 3604255, 3604256, 3604257, 3604258, 3604259, 3604260, 3604261, 3604247, 3604248, 3604249, 3604250, 3604251, 3604252, 3604253", ["904:714:2338:474"] = "3604214, 3604218, 3604219, 3604220, 3604221, 3604222, 3604223, 3604224, 3604225, 3604215, 3604216, 3604217",}
			--[[ Revendreth ]]	Leatrix_Maps["Reveal"][1306] = {["1019:737:2290:474"] = "3730584, 3730588, 3730589, 3730590, 3730591, 3730592, 3730593, 3730594, 3730595, 3730585, 3730586, 3730587, 3730584, 3730588, 3730589, 3730590, 3730591, 3730592, 3730593, 3730594, 3730595, 3730585, 3730586, 3730587", ["1030:1129:1200:1407"] = "3730837, 3730848, 3730855, 3730856, 3730857, 3730858, 3730859, 3730860, 3730861, 3730838, 3730839, 3730840, 3730841, 3730842, 3730843, 3730844, 3730845, 3730846, 3730847, 3730849, 3730850, 3730851, 3730852, 3730853, 3730854, 3730837, 3730848, 3730855, 3730856, 3730857, 3730858, 3730859, 3730860, 3730861, 3730838, 3730839, 3730840, 3730841, 3730842, 3730843, 3730844, 3730845, 3730846, 3730847, 3730849, 3730850, 3730851, 3730852, 3730853, 3730854", ["1087:878:869:1682"] = "3730730, 3730741, 3730743, 3730744, 3730745, 3730746, 3730747, 3730748, 3730749, 3730731, 3730732, 3730733, 3730734, 3730735, 3730736, 3730737, 3730738, 3730739, 3730740, 3730742, 3730730, 3730741, 3730743, 3730744, 3730745, 3730746, 3730747, 3730748, 3730749, 3730731, 3730732, 3730733, 3730734, 3730735, 3730736, 3730737, 3730738, 3730739, 3730740, 3730742", ["1192:963:485:0"] = "3730707, 3730718, 3730720, 3730721, 3730725, 3730726, 3730727, 3730728, 3730729, 3730708, 3730709, 3730710, 3730711, 3730712, 3730713, 3730714, 3730715, 3730716, 3730717, 3730719", ["1207:1465:433:596"] = "3730807, 3730818, 3730829, 3730831, 3730832, 3730833, 3730834, 3730835, 3730836, 3730808, 3730809, 3730810, 3730811, 3730812, 3730813, 3730814, 3730815, 3730816, 3730817, 3730819, 3730820, 3730821, 3730822, 3730823, 3730824, 3730825, 3730826, 3730827, 3730828, 3730830, 3730807, 3730818, 3730829, 3730831, 3730832, 3730833, 3730834, 3730835, 3730836, 3730808, 3730809, 3730810, 3730811, 3730812, 3730813, 3730814, 3730815, 3730816, 3730817, 3730819, 3730820, 3730821, 3730822, 3730823, 3730824, 3730825, 3730826, 3730827, 3730828, 3730830", ["1339:746:1974:919"] = "3730750, 3730760, 3730761, 3730762, 3730763, 3730764, 3730765, 3730766, 3730767, 3730751, 3730752, 3730753, 3730754, 3730755, 3730756, 3730757, 3730758, 3730759, 3730750, 3730760, 3730761, 3730762, 3730763, 3730764, 3730765, 3730766, 3730767, 3730751, 3730752, 3730753, 3730754, 3730755, 3730756, 3730757, 3730758, 3730759", ["586:1091:1306:555"] = "3730641, 3730648, 3730649, 3730650, 3730651, 3730652, 3730653, 3730657, 3730669, 3730642, 3730643, 3730644, 3730645, 3730646, 3730647",  ["685:688:1527:300"] = "3730685, 3730688, 3730690, 3730694, 3730695, 3730698, 3730701, 3730704, 3730706, 3730768, 3730769, 3730770, 3730771, 3730772, 3730773, 3730774, 3730775, 3730776, 3730768, 3730769, 3730770, 3730771, 3730772, 3730773, 3730774, 3730775, 3730776, 3730768, 3730769, 3730770, 3730771, 3730772, 3730773, 3730774, 3730775, 3730776", ["711:1183:1987:1377"] = "3730628, 3730633, 3730634, 3730635, 3730636, 3730637, 3730638, 3730639, 3730640, 3730629, 3730630, 3730631, 3730722, 3730723, 3730632", ["718:847:2597:1316"] = "3730596, 3730600, 3730601, 3730602, 3730603, 3730604, 3730605, 3730606, 3730607, 3730597, 3730598, 3730599, 3730596, 3730600, 3730601, 3730602, 3730603, 3730604, 3730605, 3730606, 3730607, 3730597, 3730598, 3730599", ["720:578:1487:1982"] = "3730777, 3730778, 3730779, 3730780, 3730781, 3730782, 3730783, 3730784, 3730785, 3730777, 3730778, 3730779, 3730780, 3730781, 3730782, 3730783, 3730784, 3730785", ["835:1040:2324:1520"] = "3730786, 3730797, 3730799, 3730800, 3730801, 3730802, 3730803, 3730804, 3730805, 3730787, 3730788, 3730789, 3730790, 3730791, 3730792, 3730793, 3730794, 3730795, 3730796, 3730798, 3730786, 3730797, 3730799, 3730800, 3730801, 3730802, 3730803, 3730804, 3730805, 3730787, 3730788, 3730789, 3730790, 3730791, 3730792, 3730793, 3730794, 3730795, 3730796, 3730798", ["885:1060:1647:484"] = "3730608, 3730619, 3730621, 3730622, 3730623, 3730624, 3730625, 3730626, 3730627, 3730609, 3730610, 3730611, 3730612, 3730613, 3730614, 3730615, 3730616, 3730617, 3730618, 3730620",}
			--[[ Maldraxxus ]]	Leatrix_Maps["Reveal"][1323] = {["1149:703:284:1085"] = "3745117, 3745124, 3745125, 3745126, 3745127, 3745128, 3745129, 3745130, 3745131, 3745118, 3745119, 3745120, 3745121, 3745122, 3745123", ["1194:998:2438:785"] = "3745289, 3745300, 3745302, 3745303, 3745304, 3745305, 3745306, 3745307, 3745308, 3745290, 3745291, 3745292, 3745293, 3745294, 3745295, 3745296, 3745297, 3745298, 3745299, 3745301", ["1231:1391:261:65"] = "3745353, 3745364, 3745375, 3745377, 3745378, 3745379, 3745380, 3745381, 3745382, 3745354, 3745355, 3745356, 3745357, 3745358, 3745359, 3745360, 3745361, 3745362, 3745363, 3745365, 3745366, 3745367, 3745368, 3745369, 3745370, 3745371, 3745372, 3745373, 3745374, 3745376", ["1363:1137:2232:13"] = "3745189, 3745200, 3745211, 3745213, 3745214, 3745215, 3745216, 3745217, 3745218, 3745190, 3745191, 3745192, 3745193, 3745194, 3745195, 3745196, 3745197, 3745198, 3745199, 3745201, 3745202, 3745203, 3745204, 3745205, 3745206, 3745207, 3745208, 3745209, 3745210, 3745212", ["1508:1209:330:1351"] = "3745219, 3745230, 3745241, 3745243, 3745244, 3745245, 3745246, 3745247, 3745248, 3745220, 3745221, 3745222, 3745223, 3745224, 3745225, 3745226, 3745227, 3745228, 3745229, 3745231, 3745232, 3745233, 3745234, 3745235, 3745236, 3745237, 3745238, 3745239, 3745240, 3745242", ["1925:1136:1582:1424"] = "3745249, 3745260, 3745271, 3745282, 3745284, 3745285, 3745286, 3745287, 3745288, 3745250, 3745251, 3745252, 3745253, 3745254, 3745255, 3745256, 3745257, 3745258, 3745259, 3745261, 3745262, 3745263, 3745264, 3745265, 3745266, 3745267, 3745268, 3745269, 3745270, 3745272, 3745273, 3745274, 3745275, 3745276, 3745277, 3745278, 3745279, 3745280, 3745281, 3745283", ["673:788:1171:836"] = "3745341, 3745345, 3745346, 3745347, 3745348, 3745349, 3745350, 3745351, 3745352, 3745342, 3745343, 3745344", ["694:666:1815:517"] = "3745132, 3745133, 3745134, 3745135, 3745136, 3745137, 3745138, 3745139, 3745140", ["719:802:2028:894"] = "3745141, 3745145, 3745146, 3745147, 3745148, 3745149, 3745150, 3745151, 3745152, 3745142, 3745143, 3745144", ["730:730:1566:862"] = "3745383, 3745384, 3745385, 3745386, 3745387, 3745388, 3745389, 3745390, 3745391", ["757:985:1551:1342"] = "3745309, 3745313, 3745314, 3745315, 3745316, 3745317, 3745318, 3745319, 3745320, 3745310, 3745311, 3745312", ["858:1178:1202:0"] = "3745321, 3745332, 3745334, 3745335, 3745336, 3745337, 3745338, 3745339, 3745340, 3745322, 3745323, 3745324, 3745325, 3745326, 3745327, 3745328, 3745329, 3745330, 3745331, 3745333", ["932:919:1692:0"] = "3745173, 3745181, 3745182, 3745183, 3745184, 3745185, 3745186, 3745187, 3745188, 3745174, 3745175, 3745176, 3745177, 3745178, 3745179, 3745180", ["951:1071:631:46"] = "3745153, 3745164, 3745166, 3745167, 3745168, 3745169, 3745170, 3745171, 3745172, 3745154, 3745155, 3745156, 3745157, 3745158, 3745159, 3745160, 3745161, 3745162, 3745163, 3745165",}
			--[[ The Maw ]]		Leatrix_Maps["Reveal"][1329] = {
				["1009:835:1442:1262"] = "3745832, 3745840, 3745841, 3745842, 3745843, 3745844, 3745845, 3745846, 3745847, 3745833, 3745834, 3745835, 3745836, 3745837, 3745838, 3745839,", 
				["1053:934:49:918"] = "3745893, 3745904, 3745906, 3745907, 3745908, 3745909, 3745910, 3745911, 3745912, 3745894, 3745895, 3745896, 3745897, 3745898, 3745899, 3745900, 3745901, 3745902, 3745903, 3745905,",
				["1078:824:772:598"] = "3746082, 3746093, 3746095, 3746096, 3746097, 3746098, 3746099, 3746100, 3746101, 3746083, 3746084, 3746085, 3746086, 3746087, 3746088, 3746089, 3746090, 3746091, 3746092, 3746094,", 
				["1186:821:1100:696"] = "3745873, 3745884, 3745886, 3745887, 3745888, 3745889, 3745890, 3745891, 3745892, 3745874, 3745875, 3745876, 3745877, 3745878, 3745879, 3745880, 3745881, 3745882, 3745883, 3745885,",
				["1232:1236:0:342"] = "3745848, 3745859, 3745866, 3745867, 3745868, 3745869, 3745870, 3745871, 3745872, 3745849, 3745850, 3745851, 3745852, 3745853, 3745854, 3745855, 3745856, 3745857, 3745858, 3745860, 3745861, 3745862, 3745863, 3745864, 3745865,",
				["1395:932:183:0"] = "3746024, 3746035, 3746041, 3746042, 3746043, 3746044, 3746045, 3746046, 3746047, 3746025, 3746026, 3746027, 3746028, 3746029, 3746030, 3746031, 3746032, 3746033, 3746034, 3746036, 3746037, 3746038, 3746039, 3746040,",
				["1408:988:1856:1572"] = "3746048, 3746059, 3746065, 3746066, 3746067, 3746068, 3746069, 3746070, 3746071, 3746049, 3746050, 3746051, 3746052, 3746053, 3746054, 3746055, 3746056, 3746057, 3746058, 3746060, 3746061, 3746062, 3746063, 3746064,",
				["1488:1946:1797:0"] = "3745913, 3745924, 3745935, 3745948, 3745959, 3745960, 3745961, 3745962, 3745963, 3745914, 3745915, 3745916, 3745917, 3745918, 3745919, 3745920, 3745921, 3745922, 3745923, 3745925, 3745926, 3745927, 3745928, 3745929, 3745930, 3745931, 3745932, 3745933, 3745934, 3745936, 3745937, 3745938, 3745939, 3745940, 3745942, 3745943, 3745944, 3745946, 3745947, 3745949, 3745950, 3745951, 3745953, 3745954, 3745955, 3745956, 3745957, 3745958,", 
				["1504:929:1171:0"] = "3745964, 3745975, 3745981, 3745982, 3745983, 3745984, 3745985, 3745986, 3745987, 3745965, 3745966, 3745967, 3745968, 3745969, 3745970, 3745971, 3745972, 3745973, 3745974, 3745976, 3745977, 3745978, 3745979, 3745980,",
				["928:1359:808:1201"] = "3746000, 3746011, 3746017, 3746018, 3746019, 3746020, 3746021, 3746022, 3746023, 3746001, 3746002, 3746003, 3746004, 3746005, 3746006, 3746007, 3746008, 3746009, 3746010, 3746012, 3746013, 3746014, 3746015, 3746016,", 
				["928:729:1404:1831"] = "3745988, 3745992, 3745993, 3745994, 3745995, 3745996, 3745997, 3745998, 3745999, 3745989, 3745990, 3745991,",
				["954:1076:262:1423"] = "3745812, 3745823, 3745825, 3745826, 3745827, 3745828, 3745829, 3745830, 3745831, 3745813, 3745814, 3745815, 3745816, 3745817, 3745818, 3745819, 3745820, 3745821, 3745822, 3745824,",
			}
			--[[ Korthia ]] 	Leatrix_Maps["Reveal"][1648] = {
				["1264:715:1841:645"] = "4075019, 4075026, 4075027, 4075028, 4075029, 4075030, 4075031, 4075032, 4075033, 4075020, 4075021, 4075022, 4075023, 4075024, 4075025", 
				["1362:1088:945:0"] = "4074977, 4074988, 4074999, 4075001, 4075002, 4075003, 4075004, 4075005, 4075006, 4074978, 4074979, 4074980, 4074981, 4074982, 4074983, 4074984, 4074985, 4074986, 4074987, 4074989, 4074990, 4074991, 4074992, 4074993, 4074994, 4074995, 4074996, 4074997, 4074998, 4075000", 
				["1412:792:1474:891"] = "4075034, 4075045, 4075051, 4075052, 4075053, 4075054, 4075055, 4075056, 4075057, 4075035, 4075036, 4075037, 4075038, 4075039, 4075040, 4075041, 4075042, 4075043, 4075044, 4075046, 4075047, 4075048, 4075049, 4075050", 
				["1612:1268:153:0"] = "4074926, 4074937, 4074948, 4074955, 4074956, 4074957, 4074958, 4074959, 4074960, 4074927, 4074928, 4074929, 4074930, 4074931, 4074932, 4074933, 4074934, 4074935, 4074936, 4074938, 4074939, 4074940, 4074941, 4074942, 4074943, 4074944, 4074945, 4074946, 4074947, 4074949, 4074950, 4074951, 4074952, 4074953, 4074954", 
				["1871:1010:1231:1429"] = "4075058, 4075069, 4075080, 4075084, 4075085, 4075086, 4075087, 4075088, 4075089, 4075059, 4075060, 4075061, 4075062, 4075063, 4075064, 4075065, 4075066, 4075067, 4075068, 4075070, 4075071, 4075072, 4075073, 4075074, 4075075, 4075076, 4075077, 4075078, 4075079, 4075081, 4075082, 4075083", 
				["766:637:958:997"] = "4074917, 4074918, 4074919, 4074920, 4074921, 4074922, 4074923, 4074924, 4074925", 
				["834:696:1500:0"] = "4075007, 4075011, 4075012, 4075013, 4075014, 4075015, 4075016, 4075017, 4075018, 4075008, 4075009, 4075010", 
				["844:875:2113:0"] = "4074961, 4074969, 4074970, 4074971, 4074972, 4074973, 4074974, 4074975, 4074976, 4074962, 4074963, 4074964, 4074965, 4074966, 4074967, 4074968", 
				["929:817:597:1053"] = "4075090, 4075098, 4075099, 4075100, 4075101, 4075102, 4075103, 4075104, 4075105, 4075091, 4075092, 4075093, 4075094, 4075095, 4075096, 4075097",
			}

			-- Create table to store revealed overlays
			local overlayTextures = {}
			local bfoverlayTextures = {}

			-- Function to refresh overlays (Blizzard_SharedMapDataProviders\MapExplorationDataProvider)
			local function MapExplorationPin_RefreshOverlays(pin, fullUpdate)
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

			-- Repeat refresh overlays function for Battlefield map
			local function bfMapExplorationPin_RefreshOverlays(pin, fullUpdate)
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
			LeaMapsLC:MakeSL(tintFrame, "tintRed", "Red", "Drag to set the amount of red.", 0, 1, 0.1, 36, -142, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintGreen", "Green", "Drag to set the amount of green.", 0, 1, 0.1, 36, -192, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintBlue", "Blue", "Drag to set the amount of blue.", 0, 1, 0.1, 206, -142, "%.1f")
			LeaMapsLC:MakeSL(tintFrame, "tintAlpha", "Opacity", "Drag to set the opacity.", 0.1, 1, 0.1, 206, -192, "%.1f")

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
					for i = 1, #overlayTextures  do
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
					for i = 1, #overlayTextures  do
						overlayTextures[i]:SetVertexColor(1, 1, 1)
						overlayTextures[i]:SetAlpha(1.0)
					end
					for i = 1, #bfoverlayTextures  do
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
			LeaMapsCB["tintRed"]:HookScript("OnMouseWheel", SetTintCol)
			LeaMapsCB["tintRed"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintGreen"]:HookScript("OnMouseWheel", SetTintCol)
			LeaMapsCB["tintGreen"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintBlue"]:HookScript("OnMouseWheel", SetTintCol)
			LeaMapsCB["tintBlue"]:HookScript("OnValueChanged", SetTintCol)
			LeaMapsCB["tintAlpha"]:HookScript("OnMouseWheel", SetTintCol)
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
				-- Prevent options panel from showing if Blizzard options panel is showing
				if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then return end
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
				icon = "Interface\\Worldmap\\UI-World-Icon",
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

			-- ShowMemoryUsage(LeaMapsLC["PageF"], "TOPLEFT", 16, -282)

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

			local expTitle = LeaMapsLC:MakeTx(interPanel, "Shadowlands", 0, 0)
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

			local pTex = interPanel:CreateTexture(nil, "BACKGROUND")
			pTex:SetAllPoints()
			pTex:SetTexture("Interface\\GLUES\\Models\\UI_MainMenu\\swordgradient2")
			pTex:SetAlpha(0.2)
			pTex:SetTexCoord(0, 1, 1, 0)

			InterfaceOptions_AddCategory(interPanel)

		end

		----------------------------------------------------------------------
		-- Final code
		----------------------------------------------------------------------

		-- Prevent tracked objectives, quest map button and boss buttons from being clicked during combat
		do 

			-- Quests
			local questHeaderClick = QUEST_TRACKER_MODULE.OnBlockHeaderClick
			function QUEST_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
				if not LeaMapsLC:PlayerInCombat() then
					questHeaderClick(self, block, mouseButton)
				end
			end

			-- Achievements
			local achieveHeaderClick = ACHIEVEMENT_TRACKER_MODULE.OnBlockHeaderClick
			function ACHIEVEMENT_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
				if not LeaMapsLC:PlayerInCombat() then
					achieveHeaderClick(self, block, mouseButton)
				end
			end

			-- Default
			local defaultHeaderClick = DEFAULT_OBJECTIVE_TRACKER_MODULE.OnBlockHeaderClick
			function DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
				if not LeaMapsLC:PlayerInCombat() then
					defaultHeaderClick(self, block, mouseButton)
				end
			end

			-- Quest map button (shown in quest detail pane)
			local questMapButton = QuestLogPopupDetailFrame.ShowMapButton:GetScript("OnClick")
			QuestLogPopupDetailFrame.ShowMapButton:SetScript("OnClick", function(self)
				if not LeaMapsLC:PlayerInCombat() then
					questMapButton(self)
				end
			end)

			-- Boss buttons
			local ejPinClick = EncounterJournalPinMixin.OnClick
			function EncounterJournalPinMixin:OnClick()
				if not LeaMapsLC:PlayerInCombat() then
					ejPinClick(self)
				end
			end

		end

		-- Show first run message
		if not LeaMapsDB["FirstRunMessageSeen"] then
			C_Timer.After(1, function()
				LeaMapsLC:Print(L["Enter"] .. " |cff00ff00" .. "/ltm" .. "|r " .. L["or click the minimap button to open Leatrix Maps."])
				LeaMapsDB["FirstRunMessageSeen"] = true
			end)
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
		Side:SetSize(470, 380)
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
		local reloadb = LeaMapsLC:CreateButton("ConfigReload", Side, "Reload", "BOTTOMRIGHT", -16, 10, 25)
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
		LeaMapsLC:CreateBar("MainTexture", Side, 470, 333, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

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
		if not self:IsEnabled() then return end
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
		if not self:IsEnabled() then return end
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

	-- Check if player is in combat
	function LeaMapsLC:PlayerInCombat()
		if UnitAffectingCombat("player") then
			LeaMapsLC:Print("You cannot do that in combat.")
			return true
		end
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
			-- Option requires UI reload
			if LeaMapsLC[option] ~= LeaMapsDB[option] or LeaMapsLC[option] == "Off" then
				LeaMapsLC:LockItem(LeaMapsCB[item], true)
			else
				LeaMapsLC:LockItem(LeaMapsCB[item], false)
			end

		else
			-- Option does not require UI reload
			if LeaMapsLC[option] == "Off" then
				LeaMapsLC:LockItem(LeaMapsCB[item], true)
			else
				LeaMapsLC:LockItem(LeaMapsCB[item], false)
			end
		end
	end

	-- Set lock state for configuration buttons
	function LeaMapsLC:SetDim()
		LeaMapsLC:LockOption("RevealMap", "RevTintBtn", true)					-- Shiw unexplored areas
		LeaMapsLC:LockOption("UnlockMap", "UnlockMapBtn", true)					-- Unlock map frame
		LeaMapsLC:LockOption("ShowCoords", "ShowCoordsBtn", false)				-- Show coordinates
		LeaMapsLC:LockOption("EnhanceBattleMap", "EnhanceBattleMapBtn", true) 	-- Enhance battlefield map
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
		mbtn:GetNormalTexture():SetTexCoord(0.5, 1, 0, 1)
		mbtn:SetHighlightTexture("Interface\\AddOns\\Leatrix_Maps\\Leatrix_Maps.blp")
		mbtn:GetHighlightTexture():SetTexCoord(0, 0.5, 0, 1)

		-- Hide the default textures
		mbtn:HookScript("OnShow", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnEnable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnDisable", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseDown", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)
		mbtn:HookScript("OnMouseUp", function() mbtn.Left:Hide(); mbtn.Middle:Hide(); mbtn.Right:Hide() end)

		return mbtn
	end

	-- Set reload button status
	function LeaMapsLC:ReloadCheck()
		if	(LeaMapsLC["NoMapBorder"] ~= LeaMapsDB["NoMapBorder"])				-- Remove map border
		or	(LeaMapsLC["UnlockMap"] ~= LeaMapsDB["UnlockMap"])					-- Unlock map
		or	(LeaMapsLC["RevealMap"] ~= LeaMapsDB["RevealMap"])					-- Show unexplored areas
		or	(LeaMapsLC["ShowIcons"] ~= LeaMapsDB["ShowIcons"])					-- Show dungeons and raids
		or	(LeaMapsLC["HideTownCity"] ~= LeaMapsDB["HideTownCity"])			-- Hide town and city icons
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
		if width then text:SetWidth(width) end
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
			if Cbox.f:GetWidth() > 172 then
				Cbox.f:SetWidth(172)
			end
			-- Set checkbox click width
			if Cbox.f:GetStringWidth() > 172 then
				Cbox:SetHitRectInsets(0, -162, 0, 0)
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
		CfgBtn.t:SetTexCoord(0, 0.50, 0, 0.50)
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
		local Slider = CreateFrame("Slider", "LeaMapsGlobalSlider" .. field, frame, "OptionssliderTemplate")
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

		-- Remove slider text
		_G[Slider:GetName().."Low"]:SetText('')
		_G[Slider:GetName().."High"]:SetText('')

		-- Set label
		_G[Slider:GetName().."Text"]:SetText(L[label])

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
				SetCVar("mapFade", "1")
				wipe(LeaMapsDB)
				LeaMapsLC["NoSaveSettings"] = true
				ReloadUI()
			elseif str == "debug" then
				-- Toggle debug mode
				if LeaMapsLC["DebugMode"] then
					LeaMapsLC["DebugMode"] = nil
					if GetCVar("showDungeonEntrancesOnMap") ~= "0" then
						SetCVar("showDungeonEntrancesOnMap", "0")
					end
					LeaMapsLC:Print(L["Debug"] .. "|cffffffff " .. L["disabled"] .. "|r.")
				else
					LeaMapsLC["DebugMode"] = true
					LeaMapsLC:Print(L["Debug"] .. "|cffffffff " .. L["enabled"] .. "|r.")
				end
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
				-- Show admin commands
				LeaMapsLC:Print("reset - Reset panel position")
				LeaMapsLC:Print("wipe - Wipe addon settings")
				LeaMapsLC:Print("debug - Lets you enable dungeon icons in world map settings")
				LeaMapsLC:Print("setmap <id> - Show map ID <id>")
				LeaMapsLC:Print("admin - Load admin profile")
				return
			elseif str == "admin" then
				-- Preset profile (reload required)
				LeaMapsLC["NoSaveSettings"] = true
				wipe(LeaMapsDB)

				-- Mechanics
				LeaMapsDB["NoMapBorder"] = "On"
				LeaMapsDB["UnlockMap"] = "On"
				LeaMapsDB["EnableMovement"] = "On"
				LeaMapsDB["MapScale"] = 1.0
				LeaMapsDB["MaxMapScale"] = 0.9
				LeaMapsDB["StickyMapFrame"] = "Off"
				LeaMapsDB["RememberZoom"] = "On"
				LeaMapsDB["CenterMapOnPlayer"] = "On"
				LeaMapsDB["NoMapFade"] = "On"
				LeaMapsDB["NoMapEmote"] = "On"
				LeaMapsDB["MapPosA"] = "TOPLEFT"
				LeaMapsDB["MapPosR"] = "TOPLEFT"
				LeaMapsDB["MapPosX"] = 16
				LeaMapsDB["MapPosY"] = -94
				LeaMapsDB["MaxMapPosA"] = "CENTER"
				LeaMapsDB["MaxMapPosR"] = "CENTER"
				LeaMapsDB["MaxMapPosX"] = 0
				LeaMapsDB["MaxMapPosY"] = 0

				-- Elements
				LeaMapsDB["RevealMap"] = "On"
				LeaMapsDB["RevTint"] = "On"
				LeaMapsDB["tintRed"] = 0.6
				LeaMapsDB["tintGreen"] = 0.6
				LeaMapsDB["tintBlue"] = 1.0
				LeaMapsDB["tintAlpha"] = 1.0
				LeaMapsDB["ShowIcons"] = "On"
				LeaMapsDB["ShowCoords"] = "On"
				LeaMapsDB["CoordsLargeFont"] = "On"
				LeaMapsDB["CoordsBackground"] = "On"
				LeaMapsDB["HideTownCity"] = "On"

				-- More
				LeaMapsDB["EnhanceBattleMap"] = "On"
				LeaMapsDB["UnlockBattlefield"] = "On"
				LeaMapsDB["BattleMapWidth"] = 300
				LeaMapsDB["BattleCenterOnPlayer"] = "On"
				LeaMapsDB["BattleGroupIconSize"] = 8
				LeaMapsDB["BattlePlayerArrowSize"] = 12
				LeaMapsDB["BattleMapOpacity"] = 1
				LeaMapsDB["BattleMapA"] = "BOTTOMRIGHT"
				LeaMapsDB["BattleMapR"] = "BOTTOMRIGHT"
				LeaMapsDB["BattleMapX"] = -47
				LeaMapsDB["BattleMapY"] = 83

				LeaMapsDB["ShowMinimapIcon"] = "On"
				LeaMapsDB["minimapPos"] = 204 -- LeaMapsDB

				ReloadUI()
			elseif str == "help" then
				-- Show available commands
				LeaMapsLC:Print("Leatrix Maps" .. "|n")
				LeaMapsLC:Print(L["Version"] .. " " .. LeaMapsLC["AddonVer"] .. "|n|n")
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
			-- Prevent options panel from showing if a game options panel is showing
			if InterfaceOptionsFrame:IsShown() or VideoOptionsFrame:IsShown() or ChatConfigFrame:IsShown() then return end
			-- Prevent options panel from showing if Blizzard Store is showing
			if StoreFrame and StoreFrame:GetAttribute("isshown") then return end
			-- Toggle the options panel if game options panel is not showing
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
	eFrame:RegisterEvent("ADDON_LOADED")
	eFrame:RegisterEvent("PLAYER_LOGIN")
	eFrame:RegisterEvent("PLAYER_LOGOUT")
	eFrame:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	eFrame:SetScript("OnEvent", function(self, event, arg1)

		if event == "ADDON_LOADED" and arg1 == "Leatrix_Maps" then
			-- Load settings or set defaults
			LeaMapsLC:LoadVarChk("NoMapBorder", "Off")					-- Remove map border
			LeaMapsLC:LoadVarChk("UnlockMap", "Off")					-- Unlock map frame
			LeaMapsLC:LoadVarChk("EnableMovement", "On")				-- Enable frame movement
			LeaMapsLC:LoadVarNum("MapScale", 1.0, 0.5, 2)				-- Map scale
			LeaMapsLC:LoadVarNum("MaxMapScale", 0.9, 0.5, 2)			-- Maximised map scale
			LeaMapsLC:LoadVarChk("StickyMapFrame", "Off")				-- Sticky map frame
			LeaMapsLC:LoadVarChk("RememberZoom", "On")					-- Remember zoom level
			LeaMapsLC:LoadVarChk("CenterMapOnPlayer", "Off")			-- Center map on player
			LeaMapsLC:LoadVarChk("NoMapFade", "On")						-- Disable map fade
			LeaMapsLC:LoadVarChk("NoMapEmote", "On")					-- Disable map emote
			LeaMapsLC:LoadVarAnc("MapPosA", "TOPLEFT")					-- Windowed map anchor
			LeaMapsLC:LoadVarAnc("MapPosR", "TOPLEFT")					-- Windowed map relative
			LeaMapsLC:LoadVarNum("MapPosX", 16, -5000, 5000)			-- Windowed map X
			LeaMapsLC:LoadVarNum("MapPosY", -94, -5000, 5000)			-- Windowed map Y
			LeaMapsLC:LoadVarAnc("MaxMapPosA", "CENTER")				-- Maximised map anchor
			LeaMapsLC:LoadVarAnc("MaxMapPosR", "CENTER")				-- Maximised map relative
			LeaMapsLC:LoadVarNum("MaxMapPosX", 0, -5000, 5000)			-- Maximised map X
			LeaMapsLC:LoadVarNum("MaxMapPosY", 0, -5000, 5000)			-- Maximised map Y

			-- Elements
			LeaMapsLC:LoadVarChk("RevealMap", "On")						-- Show unexplored areas
			LeaMapsLC:LoadVarChk("RevTint", "On")						-- Tint revealed unexplored areas
			LeaMapsLC:LoadVarNum("tintRed", 0.6, 0, 1)					-- Tint red
			LeaMapsLC:LoadVarNum("tintGreen", 0.6, 0, 1)				-- Tint green
			LeaMapsLC:LoadVarNum("tintBlue", 1, 0, 1)					-- Tint blue
			LeaMapsLC:LoadVarNum("tintAlpha", 1, 0, 1)					-- Tint transparency
			LeaMapsLC:LoadVarChk("ShowIcons", "On")						-- Location icons
			LeaMapsLC:LoadVarChk("ShowCoords", "On")					-- Show coordinates
			LeaMapsLC:LoadVarChk("CoordsLargeFont", "Off")				-- Coordinates large font
			LeaMapsLC:LoadVarChk("CoordsBackground", "On")				-- Coordinates background
			LeaMapsLC:LoadVarChk("HideTownCity", "On")					-- Hide town and city icons

			-- More
			LeaMapsLC:LoadVarChk("EnhanceBattleMap", "Off")				-- Enhance battlefield map
			LeaMapsLC:LoadVarChk("UnlockBattlefield", "On")				-- Unlock battlefield map
			LeaMapsLC:LoadVarNum("BattleMapWidth", 300, 150, 900)		-- Resize battlefield map
			LeaMapsLC:LoadVarChk("BattleCenterOnPlayer", "Off")			-- Center map on player
			LeaMapsLC:LoadVarNum("BattleGroupIconSize", 8, 8, 16)		-- Battlefield group icon size
			LeaMapsLC:LoadVarNum("BattlePlayerArrowSize", 12, 12, 24)	-- Battlefield player arrow size
			LeaMapsLC:LoadVarNum("BattleMapOpacity", 1, 0.1, 1)			-- Battlefield map opacity
			LeaMapsLC:LoadVarAnc("BattleMapA", "BOTTOMRIGHT")			-- Battlefield map anchor
			LeaMapsLC:LoadVarAnc("BattleMapR", "BOTTOMRIGHT")			-- Battlefield map relative
			LeaMapsLC:LoadVarNum("BattleMapX", -47, -5000, 5000)		-- Battlefield map X axis
			LeaMapsLC:LoadVarNum("BattleMapY", 83, -5000, 5000)			-- Battlefield map Y axis

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

		elseif event == "PLAYER_LOGIN" then
			-- Run main function
			LeaMapsLC:MainFunc()

		elseif event == "PLAYER_LOGOUT" and not LeaMapsLC["NoSaveSettings"] then
			-- Mechanics
			LeaMapsDB["NoMapBorder"] = LeaMapsLC["NoMapBorder"]
			LeaMapsDB["UnlockMap"] = LeaMapsLC["UnlockMap"]
			LeaMapsDB["EnableMovement"] = LeaMapsLC["EnableMovement"]
			LeaMapsDB["MapScale"] = LeaMapsLC["MapScale"]
			LeaMapsDB["MaxMapScale"] = LeaMapsLC["MaxMapScale"]
			LeaMapsDB["StickyMapFrame"] = LeaMapsLC["StickyMapFrame"]
			LeaMapsDB["RememberZoom"] = LeaMapsLC["RememberZoom"]
			LeaMapsDB["CenterMapOnPlayer"] = LeaMapsLC["CenterMapOnPlayer"]
			LeaMapsDB["NoMapFade"] = LeaMapsLC["NoMapFade"]
			LeaMapsDB["NoMapEmote"] = LeaMapsLC["NoMapEmote"]
			LeaMapsDB["MapPosA"] = LeaMapsLC["MapPosA"]
			LeaMapsDB["MapPosR"] = LeaMapsLC["MapPosR"]
			LeaMapsDB["MapPosX"] = LeaMapsLC["MapPosX"]
			LeaMapsDB["MapPosY"] = LeaMapsLC["MapPosY"]
			LeaMapsDB["MaxMapPosA"] = LeaMapsLC["MaxMapPosA"]
			LeaMapsDB["MaxMapPosR"] = LeaMapsLC["MaxMapPosR"]
			LeaMapsDB["MaxMapPosX"] = LeaMapsLC["MaxMapPosX"]
			LeaMapsDB["MaxMapPosY"] = LeaMapsLC["MaxMapPosY"]

			-- Elements
			LeaMapsDB["RevealMap"] = LeaMapsLC["RevealMap"]
			LeaMapsDB["RevTint"] = LeaMapsLC["RevTint"]
			LeaMapsDB["tintRed"] = LeaMapsLC["tintRed"]
			LeaMapsDB["tintGreen"] = LeaMapsLC["tintGreen"]
			LeaMapsDB["tintBlue"] = LeaMapsLC["tintBlue"]
			LeaMapsDB["tintAlpha"] = LeaMapsLC["tintAlpha"]
			LeaMapsDB["ShowIcons"] = LeaMapsLC["ShowIcons"]
			LeaMapsDB["ShowCoords"] = LeaMapsLC["ShowCoords"]
			LeaMapsDB["CoordsLargeFont"] = LeaMapsLC["CoordsLargeFont"]
			LeaMapsDB["CoordsBackground"] = LeaMapsLC["CoordsBackground"]
			LeaMapsDB["HideTownCity"] = LeaMapsLC["HideTownCity"]

			-- More
			LeaMapsDB["EnhanceBattleMap"] = LeaMapsLC["EnhanceBattleMap"]
			LeaMapsDB["UnlockBattlefield"] = LeaMapsLC["UnlockBattlefield"]
			LeaMapsDB["BattleMapWidth"] = LeaMapsLC["BattleMapWidth"]
			LeaMapsDB["BattleCenterOnPlayer"] = LeaMapsLC["BattleCenterOnPlayer"]
			LeaMapsDB["BattleGroupIconSize"] = LeaMapsLC["BattleGroupIconSize"]
			LeaMapsDB["BattlePlayerArrowSize"] = LeaMapsLC["BattlePlayerArrowSize"]
			LeaMapsDB["BattleMapOpacity"] = LeaMapsLC["BattleMapOpacity"]
			LeaMapsDB["BattleMapA"] = LeaMapsLC["BattleMapA"]
			LeaMapsDB["BattleMapR"] = LeaMapsLC["BattleMapR"]
			LeaMapsDB["BattleMapX"] = LeaMapsLC["BattleMapX"]
			LeaMapsDB["BattleMapY"] = LeaMapsLC["BattleMapY"]

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
	PageF:SetSize(470, 380)
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
	MainTexture:SetSize(470, 333)
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
	PageF.v:SetNonSpaceWrap(true); PageF.v:SetText(L["Version"] .. " " .. LeaMapsLC["AddonVer"])

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
	LeaMapsLC:MakeTx(PageF, "Mechanics", 16, -72)
	LeaMapsLC:MakeCB(PageF, "NoMapBorder", "Remove map border", 16, -92, true, "If checked, the map border will be removed.")
	LeaMapsLC:MakeCB(PageF, "UnlockMap", "Unlock map frame", 16, -112, true, "If checked, you will be able to move and scale the map.|n|nThe map position and scale will be saved separately for the maximised and windowed maps.")
	LeaMapsLC:MakeCB(PageF, "RememberZoom", "Remember zoom level", 16, -132, false, "If checked, opening the map will use the same zoom level from when you last closed it as long as the map zone has not changed.")
	LeaMapsLC:MakeCB(PageF, "CenterMapOnPlayer", "Center map on player", 16, -152, false, "If checked, the map will stay centered on your location as long as you are not dragging the map or in a dungeon.")
	LeaMapsLC:MakeCB(PageF, "NoMapFade", "Disable map fade", 16, -172, false, "If checked, the map will not fade while your character is moving.")
	LeaMapsLC:MakeCB(PageF, "NoMapEmote", "Disable reading emote", 16, -192, false, "If checked, your character will not perform the reading emote when you open the map.")

	LeaMapsLC:MakeTx(PageF, "Elements", 225, -72)
	LeaMapsLC:MakeCB(PageF, "RevealMap", "Show unexplored areas", 225, -92, true, "If checked, unexplored areas of the map will be shown on the world map and the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "ShowCoords", "Show coordinates", 225, -112, false, "If checked, coordinates will be shown.")
	LeaMapsLC:MakeCB(PageF, "ShowIcons", "Enhance dungeon icons", 225, -132, true, "If checked, dungeon, raid and portal icons will be positioned more accurately and there will be more of them.")
	LeaMapsLC:MakeCB(PageF, "HideTownCity", "Hide town and city icons", 225, -152, true, "If checked, town and city icons will not be shown on the continent maps.")

	LeaMapsLC:MakeTx(PageF, "More", 225, -192)
	LeaMapsLC:MakeCB(PageF, "EnhanceBattleMap", "Enhance battlefield map", 225, -212, true, "If checked, you will be able to customise the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "ShowMinimapIcon", "Show minimap button", 225, -232, false, "If checked, the minimap button will be shown.")

 	LeaMapsLC:CfgBtn("RevTintBtn", LeaMapsCB["RevealMap"])
 	LeaMapsLC:CfgBtn("UnlockMapBtn", LeaMapsCB["UnlockMap"])
 	LeaMapsLC:CfgBtn("ShowCoordsBtn", LeaMapsCB["ShowCoords"])
 	LeaMapsLC:CfgBtn("EnhanceBattleMapBtn", LeaMapsCB["EnhanceBattleMap"])
