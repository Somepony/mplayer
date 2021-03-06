unit Unit4;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, RzTrkBar, osc_vis;

type
  TForm4 = class(TForm)
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SettingsSave;
    procedure SettingsRead;
    procedure Button1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  SetsReading:Boolean;

implementation
uses Unit1, Unit2, Unit3, Unit9;

{$R *.dfm}

procedure TForm4.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

function WSbyOrd(OrdNum:Integer):TWindowState;
begin
 Result:=wsNormal;
 if OrdNum=0 then Result:=wsNormal
 else if OrdNum=1 then Result:=wsMinimized
 else if OrdNum=2 then Result:=wsMaximized;
end;

function BoolByOrd(OrdNum:Integer):Boolean;
begin
 Result:=False;
 if OrdNum=0 then Result:=False
 else if OrdNum=1 then Result:=True;
end;

function GetRepeatMode:Integer;
begin
 if Form1.N7.Checked then
  Result:=1
 else if Form1.N8.Checked then
  Result:=2
 else
  Result:=0;
end;

procedure SetRepeatMode(Mode:Integer);
begin
 if Mode=1 then
  begin
   Form1.N7.Checked:=True;
   Form1.N8.Checked:=False;
  end
 else if Mode=2 then
  begin
   Form1.N7.Checked:=False;
   Form1.N8.Checked:=True;
  end
 else
  begin
   Form1.N7.Checked:=False;
   Form1.N8.Checked:=False;
  end;
end;

function GetPlaybackMode:Integer;
begin
 Result:=1;
 if Form1.N13.Checked then
  Result:=1
 else if Form1.N14.Checked then
  Result:=2
 else if Form1.N15.Checked then
  Result:=3;
end;

procedure SetPlaybackMode(Mode:Integer);
begin
 if Mode=1 then
  begin
   Form1.N13.Checked:=True;
  end
 else if Mode=2 then
  begin
   Form1.N14.Checked:=True;
  end
 else if Mode=3 then
  begin
   Form1.N15.Checked:=True;
  end;
end;

procedure TForm4.Button1Click(Sender: TObject);
begin
 Form1.ColorDialog1.Color:=OcilloScope.BackColor;
 if Form1.ColorDialog1.Execute then
  OcilloScope.BackColor:=Form1.ColorDialog1.Color;
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
 Form1.ColorDialog1.Color:=OcilloScope.Pen;
 if Form1.ColorDialog1.Execute then
  begin
   OcilloScope.Pen:=Form1.ColorDialog1.Color;
  end;
end;

procedure TForm4.SettingsSave;
var
 Tmp,i:Integer;
begin
 if (SetsReading=False) and (AppClosing=False) then
  begin
   AssignFile(Sets,SetsPath);
   Rewrite(Sets);
   Write(Sets,OcilloScope.BackColor);
   Write(Sets,OcilloScope.Pen);
   Write(Sets,OcilloScope.LineWidth);
   Write(Sets,OcilloScope.Offset);
   Write(Sets,Form2.Width);
   Write(Sets,Form2.Height);
   Tmp:=Ord(Form2.WindowState);
   Write(Sets,Tmp);
   for i:= 0 To 5 Do
    begin
     Tmp:=Form2.ListView1.Columns.Items[i].Width;
     Write(Sets,Tmp);
    end;
   Write(Sets,Form3.BalanceTrackBar.Position);
   Write(Sets,Form3.VolumeTrackBar.Position);
   Write(Sets,Form3.SpeedTrackBar.Position);
   Tmp:=Ord(Form3.CheckBox1.Checked);
   Write(Sets,Tmp);
   Tmp:=GetRepeatMode;
   Write(Sets,Tmp);
   Tmp:=GetPlaybackMode;
   Write(Sets,Tmp);
   Tmp:=Form3.ComboBox1.ItemIndex;
   Write(Sets,Tmp);
   Tmp:=Ord(Form3.CheckBox4.Checked);
   Write(Sets,Tmp);
   Tmp:=Form3.ComboBox2.ItemIndex;
   Write(Sets,Tmp);
   Tmp:=Ord(Form3.CheckBox5.Checked);
   Write(Sets,Tmp);
   Tmp:=Form3.SpinEdit1.Value;
   Write(Sets,Tmp);
   Tmp:=Form3.RzTrackBar3.Position;
   Write(Sets,Tmp);
   Tmp:=Ord(Form3.CheckBox6.Checked);
   Write(Sets,Tmp);
   Write(Sets,SpecMode);
   Tmp:=Form3.RadioGroup1.ItemIndex;
   Write(Sets,Tmp);
   Tmp:=Ord(Form3.CheckBox7.Checked);
   Write(Sets,Tmp);
   CloseFile(Sets);
  end;
