-- 
-- MpManager - Event - MoneyStats
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - MoneyStats - Add money stats to farm
MpManagement_MoneyStats_AddMoneyStatsToFarm = {};
MpManagement_MoneyStats_AddMoneyStatsToFarm_mt = Class(MpManagement_MoneyStats_AddMoneyStatsToFarm, Event);
InitEventClass(MpManagement_MoneyStats_AddMoneyStatsToFarm, "MpManagement_MoneyStats_AddMoneyStatsToFarm");
function MpManagement_MoneyStats_AddMoneyStatsToFarm:emptyNew()
	return Event:new(MpManagement_MoneyStats_AddMoneyStatsToFarm_mt);
end;
function MpManagement_MoneyStats_AddMoneyStatsToFarm:new(dat, name, farm, statType, addInfo, addFrom, num, amount)
	local self = MpManagement_MoneyStats_AddMoneyStatsToFarm:emptyNew();
	self.dat = dat;
	self.name = name;
	self.farm = farm:getName();
	self.statType = statType;
	self.addInfo = addInfo;
	self.addFrom = addFrom;
	self.num = tostring(num);
	self.amount = amount;
	return self;
end;
function MpManagement_MoneyStats_AddMoneyStatsToFarm:readStream(streamId, connection)
	self.dat = streamReadString(streamId);
	self.name = streamReadString(streamId);
	self.farm = streamReadString(streamId);
	self.statType = streamReadString(streamId);
	self.addInfo = streamReadString(streamId);
	self.addFrom = streamReadString(streamId);
	self.num = streamReadString(streamId);
	self.amount = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_MoneyStats_AddMoneyStatsToFarm:writeStream(streamId, connection)
	streamWriteString(streamId, self.dat);
	streamWriteString(streamId, self.name);
	streamWriteString(streamId, self.farm);
	streamWriteString(streamId, self.statType);
	streamWriteString(streamId, self.addInfo);
	streamWriteString(streamId, self.addFrom);
	streamWriteString(streamId, self.num);
	streamWriteInt32(streamId, self.amount);
end;
function MpManagement_MoneyStats_AddMoneyStatsToFarm:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.moneyStats:addMoneyStatsToFarm(self.dat, self.name, g_mpManager.utils:getFarmTblFromFarmname(self.farm), self.statType, self.addInfo, self.addFrom, self.num, self.amount, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_MoneyStats_AddMoneyStatsToFarm.sendEvent(dat, name, farm, statType, addInfo, addFrom, num, amount, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_MoneyStats_AddMoneyStatsToFarm:new(dat, name, farm, statType, addInfo, addFrom, num, amount))
		else
			g_client:getServerConnection():sendEvent(MpManagement_MoneyStats_AddMoneyStatsToFarm:new(dat, name, farm, statType, addInfo, addFrom, num, amount))
		end
	end
end;

-- Synch for MpManager  - MoneyStats - Remove money stats from farm
MpManagement_MoneyStats_RemoveMoneyStatsFromFarm = {};
MpManagement_MoneyStats_RemoveMoneyStatsFromFarm_mt = Class(MpManagement_MoneyStats_RemoveMoneyStatsFromFarm, Event);
InitEventClass(MpManagement_MoneyStats_RemoveMoneyStatsFromFarm, "MpManagement_MoneyStats_RemoveMoneyStatsFromFarm");
function MpManagement_MoneyStats_RemoveMoneyStatsFromFarm:emptyNew()
	return Event:new(MpManagement_MoneyStats_RemoveMoneyStatsFromFarm_mt);
end;
function MpManagement_MoneyStats_RemoveMoneyStatsFromFarm:new(farm, posToRemove)
	local self = MpManagement_MoneyStats_RemoveMoneyStatsFromFarm:emptyNew();
	self.farm = farm:getName();
	self.posToRemove = posToRemove;
	return self;
end;
function MpManagement_MoneyStats_RemoveMoneyStatsFromFarm:readStream(streamId, connection)
	self.farm = streamReadString(streamId);
	self.posToRemove = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_MoneyStats_RemoveMoneyStatsFromFarm:writeStream(streamId, connection)
	streamWriteString(streamId, self.farm);
	streamWriteInt32(streamId, self.posToRemove);
end;
function MpManagement_MoneyStats_RemoveMoneyStatsFromFarm:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.moneyStats:removeMoneyStatsFromFarm(g_mpManager.utils:getFarmTblFromFarmname(self.farm), self.posToRemove, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_MoneyStats_RemoveMoneyStatsFromFarm.sendEvent(farm, posToRemove, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_MoneyStats_RemoveMoneyStatsFromFarm:new(farm, posToRemove))
		else
			g_client:getServerConnection():sendEvent(MpManagement_MoneyStats_RemoveMoneyStatsFromFarm:new(farm, posToRemove))
		end
	end
end;