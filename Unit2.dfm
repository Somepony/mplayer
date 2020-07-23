object Form2: TForm2
  Left = 327
  Top = 129
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #1055#1083#1077#1081#1083#1080#1089#1090
  ClientHeight = 253
  ClientWidth = 497
  Color = clBtnFace
  Constraints.MinHeight = 311
  Constraints.MinWidth = 513
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    497
    253)
  PixelsPerInch = 96
  TextHeight = 14
  object Label1: TLabel
    Left = 8
    Top = 204
    Width = 183
    Height = 14
    Anchors = [akLeft, akBottom]
    Caption = #1054#1073#1097#1072#1103' '#1087#1088#1086#1076#1086#1083#1078#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100': 0:00:00'
  end
  object Button1: TButton
    Left = 8
    Top = 220
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 104
    Top = 220
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1044#1086#1073#1072#1074#1080#1090#1100' URL'
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 200
    Top = 220
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1054#1095#1080#1089#1090#1080#1090#1100
    TabOrder = 2
    OnClick = Button3Click
  end
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 497
    Height = 198
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'N'
        Width = 30
      end
      item
        Caption = #1048#1089#1087#1086#1083#1085#1080#1090#1077#1083#1100
        Width = 90
      end
      item
        Caption = #1053#1072#1079#1074#1072#1085#1080#1077
        Width = 80
      end
      item
        Caption = #1040#1083#1100#1073#1086#1084
        Width = 70
      end
      item
        Caption = #1055#1088#1086#1076#1086#1083#1078#1080#1090#1077#1083#1100#1085#1086#1089#1090#1100
        Width = 120
      end
      item
        Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091
        Width = 87
      end>
    ColumnClick = False
    HideSelection = False
    HotTrackStyles = [htUnderlineCold, htUnderlineHot]
    ReadOnly = True
    RowSelect = True
    TabOrder = 4
    ViewStyle = vsReport
    OnDblClick = ListView1DblClick
    OnKeyDown = ListView1KeyDown
    OnKeyPress = ListView1KeyPress
    OnSelectItem = ListView1SelectItem
  end
  object Button4: TButton
    Left = 296
    Top = 220
    Width = 89
    Height = 25
    Anchors = [akLeft, akBottom]
    Caption = #1057#1082#1072#1095#1072#1090#1100
    Enabled = False
    TabOrder = 3
    Visible = False
    OnClick = Button4Click
  end
  object MainMenu1: TMainMenu
    Left = 65512
    Top = 65512
    object N1: TMenuItem
      Caption = #1052#1077#1085#1102
      object N2: TMenuItem
        Caption = #1054#1090#1082#1088#1099#1090#1100' '#1087#1083#1077#1081#1083#1080#1089#1090
        Default = True
        OnClick = N2Click
      end
      object N3: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1087#1083#1077#1081#1083#1080#1089#1090
        OnClick = N3Click
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object N5: TMenuItem
        Caption = #1054#1073#1085#1086#1074#1080#1090#1100' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1102
        OnClick = N5Click
      end
      object N6: TMenuItem
        Caption = #1059#1073#1088#1072#1090#1100' '#1085#1077#1089#1091#1097#1077#1089#1090#1074#1091#1102#1097#1080#1077' '#1092#1072#1081#1083#1099
        OnClick = N6Click
      end
    end
    object N7: TMenuItem
      Caption = #1055#1086#1080#1089#1082
      OnClick = N8Click
    end
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = '*.m3u'
    Filter = #1055#1083#1077#1081#1083#1080#1089#1090'|*.m3u'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 65512
    Top = 65512
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = '*.m3u'
    Filter = #1055#1083#1077#1081#1083#1080#1089#1090'|*.m3u;*.m3u8;*.cue'
    Left = 65512
    Top = 65512
  end
  object FD1: TFindDialog
    Options = [frDown, frHideMatchCase, frHideWholeWord]
    OnFind = FD1Find
    Left = 65512
    Top = 65512
  end
  object SD2: TSaveDialog
    DefaultExt = 'mp3'
    Filter = 'MP3|*.mp3'
    Left = 65512
    Top = 144
  end
end
