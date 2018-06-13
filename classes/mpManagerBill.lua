-- 
-- MpManager - Bill
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerBill = {};
g_mpManager.bill = MpManagerBill;


MpManagerBill.STATE_UNPAYED = 1;
MpManagerBill.STATE_PAYED = 2;

MpManagerBill.id = 0;
MpManagerBill.bills = {};

function MpManagerBill:load()
	g_mpManager.saveManager:addSave(MpManagerBill.saveSavegame, MpManagerBill);
	g_mpManager.loadManager:addLoad(MpManagerBill.loadSavegame, MpManagerBill);
end;

function MpManagerBill:getNextId(noEventSend)
	MpManagement_Bill_GetNextId.sendEvent(noEventSend)
	MpManagerBill.id = MpManagerBill.id + 1;
	return MpManagerBill.id;
end;

function MpManagerBill:formatId(id)
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

--num(billId), address(farmname), sender(playername), state, date, entries(table)
--	entries: workId, place(name), num, price
function MpManagerBill:addBill(billdata, noEventSend)
	MpManagement_Bill_NewBill.sendEvent(billdata, noEventSend)
	table.insert(MpManagerBill.bills, billdata);
	g_gui.guis["MpManagerScreen"].target:loadBills();
end;

function MpManagerBill:getBillsByFarmname(name)
	local bills = {};
	for _,bill in pairs(MpManagerBill.bills) do
		if bill.address == name or g_mpManager.utils:getFarmFromUsername(bill.sender) == name then
			table.insert(bills, bill);
		end;
	end;
	return bills;
end;

function MpManagerBill:getStateText(state)
	return g_i18n:getText("billsState_" .. state);
end;

function MpManagerBill:setState(billId, state, noEventSend)
	MpManagement_Bill_SetState.sendEvent(billId, state, noEventSend)
	for _,bill in pairs(MpManagerBill.bills) do
		if bill.num == billId then
			bill.state = state;
		end;
	end;
	g_gui.guis["MpManagerScreen"].target:loadBills();
end;

function MpManagerBill:deleteBillById(billId, noEventSend)
	MpManagement_Bill_DeleteById.sendEvent(billId, noEventSend)
	for id,bill in pairs(MpManagerBill.bills) do
		if bill.num == billId then
			table.remove(MpManagerBill.bills, id);
		end;
	end;
	g_gui.guis["MpManagerScreen"].target:loadBills();
end;

function MpManagerBill:onFarmNameChange(oldName, newName, noEventSend)
	MpManagement_Bill_OnFarmNameChange.sendEvent(oldName, newName, noEventSend)
	for _,bill in pairs(MpManagerBill.bills) do
		if bill.address == oldName then
			bill.address = newName;
		end;
	end;
end;

function MpManagerBill:onPlayerNameChange(oldName, newName, noEventSend)
	MpManagement_Bill_OnPlayerNameChange.sendEvent(oldName, newName, noEventSend)
	for _,bill in pairs(MpManagerBill.bills) do
		if bill.sender == oldName then
			bill.sender = newName;
		end;
	end;
end;

function MpManagerBill:onFarmDelete(deleteName)
	for _,bill in pairs(MpManagerBill.bills) do
		if bill.address == deleteName or g_mpManager.utils:getFarmFromUsername(bill.sender) == deleteName then
			MpManagerBill:deleteBillById(bill.num);
		end;
	end;
end;

function MpManagerBill:onPlayerDelete(deleteName)
	for _,bill in pairs(MpManagerBill.bills) do
		if bill.sender == deleteName then
			MpManagerBill:deleteBillById(bill.num);
		end;
	end;
end;

