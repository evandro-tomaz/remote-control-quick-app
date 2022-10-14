
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


function QuickApp:uibuttonOnOnReleased(event)
self:send("",true)
end

function QuickApp:uibuttonOffOnReleased(event)
self:send("",true)
end

function QuickApp:uibuttonchRelease(event)
self:send("",true)
end






