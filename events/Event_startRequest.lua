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

clientToServerConnection = {};
clientToServerConnection_mt = Class(clientToServerConnection, Event);
InitEventClass(clientToServerConnection, "clientToServerConnection");
function clientToServerConnection:emptyNew()
    return Event:new(clientToServerConnection_mt);
end;
function clientToServerConnection:new()
    return clientToServerConnection:emptyNew();
end;
function clientToServerConnection:readStream(streamId, connection)
	connection:sendEvent(serverStartSynch:new());
end;
function clientToServerConnection:writeStream(streamId, connection)
end;

serverStartSynch = {};
serverStartSynch_mt = Class(serverStartSynch, Event);
InitEventClass(serverStartSynch, "serverStartSynch");
function serverStartSynch:emptyNew()
    return Event:new(serverStartSynch_mt);
end;
function serverStartSynch:new()
    return serverStartSynch:emptyNew();
end;
function serverStartSynch:readStream(streamId, connection)	
	g_mpManager.isConfig = streamReadBool(streamId);
	g_mpManager.isConfigNow = streamReadString(streamId);
	
	if g_mpManager.isConfig then
		g_mpManager.admin:readStream(streamId, connection);
		g_mpManager.farm:readStream(streamId, connection);
		g_mpManager.user:readStream(streamId, connection);
		g_mpManager.settings:readStream(streamId, connection);
		g_mpManager.husbandry:readStream(streamId, connection);
		g_mpManager.assignabels:readStream(streamId, connection);
		g_mpManager.moneyAssignabels:readStream(streamId, connection);
		g_mpManager.moneyStats:readStream(streamId, connection);
		g_mpManager.bill:readStream(streamId, connection);
		g_mpManager.transfer:readStream(streamId, connection);
		--g_mpManager.modulManager:readStream(streamId, connection);
	end;
end;

function serverStartSynch:writeStream(streamId, connection)	
	streamWriteBool(streamId, g_mpManager.isConfig);
	streamWriteString(streamId, Utils.getNoNil(g_mpManager.isConfigNow, ""));
	if g_mpManager.isConfig then
		g_mpManager.admin:writeStream(streamId, connection);
		g_mpManager.farm:writeStream(streamId, connection);
		g_mpManager.user:writeStream(streamId, connection);
		g_mpManager.settings:writeStream(streamId, connection);
		g_mpManager.husbandry:writeStream(streamId, connection);
		g_mpManager.assignabels:writeStream(streamId, connection);
		g_mpManager.moneyAssignabels:writeStream(streamId, connection);
		g_mpManager.moneyStats:writeStream(streamId, connection);
		g_mpManager.bill:writeStream(streamId, connection);
		g_mpManager.transfer:writeStream(streamId, connection);
		--g_mpManager.modulManager:writeStream(streamId, connection);
	end;
end;