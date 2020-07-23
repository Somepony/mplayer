unit UnitOSD;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls;

type
  TFormOSD = class(TForm)
    Label1: TLabel;
    Timer1: TTimer;
    procedure ShowOSDText(Text:String);
    procedure ShowOSD(IgnoreSetting:Boolean=False);
    procedure SetOSDText(Text:String);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormOSD: TFormOSD;
  OSDStage:Byte;
  OSDDisplayTime:Cardinal=3000;
  OSDTimeStamp:Int64;

implementation
uses Unit1, Unit3;

{$R *.dfm}

function GTC:Int64;
begin
 if GTC64loaded then
  Result:=GetTickCount64
 else
  Result:=GetTickCount;
end;

procedure TFormOSD.ShowOSDText(Text:String);
begin
 FormOSD.SetOSDText(Text);
 FormOSD.ShowOSD;
end;

procedure TFormOSD.ShowOSD(IgnoreSetting:Boolean=False);
begin
 if (Form3.CheckBox7.Checked) or IgnoreSetting then
  begin
   FormOSD.AlphaBlendValue:=0;
   OSDStage:=1;
   ShowWindow(FormOSD.Handle,SW_SHOWNOACTIVATE);
   FormOSD.Visible:=True;
   Timer1.Enabled:=True;
  end;
end;

procedure TFormOSD.SetOSDText(Text:String);
begin
 Label1.Caption:=Text;
end;

procedure TFormOSD.FormCreate(Sender: TObject);
var
 old:Integer;
begin
 FormOSD.Width:=Screen.Width;
 FormOSD.Left:=0;
 FormOSD.Top:=0;
 if ShowOSDNeeded then
  FormOSD.ShowOSDText(tmpOSDtext);
 old:=GetWindowLongA(FormOSD.Handle,GWL_EXSTYLE);
 SetWindowLongA(FormOSD.Handle,GWL_EXSTYLE,old or WS_EX_TRANSPARENT);
end;

procedure TFormOSD.Timer1Timer(Sender: TObject);
begin
 SetWindowPos(FormOSD.Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
 case OSDStage of
  1:
    if FormOSD.AlphaBlendValue<100 then
     FormOSD.AlphaBlendValue:=FormOSD.AlphaBlendValue+1
    else
     begin
      OSDStage:=2;
      OSDTimeStamp:=GTC;
     end;
  2:
    if GTC-OSDTimeStamp>=OSDDisplayTime then OSDStage:=3;
  3:
    if FormOSD.AlphaBlendValue>0 then
     FormOSD.AlphaBlendValue:=FormOSD.AlphaBlendValue-1
    else
     begin
      FormOSD.Visible:=False;
      Timer1.Enabled:=False;
     end;
 end;
end;

end.
