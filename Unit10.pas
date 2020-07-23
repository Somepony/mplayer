unit Unit10;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, BASS, StdCtrls, ExtCtrls, ComCtrls, CheckLst, RzTrkBar,
  RzLstBox, RzChkLst, BassWASAPI, MMsystem, BASSmix;

type
  TForm10 = class(TForm)
    Button1: TButton;
    SD: TSaveDialog;
    Button2: TButton;
    Button3: TButton;
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Timer2: TTimer;
    Label4: TLabel;
    ComboBox1: TComboBox;
    IVolumeTrackBar: TRzTrackBar;
    CheckListBox1: TRzCheckList;
    procedure GetRecDevices;
    procedure UpdatePBS(LL,RL:Integer);
    procedure UpdatePBS_WASAPI(Level:Single);
    procedure StartRec;
    procedure StopRec;
    procedure SetRecDevice(ID:Integer);
    procedure UpdateInputList;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CheckListBox1Click(Sender: TObject);
    procedure CheckListBox1Change(Sender: TObject; Index: Integer;
      NewState: TCheckBoxState);
    procedure IVolumeTrackBarChange(Sender: TObject);
    procedure IVolumeTrackBarMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  private
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

  WAVHDR = packed record
    riff:array[0..3] of AnsiChar;
    len:DWord;
    cWavFmt:array[0..7] of AnsiChar;
    dwHdrLen:DWord;
    wFormat:Word;
    wNumChannels:Word;
    dwSampleRate:DWord;
    dwBytesPerSec:DWord;
    wBlockAlign:Word;
    wBitsPerSample:Word;
    cData:array[0..3] of AnsiChar;
    dwDataLen:DWord;
  end;

const
  BUFSTEP=200000;

var
  Form10: TForm10;
  HREC,HPLAY:Cardinal;
  WaveHdr:WAVHDR;
  WaveStream:TMemoryStream;
  ErrorCode:Integer;
  Rec:Boolean;
  RecTimer:Extended;
  WAS_Offset:Integer=-1;
  WASAPIMode:Boolean=False;
  WAS_D_IDs:array of Integer;
  instream:HSTREAM=0;
  inmixer:HSTREAM=0;
  loopback:Integer;

implementation
uses Unit1, Unit3, Unit4;

{$R *.dfm}

function IsBitSet(const AValueToCheck,ABitIndex:Integer):Boolean;
begin
 Result:=AValueToCheck and (1 shl ABitIndex)<>0;
end;

procedure TForm10.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

function RecordingCallback(Handle:HRECORD;buffer:Pointer;length:integer;user:Pointer):Boolean; stdcall;
begin
 WaveStream.Write(buffer^,length);
 Result:=True;
end;

function WASAPICallback(buffer:Pointer;length:DWORD;user:Pointer):DWORD; stdcall;
var
 c:Integer;
 temp:array[0..49999] of Byte;
begin
 BASS_StreamPutData(instream,buffer,length);
 c:=BASS_ChannelGetData(inmixer,@temp,SizeOf(temp));
 if c>0 then
  begin
	 WaveStream.Write(temp,c);
   //WaveStream.Write(buffer^,length);
   Result:=1;
	end
 else
  begin
   Form10.StopRec;
   Result:=0;
  end;
end;

procedure TForm10.GetRecDevices;
var
 count:Integer;
 info:BASS_DEVICEINFO;
begin
 ComboBox1.Clear;
 SetLength(WAS_D_IDs,0);
 count:=0;
 while BASS_RecordGetDeviceInfo(count,info) do
  begin
   ComboBox1.Items.Add(info.name);
   count:=count+1;
  end;
 if IsVista then
  begin
   WAS_Offset:=count;
   ComboBox1.Items.Add('System Sound [WASAPI]');
  end;
 ComboBox1.ItemIndex:=BASS_RecordGetDevice;
 UpdateInputList;
end;

procedure TForm10.UpdatePBS(LL,RL:Integer);
begin
 LL:=Round(LL*409/32768)+24;
 RL:=Round(RL*409/32768)+24;
 Form10.Canvas.Brush.Style:=bsSolid;
 Form10.Canvas.Brush.Color:=clBlack;
 Form10.Canvas.Rectangle(24,64,433,81);
 Form10.Canvas.Rectangle(24,88,433,105);
 Form10.Canvas.Brush.Color:=clLime;
 Form10.Canvas.Rectangle(24,64,LL,81);
 Form10.Canvas.Rectangle(24,88,RL,105);
end;

procedure TForm10.UpdatePBS_WASAPI(Level:Single);
var
 LL,RL:Integer;
