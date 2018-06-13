-- 
-- MpManager -  Settings
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

Settings = {};
g_mpManager.settings = Settings;

function Settings:load()
	Settings.settings = {};

	local assignabelsBuildings = {
		name = "assignabelsBuildings",
		tbl = {
			g_i18n:getText("settings_1_1"),
			g_i18n:getText("settings_1_2")
		},
		active = 1,
	};
	table.insert(Settings.settings, assignabelsBuildings);
	
	local bills_create = {
		name = "bills_create",
		tbl = {
			g_i18n:getText("settings_20_1"),
			g_i18n:getText("settings_20_2")
		},
		active = 1,
	};
	table.insert(Settings.settings, bills_create);
	
	local bills_pay = {
		name = "bills_pay",
		tbl = {
			g_i18n:getText("settings_20_1"),
			g_i18n:getText("settings_20_2")
		},
		active = 2,
	};
	table.insert(Settings.settings, bills_pay);
	
	local transfers_create = {
		name = "transfers_create",
		tbl = {
			g_i18n:getText("settings_20_1"),
			g_i18n:getText("settings_20_2")
		},
		active = 2,
	};
	table.insert(Settings.settings, transfers_create);

end;

function Settings:getSetting(name)
	for _, setting in pairs(Settings.settings) do
		if setting.name == name then
			return setting;
		end;
	end;
end;

function Settings:setState(name, index, noEventSend)
	MpManagement_Settings_SetState.sendEvent(name, index, noEventSend);
	for _, setting in pairs(Settings.settings) do
		if setting.name == name then
			setting.active = index;
		end;
	end;
end;

function Settings:getState(name)
	for _, setting in pairs(Settings.settings) do
		if setting.name == name then
			return setting.active;
		end;
	end;
end;
function Settings:saveSavegame() 
	local index = 0;	
	for _, setting in pairs(Settings.settings) do
		g_mpManager.saveManager:setXmlString(string.format("settings.setting(%d)#name", index), setting.name);	
		g_mpManager.saveManager:setXmlInt(string.format("settings.setting(%d)#active", index), setting.active);	
		index = index + 1;
	end;
end;

function Settings:loadSavegame()
	local index = 0;
	while true do
		if not g_mpManager.loadManager:hasXmlProperty(string.format("settings.setting(%d)", index)) then
			break;
		end;		
		local name = g_mpManager.loadManager:getXmlString(string.format("settings.setting(%d)#name", index));
		local active = g_mpManager.loadManager:getXmlInt(string.format("settings.setting(%d)#active", index));
		Settings:setState(name, active, true);
		index = index + 1;
	end;
end;

function Settings:writeStream(streamId, connection)	
	streamWriteInt32(streamId, g_mpManager.utils:getTableLenght(Settings.settings));
	for _, setting in pairs(Settings.settings) do
		streamWriteString(streamId, setting.name);
		streamWriteInt32(streamId, setting.active);
	end;
end;

function Settings:readStream(streamId, connection)
	local num = streamReadInt32(streamId);
	for i=1, num do
		local name = streamReadString(streamId);
		local index = streamReadInt32(streamId);
		Settings:setState(name, index, true);
	end;
end;