-- 
-- MpManager -  MoneyStats
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MoneyStats = {};
g_mpManager.moneyStats = MoneyStats;

MoneyStats.limit = 50;

local counter = -1;
local function getNextNumber() counter = counter + 1; return counter; end;

MoneyStats.STATE_NONE = getNextNumber();
MoneyStats.STATE_AI = getNextNumber();
MoneyStats.STATE_DONOTHING = getNextNumber();
MoneyStats.STATE_BGA = getNextNumber();
MoneyStats.STATE_SHOVEL = getNextNumber();
MoneyStats.STATE_PLACEABLE = getNextNumber();
MoneyStats.STATE_MILKSELL = getNextNumber();
MoneyStats.STATE_STORAGE = getNextNumber();
MoneyStats.STATE_TRAIN = getNextNumber();
MoneyStats.STATE_SILOEXTENSION = getNextNumber();
MoneyStats.STATE_SELLHANDTOOL = getNextNumber();
MoneyStats.STATE_SELLPLACEABLE = getNextNumber();
MoneyStats.STATE_SELLVEHICLE = getNextNumber();
MoneyStats.STATE_BALEDESTROYTRIGGER = getNextNumber();
MoneyStats.STATE_FILLABLEPALLETTRIGGER = getNextNumber();
MoneyStats.STATE_FILLTRIGGER = getNextNumber();
MoneyStats.STATE_GASSTATION = getNextNumber();
MoneyStats.STATE_PALLETTRIGGER = getNextNumber();
MoneyStats.STATE_PICKUPOBJECTSSELLTRIGGER = getNextNumber();
MoneyStats.STATE_TIPTRIGGER = getNextNumber();
MoneyStats.STATE_WOODSELLTRIGGER = getNextNumber();
MoneyStats.STATE_WATERTRAILERFILLLEVEL = getNextNumber();

function MoneyStats:load()	
	MoneyStats.sortByFarm = {};
	--MoneyStats.toAssign = {};
	MoneyStats.lastDisplayedMoney = 0;	
	
	MoneyStats.activeMoneyState = MoneyStats.STATE_NONE;
	MoneyStats.activeMoneyAI = {};
	MoneyStats.activeMoneyAI_money = 0;
	MoneyStats.activeMoneyAI_statType = "";
	
	MoneyStats.activeMoneyShovel = {};
	MoneyStats.activeMoneyShovel_money = 0;
	MoneyStats.activeMoneyShovel_statType = "";
	MoneyStats.activeMoneyShovel_timer = 0;
	
	MoneyStats.activeMoneyGasStationVehicles = {};
	MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles = {};
	
	MoneyStats.activeMoneyTrain = {};
	MoneyStats.activeMoneyBaleDestroyerTrigger = {};
	MoneyStats.activeMoneyFillablePalletSellTrigger = {};
	MoneyStats.activeMoneyFillTrigger = {};
	MoneyStats.activeMoneyTipTrigger = {};
	MoneyStats.activeMoneyWoodSellTrigger = {};
	
	MoneyStats.activeBga = nil;
	MoneyStats.activePlaceable = nil;
	MoneyStats.activeStorage = nil;
	MoneyStats.activeTrain = nil;
	MoneyStats.activeSiloExtension = nil;
	
	MoneyStats.manuelMoney_money = 0;
	MoneyStats.manuelMoney_type = "";
	MoneyStats.manuelMoney_timer = 0;
	
	g_mpManager.saveManager:addSave(MoneyStats.saveSavegame, MoneyStats);
	g_mpManager.loadManager:addLoad(MoneyStats.loadSavegame, MoneyStats);
	g_mpManager:addUpdateable(MoneyStats, MoneyStats.update);
end;

function MoneyStats:getDate(noHour)
	if noHour then
		return string.format("%s", getDate("%d.%m.%Y"));
	end;
	return string.format("%s %s", getDate("%d.%m.%Y"), getDate("%H:%M:%S"));
end;

function MoneyStats:getSortByFarm()
	return MoneyStats.sortByFarm[g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName)];
end;

