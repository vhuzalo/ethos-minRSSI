--  Minimum RSSI value widget for ETHOS v1.0
--
--  License GPLv3: http://www.gnu.org/licenses/gpl-3.0.html                                                
--                                                                                                         
--  This program is free software; you can redistribute it and/or modify                                   
--  it under the terms of the GNU General Public License version 3 as                                      
--  published by the Free Software Foundation.                                                             
--                                                                                                         
--                                                                                                         
--  By Vagner Huzalo 


local RX_STATUS_OFF = 0
local RX_STATUS_ON = 1
local translations = {en="RSSI -"}
local rxStatus = RX_STATUS_OFF

local function name(widget)
    local locale = system.getLocale()
    return translations[locale] or translations["en"]
end

local function create()
    return {
		source=nil, 
		value=100
	}
end

local function paint(widget) 	
	if widget.source == nil then
        return
    end
	
    local w, h = lcd.getWindowSize()
	
    local text_w, text_h = lcd.getTextSize("")	
	if rxStatus == RX_STATUS_ON then
		lcd.color(WHITE)
	else
		lcd.color(RED)
	end

	lcd.font(FONT_L)
	lcd.drawText(w / 2, (h - text_h)/ 2, widget.value.. " db", CENTERED)
	
end

local function wakeup(widget)
    if widget.source then
        local newValue = widget.source:value()
		
		if rxStatus == RX_STATUS_OFF and newValue > 97 then
			rxStatus = RX_STATUS_ON
			lcd.invalidate()
		end
		
		if rxStatus == RX_STATUS_ON and newValue == 0 then
			rxStatus = RX_STATUS_OFF
			lcd.invalidate()
		end				
		
        if widget.value ~= newValue and newValue <  widget.value and rxStatus == RX_STATUS_ON then
            widget.value = newValue			
            lcd.invalidate()
		end
    end
end

local function configure(widget)
    line = form.addLine("Source")
    form.addSourceField(line, nil, function() return widget.source end, function(value) widget.source = value end)
end

local function read(widget)
    widget.source = storage.read("source")
end

local function write(widget)
    storage.write("source", widget.source)
end

local function init()
    system.registerWidget({key="minRSSI", name=name, create=create, paint=paint, wakeup=wakeup, configure=configure, read=read, write=write})
end

return {init=init}