-- 
-- MpManager - Event - MoneyAssignment
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 21.06.2018
-- @Version: 1.1.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - MoneyAssignment - Add Assignment 
MpManagement_MoneyAssignment_AddAssignment = {};
MpManagement_MoneyAssignment_AddAssignment_mt = Class(MpManagement_MoneyAssignment_AddAssignment, Event);
InitEventClass(MpManagement_MoneyAssignment_AddAssignment, "MpManagement_MoneyAssignment_AddAssignment");
function MpManagement_MoneyAssignment_AddAssignment:emptyNew()
	return Event:new(MpManagement_MoneyAssignment_AddAssignment_mt);
end;
function MpManagement_MoneyAssignment_AddAssignment:new(id, statType, money)
	local self = MpManagement_MoneyAssignment_AddAssignment:emptyNew();
	self.id = id;
	self.statType = statType;
	self.money = money;
	return self;
end;
function MpManagement_MoneyAssignment_AddAssignment:readStream(streamId, connection)
	self.id = streamReadInt32(streamId);
	self.statType = streamReadString(streamId);
	self.money = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_MoneyAssignment_AddAssignment:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.id);
	streamWriteString(streamId, self.statType);
	streamWriteInt32(streamId, self.money);
end;
function MpManagement_MoneyAssignment_AddAssignment:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.moneyAssignabels:addAssignment(self.id, self.statType, self.money, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_MoneyAssignment_AddAssignment.sendEvent(id, statType, money, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_MoneyAssignment_AddAssignment:new(id, statType, money))
		else
			g_client:getServerConnection():sendEvent(MpManagement_MoneyAssignment_AddAssignment:new(id, statType, money))
		end
	end
end;

-- Synch for MpManager  - MoneyAssignment - Remove Assignment 
MpManagement_MoneyAssignment_RemoveAssignment = {};
MpManagement_MoneyAssignment_RemoveAssignment_mt = Class(MpManagement_MoneyAssignment_RemoveAssignment, Event);
InitEventClass(MpManagement_MoneyAssignment_RemoveAssignment, "MpManagement_MoneyAssignment_RemoveAssignment");
function MpManagement_MoneyAssignment_RemoveAssignment:emptyNew()
	return Event:new(MpManagement_MoneyAssignment_RemoveAssignment_mt);
end;
function MpManagement_MoneyAssignment_RemoveAssignment:new(id, playerName)
	local self = MpManagement_MoneyAssignment_RemoveAssignment:emptyNew();
	self.id = id;
	self.playerName = playerName;
	return self;
end;
function MpManagement_MoneyAssignment_RemoveAssignment:readStream(streamId, connection)
	self.id = streamReadInt32(streamId);
	self.playerName = streamReadString(streamId);
	self:run(connection);
end;
function MpManagement_MoneyAssignment_RemoveAssignment:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.id);
	streamWriteString(streamId, self.playerName);
end;
function MpManagement_MoneyAssignment_RemoveAssignment:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.moneyAssignabels:removeAssignment(self.id, self.playerName, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_MoneyAssignment_RemoveAssignment.sendEvent(id, playerName, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_MoneyAssignment_RemoveAssignment:new(id, playerName))
		else
			g_client:getServerConnection():sendEvent(MpManagement_MoneyAssignment_RemoveAssignment:new(id, playerName))
		end
	end
end;