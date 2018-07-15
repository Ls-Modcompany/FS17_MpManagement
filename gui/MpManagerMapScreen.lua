-- 
-- MpManager - MpManagerMapScreen
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 12.07.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerMapScreen = {};

local MpManagerMapScreen_mt = Class(MpManagerMapScreen, ScreenElement);

function MpManagerMapScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerMapScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    return self;
end;

function MpManagerMapScreen:onCreate()	
end;

function MpManagerMapScreen:onClose(element)
    MpManagerMapScreen:superClass().onClose(self);
end

function MpManagerMapScreen:onOpen()
    MpManagerMapScreen:superClass().onOpen(self);
	self.inputDelay = 10;
	
	if fileExists(g_currentMission.baseDirectory.."modDesc.xml") then
		local xml = loadXMLFile("modDesc",g_currentMission.baseDirectory.."modDesc.xml","modDesc");
		local mapXml = loadXMLFile("map",g_currentMission.baseDirectory..getXMLString(xml, "modDesc.maps.map".."#configFilename"),"map"); 
		self.baseMapPDAwidth = getXMLInt(mapXml, "map.ingameMap".."#width");
	else
		self.baseMapPDAwidth = 2048;
	end;
	--print(Utils.getModNameAndBaseDirectory(g_currentMission.ingameMap.mapOverlay.filename));
	--self.gui_pda:setImageFilename(g_currentMission.ingameMap.mapOverlay.filename);
	--self.gui_pda.overlay.filename = g_currentMission.ingameMap.mapOverlay.filename;
	--GuiOverlay.createOverlay(self.gui_pda.overlay);
	--= Overlay:new("overlay", g_currentMission.ingameMap.mapOverlay.filename);
	self.pdaId = createImageOverlay(g_currentMission.ingameMap.mapOverlay.filename);
	local mapName = "Map";
	if g_currentMission.missionInfo ~= nil then
		mapName = tostring(g_currentMission.missionInfo.name);
		local map = MapsUtil.getMapById(g_currentMission.missionInfo.mapId);
		if map ~= nil then
			if g_currentMission.missionInfo:isa(FSCareerMissionInfo) then
				mapName = map.title;
			end;
		end
	end;
	self.gui_header:setText(mapName);
	
    FocusManager:setFocus(self.buttonOK);
end

function MpManagerMapScreen:update(dt)
    MpManagerMapScreen:superClass().update(self, dt);
	if self.inputDelay > 0 then
		self.inputDelay = self.inputDelay - 1;
	end;
end

function MpManagerMapScreen:draw()

	renderOverlay(self.pdaId, 0,0,0.5,0.5);
end;

function MpManagerMapScreen:onClickOk()
	if self.inputDelay <= 0 then
		g_gui:closeDialogByName("MpManagerMapScreen");
	end;
end;

function MpManagerMapScreen:setPos(x, y)
	
	-- g_currentMission.ingameMap.mapOverlay.filename
	
	-- local x,_,z = unpack(field.pos);
	-- x = 0.75 + (0.3 / FarmingTablet_App_Horsch.baseMapPDAwidth * x) - 0.0025;
	-- z = 0.4665 + (0.533 / FarmingTablet_App_Horsch.baseMapPDAwidth * -z) - 0.005; 
	-- renderOverlay(g_farmingTablet.button.getOverlayByModus_name("image", "on").id,x,z,0.005,0.01);
end;