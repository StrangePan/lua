require "common/enum"

MessageType = buildEnum(
  "BUNDLE",
  "CONNECT_INIT",
  "CONNECT_ACK",
  "DISCONNECT",
  "PING",
  "ACK",
  "ACK_REQUEST",
  "ACK_REQUEST_RESET",
  "ENTITY_UPDATE")