end;

procedure TForm4.SettingsRead;
var
 Tmp,i:Integer;
begin
 if FileExists(SetsPath) then
  begin
   SetsReading:=True;
   AssignFile(Sets,SetsPath);
   Reset(Sets);
   Read(Sets,Tmp);
   OcilloScope.BackColor:=Tmp;
   Read(Sets,Tmp);
   OcilloScope.Pen:=Tmp;
   Read(Sets,Tmp);
   Form3.RzTrackbar1.Position:=Tmp;
   Read(Sets,Tmp);
   Form3.RzTrackbar2.Position:=Tmp;
   Read(Sets,Tmp);
   Form2.Width:=Tmp;
   Read(Sets,Tmp);
   Form2.Height:=Tmp;
   Read(Sets,Tmp);
   Form2.WindowState:=WSbyOrd(Tmp);
   for i:= 0 To 5 Do
    begin
     Read(Sets,Tmp);
     Form2.ListView1.Columns.Items[i].Width:=Tmp;
    end;
   Read(Sets,Tmp);
   Form3.BalanceTrackBar.Position:=Tmp;
   Read(Sets,Tmp);
   Form3.VolumeTrackBar.Position:=Tmp;
   Read(Sets,Tmp);
   Form3.SpeedTrackBar.Position:=Tmp;
   Read(Sets,Tmp);
   Form3.CheckBox1.Checked:=BoolByOrd(Tmp);
   Read(Sets,Tmp);
   SetRepeatMode(Tmp);
   Read(Sets,Tmp);
   SetPlaybackMode(Tmp);
   if not EOF(Sets) then
    begin
     Read(Sets,Tmp);
     Form3.ComboBox1.ItemIndex:=Tmp;
     Form3.ChangeDevice(Tmp+1);
    end;
   if not EOF(Sets) then
    begin
     Read(Sets,Tmp);
     Form3.CheckBox4.Checked:=BoolByOrd(Tmp);
     Read(Sets,Tmp);
     Form3.ComboBox2.ItemIndex:=Tmp;
    end;
   if not EOF(Sets) then
    begin
     Read(Sets,Tmp);
     Form3.CheckBox5.Checked:=BoolByOrd(Tmp);
    end;
   if not EOF(Sets) then
    begin
     Read(Sets,Tmp);
     Form3.SpinEdit1.Value:=Tmp;
    end;
   if not EOF(Sets) then
    begin
     Read(Sets,Tmp);
     Form3.RzTrackBar3.Position:=Tmp;
    end;
   if not EOF(Sets) then
    begin
     Read(Sets,Tmp);
     Form3.CheckBox6.Checked:=BoolByOrd(Tmp);
    end
   else Form3.CheckBox6.Checked:=False;
   if not EOF(Sets) then
    begin
     Read(Sets,Tmp);
     Form1.SetSpecMode(Tmp);
    end;
   if not EOF(Sets) then
    begin
     Read(Sets,Tmp);
     Form3.RadioGroup1.ItemIndex:=Tmp;
    end;
   if not EOF(Sets) then
    begin
     Read(Sets,Tmp);
     Form3.CheckBox7.Checked:=BoolByOrd(Tmp);
    end;
   CloseFile(Sets);
   SetsReading:=False;
  end
 else Form3.CheckBox6.Checked:=False;
end;

procedure TForm4.Button1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbRight then
  OcilloScope.BackColor:=Form1.Color;
end;

end.
