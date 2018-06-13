-- 
-- MpManager - Transferscreen
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerTransferScreen = {};

local MpManagerTransferScreen_mt = Class(MpManagerTransferScreen, ScreenElement);

function MpManagerTransferScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerTransferScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    return self;
end;

function MpManagerTransferScreen:onCreate()
	self.gui_transferBackground:setImageFilename(g_mpManager.dir .. "huds/Ueberweisung.dds");
	self.gui_paperLogo:setImageFilename(g_mpManager.dir .. "huds/RechnungLogo.dds");	
end;

function MpManagerTransferScreen:onClose(element)
    MpManagerTransferScreen:superClass().onClose(self);
end

function MpManagerTransferScreen:onOpen()
    MpManagerTransferScreen:superClass().onOpen(self);
	self.date = g_mpManager.moneyStats:getDate(true);
	self.gui_date:setText(self.date);
	self:reset();
end;

function MpManagerTransferScreen:onClickBack()
	g_gui:closeDialogByName("MpManagerTransferScreen");
end;

function MpManagerTransferScreen:onClickDelete()
	g_mpManager:showCheckDialog(g_i18n:getText("mpManager_Transfer_text23"), self.onClickDeleteOk, nil, self) 
end;

function MpManagerTransferScreen:onClickDeleteOk()
	g_mpManager.transfer:deleteTransferById(self.id);
	g_gui:closeDialogByName("MpManagerTransferScreen");
end;

function MpManagerTransferScreen:onClickApply()
	if self.currentZweck ~= "" and self.currentMoney ~= "" and tonumber(self.currentMoney) ~= nil then
		g_mpManager.transfer:addTransfer({id=self.id, empf=self.address[self.currentAddress], zweck=self.currentZweck, 
											zweckAdd=self.currentZweckAdd, money=tonumber(self.currentMoney), 
											sender=g_currentMission.missionInfo.playerName, date=self.date});		
		
		local farm = g_mpManager.utils:getFarmTblFromUsername(g_currentMission.missionInfo.playerName);
		local farm2 = g_mpManager.utils:getFarmTblFromFarmname(self.address[self.currentAddress]);
		
		farm:addMoney(tonumber(self.currentMoney) * -1);
		MoneyStats:addMoneyStatsToFarm(self.date, g_currentMission.missionInfo.playerName, farm, "other", g_i18n:getText("mpManager_Transfer_text20"), farm2:getName(), g_mpManager.transfer:formatId(self.id), tonumber(self.currentMoney) * -1);
				
		farm2:addMoney(tonumber(self.currentMoney));
		MoneyStats:addMoneyStatsToFarm(self.date, "-", farm2, "other", g_i18n:getText("mpManager_Transfer_text21"), farm:getName(), g_mpManager.transfer:formatId(self.id), tonumber(self.currentMoney));
		
		g_gui:closeDialogByName("MpManagerTransferScreen");
		
		if self.billId ~= nil then
			g_mpManager.bill:setState(self.billId, g_mpManager.bill.STATE_PAYED);
		end;		
		
		if self.copyBillData ~= nil then
			g_gui.guis["MpManagerBillScreen"].target:setData(self.copyBillData);
		end;
	end;
end;

function MpManagerTransferScreen:reset()
	self.gui_button_apply:setVisible(true);
	self.gui_button_delete:setVisible(false);
	self.address = {}
	for _, farm in pairs(g_mpManager.farm:getFarms()) do	
		table.insert(self.address, farm:getName());
	end;	
	self.gui_SelectionEmpf:setTexts(self.address, true);
	self.gui_empf:setText(string.format("%s (%s)", g_mpManager.utils:getFarmTblFromFarmname(self.address[1]):getLeader(), self.address[1]));
	self.gui_input_zweck:setText("");
	self.gui_input_zweckAdd:setText("");
	self.gui_input_money:setText("");
	self.gui_ver1:setText("");
	self.gui_ver2:setText("");
	self.gui_money:setText("");
	
	self.currentZweck = "";
	self.currentZweckAdd = "";
	self.currentMoney = "";
	self.currentAddress = 1;
	self.billId = nil;
	
	self.gui_seperator:setVisible(true);
	self.gui_date:setText(self.date);	
	self.gui_unterschrift:setText(string.format("%s %s",g_currentMission.missionInfo.playerName, g_mpManager.utils:getFarmFromUsername(g_currentMission.missionInfo.playerName)));	
end;

function MpManagerTransferScreen:update(dt)
    MpManagerTransferScreen:superClass().update(self, dt);	
end

function MpManagerTransferScreen:setData(data, createNewTransfer)
    if data ~= nil and not createNewTransfer then
		self.gui_ver1:setText(data.zweck);
		self.gui_ver2:setText(data.zweckAdd);
		self.gui_money:setText(g_i18n:formatMoney(data.money,0,true));
		self.gui_empf:setText(string.format("%s (%s)", g_mpManager.utils:getFarmTblFromFarmname(data.empf):getLeader(), data.empf));
		self.gui_rightSide_createTransfer:setVisible(false);
		self.gui_button_apply:setVisible(false);
		self.gui_button_delete:setVisible(true);
		self.gui_seperator:setVisible(false);
		self.id = data.id;
	elseif data ~= nil and createNewTransfer then
		self.gui_ver1:setText(data.zweck);
		self.gui_empf:setText(string.format("%s (%s)", g_mpManager.utils:getFarmTblFromFarmname(data.empf):getLeader(), data.empf));
		self.gui_money:setText(g_i18n:formatMoney(data.money,0,true));
		self.gui_input_zweck:setText(data.zweck);
		self.gui_input_money:setText(string.format("%.d",data.money));
		self.billId = data.billId;
		self.currentZweck = data.zweck;
		self.currentMoney = tostring(data.money);
		self.copyBillData = data.copyData;
		
		for i, farm in pairs(g_mpManager.farm:getFarms()) do	
			if farm:getName() == data.empf then
				self.currentAddress = i;
				self.gui_SelectionEmpf:setState(self.currentAddress);
			end;
		end;	
		self.id = g_mpManager.transfer:getNextId();	
	else
		self.id = g_mpManager.transfer:getNextId();	
	end;		
end

function MpManagerTransferScreen:onClickEmpChange(state)
	self.currentAddress = state;
	self.gui_empf:setText(string.format("%s (%s)", g_mpManager.utils:getFarmTblFromFarmname(self.address[state]):getLeader(), self.address[state]));
end

function MpManagerTransferScreen:onTextChanged_zweck()
	self.gui_ver1:setText(self.gui_input_zweck.text);
	self.currentZweck = self.gui_input_zweck.text;
end

function MpManagerTransferScreen:onTextChanged_zweckAdd()
	self.gui_ver2:setText(self.gui_input_zweckAdd.text);
	self.currentZweckAdd = self.gui_input_zweckAdd.text;
end

function MpManagerTransferScreen:onTextChanged_zweckMoney()
	if tonumber(self.gui_input_money.text) ~= nil then
		self.gui_money:setText(g_i18n:formatMoney(self.gui_input_money.text,0,true));
		self.currentMoney = self.gui_input_money.text;
	end;
end