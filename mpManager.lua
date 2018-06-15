-- 
-- MpManager 
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 15.06.2018
-- @Version: 1.0.0.1
-- 
-- @Support: LS-Modcompany
-- 
local version = "1.0.0.1 (15.06.2018)";

MpManager = {};
--_G["g_mpManager"] = MpManager;
getfenv(0)["g_mpManager"] = MpManager;
MpManager.dir = g_currentModDirectory;
addModEventListener(MpManager);

source(MpManager.dir .. "Debug.lua");
g_debug.write(-2, "load MpManager %s", version);

g_mpManager.updates = {};

-- Manager
source(MpManager.dir .. "manager/mpManagerLoadManager.lua");
source(MpManager.dir .. "manager/mpManagerSaveManager.lua");
source(MpManager.dir .. "manager/mpManagerModulManager.lua");

-- Classes
source(MpManager.dir .. "classes/mpManagerAdmin.lua");
source(MpManager.dir .. "classes/mpManagerFarm.lua");
source(MpManager.dir .. "classes/mpManagerUser.lua");
source(MpManager.dir .. "classes/mpManagerData.lua");
source(MpManager.dir .. "classes/mpManagerBill.lua");
source(MpManager.dir .. "classes/mpManagerTransfer.lua");

--Objects - General
source(MpManager.dir .. "objects/general/Assignables.lua");
source(MpManager.dir .. "objects/general/Displays.lua");
source(MpManager.dir .. "objects/general/Husbandry.lua");
source(MpManager.dir .. "objects/general/MoneyAssignment.lua");
source(MpManager.dir .. "objects/general/MoneyStats.lua");
source(MpManager.dir .. "objects/general/Settings.lua");
source(MpManager.dir .. "objects/general/Utils.lua");

--Objects
source(MpManager.dir .. "objects/Bga.lua");
source(MpManager.dir .. "objects/Placeables.lua");
source(MpManager.dir .. "objects/Storage.lua");

--Objects - Gui
source(MpManager.dir .. "objects/gui/ToggleButton.lua");

source(MpManager.dir .. "objects/vehicles/Vehicles.lua");

-- Gui
source(MpManager.dir .. "gui/mpManagerGui.lua");

-- Events
source(MpManager.dir .. "events/Event_startRequest.lua");
source(MpManager.dir .. "events/Event_Config.lua");
source(MpManager.dir .. "events/Event_VehicleSpec.lua");

source(MpManager.dir .. "events/Event_Admin.lua");
source(MpManager.dir .. "events/Event_Farm.lua");
source(MpManager.dir .. "events/Event_User.lua");
source(MpManager.dir .. "events/Event_Settings.lua");
source(MpManager.dir .. "events/Event_Husbandry.lua");
source(MpManager.dir .. "events/Event_Assignables.lua");
source(MpManager.dir .. "events/Event_MoneyAssignment.lua");
source(MpManager.dir .. "events/Event_MoneyStats.lua");
source(MpManager.dir .. "events/Event_Bill.lua");
source(MpManager.dir .. "events/Event_Transfer.lua");

local langXml = loadXMLFile("TempConfig", MpManager.dir .. "l10n" .. g_languageSuffix .. ".xml");
g_i18n:loadEntriesFromXML(langXml, "l10n.elements.e(%d)", "Warning: Duplicate text in l10n %s", g_i18n.globalI18N.texts);
	
function MpManager:loadMap()	
	MpManager:setConfig(false, true);
	MpManager.isConfigNow = "";
	MpManager.canShowGui = true;	
	
	g_mpManager.admin:load();
	g_mpManager.farm:load();
	g_mpManager.user:load();
	g_mpManager.data:load();
	g_mpManager.bill:load();
	g_mpManager.transfer:load();
	g_mpManager.gui:load();
	
	g_mpManager.assignabels:load();
	g_mpManager.settings:load();
	
	g_mpManager.moneyStats:load();
	g_mpManager.moneyAssignabels:load();
	g_mpManager.vehicles:load();
	
	g_mpManager.placeables:load();
	g_mpManager.husbandry:load();
	g_mpManager.mpManagerBga:load();
	g_mpManager.mpManagerStorage:load();
	
	g_mpManager.loadManager:loadSavegame();	
	
	g_mpManager.reloadScreen = false;
end;

function MpManager:addUpdateable(target, update)
	table.insert(g_mpManager.updates, {update=update, target=target});
end;

function MpManager:removeUpdateable(target, update)
	for key, u in pairs(g_mpManager.updates) do
		if u.target == target then
			table.remove(g_mpManager.updates, key);
			break;
		end;
	end;
end;

function MpManager:setCanShowGui(state, closeGui)
	MpManager.canShowGui = state;
	if not state and closeGui then
		g_gui:showGui("");
	end;
end;

