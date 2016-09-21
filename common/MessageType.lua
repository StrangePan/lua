require "common/enum"

MessageType = {
  "BUNDLE",
  "CLIENT_CONNECT_INIT",
  "SERVER_CONNECT_ACK"
}

buildEnum(MessageType)
