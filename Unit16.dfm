object Form16: TForm16
  Left = 264
  Top = 212
  HorzScrollBar.Visible = False
  VertScrollBar.Visible = False
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = #1048#1089#1090#1086#1088#1080#1103' '#1074#1086#1089#1087#1088#1086#1080#1079#1074#1077#1076#1077#1085#1080#1103
  ClientHeight = 442
  ClientWidth = 681
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
    681
    442)
  PixelsPerInch = 96
  TextHeight = 14
  object JvItemsPanel1: TJvItemsPanel
    Left = 0
    Top = 0
    Width = 137
    Height = 442
    AutoGrow = False
    AutoSize = False
    HotTrack = False
    OnItemClick = JvItemsPanel1ItemClick
    Anchors = [akLeft, akTop, akBottom]
    TabOrder = 0
    DesignSize = (
      137
      442)
    object Shape1: TShape
      Left = 136
      Top = 0
      Width = 1
      Height = 442
      Anchors = [akLeft, akTop, akBottom]
      Pen.Color = clBtnShadow
    end
    object Button1: TButton
      Left = 8
      Top = 408
      Width = 121
      Height = 25
      Anchors = [akLeft, akBottom]
      Caption = #1054#1095#1080#1089#1090#1080#1090#1100' '#1080#1089#1090#1086#1088#1080#1102
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object RzPageControl1: TRzPageControl
    Left = 137
    Top = -24
    Width = 544
    Height = 466
    Hint = ''
    ActivePage = TabSheet1
    Anchors = [akLeft, akTop, akRight, akBottom]
    ShowCardFrame = False
    ShowFocusRect = False
    ShowFullFrame = False
    ShowShadow = False
    TabIndex = 0
    TabOrder = 1
    FixedDimension = 20
    object TabSheet1: TRzTabSheet
      Caption = 'TabSheet1'
      DesignSize = (
        544
        446)
      object ListView1: TListView
        Left = 0
        Top = 4
        Width = 545
        Height = 443
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #1044#1072#1090#1072
            Width = 125
          end
          item
            Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091
            Width = 400
          end>
        ColumnClick = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = ListView1DblClick
        OnKeyDown = ListView1KeyDown
      end
    end
    object TabSheet2: TRzTabSheet
      Caption = 'TabSheet2'
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        544
        446)
      object ListView2: TListView
        Left = 0
        Top = 4
        Width = 545
        Height = 443
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #1044#1072#1090#1072
            Width = 125
          end
          item
            Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091
            Width = 400
          end>
        ColumnClick = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = ListView1DblClick
        OnKeyDown = ListView1KeyDown
      end
    end
    object TabSheet3: TRzTabSheet
      Caption = 'TabSheet3'
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        544
        446)
      object ListView3: TListView
        Left = 0
        Top = 4
        Width = 545
        Height = 443
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #1044#1072#1090#1072
            Width = 125
          end
          item
            Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091
            Width = 400
          end>
        ColumnClick = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = ListView1DblClick
        OnKeyDown = ListView1KeyDown
      end
    end
    object TabSheet4: TRzTabSheet
      Caption = 'TabSheet4'
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        544
        446)
      object ListView4: TListView
        Left = 0
        Top = 4
        Width = 545
        Height = 443
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #1044#1072#1090#1072
            Width = 125
          end
          item
            Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091
            Width = 400
          end>
        ColumnClick = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = ListView1DblClick
        OnKeyDown = ListView1KeyDown
      end
    end
    object TabSheet5: TRzTabSheet
      Caption = 'TabSheet5'
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        544
        446)
      object ListView5: TListView
        Left = 0
        Top = 4
        Width = 545
        Height = 443
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #1044#1072#1090#1072
            Width = 125
          end
          item
            Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091
            Width = 400
          end>
        ColumnClick = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = ListView1DblClick
        OnKeyDown = ListView1KeyDown
      end
    end
    object TabSheet6: TRzTabSheet
      Caption = 'TabSheet6'
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        544
        446)
      object ListView6: TListView
        Left = 0
        Top = 4
        Width = 545
        Height = 443
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #1044#1072#1090#1072
            Width = 125
          end
          item
            Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091
            Width = 400
          end>
        ColumnClick = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = ListView1DblClick
        OnKeyDown = ListView1KeyDown
      end
    end
    object TabSheet7: TRzTabSheet
      Caption = 'TabSheet7'
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      DesignSize = (
        544
        446)
      object ListView7: TListView
        Left = 0
        Top = 4
        Width = 545
        Height = 443
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = #1044#1072#1090#1072
            Width = 125
          end
          item
            Caption = #1055#1091#1090#1100' '#1082' '#1092#1072#1081#1083#1091
            Width = 400
          end>
        ColumnClick = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = ListView1DblClick
        OnKeyDown = ListView1KeyDown
      end
    end
  end
end
