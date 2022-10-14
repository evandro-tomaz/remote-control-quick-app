-- Sample that works similar to virtual devices on Home Center 2 
-- Please configure quickapp by filling ip and port variables
-- In added buttons just use self:send(<sting to send>, <waitForResponse>) function.
-- On button clicked QuickApp will connect provided ip send the message. 
-- If waitForResponse parameter is true, it does the following scenario: connect->send message->disconnect
-- If waitForResponse parameter is false, it does the following scenario: connect->send message->wait for response->disconnect

function QuickApp:send(dataToSend, waitForResponse)
    self.sock:close()
    
    self:connect(function()     
        local dataConverted = self:parseData(dataToSend) -- replace string starting with '0x' to hex value
        self.sock:write(dataConverted, {
            success = function()
                if waitForResponse then
                    self:waitForResponseFunction()
                else
                    self.sock:close()
                end
            end,
            error = function(err)
                self.sock:close()
            end
        })
    end)
end

function QuickApp:parseData(str)
    while true do 
        if string.find(str, '0x') then
            i,j = string.find(str, '0x')
            str = string.sub(str, 1, i - 1) .. self:fromhex(string.sub(str, i + 2, j +2)) .. string.sub(str, j + 3)
        else
            return str
        end
    end
end

function QuickApp:fromhex(str)
    return (str:gsub('..', function(cc)
        return string.char(tonumber(cc, 16))
    end))
end

function QuickApp:waitForResponseFunction()
    self.sock:read({
        success = function(data)
            self:debug("response data:", data)
            self.sock:close()
        end,
        error = function()
            self:debug("response error")
            self.sock:close()
        end
    })
end

function QuickApp:connect(successCallback)
    print("connecting:", self.ip, self.port)
    self.sock:connect(self.ip, self.port, {
        success = function()
            self:debug("connected")
            successCallback()
        end,
        error = function(err)
            self.sock:close()
            self:debug("connection error")
        end,
    })
end 

function QuickApp:onInit()
    self:debug("onInit")
    self.ip = self:getVariable("ip")
    self.port = tonumber(self:getVariable("port"))
    self.sock = net.TCPSocket()
end
-- Turn ac On
-- 
function QuickApp:turnOn()
    self:updateProperty("value", true)
    self:send("sendir,1:2,1,39000,1,1,130,381,19,60,19,21,18,21,18,21,18,61,18,20,19,21,18,21,18,21,18,21,18,21,18,21,18,21,18,21,18,21,18,20,19,21,18,21,18,61,18,61,18,21,18,21,18,61,18,21,18,20,19,61,19,21,18,61,19,2000", true) 
    self:updateView("Sitema", "text", "Ar Ligado")
end

--
-- Turn ac Off 
-- 
function QuickApp:turnOff()
    self:updateProperty("value", false)    
    self:send("sendir,1:2,1,39000,1,1,121,380,20,61,18,20,19,21,18,21,18,61,18,20,19,21,18,21,18,61,18,61,18,21,18,21,18,21,18,21,18,21,18,21,18,21,18,21,18,20,19,21,18,21,18,61,18,21,18,61,18,21,18,21,18,21,18,61,18,2000",true) 
    self:updateView("Sitema", "text", "Ar Desligado")
end
-----modo de operacao-----

function QuickApp:uibuttonauto(event)
self:send("sendir,1:2,1,39000,1,1,121,381,20,60,19,21,18,21,18,21,18,61,18,20,19,21,18,21,18,21,18,21,18,21,18,21,18,61,18,21,18,61,19,61,18,21,18,20,19,61,19,20,19,20,19,61,18,21,18,61,19,20,19,20,19,61,18,21,18,2000", true)
self:updateView("Operacao", "text", "Automatico")
end

function QuickApp:uibuttonvent(event)
self:send("sendir,1:2,1,39000,1,1,121,385,19,60,19,22,18,21,18,21,18,61,18,22,18,21,18,21,18,21,18,21,18,21,18,21,19,61,18,21,19,61,18,22,18,21,19,21,19,61,19,61,19,21,18,61,18,21,18,21,18,21,18,21,18,21,18,61,18,2000", true)
self:updateView("Operacao", "text", "Ventilador")
end

function QuickApp:uibuttonfrio(event)
self:send("sendir,1:2,1,39000,1,1,129,381,20,61,19,21,18,21,18,21,18,61,18,21,18,21,18,21,18,20,19,21,18,21,18,21,19,61,18,21,18,20,19,21,18,21,18,21,18,61,18,61,18,21,18,21,18,61,18,21,18,61,18,60,19,21,18,61,18,2000", true)
self:updateView("Operacao", "text", "Modo Frio")
end

function QuickApp:uibuttonquente(event)
self:send("", true)
self:updateView("Operacao", "text", "Modo Quente")

end


------Velocidade-----

function QuickApp:uibuttonalta(event)
self:send("", true)
self:updateView("Velocidade", "text", "Vel Alta")
end

function QuickApp:uibuttonmed(event)
self:send("", true)
self:updateView("Velocidade", "text", "Vel Media")
end

function QuickApp:uibuttonlow(event)
self:send("", true)
self:updateView("Velocidade", "text", "Vel Baixa")
end

------temperatura----


function QuickApp:sTemp(event)
    local valor = event.values[1]
    print("valor ",valor)
    if valor >= 0 and valor <= 10 then
        self:send("", true)

        self:updateView("temp", "text", "Temp: 18°C")
    elseif valor > 10 and valor <= 20 then
        self:send("", true)

        self:updateView("temp", "text", "Temp: 19°C") 
    elseif valor > 20 and valor <= 30 then
        self:send("", true)

        self:updateView("temp", "text", "Temp: 20°C")
    elseif valor > 30 and valor <= 40 then
        self:send("", true)

        self:updateView("temp", "text", "Temp: 21°C")
    elseif valor > 40 and valor <= 50 then
        self:send("", true)

        self:updateView("temp", "text", "Temp: 22°C")
    elseif valor > 50 and valor <= 60 then
        self:send("", true)

        self:updateView("temp", "text", "Temp: 23°C")
    elseif valor > 60 and valor <= 70 then
        self:send("", true)
        self:updateView("temp", "text", "Temp: 24°C")
    elseif valor > 70 and valor <= 80 then
        self:send("", true)

        self:updateView("temp", "text", "Temp: 25°C")
    elseif valor > 90 and valor <= 100 then
        self:send("", true)
        
        self:updateView("temp", "text", "Temp: 26°C")
    else
        print("Erro!")
    end
end