function MoneyStats:update(dt)
	for k,v in pairs(g_currentMission.users) do
		local money = g_mpManager.utils:getMoneyFromUsername(v.nickname);
		g_currentMission.users[k].money = Utils.getNoNil(money, 0);
	end;
	local money = g_mpManager.utils:getMoneyFromUsername(g_currentMission.missionInfo.playerName);	
	MoneyStats.lastDisplayedMoney = Utils.getNoNil(money, MoneyStats.lastDisplayedMoney);
	g_currentMission.missionStats.money = MoneyStats.lastDisplayedMoney;
	
	for vehicle, data in pairs(MoneyStats.activeMoneyShovel) do
		if data.timer > 50 then
			local farm = g_mpManager.utils:getFarmTblFromUsername(vehicle.controllerName);
			if farm ~= nil then
				MoneyStats:addMoneyStatsToFarm(MoneyStats:getDate(), vehicle.controllerName, farm, data.statType, data.addInfo, data.addFrom, data.num, data.amount);
				farm:addMoney(data.money);
			end;
			MoneyStats.activeMoneyShovel[vehicle] = nil;
		else
			data.timer = data.timer + 1;
		end;
	end;	
		
	for a, s in pairs(MoneyStats.activeMoneyTrain) do
		for statType, d in pairs(s) do
			if d.timer > 50 then
				g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_TRAIN, statType, d.money);	
				MoneyStats.activeMoneyTrain[a][statType] = nil;
			else
				d.timer = d.timer + 1;
			end;
		end;
	end;	
		
	for trigger, d in pairs(MoneyStats.activeMoneyBaleDestroyerTrigger) do
		if d.timer > 50 then
			g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, "soldBales", d.amount);	
			MoneyStats.activeMoneyBaleDestroyerTrigger[trigger] = nil;
		else
			d.timer = d.timer + 1;
		end;
	end;
		
	for trigger, d in pairs(MoneyStats.activeMoneyFillablePalletSellTrigger) do
		if d.timer > 50 then
			g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, d.statType, d.amount);	
			MoneyStats.activeMoneyFillablePalletSellTrigger[trigger] = nil;
		else
			d.timer = d.timer + 1;
		end;
	end;
		
	for trigger, d in pairs(MoneyStats.activeMoneyFillTrigger) do
		if d.timer > 50 then
			g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, d.statType, d.amount);	
			MoneyStats.activeMoneyFillTrigger[trigger] = nil;
		else
			d.timer = d.timer + 1;
		end;
	end;
		
	for vehicle, data in pairs(MoneyStats.activeMoneyGasStationVehicles) do
		if data.timer > 50 then
			local farm = g_mpManager.utils:getFarmTblFromUsername(vehicle.controllerName);
			if farm ~= nil then
				MoneyStats:addMoneyStatsToFarm(MoneyStats:getDate(), vehicle.controllerName, farm, "purchaseFuel", "-", data.addFrom, g_i18n:formatMoney(data.delta,0,false), data.amount);
				farm:addMoney(data.amount);
			end;
			MoneyStats.activeMoneyGasStationVehicles[vehicle] = nil;
		else
			data.timer = data.timer + 1;
		end;
	end;
		
	for trigger, d in pairs(MoneyStats.activeMoneyTipTrigger) do
		if d.timer > 50 then
			g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, d.statType, d.amount);	
			MoneyStats.activeMoneyTipTrigger[trigger] = nil;
		else
			d.timer = d.timer + 1;
		end;
	end;
		
	for trigger, d in pairs(MoneyStats.activeMoneyWoodSellTrigger) do
		if d.timer > 50 then
			g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, "soldWood", d.amount);	
			MoneyStats.activeMoneyWoodSellTrigger[trigger] = nil;
		else
			d.timer = d.timer + 1;
		end;
	end;
		
	for vehicle, data in pairs(MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles) do
		if data.timer > 50 then
			local farm = g_mpManager.utils:getFarmTblFromUsername(vehicle.controllerName);
			if farm ~= nil then
				MoneyStats:addMoneyStatsToFarm(MoneyStats:getDate(), vehicle.controllerName, farm, "purchaseWater", "-", "-", g_i18n:formatMoney(data.delta,0,false), data.amount);
				farm:addMoney(data.amount);
			end;
			MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[vehicle] = nil;
		else
			data.timer = data.timer + 1;
		end;
	end;
	
	if MoneyStats.manuelMoney_money ~= 0 then
		if MoneyStats.manuelMoney_timer >= 300 then
			g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, MoneyStats.manuelMoney_type, MoneyStats.manuelMoney_money);	
			MoneyStats.manuelMoney_money = 0;
			MoneyStats.manuelMoney_type = "";
			MoneyStats.manuelMoney_timer = 0;
		else
			MoneyStats.manuelMoney_timer = MoneyStats.manuelMoney_timer + 1;
		end;
	
	end;
	
	--Set load to 0
	if g_currentMission.missionStats.loan ~= 0 then
		g_currentMission.missionStats.loan = 0;
	end;
end;


function MoneyStats:addMoneyStatsToFarm(dat, name, farm, statType, addInfo, addFrom, num, amount, noEventSend)
	if amount == 0 or farm == nil then
		return;
	end;
	
	while true do
		if not MoneyStats:getCanAddStatsToFarm(farm) then
			MoneyStats:removeMoneyStatsFromFarm(farm, 1);
		else
			break;
		end;
	end;
	if MoneyStats.sortByFarm[farm:getName()] == nil then
		MoneyStats.sortByFarm[farm:getName()] = {};
	end;	
	if name == nil then
		name = "-";
	end;
	if addInfo == nil then
		addInfo = "-";
	end;
	if addFrom == nil then
		addFrom = "-";
	end;
	if num == nil then
		num = "-";
	end;
	MpManagement_MoneyStats_AddMoneyStatsToFarm.sendEvent(dat, name, farm, statType, addInfo, addFrom, num, amount, noEventSend);
	table.insert(MoneyStats.sortByFarm[farm:getName()], {date=dat, name=name, farmname=farm:getName(), statType=statType, addInfo=addInfo, addFrom=addFrom, num=tostring(num), amount=amount});	
	--print(string.format("add money to farm %s %s %s %s %s %s %s %s", dat, name, farm:getName(), statType, addInfo, addFrom, num, amount));
end;

function MoneyStats:getCanAddStatsToFarm(farm)
	if farm ~= nil and MoneyStats.sortByFarm[farm:getName()] ~= nil and table.getn(MoneyStats.sortByFarm[farm:getName()]) >= MoneyStats.limit then
		return false;
	else
		return true;
	end;
end;

function MoneyStats:removeMoneyStatsFromFarm(farm, posToRemove, noEventSend)
	MpManagement_MoneyStats_RemoveMoneyStatsFromFarm.sendEvent(farm, posToRemove, noEventSend);
	if MoneyStats.sortByFarm[farm:getName()] ~= nil then
		table.remove(MoneyStats.sortByFarm[farm:getName()], posToRemove);
	end;
end;

-- function MoneyStats:addMoneyStatsToAssign(amount, statType, dateA, timeA)
	-- --Event
	-- table.insert(MoneyStats.toAssign, {amount=amount, statType=statType, date=dateA, time=timeA});	
-- end;

-- function MoneyStats:removeMoneyStatsToAssign(posToRemove)
	-- --Event
	-- table.remove(MoneyStats.toAssign, posToRemove);	
-- end;

function MoneyStats:setActiveMoneyState(state) 
	MoneyStats.activeMoneyState = state;
end

function MoneyStats:saveSavegame(dt)
	local index = 0;
	for farmname, d in pairs(MoneyStats.sortByFarm) do
		for _,data in pairs(d) do
			g_mpManager.saveManager:setXmlString(string.format("moneyStats.stat(%d)#date", index), data.date);	
			g_mpManager.saveManager:setXmlString(string.format("moneyStats.stat(%d)#name", index), Utils.getNoNil(data.name, "-"));
			g_mpManager.saveManager:setXmlString(string.format("moneyStats.stat(%d)#farmname", index), farmname);
			g_mpManager.saveManager:setXmlString(string.format("moneyStats.stat(%d)#statType", index), Utils.getNoNil(data.statType, "-"));
			g_mpManager.saveManager:setXmlString(string.format("moneyStats.stat(%d)#addInfo", index), Utils.getNoNil(data.addInfo, "-"));	
			g_mpManager.saveManager:setXmlString(string.format("moneyStats.stat(%d)#addFrom", index), Utils.getNoNil(data.addFrom, "-"));	
			g_mpManager.saveManager:setXmlString(string.format("moneyStats.stat(%d)#num", index), Utils.getNoNil(data.num, "-"));		
			g_mpManager.saveManager:setXmlInt(string.format("moneyStats.stat(%d)#amount", index), data.amount);
			index = index + 1;
		end;
	end;
