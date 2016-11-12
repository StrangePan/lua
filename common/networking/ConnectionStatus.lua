require "common/enum"

ConnectionStatus = buildEnum(
  "DISCONNECTED",
  "CONNECTING",
  "CONNECTED",
  "STALLED")
