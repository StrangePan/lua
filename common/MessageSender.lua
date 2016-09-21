require "common/class"
require "Serializer"

--
-- Class for sending messages to a recipient or multiple recipients
--
MessageSender = buildClass()

function MessageSender:_init(udp)
  self.udp = udp
end

--
-- Sends the supplied message to supplied recipients. These optional parameters
-- are expected to be tables with ['address'] and ['port'] fields.
--
function MessageSender:sendMessage(message, ...)
  local recipients = {...}
  local data = Serializer.serialize(message)
  if data == nil then return end
  
  for _,recipient in ipairs(recipients) do
    if type(recipient) == "table"
      and type(recipient.address) == "string"
      and type(recipient.port) == "number" then
      self.udp:sendto(data, recipient.address, recipient.port)
    end
  end
end
