object PayamCallerIDService: TPayamCallerIDService
  OldCreateOrder = False
  AllowPause = False
  DisplayName = 'PayamCallerIDService'
  Interactive = True
  OnExecute = ServiceExecute
  Left = 559
  Top = 98
  Height = 443
  Width = 419
  object Timer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerTimer
    Left = 16
    Top = 24
  end
  object LogTimer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = LogTimerTimer
    Left = 64
    Top = 24
  end
  object TCPServer: TIdTCPServer
    Bindings = <>
    CommandHandlers = <>
    DefaultPort = 7676
    Greeting.NumericCode = 0
    MaxConnectionReply.NumericCode = 0
    OnConnect = TCPServerConnect
    OnExecute = TCPServerExecute
    OnDisconnect = TCPServerDisconnect
    ReplyExceptionCode = 0
    ReplyTexts = <>
    ReplyUnknownCommand.NumericCode = 0
    Left = 16
    Top = 88
  end
  object IdAntiFreeze: TIdAntiFreeze
    Left = 64
    Top = 88
  end
  object ThreadManager: TIdThreadMgrDefault
    Left = 120
    Top = 24
  end
  object InsertLogWhenDBDisconnected: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = InsertLogWhenDBDisconnectedTimer
    Left = 176
    Top = 88
  end
  object TestTimer: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = TestTimerTimer
    Left = 72
    Top = 168
  end
  object ConnectionTimer: TTimer
    Enabled = False
    Interval = 60000
    OnTimer = ConnectionTimerTimer
    Left = 168
    Top = 168
  end
end
