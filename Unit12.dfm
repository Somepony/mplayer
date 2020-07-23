object Form12: TForm12
  Left = 401
  Top = 483
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #1050#1086#1085#1089#1086#1083#1100
  ClientHeight = 431
  ClientWidth = 673
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    673
    431)
  PixelsPerInch = 96
  TextHeight = 14
  object Edit1: TEdit
    Left = 0
    Top = 410
    Width = 673
    Height = 22
    Anchors = [akLeft, akRight, akBottom]
    TabOrder = 0
    OnKeyDown = Edit1KeyDown
    OnKeyPress = Edit1KeyPress
  end
  object Memo1: TRichEdit
    Left = 0
    Top = 0
    Width = 673
    Height = 409
    Anchors = [akLeft, akTop, akRight, akBottom]
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Lucida Console'
    Font.Style = []
    HideSelection = False
    ParentFont = False
    ReadOnly = True
    ScrollBars = ssBoth
    TabOrder = 1
    WantTabs = True
    WordWrap = False
    Zoom = 100
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 65512
    Top = 65512
  end
  object HTTPSrv: TIdHTTPServer
    Bindings = <>
    DefaultPort = 5000
    Left = 65512
    Top = 65512
  end
  object Timer2: TTimer
    Enabled = False
    OnTimer = Timer2Timer
    Left = 65512
    Top = 65512
  end
  object AE: TApplicationEvents
    OnMessage = AEMessage
    Left = 96
    Top = 160
  end
  object RESTClient1: TRESTClient
    BaseURL = 'https://api.hearthstonejson.com/v1/latest/ruRU/cards.json'
    Params = <>
    HandleRedirects = True
    RaiseExceptionOn500 = False
    SynchronizedEvents = False
    UserAgent = 'mplayer RESTClient/1.0'
    Left = 272
    Top = 136
  end
  object RESTRequest1: TRESTRequest
    Client = RESTClient1
    Params = <>
    Response = RESTResponse1
    OnAfterExecute = RESTRequest1AfterExecute
    SynchronizedEvents = False
    Left = 384
    Top = 136
  end
  object RESTResponse1: TRESTResponse
    Left = 480
    Top = 136
  end
end