begin
 if Level<0 then Level:=0
 else if Level>1 then Level:=1;
 LL:=Round(Level*409)+24;
 RL:=Round(Level*409)+24;
 Form10.Canvas.Brush.Style:=bsSolid;
 Form10.Canvas.Brush.Color:=clBlack;
 Form10.Canvas.Rectangle(24,64,433,81);
 Form10.Canvas.Rectangle(24,88,433,105);
 Form10.Canvas.Brush.Color:=clLime;
 Form10.Canvas.Rectangle(24,64,LL,81);
 Form10.Canvas.Rectangle(24,88,RL,105);
end;

procedure TForm10.StartRec;
var
 template:String;
 ErrorCode:Integer;
 wi:BASS_WASAPI_INFO;
begin
 if WaveStream.Size>0 then
  begin
   BASS_StreamFree(HPLAY);
   WaveStream.Clear;
   RecTimer:=0;
  end;
 with WaveHdr do
  begin
   riff:='RIFF';
   len:=36;
	 cWavFmt:='WAVEfmt ';
	 dwHdrLen:=16;
	 wFormat:=1;
	 wNumChannels:=2;
	 wBlockAlign:=4;
	 wBitsPerSample:=16;
	 cData:='data';
	 dwDataLen:=0;
  end;
 if WASAPIMode then
  begin
   with WaveHdr do
    begin
	   dwSampleRate:=48000;
	   dwBytesPerSec:=192000;
    end;
  end
 else
  begin
   with WaveHdr do
    begin
	   dwSampleRate:=44100;
	   dwBytesPerSec:=176400;
    end;
  end;
 WaveStream.Write(WaveHdr,SizeOf(WAVHDR));
 if WASAPIMode then
  begin
   BASS_WASAPI_GetInfo(wi);
   inmixer:=BASS_Mixer_StreamCreate(48000,2,BASS_STREAM_DECODE);
   instream:=BASS_StreamCreate(wi.freq,wi.chans,BASS_SAMPLE_FLOAT or BASS_STREAM_DECODE,STREAMPROC_PUSH,nil);
   BASS_Mixer_StreamAddChannel(inmixer,instream,0);
   if not BASS_WASAPI_Start then
    begin
     ShowMessage('Не могу начать запись: Причина неизвестна.');
     BASS_StreamFree(instream);
     BASS_StreamFree(inmixer);
     Exit;
    end;
  end
 else
  begin
   BASS_StreamFree(instream);
   BASS_StreamFree(inmixer);
   HREC:=BASS_RecordStart(44100,2,0,@RecordingCallback,nil);
  end;
 if (HREC=0) and (not WASAPIMode) then
  begin
   ErrorCode:=BASS_ErrorGetCode;
   template:='Не могу начать запись: ';
   case ErrorCode of
    BASS_ERROR_BUSY:
     ShowMessage(template + 'Звуковая карта перегружена.');
    BASS_ERROR_NOTAVAIL:
     ShowMessage(template + 'Звуковая карта недоступна. Проверьте, может какое-то другое приложение использует запись звука.');
    BASS_ERROR_MEM:
     ShowMessage(template + 'Недостаточно памяти.');
    BASS_ERROR_UNKNOWN:
     ShowMessage(template + 'Причина неизвестна.');
    else
     ShowMessage(template + 'Причина неизвестна.');
   end;
   Exit;
  end;
 Button1.Caption:='Остановить запись';
 Button2.Enabled:=False;
 Button3.Enabled:=False;
 ComboBox1.Enabled:=False;
 Rec:=True;
end;

procedure TForm10.StopRec;
var
 i:Integer;
begin
 Rec:=False;
 if WASAPIMode then
  begin
   BASS_WASAPI_Stop(True);
   BASS_StreamFree(instream);
   BASS_StreamFree(inmixer);
  end
 else BASS_ChannelStop(HREC);
 Button1.Caption:='Начать запись';
 WaveStream.Position:=4;
 i:=WaveStream.Size-8;
 WaveStream.Write(i,4);
 i:=i-$24;
 WaveStream.Position:=40;
 WaveStream.Write(i,4);
 WaveStream.Position:=0;
 HPLAY:=BASS_StreamCreateFile(True,WaveStream.Memory,0,WaveStream.Size,0);
 if HPLAY=0 then
  ShowMessage('Неизвестная ошибка')
 else
  begin
   Button2.Enabled:=True;
   Button3.Enabled:=True;
   ComboBox1.Enabled:=True;
  end;
end;

procedure TForm10.SetRecDevice(ID:Integer);
var
 ErrorCode:Integer;
begin
 if ID>=WAS_Offset then
  begin
   WASAPIMode:=
   (BASS_WASAPI_Init(-1,0,0,BASS_WASAPI_BUFFER,1,0.1,nil,nil))
   and
   (BASS_WASAPI_Init(-3,0,0,BASS_WASAPI_BUFFER,1,0.1,@WASAPICallback,nil));
   if not WASAPIMode then
    begin
     ErrorCode:=BASS_ErrorGetCode;
     WASAPIMode:=ErrorCode=BASS_ERROR_ALREADY;
    end;
  end
 else WASAPIMode:=False;
 if WASAPIMode then loopback:=BASS_WASAPI_GetDevice;
 if (not WASAPIMode) and (not BASS_RecordSetDevice(ID)) then
  begin
   ErrorCode:=BASS_ErrorGetCode;
   WASAPIMode:=False;
   if ErrorCode=BASS_ERROR_INIT then
    begin
     BASS_RecordInit(ID);
     BASS_RecordSetDevice(ID);
    end;
  end;
 UpdateInputList;
