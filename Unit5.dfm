object Form5: TForm5
  Left = 256
  Top = 464
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = #1054#1090#1082#1088#1099#1090#1100' URL'
  ClientHeight = 73
  ClientWidth = 585
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 14
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 23
    Height = 14
    Caption = 'URL:'
  end
  object Edit1: TEdit
    Left = 40
    Top = 8
    Width = 537
    Height = 22
    TabOrder = 0
    Text = 'http://'
  end
  object Button1: TButton
    Left = 360
    Top = 40
    Width = 105
    Height = 25
    Caption = #1054#1090#1082#1088#1099#1090#1100
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 472
    Top = 40
    Width = 105
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 2
  end
end