function MpManagerBill:saveSavegame()
	g_mpManager.saveManager:setXmlInt("bills#id", MpManagerBill.id);
	local index = 0;
	for _,bill in pairs(MpManagerBill.bills) do
		g_mpManager.saveManager:setXmlInt(string.format("bills.bill(%d)#num", index), bill.num);
		g_mpManager.saveManager:setXmlString(string.format("bills.bill(%d)#address", index), bill.address);
		g_mpManager.saveManager:setXmlString(string.format("bills.bill(%d)#sender", index), bill.sender);
		g_mpManager.saveManager:setXmlInt(string.format("bills.bill(%d)#state", index), bill.state);
		g_mpManager.saveManager:setXmlString(string.format("bills.bill(%d)#date", index), bill.date);
		
		local index2 = 0;
		for _,e in pairs(bill.entries) do
			g_mpManager.saveManager:setXmlInt(string.format("bills.bill(%d).entry(%d)#workId", index, index2), e.workId);
			g_mpManager.saveManager:setXmlString(string.format("bills.bill(%d).entry(%d)#place", index, index2), e.place);
			g_mpManager.saveManager:setXmlInt(string.format("bills.bill(%d).entry(%d)#num", index, index2), Utils.getNoNil(e.num, 0));
			g_mpManager.saveManager:setXmlInt(string.format("bills.bill(%d).entry(%d)#price", index, index2), e.price);
			index2 = index2 + 1;
		end;
		index = index + 1;
	end;
end;

function MpManagerBill:loadSavegame()
	MpManagerBill.id = Utils.getNoNil(g_mpManager.loadManager:getXmlInt("bills#id"), MpManagerBill.id);
	local index = 0;
	while true do
		local addKey = string.format("bills.bill(%d)", index);
		if not g_mpManager.loadManager:hasXmlProperty(addKey) then
			break;
		end
		local num = g_mpManager.loadManager:getXmlInt(addKey .. "#num");
		local address = g_mpManager.loadManager:getXmlString(addKey .. "#address");
		local sender = g_mpManager.loadManager:getXmlString(addKey .. "#sender");
		local state = g_mpManager.loadManager:getXmlInt(addKey .. "#state");
		local dat = g_mpManager.loadManager:getXmlString(addKey .. "#date");
		
		local entries = {};
		local index2 = 0;
		while true do
			local addKey2 = string.format("bills.bill(%d).entry(%d)", index, index2);
			if not g_mpManager.loadManager:hasXmlProperty(addKey2) then
				break;
			end;
			local workId = g_mpManager.loadManager:getXmlInt(addKey2 .. "#workId");
			local place = g_mpManager.loadManager:getXmlString(addKey2 .. "#place");
			local numE = g_mpManager.loadManager:getXmlInt(addKey2 .. "#num");
			local price = g_mpManager.loadManager:getXmlInt(addKey2 .. "#price");
			table.insert(entries, {workId=workId, place=place, num=numE, price=price});			
			index2 = index2 + 1;
		end;
		MpManagerBill:addBill({num=num, address=address, sender=sender, entries=entries, state=state, date=dat}, true);		
		index = index + 1;
	end;
end;

function MpManagerBill:writeStream(streamId, connection)
	streamWriteInt32(streamId, MpManagerBill.id);
	streamWriteInt32(streamId, table.getn(MpManagerBill.bills));
	for _,bill in pairs(MpManagerBill.bills) do
		streamWriteInt32(streamId, bill.num);
		streamWriteString(streamId, bill.address);
		streamWriteString(streamId, bill.sender);
		streamWriteInt16(streamId, bill.state);
		streamWriteString(streamId, bill.date);
		
		streamWriteInt32(streamId, table.getn(bill.entries));
		for _,e in pairs(bill.entries) do
			streamWriteInt32(streamId, e.workId);
			streamWriteString(streamId, e.place);
			streamWriteInt32(streamId, Utils.getNoNil(e.num, 0));
			streamWriteInt32(streamId, e.price);
		end;				
	end;
end;

function MpManagerBill:readStream(streamId, connection)
	MpManagerBill.id = streamReadInt32(streamId);
	local count = streamReadInt32(streamId);
	for i=1, count do
		local num = streamReadInt32(streamId);
		local address = streamReadString(streamId);
		local sender = streamReadString(streamId);
		local state = streamReadInt16(streamId);
		local dat = streamReadString(streamId);
		
		local entries = {};
		local numC = streamReadInt32(streamId);
		for j=1, numC do
			local workId = streamReadInt32(streamId);
			local place = streamReadString(streamId);
			local numE = streamReadInt32(streamId);
			local price = streamReadInt32(streamId);
			table.insert(entries, {workId=workId, place=place, num=numE, price=price});	
		end;
		MpManagerBill:addBill({num=num, address=address, sender=sender, entries=entries, state=state, date=dat}, true);	
	end;
end;