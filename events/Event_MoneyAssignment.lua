-- 
-- MpManager - Event - MoneyAssignment
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager  - MoneyAssignment - Add Dialog
MpManagement_MoneyAssignment_AddDialog = {};
MpManagement_MoneyAssignment_AddDialog_mt = Class(MpManagement_MoneyAssignment_AddDialog, Event);
InitEventClass(MpManagement_MoneyAssignment_AddDialog, "MpManagement_MoneyAssignment_AddDialog");
function MpManagement_MoneyAssignment_AddDialog:emptyNew()
	return Event:new(MpManagement_MoneyAssignment_AddDialog_mt);
end;
function MpManagement_MoneyAssignment_AddDialog:new(id, statType, money)
	local self = MpManagement_MoneyAssignment_AddDialog:emptyNew();
	self.id = id;
	self.statType = statType;
	self.money = money;
	return self;
end;
function MpManagement_MoneyAssignment_AddDialog:readStream(streamId, connection)
	self.id = streamReadInt32(streamId);
	self.statType = streamReadString(streamId);
	self.money = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_MoneyAssignment_AddDialog:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.id);
	streamWriteString(streamId, self.statType);
	streamWriteInt32(streamId, self.money);
end;
function MpManagement_MoneyAssignment_AddDialog:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.moneyAssignabels:addDialog(self.id, self.statType, self.money, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_MoneyAssignment_AddDialog.sendEvent(id, statType, money, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_MoneyAssignment_AddDialog:new(id, statType, money))
		else
			g_client:getServerConnection():sendEvent(MpManagement_MoneyAssignment_AddDialog:new(id, statType, money))
		end
	end
end;

-- Synch for MpManager  - MoneyAssignment - Remove dialog
MpManagement_MoneyAssignment_RemoveDialog = {};
MpManagement_MoneyAssignment_RemoveDialog_mt = Class(MpManagement_MoneyAssignment_RemoveDialog, Event);
InitEventClass(MpManagement_MoneyAssignment_RemoveDialog, "MpManagement_MoneyAssignment_RemoveDialog");
function MpManagement_MoneyAssignment_RemoveDialog:emptyNew()
	return Event:new(MpManagement_MoneyAssignment_RemoveDialog_mt);
end;
function MpManagement_MoneyAssignment_RemoveDialog:new(id)
	local self = MpManagement_MoneyAssignment_RemoveDialog:emptyNew();
	self.id = id;
	return self;
end;
function MpManagement_MoneyAssignment_RemoveDialog:readStream(streamId, connection)
	self.id = streamReadInt32(streamId);
	self:run(connection);
end;
function MpManagement_MoneyAssignment_RemoveDialog:writeStream(streamId, connection)
	streamWriteInt32(streamId, self.id);
end;
function MpManagement_MoneyAssignment_RemoveDialog:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager.moneyAssignabels:removeDialog(self.id, true);
	g_mpManager.reloadScreen = true;
end;
function MpManagement_MoneyAssignment_RemoveDialog.sendEvent(id, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_MoneyAssignment_RemoveDialog:new(id))
		else
			g_client:getServerConnection():sendEvent(MpManagement_MoneyAssignment_RemoveDialog:new(id))
		end
	end
end;