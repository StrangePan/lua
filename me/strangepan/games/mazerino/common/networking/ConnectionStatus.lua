require "strangepan.util.enum"

ConnectionStatus = buildEnum(
  "DISCONNECTED",
  "CONNECTING",
  "CONNECTED",
  "STALLED")