end;

procedure TForm10.UpdateInputList;
var
 i,s:Integer;
 vol:Single;
 name:PAnsiChar;
begin
 i:=-1;
 CheckListBox1.Clear;
 if not WASAPIMode then
  begin
   CheckListBox1.Enabled:=True;
   IVolumeTrackBar.Enabled:=True;
   repeat
    name:=BASS_RecordGetInputName(i);
    if name=nil then Break
    else
     begin
      CheckListBox1.Items.Add(name);
      s:=BASS_RecordGetInput(i,vol);
      CheckListBox1.ItemChecked[i+1]:=not IsBitSet(s,16);
     end;
    i:=i+1;
   until name=nil;
  end
 else
  begin
   CheckListBox1.Enabled:=False;
   IVolumeTrackBar.Enabled:=False;
  end;
end;

procedure TForm10.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Timer1.Enabled:=False;
 Timer2.Enabled:=False;
 BASS_WASAPI_Stop(True);
 BASS_StreamFree(HPLAY);
 BASS_StreamFree(instream);
 BASS_StreamFree(inmixer);
 BASS_RecordFree;
 WASAPIMode:=False;
 FreeAndNil(WaveStream);
end;

procedure TForm10.Button2Click(Sender: TObject);
begin
 if WASAPIMode then
  begin
   if BASS_WASAPI_IsStarted then
    StopRec
   else
    StartRec;
  end
 else
  begin
   if BASS_ChannelIsActive(HREC)<>0 then
    StopRec
   else
    StartRec;
  end;
end;

procedure TForm10.Button3Click(Sender: TObject);
begin
 BASS_ChannelPlay(HPLAY,True);
end;

procedure TForm10.Button4Click(Sender: TObject);
begin
 if SD.Execute then
  WaveStream.SaveToFile(SD.FileName);
end;

procedure TForm10.Timer1Timer(Sender: TObject);
begin
 if Rec then
  begin
   RecTimer:=RecTimer+(1/(24*60*60*4));
  end;
 Label1.Caption:=TimeToStr(RecTimer);
end;

procedure TForm10.Timer2Timer(Sender: TObject);
var
 LLevel,RLevel:Integer;
 Levels:DWORD;
begin
 if Rec then
  begin
   if WASAPIMode then
    Levels:=BASS_WASAPI_GetLevel
   else
    Levels:=BASS_ChannelGetLevel(HREC);
   LLevel:=WORD(Levels);
   RLevel:=HIWORD(Levels);
   UpdatePBS(LLevel,RLevel);
  end;
end;

procedure TForm10.ComboBox1Change(Sender: TObject);
begin
 SetRecDevice(ComboBox1.ItemIndex);
end;

procedure TForm10.FormCreate(Sender: TObject);
begin
 Unit4.SetsReading:=False;
 Form4.SettingsRead;
end;

procedure TForm10.CheckListBox1Click(Sender: TObject);
var
 vol:Single;
begin
 if CheckListBox1.Items.Count>0 then
  if CheckListBox1.ItemIndex>-1 then
   begin
    BASS_RecordGetInput(CheckListBox1.ItemIndex-1,vol);
    IVolumeTrackBar.Position:=Round(vol*1000);
   end;
end;

procedure TForm10.CheckListBox1Change(Sender: TObject; Index: Integer;
  NewState: TCheckBoxState);
var
 s:Integer;
 vol:Single;
begin
 if CheckListBox1.Items.Count>0 then
  begin
   s:=BASS_RecordGetInput(Index-1,vol);
   case NewState of
    cbUnchecked: s:=s or BASS_INPUT_OFF;
    cbChecked: s:=s or BASS_INPUT_ON;
   end;
   BASS_RecordSetInput(Index-1,s,vol);
  end;
end;

procedure TForm10.IVolumeTrackBarChange(Sender: TObject);
var
 s:Integer;
 vol:Single;
begin
 if CheckListBox1.Items.Count>0 then
  if CheckListBox1.ItemIndex>-1 then
   begin
    s:=BASS_RecordGetInput(CheckListBox1.ItemIndex-1,vol);
    BASS_RecordSetInput(CheckListBox1.ItemIndex-1,s,IVolumeTrackBar.Position/1000);
   end;
end;

procedure TForm10.IVolumeTrackBarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbLeft then
  IVolumeTrackBar.Position:=Form1.DoSomeStreetMagic(Y,IVolumeTrackBar.Height,IVolumeTrackBar.Max);
end;

end.