end;

function MoneyStats:loadSavegame(dt)
	local index = 0;
	while true do
		local key = string.format("moneyStats.stat(%d)", index);
		if not g_mpManager.loadManager:hasXmlProperty(key) then
			break;
		end;
		local dat = g_mpManager.loadManager:getXmlString(key .. "#date");
		local name = g_mpManager.loadManager:getXmlString(key .. "#name");
		local farmname = g_mpManager.loadManager:getXmlString(key .. "#farmname");
		local statType = g_mpManager.loadManager:getXmlString(key .. "#statType");
		local addInfo = g_mpManager.loadManager:getXmlString(key .. "#addInfo");
		local addFrom = g_mpManager.loadManager:getXmlString(key .. "#addFrom");
		local num = g_mpManager.loadManager:getXmlString(key .. "#num");
		local amount = g_mpManager.loadManager:getXmlInt(key .. "#amount");
		MoneyStats:addMoneyStatsToFarm(dat, name, g_mpManager.utils:getFarmTblFromFarmname(farmname), statType, addInfo, addFrom, num, amount, true)
		index = index + 1;
	end;
end;

function MoneyStats:writeStream(streamId, connection)	
	streamWriteInt32(streamId, g_mpManager.utils:getTableLenght(MoneyStats.sortByFarm));
	for farmname, data in pairs(MoneyStats.sortByFarm) do
		streamWriteString(streamId, farmname);
		streamWriteInt32(streamId, g_mpManager.utils:getTableLenght(data));
		for farmname, d in pairs(data) do
			streamWriteString(streamId, d.date);
			streamWriteString(streamId, d.name);
			streamWriteString(streamId, d.statType);
			streamWriteString(streamId, d.addInfo);
			streamWriteString(streamId, d.addFrom);
			streamWriteString(streamId, d.num);
			streamWriteInt32(streamId, d.amount);
		end;
	end;
end;

function MoneyStats:readStream(streamId, connection)
	local numFarms = streamReadInt32(streamId);
	for i=1, numFarms do
		local farmname = streamReadString(streamId);
		local numData = streamReadInt32(streamId);
		for i=1, numData do
			local dat = streamReadString(streamId);
			local name = streamReadString(streamId);
			local statType = streamReadString(streamId);
			local addInfo = streamReadString(streamId);
			local addFrom = streamReadString(streamId);
			local num = streamReadString(streamId);
			local amount = streamReadInt32(streamId);			
			MoneyStats:addMoneyStatsToFarm(dat, name, g_mpManager.utils:getFarmTblFromFarmname(farmname), statType, addInfo, addFrom, num, amount, true)
		end;
	end;
end;

function MoneyStats:addMoney(old)
	return function(e, amount, userId, statType)
		if g_server ~= nil and statType ~= nil then
			if amount == 0 then
				return;
			end;
			if MoneyStats.activeMoneyState == MoneyStats.STATE_NONE then
				g_currentMission.missionStats:changeFinanceStats(amount, statType);
				g_currentMission.missionStats:changeBalance(amount);
				
				local add = false;
				if userId ~= nil then				
					local farm = g_mpManager.utils:getFarmTblFromUsername(g_currentMission:findUserByUserId(userId).nickname);
					if farm ~= nil then
						farm:addMoney(amount);
						MoneyStats:addMoneyStatsToFarm(MoneyStats:getDate(), g_currentMission:findUserByUserId(userId).nickname, farm, statType, addInfo, addFrom, num, amount);
						add = true;				
					end;
				end;
				if not add then
					--MoneyStats:addMoneyStatsToAssign(amount, statType, getDate("%d.%m.%Y"), getDate("%H:%M:%S"));
				end;
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_GASSTATION then
				if MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV] == nil then
					MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV] = {};
					MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].amount = 0;
					MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].delta = 0;			
					local fullViewName = Utils.getNoNil(getUserAttribute(MoneyStats.activeMoneyGasStationS.triggerId, "stationName"), "map_fuelStation")
					if g_i18n:hasText(fullViewName) then
						fullViewName = g_i18n:getText(fullViewName)
					end;
					MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].addFrom	= fullViewName;			
				end;
				MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].timer = 0;
				MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].amount = MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].amount + amount;
			end;
		end;		
	end;	
end;

