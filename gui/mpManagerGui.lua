-- 
-- MpManager - Gui
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerGui = {};
g_mpManager.gui = MpManagerGui;

local guis = {
	"MpManagerScreen",
	"MpManagerConfigScreen",
	"MpManagerInfoScreen",
	"MpManagerInputScreen",
	"MpManagerCheckScreen",
	"MpManagerMoneyAssignmentScreen",
	"MpManagerBillScreen",
	"MpManagerTransferScreen",
	"MpManagerSelectionScreen",
	--"MpManagerMapScreen",
}

function MpManagerGui:load()
	--loadGuis
	MpManagerGui.guis = {};
	local path = MpManager.dir .. "gui/";
    g_gui:loadProfiles(path .. "guiProfiles.xml");	
	for _,gui in pairs(guis) do
		local guiPath = path .. gui;
		source(guiPath .. ".lua");
		local class = _G[gui];
		MpManagerGui.guis[gui] = class:new();
		g_gui:loadGui(guiPath .. ".xml", gui, MpManagerGui.guis[gui]);
	end;
	FocusManager:setGui("MPLoadingScreen");
	
	MpManagerGui.timer = 0;	
end;

function MpManagerGui:update(dt) 
	-- if MpManagerGui.timer > 100 then
		-- MpManagerGui.timer = 0;
		-- local path = MpManager.dir .. "gui/";
		-- g_gui:loadProfiles(path .. "guiProfiles.xml");	
		
		-- local langXml = loadXMLFile("TempConfig", MpManager.dir .. "l10n" .. g_languageSuffix .. ".xml");
		-- local textI = 0;
		-- while true do
			-- local key = string.format("l10n.elements.e(%d)", textI);
			-- if not hasXMLProperty(langXml, key) then
				-- break;
			-- end;
			-- local name = getXMLString(langXml, key.."#k");
			-- local text = getXMLString(langXml, key.."#v");
			-- if name ~= nil and text ~= nil then
				-- g_i18n.globalI18N.texts[name] = text:gsub("\r\n", "\n");
			-- end;
			-- textI = textI+1;
		-- end;
		
		-- for _,gui in pairs(guis) do
			-- local guiPath = path .. gui;
			-- local class = _G[gui];
			-- MpManagerGui.guis[gui] = class:new();
			-- g_gui:loadGui(guiPath .. ".xml", gui, MpManagerGui.guis[gui]);
		-- end;
		-- g_gui:showGui("MpManagerMapScreen")
	-- else
		-- MpManagerGui.timer = MpManagerGui.timer + 1;
	-- end;
end;
