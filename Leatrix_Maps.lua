
	----------------------------------------------------------------------
	-- 	Leatrix Maps 9.1.36 (29th December 2021)
	----------------------------------------------------------------------

	-- 10:Func, 20:Comm, 30:Evnt, 40:Panl

	-- Create global table
	_G.LeaMapsDB = _G.LeaMapsDB or {}

	-- Create local tables
	local LeaMapsLC, LeaMapsCB, LeaConfigList = {}, {}, {}

	-- Version
	LeaMapsLC["AddonVer"] = "9.1.36"

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

		-- This is used so that remember zoom level and center map on player work together for stubborn maps
		LeaMapsLC.ShouldZoomInstantly = 0

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
			LeaMapsLC:MakeCB(battleFrame, "BattleCenterOnPlayer", "Center map on player", 16, -112, false, "If checked, the battlefield map will stay centered on your location as long as you are not in a dungeon.|n|nYou can hold shift while panning the map to temporarily prevent it from centering.")

			LeaMapsLC:MakeSL(battleFrame, "BattleGroupIconSize", "Group Icons", "Drag to set the group icon size.", 8, 32, 1, 206, -172, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattlePlayerArrowSize", "Player Arrow", "Drag to set the player arrow size.", 12, 48, 1, 36, -172, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleMapSize", "Map Size", "Drag to set the battlefield map size.|n|nIf the map is unlocked, you can also resize the battlefield map by dragging the bottom-right corner.", 150, 1200, 1, 36, -232, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleMapOpacity", "Map Opacity", "Drag to set the battlefield map opacity.", 0.1, 1, 0.1, 206, -232, "%.0f")
			LeaMapsLC:MakeSL(battleFrame, "BattleMaxZoom", "Max Zoom", "Drag to set the maximum zoom level.|n|nOpen the battlefield map to see the maximum zoom level change as you drag the slider.", 1, 6, 0.1, 36, -292, "%.0f")

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
			-- Battlefield map maximum zoom
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
			-- Center map on player
			----------------------------------------------------------------------

			do

				local cTime = -1

				-- Function to update map
				local function cUpdate(self, elapsed)
					if cTime > 2 or cTime == -1 then
						if BattlefieldMapFrame.ScrollContainer:IsPanning() or IsShiftKeyDown() then return end
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
				local function SetCenterNow() if LeaMapsLC["BattleCenterOnPlayer"] == "On" then cTime = -1 end	end
				local function SetCenterSoon() if LeaMapsLC["BattleCenterOnPlayer"] == "On" then cTime = 1.7 end end

				BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseUp", SetCenterSoon)
				BattlefieldMapFrame:HookScript("OnShow", SetCenterNow)
				BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseWheel", SetCenterSoon)

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
				BattlefieldMapFrame.groupMembersDataProvider:SetUnitPinSize("player", LeaMapsLC["BattlePlayerArrowSize"])
				BattlefieldMapFrame.groupMembersDataProvider.pin:SynchronizePinSizes()
			end

			-- Set player arrow when option is changed and on startup
			LeaMapsCB["BattlePlayerArrowSize"]:HookScript("OnValueChanged", SetPlayerArrow)
			SetPlayerArrow()

			----------------------------------------------------------------------
			-- Group icons
			----------------------------------------------------------------------

			-- Function to set group icons
			local function FixGroupPin()

				-- Icons should be under the player arrow
				BattlefieldMapFrame.groupMembersDataProvider.pin.SetAppearanceField("party", "sublevel", 0)
				BattlefieldMapFrame.groupMembersDataProvider.pin.SetAppearanceField("raid", "sublevel", 0)

				-- Icon size
				BattlefieldMapFrame.groupMembersDataProvider:SetUnitPinSize("party", LeaMapsLC["BattleGroupIconSize"])
				BattlefieldMapFrame.groupMembersDataProvider:SetUnitPinSize("raid", LeaMapsLC["BattleGroupIconSize"])
				BattlefieldMapFrame.groupMembersDataProvider.pin:SynchronizePinSizes()

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
				LeaMapsLC["BattleMapSize"] = 300
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
					LeaMapsLC["BattleMapSize"] = 300
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
					if WorldMapFrame.ScrollContainer:IsPanning() or IsShiftKeyDown() then return end
					local position = C_Map.GetPlayerMapPosition(WorldMapFrame.mapID, "player")
					if position then
						local x, y = position.x, position.y
						if x then
							local minX, maxX, minY, maxY = WorldMapFrame.ScrollContainer:CalculateScrollExtentsAtScale(WorldMapFrame.ScrollContainer:GetCanvasScale())
							local cx = Clamp(x, minX, maxX)
							local cy = Clamp(y, minY, maxY)
							-- This is set in center map on player
							if LeaMapsLC.ShouldZoomInstantly == 1 then
								WorldMapFrame.ScrollContainer.currentScrollX = cx
								WorldMapFrame.ScrollContainer.targetScrollX = cx
								WorldMapFrame.ScrollContainer.currentScrollY = cy
								WorldMapFrame.ScrollContainer.targetScrollY = cy
								WorldMapFrame.ScrollContainer:InstantPanAndZoom(WorldMapFrame.ScrollContainer:GetCanvasScale(), cx, cy)
							else
								WorldMapFrame.ScrollContainer:SetPanTarget(cx, cy)
							end
							LeaMapsLC.ShouldZoomInstantly = 0
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
			local function SetCenterNow() if LeaMapsLC["CenterMapOnPlayer"] == "On" then cTime = -1 end	end
			local function SetCenterSoon() if LeaMapsLC["CenterMapOnPlayer"] == "On" then cTime = 1.7 end end

			WorldMapFrame.ScrollContainer:HookScript("OnMouseUp", SetCenterSoon)
			WorldMapFrame:HookScript("OnShow", SetCenterNow)
			WorldMapFrame.SidePanelToggle.CloseButton:HookScript("OnClick", SetCenterNow)
			WorldMapFrame.SidePanelToggle.OpenButton:HookScript("OnClick", SetCenterNow)
			WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", SetCenterSoon)

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
				if not WorldMapFrame.mapID then
					local mapID = C_Map.GetBestMapForUnit("player")
					if mapID and mapID > 0 then WorldMapFrame:SetMapID(mapID) else WorldMapFrame:SetMapID(1) end
				end
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
						local desiredScale = currentScale * self.baseScale
						if desiredScale == 0 then
							desiredScale = 1
						end
						table.insert(self.zoomLevels, {scale = desiredScale, layerIndex = layerIndex})
					end
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
						-- if fullUpdate then
							-- Prevent pointer ring glitch with toggle quest log button
							-- WorldMapFrame.ScrollContainer:InstantPanAndZoom(lastZoomLevel, 0.5, 0.5)
						-- end
						WorldMapFrame.ScrollContainer.currentScale = lastScale
						WorldMapFrame.ScrollContainer.targetScale = lastScale
						WorldMapFrame.ScrollContainer.currentScrollX = lastHorizontal
						WorldMapFrame.ScrollContainer.targetScrollX = lastHorizontal
						WorldMapFrame.ScrollContainer.currentScrollY = lastVertical
						WorldMapFrame.ScrollContainer.targetScrollY = lastVertical
						WorldMapFrame.ScrollContainer:InstantPanAndZoom(lastZoomLevel, lastHorizontal, lastVertical)
						WorldMapFrame:OnMapChanged()
						-- This is used by center map on player
						if WorldMapFrame:ShouldZoomInstantly() then
							LeaMapsLC.ShouldZoomInstantly = 1
						else
							LeaMapsLC.ShouldZoomInstantly = 0
						end
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

			-- Get table from file
			local PinData = Leatrix_Maps["Icons"]

			-- Create table
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

							local myPOI = {}

							-- Dungeon - Horde
							if pinInfo[1] == "DungeonH" and playerFaction == "Horde" then
								myPOI["atlasName"] = "Dungeon"
								myPOI["journalID"] = pinInfo[6]

							-- Dungeon - Alliance
							elseif pinInfo[1] == "DungeonA" and playerFaction == "Alliance" then
								myPOI["atlasName"] = "Dungeon"
								myPOI["journalID"] = pinInfo[6]

							-- Dungeon - Neutral
							elseif pinInfo[1] == "Dungeon" then
								myPOI["atlasName"] = "Dungeon"
								myPOI["journalID"] = pinInfo[6]

							-- Raid - Horde
							elseif pinInfo[1] == "RaidH" and playerFaction == "Horde" then
								myPOI["atlasName"] = "Raid"
								myPOI["journalID"] = pinInfo[6]

							-- Raid - Alliance
							elseif pinInfo[1] == "RaidA" and playerFaction == "Alliance" then
								myPOI["atlasName"] = "Raid"
								myPOI["journalID"] = pinInfo[6]

							-- Raid - Neutral
							elseif pinInfo[1] == "Raid" then
								myPOI["atlasName"] = "Raid"
								myPOI["journalID"] = pinInfo[6]

							-- Portal - Horde
							elseif pinInfo[1] == "PortalH" and playerFaction == "Horde" then
								myPOI["atlasName"] = "TaxiNode_Continent_Horde"
								if pinInfo[7] and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) then myPOI["atlasName"] = nil end -- Do nothing if first quest not completed
								if pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then myPOI["atlasName"] = nil end -- Do nothing if second quest is completed

							-- Portal - Alliance
							elseif pinInfo[1] == "PortalA" and playerFaction == "Alliance" then
								myPOI["atlasName"] = "TaxiNode_Continent_Alliance"
								if pinInfo[7] and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) then myPOI["atlasName"] = nil end -- Do nothing if first quest not completed
								if pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then myPOI["atlasName"] = nil end -- Do nothing if second quest is completed

							-- Portal - Neutral
							elseif pinInfo[1] == "PortalN" then
								myPOI["atlasName"] = "TaxiNode_Continent_Neutral"
								if pinInfo[7] and not C_QuestLog.IsQuestFlaggedCompleted(pinInfo[7]) then myPOI["atlasName"] = nil end -- Do nothing if first quest not completed
								if pinInfo[8] and C_QuestLog.IsQuestFlaggedCompleted(pinInfo[8]) then myPOI["atlasName"] = nil end -- Do nothing if second quest is completed

							-- Chest
							elseif pinInfo[1] == "Chest" then
								myPOI["atlasName"] = "ChallengeMode-icon-chest"

							-- Arrow
							elseif pinInfo[1] == "Arrow" then
								myPOI["atlasName"] = "Garr_LevelUpgradeArrow"
								myPOI["journalID"] = pinInfo[7]

							-- Taxi - Neutral (as used in Korthia for Flayedwing Transporter)
							elseif pinInfo[1] == "TaxiN" then
								myPOI["atlasName"] = "warfront-neutralhero-gold"

							end

							-- Mandatory fields
							myPOI["position"] = CreateVector2D(pinInfo[2] / 100, pinInfo[3] / 100)
							myPOI["name"] = pinInfo[4]
							myPOI["description"] = pinInfo[5]

							-- Acquire the pin if it has a texture
							if myPOI["atlasName"] then
								local pin = self:GetMap():AcquirePin("LeaMapsGlobalPinTemplate", myPOI)
								pin.Texture:SetRotation(0)
								pin.HighlightTexture:SetRotation(0)
								if pinInfo[1] == "Arrow" then
									pin.Texture:SetRotation(pinInfo[6])
									pin.HighlightTexture:SetRotation(pinInfo[6])
								elseif pinInfo[1] == "TaxiN" then
									pin:SetSize(28, 28)
									pin.Texture:SetSize(28, 28)
									pin.HighlightTexture:SetSize(28, 28)
								end
							end

						end
					end

				end

			end

			_G.LeaMapsGlobalPinMixin = BaseMapPoiPinMixin:CreateSubPin("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE")

			function LeaMapsGlobalPinMixin:OnAcquired(myInfo)
				BaseMapPoiPinMixin.OnAcquired(self, myInfo)
				self.journalID = myInfo.journalID
			end

			function LeaMapsGlobalPinMixin:OnMouseUp(btn)
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
			--[[ The Maw (intro)]]	Leatrix_Maps["Reveal"][1329] = {
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
			--[[ The Maw (main)]]	Leatrix_Maps["Reveal"][1693] = {["1009:835:1442:1262"] = "4178838, 4178839, 4178840, 4178841, 4178842, 4178843, 4178844, 4178845, 4178846, 4178847, 4178848, 4178849, 4178850, 4178851, 4178852, 4178853", ["1053:934:49:918"] = "4178986, 4178987, 4178988, 4178989, 4178990, 4178991, 4178992, 4178993, 4178994, 4178995, 4178996, 4178997, 4178998, 4178999, 4179000, 4179001, 4179002, 4179003, 4179004, 4179005", ["1078:824:772:598"] = "4178966, 4178967, 4178968, 4178969, 4178970, 4178971, 4178972, 4178973, 4178974, 4178975, 4178976, 4178977, 4178978, 4178979, 4178980, 4178981, 4178982, 4178983, 4178984, 4178985", ["1186:821:1100:696"] = "4178946, 4178947, 4178948, 4178949, 4178950, 4178951, 4178952, 4178953, 4178954, 4178955, 4178956, 4178957, 4178958, 4178959, 4178960, 4178961, 4178962, 4178963, 4178964, 4178965", ["1232:1236:0:342"] = "4179006, 4179007, 4179008, 4179009, 4179010, 4179011, 4179012, 4179013, 4179014, 4179015, 4179016, 4179017, 4179018, 4179019, 4179020, 4179021, 4179022, 4179023, 4179024, 4179025, 4179026, 4179027, 4179028, 4179029, 4179030", ["1395:932:183:0"] = "4179031, 4179032, 4179033, 4179034, 4179035, 4179036, 4179037, 4179038, 4179039, 4179040, 4179041, 4179042, 4179043, 4179044, 4179045, 4179046, 4179047, 4179048, 4179049, 4179050, 4179051, 4179052, 4179053, 4179054", ["1408:988:1856:1572"] = "4178802, 4178803, 4178804, 4178805, 4178806, 4178807, 4178808, 4178809, 4178810, 4178811, 4178812, 4178813, 4178814, 4178815, 4178816, 4178817, 4178818, 4178819, 4178820, 4178821, 4178822, 4178823, 4178824, 4178825", ["1488:1946:1797:0"] = "4178854, 4178855, 4178856, 4178857, 4178858, 4178859, 4178860, 4178861, 4178862, 4178863, 4178864, 4178865, 4178866, 4178867, 4178868, 4178869, 4178870, 4178871, 4178872, 4178873, 4178874, 4178875, 4178876, 4178877, 4178878, 4178879, 4178880, 4178881, 4178882, 4178883, 4178884, 4178885, 4178886, 4178887, 4178888, 4178889, 4178890, 4178891, 4178892, 4178893, 4178894, 4178895, 4178896, 4178897, 4178898, 4178899, 4178900, 4178901", ["1504:929:1171:0"] = "4179055, 4179056, 4179057, 4179058, 4179059, 4179060, 4179061, 4179062, 4179063, 4179064, 4179065, 4179066, 4179067, 4179068, 4179069, 4179070, 4179071, 4179072, 4179073, 4179074, 4179075, 4179076, 4179077, 4179078", ["928:1359:808:1201"] = "4178922, 4178923, 4178924, 4178925, 4178926, 4178927, 4178928, 4178929, 4178930, 4178931, 4178932, 4178933, 4178934, 4178935, 4178936, 4178937, 4178938, 4178939, 4178940, 4178941, 4178942, 4178943, 4178944, 4178945", ["928:729:1404:1831"] = "4178826, 4178827, 4178828, 4178829, 4178830, 4178831, 4178832, 4178833, 4178834, 4178835, 4178836, 4178837", ["954:1076:262:1423"] = "4178902, 4178903, 4178904, 4178905, 4178906, 4178907, 4178908, 4178909, 4178910, 4178911, 4178912, 4178913, 4178914, 4178915, 4178916, 4178917, 4178918, 4178919, 4178920, 4178921",}
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

			--[[ Zereth Mortis ]] Leatrix_Maps["Reveal"][1650] = {
				["1008:726:1736:1363"] = "4261324, 4261328, 4261329, 4261330, 4261331, 4261332, 4261333, 4261334, 4261335, 4261325, 4261326, 4261327", ["1072:1207:269:730"] = "4261352, 4261363, 4261370, 4261371, 4261372, 4261373, 4261374, 4261375, 4261376, 4261353, 4261354, 4261355, 4261356, 4261357, 4261358, 4261359, 4261360, 4261361, 4261362, 4261364, 4261365, 4261366, 4261367, 4261368, 4261369", ["1117:1012:777:1548"] = "4261386, 4261397, 4261399, 4261400, 4261401, 4261402, 4261403, 4261404, 4261405, 4261387, 4261388, 4261389, 4261390, 4261391, 4261392, 4261393, 4261394, 4261395, 4261396, 4261398", ["1289:1364:364:57"] = "4261530, 4261544, 4261555, 4261563, 4261564, 4261565, 4261566, 4261567, 4261568, 4261531, 4261532, 4261533, 4261534, 4261535, 4261536, 4261538, 4261539, 4261541, 4261543, 4261545, 4261546, 4261547, 4261548, 4261549, 4261550, 4261551, 4261552, 4261553, 4261554, 4261556, 4261557, 4261558, 4261559, 4261560, 4261561, 4261562", ["1362:1236:2240:35"] = "4261488, 4261499, 4261510, 4261512, 4261513, 4261514, 4261515, 4261516, 4261517, 4261489, 4261490, 4261491, 4261492, 4261493, 4261494, 4261495, 4261496, 4261497, 4261498, 4261500, 4261501, 4261502, 4261503, 4261504, 4261505, 4261506, 4261507, 4261508, 4261509, 4261511", ["1709:1426:2072:665"] = "4261437, 4261448, 4261459, 4261470, 4261474, 4261475, 4261476, 4261477, 4261478, 4261438, 4261439, 4261440, 4261441, 4261442, 4261443, 4261444, 4261445, 4261446, 4261447, 4261449, 4261450, 4261451, 4261452, 4261453, 4261454, 4261455, 4261456, 4261457, 4261458, 4261460, 4261461, 4261462, 4261463, 4261464, 4261465, 4261466, 4261467, 4261468, 4261469, 4261471, 4261472, 4261473", ["516:516:2005:872"] = "4261479, 4261480, 4261481, 4261482, 4261483, 4261484, 4261485, 4261486, 4261487", ["563:715:1641:431"] = "4261569, 4261570, 4261571, 4261572, 4261573, 4261574, 4261575, 4261576, 4261577", ["579:479:1058:1264"] = "4261406, 4261407, 4261408, 4261409, 4261410, 4261411", ["582:590:1912:112"] = "4261336, 4261337, 4261338, 4261339, 4261340, 4261341, 4261349, 4261350, 4261351", ["629:554:900:1499"] = "4261412, 4261413, 4261414, 4261415, 4261416, 4261417, 4261418, 4261419, 4261420", ["649:666:1162:535"] = "4261283, 4261284, 4261285, 4261286, 4261287, 4261288, 4261289, 4261290, 4261291", ["736:755:1466:991"] = "4261377, 4261378, 4261379, 4261380, 4261381, 4261382, 4261383, 4261384, 4261385", ["823:628:1497:1932"] = "4261292, 4261296, 4261297, 4261298, 4261299, 4261300, 4261301, 4261302, 4261303, 4261293, 4261294, 4261295", ["880:1087:1924:140"] = "4261304, 4261315, 4261317, 4261318, 4261319, 4261320, 4261321, 4261322, 4261323, 4261305, 4261306, 4261307, 4261308, 4261309, 4261310, 4261311, 4261312, 4261313, 4261314, 4261316", ["928:910:1198:0"] = "4261421, 4261429, 4261430, 4261431, 4261432, 4261433, 4261434, 4261435, 4261436, 4261422, 4261423, 4261424, 4261425, 4261426, 4261427, 4261428", ["986:700:1841:1640"] = "4261518, 4261522, 4261523, 4261524, 4261525, 4261526, 4261527, 4261528, 4261529, 4261519, 4261520, 4261521",
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

		-- Hide the battlefield map tab because it's shown even when enhance battlefield map is disabled
		BattlefieldMapTab:Hide()

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
		Side:SetSize(470, 430)
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
		LeaMapsLC:CreateBar("MainTexture", Side, 470, 383, "TOPRIGHT", 0.7, 0.7, 0.7, 0.7,  "Interface\\ACHIEVEMENTFRAME\\UI-GuildAchievement-Parchment-Horizontal-Desaturated.png")

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
		LeaMapsLC:LockOption("IncreaseZoom", "IncreaseZoomBtn", false) 			-- Increase zoom level
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
				LeaMapsDB["NoMapBorder"] = "On"
				LeaMapsDB["UnlockMap"] = "On"
				LeaMapsDB["EnableMovement"] = "On"
				LeaMapsDB["MapScale"] = 1.0
				LeaMapsDB["MaxMapScale"] = 0.9
				LeaMapsDB["StickyMapFrame"] = "Off"
				LeaMapsDB["RememberZoom"] = "On"
				LeaMapsDB["IncreaseZoom"] = "On"
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
				LeaMapsDB["BattleMapSize"] = 300
				LeaMapsDB["BattleCenterOnPlayer"] = "On"
				LeaMapsDB["BattleGroupIconSize"] = 8
				LeaMapsDB["BattlePlayerArrowSize"] = 12
				LeaMapsDB["BattleMapOpacity"] = 1
				LeaMapsDB["BattleMaxZoom"] = 2
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
			LeaMapsLC:LoadVarChk("IncreaseZoom", "Off")					-- Increase zoom level
			LeaMapsLC:LoadVarNum("IncreaseZoomMax", 2, 1, 6)			-- Increase zoom level maximum
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
			LeaMapsLC:LoadVarNum("BattleMapSize", 300, 150, 1200)		-- Resize battlefield map
			LeaMapsLC:LoadVarChk("BattleCenterOnPlayer", "Off")			-- Center map on player
			LeaMapsLC:LoadVarNum("BattleGroupIconSize", 8, 8, 32)		-- Battlefield group icon size
			LeaMapsLC:LoadVarNum("BattlePlayerArrowSize", 12, 12, 48)	-- Battlefield player arrow size
			LeaMapsLC:LoadVarNum("BattleMapOpacity", 1, 0.1, 1)			-- Battlefield map opacity
			LeaMapsLC:LoadVarNum("BattleMaxZoom", 1, 1, 6)				-- Battlefield map zoom
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
			LeaMapsDB["IncreaseZoom"] = LeaMapsLC["IncreaseZoom"]
			LeaMapsDB["IncreaseZoomMax"] = LeaMapsLC["IncreaseZoomMax"]
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
	PageF:SetSize(470, 430)
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
	MainTexture:SetSize(470, 383)
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
	LeaMapsLC:MakeTx(PageF, "Appearance", 16, -72)
	LeaMapsLC:MakeCB(PageF, "NoMapBorder", "Remove map border", 16, -92, true, "If checked, the map border will be removed.")

	LeaMapsLC:MakeTx(PageF, "Zoom", 16, -132)
	LeaMapsLC:MakeCB(PageF, "RememberZoom", "Remember zoom level", 16, -152, false, "If checked, opening the map will use the same zoom level from when you last closed it as long as the map zone has not changed.")
	LeaMapsLC:MakeCB(PageF, "IncreaseZoom", "Increase zoom level", 16, -172, false, "If checked, you will be able to zoom further into the world map.")
	LeaMapsLC:MakeCB(PageF, "CenterMapOnPlayer", "Center map on player", 16, -192, false, "If checked, the map will stay centered on your location as long as you are not in a dungeon.|n|nYou can hold shift while panning the map to temporarily prevent it from centering.")

	LeaMapsLC:MakeTx(PageF, "System", 16, -232)
	LeaMapsLC:MakeCB(PageF, "UnlockMap", "Unlock map frame", 16, -252, true, "If checked, you will be able to move and scale the map.|n|nThe map position and scale will be saved separately for the maximised and windowed maps.")

	LeaMapsLC:MakeTx(PageF, "Elements", 225, -72)
	LeaMapsLC:MakeCB(PageF, "RevealMap", "Show unexplored areas", 225, -92, true, "If checked, unexplored areas of the map will be shown on the world map and the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "ShowCoords", "Show coordinates", 225, -112, false, "If checked, coordinates will be shown.")
	LeaMapsLC:MakeCB(PageF, "ShowIcons", "Enhance dungeon icons", 225, -132, true, "If checked, dungeon, raid and portal icons will be positioned more accurately and there will be more of them.")
	LeaMapsLC:MakeCB(PageF, "HideTownCity", "Hide town and city icons", 225, -152, true, "If checked, town and city icons will not be shown on the continent maps.")

	LeaMapsLC:MakeTx(PageF, "More", 225, -192)
	LeaMapsLC:MakeCB(PageF, "EnhanceBattleMap", "Enhance battlefield map", 225, -212, true, "If checked, you will be able to customise the battlefield map.")
	LeaMapsLC:MakeCB(PageF, "NoMapFade", "Disable map fade", 225, -232, false, "If checked, the map will not fade while your character is moving.")
	LeaMapsLC:MakeCB(PageF, "NoMapEmote", "Disable reading emote", 225, -252, false, "If checked, your character will not perform the reading emote when you open the map.")
	LeaMapsLC:MakeCB(PageF, "ShowMinimapIcon", "Show minimap button", 225, -272, false, "If checked, the minimap button will be shown.")

 	LeaMapsLC:CfgBtn("IncreaseZoomBtn", LeaMapsCB["IncreaseZoom"])
 	LeaMapsLC:CfgBtn("RevTintBtn", LeaMapsCB["RevealMap"])
 	LeaMapsLC:CfgBtn("UnlockMapBtn", LeaMapsCB["UnlockMap"])
 	LeaMapsLC:CfgBtn("ShowCoordsBtn", LeaMapsCB["ShowCoords"])
 	LeaMapsLC:CfgBtn("EnhanceBattleMapBtn", LeaMapsCB["EnhanceBattleMap"])
