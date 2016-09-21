require "common/enum"

ConnectionStatus = {
  "DISCONNECTED",
  "CONNECTING",
  "CONNECTED",
  "STALLED"
}

buildEnum(ConnectionStatus)
