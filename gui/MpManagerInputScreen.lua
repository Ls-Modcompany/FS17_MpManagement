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

MpManagerInputScreen = {};
MpManagerInputScreen.INPUTTYPE_TEXT = 1;
MpManagerInputScreen.INPUTTYPE_CHOOSE = 2;

local MpManagerInputScreen_mt = Class(MpManagerInputScreen, ScreenElement);

function MpManagerInputScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerInputScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    return self;
end;

function MpManagerInputScreen:onCreate()	
	self.inputType = MpManagerInputScreen.INPUTTYPE_TEXT;
	self.textInput:setVisible(true);
	self.textTable:setVisible(false);
	self.blockTime = 0;
end;

function MpManagerInputScreen:onClose(element)
    MpManagerInputScreen:superClass().onClose(self);
    self.textInput:setForcePressed(false);
	FocusManager:setFocus(self.okButton);
end

function MpManagerInputScreen:onOpen()
    MpManagerInputScreen:superClass().onOpen(self);
	if self.inputType == MpManagerInputScreen.INPUTTYPE_TEXT then
		FocusManager:setFocus(self.textInput);
        self.textInput:setForcePressed(true);
	else
		FocusManager:setFocus(self.textTable);
	end;	
end

function MpManagerInputScreen:update(dt)
    MpManagerInputScreen:superClass().update(self, dt);
	if self.blockTime > 0 then
		self.blockTime = self.blockTime - 1;
	end;
end

function MpManagerInputScreen:onClickOk()
	if self.blockTime == 0 then
		g_gui:closeDialogByName("MpManagerInputScreen");
		if self.onOk ~= nil then
			if self.inputType == MpManagerInputScreen.INPUTTYPE_TEXT then
				self.onOk(self.target, self.textInput.text, self.args);
				self.textInput:setText("");
			else
				self.onOk(self.target, self.textTable.texts[self.textTable:getState()], self.args);
				self.textTable:setState(1);
			end;
		end;
	end;
end;

function MpManagerInputScreen:onEnterPressed()
    self.textInput:setForcePressed(false);
	self.blockTime = 2;
	FocusManager:setFocus(self.okButton);
end;

function MpManagerInputScreen:onClickBack()
    g_gui:closeDialogByName("MpManagerInputScreen");
	if self.onBack ~= nil then
		self.onBack(self.target);
	end;
end;

function MpManagerInputScreen:setData(header, info, button, inputType, dataTable)
	self.infoHeader:setText(header);
	self.infoText:setText(info);
	self.okButton:setText(button);
	self.inputType = inputType;
	if self.inputType == MpManagerInputScreen.INPUTTYPE_TEXT then
		if dataTable and type(dataTable) == "string" then
			self.textInput:setText(dataTable);
		end;
		self.textInput:setVisible(true);
		self.textTable:setVisible(false);
		FocusManager:setFocus(self.textInput);
        self.textInput:setForcePressed(true);
	else
		self.textTable:setTexts(dataTable);
		self.textInput:setVisible(false);
		self.textTable:setVisible(true);
		FocusManager:setFocus(self.textTable);
        self.textInput:setForcePressed(false);
	end;
end;

function MpManagerInputScreen:setCallback(onOk, target, args)
	self.onOk = onOk;
	self.target = target;
	self.args = args;
end;

function MpManagerInputScreen:setCallbackBack(onBack, target)
	self.onBack = onBack;
	self.target = target;
end;