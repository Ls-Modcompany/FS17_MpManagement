-- 
-- MpManager - Transfer
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerTransfer = {};
g_mpManager.transfer = MpManagerTransfer;

MpManagerTransfer.id = 0;
MpManagerTransfer.transfers = {};

function MpManagerTransfer:load()
	g_mpManager.saveManager:addSave(MpManagerTransfer.saveSavegame, MpManagerTransfer);
	g_mpManager.loadManager:addLoad(MpManagerTransfer.loadSavegame, MpManagerTransfer);
end;

function MpManagerTransfer:getNextId(noEventSend)
	MpManagement_Transfer_GetNextId.sendEvent(noEventSend)
	MpManagerTransfer.id = MpManagerTransfer.id + 1;
	return MpManagerTransfer.id;
end;

function MpManagerTransfer:formatId(id)
	local addText = "";
	if id < 10 then
		addText = "000";
	elseif id < 100 then
		addText = "00";
	elseif id < 1000 then
		addText = "0";
	end;
	return string.format("%s%s",addText, id);
end;

--id, empf(farmname), zweck, zweckAdd, money(int), sender(playername), date(string)
function MpManagerTransfer:addTransfer(transferdata, noEventSend)
	MpManagement_Transfer_NewTransfer.sendEvent(transferdata, noEventSend)
	table.insert(MpManagerTransfer.transfers, transferdata);
	g_gui.guis["MpManagerScreen"].target:loadTransfers();
end;

function MpManagerTransfer:deleteTransferById(transferId, noEventSend)
	MpManagement_Transfer_DeleteById.sendEvent(transferId, noEventSend)
	for id,transfer in pairs(MpManagerTransfer.transfers) do
		if transfer.id == transferId then
			table.remove(MpManagerTransfer.transfers, id);
		end;
	end;
	g_gui.guis["MpManagerScreen"].target:loadTransfers();
end;

function MpManagerTransfer:onFarmDelete(deleteName)
	for _,transfer in pairs(MpManagerTransfer.transfers) do
		if transfer.empf == deleteName or g_mpManager.utils:getFarmFromUsername(transfer.sender) == deleteName then
			MpManagerTransfer:deleteTransferById(transfer.id);
		end;
	end;
end;

function MpManagerTransfer:onPlayerDelete(deleteName)
	for _,transfer in pairs(MpManagerTransfer.transfers) do
		if transfer.sender == deleteName then
			MpManagerTransfer:deleteTransferById(transfer.id);
		end;
	end;
end;

function MpManagerTransfer:onFarmNameChange(oldName, newName, noEventSend)
	MpManagement_Transfer_OnFarmNameChange.sendEvent(oldName, newName, noEventSend)
	for _,transfer in pairs(MpManagerTransfer.transfers) do
		if transfer.empf == oldName then
			transfer.empf = newName;
		end;
	end;
end;

function MpManagerTransfer:onPlayerNameChange(oldName, newName, noEventSend)
	MpManagement_Transfer_OnPlayerNameChange.sendEvent(oldName, newName, noEventSend)
	for _,transfer in pairs(MpManagerTransfer.transfers) do
		if transfer.sender == oldName then
			transfer.sender = newName;
		end;
	end;
end;

function MpManagerTransfer:getTransfersByFarmname(name)
	local transfers = {};
	for _,transfer in pairs(MpManagerTransfer.transfers) do
		if transfer.empf == name or g_mpManager.utils:getFarmFromUsername(transfer.sender) == name then
			table.insert(transfers, transfer);
		end;
	end;
	return transfers;
end;

function MpManagerTransfer:saveSavegame()
	g_mpManager.saveManager:setXmlInt("transfers#id", MpManagerTransfer.id);
	local index = 0;
	for _,transfer in pairs(MpManagerTransfer.transfers) do
		g_mpManager.saveManager:setXmlInt(string.format("transfers.transfer(%d)#id", index), transfer.id);
		g_mpManager.saveManager:setXmlString(string.format("transfers.transfer(%d)#empf", index), transfer.empf);
		g_mpManager.saveManager:setXmlString(string.format("transfers.transfer(%d)#zweck", index), transfer.zweck);
		g_mpManager.saveManager:setXmlString(string.format("transfers.transfer(%d)#zweckAdd", index), transfer.zweckAdd);
		g_mpManager.saveManager:setXmlInt(string.format("transfers.transfer(%d)#money", index), transfer.money);
		g_mpManager.saveManager:setXmlString(string.format("transfers.transfer(%d)#sender", index), transfer.sender);
		g_mpManager.saveManager:setXmlString(string.format("transfers.transfer(%d)#date", index), transfer.date);		
		index = index + 1;
	end;
end;

function MpManagerTransfer:loadSavegame()
	MpManagerTransfer.id = Utils.getNoNil(g_mpManager.loadManager:getXmlInt("transfers#id"), MpManagerTransfer.id);
	local index = 0;
	while true do
		local addKey = string.format("transfers.transfer(%d)", index);
		if not g_mpManager.loadManager:hasXmlProperty(addKey) then
			break;
		end
		local id = g_mpManager.loadManager:getXmlInt(addKey .. "#id");
		local empf = g_mpManager.loadManager:getXmlString(addKey .. "#empf");
		local zweck = g_mpManager.loadManager:getXmlString(addKey .. "#zweck");
		local zweckAdd = g_mpManager.loadManager:getXmlString(addKey .. "#zweckAdd");
		local money = g_mpManager.loadManager:getXmlInt(addKey .. "#money");
		local sender = g_mpManager.loadManager:getXmlString(addKey .. "#sender");
		local dat = g_mpManager.loadManager:getXmlString(addKey .. "#date");		
		MpManagerTransfer:addTransfer({id=id, empf=empf, zweck=zweck, zweckAdd=zweckAdd, money=money, sender=sender, date=dat}, true);		
		index = index + 1;
	end;
end;

function MpManagerTransfer:writeStream(streamId, connection)
	streamWriteInt32(streamId, MpManagerTransfer.id);
	streamWriteInt32(streamId, table.getn(MpManagerTransfer.transfers));
	for _,transfer in pairs(MpManagerTransfer.transfers) do
		streamWriteInt32(streamId, transfer.id);
		streamWriteString(streamId, transfer.empf);
		streamWriteString(streamId, transfer.zweck);
		streamWriteString(streamId, transfer.zweckAdd);
		streamWriteInt32(streamId, transfer.money);
		streamWriteString(streamId, transfer.sender);
		streamWriteString(streamId, transfer.date);
	end;
end;

function MpManagerTransfer:readStream(streamId, connection)
	MpManagerTransfer.id = streamReadInt32(streamId);
	local count = streamReadInt32(streamId);
	for i=1, count do
		local id = streamReadInt32(streamId);
		local empf = streamReadString(streamId);
		local zweck = streamReadString(streamId);
		local zweckAdd = streamReadString(streamId);
		local money = streamReadInt32(streamId);
		local sender = streamReadString(streamId);
		local dat = streamReadString(streamId);
		MpManagerTransfer:addTransfer({id=id, empf=empf, zweck=zweck, zweckAdd=zweckAdd, money=money, sender=sender, date=dat}, true);		
	end;
end;