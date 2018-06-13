-- 
-- MpManager - MpManagerMoneyAssignmentScreen
-- 
-- @Interface: 1.5.3.1 b1841
-- @Author: LS-Modcompany/kevink98 
-- @Date: 03.06.2018
-- @Version: 1.0.0.0
-- 
-- @Support: LS-Modcompany
-- 

MpManagerMoneyAssignmentScreen = {};

local MpManagerMoneyAssignmentScreen_mt = Class(MpManagerMoneyAssignmentScreen, ScreenElement);

function MpManagerMoneyAssignmentScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerMoneyAssignmentScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    return self;
end;

function MpManagerMoneyAssignmentScreen:onCreate()	
end;

function MpManagerMoneyAssignmentScreen:onClose(element)
    MpManagerMoneyAssignmentScreen:superClass().onClose(self);
	FocusManager:setFocus(self.okButton);
end

function MpManagerMoneyAssignmentScreen:onOpen()
    MpManagerMoneyAssignmentScreen:superClass().onOpen(self);
	FocusManager:setFocus(self.textTable);
end

function MpManagerMoneyAssignmentScreen:update(dt)
    MpManagerMoneyAssignmentScreen:superClass().update(self, dt);
end

function MpManagerMoneyAssignmentScreen:onClickYes()
	g_gui:closeDialogByName("MpManagerMoneyAssignmentScreen");
	if self.onOk ~= nil then
		self.onOk(self.target, self.textTable.texts[self.textTable:getState()], self.args);
		self.textTable:setState(1);
	end;
end;

function MpManagerMoneyAssignmentScreen:onClickNo()
    g_gui:closeDialogByName("MpManagerMoneyAssignmentScreen");
	if self.onBack ~= nil then
		self.onBack(self.target, self.textTable.texts[self.textTable:getState()]);
	end;
end;

function MpManagerMoneyAssignmentScreen:setData(header, info, dataTable, state)
	self.infoHeader:setText(header);
	self.infoText:setText(info);
	self.textTable:setTexts(dataTable);
	self.textTable:setState(state);
	FocusManager:setFocus(self.okButton);
end;

function MpManagerMoneyAssignmentScreen:setCallback(onOk, target, args)
	self.onOk = onOk;
	self.target = target;
	self.args = args;
end;

function MpManagerMoneyAssignmentScreen:setCallbackBack(onBack, target)
	self.onBack = onBack;
	self.target = target;
end;