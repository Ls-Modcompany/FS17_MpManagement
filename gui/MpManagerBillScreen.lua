-- 
-- MpManager - ConfigScreen
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerBillScreen = {};

local MpManagerBillScreen_mt = Class(MpManagerBillScreen, ScreenElement);

function MpManagerBillScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerBillScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    return self;
end;

function MpManagerBillScreen:onCreate()
	self.gui_paperBackground:setImageFilename(g_mpManager.dir .. "huds/Papier.dds");
	self.gui_paperLogo:setImageFilename(g_mpManager.dir .. "huds/RechnungLogo.dds");
	self.gui_payedLogo:setImageFilename(g_mpManager.dir .. "huds/Stempel.dds");
	
	self.mpManagerBillUiPage1_list:removeElement(self.gui_bill_itemTemplate);
	
end;

function MpManagerBillScreen:onClose(element)
    MpManagerBillScreen:superClass().onClose(self);
end

function MpManagerBillScreen:onOpen()
    MpManagerBillScreen:superClass().onOpen(self);
	self.gui_rightSide_createBill:setVisible(true);
	self.gui_rightSide_showBill:setVisible(false);
	self.gui_payedLogo:setVisible(false);
	self:reset();
end;

function MpManagerBillScreen:onClickResest()	
	self:reset();
end;

function MpManagerBillScreen:reset()	
	self.places = g_mpManager.utils:getPlaces();
	self.works = g_mpManager.data:getWorks();
	
	self.address = {}
	for _, farm in pairs(g_mpManager.farm:getFarms()) do	
		table.insert(self.address, farm:getName());
	end;		
	
	self.nums = {};
	for i=1, 100 do
		table.insert(self.nums, {name=tostring(i)});
	end;
	
	self.gui_rS_work:setText(g_i18n:getText("mpManager_Bill_info03"));
	self.gui_rS_place:setText(g_i18n:getText("mpManager_Bill_info03"));
	self.gui_rS_num:setText(g_i18n:getText("mpManager_Bill_info03"));
	
	self.gui_billSelectionAdr:setTexts(self.address, true);
	self.gui_billSelectionAdr:setState(1);
	self.currentAddress = self.gui_billSelectionAdr:getState();
	self.gui_addr_farmleader:setText(g_mpManager.utils:getFarmTblFromFarmname(self.address[self.currentAddress]):getLeader());
	self.gui_addr_farm:setText(g_mpManager.utils:getFarmTblFromFarmname(self.address[self.currentAddress]):getName());
	
	self.count = 1;
	
	self.gui_addr_from_farm:setText(g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName));
	self.gui_addr_from_name:setText(g_currentMission.missionInfo.playerName);
	self.date = g_mpManager.moneyStats:getDate();
	self.gui_addr_date:setText(self.date);
	
	self.entries = {};
	self.currentEntry = {};
	self.mpManagerBillUiPage1_list:deleteListItems();
	self.gui_button_addEntry:setVisible(false);
	self.gui_arrow1:setVisible(false);
	self.gui_arrow2:setVisible(false);
	self.gui_fullPrice:setText(g_i18n:formatMoney(0,0,true));
end;

function MpManagerBillScreen:onClickBack()
	g_gui:closeDialogByName("MpManagerBillScreen");
end;