function MoneyStats:addSharedMoney(old)
	return function(s, amount, statType)	
		if statType == nil then
			statType = "other";
		end;
		--print(string.format("%s %s",amount, statType));
		if amount ~= 0 then
			if MoneyStats.activeMoneyState == MoneyStats.STATE_AI then
				MoneyStats.activeMoneyAI_money = amount;
				MoneyStats.activeMoneyAI_statType = statType;
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_BGA then
				if MoneyStats.activeBga ~= nil then
					local bga_tbl = g_mpManager.assignabels.assignabelsById[g_mpManager.assignabels.BGA];
					for _, bga in pairs(bga_tbl) do
						if bga.object == MoneyStats.activeBga then
							if bga.object.mpManagerMoney == nil then
								bga.object.mpManagerMoney = 0;
							end;
							bga.object.mpManagerMoney = bga.object.mpManagerMoney + amount;
							break;
						end;
					end;
				else
					g_debug.write(-1, "Can't add money to Bga");
				end;
				MoneyStats.activeBga = nil;				
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_SHOVEL then
				MoneyStats.activeMoneyShovel_money = amount;
				MoneyStats.activeMoneyShovel_statType = statType;
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_PLACEABLE then
				if MoneyStats.activePlaceable ~= nil then
					local placeable_tbl = g_mpManager.assignabels.assignabelsById[g_mpManager.assignabels.PLACEABLE];
					for _, placeable in pairs(placeable_tbl) do
						if placeable.object == MoneyStats.activePlaceable then
							if placeable.object.mpManagerMoney == nil then
								placeable.object.mpManagerMoney = 0;
							end;
							placeable.object.mpManagerMoney = placeable.object.mpManagerMoney + amount;
							break;
						end;
					end;
				else
					g_debug.write(-1, "Can't add money to Placeable");				
				end;
				MoneyStats.activePlaceable = nil;			
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_MILKSELL then
				local p = g_mpManager.assignabels.assignabelsById[g_mpManager.assignabels.MILKSELL][1];				
				local farm = g_mpManager.utils:getFarmTblFromFarmname(p.object.mpManagerFarm);
				local split = false;
				if farm == nil then
					split = true;
				end;
				if split then
					local m = amount / table.getn(g_mpManager.farm:getFarms());
					for _, farm in pairs(g_mpManager.farm:getFarms()) do
						g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "-", farm, "soldMilk", g_i18n:getText("mpManager_moneyinput_automaticIncome"), p.name, "-", m);
						farm:addMoney(m);	
					end;
				else
					g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "-", farm, "soldMilk", g_i18n:getText("mpManager_moneyinput_automaticIncome"), p.name, "-", amount);
					farm:addMoney(amount);	
				end;
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_STORAGE then
				if MoneyStats.activeStorage ~= nil then
					for _, storage in pairs(g_mpManager.assignabels.assignabelsById[g_mpManager.assignabels.STORAGE]) do
						if storage.object == MoneyStats.activeStorage then
							if storage.object.mpManagerMoney == nil then
								storage.object.mpManagerMoney = 0;
							end;
							storage.object.mpManagerMoney = storage.object.mpManagerMoney + amount;
							break;
						end;
					end;
				else
					g_debug.write(-1, "Can't add money to Storage");
				end;
				MoneyStats.activeStorage = nil;		
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_TRAIN then
				if MoneyStats.activeMoneyTrain[MoneyStats.activeTrain] == nil then
					MoneyStats.activeMoneyTrain[MoneyStats.activeTrain] = {};
				end;
				if MoneyStats.activeMoneyTrain[MoneyStats.activeTrain][statType] == nil then
					MoneyStats.activeMoneyTrain[MoneyStats.activeTrain][statType] = {};
					MoneyStats.activeMoneyTrain[MoneyStats.activeTrain][statType].money = 0;
				end;
				MoneyStats.activeMoneyTrain[MoneyStats.activeTrain][statType].money = MoneyStats.activeMoneyTrain[MoneyStats.activeTrain][statType].money + amount;	
				MoneyStats.activeMoneyTrain[MoneyStats.activeTrain][statType].timer = 0;	
				MoneyStats.activeTrain = nil;
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_SILOEXTENSION then
				if MoneyStats.activeSiloExtension.mpManagerFarm ~= nil and g_mpManager.utils:getFarmTblFromFarmname(MoneyStats.activeSiloExtension.mpManagerFarm) ~= nil then
					local farm = g_mpManager.utils:getFarmTblFromFarmname(MoneyStats.activeSiloExtension.mpManagerFarm);
					g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "-", farm, "harvestIncome", g_i18n:getText("mpManager_MoneyAssignment_siloExtension"), "-", "-", amount);
					farm:addMoney(amount);	
				else
					amount = amount / table.getn(g_mpManager.farm:getFarms());
					for _, farm in pairs(g_mpManager.farm:getFarms()) do
						g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "-", farm, "harvestIncome", g_i18n:getText("mpManager_MoneyAssignment_siloExtension"), "-", "-", amount);
						farm:addMoney(amount);	
					end;
				end;
				MoneyStats.activeSiloExtension = nil;
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_SELLHANDTOOL then					
				g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_HANDTOOL, statType, amount);	
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_SELLPLACEABLE then					
				g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_PLACEABLE, statType, amount);	
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_SELLVEHICLE then					
				g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_VEHICLE, statType, amount);		
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_BALEDESTROYTRIGGER then					
				if MoneyStats.activeMoneyBaleDestroyerTrigger[MoneyStats.activeBaleDestroyTrigger] == nil then
					MoneyStats.activeMoneyBaleDestroyerTrigger[MoneyStats.activeBaleDestroyTrigger] = {};
					MoneyStats.activeMoneyBaleDestroyerTrigger[MoneyStats.activeBaleDestroyTrigger].amount = 0;
				end;
				MoneyStats.activeMoneyBaleDestroyerTrigger[MoneyStats.activeBaleDestroyTrigger].timer = 0;
				MoneyStats.activeMoneyBaleDestroyerTrigger[MoneyStats.activeBaleDestroyTrigger].amount = MoneyStats.activeMoneyBaleDestroyerTrigger[MoneyStats.activeBaleDestroyTrigger].amount + amount;
				MoneyStats.activeBaleDestroyTrigger = nil;		
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_FILLABLEPALLETTRIGGER then					
				if MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeFillablePalletSellTrigger] == nil then
					MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeFillablePalletSellTrigger] = {};
					MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeFillablePalletSellTrigger].amount = 0;
				end;
				
				local oldStatType = MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeFillablePalletSellTrigger].statType;
				if oldStatType ~= nil and oldStatType ~= statType then
					g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, oldStatType, MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeFillablePalletSellTrigger].amount);	
					MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeFillablePalletSellTrigger].amount = 0;
				end;
				
				MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeFillablePalletSellTrigger].timer = 0;
				MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeFillablePalletSellTrigger].statType = statType;
				MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeFillablePalletSellTrigger].amount = MoneyStats.activeMoneyFillablePalletSellTrigger[MoneyStats.activeBaleDestroyTrigger].amount + amount;
				MoneyStats.activeFillablePalletSellTrigger = nil;
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_FILLTRIGGER then					
				if MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger] == nil then
					MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger] = {};
					MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger].amount = 0;
				end;	
				
				local oldStatType = MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger].statType;
				if oldStatType ~= nil and oldStatType ~= statType then
					g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, oldStatType, MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger].amount);	
					MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger].amount = 0;
				end;		
				
				MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger].timer = 0;
				MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger].statType = statType;	
				MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger].amount = MoneyStats.activeMoneyFillTrigger[MoneyStats.activeFillTrigger].amount + amount;
				MoneyStats.activeFillablePalletSellTrigger = nil;
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_PALLETTRIGGER then					
				g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_PALLETTRIGGER, statType, amount);	
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_PICKUPOBJECTSSELLTRIGGER then					
				g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_PICKUPOBJECTSSELLTRIGGER, statType, amount);
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_TIPTRIGGER then					
				if MoneyStats.activeMoneyTipTrigger[MoneyStats.activeTipTrigger] == nil then
					MoneyStats.activeMoneyTipTrigger[MoneyStats.activeTipTrigger] = {};
					MoneyStats.activeMoneyTipTrigger[MoneyStats.activeTipTrigger].amount = 0;
				end;				
				MoneyStats.activeMoneyTipTrigger[MoneyStats.activeTipTrigger].timer = 0;
				MoneyStats.activeMoneyTipTrigger[MoneyStats.activeTipTrigger].statType = MoneyStats.activeTipTrigger.lastIncomeName;
				MoneyStats.activeMoneyTipTrigger[MoneyStats.activeTipTrigger].amount = MoneyStats.activeMoneyTipTrigger[MoneyStats.activeTipTrigger].amount + amount;
				MoneyStats.activeTipTrigger = nil;	
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_WOODSELLTRIGGER then					
				if MoneyStats.activeMoneyWoodSellTrigger[MoneyStats.activeWoodSellTrigger] == nil then
					MoneyStats.activeMoneyWoodSellTrigger[MoneyStats.activeWoodSellTrigger] = {};
					MoneyStats.activeMoneyWoodSellTrigger[MoneyStats.activeWoodSellTrigger].amount = 0;
				end;				
				MoneyStats.activeMoneyWoodSellTrigger[MoneyStats.activeWoodSellTrigger].timer = 0;
				MoneyStats.activeMoneyWoodSellTrigger[MoneyStats.activeWoodSellTrigger].amount = MoneyStats.activeMoneyWoodSellTrigger[MoneyStats.activeWoodSellTrigger].amount + amount;
				MoneyStats.activeWoodSellTrigger = nil;	
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_WATERTRAILERFILLLEVEL then
				if MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[MoneyStats.activeMoneyWaterTrailerFillTriggerV] == nil then
					MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[MoneyStats.activeMoneyWaterTrailerFillTriggerV] = {};
					MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[MoneyStats.activeMoneyWaterTrailerFillTriggerV].amount = 0;
					MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[MoneyStats.activeMoneyWaterTrailerFillTriggerV].delta = 0;		
				end;
				MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[MoneyStats.activeMoneyWaterTrailerFillTriggerV].timer = 0;
				MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[MoneyStats.activeMoneyWaterTrailerFillTriggerV].amount = MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[MoneyStats.activeMoneyWaterTrailerFillTriggerV].amount + amount;
			elseif MoneyStats.activeMoneyState == MoneyStats.STATE_GASSTATION then
				if MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV] == nil then
					MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV] = {};
					MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].amount = 0;
					MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].delta = 0;			
					local fullViewName = Utils.getNoNil(getUserAttribute(MoneyStats.activeMoneyGasStationS.triggerId, "stationName"), "map_fuelStation")
					if g_i18n:hasText(fullViewName) then
						fullViewName = g_i18n:getText(fullViewName)
					end;
					MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].addFrom	= fullViewName;			
				end;
				MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].timer = 0;
				MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].amount = MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].amount + amount;
			elseif not MoneyStats.activeMoneyState == MoneyStats.STATE_DONOTHING then
				if not g_mpManager.modulManager:controllMoney(statType, amount) then
					if amount > 100 then
						g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, statType, amount);
					else
						if MoneyStats.manuelMoney_type == "" then
							MoneyStats.manuelMoney_money = amount;
							MoneyStats.manuelMoney_type = statType;
							MoneyStats.manuelMoney_timer = 0;
						elseif MoneyStats.manuelMoney_type == statType then
							MoneyStats.manuelMoney_money = MoneyStats.manuelMoney_money + amount;
							MoneyStats.manuelMoney_timer = 0;
						elseif MoneyStats.manuelMoney_money ~= 0 then
							g_mpManager.moneyAssignabels:addDialog(g_mpManager.moneyAssignabels.DLG_NOADDINFO, MoneyStats.manuelMoney_type, MoneyStats.manuelMoney_money);
							MoneyStats.manuelMoney_money = 0;
							MoneyStats.manuelMoney_type = "";
							MoneyStats.manuelMoney_timer = 0;
						end;
					end;
				end;
			end;	
		end;
	end;	
