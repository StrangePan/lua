require "common/enum"

MessageType = {
  "BUNDLE",
  "CONNECT_INIT",
  "CONNECT_ACK",
  "DISCONNECT",
  "PING",
  "ACK",
  "ACK_RESET",
  "ACK_REQUEST"
}

buildEnum(MessageType)