function MpManagerBillScreen:onClickAddEntry()
	if self.currentEntry.workId ~= nil and self.currentEntry.place ~= nil and (self.currentEntry.num ~= nil or self.currentEntry.ignoreNum) then

		local newItem = self.gui_bill_itemTemplate:clone(self.mpManagerBillUiPage1_list);	
		newItem:updateAbsolutePosition();		
		self.mpManagerBillUiPage1_list:updateItemPositions();
		
		local price = 0;
		local w = self.works[self.currentEntry.workId];
		local p = g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName):getWorkpriceByName(w.name);
		if w.unit == "ha" then
			price = p * self:getHaFromFieldname(self.currentEntry.place);
		else
			price = p * self.currentEntry.num;
		end;
		table.insert(self.entries, {workId=self.currentEntry.workId, place=self.currentEntry.place, num=self.currentEntry.num, price=price});
		self.count = self.count + 1;
		
		--reset
		self.gui_rS_work:setText(g_i18n:getText("mpManager_Bill_info03"));
		self.gui_rS_place:setText(g_i18n:getText("mpManager_Bill_info03"));
		self.gui_rS_num:setText(g_i18n:getText("mpManager_Bill_info03"));
		self.currentEntry = {};
		self.gui_button_addEntry:setVisible(false);
		self.gui_rS_num:setVisible(true);
		self.gui_rS_num_header:setVisible(true);
		self.gui_rS_num_background:setVisible(true);
		self.gui_button_num:setVisible(true);
		self.gui_arrow1:setVisible(table.getn(self.entries) > 6);
		self.gui_arrow2:setVisible(table.getn(self.entries) > 6);
		self.gui_fullPrice:setText(g_i18n:formatMoney(self:calcFullPrice(),0,true));
	end;
end;

function MpManagerBillScreen:onClickApply()
	if table.getn(self.entries) > 0 then
		local bill = {num=self.billId, address=g_mpManager.utils:getFarmTblFromFarmname(self.address[self.currentAddress]):getName(), 
						sender=g_currentMission.missionInfo.playerName, entries=self.entries, date=self.date, state=g_mpManager.bill.STATE_UNPAYED};
		g_mpManager.bill:addBill(bill);
		g_gui:closeDialogByName("MpManagerBillScreen");
	end;
end;

function MpManagerBillScreen:update(dt)
    MpManagerBillScreen:superClass().update(self, dt);	
end

function MpManagerBillScreen:setData(data)
    if data ~= nil then
		self.gui_rightSide_createBill:setVisible(false);
		self.gui_rightSide_showBill:setVisible(true);
		
		self.entries = {};
		self.mpManagerBillUiPage1_list:deleteListItems();
		for _,entry in pairs(data.entries) do
			self.currentEntry = {};
			self.currentEntry = entry;
			local newItem = self.gui_bill_itemTemplate:clone(self.mpManagerBillUiPage1_list);	
			newItem:updateAbsolutePosition();		
			self.mpManagerBillUiPage1_list:updateItemPositions();
			self.currentEntry = nil;
			self.count = self.count + 1;
			table.insert(self.entries, entry);
		end;
		self.gui_addr_billNum:setText(g_mpManager.bill:formatId(data.num));
		self.gui_fullPrice:setText(g_i18n:formatMoney(self:calcFullPrice(),0,true));
		self.gui_addr_farmleader:setText(g_mpManager.utils:getFarmTblFromFarmname(data.address):getLeader());
		self.gui_addr_farm:setText(data.address);		
		self.gui_addr_from_farm:setText(g_mpManager.utils:getFarmFromUsername(data.sender));
		self.gui_addr_from_name:setText(data.sender);
		self.gui_addr_date:setText(data.date);
		self.gui_button_delete:setVisible(data.state == g_mpManager.bill.STATE_PAYED);		
		
		local access = false;
		if data.state ~= g_mpManager.bill.STATE_PAYED then 
			if g_mpManager.settings:getState("bills_pay") == 1 then --Jeder
				access = true;
			elseif g_mpManager.settings:getState("bills_pay") == 2 then --FarmLeader
				if g_mpManager.utils:getUsernameIsLeader(g_currentMission.missionInfo.playerName) then
					access = true;
				end;
			end;
			if data.address ~= g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName) then
				access = false;
			end;
		end;
		self.gui_button_transfer:setVisible(access);	
		
		self.gui_payedLogo:setVisible(data.state == g_mpManager.bill.STATE_PAYED);
		self.currentAddressFarm = g_mpManager.utils:getFarmFromUsername(data.sender);
		self.billId = data.num;
		self.copyData = data;
	else
		self.billId = g_mpManager.bill:getNextId();
	end;
	self.gui_addr_billNum:setText(g_mpManager.bill:formatId(self.billId));