end;

function MoneyStats:dayChanged(old)
	return function(s)
		if g_currentMission:getIsServer() then
			
			local vehicleCosts = {};
			local buildingsCosts = {};
			local vehicleLeasingCosts = {};
			for _,farm in pairs(g_mpManager.farm:getFarms()) do
				vehicleCosts[farm:getName()] = 0;
				buildingsCosts[farm:getName()] = 0;
				vehicleLeasingCosts[farm:getName()] = 0;
			end;	
			
			for _, item in pairs(g_currentMission.leasedVehicles) do
				for _, vehicle in pairs(item.items) do
					local farmname = vehicle:getFarm();		
					local costs = vehicle:getPrice() * EconomyManager.PER_DAY_LEASING_FACTOR
					if farmname ~= nil and vehicleLeasingCosts[farmname] ~= nil then
						vehicleLeasingCosts[farmname] = vehicleLeasingCosts[farmname] + costs;
					else
						costs = costs / table.getn(g_mpManager.farm:getFarms());
						for _,farm in pairs(g_mpManager.farm:getFarms()) do
							vehicleLeasingCosts[farm:getName()] = vehicleLeasingCosts[farm:getName()] + costs;
						end;			
					end;
				end
			end
			
			for storeItem, item in pairs(g_currentMission.ownedItems) do
				if StoreItemsUtil.getIsVehicle(storeItem) then
					for _, realItem in pairs(item.items) do
						local farmname = realItem:getFarm();						
						if realItem.propertyState == Vehicle.PROPERTY_STATE_OWNED then
							local upKeep = realItem:getDailyUpKeep();
							if farmname ~= nil and vehicleCosts[farmname] ~= nil then
								vehicleCosts[farmname] = vehicleCosts[farmname] + upKeep;
							else
								upKeep = upKeep / table.getn(g_mpManager.farm:getFarms());
								for _,farm in pairs(g_mpManager.farm:getFarms()) do
									vehicleCosts[farm:getName()] = vehicleCosts[farm:getName()] + upKeep;
								end;			
							end;
						end;
					end
				else
					for _, realItem in pairs(item.items) do
						local farmname = realItem.mpManagerFarm;
						local upKeep = realItem:getDailyUpKeep();
						if farmname ~= nil and buildingsCosts[farmname] ~= nil then
							buildingsCosts[farmname] = buildingsCosts[farmname] + upKeep;
						else
							upKeep = upKeep / table.getn(g_mpManager.farm:getFarms());
							for _,farm in pairs(g_mpManager.farm:getFarms()) do
								buildingsCosts[farm:getName()] = buildingsCosts[farm:getName()] + upKeep;
							end;			
						end;
					end
				end
			end
			
			for farmname, value in pairs(vehicleCosts) do
				local m = value * -1;
				g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "-", g_mpManager.utils:getFarmTblFromFarmname(farmname), "vehicleRunningCost", g_i18n:getText("mpManager_moneyinput_automaticIncome"), "-", "-", m);
				g_mpManager.utils:getFarmTblFromFarmname(farmname):addMoney(m);			
			end;
			
			for farmname, value in pairs(buildingsCosts) do
				local m = value * -1;
				g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "-", g_mpManager.utils:getFarmTblFromFarmname(farmname), "propertyMaintenance", g_i18n:getText("mpManager_moneyinput_automaticIncome"), "-", "-", m);
				g_mpManager.utils:getFarmTblFromFarmname(farmname):addMoney(m);			
			end;
			
			for farmname, value in pairs(vehicleLeasingCosts) do
				local m = value * -1;
				g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "-", g_mpManager.utils:getFarmTblFromFarmname(farmname), "vehicleLeasingCost", g_i18n:getText("mpManager_moneyinput_automaticIncome"), "-", "-", m);
				g_mpManager.utils:getFarmTblFromFarmname(farmname):addMoney(m);			
			end;
			
			local sellAnimals = {}
			for name, h in pairs(g_currentMission.husbandries) do
				sellAnimals[name] = h:getNumAnimals(0)
			end;
			
			local priceFarm = {}
			for _,farm in pairs(g_mpManager.farm:getFarms()) do
				local farmname = farm:getName();
				if priceFarm[farmname] == nil then
					priceFarm[farmname] = 0;
				end;
				for name,count in pairs(g_mpManager.husbandry:getHusbandryByFarmName(farm:getName())) do
					priceFarm[farmname] = priceFarm[farmname] + count * g_currentMission.husbandries[name].dailyUpkeep;
					sellAnimals[name] = sellAnimals[name] - count;
				end;					
			end;		
			
			local numFarms = table.getn(g_mpManager.farm:getFarms());
			for name, count in pairs(sellAnimals) do
				if count > 0 then
					local price = count * g_currentMission.husbandries[name].dailyUpkeep / numFarms;
					for _,farm in pairs(g_mpManager.farm:getFarms()) do
						local farmname = farm:getName();
						priceFarm[farmname] = priceFarm[farmname] + price;
					end;					
				end;
			end;
			
			for _,farm in pairs(g_mpManager.farm:getFarms()) do	
				local m = priceFarm[farm:getName()] * -1;
				g_mpManager.moneyStats:addMoneyStatsToFarm(g_mpManager.moneyStats:getDate(), "-", farm, "animalUpkeep", g_i18n:getText("mpManager_moneyinput_automaticIncome"), "-", "-", m);
				farm:addMoney(m);
			end;		
			g_currentMission.missionStats:archiveFinanceStats();
		end;	
	end;
