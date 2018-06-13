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

MpManagerInfoScreen = {};

local MpManagerInfoScreen_mt = Class(MpManagerInfoScreen, ScreenElement);

function MpManagerInfoScreen:new(target, custom_mt)
    if custom_mt == nil then
        custom_mt = MpManagerInfoScreen_mt;
    end;
    local self = ScreenElement:new(target, custom_mt);
    return self;
end;

function MpManagerInfoScreen:onCreate()	
	self.nextWindow = "";
end;

function MpManagerInfoScreen:onClose(element)
    MpManagerInfoScreen:superClass().onClose(self);
end

function MpManagerInfoScreen:onOpen()
    MpManagerInfoScreen:superClass().onOpen(self);
	self.inputDelay = 10;
    FocusManager:setFocus(self.buttonOK)
end

function MpManagerInfoScreen:update(dt)
    MpManagerInfoScreen:superClass().update(self, dt);
	if self.inputDelay > 0 then
		self.inputDelay = self.inputDelay - 1;
	end;
end

function MpManagerInfoScreen:onClickOk()
	if self.inputDelay <= 0 then
		g_gui:closeDialogByName("MpManagerInfoScreen");
		if self.onEnter ~= nil and self.target ~= nil then
			self.onEnter(self.target);
		end;
		self.onEnter = nil;
		self.target = nil;
	end;
end;

function MpManagerInfoScreen:setInfoText(newText)
	if newText ~= nil then
		self.infoText:setText(newText);
	end;
end;

function MpManagerInfoScreen:setCallback(onEnter, target)
	self.onEnter = onEnter;
	self.target = target;
end;