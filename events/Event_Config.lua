-- 
-- MpManager - Event - FinishConfig
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

-- Synch for MpManager finish config
MpManagement_Config_finishConfig = {};
MpManagement_Config_finishConfig_mt = Class(MpManagement_Config_finishConfig, Event);
InitEventClass(MpManagement_Config_finishConfig, "MpManagement_Config_finishConfig");
function MpManagement_Config_finishConfig:emptyNew()
	return Event:new(MpManagement_Config_finishConfig_mt);
end;
function MpManagement_Config_finishConfig:new()
	return MpManagement_Config_finishConfig:emptyNew();
end;
function MpManagement_Config_finishConfig:readStream(streamId, connection)
	
	g_mpManager.isConfig = true;
	--g_mpManager.admin:readStream(streamId, connection);
	--g_mpManager.farm:readStream(streamId, connection);
	--g_mpManager.user:readStream(streamId, connection);

	self:run(connection);
end;

function MpManagement_Config_finishConfig:writeStream(streamId, connection)
	
	--g_mpManager.admin:writeStream(streamId, connection);
	--g_mpManager.farm:writeStream(streamId, connection);
	--g_mpManager.user:writeStream(streamId, connection);
	
end;

function MpManagement_Config_finishConfig:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil)
	end
	--g_mpManager:finishConfig(true);
end;

function MpManagement_Config_finishConfig.sendEvent(noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManagement_Config_finishConfig:new())
		else
			g_client:getServerConnection():sendEvent(MpManagement_Config_finishConfig:new())
		end
	end
end;

-- Synch for MpManager.isConfigNow
MpManager_ConfigAdd_isConfigNow = {};
MpManager_ConfigAdd_isConfigNow_mt = Class(MpManager_ConfigAdd_isConfigNow, Event);
InitEventClass(MpManager_ConfigAdd_isConfigNow, "MpManager_ConfigAdd_isConfigNow");
function MpManager_ConfigAdd_isConfigNow:emptyNew()
	return Event:new(MpManager_ConfigAdd_isConfigNow_mt);
end;
function MpManager_ConfigAdd_isConfigNow:new(name)
	local self = MpManager_ConfigAdd_isConfigNow:emptyNew();
	self.name = name;
	return self;
end;
function MpManager_ConfigAdd_isConfigNow:readStream(streamId, connection)
	self.name = streamReadString(streamId);
	self:run(connection);
end;
function MpManager_ConfigAdd_isConfigNow:writeStream(streamId, connection)
	streamWriteString(streamId, self.name);
end;
function MpManager_ConfigAdd_isConfigNow:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager:setConfigNow(self.name, true);
end;
function MpManager_ConfigAdd_isConfigNow.sendEvent(name, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManager_ConfigAdd_isConfigNow:new(name))
		else
			g_client:getServerConnection():sendEvent(MpManager_ConfigAdd_isConfigNow:new(name))
		end
	end
end;

-- Synch for MpManager.isConfig
MpManager_ConfigAdd_isConfig = {};
MpManager_ConfigAdd_isConfig_mt = Class(MpManager_ConfigAdd_isConfig, Event);
InitEventClass(MpManager_ConfigAdd_isConfig, "MpManager_ConfigAdd_isConfig");
function MpManager_ConfigAdd_isConfig:emptyNew()
	return Event:new(MpManager_ConfigAdd_isConfig_mt);
end;
function MpManager_ConfigAdd_isConfig:new(state)
	local self = MpManager_ConfigAdd_isConfig:emptyNew();
	self.state = state;
	return self;
end;
function MpManager_ConfigAdd_isConfig:readStream(streamId, connection)
	self.state = streamReadBool(streamId);
	self:run(connection);
end;
function MpManager_ConfigAdd_isConfig:writeStream(streamId, connection)
	streamWriteBool(streamId, self.state);
end;
function MpManager_ConfigAdd_isConfig:run(connection)
	if not connection:getIsServer() then
		g_server:broadcastEvent(self, false, connection, nil);
	end
	g_mpManager:setConfig(self.state, true);
end;
function MpManager_ConfigAdd_isConfig.sendEvent(state, noEventSend)
	if (noEventSend == nil or noEventSend == false) then
		if g_server ~= nil then
			g_server:broadcastEvent(MpManager_ConfigAdd_isConfig:new(state))
		else
			g_client:getServerConnection():sendEvent(MpManager_ConfigAdd_isConfig:new(state))
		end
	end
end;