end;
FSBaseMission.addSharedMoney = MoneyStats:addSharedMoney(FSBaseMission.addSharedMoney);
FSBaseMission.addMoney = MoneyStats:addMoney(FSBaseMission.addMoney);
EconomyManager.dayChanged = MoneyStats:dayChanged(EconomyManager.dayChanged);

-- No vehicle costs for handtool chainsaw
function MoneyStats.Chainsaw_update(old) 
	return function(s, ...)
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_DONOTHING);
		old(s, ...);
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);		
	end;
end
Chainsaw.update = MoneyStats.Chainsaw_update(Chainsaw.update);

--BGA
-- BGA: Selling bales
function MoneyStats.Bga_objectDeleteTriggerCallback(old) 
	return function(s, ...)
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_BGA);
		MoneyStats.activeBga = s;
		old(s, ...);
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);		
	end;
end
-- BGA: Selling filllevel
function MoneyStats.Bga_setFillLevel(old) 
	return function(s, fillLevel, fillType, fillable, trigger)
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_BGA);
		MoneyStats.activeBga = s;
		local oldLvl = s.bunkerFillLevel;
		old(s, fillLevel, fillType, fillable, trigger);
		if fillType ~= FillUtil.FILLTYPE_LIQUIDMANURE then
			if s.mpManagerNum == nil then
				s.mpManagerNum = 0;
			end;
			local delta = s.bunkerFillLevel - oldLvl;
			if delta > 0 then
				s.mpManagerNum = s.mpManagerNum + delta;
			end;
		end;
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);		
	end;
end

Bga.objectDeleteTriggerCallback = MoneyStats.Bga_objectDeleteTriggerCallback(Bga.objectDeleteTriggerCallback);
Bga.setFillLevel = MoneyStats.Bga_setFillLevel(Bga.setFillLevel);
--BGA end

-- Shovel: addShovelFillLevel
function MoneyStats.ShovelTarget_addShovelFillLevel(old) 
	return function(trigger, shovel, fillLevelDelta, fillType)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_SHOVEL);
		local fillLevelDeltaR = old(trigger, shovel, fillLevelDelta, fillType);		
		if trigger.parent == nil then
			local vehicle = shovel;
			if shovel.attacherVehicle ~= nil then
				vehicle = shovel.attacherVehicle;
				if shovel.attacherVehicle.attacherVehicle ~= nil then
					vehicle = shovel.attacherVehicle.attacherVehicle;
				end;
			end;	
			if MoneyStats.activeMoneyShovel[vehicle] == nil then
				MoneyStats.activeMoneyShovel[vehicle] = {};
				MoneyStats.activeMoneyShovel[vehicle].money = 0;
				MoneyStats.activeMoneyShovel[vehicle].statType = MoneyStats.activeMoneyShovel_statType;
				MoneyStats.activeMoneyShovel[vehicle].timer = 0;
			end;
			MoneyStats.activeMoneyShovel[vehicle].money = MoneyStats.activeMoneyShovel[vehicle].money + MoneyStats.activeMoneyShovel_money;
			MoneyStats.activeMoneyShovel[vehicle].timer = 0;
			MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);
			MoneyStats.activeMoneyShovel_money = 0;
			MoneyStats.activeMoneyShovel_statType = "";
			MoneyStats.activeMoneyShovel_timer = 0;
		end;
		return fillLevelDeltaR;
	end;
