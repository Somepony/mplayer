unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RzTrkBar, StdCtrls, BASS, RzLstBox, RzChkLst, JvExControls,
  JvAnimatedImage, JvGIFCtrl, ExtCtrls, RzButton, RzRadChk, RzTabs,
  JvExExtCtrls, JvExtComponent, JvItemsPanel, osc_vis, Spin, IdSSLOpenSSL, MMsystem, MMDevApi,
  acPNG;

type
  TEID=(eChorus,eCompressor,eDistortion,eEcho,eFlanger,eGargle,eParamEQ);

  TForm3 = class(TForm)
    Label6: TLabel;
    Label7: TLabel;
    VolumeTrackBar: TRzTrackBar;
    BalanceTrackBar: TRzTrackBar;
    Label1: TLabel;
    SpeedTrackBar: TRzTrackBar;
    RD: TJvGIFAnimator;
    Timer1: TTimer;
    CheckBox1: TRzCheckBox;
    ComboBox1: TComboBox;
    Label2: TLabel;
    RzPageControl1: TRzPageControl;
    JvItemsPanel1: TJvItemsPanel;
    TabSheet1: TRzTabSheet;
    TabSheet2: TRzTabSheet;
    TabSheet3: TRzTabSheet;
    Shape1: TShape;
    Shape2: TShape;
    GroupBox1: TGroupBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    TabSheet4: TRzTabSheet;
    GroupBox2: TGroupBox;
    CheckBox4: TCheckBox;
    ComboBox2: TComboBox;
    Label3: TLabel;
    Label4: TLabel;
    CheckBox5: TCheckBox;
    Label5: TLabel;
    TabSheet5: TRzTabSheet;
    Button1: TButton;
    Button2: TButton;
    Label8: TLabel;
    RzTrackBar1: TRzTrackBar;
    Label9: TLabel;
    RzTrackBar2: TRzTrackBar;
    TabSheet6: TRzTabSheet;
    Label10: TLabel;
    Label11: TLabel;
    SpinEdit1: TSpinEdit;
    Button3: TButton;
    Label12: TLabel;
    Label13: TLabel;
    RzTrackBar3: TRzTrackBar;
    CheckBox6: TCheckBox;
    Memo1: TMemo;
    RadioGroup1: TRadioGroup;
    ComboBox3: TComboBox;
    LF: TJvGIFAnimator;
    Image1: TImage;
    CheckBox7: TCheckBox;
    TabSheet7: TRzTabSheet;
    RzPageControl2: TRzPageControl;
    JvItemsPanel2: TJvItemsPanel;
    TabSheet8: TRzTabSheet;
    Shape3: TShape;
    RzTrackBar4: TRzTrackBar;
    Label14: TLabel;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    RzTrackBar5: TRzTrackBar;
    Label15: TLabel;
    Label16: TLabel;
    RzTrackBar6: TRzTrackBar;
    Label17: TLabel;
    RzTrackBar7: TRzTrackBar;
    ScrollBar1: TScrollBar;
    RzTrackBar8: TRzTrackBar;
    Label18: TLabel;
    Label19: TLabel;
    TabSheet9: TRzTabSheet;
    TabSheet10: TRzTabSheet;
    TabSheet11: TRzTabSheet;
    TabSheet12: TRzTabSheet;
    TabSheet13: TRzTabSheet;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    RzTrackBar9: TRzTrackBar;
    procedure ReinitCurrentSong;
    procedure ChangeDevice(ID:Integer;NoErrLog:Boolean=False);
    procedure GetDevices;
    procedure Show; overload;
    procedure SetVolume(Level:Cardinal);
    procedure SetBalance(Balance:Integer);
    procedure SetSpeed(Speed:Integer);
    procedure FX_Reverb(Applied:Boolean);
    procedure AddEffect(EID:TEID;Update:Boolean=False);
    procedure RemoveEffect(EID:TEID);
    procedure ApplyAllSettings;
    procedure BalanceTracge(Sender: TObject);
    procedure VolumeTrackBarChange(Sender: TObject);
    procedure SpeedTrackBarChange(Sender: TObject);
    procedure UpdateScrolledPages;
    procedure CheckBox1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure RDClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    function CalcNewCursorPosX(SpeedTrackPos:Integer):Integer;
    procedure JvItemsPanel1ItemClick(Sender: TObject; ItemIndex: Integer);
    procedure CheckBox4Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Button2Click(Sender: TObject);
    procedure RzTrackBar1Change(Sender: TObject);
    procedure RzTrackBar2Change(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure RzTrackBar3Change(Sender: TObject);
    procedure CheckBox6Click(Sender: TObject);
    procedure RadioGroup1Click(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure LFClick(Sender: TObject);
    procedure JvItemsPanel2ItemClick(Sender: TObject; ItemIndex: Integer);
    procedure TBMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ScrollBar1Change(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure RzTrackBar4Change(Sender: TObject);
    procedure RzTrackBar5Change(Sender: TObject);
    procedure RzTrackBar6Change(Sender: TObject);
    procedure RzTrackBar7Change(Sender: TObject);
    procedure RzTrackBar8Change(Sender: TObject);
    procedure TBVertMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckBox9Click(Sender: TObject);
    procedure RzTrackBar9Change(Sender: TObject);
  private
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  FX_ReverbV:HFX;
  ChannelEffects:array[Low(TEID)..High(TEID)] of HFX;

implementation
uses Unit1, Unit2, Unit4, Unit16;

{$R *.dfm}

procedure TForm3.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

function FPSLimitToSeconds(FPS:Word):Word;
begin
 if FPS=0 then Result:=0
 else Result:=Round(1000/FPS);
end;

procedure TForm3.ReinitCurrentSong;
var
 pos:Int64;
 songstage:Integer;
begin
 songstage:=BASS_ChannelIsActive(MediaFile);
 pos:=BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE);
 if pos>-1 then
  begin
   Form2.ListView1.ItemIndex:=CurSongNum;
   Form2.PlaySelectedSong;
   BASS_ChannelSetPosition(MediaFile,pos,BASS_POS_BYTE);
   if songstage=BASS_ACTIVE_PAUSED then
    Form1.PausePlay
   else if songstage=BASS_ACTIVE_STOPPED then
    Form1.StopPlaying;
  end;
end;

procedure TForm3.ChangeDevice(ID:Integer;NoErrLog:Boolean=False);
var
 ErrorCode:Integer;
begin
 if not BASS_ChannelSetDevice(MediaFile,ID) then
  begin
   ErrorCode:=BASS_ErrorGetCode;
   if ErrorCode=BASS_ERROR_INIT then
    begin
     BASS_Init(ID,44100,0,0,nil);
     BASS_ChannelSetDevice(MediaFile,ID);
    end;
  end;
 if not NoErrLog then Form1.AddErrorLog('Устройство воспроизведения изменено: ' + IntToStr(ID));
end;

procedure TForm3.GetDevices;
var
 count:Integer;
 info:BASS_DEVICEINFO;
begin
 ComboBox1.Clear;
 count:=1;
 ErrorLog.Add('-----Устройства воспроизведения-----');
 while BASS_GetDeviceInfo(count,info) do
  begin
   ComboBox1.Items.Add(info.name);
   ErrorLog.Add(' ' + IntToStr(count) + ': ' + info.name + ' / ' + info.driver);
   count:=count+1;
  end;
 ErrorLog.Add('Выбранное устройство: ' + IntToStr(BASS_GetDevice));
 ErrorLog.Add('');
 ComboBox1.ItemIndex:=BASS_GetDevice-1;
end;

procedure TForm3.Show;
begin
 Timer1.Enabled:=False;
 RD.Animate:=True;
 RD.Left:=Form3.ClientWidth-RD.Width;
 inherited Show;
end;

procedure TForm3.SetVolume(Level:Cardinal);
begin
 BASS_ChannelSetAttribute(MediaFile,BASS_ATTRIB_VOL,Level/1000);
 Form3.VolumeTrackBar.Position:=Level;
 Form1.MVolumeTrackBar.Position:=Level;
end;

procedure TForm3.SetBalance(Balance:Integer);
begin
 BASS_ChannelSetAttribute(MediaFile,BASS_ATTRIB_PAN,Balance/1000);
 BalanceTrackBar.Position:=Balance;
end;

procedure TForm3.SetSpeed(Speed:Integer);
begin
 BASS_ChannelSetAttribute(MediaFile,BASS_ATTRIB_FREQ,Speed);
 SpeedTrackBar.Position:=Speed;
 if (SpeedTrackBar.Position>0) and (cfrc>0) then
  begin
   speedprc:=SpeedTrackBar.Position*100/cfrc;
   Label4.Visible:=True;
   CheckBox5.Visible:=True;
   Label4.Caption:='Скорость: ' + FormatFloat('0.####',speedprc) + '%';
   if CheckBox5.Checked then Form1.ChangeFrcGUI(SpeedTrackBar.Position);
  end
 else
  begin
   Label4.Visible:=False;
   CheckBox5.Visible:=False;
   Form1.ChangeFrcGUI(cfrc);
  end;
end;

procedure TForm3.FX_Reverb(Applied:Boolean);
begin
 if Applied then
  FX_ReverbV:=BASS_ChannelSetFX(MediaFile,BASS_FX_DX8_REVERB,1)
 else
  BASS_ChannelRemoveFX(MediaFile,FX_ReverbV);
end;

function BuildChorusStruct:BASS_DX8_CHORUS;
begin
 Result.fWetDryMix:=Form3.RzTrackBar4.Position;
 Result.fDepth:=Form3.RzTrackBar5.Position;
 Result.fFeedback:=Form3.RzTrackBar6.Position;
 Result.fFrequency:=Form3.RzTrackBar7.Position/10;
 Result.fDelay:=Form3.RzTrackBar7.Position;
end;

function BuildCompStruct:BASS_DX8_COMPRESSOR;
begin
 Result.fGain:=Form3.RzTrackBar9.Position;
 Result.fAttack:=10;
 Result.fRelease:=200;
 Result.fThreshold:=-20;
 Result.fRatio:=3;
 Result.fPredelay:=4;
end;

procedure TForm3.AddEffect(EID:TEID;Update:Boolean=False);
var
 ChorusStruct:BASS_DX8_CHORUS;
 CompStruct:BASS_DX8_COMPRESSOR;
begin
 case EID of
  eChorus:
   if CheckBox8.Checked then
   begin
    if not Update then ChannelEffects[EID]:=BASS_ChannelSetFX(MediaFile,BASS_FX_DX8_CHORUS,2);
    ChorusStruct:=BuildChorusStruct;
    BASS_FXSetParameters(ChannelEffects[EID],@ChorusStruct);
   end;
  eCompressor:
   if CheckBox9.Checked then
   begin
    if not Update then ChannelEffects[EID]:=BASS_ChannelSetFX(MediaFile,BASS_FX_DX8_COMPRESSOR,3);
    CompStruct:=BuildCompStruct;
    BASS_FXSetParameters(ChannelEffects[EID],@CompStruct);
   end;
  eDistortion: ;
  eEcho: ;
  eFlanger: ;
  eGargle: ;
 end;
end;

procedure TForm3.RemoveEffect(EID:TEID);
begin
 case EID of
  eChorus:
   BASS_ChannelRemoveFX(MediaFile,ChannelEffects[EID]);
  eCompressor:
   BASS_ChannelRemoveFX(MediaFile,ChannelEffects[EID]);
  eDistortion: ;
  eEcho: ;
  eFlanger: ;
  eGargle: ;
 end;
end;

procedure TForm3.ApplyAllSettings;
var
 EID:TEID;
begin
 SetVolume(VolumeTrackBar.Position);
 SetBalance(BalanceTrackBar.Position);
 SpeedTrackBar.OnChange(Self);
 FX_Reverb(CheckBox1.Checked);
 for EID:= Low(TEID) to High(TEID) do
  AddEffect(EID);
end;

procedure TForm3.BalanceTracge(Sender: TObject);
begin
 SetBalance(BalanceTrackBar.Position);
 Label6.Caption:='Баланс: ' + IntToStr(BalanceTrackBar.Position);
end;

procedure TForm3.VolumeTrackBarChange(Sender: TObject);
begin
 SetVolume(VolumeTrackBar.Position);
 Label7.Caption:='Громкость: ' + FloatToStr(VolumeTrackBar.Position/10) + '%';
end;

procedure TForm3.SpeedTrackBarChange(Sender: TObject);
begin
 SetSpeed(SpeedTrackBar.Position);
end;

procedure TForm3.UpdateScrolledPages;
begin
 ScrollBar1Change(ScrollBar1);
end;

procedure TForm3.CheckBox1Click(Sender: TObject);
begin
 FX_Reverb(CheckBox1.Checked);
end;

procedure TForm3.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 RD.Animate:=False;
end;

procedure TForm3.RDClick(Sender: TObject);
begin
 Timer1.Enabled:=True;
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
 RD.Left:=RD.Left-1;
 if RD.Left<-50 then
  begin
   RD.Animate:=False;
   Timer1.Enabled:=False;
  end;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
 GetDevices;
 UpdateScrolledPages;
end;

procedure TForm3.ComboBox1Change(Sender: TObject);
begin
 ChangeDevice(ComboBox1.ItemIndex+1);
end;

function TForm3.CalcNewCursorPosX(SpeedTrackPos:Integer):Integer;
begin
 Result:=Form3.Left+Round(SpeedTrackPos/SpeedTrackBar.Max*165)+25;
end;

procedure TForm3.JvItemsPanel1ItemClick(Sender: TObject;
  ItemIndex: Integer);
begin
 RzPageControl1.TabIndex:=ItemIndex;
end;

procedure TForm3.CheckBox4Click(Sender: TObject);
begin
 if CheckBox4.Checked then
  begin
   Form1.Button3.Caption:='<<< [F9]';
   Form1.Button2.Caption:='Pause/Play [F10]';
   Form1.Button1.Caption:='Стоп [F11]';
   Form1.Button4.Caption:='>>> [F12]';
  end
 else
  begin
   Form1.Button3.Caption:='<<<';
   Form1.Button2.Caption:='Pause/Play';
   Form1.Button1.Caption:='Стоп';
   Form1.Button4.Caption:='>>>';
  end;
end;

procedure TForm3.CheckBox5Click(Sender: TObject);
begin
 if CheckBox5.Checked then Form1.ChangeFrcGUI(SpeedTrackBar.Position)
 else Form1.ChangeFrcGUI(cfrc);
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
 Form1.ColorDialog1.Color:=OcilloScope.BackColor;
 if Form1.ColorDialog1.Execute then
  OcilloScope.BackColor:=Form1.ColorDialog1.Color;
end;

procedure TForm3.Button1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbRight then
  OcilloScope.BackColor:=Form1.Color;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
 Form1.ColorDialog1.Color:=OcilloScope.Pen;
 if Form1.ColorDialog1.Execute then
  begin
   OcilloScope.Pen:=Form1.ColorDialog1.Color;
  end;
end;

procedure TForm3.RzTrackBar1Change(Sender: TObject);
begin
 OcilloScope.LineWidth:=RzTrackbar1.Position;
 Label8.Caption:='Толщина линии: ' + IntToStr(RzTrackbar1.Position);
end;

procedure TForm3.RzTrackBar2Change(Sender: TObject);
begin
 OcilloScope.Offset:=RzTrackBar2.Position;
 Label9.Caption:='Чувствительность: ' + IntToStr(RzTrackbar2.Position);
end;

procedure TForm3.Button3Click(Sender: TObject);
begin
 Form16.DeleteUnnecessaryRecords;
end;

procedure TForm3.RzTrackBar3Change(Sender: TObject);
begin
 Label13.Caption:='Ограничение FPS осциллоскопа: ' + IntToStr(RzTrackBar3.Position);
 OcilloFPSLimit:=FPSLimitToSeconds(RzTrackBar3.Position);
end;

procedure TForm3.CheckBox6Click(Sender: TObject);
begin
 if CheckBox6.Checked then
  begin
   RzTrackBar3.Max:=1000;
   RzTrackBar3.TickStep:=100;
  end
 else
  begin
   RzTrackBar3.Max:=60;
   RzTrackBar3.TickStep:=10;
  end;
 Memo1.Visible:=CheckBox6.Checked;
end;

procedure TForm3.RadioGroup1Click(Sender: TObject);
begin
 {case RadioGroup1.ItemIndex of
  0: Form1.IdSSLIOHandlerSocket1.SSLOptions.Method:=sslvSSLv2;
  1: Form1.IdSSLIOHandlerSocket1.SSLOptions.Method:=sslvSSLv23;
  2: Form1.IdSSLIOHandlerSocket1.SSLOptions.Method:=sslvSSLv3;
  3: Form1.IdSSLIOHandlerSocket1.SSLOptions.Method:=sslvTLSv1;
  else Form1.IdSSLIOHandlerSocket1.SSLOptions.Method:=sslvSSLv23;
 end;}
end;

procedure TForm3.ComboBox3Change(Sender: TObject);
begin
 Form1.SetSpecMode(ComboBox3.ItemIndex);
end;

procedure TForm3.LFClick(Sender: TObject);
begin
 Image1.Visible:=True;
end;

procedure TForm3.JvItemsPanel2ItemClick(Sender: TObject;
  ItemIndex: Integer);
begin
 RzPageControl2.TabIndex:=ItemIndex;
end;

procedure TForm3.TBMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbLeft then
  (Sender as TRzTrackBar).Position:=Form1.DoSomeUnicornMagic(X,(Sender as TRzTrackBar).Width,(Sender as TRzTrackBar).Max,(Sender as TRzTrackBar).Min);
end;

procedure TForm3.ScrollBar1Change(Sender: TObject);
var
 modify:Integer;
begin
 if ScrollBar1.Position<=51 then
  begin
   modify:=ScrollBar1.Position*-1*2;
   Label14.Top:=8+modify;
   RzTrackBar4.Top:=24+modify;
   Label15.Top:=56+modify;
   RzTrackBar5.Top:=72+modify;
   Label16.Top:=104+modify;
   RzTrackBar6.Top:=120+modify;
   Label17.Top:=152+modify;
   RzTrackBar7.Top:=168+modify;
   Label18.Top:=200+modify;
   RzTrackBar8.Top:=216+modify;
   RzTrackBar4.Repaint;
   RzTrackBar5.Repaint;
   RzTrackBar6.Repaint;
   RzTrackBar7.Repaint;
   RzTrackBar8.Repaint;
  end
 else
  ScrollBar1.Position:=51;
end;

procedure TForm3.CheckBox8Click(Sender: TObject);
var
 state:Boolean;
begin
 state:=CheckBox8.Checked;
 if state then
  AddEffect(eChorus)
 else
  RemoveEffect(eChorus);
 Label14.Enabled:=state; Label15.Enabled:=state;
 Label16.Enabled:=state; Label17.Enabled:=state;
 Label18.Enabled:=state; RzTrackBar4.Enabled:=state;
 RzTrackBar5.Enabled:=state; RzTrackBar6.Enabled:=state;
 RzTrackBar7.Enabled:=state; RzTrackBar8.Enabled:=state;
end;

procedure TForm3.RzTrackBar4Change(Sender: TObject);
begin
 Label14.Caption:='Баланс: ' + IntToStr(RzTrackBar4.Position);
 AddEffect(eChorus,True);
end;

procedure TForm3.RzTrackBar5Change(Sender: TObject);
begin
 Label15.Caption:='Глубина: ' + IntToStr(RzTrackBar5.Position);
 AddEffect(eChorus,True);
end;

procedure TForm3.RzTrackBar6Change(Sender: TObject);
begin
 Label16.Caption:='Feedback: ' + IntToStr(RzTrackBar6.Position);
 AddEffect(eChorus,True);
end;

procedure TForm3.RzTrackBar7Change(Sender: TObject);
begin
 Label17.Caption:='Частота: ' + Format('%g',[RzTrackBar7.Position/10]);
 AddEffect(eChorus,True);
end;

procedure TForm3.RzTrackBar8Change(Sender: TObject);
begin
 Label18.Caption:='Задержка: ' + IntToStr(RzTrackBar8.Position);
 AddEffect(eChorus,True);
end;

procedure TForm3.TBVertMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbLeft then
  (Sender as TRzTrackBar).Position:=Form1.DoSomeStreetMagic(Y,(Sender as TRzTrackBar).Height,(Sender as TRzTrackBar).Max,(Sender as TRzTrackBar).Min);
end;

procedure TForm3.CheckBox9Click(Sender: TObject);
var
 state:Boolean;
begin
 state:=CheckBox9.Checked;
 if state then
  AddEffect(eCompressor)
 else
  RemoveEffect(eCompressor);
 Label25.Enabled:=state;
 RzTrackBar9.Enabled:=state;
end;

procedure TForm3.RzTrackBar9Change(Sender: TObject);
begin
 Label25.Caption:='Gain: ' + IntToStr(RzTrackBar9.Position);
 AddEffect(eCompressor,True);
end;

end.