end

function MpManagerBillScreen:onCreate_item_pos(element)
	if self.count ~= nil then
		element:setText(tostring(self.count));
	end;
end;

function MpManagerBillScreen:onCreate_item_num(element)
	if self.currentEntry ~= nil and self.currentEntry.workId ~= nil then
		local w = self.works[self.currentEntry.workId];
		local addUnit = " " .. g_mpManager.data:getUnitShortText(w.unit);
		if w.unit == "ha" then
			element:setText(g_i18n:formatMoney(self:getHaFromFieldname(self.currentEntry.place),2,false) .. addUnit);
		else 
			element:setText(g_i18n:formatMoney(self.currentEntry.num,0,false) .. addUnit);
		end;
	end;
end;

function MpManagerBillScreen:onCreate_item_priceOne(element)
	if self.currentEntry ~= nil and self.currentEntry.workId ~= nil then
		local price = g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName):getWorkpriceByName(self.works[self.currentEntry.workId].name);
		element:setText(g_i18n:formatMoney(price,0,false));
	end;
end;

function MpManagerBillScreen:onCreate_item_priceAll(element)
	if self.currentEntry ~= nil and self.currentEntry.workId ~= nil then	
		local w = self.works[self.currentEntry.workId];
		local price = g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName):getWorkpriceByName(self.works[self.currentEntry.workId].name);
		if w.unit == "ha" then
			element:setText(g_i18n:formatMoney(price * self:getHaFromFieldname(self.currentEntry.place),0,false));
		else
			element:setText(g_i18n:formatMoney(price * self.currentEntry.num,0,false));
		end;
	end;
end;

function MpManagerBillScreen:onCreate_item_desc1(element)
	if self.currentEntry ~= nil and self.currentEntry.workId ~= nil then
		element:setText(g_mpManager.data:getWorkText(self.works[self.currentEntry.workId].name));
	end;
end;

function MpManagerBillScreen:onCreate_item_desc2(element)
	if self.currentEntry ~= nil and self.currentEntry.place ~= nil then
		local addText = "";
		for _,v in pairs(self.places) do
			if v.name == self.currentEntry.place and v.area ~= nil then
				addText = " (" .. g_i18n:formatMoney(v.area,2,false) .. " HA)";
				break;
			end;
		end;
		element:setText(self.currentEntry.place .. addText);
	end;
end;

function MpManagerBillScreen:onClickBillSelectionAddr(state)
	self.currentAddress = state;
	self.gui_addr_farmleader:setText(g_mpManager.utils:getFarmTblFromFarmname(self.address[state]):getLeader());
	self.gui_addr_farm:setText(g_mpManager.utils:getFarmTblFromFarmname(self.address[self.currentAddress]):getName());
end;



function MpManagerBillScreen:onClickOpenWork()
	local data = {};
	for _,work in pairs(self.works) do		
		local price = g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName):getWorkpriceByName(work.name)
		table.insert(data, {row1=g_mpManager.data:getWorkText(work.name), row2=g_mpManager.data:getUnitText(work.unit), row3=g_i18n:formatMoney(price,0,true)});
	end;
	g_mpManager:showSelectionScreen(self.onClickOpenWorkOk, self, data, 3, g_i18n:getText("mpManager_Bill_button04"), g_i18n:getText("work_flow_item1"), g_i18n:getText("work_flow_item2"), g_i18n:getText("work_flow_item3"));