end
ShovelTarget.addShovelFillLevel = MoneyStats.ShovelTarget_addShovelFillLevel(ShovelTarget.addShovelFillLevel);
ShovelTarget.addPipeFillLevel = MoneyStats.ShovelTarget_addShovelFillLevel(ShovelTarget.addPipeFillLevel);
-- Shovel: addShovelFillLevel end

-- Deactive functions
function MoneyStats.doNothing() return function() end end
-- Deactive loan (Giants)
InGameMenu.onClickFinancesBorrow = MoneyStats.doNothing();
InGameMenu.onClickFinancesRepay = MoneyStats.doNothing();
-- Deactive send money to other user
InGameMenu.transferMoney = MoneyStats.doNothing();
-- Deactive Consolecommand for cheating money
FSBaseMission.consoleCommandCheatMoney = MoneyStats.doNothing();
-- Deactive addMoneyChange at the moment -> TODO
FSBaseMission.addMoneyChange = MoneyStats.doNothing();
-- Deactive functions end

-- AI
function MoneyStats.AIVehicle_startAIVehicle(old) 
	return function(s, helperIndex, noEventSend)
		old(s, helperIndex, noEventSend);
		if noEventSend == nil or noEventSend == false then
			s:setAIFarm(g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName), g_currentMission.missionInfo.playerName);	
		end;
	end;
end
function MoneyStats.AIVehicle_stopAIVehicle(old) 
	return function(s, reason, noEventSend)
		old(s, reason, noEventSend);
		if MoneyStats.activeMoneyAI[s] ~= nil then
			local farmname, name = s:getAIFarm();
			local farm = g_mpManager.utils:getFarmTblFromFarmname(farmname);
			if farm ~= nil then
				for statType, money in pairs(MoneyStats.activeMoneyAI[s]) do
					if money ~= 0 then
						-- if not MoneyStats:getCanAddStatsToFarm(farm) then
							-- MoneyStats:removeMoneyStatsFromFarm(farm, 1);
						-- end;
						MoneyStats:addMoneyStatsToFarm(MoneyStats:getDate(), name, farm, statType, g_i18n:getText("workerCost"), g_i18n:getText("worker"), num, money);
						farm:addMoney(money);
					end;
				end;
			else
				g_debug.write(-1, "Can't add money after stop ai vehicle %s %s %s", farmname, name, farm);
			end;
		end;
	end;
end
function MoneyStats.AIVehicle_costs(old) 
	return function(vehicle, ...)
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_AI);
		local r1,r2 = old(vehicle, ...);			
		if MoneyStats.activeMoneyAI_money ~= 0 and MoneyStats.activeMoneyAI_statType ~= "" then
			local vehicleToSave = vehicle;
			if vehicle.getSteeringAxleBaseVehicle ~= nil then
				local attached = vehicle:getSteeringAxleBaseVehicle();
				if attached ~= nil then
					vehicleToSave = attached;
					if vehicleToSave.getAIFarm == nil and vehicleToSave.attacherVehicle ~= nil then
						vehicleToSave = vehicleToSave.attacherVehicle;
						if vehicleToSave.getAIFarm == nil and vehicleToSave.attacherVehicle ~= nil then
							vehicleToSave = vehicleToSave.attacherVehicle;
						end;
					end;
				end;
			end;
			if MoneyStats.activeMoneyAI[vehicleToSave] == nil then 
				MoneyStats.activeMoneyAI[vehicleToSave] = {};
			end;
			if MoneyStats.activeMoneyAI[vehicleToSave][MoneyStats.activeMoneyAI_statType] == nil then 
				MoneyStats.activeMoneyAI[vehicleToSave][MoneyStats.activeMoneyAI_statType] = 0;
			end;
			MoneyStats.activeMoneyAI[vehicleToSave][MoneyStats.activeMoneyAI_statType] = MoneyStats.activeMoneyAI[vehicleToSave][MoneyStats.activeMoneyAI_statType] + MoneyStats.activeMoneyAI_money;
			MoneyStats.activeMoneyAI_money = 0;
			MoneyStats.activeMoneyAI_statType = "";
		end;
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);
		return r1,r2;
	end;
end

AIVehicle.startAIVehicle = MoneyStats.AIVehicle_startAIVehicle(AIVehicle.startAIVehicle);
AIVehicle.stopAIVehicle = MoneyStats.AIVehicle_stopAIVehicle(AIVehicle.stopAIVehicle);
AIVehicle.updateTick = MoneyStats.AIVehicle_costs(AIVehicle.updateTick);
SowingMachine.updateTick = MoneyStats.AIVehicle_costs(SowingMachine.updateTick);
TreePlanter.updateTick = MoneyStats.AIVehicle_costs(TreePlanter.updateTick);
Sprayer.getHasSpray = MoneyStats.AIVehicle_costs(Sprayer.getHasSpray);
Motorized.updateFuelUsage = MoneyStats.AIVehicle_costs(Motorized.updateFuelUsage);
-- AI End

--Placeables
function MoneyStats.payPlaceable(old) 
	return function(s,...)		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_PLACEABLE);	
		MoneyStats.activePlaceable = s;
		old(s,...);
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);			
	end;
end;
Placeable.hourChanged = MoneyStats.payPlaceable(Placeable.hourChanged);
BeehivePlaceable.hourChanged = MoneyStats.payPlaceable(BeehivePlaceable.hourChanged);
GreenhousePlaceable.hourChanged = MoneyStats.payPlaceable(GreenhousePlaceable.hourChanged);
SolarCollectorPlaceable.hourChanged = MoneyStats.payPlaceable(SolarCollectorPlaceable.hourChanged);
WindTurbinePlaceable.hourChanged = MoneyStats.payPlaceable(WindTurbinePlaceable.hourChanged);
HighPressureWasher.update = MoneyStats.payPlaceable(HighPressureWasher.update);
WoodCrusherPlaceable.onCrushedSplitShape = MoneyStats.payPlaceable(WoodCrusherPlaceable.onCrushedSplitShape);

--Placeables End

function MoneyStats.FSBaseMission_sellMilk(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_MILKSELL);
		old(s,...);
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
FSBaseMission.sellMilk = MoneyStats.FSBaseMission_sellMilk(FSBaseMission.sellMilk);

