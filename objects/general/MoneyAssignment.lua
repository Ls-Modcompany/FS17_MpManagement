-- 
-- MpManager - MoneyAssignment
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
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
	MoneyAssignment.dialogs = {};
	--MoneyAssignment.dialogsCallbackTarget = {};
	MoneyAssignment.header = g_i18n:getText("mpManager_MoneyAssignment_header");
	MoneyAssignment.textNeg = g_i18n:getText("mpManager_MoneyAssignment_textNeg");
	MoneyAssignment.textPos = g_i18n:getText("mpManager_MoneyAssignment_textPos");
	
	MoneyAssignment.currentId = 0;
	MoneyAssignment.readyForDlg = true;

	g_mpManager:addUpdateable(MoneyAssignment, MoneyAssignment.update);
end;

-- function MoneyAssignment:setCallbackTarget(id, callback, target)
	-- if MoneyAssignment.dialogsCallbackTarget[id] == nil then
		-- MoneyAssignment.dialogsCallbackTarget[id] = {};
	-- end;
	-- MoneyAssignment.dialogsCallbackTarget[id].callback = callback;
	-- MoneyAssignment.dialogsCallbackTarget[id].target = target;
-- end;

function MoneyAssignment:addDialog(id, statType, money, noEventSend)
	MpManagement_MoneyAssignment_AddDialog.sendEvent(id, statType, money, noEventSend);
	MoneyAssignment.dialogs[getNextId()] = {id=id, statType=statType, money=money};
end;

function MoneyAssignment:removeDialog(id, noEventSend)
	MpManagement_MoneyAssignment_RemoveDialog.sendEvent(id, noEventSend);
	if MoneyAssignment.currentId == id then
		MoneyAssignment.currentId = nil;
	end;
	MoneyAssignment.dialogs[id] = nil;
end;

function MoneyAssignment:callbackYes(farmname)	
	if MoneyAssignment.currentId ~= nil then
		local dlg = MoneyAssignment.dialogs[MoneyAssignment.currentId];
		local farm = g_mpManager.utils:getFarmTblFromFarmname(farmname);
		local info = "-";
		if dlg.id == MoneyAssignment.DLG_TRAIN then
			info = g_i18n:getText("mpManager_MoneyAssignment_train");
		elseif dlg.id == MoneyAssignment.DLG_HANDTOOL then
			info = g_i18n:getText("mpManager_MoneyAssignment_handtool");
		elseif dlg.id == MoneyAssignment.DLG_PLACEABLE then
			info = g_i18n:getText("mpManager_MoneyAssignment_placeable");
		elseif dlg.id == MoneyAssignment.DLG_VEHICLE then
			info = g_i18n:getText("mpManager_MoneyAssignment_vehicle");
		elseif dlg.id == MoneyAssignment.DLG_PALLETTRIGGER then
			info = g_i18n:getText("mpManager_MoneyAssignment_palletTrigger");
		elseif dlg.id == MoneyAssignment.DLG_PICKUPOBJECTSSELLTRIGGER then
			info = g_i18n:getText("mpManager_MoneyAssignment_pickupObectsSellTrigger");
		end;	
		MoneyStats:addMoneyStatsToFarm(MoneyStats:getDate(), g_currentMission.missionInfo.playerName, farm, dlg.statType, info, "-", "-", dlg.money);
		farm:addMoney(dlg.money);
		
		MoneyAssignment:removeDialog(MoneyAssignment.currentId);
	end;
	MoneyAssignment.readyForDlg = true;
end;

function MoneyAssignment:callbackNo()
	--if MoneyAssignment.currentId ~= nil then
	--	MoneyAssignment:removeDialog(MoneyAssignment.currentId);
	--end;
	MoneyAssignment.readyForDlg = true;
	MoneyAssignment.dialogs[MoneyAssignment.currentId] = nil;
end;

function MoneyAssignment.update(dt)
	if g_mpManager.utils:getTableLenght(MoneyAssignment.dialogs) > 0 and MoneyAssignment.readyForDlg and g_client ~= nil then	
		local id, dlgData = MoneyAssignment:getNextDlgData();	
		MoneyAssignment.currentId = id;
		local t, i = g_mpManager.utils:getFarmNamesAndIndex();	
		local text = MoneyAssignment.textNeg;
		if dlgData.money < 0 then
			text = MoneyAssignment.textPos;
		end;
		local dlg = g_mpManager:showMoneyAssignmentDialog(string.format("%s (%s, %s)", MoneyAssignment.header, Utils.getNoNil(FinanceStats.statNamesI18n[dlgData.statType], "-"), g_i18n:formatMoney(dlgData.money, 0, true)), text, MoneyAssignment.callbackYes, MoneyAssignment, t, i);	
		dlg:setCallbackBack(MoneyAssignment.callbackNo, MoneyAssignment);
		MoneyAssignment.readyForDlg = false;
	end;
	
	if not MoneyAssignment.readyForDlg then		
		FocusManager:setGui("MpManagerMoneyAssignmentScreen");
	end;
end;

function MoneyAssignment:getNextDlgData()
	for k,v in pairs(MoneyAssignment.dialogs) do
		return k, v;
	end;
end;

function MoneyAssignment:writeStream(streamId, connection)	
	streamWriteInt32(streamId, MoneyAssignment.id);
	-- streamWriteInt32(streamId, g_mpManager.utils:getTableLenght(MoneyAssignment.dialogs));
	-- for _,dlg in pairs(MoneyAssignment.dialogs) do
		-- streamWriteInt32(streamId, dlg.id);
		-- streamWriteString(streamId, dlg.statType);
		-- streamWriteInt32(streamId, dlg.money);
	-- end;
end;

function MoneyAssignment:readStream(streamId, connection)
	MoneyAssignment.id = streamReadInt32(streamId);
	-- local num = streamReadInt32(streamId);
	-- for i=1, num do
		-- local id = streamReadInt32(streamId);
		-- local statType = streamReadString(streamId);
		-- local money = streamReadInt32(streamId);
		-- MoneyAssignment:addDialog(id, statType, money, true)
	-- end;
end;