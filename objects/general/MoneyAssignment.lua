-- 
-- MpManager - MoneyAssignment
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 21.06.2018
-- @Version: 1.1.0.0
-- 
-- @Support: LS-Modcompany
-- 

MoneyAssignment = {};
g_mpManager.moneyAssignabels = MoneyAssignment;

local counter = 0;
local function getNextNumber() counter = counter + 1; return counter; end;

MoneyAssignment.DLG_NOADDINFO = getNextNumber();
MoneyAssignment.DLG_TRAIN = getNextNumber();
MoneyAssignment.DLG_HANDTOOL = getNextNumber();
MoneyAssignment.DLG_PLACEABLE = getNextNumber();
MoneyAssignment.DLG_VEHICLE = getNextNumber();
MoneyAssignment.DLG_PALLETTRIGGER = getNextNumber();
MoneyAssignment.DLG_PICKUPOBJECTSSELLTRIGGER = getNextNumber();

MoneyAssignment.id = 0;
local function getNextId() MoneyAssignment.id = MoneyAssignment.id + 1; return MoneyAssignment.id; end;

function MoneyAssignment:load()
	MoneyAssignment.assignments = {};
	g_mpManager.saveManager:addSave(MoneyAssignment.saveSavegame, MoneyAssignment);
	g_mpManager.loadManager:addLoad(MoneyAssignment.loadSavegame, MoneyAssignment);
end;

function MoneyAssignment:addAssignment(id, statType, money, noEventSend)
	MpManagement_MoneyAssignment_AddAssignment.sendEvent(id, statType, money, noEventSend);
	MoneyAssignment.assignments[getNextId()] = {id=id, statType=statType, money=money, date=MoneyStats:getDate()};
end;

function MoneyAssignment:removeAssignment(id, playerName, noEventSend)
	if MoneyAssignment.assignments[id] == nil then return; end;
	MpManagement_MoneyAssignment_RemoveAssignment.sendEvent(id, playerName, noEventSend);
	
	local ass = MoneyAssignment.assignments[id]
	local farm = g_mpManager.utils:getFarmTblFromUsername(playerName);
	if farm == nil then
		g_debug.write(-1, "Can't remove assignment");
		return;
	end;
	local info = "-";
	if ass.id == MoneyAssignment.DLG_TRAIN then
		info = g_i18n:getText("mpManager_MoneyAssignment_train");
	elseif ass.id == MoneyAssignment.DLG_HANDTOOL then
		info = g_i18n:getText("mpManager_MoneyAssignment_handtool");
	elseif ass.id == MoneyAssignment.DLG_PLACEABLE then
		info = g_i18n:getText("mpManager_MoneyAssignment_placeable");
	elseif ass.id == MoneyAssignment.DLG_VEHICLE then
		info = g_i18n:getText("mpManager_MoneyAssignment_vehicle");
	elseif ass.id == MoneyAssignment.DLG_PALLETTRIGGER then
		info = g_i18n:getText("mpManager_MoneyAssignment_palletTrigger");
	elseif ass.id == MoneyAssignment.DLG_PICKUPOBJECTSSELLTRIGGER then
		info = g_i18n:getText("mpManager_MoneyAssignment_pickupObectsSellTrigger");
	end;	
	MoneyStats:addMoneyStatsToFarm(ass.date, playerName, farm, ass.statType, info, "-", "-", ass.money);
	farm:addMoney(ass.money);	
	MoneyAssignment.assignments[id] = nil;
end;

function MoneyAssignment:getAssignments()
	return MoneyAssignment.assignments;
end;

function MoneyAssignment:writeStream(streamId, connection)	
	streamWriteInt32(streamId, MoneyAssignment.id);
	streamWriteInt32(streamId, g_mpManager.utils:getTableLenght(MoneyAssignment.assignments));
	for assId,ass in pairs(MoneyAssignment.assignments) do
		streamWriteInt32(streamId, assId);
		streamWriteInt32(streamId, ass.id);
		streamWriteString(streamId, ass.statType);
		streamWriteInt32(streamId, ass.money);
	end;
end;

function MoneyAssignment:readStream(streamId, connection)
	MoneyAssignment.id = streamReadInt32(streamId);
	local num = streamReadInt32(streamId);
	for i=1, num do
		local assId = streamReadInt32(streamId);
		local id = streamReadInt32(streamId);
		local statType = streamReadString(streamId);
		local money = streamReadInt32(streamId);
		MoneyAssignment.assignments[assId] = {id=id, statType=statType, money=money};
	end;
end;

function MoneyAssignment:saveSavegame()
	local index = 0;
	for _,ass in pairs(MoneyAssignment.assignments) do
		g_mpManager.saveManager:setXmlInt(string.format("moneyAssignabels.assignment(%d)#id", index), ass.id);	
		g_mpManager.saveManager:setXmlString(string.format("moneyAssignabels.assignment(%d)#statType", index), ass.statType);
		g_mpManager.saveManager:setXmlInt(string.format("moneyAssignabels.assignment(%d)#money", index), ass.money);	
		g_mpManager.saveManager:setXmlString(string.format("moneyAssignabels.assignment(%d)#date", index), ass.date);			
		index = index + 1;
	end;
end;

function MoneyAssignment:loadSavegame()
	local index = 0;
	while true do
		local key = string.format("moneyAssignabels.assignment(%d)", index);
		if not g_mpManager.loadManager:hasXmlProperty(key) then
			break;
		end;
		local id = g_mpManager.loadManager:getXmlInt(key .. "#id");
		local statType = g_mpManager.loadManager:getXmlString(key .. "#statType");
		local money = g_mpManager.loadManager:getXmlInt(key .. "#money");
		local dat = g_mpManager.loadManager:getXmlString(key .. "#date");
		MoneyAssignment.assignments[getNextId()] = {id=id, statType=statType, money=money, date=dat};
		index = index + 1;
	end;
end;