function MoneyStats.Storage_hourChanged(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_STORAGE);
		MoneyStats.activeStorage = s;
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
Storage.hourChanged = MoneyStats.Storage_hourChanged(Storage.hourChanged);

function MoneyStats.Train_unloadTrain(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_TRAIN);
		MoneyStats.activeTrain = s;
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
Train.unloadTrain = MoneyStats.Train_unloadTrain(Train.unloadTrain);

function MoneyStats.SiloExtensionPlaceable_onSell(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_SILOEXTENSION);
		MoneyStats.activeSiloExtension = s;
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
SiloExtensionPlaceable.onSell = MoneyStats.SiloExtensionPlaceable_onSell(SiloExtensionPlaceable.onSell);

function MoneyStats.SellHandToolEvent_run(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_SELLHANDTOOL);
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
SellHandToolEvent.run = MoneyStats.SellHandToolEvent_run(SellHandToolEvent.run);

function MoneyStats.SellPlaceableEvent_run(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_SELLPLACEABLE);
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
SellPlaceableEvent.run = MoneyStats.SellPlaceableEvent_run(SellPlaceableEvent.run);

function MoneyStats.SellVehicleEvent_run(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_SELLVEHICLE);
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
SellVehicleEvent.run = MoneyStats.SellVehicleEvent_run(SellVehicleEvent.run);

function MoneyStats.BaleDestroyerTrigger_triggerCallback(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_BALEDESTROYTRIGGER);
		MoneyStats.activeBaleDestroyTrigger = s;
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
BaleDestroyerTrigger.triggerCallback = MoneyStats.BaleDestroyerTrigger_triggerCallback(BaleDestroyerTrigger.triggerCallback);
--BarnMoverTrigger.triggerCallbackTarget = MoneyStats.BaleDestroyerTrigger_triggerCallback(BarnMoverTrigger.triggerCallbackTarget); --not register in main.lua from giants^^

function MoneyStats.FillablePalletSellTrigger_triggerCallback(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_FILLABLEPALLETTRIGGER);
		MoneyStats.activeFillablePalletSellTrigger = s;
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
FillablePalletSellTrigger.triggerCallback = MoneyStats.FillablePalletSellTrigger_triggerCallback(FillablePalletSellTrigger.triggerCallback);

function MoneyStats.FillTrigger_fill(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_FILLTRIGGER);
		MoneyStats.activeFillTrigger = s;
		local delta = old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
		return delta;
	end;
end;	
FillTrigger.fill = MoneyStats.FillTrigger_fill(FillTrigger.fill);

function MoneyStats.GasStation_fillFuel(old) 
	return function(s, vehicle,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_GASSTATION);
		local v = vehicle;
		if vehicle.attacherVehicle ~= nil then
			v = vehicle.attacherVehicle;
			if vehicle.attacherVehicle.attacherVehicle ~= nil then
				v = vehicle.attacherVehicle.attacherVehicle;
			end;
		end;		
		MoneyStats.activeMoneyGasStationV = v;
		MoneyStats.activeMoneyGasStationS = s;
		local delta = old(s,vehicle,...);
		MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].delta = MoneyStats.activeMoneyGasStationVehicles[MoneyStats.activeMoneyGasStationV].delta + delta;			
		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);
		return delta;
	end;
end;	
GasStation.fillFuel = MoneyStats.GasStation_fillFuel(GasStation.fillFuel);

--[[
function MoneyStats.PalletTrigger_palletTriggerTimerCallback(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_PALLETTRIGGER);
		MoneyStats.activePalletTrigger = s;
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
]]--
--PalletTrigger.palletTriggerTimerCallback = MoneyStats.PalletTrigger_palletTriggerTimerCallback(PalletTrigger.palletTriggerTimerCallback); --not included in main.lua

function MoneyStats.PickupObjectsSellTrigger_triggerCallback(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_PICKUPOBJECTSSELLTRIGGER);
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
PickupObjectsSellTrigger.triggerCallback = MoneyStats.PickupObjectsSellTrigger_triggerCallback(PickupObjectsSellTrigger.triggerCallback);

function MoneyStats.TipTrigger_sellFillType(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_TIPTRIGGER);
		MoneyStats.activeTipTrigger = s;
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
TipTrigger.sellFillType = MoneyStats.TipTrigger_sellFillType(TipTrigger.sellFillType);

function MoneyStats.WoodSellTrigger_triggerCallback(old) 
	return function(s,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_WOODSELLTRIGGER);
		MoneyStats.activeWoodSellTrigger = s;
		old(s,...);		
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
	end;
end;	
WoodSellTrigger.triggerCallback = MoneyStats.WoodSellTrigger_triggerCallback(WoodSellTrigger.triggerCallback);

function MoneyStats.WaterTrailerFillTrigger_fillWater(old) 
	return function(s, vehicle,...)	
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_WATERTRAILERFILLLEVEL);
		local v = vehicle;
		if vehicle.attacherVehicle ~= nil then	
			v = vehicle.attacherVehicle;
			if vehicle.attacherVehicle.attacherVehicle ~= nil then
				v = vehicle.attacherVehicle.attacherVehicle;
			end;
		end;		
		MoneyStats.activeMoneyWaterTrailerFillTriggerV = v;
		local delta = old(s, vehicle,...);
		if s.priceScale > 0 then
			MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[MoneyStats.activeMoneyWaterTrailerFillTriggerV].delta = MoneyStats.activeMoneyWaterTrailerFillTriggerVehicles[MoneyStats.activeMoneyWaterTrailerFillTriggerV].delta + delta;			
		end;
		MoneyStats:setActiveMoneyState(MoneyStats.STATE_NONE);	
		return delta;
	end;
end;	
WaterTrailerFillTrigger.fillWater = MoneyStats.WaterTrailerFillTrigger_fillWater(WaterTrailerFillTrigger.fillWater);

-- function traceback()
  -- local level = 1
  -- while true do
	-- local info = debug.getinfo(level, "Sl")
	-- if not info then break end
	-- if info.what == "C" then   -- is a C function?
	  -- print(level, "C function")
	-- else   -- a Lua function
	  -- print(string.format("[%s]:%d",
						  -- info.short_src, info.currentline))
	-- end
	-- level = level + 1
  -- end
-- end