end;
function MpManagerBillScreen:onClickOpenWorkOk(index)
	self.currentEntry.workId = self.works[index].id;
	self.gui_rS_work:setText(g_mpManager.data:getWorkText(self.works[index].name));
	
	if self.works[index].unit == "ha" then
		self.currentEntry.ignoreNum = true;
		self.currentEntry.needArea = true;
	else
		self.currentEntry.ignoreNum = false;
		self.currentEntry.needArea = false;
	end;
	self.gui_rS_num:setVisible(not self.currentEntry.ignoreNum);
	self.gui_rS_num_header:setVisible(not self.currentEntry.ignoreNum);
	self.gui_rS_num_background:setVisible(not self.currentEntry.ignoreNum);
	self.gui_button_num:setVisible(not self.currentEntry.ignoreNum);
	
	self.gui_button_addEntry:setVisible(self:canApplyCurrentEntry());
end;

function MpManagerBillScreen:onClickOpenPlace()
	local data = {};
	for _,place in pairs(self.places) do
		table.insert(data, {row1=place.name});
	end;
	g_mpManager:showSelectionScreen(self.onClickOpenPlaceOk, self, data, 1, g_i18n:getText("mpManager_Bill_button05"), g_i18n:getText("work_flow_item4"));
end;
function MpManagerBillScreen:onClickOpenPlaceOk(index)
	self.currentEntry.place = self.places[index].name;
	self.gui_rS_place:setText(self.places[index].name);
	self.gui_button_addEntry:setVisible(self:canApplyCurrentEntry());
end;

function MpManagerBillScreen:onClickOpenNum()
	local data = {};
	for _,num in pairs(self.nums) do
		table.insert(data, {row1=num.name});
	end;
	g_mpManager:showSelectionScreen(self.onClickOpenNumOk, self, data, 1, g_i18n:getText("mpManager_Bill_button06"), g_i18n:getText("work_flow_item5"));
end;
function MpManagerBillScreen:onClickOpenNumOk(index)
	self.currentEntry.num = tonumber(self.nums[index].name);
	self.gui_rS_num:setText(tostring(self.nums[index].name));
	self.gui_button_addEntry:setVisible(self:canApplyCurrentEntry());
end;

function MpManagerBillScreen:getHaFromFieldname(name)
	for _,v in pairs(self.places) do
		if v.name == name then
			return v.area;
		end;
	end;
end;

function MpManagerBillScreen:canApplyCurrentEntry()
	if self.currentEntry ~= nil and self.currentEntry.workId ~= nil and self.currentEntry.place ~= nil then		
		if self.currentEntry.num ~= nil then
			return true;
		elseif self.currentEntry.ignoreNum and self.currentEntry.needArea and self.currentEntry.place ~= nil then
			if self:getHaFromFieldname(self.currentEntry.place) ~= nil then
				return true;
			end;
		elseif self.currentEntry.ignoreNum and not self.currentEntry.needArea then
			return true;
		end;
	end;
	return false;
end;

function MpManagerBillScreen:calcFullPrice()
	local p = 0;
	if self.entries ~= nil then
		for _,entry in pairs(self.entries) do
			--p = p + g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName):getWorkpriceByName(self.works[entry.workId].name)			
			p = p + entry.price;
		end;
	end;
	return p;
end;

function MpManagerBillScreen:onClickTransfer()
	local data = {};
	data.empf = self.currentAddressFarm;
	data.zweck = string.format(g_i18n:getText("mpManager_Transfer_text22"), g_mpManager.bill:formatId(self.billId));
	data.billId = self.billId;
	data.money = self:calcFullPrice();
	data.copyData = self.copyData;
	g_mpManager:showMpManagerTransferScreen(data, true);
end;

function MpManagerBillScreen:onClickDelete()
	g_mpManager:showCheckDialog(g_i18n:getText("mpManager_Bill_info04"), self.onClickDeleteOk, nil, self) 
end;

function MpManagerBillScreen:onClickDeleteOk()
	g_mpManager.bill:deleteBillById(self.billId);
	g_gui:closeDialogByName("MpManagerBillScreen");
end;