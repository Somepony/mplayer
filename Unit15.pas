unit Unit15;

interface

uses Windows, SysUtils, Classes, Graphics, Forms, Controls, StdCtrls,
  Buttons, ExtCtrls, Messages, Dialogs, acPNG;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Version: TLabel;
    Copyright: TLabel;
    Comments: TLabel;
    OKButton: TButton;
    PonyPic: TImage;
    Label1: TLabel;
    RarePic: TImage;
    NP: TLabel;
    procedure LuckyLaunch;
    procedure FormCreate(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation
uses Unit1, Unit3;

{$R *.dfm}

procedure TAboutBox.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

procedure TAboutBox.LuckyLaunch;
begin
 if Round(Random(90))=0 then
  begin
   PonyPic.Picture:=RarePic.Picture;
   Form3.RD.Image:=Form3.LF.Image;
   Form3.RD.Hint:='Флатти';
   Form3.RD.OnClick:=Form3.LFClick;
   Form1.AddErrorLog('Lucky Launch!!!');
  end;
end;

procedure TAboutBox.FormCreate(Sender: TObject);
begin
 ProductName.Caption:=APP_NAME;
 Version.Caption:=APP_VERSION;
 LuckyLaunch;
 if NON_PUBLIC then
  AboutBox.NP.Visible:=True;
end;

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
 AboutBox.Close;
end;

end.
 