function MpManager:update(dt) 
	g_mpManager.gui:update();
	g_currentMission:addHelpButtonText(g_i18n:getText("input_MPMANAGER"), InputBinding.MPMANAGER, nil, GS_PRIO_VERY_HIGH);
	if InputBinding.hasEvent(InputBinding.MPMANAGER) then
		if MpManager.isConfig and MpManager.canShowGui then
			g_gui:showGui("MpManagerScreen");
		else
			if MpManager.isConfigNow == "" then
				g_gui:showGui("MpManagerConfigScreen");
				MpManager:setConfigNow(g_currentMission.missionInfo.playerName);
			else
				-- Zeige Gui, wenn jemand im Konfigscreen ist. Anzeige Name.
				g_mpManager:showInfoDialog(string.format(g_i18n:getText("mpManagerConfig_error7"), MpManager.isConfigNow));
			end;
		end;
    end;
	
	if self.needUpdate == nil and g_client ~= nil and g_server == nil then
		if self.firstUpdate == nil then
			g_client:getServerConnection():sendEvent(clientToServerConnection:new());
			self.firstUpdate = true;
			self.needUpdate = false;
		end;
		
		if not g_mpManager.isConfig then
			if self.requestTimer == nil then
				self.requestTimer = 0;
			end;
			if self.requestTimer < 600 then
				self.requestTimer = self.requestTimer + 1;
			else
				g_client:getServerConnection():sendEvent(clientToServerConnection:new());
				self.needUpdate = false;
			end;
		end;	
	end;	
	
	if g_mpManager.isConfig then
		for _,update in pairs(g_mpManager.updates) do
			update.update(update.target, dt);
		end; 
	end;	
end;

function MpManager:breakConfig() 
	MpManager:setConfigNow("");
end;
function MpManager:setConfigNow(name, noEventSend) 
	MpManager_ConfigAdd_isConfigNow.sendEvent(name, noEventSend)
	MpManager.isConfigNow = name;
end;
function MpManager:setConfig(state, noEventSend) 
	MpManager_ConfigAdd_isConfig.sendEvent(state, noEventSend)
	MpManager.isConfig = state;
end;

function MpManager:finishConfig(noEventSend, adminPw, admins, farms, users, moneyFarm)
	g_mpManager.admin:setAdminPasswort(adminPw);
	for _,adminName in pairs(admins) do
		g_mpManager.admin:newAdmin(adminName);
	end;	
	for _,farm in pairs(farms) do
		g_mpManager.farm:newFarm(farm.farm, farm.leader, moneyFarm);
	end;
	for _,user in pairs(users) do
		g_mpManager.user:newUser(user.user, user.farm);
	end;
	MpManagement_Config_finishConfig.sendEvent(noEventSend)
	MpManager:setConfig(true, true);
	MpManager:breakConfig();
	g_mpManager.farm.defaultMoney = moneyFarm;
	g_mpManager.husbandry:loadDefault()
end;

--Dialogs
function MpManager:showInputDialog(header, text, buttonText, inputType, callback, target, dataTable) 
	local dialog = g_gui:showDialog("MpManagerInputScreen");
	dialog.target:setData(header, text, buttonText, inputType, dataTable);
	dialog.target:setCallback(callback, target);
	return dialog.target;
end;

function MpManager:showInfoDialog(text) 
	local dialog = g_gui:showDialog("MpManagerInfoScreen");
    dialog.target:setInfoText(text);
	return dialog.target;
end;

function MpManager:showCheckDialog(text, callbackOk, callbackBreak, target) 
	local dialog = g_gui:showDialog("MpManagerCheckScreen");
    dialog.target:setInfoText(text)
	dialog.target:setCallback(callbackOk, callbackBreak, target);
	return dialog.target;
end;

function MpManager:showMoneyAssignmentDialog(header, text, callback, target, dataTable, i) 
	local dialog = g_gui:showDialog("MpManagerMoneyAssignmentScreen");
	dialog.target:setData(header, text, dataTable, i);
	dialog.target:setCallback(callback, target);
	return dialog.target;
end;

function MpManager:showSelectionScreen(callback, target, data, num, header, t1, t2, t3) 
	local dialog = g_gui:showDialog("MpManagerSelectionScreen");
	dialog.target:setData(data, num, header, t1, t2, t3);
	dialog.target:setCallback(callback, target);
	return dialog.target;
end;

function MpManager:showMpManagerBillScreen(data) 
	local dialog = g_gui:showDialog("MpManagerBillScreen");
	dialog.target:setData(data);
	return dialog.target;
end;

function MpManager:showMpManagerTransferScreen(data, createNewTransfer) 
	local dialog = g_gui:showDialog("MpManagerTransferScreen");
	dialog.target:setData(data, createNewTransfer);
	return dialog.target;
end;

function MpManager:mouseEvent(posX, posY, isDown, isUp, button) end;
function MpManager:keyEvent(unicode, sym, modifier, isDown) end;
function MpManager:draw() end;
function MpManager:delete() end;
function MpManager:deleteMap() end;