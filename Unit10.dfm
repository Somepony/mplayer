object Form10: TForm10
  Left = 271
  Top = 387
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1047#1072#1087#1080#1089#1100' '#1079#1074#1091#1082#1072
  ClientHeight = 257
  ClientWidth = 441
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 14
  object Label1: TLabel
    Left = 8
    Top = 48
    Width = 36
    Height = 14
    Caption = '0:00:00'
  end
  object Label2: TLabel
    Left = 8
    Top = 64
    Width = 9
    Height = 14
    Caption = 'L:'
  end
  object Label3: TLabel
    Left = 8
    Top = 88
    Width = 10
    Height = 14
    Caption = 'R:'
  end
  object Label4: TLabel
    Left = 8
    Top = 112
    Width = 102
    Height = 14
    Caption = #1059#1089#1090#1088#1086#1081#1089#1090#1074#1086' '#1079#1072#1087#1080#1089#1080':'
  end
  object Button1: TButton
    Left = 8
    Top = 8
    Width = 137
    Height = 33
    Caption = #1053#1072#1095#1072#1090#1100' '#1079#1072#1087#1080#1089#1100
    TabOrder = 0
    OnClick = Button2Click
  end
  object Button2: TButton
    Left = 152
    Top = 8
    Width = 137
    Height = 33
    Caption = #1042#1086#1089#1087#1088#1086#1080#1079#1074#1077#1089#1090#1080
    Enabled = False
    TabOrder = 1
    OnClick = Button3Click
  end
  object Button3: TButton
    Left = 296
    Top = 8
    Width = 137
    Height = 33
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    Enabled = False
    TabOrder = 2
    OnClick = Button4Click
  end
  object ComboBox1: TComboBox
    Left = 8
    Top = 128
    Width = 297
    Height = 22
    Style = csDropDownList
    TabOrder = 3
    OnChange = ComboBox1Change
  end
  object IVolumeTrackBar: TRzTrackBar
    Left = 305
    Top = 128
    Width = 25
    Height = 121
    Max = 1000
    Orientation = orVertical
    Position = 1000
    ShowTicks = False
    ThumbStyle = tsFlat
    TrackOffset = 10
    TrackWidth = 6
    Transparent = True
    OnChange = IVolumeTrackBarChange
    TabOrder = 4
    OnMouseDown = IVolumeTrackBarMouseDown
  end
  object CheckListBox1: TRzCheckList
    Left = 8
    Top = 152
    Width = 297
    Height = 97
    OnChange = CheckListBox1Change
    ItemHeight = 17
    TabOrder = 5
    OnClick = CheckListBox1Click
  end
  object SD: TSaveDialog
    DefaultExt = '*.wav'
    Filter = 'WAVE|*.wav; *.wave'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 65512
    Top = 65520
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 250
    OnTimer = Timer1Timer
    Left = 65520
    Top = 65512
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer2Timer
    Left = 65512
    Top = 65512
  end
end
