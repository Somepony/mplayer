unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, BASS, tags, XPMan, ExtCtrls, Menus, ComCtrls, RzTrkBar, osc_vis, CommonTypes,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP, ShellAPI,
  IdIOHandler, IdIOHandlerSocket, IdSSLOpenSSL, md5hash, TaskBarW7, ImgList,
  RzStatus, JvComponentBase, JvComputerInfoEx, TLHelp32, MediaInfoDLL, uFMOD, Clipbrd, MMDevApi, ActiveX,
  DateUtils, MMsystem, ShlObj, BASSmix, SomeponyUtils, System.ImageList,
  System.Win.TaskbarCore, Vcl.Taskbar, System.Actions, Vcl.ActnList,
  IdIOHandlerStack, IdSSL, MplayerAPI;

const
 CWM_COMMANDS_ARRIVED=WM_USER+20;
 APP_NAME='Медиаплаир';
 APP_VERSION='0.8.10.4';
 SPEC_MODES_COUNT=5;
 //VALID_EXTENSIONS_COUNT=5;
 //VALID_EXTENSIONS:array[1..VALID_EXTENSIONS_COUNT] of String=('.mp3','.wav','.wave','.ogg','.xm');
 SETTINGS_FILE_NAME='settings.dat';
 STATS_FILE_NAME='stats.dat';
 NON_PUBLIC=False;

 VK_OFFICIAL_ANDROID_APP_ID='2274003';
 VK_OFFICIAL_ANDROID_APP_SECRET='hHbZxrka2uZ6jB1inYsH';
 VK_OFFICIAL_IPHONE_APP_ID='3140623';
 VK_OFFICIAL_IPHONE_APP_SECRET='VeWdmVclDCtn6ihuP1nt';

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    XPManifest1: TXPManifest;
    Button2: TButton;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    PlayPause1: TMenuItem;
    N3: TMenuItem;
    Label1: TLabel;
    Label2: TLabel;
    PosBar1: TRzTrackBar;
    Button1: TButton;
    Label3: TLabel;
    Label4: TLabel;
    PaintBox1: TPaintBox;
    ColorDialog1: TColorDialog;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    Button3: TButton;
    Button4: TButton;
    N9: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    N14: TMenuItem;
    N15: TMenuItem;
    AB1: TMenuItem;
    Label_A: TLabel;
    Label_B: TLabel;
    URL1: TMenuItem;
    HTTP1: TIdHTTP;
    VK1: TMenuItem;
    ImageList1: TImageList;
    N10: TMenuItem;
    N11: TMenuItem;
    N16: TMenuItem;
    N17: TMenuItem;
    N18: TMenuItem;
    N19: TMenuItem;
    MVolumeTrackBar: TRzTrackBar;
    Label5: TRzMarqueeStatus;
    RMS1: TRzMarqueeStatus;
    RMS2: TRzMarqueeStatus;
    N20: TMenuItem;
    CInfo: TJvComputerInfoEx;
    S_PointA: TShape;
    S_PointB: TShape;
    MediaInfo1: TMenuItem;
    N21: TMenuItem;
    N22: TMenuItem;
    N23: TMenuItem;
    N24: TMenuItem;
    SongTitlePopupMenu: TPopupMenu;
    N25: TMenuItem;
    N26: TMenuItem;
    SpecModeMenu: TPopupMenu;
    N27: TMenuItem;
    N28: TMenuItem;
    N29: TMenuItem;
    N30: TMenuItem;
    N31: TMenuItem;
    N32: TMenuItem;
    ActionList1: TActionList;
    Action1: TAction;
    Action2: TAction;
    Action3: TAction;
    Action4: TAction;
    Taskbar1: TTaskbar;
    IPa: TImage;
    IPl: TImage;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    N33: TMenuItem;
    N34: TMenuItem;
    N35: TMenuItem;
    function DoSomeUnicornMagic(X,W,M:Integer;Extra:Integer=0):Integer;
    function DoSomeStreetMagic(Y,H,M:Integer;Extra:Integer=0):Integer;
    procedure SetVistaVolume(Volume:Byte);
    procedure SetWinXPVolume(Volume:Byte);
    procedure ClosingTasks;
    procedure DropChannel;
    procedure ChangeFrcGUI(Frc:Integer);
    procedure HotKeyEngine(Mods,VKey:Word);
    procedure RegisterHotKeys;
    procedure UnregisterHotKeys;
    function IsValidExt(FilePath:String):Boolean;
    procedure TotalTerminate;
    function TerminatePlayersProcess:Boolean;
    function MarkCovered:Boolean;
    procedure InitErrorLog;
    procedure AddErrorLog(Msg:String);
    procedure EndErrorLog(Msg:String='');
    function ArrivedParamCount:Integer;
    function GetArrivedParamStrPos(Num:Integer):Integer;
    function ArrivedParamStr(Num:Integer):String;
    procedure IncVolume;
    procedure DecVolume;
    procedure RewForward(Sec:Integer);
    procedure RewBackward(Sec:Integer);
    procedure RewExact(Sec:Integer);
    procedure RewForwardPrc(Prc:Integer);
    procedure RewBackwardPrc(Prc:Integer);
    procedure RewExactPrc(Prc:Integer);
    procedure CheckBASSVersion;
    procedure InitBASS(Reinit:Boolean=False);
    function InitRecord:Boolean;
    procedure ScanDir(StartDir:String;Mask:string;List:TStrings;ScanSubDirs:Boolean);
    function ReadStringFromMailslot:String;
    procedure GoToForeground;
    procedure PlayFileByNum(Num:Integer=0;Stop:Boolean=False);
    procedure StopPlaying;
    procedure SetTitleCaption(CPT:String);
    function InvertColor(C:TColor):TColor;
    procedure LaunchCheckParams;
    procedure LaunchOpen;
    procedure OpenArrivedFiles;
    procedure OpenFile;
    procedure OpenURL;
    function CalcSIG(Rq:String):String;
    procedure OpenVKPlaylist;
    procedure PlayFile(Stop:Boolean=False;ChannelAlreadySetUp:Boolean=False);
    procedure StopFile;
    procedure PausePlay;
    procedure ABrepeat;
    procedure ABreset;
    procedure AfterPlaybackStopTask;
    procedure PrevButton;
    procedure SwapSpecMode;
    function SetSpecMode(ID:Byte):Boolean;
    function LoadGTC64func:Boolean;
    procedure SaveStats;
    procedure LoadStats;
    procedure ClearStats;
    procedure UpdateStatsUptime;
    procedure UpdateStatsPlayedTime;
    procedure LoadBASSPlugins;
    procedure AfterAppLoadTasks;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure PlayPause1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure PosBar1Change(Sender: TObject);
    procedure PosBar1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PosBar1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure N6Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure N9Click(Sender: TObject);
    procedure N13Click(Sender: TObject);
    procedure N14Click(Sender: TObject);
    procedure N15Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure AB1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure URL1Click(Sender: TObject);
    procedure VK1Click(Sender: TObject);
    procedure N17Click(Sender: TObject);
    procedure N18Click(Sender: TObject);
    procedure N19Click(Sender: TObject);
    procedure MVolumeTrackBarChange(Sender: TObject);
    procedure N20Click(Sender: TObject);
    procedure MediaInfo1Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N22Click(Sender: TObject);
    procedure N23Click(Sender: TObject);
    procedure N24Click(Sender: TObject);
    procedure N25Click(Sender: TObject);
    procedure N26Click(Sender: TObject);
    procedure PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MVolumeTrackBarMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure N27Click(Sender: TObject);
    procedure N28Click(Sender: TObject);
    procedure N29Click(Sender: TObject);
    procedure N30Click(Sender: TObject);
    procedure N31Click(Sender: TObject);
    procedure N32Click(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure Action3Execute(Sender: TObject);
    procedure Action4Execute(Sender: TObject);
    procedure N33Click(Sender: TObject);
  private
    procedure WMDROPFILES(var Message:TWMDROPFILES); message WM_DROPFILES;
    procedure WMCommandArrived(var Message:TMessage); message CWM_COMMANDS_ARRIVED;
    procedure WMHotKeyHandler(var Message:TMessage); message WM_HOTKEY;
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
    procedure WMXMouseButtonsHandler(var Message:TMessage); message WM_APPCOMMAND;
  public
    { Public declarations }
  end;

  TOcilloScopeThread=class(TThread)
   procedure DrawOcilloScope;
   procedure Execute; override;
  end;

  TCommandsThread=class(TThread)
   procedure Execute; override;
  end;

  TMMKeysHandler=class(TThread)
   procedure MMNextSong;
   procedure MMPrevSong;
   procedure MMStop;
   procedure MMPausePlay;
   procedure Execute; override;
  end;

  TSongInfo=record
   Arti:String;
   Title:String;
   Album:String;
   Duration:TDateTime;
   AddThis:Boolean;
  end;

  TMetrics=(kbyte,Mbyte,Gbyte,Tbyte);

  TStats=record
   PlayedTimeMSECThisRun:Int64;
   PlayedTimeMSECTotal:Int64;
   PlayedTraxThisRun:Int64;
   PlayedTraxTotal:Int64;
   UptimeMSECTotal:Int64;
   LaunchedTimesTotal:Int64;
   ConsoleCmdsUsedTimesTotal:Int64;
  end;

  TGetTickCount64=function():Int64;

var
  Form1: TForm1;
  MediaFilePath,ErrorLogFilePath:String;
  MediaFile:HSTREAM;
  Playing:Boolean;
  Rew:Boolean;
  MediaInfo:BASS_CHANNELINFO;
  MediaInfoHandle:Cardinal;
  CurSongNum:Cardinal;
  OcilloScopeThread:TOcilloScopeThread;
  AppLoaded,NeededRepaint,NeededInstantRepaintInNextItr:Boolean;
  ABstage,Itr:Byte;
  PointA,PointB:Int64;
  Sets:File of Integer;
  SetsPath:String;
  AppClosing:Boolean;
  VKAccessToken,VKDefaultID,VKSecret:String;
  VKAuth,VKNameGet:Boolean;
  SongInfo:TSongInfo;
  ServerMailslotHandle,CommandEvent:THandle;
  CommandsThread:TCommandsThread;
  MMKeysHandler:TMMKeysHandler;
  ArrivedParamString:String;
  ErrorLog:TStringList;
  CheckFileExt:Boolean;
  MediaInfoLoaded:Boolean;
  MediaInfoUpdateNeeded:Boolean=False;
  ShowOSDNeeded:Boolean=False;
  tmpOSDtext:String;
  LaunchProgram,LaunchProgramParams,PerformCommand:String;
  ProgDir:String;
  keyids:array of TAtom;
  cfrc:Integer;
  speedprc:Single;
  OcilloFPSLimit:Word=20;
  WinXP_gs_hMixer:HMIXER;
  WinXP_gs_mxcd:TMIXERCONTROLDETAILS;
  IsVista:Boolean;
  GlobalFormats:TFormatSettings;
  Stats:TStats;
  StatsPath:String;
  StatsFile:file of TStats;
  LaunchTimeStamp:Int64;
  GetTickCount64:TGetTickCount64;
  GTC64loaded:Boolean;
  PTstamp:Int64=0;
  StartedFirstTime:Boolean=False;
  UserAgent:PChar;
  TryVKImportAnyway:Boolean=False;
  MinecraftMacromodHook:Boolean=False;
  VKPretendOfficial:Boolean=False;
  //TB:TaskBarW7.TTaskBar;

  OLDbytes:Int64;
  OLDtimestamp:Cardinal;

  DEBUG_Params:String;

  function GetConvertedBitrate(Handle:HSTREAM;var Metrics:TMetrics):Extended;

implementation
uses Unit2, Unit3, Unit4, Unit5, Unit6, Unit7, Unit8, Unit9, Unit10, Unit11, Unit12, Unit13, Unit14, Unit15, Unit16, UnitOSD, Unit17;

{$R *.dfm}

procedure WinXP_InitVolume;
var
 mxlc:MIXERLINECONTROLS;
 mxl:MIXERLINE;
 mxc:MIXERCONTROL;
begin
 mixerOpen(@WinXP_gs_hMixer,0,0,0,0);
 ZeroMemory(@mxl,sizeof(mxl));
 mxl.cbStruct:=sizeof(mxl);
 mxl.dwComponentType:=MIXERLINE_COMPONENTTYPE_DST_SPEAKERS;
 mixerGetLineInfo(WinXP_gs_hMixer,@mxl,MIXER_GETLINEINFOF_COMPONENTTYPE);
 ZeroMemory(@mxlc,sizeof(mxlc));
 mxlc.cbStruct:=sizeof(mxlc);
 mxlc.dwLineID:=mxl.dwLineID;
 mxlc.dwControlType:=MIXERCONTROL_CONTROLTYPE_VOLUME;
 //mxlc.dwControlType:=MIXERCONTROL_CONTROLTYPE_DECIBELS;
 mxlc.cControls:=1;
 mxlc.cbmxctrl:=sizeof(mxc);
 mxlc.pamxctrl:=@mxc;
 ZeroMemory(@mxc,sizeof(mxc));
 mxc.cbStruct:=sizeof(mxc);
 mixerGetLineControls(WinXP_gs_hMixer,@mxlc,MIXER_GETLINECONTROLSF_ONEBYTYPE);
 ZeroMemory(@WinXP_gs_mxcd,sizeof(WinXP_gs_mxcd));
 WinXP_gs_mxcd.cbStruct:=sizeof(WinXP_gs_mxcd);
 WinXP_gs_mxcd.cbDetails:=sizeof(MIXERCONTROLDETAILS_UNSIGNED);
 WinXP_gs_mxcd.dwControlID:=mxc.dwControlID;
 WinXP_gs_mxcd.cChannels:=1;
end;

procedure WinXP_CloseVolume;
begin
 mixerClose(WinXP_gs_hMixer);
end;

function WinXP_GetVolume:DWORD;
var
 volS:MIXERCONTROLDETAILS_UNSIGNED;
begin
 WinXP_gs_mxcd.paDetails:=@volS;
 mixerGetControlDetails(WinXP_gs_hMixer,@WinXP_gs_mxcd,MIXER_GETCONTROLDETAILSF_VALUE);
 Result:=volS.dwValue;
end;

procedure WinXP_SetVolume(Volume:DWORD);
var
 volS:MIXERCONTROLDETAILS_UNSIGNED;
begin
 ZeroMemory(@volS,sizeof(volS));
 WinXP_gs_mxcd.paDetails:=@volS;
 volS.dwValue:=Volume;
 mixerSetControlDetails(WinXP_gs_hMixer,@WinXP_gs_mxcd,0);
end;

procedure ShellExecute(const AWnd: HWND; const AOperation, AFileName: String; const AParameters: String = ''; const ADirectory: String = ''; const AShowCmd: Integer = SW_SHOWNORMAL);
var
 ExecInfo:TShellExecuteInfo;
 NeedUninitialize:Boolean;
begin
  Assert(AFileName<>'');
  NeedUninitialize:=SUCCEEDED(CoInitializeEx(nil,COINIT_APARTMENTTHREADED or COINIT_DISABLE_OLE1DDE));
  try
   FillChar(ExecInfo,SizeOf(ExecInfo),0);
    ExecInfo.cbSize:=SizeOf(ExecInfo);
    ExecInfo.Wnd:= AWnd;
    ExecInfo.lpVerb:=Pointer(AOperation);
    ExecInfo.lpFile:=PChar(AFileName);
    ExecInfo.lpParameters:=Pointer(AParameters);
    ExecInfo.lpDirectory:=Pointer(ADirectory);
    ExecInfo.nShow:=AShowCmd;
    ExecInfo.fMask:=SEE_MASK_FLAG_NO_UI;
    {$IFDEF UNICODE}
    // Необязательно, см. http://www.transl-gunsmoker.ru/2015/01/what-does-SEEMASKUNICODE-flag-in-ShellExecuteEx-actually-do.html
    ExecInfo.fMask := ExecInfo.fMask or SEE_MASK_UNICODE;
    {$ENDIF}
 
    {$WARN SYMBOL_PLATFORM OFF}
    Win32Check(ShellExecuteEx(@ExecInfo));
    {$WARN SYMBOL_PLATFORM ON}
  finally
    if NeedUninitialize then
      CoUninitialize;
  end;
end;

function GetSpecialFolderLocation(const Folder: Integer; const FolderNew: TGUID): String;
const
  KF_FLAG_DONT_VERIFY         = $00004000;
var
  FolderPath: PWideChar;
  SHGetFolderPath: function(hwnd: HWND; csidl: Integer; hToken: THandle; dwFlags: DWORD; pszPath: PWideChar): HResult; stdcall;
  SHGetKnownFolderPath: function(const rfid: TIID; dwFlags: DWORD; hToken: THandle; var ppszPath: PWideChar): HRESULT; stdcall;
begin
  Result := '';
 
  if not CompareMem(@FolderNew, @GUID_NULL, SizeOf(TGUID)) then
  begin
    SHGetKnownFolderPath := GetProcAddress(GetModuleHandle('Shell32.dll'), 'SHGetKnownFolderPath');
    if Assigned(SHGetKnownFolderPath) then
    begin
      FolderPath := nil;
      SetLastError(Cardinal(SHGetKnownFolderPath(FolderNew, KF_FLAG_DONT_VERIFY, 0, FolderPath)));
      if Succeeded(HRESULT(GetLastError)) then
      begin
        Result := FolderPath;
        CoTaskMemFree(FolderPath);
      end;
    end;
  end;
 
  if (Result = '') and (Folder >= 0) then
  begin
    SHGetFolderPath := GetProcAddress(GetModuleHandle('Shell32.dll'), 'SHGetFolderPathW');
    if Assigned(SHGetFolderPath) then
    begin
      FolderPath := AllocMem((MAX_PATH + 1) * SizeOf(WideChar));
      SetLastError(Cardinal(SHGetFolderPath(0, Folder, 0, 0, FolderPath)));
      if Succeeded(HRESULT(GetLastError)) then
        Result := FolderPath;
      FreeMem(FolderPath);
    end;
  end;
 
  if Result <> '' then
    Result := IncludeTrailingPathDelimiter(Result);
end;

function ParamStrContainFiles:Boolean;
begin
 Result:=False;
 if ParamCount>0 then
  if FileExists(ParamStr(1)) then
   begin
    Result:=True;
    Exit;
   end;
end;

procedure DetermineCurSongNum;
var
 cn,cns,i,L:Integer;
 cursec:Int64;
 tmpStr:String;
begin
 cns:=0;
 cursec:=Round(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)));
 L:=Length(SongMetaData);
 if L>0 then
  begin
   for i := 0 to L-1 do
    if SongMetaData[i].Name='Start' then
     if cursec>=CueIndexToSeconds(SongMetaData[i].Value) then
      if CueIndexToSeconds(SongMetaData[i].Value)>=cns then
       begin
        cns:=CueIndexToSeconds(SongMetaData[i].Value);
        cn:=SongMetaData[i].Num;
       end;
   CurSongNum:=cn;
   tmpStr:=GetSongArtist(CurSongNum) + ' - ' + GetSongName(CurSongNum);
   Form1.SetTitleCaption(IntToStr(cn+1) + '. ' + tmpStr);
   Form2.ListView1.ItemIndex:=cn;
  end;
end;

function TForm1.DoSomeUnicornMagic(X,W,M:Integer;Extra:Integer=0):Integer;
var
 p:Integer;
begin
 Extra:=Abs(Extra);
 X:=Round((X*(W+22)/W))-10;
 p:=Round((X*100)/W);
 Result:=Round(p*(M+Extra)/100)-Extra;
end;

function TForm1.DoSomeStreetMagic(Y,H,M:Integer;Extra:Integer=0):Integer;
begin
 Result:=DoSomeUnicornMagic(H-Y,H,M,Extra);
end;

procedure TForm1.SetVistaVolume(Volume:Byte);
var
 deviceEnumerator:IMMDeviceEnumerator;
 defaultDevice:IMMDevice;
 endpointVolume:IAudioEndpointVolume;
begin
 CoCreateInstance(CLASS_IMMDeviceEnumerator,nil,CLSCTX_INPROC_SERVER,IID_IMMDeviceEnumerator,deviceEnumerator);
 deviceEnumerator.GetDefaultAudioEndpoint(eRender,eConsole,defaultDevice);
 defaultDevice.Activate(IID_IAudioEndpointVolume,CLSCTX_INPROC_SERVER,nil,endpointVolume);
 endpointVolume.SetMasterVolumeLevelScalar(Volume/100,nil);
end;

procedure TForm1.SetWinXPVolume(Volume:Byte);
var
 tVl:Integer;
begin
 tVl:=Round(Volume*255/100);
 WinXP_InitVolume;
 WinXP_SetVolume((tVl shl 8) or tVl);
 WinXP_CloseVolume;
end;

procedure TMMKeysHandler.MMNextSong;
begin
 Form2.PlayNextSong;
end;

procedure TMMKeysHandler.MMPrevSong;
begin
 Form1.PrevButton;
end;

procedure TMMKeysHandler.MMStop;
begin
 Form1.StopPlaying;
end;

procedure TMMKeysHandler.MMPausePlay;
begin
 Form1.PausePlay;
end;

procedure TMMKeysHandler.Execute;
begin
 while not Terminated do
  begin
   if getasynckeystate(176)<>0 then
    begin
     Synchronize(MMNextSong);
     Sleep(500);
    end;
   if getasynckeystate(177)<>0 then
    begin
     Synchronize(MMPrevSong);
     Sleep(500);
    end;
   if getasynckeystate(178)<>0 then
    begin
     Synchronize(MMStop);
     Sleep(500);
    end;
   if getasynckeystate(179)<>0 then
    begin
     Synchronize(MMPausePlay);
     Sleep(500);
    end;
   Sleep(1);
  end;
end;

procedure TForm1.ClosingTasks;
begin
 Form4.SettingsSave;
 Form16.SaveHistory;
 if Playing then
  Form1.UpdateStatsPlayedTime;
 Stats.PlayedTimeMSECTotal:=Stats.PlayedTimeMSECTotal+Stats.PlayedTimeMSECThisRun;
 Form1.UpdateStatsUptime;
 Form1.SaveStats;
 UnregisterHotKeys;
 MMKeysHandler.Terminate;
 FreeAndNil(MMKeysHandler);
 Form12.HTTPSrv.Active:=False;
 FreeAndNil(Form12.HTTPSrv);
 if RestoreWinVolFlag then
  if IsVista then
   SetVistaVolume(RestoreWinVolValue)
  else
   SetWinXPVolume(RestoreWinVolValue);
 if timer <> 0 then
  timeKillEvent(timer);
 BASS_Free;
 if SpecDC <> 0 then
  DeleteDC(SpecDC);
 if SpecBmp <> 0 then
  DeleteObject(specbmp);
end;

procedure TForm1.DropChannel;
begin
 StopPlaying;
 BASS_ChannelStop(MediaFile);
 BASS_StreamFree(MediaFile);
 BASS_MusicFree(MediaFile);
 MediaFilePath:='';
 ABreset;
 Label1.Caption:='0:00:00';
 Label2.Caption:='0:00:00';
 SetTitleCaption('');
 Label4.Caption:='Частота: 0 Гц' + #13 + 'Каналы: 0' + #13 + 'Битрейт: 0 кбит/сек';
 MediaFile:=0;
end;

procedure TForm1.ChangeFrcGUI(Frc:Integer);
var
 tmpSL:TStringList;
 lngth,cpos:Int64;
 tmpprc:Single;
begin
 if AppLoaded then
  begin
   if Frc=cfrc then
    begin
     tmpprc:=speedprc;
     speedprc:=100;
    end;
   tmpSL:=TStringList.Create;
   tmpSL.Text:=Label4.Caption;
   tmpSL.Strings[0]:='Частота: ' + IntToStr(Frc) + ' Гц';
   Label4.Caption:=tmpSL.Text;
   FreeAndNil(tmpSL);
   if speedprc>0 then
    begin
     lngth:=BASS_ChannelGetLength(MediaFile,BASS_POS_BYTE);
     lngth:=Round(lngth/speedprc*100);
     Label2.Caption:=MyTimeToStr(BASS_ChannelBytes2Seconds(MediaFile,lngth)/(60*60*24));
     cpos:=BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE);
     cpos:=Round(cpos/speedprc*100);
     Label1.Caption:=MyTimeToStr(BASS_ChannelBytes2Seconds(MediaFile,cpos)/(60*60*24));
    end;
   if Frc=cfrc then speedprc:=tmpprc;
  end;
end;

procedure TForm1.HotKeyEngine(Mods,VKey:Word);
var
 m:Byte;
 reqMod:Word;
begin
 case VKey of
  176: Form2.PlayNextSong;
  177: PrevButton;
  178: StopPlaying;
  179: PausePlay;
 end;
 if Form3.CheckBox4.Checked then
  begin
   m:=Form3.ComboBox2.ItemIndex;
   case m of
    0: reqMod:=MOD_CONTROL;
    1: reqMod:=MOD_ALT;
    2: reqMod:=MOD_CONTROL or MOD_ALT;
   end;
   if Mods<>reqMod then Exit;
   case VKey of
    VK_F9: PrevButton;
    VK_F10: PausePlay;
    VK_F11: StopPlaying;
    VK_F12: Form2.PlayNextSong;
   end;
  end;
end;

procedure TForm1.RegisterHotKeys;
var
 i:Byte;
begin
 SetLength(keyids,12);
 for i:= 0 To Length(keyids)-1 Do
  keyids[i]:=GlobalAddAtom(PChar('PonyPlayer HK' + IntToStr(i+1)));
 RegisterHotKey(Form1.Handle,keyids[0],MOD_CONTROL,VK_F9);
 RegisterHotKey(Form1.Handle,keyids[1],MOD_CONTROL,VK_F10);
 RegisterHotKey(Form1.Handle,keyids[2],MOD_CONTROL,VK_F11);
 RegisterHotKey(Form1.Handle,keyids[3],MOD_CONTROL,VK_F12);
 RegisterHotKey(Form1.Handle,keyids[4],MOD_ALT,VK_F9);
 RegisterHotKey(Form1.Handle,keyids[5],MOD_ALT,VK_F10);
 RegisterHotKey(Form1.Handle,keyids[6],MOD_ALT,VK_F11);
 RegisterHotKey(Form1.Handle,keyids[7],MOD_ALT,VK_F12);
 RegisterHotKey(Form1.Handle,keyids[8],MOD_CONTROL or MOD_ALT,VK_F9);
 RegisterHotKey(Form1.Handle,keyids[9],MOD_CONTROL or MOD_ALT,VK_F10);
 RegisterHotKey(Form1.Handle,keyids[10],MOD_CONTROL or MOD_ALT,VK_F11);
 RegisterHotKey(Form1.Handle,keyids[11],MOD_CONTROL or MOD_ALT,VK_F12);
 {RegisterHotKey(Form1.Handle,keyids[12],0,176);
 RegisterHotKey(Form1.Handle,keyids[13],0,177);
 RegisterHotKey(Form1.Handle,keyids[14],0,178);
 RegisterHotKey(Form1.Handle,keyids[15],0,179);}
end;

procedure TForm1.UnregisterHotKeys;
var
 i:Byte;
begin
 for i:= 0 To Length(keyids)-1 Do
  begin
   UnregisterHotKey(Form1.Handle,keyids[i]);
   GlobalDeleteAtom(keyids[i]);
  end;
end;

function TForm1.IsValidExt(FilePath:String):Boolean;
{var
 i,start:Byte;
 Extension:String;}
begin
 {Result:=False;
 if CheckFileExt then
  begin
   Extension:=LowerCase(ExtractFileExt(FilePath));
   start:=1;
   for i:= start To VALID_EXTENSIONS_COUNT Do
    if Extension=VALID_EXTENSIONS[i] then
     begin
      Result:=True;
      Exit;
     end;
  end
 else} Result:=True;
end;

function KillProcess(ExeName:string):Boolean;
var
 B:Boolean;
 ProcList:THandle;
 PE:TProcessEntry32;
begin
 Result:=False;
 ProcList:=CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS,0);
 PE.dwSize:=SizeOf(PE);
 B:=Process32First(ProcList,PE);
 while B do
  begin
   if (UpperCase(PE.szExeFile)=UpperCase(ExtractFileName(ExeName))) then
    Result:=TerminateProcess(OpenProcess($0001,False,PE.th32ProcessID),0);
   B:=Process32Next(ProcList,PE);
  end;
 CloseHandle(ProcList);
end;

function GetMarkPos(Point:Int64):Integer;
var
 Max:Int64;
begin
 Max:=BASS_ChannelGetLength(MediaFile,BASS_POS_BYTE);
 Result:=Round(Point*365/Max)+17;
end;

function InitErrorMsgToString(ErrorID:Integer):String;
begin
 case ErrorID of
  BASS_ERROR_DX: Result:='BASS_ERROR_DX';
  BASS_ERROR_DEVICE: Result:='BASS_ERROR_DEVICE';
  BASS_ERROR_ALREADY: Result:='BASS_ERROR_ALREADY';
  BASS_ERROR_DRIVER: Result:='BASS_ERROR_DRIVER';
  BASS_ERROR_FORMAT: Result:='BASS_ERROR_FORMAT';
  BASS_ERROR_MEM: Result:='BASS_ERROR_MEM';
  BASS_ERROR_NO3D: Result:='BASS_ERROR_NO3D';
  BASS_ERROR_UNKNOWN: Result:='BASS_ERROR_UNKNOWN';
 end;
end;

function SecondsToIntValue(Seconds:Double):Integer;
begin
 Result:=Trunc(Seconds*1000);
end;

function IntValueToSeconds(IntValue:Integer):Double;
begin
 Result:=IntValue/1000;
end;

procedure TCommandsThread.Execute;
begin
 while True Do
  begin
   if WaitForSingleObject(CommandEvent,INFINITE)=WAIT_OBJECT_0 then
    PostMessage(Form1.Handle,CWM_COMMANDS_ARRIVED,0,0);
  end;
end;

procedure TForm1.TotalTerminate;
begin
 ClosingTasks;
 Application.Terminate;
 TerminatePlayersProcess; // Если строчка выше не сработала, применяем тяжёлую артиллерию
end;

function TForm1.TerminatePlayersProcess:Boolean;
var
 ExeName:String;
begin
 ExeName:=ExtractFileName(Application.ExeName);
 Result:=KillProcess(ExeName);
end;

function TForm1.MarkCovered:Boolean;
var
 CurPos,diff:Integer;
begin
 Result:=False;
 CurPos:=GetMarkPos(BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE));
 diff:=S_PointA.Left-CurPos;
 if (diff>=-6) and (diff<=6) then Result:=True;
 if (not Result) and (ABstage=2) then
  begin
   diff:=S_PointB.Left-CurPos;
   if (diff>=-6) and (diff<=6) then Result:=True;
  end;
end;

procedure TForm1.InitErrorLog;
begin
 ErrorLog:=TStringList.Create;
 ErrorLog.Add('mplayer ' + APP_VERSION);
 ErrorLog.Add('Момент запуска: '+DateToStr(Date)+' '+MyTimeToStr(Time,True) + ' / ' + FloatToStr(Date+Time));
 ErrorLog.Add('');
 ErrorLog.Add('-----Инфо о системе-----');
 ErrorLog.Add('Процессор: ' + Trim(CInfo.CPU.Name));
 ErrorLog.Add('Всего RAM: ' + IntToStr(CInfo.Memory.TotalPhysicalMemory) + ' байт');
 ErrorLog.Add('Свободно RAM: ' + IntToStr(CInfo.Memory.FreePhysicalMemory) + ' байт');
 if CInfo.OS.ServicePackVersion>0 then
  ErrorLog.Add('ОС: ' + CInfo.OS.ProductName + ' ' + CInfo.OS.VersionCSDString)
 else
  ErrorLog.Add('ОС: ' + CInfo.OS.ProductName);
 ErrorLog.Add('');
end;

procedure TForm1.AddErrorLog(Msg:String);
begin
 ErrorLog.Add(DateToStr(Date)+' '+MyTimeToStr(Time,True) + ' - ' + Msg);
end;

procedure TForm1.EndErrorLog(Msg:String='');
var
 i:Integer;
begin
 if Length(Msg)>0 then ErrorLog.Add(DateToStr(Date)+' '+TimeToStr(Time) + ' - ' + Msg);
 ErrorLogFilePath:=ExtractFilePath(Application.ExeName)+'ErrorLog-'+DateToStr(Date)+'-'+TimeToStr(Time)+'.txt';
 i:=2;
 repeat
  i:=i+1;
  if ErrorLogFilePath[i]=':' then
   begin
    Delete(ErrorLogFilePath,i,1);
    i:=i-1;
   end;
 until i>=Length(ErrorLogFilePath);
 ErrorLog.SaveToFile(ErrorLogFilePath);
 Application.Terminate;
end;

function TForm1.ArrivedParamCount:Integer;
var
 i,L:Integer;
 IgnoreSpace:Boolean;
begin
 Result:=0;
 L:=Length(ArrivedParamString);
 IgnoreSpace:=False;
 if (L>0) and (Copy(ArrivedParamString,1,1)='o') then
  for i:= 2 To L Do
   begin
    if ArrivedParamString[i]='"' then
     IgnoreSpace:=not IgnoreSpace;
    if (ArrivedParamString[i]=' ') and (not IgnoreSpace) then
     Result:=Result+1;
   end;
end;

function TForm1.GetArrivedParamStrPos(Num:Integer):Integer;
var
 i,L,count:Integer;
 IgnoreSpace:Boolean;
begin
 count:=0;
 L:=Length(ArrivedParamString);
 IgnoreSpace:=False;
 if (L>0) and (Copy(ArrivedParamString,1,1)='o') then
  for i:= 2 To L Do
   begin
    if ArrivedParamString[i]='"' then
     IgnoreSpace:=not IgnoreSpace;
    if (ArrivedParamString[i]=' ') and (not IgnoreSpace) then
     begin
      count:=count+1;
      if count=Num then
       begin
        Result:=i;
        Exit;
       end;
     end;
   end;
end;

function TForm1.ArrivedParamStr(Num:Integer):String;
var
 start,i:Integer;
 IgnoreSpace:Boolean;
begin
 start:=GetArrivedParamStrPos(Num);
 IgnoreSpace:=False;
 for i:= start To Length(ArrivedParamString) Do
  begin
   if (ArrivedParamString[i]='"') and IgnoreSpace then
    begin
     Result:=Copy(ArrivedParamString,start+2,i-start-2);
     Exit;
    end
   else if ArrivedParamString[i]='"' then IgnoreSpace:=True;
  end;
end;

procedure TForm1.IncVolume;
begin
 MVolumeTrackBar.Position:=MVolumeTrackBar.Position+50;
end;

procedure TForm1.DecVolume;
begin
 MVolumeTrackBar.Position:=MVolumeTrackBar.Position-50;
end;

procedure TForm1.RewForward(Sec:Integer);
var
 bts:Int64;
begin
 bts:=BASS_ChannelSeconds2Bytes(MediaFile,IntValueToSeconds(PosBar1.Position)+Sec);
 BASS_ChannelSetPosition(MediaFile,bts,BASS_POS_BYTE);
 PosBar1.Position:=SecondsToIntValue(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)));
end;

procedure TForm1.RewBackward(Sec:Integer);
var
 bts:Int64;
begin
 if PosBar1.Position>(Sec*1000) then
  bts:=BASS_ChannelSeconds2Bytes(MediaFile,IntValueToSeconds(PosBar1.Position)-Sec)
 else
  bts:=0;
 BASS_ChannelSetPosition(MediaFile,bts,BASS_POS_BYTE);
 PosBar1.Position:=SecondsToIntValue(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)));
end;

procedure TForm1.RewExact(Sec:Integer);
var
 bts:Int64;
begin
 if Sec>=0 then
  begin
   bts:=BASS_ChannelSeconds2Bytes(MediaFile,Sec);
   BASS_ChannelSetPosition(MediaFile,bts,BASS_POS_BYTE);
   PosBar1.Position:=SecondsToIntValue(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)));
  end;
end;

procedure TForm1.RewForwardPrc(Prc:Integer);
var
 bts:Int64;
 cpos:Integer;
 cprc:Extended;
begin
 if (Prc>=0) and (Prc<=100) then
  begin
   cpos:=PosBar1.Position;
   cprc:=cpos*100/PosBar1.Max;
   cprc:=cprc+Prc;
   if (cprc>=0) and (cprc<=100) then
    begin
     cpos:=Round(cprc*PosBar1.Max/100);
     bts:=BASS_ChannelSeconds2Bytes(MediaFile,IntValueToSeconds(cpos));
     BASS_ChannelSetPosition(MediaFile,bts,BASS_POS_BYTE);
     PosBar1.Position:=SecondsToIntValue(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)));
    end;
  end;
end;

procedure TForm1.RewBackwardPrc(Prc:Integer);
var
 bts:Int64;
 cpos:Integer;
 cprc:Extended;
begin
 if (Prc>=0) and (Prc<=100) then
  begin
   cpos:=PosBar1.Position;
   cprc:=cpos*100/PosBar1.Max;
   cprc:=cprc-Prc;
   if cprc<0 then cprc:=0;
   if cprc<=100 then
    begin
     cpos:=Round(cprc*PosBar1.Max/100);
     bts:=BASS_ChannelSeconds2Bytes(MediaFile,IntValueToSeconds(cpos));
     BASS_ChannelSetPosition(MediaFile,bts,BASS_POS_BYTE);
     PosBar1.Position:=SecondsToIntValue(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)));
    end;
  end;
end;

procedure TForm1.RewExactPrc(Prc:Integer);
var
 bts:Int64;
 cpos:Integer;
begin
 if (Prc>=0) and (Prc<=100) then
  begin
   cpos:=Round(Prc*PosBar1.Max/100);
   bts:=BASS_ChannelSeconds2Bytes(MediaFile,IntValueToSeconds(cpos));
   BASS_ChannelSetPosition(MediaFile,bts,BASS_POS_BYTE);
   PosBar1.Position:=SecondsToIntValue(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)));
  end;
end;

procedure TForm1.CheckBASSVersion;
var
 ans:Integer;
 textversion:String;
begin
 if HIWORD(BASS_GetVersion)<>BASSVERSION then
  begin
   textversion:=IntToHex(HIWORD(BASS_GetVersion),3);
   textversion[2]:='.';
   Beep;
   ans:=MessageDlg('Внимание! Неверная версия библиотеки BASS.' + #13 + '(Ожидалась версия ' + BASSVERSIONTEXT + ', однако обнаружена ' + textversion + ')' + #13 + 'Плаир может попытаться продолжить работу, однако нормальная работа не гарантируется.' + #13#13 + 'Игнорировать предупреждение и продолжить работу?',mtConfirmation,[mbYes,mbNo],0);
   if ans=mrNo then TotalTerminate;
  end;
end;

procedure TForm1.InitBASS(Reinit:Boolean=False);
var
 ErrorCode:Integer;
 template:String;
 StopProgramm:Boolean;
begin
 BASS_SetConfig(BASS_CONFIG_DEV_DEFAULT,1);
 UserAgent:='mplayer/'+APP_VERSION;
 BASS_SetConfigPtr(BASS_CONFIG_NET_AGENT,UserAgent);
 BASS_Init(0,48000,0,0,nil);
 if not BASS_Init(-1,44100,0,Form1.Handle,nil) then
  begin
   ErrorCode:=BASS_ErrorGetCode;
   StopProgramm:=True;
   template:='Приложению не удалось запустится: ';
   MessageBeep(MB_ICONHAND);
   case ErrorCode of
    BASS_ERROR_DX:
     ShowMessage(template + 'DirectX не установлен.');
    BASS_ERROR_DEVICE:
     ShowMessage(template + 'Проверьте звуковую карту.');
    BASS_ERROR_ALREADY:
     if Reinit then
      ShowMessage(template + 'Причина неизвестна.')
     else
      begin
       BASS_Free;
       InitBass(True);
       StopProgramm:=False;
      end;
    BASS_ERROR_DRIVER:
     ShowMessage(template + 'Проверьте драйвер звуковой карты.');
    BASS_ERROR_MEM:
     ShowMessage(template + 'Недостаточно памяти.');
    BASS_ERROR_UNKNOWN:
     ShowMessage(template + 'Причина неизвестна.');
    else
     ShowMessage(template + 'Причина неизвестна.');
   end;
   if StopProgramm then
    EndErrorLog('Ошибка при инициализации библиотеки BASS (' + InitErrorMsgToString(ErrorCode) + ')');
  end;
end;

function TForm1.InitRecord:Boolean;
var
 ErrorCode:Integer;
 template:String;
begin
 Result:=BASS_RecordInit(-1);
 if not Result then
  begin
   template:='Не удалось начать запись: ';
   BASS_StreamFree(inmixer);
   ErrorCode:=BASS_ErrorGetCode;
   case ErrorCode of
    BASS_ERROR_DX:
     ShowMessage(template + 'DirectX не установлен.');
    BASS_ERROR_DEVICE:
     ShowMessage(template + 'Проверьте звуковую карту.');
    BASS_ERROR_DRIVER:
     ShowMessage(template + 'Проверьте драйвер звуковой карты.');
    BASS_ERROR_UNKNOWN:
     ShowMessage(template + 'Причина неизвестна.');
    else
     ShowMessage(template + 'Причина неизвестна.');
   end;
  end;
end;

procedure TForm1.ScanDir(StartDir:String;Mask:string;List:TStrings;ScanSubDirs:Boolean);
var
 SearchRec:TSearchRec;
begin
 if Mask ='' then Mask:= '*.*';
 if StartDir[Length(StartDir)] <> '\' then StartDir := StartDir + '\';
 if FindFirst(StartDir+Mask, faAnyFile, SearchRec) = 0 then
  begin
   repeat
    Application.ProcessMessages;
    if (SearchRec.Attr and faDirectory) <> faDirectory then
     List.Add(StartDir + SearchRec.Name)
    else if (SearchRec.Name <> '..') and (SearchRec.Name <> '.') and ScanSubDirs then
     begin
      List.Add(StartDir + SearchRec.Name + '\');
      ScanDir(StartDir + SearchRec.Name + '\',Mask,List,True);
     end;
   until FindNext(SearchRec) <> 0;
   FindClose(SearchRec);
  end;
end;

function TForm1.ReadStringFromMailslot:String;
var
 MessageSize:DWORD;
begin
 GetMailslotInfo(ServerMailslotHandle,nil,MessageSize,nil,nil);
 if MessageSize=MAILSLOT_NO_MESSAGE then
  begin
   Result:='';
   Exit;
  end;
 SetLength(Result,Round(MessageSize/2));
 ReadFile(ServerMailslotHandle,Result[1],MessageSize,MessageSize,nil);
end;

procedure TForm1.GoToForeground;
var
 Info:TAnimationInfo;
 Animation:Boolean;
begin
 Info.cbSize:=SizeOf(TAnimationInfo);
 Animation:=SystemParametersInfo(SPI_GETANIMATION,SizeOf(Info),@Info,0);
 if Animation then
  begin
   Info.iMinAnimate:=0;
   SystemParametersInfo(SPI_SETANIMATION,SizeOf(Info),@Info,0);
  end;
 if not IsIconic(Application.Handle) then Application.Minimize;
 Application.Restore;
 if Animation then
  begin
   Info.iMinAnimate:=1;
   SystemParametersInfo(SPI_SETANIMATION,SizeOf(Info),@Info,0);
  end;
end;

procedure TForm1.WMDROPFILES(var Message:TWMDROPFILES);
var
 Files:Longint;
 I,J,ans,snum:Integer;
 Buffer:array[0..MAX_PATH] of Char;
 FL:TStringList;
 dont_ask:Boolean;
begin
 Files:=DragQueryFile(Message.Drop,$FFFFFFFF,nil,0);
 StopPlaying;
 Form2.ClearPlaylist;
 dont_ask:=False;
 Form12.EWriteLog('Зарегистрирован сброс файлов');
 Form12.EWriteLog('Место: Главное окно');
 if Files=0 then Form12.EWriteLog('Файлы не обнаружены! Что-то пошло не так?')
 else Form12.EWriteLog('Обнаружены файлы:');
 for I := 0 to Files - 1 do
  begin
   DragQueryFile(Message.Drop,I,@Buffer,SizeOf(Buffer));
   Form12.EWriteLog('- '+Buffer);
   if FileExists(Buffer) then
    if (WideLowerCase(ExtractFileExt(Buffer))='.m3u') or
       (WideLowerCase(ExtractFileExt(Buffer))='.m3u8') then
     Form2.PlaylistOpen(Buffer)
    else if (WideLowerCase(ExtractFileExt(Buffer))='.cue') then
     Form2.PlaylistOpen(Buffer,ptCUE)
    else
     begin
      if IsValidExt(Buffer) then
       Form2.PlaylistAddSong(Buffer,False,True);
     end
   else if DirectoryExists(Buffer) then
    begin
     FL:=TStringList.Create;
     if dont_ask=False then
      ans:=MessageDlg('Открыть файлы в подпапках (если они есть)?',mtConfirmation,[mbYes,mbNo],0);
     if ans=mrYes then ScanDir(Buffer,'',FL,True)
     else ScanDir(Buffer,'',FL,False);
     dont_ask:=True;
     if FL.Count>0 then
      for J:= 0 To FL.Count-1 Do
       begin
        if IsValidExt(FL.Strings[J]) then
         Form2.PlaylistAddSong(FL.Strings[J],False,True);
       end;
    end;
  end;
 Form2.CalcTotalDuration;
 if N14.Checked then snum:=Form2.ListView1.Items.Count-1
 else snum:=0;
 PlayFileByNum(snum);
 DragFinish(Message.Drop);
 Form12.EWriteLog('');
end;

procedure TForm1.WMCommandArrived(var Message:TMessage);
var
 Letter:String;
begin
 GoToForeground;
 Letter:=ReadStringFromMailslot;
 Form12.EWriteLog('Зарегистрирована попытка запустить вторую копию Mplayer');
 while Letter<>'' do
  begin
   case Letter[1] of
    'o':
     begin
      Form12.EWriteLog('Принято сообщение от второй копии: ' + Letter);
      ArrivedParamString:=Letter;
      OpenArrivedFiles;
     end;
    'c':
     begin
      Form12.EWriteLog('Принято сообщение от второй копии: ' + Letter);
      Form12.Show;
      Form12.ParseCommands(Copy(Letter,3,Length(Letter)-2));
     end;
   end;
   Letter:=ReadStringFromMailslot;
  end;
 Form12.EWriteLog('');
end;

procedure TForm1.WMHotKeyHandler(var Message:TMessage);
var
 idHotKey:Integer;
 fuModifiers:Word;
 uVirtKey:Word;
begin
 idHotkey:=Message.wParam;
 fuModifiers:=LOWORD(Message.lParam);
 uVirtKey:=HIWORD(Message.lParam);
 HotKeyEngine(fuModifiers,uVirtKey);
 inherited;
end;

procedure TForm1.StopPlaying;
begin
 StopFile;
 Playing:=False;
 Label1.Caption:='0:00:00';
 Application.Title:=APP_NAME;
 PosBar1.Position:=PosBar1.Min;
end;

procedure TForm1.PlayFileByNum(Num:Integer=0;Stop:Boolean=False);
begin
 if (Num>-1) and (Form2.ListView1.Items.Count>0) then
  begin
   if Stop and (Num=CurSongNum) then Exit;
   Form2.ListView1.ItemIndex:=Num;
   CurSongNum:=Num;
   Form2.PlaySelectedSong(Stop);
  end;
end;

procedure TForm1.SetTitleCaption(CPT:String);
var
 mc:TStringList;
 tmp:String;
 i:Integer;
begin
 Label5.Caption:=CPT;
 Label5.Hint:=CPT;
 if Length(CPT)>40 then Label5.ScrollType:=RMS1.ScrollType
 else Label5.ScrollType:=RMS2.ScrollType;
 if MinecraftMacromodHook then
  begin
   mc:=TStringList.Create;
   tmp:=CPT;
   if Length(tmp)>0 then
    begin
     i:=0;
     repeat
      i:=i+1;
      until tmp[i]='.';
     Delete(tmp,1,i+1);
     end;
   mc.Add('$${');
   mc.Add(' @&sname="'+tmp+'";');
   mc.Add('}$$');
   mc.SaveToFile('C:\Users\SmseR\.mc4ep_beta\instances\altiore\minecraft\liteconfig\common\macros\Mplayer_Songname_Data.txt');
   FreeAndNil(mc);
  end;
end;

function TForm1.InvertColor(C:TColor):TColor;
var
 CR,CG,CB:Byte;
begin
 CR:=GetRValue(C);
 CG:=GetGValue(C);
 CB:=GetBValue(C);
 CR:=255-CR;
 CG:=255-CG;
 CB:=255-CB;
 Result:=RGB(CR,CG,CB);
end;

procedure TOcilloScopeThread.DrawOcilloScope;
var
 Data:TWaveData;
begin
 if (Playing) and (SpecMode=4) then
  begin
   BASS_ChannelGetData(MediaFile,@Data,2048);
   OcilloScope.Draw(Form1.PaintBox1.Canvas.Handle,Data,0,Trunc(Form1.PaintBox1.Height/2));
  end;
end;

procedure TOcilloScopeThread.Execute;
begin
 while True do
  begin
   if OcilloFPSLimit>0 then
    begin
     Synchronize(DrawOcilloScope);
     Sleep(OcilloFPSLimit); // 50 FPS
    end
   else Sleep(1);
  end;
end;

function GetBitrate(Handle:HSTREAM):Integer;
var
 L:Int64;
 T:Double;
begin
 T:=BASS_ChannelBytes2Seconds(Handle,BASS_ChannelGetLength(Handle,BASS_POS_BYTE));
 L:=BASS_StreamGetFilePosition(Handle,BASS_FILEPOS_END);
 Result:=Trunc(L/(125*T)+0.5);
end;

function GetConvertedBitrate(Handle:HSTREAM;var Metrics:TMetrics):Extended;
begin
 Result:=GetBitrate(Handle);
 if Result>1073741823 then
  begin
   Result:=Result/(1024*1024*1024);
   Metrics:=Tbyte;
   Exit;
  end
 else if Result>1048575 then
  begin
   Result:=Result/(1024*1024);
   Metrics:=Gbyte;
   Exit;
  end
 else if Result>1023 then
  begin
   Result:=Result/(1024);
   Metrics:=Mbyte;
   Exit;
  end
 else
  begin
   Metrics:=kbyte;
   Exit;
  end
end;

procedure TForm1.LaunchCheckParams;
var
 cmd:String;
 i:Integer;
begin
 if ParamCount>0 then
  begin
   if not ParamStrContainFiles then
    begin
     cmd:='';
     for i:= 1 To ParamCount Do
      begin
       cmd:=cmd+' '+ParamStr(i);
      end;
     Form12.Show;
     Form12.ParseCommands(cmd);
    end
   else LaunchOpen;
  end;
end;

procedure TForm1.LaunchOpen;
var
 i,j,ans,snum:Integer;
 dont_ask:Boolean;
 FL:TStringList;
begin
 dont_ask:=False;
 if ParamCount=1 then
  begin
   if (WideLowerCase(ExtractFileExt(ParamStr(1)))='.m3u') or
      (WideLowerCase(ExtractFileExt(ParamStr(1)))='.m3u8') then
    Form2.PlaylistOpen(ParamStr(1))
   else if (WideLowerCase(ExtractFileExt(ParamStr(1)))='.cue') then
    Form2.PlaylistOpen(ParamStr(1),ptCUE)
   else
    begin
     if IsValidExt(ParamStr(1)) then
      Form2.PlaylistAddSong(ParamStr(1),False,True)
     else if DirectoryExists(ParamStr(1)) then
      begin
       FL:=TStringList.Create;
       if dont_ask=False then
        ans:=MessageDlg('Открыть файлы в подпапках (если они есть)?',mtConfirmation,[mbYes,mbNo],0);
       if ans=mrYes then ScanDir(ParamStr(1),'',FL,True)
       else ScanDir(ParamStr(1),'',FL,False);
       dont_ask:=True;
       if FL.Count>0 then
        for j:= 0 To FL.Count-1 Do
         begin
          if IsValidExt(FL.Strings[j]) then
           Form2.PlaylistAddSong(FL.Strings[j],False,True);
         end;
      end;
     Form2.CalcTotalDuration;
     if N14.Checked then snum:=Form2.ListView1.Items.Count-1
     else snum:=0;
     PlayFileByNum(snum);
    end;
  end
 else if ParamCount>0 then
  begin
   for i:= 1 To ParamCount Do
    begin
     if IsValidExt(ParamStr(i)) then
      Form2.PlaylistAddSong(ParamStr(i),False,True)
     else if DirectoryExists(ParamStr(i)) then
      begin
       FL:=TStringList.Create;
       if dont_ask=False then
        ans:=MessageDlg('Открыть файлы в подпапках (если они есть)?',mtConfirmation,[mbYes,mbNo],0);
       if ans=mrYes then ScanDir(ParamStr(i),'',FL,True)
       else ScanDir(ParamStr(i),'',FL,False);
       dont_ask:=True;
       if FL.Count>0 then
        for j:= 0 To FL.Count-1 Do
         begin
          if IsValidExt(FL.Strings[j]) then
           Form2.PlaylistAddSong(FL.Strings[j],False,True);
         end;
      end;
    end;
   Form2.CalcTotalDuration;
   if N14.Checked then snum:=Form2.ListView1.Items.Count-1
   else snum:=0;
   PlayFileByNum(snum);
  end;
end;

procedure TForm1.OpenArrivedFiles;
var
 i,j,ans,snum:Integer;
 dont_ask:Boolean;
 FL:TStringList;
begin
 dont_ask:=False;
 Form2.ClearPlaylist;
 if ArrivedParamCount=1 then
  begin
   if (WideLowerCase(ExtractFileExt(ArrivedParamStr(1)))='.m3u') or
      (WideLowerCase(ExtractFileExt(ArrivedParamStr(1)))='.m3u8') then
    Form2.PlaylistOpen(ArrivedParamStr(1))
   else if (WideLowerCase(ExtractFileExt(ArrivedParamStr(1)))='.cue') then
    Form2.PlaylistOpen(ArrivedParamStr(1),ptCUE)
   else
    begin
     if IsValidExt(ArrivedParamStr(1)) then
      Form2.PlaylistAddSong(ArrivedParamStr(1),False,True)
     else if DirectoryExists(ArrivedParamStr(1)) then
      begin
       FL:=TStringList.Create;
       if dont_ask=False then
        ans:=MessageDlg('Открыть файлы в подпапках (если они есть)?',mtConfirmation,[mbYes,mbNo],0);
       if ans=mrYes then ScanDir(ArrivedParamStr(1),'',FL,True)
       else ScanDir(ArrivedParamStr(1),'',FL,False);
       dont_ask:=True;
       if FL.Count>0 then
        for j:= 0 To FL.Count-1 Do
         begin
          if IsValidExt(FL.Strings[j]) then
           Form2.PlaylistAddSong(FL.Strings[j],False,True);
         end;
      end;
     Form2.CalcTotalDuration;
     if N14.Checked then snum:=Form2.ListView1.Items.Count-1
     else snum:=0;
     PlayFileByNum(snum);
    end;
  end
 else if ArrivedParamCount>0 then
  begin
   for i:= 1 To ArrivedParamCount Do
    begin
     if IsValidExt(ArrivedParamStr(i)) then
      Form2.PlaylistAddSong(ArrivedParamStr(i),False,True)
     else if DirectoryExists(ArrivedParamStr(i)) then
      begin
       FL:=TStringList.Create;
       if dont_ask=False then
        ans:=MessageDlg('Открыть файлы в подпапках (если они есть)?',mtConfirmation,[mbYes,mbNo],0);
       if ans=mrYes then ScanDir(ArrivedParamStr(i),'',FL,True)
       else ScanDir(ArrivedParamStr(i),'',FL,False);
       dont_ask:=True;
       if FL.Count>0 then
        for j:= 0 To FL.Count-1 Do
         begin
          if IsValidExt(FL.Strings[j]) then
           Form2.PlaylistAddSong(FL.Strings[j],False,True);
         end;
      end;
    end;
   Form2.CalcTotalDuration;
   if N14.Checked then snum:=Form2.ListView1.Items.Count-1
   else snum:=0;
   PlayFileByNum(snum);
  end;
end;

procedure TForm1.OpenFile;
var
 snum:Integer;
 ext:String;
begin
 if OpenDialog1.Execute then
  begin
   if OpenDialog1.Files.Count=1 then
    begin
     ext:=WideLowerCase(ExtractFileExt(OpenDialog1.Files.Strings[0]));
     if (ext='.m3u') or
        (ext='.m3u8') then
      Form2.PlaylistOpen(OpenDialog1.Files.Strings[0])
     else if ext='.cue' then
      Form2.PlaylistOpen(OpenDialog1.Files.Strings[0],ptCUE)
     else
      begin
       Form2.ClearPlaylist;
       Form2.FillPlaylist;
       PlayFileByNum;
      end;
    end
   else
    begin
     Form2.ClearPlaylist;
     Form2.FillPlaylist;
     if N14.Checked then snum:=Form2.ListView1.Items.Count-1
     else snum:=0;
     PlayFileByNum(snum);
    end;
  end;
end;

procedure TForm1.OpenURL;
var
 tpath:String;
begin
 if Form5.ShowModal=mrOk then
  begin
   tpath:=Form5.Edit1.Text;
   if LowerCase(ExtractFileExt(tpath))='.m3u' then
    Form2.PlaylistOpenByURL(tpath)
   else
    begin
     MediaFilePath:=tpath;
     Form2.ClearPlaylist;
     Form2.PlaylistAddSong(MediaFilePath);
     PlayFileByNum(0);
    end;
  end;
end;

function TForm1.CalcSIG(Rq:String):String;
begin
 Result:=AnsiLowerCase(MD5(Rq + VKSecret));
end;

procedure TForm1.OpenVKPlaylist;
var
 VKrespRAW,VKurl,VKid,VKsig:String;
 SongsCount,snum:Integer;
 SongList,VKName,SongCount:TStringList;
 SongURL,vkapiquery:String;
 i:Cardinal;
 TagsReady:Boolean;
begin
 if Assigned(Form6)=False then
  Form6:=TForm6.Create(Self);
 if VKAuth=False then
  if VKPretendOfficial then
   Form7.ShowModal('https://oauth.vk.com/token?grant_type=password&scope=nohttps,audio&client_id=2274003&client_secret=hHbZxrka2uZ6jB1inYsH&username=+79060621683&password=akfnnbPony1234')
  else
   Form7.ShowModal('https://oauth.vk.com/authorize?client_id=3566040&redirect_uri=https://oauth.vk.com/blank.html&display=popup&scope=8&response_type=token&v=5.80');
 if VKAuth then
  if Form6.ShowModal=mrOK then
   begin
    VKurl:=Form6.Edit1.Text;
    if Copy(VKurl,1,8)='https://' then
     Delete(VKurl,5,1);
    if (Copy(VKurl,1,19)='http://vk.com/audio') or (Copy(VKurl,1,23)='http://www.vk.com/audio') then
     begin
      if Copy(VKurl,15,6)='audios' then
       VKid:=Copy(VKurl,21,Length(VKurl)-20)
      else
       VKid:=VKDefaultID;
      vkapiquery:='audio.getCount?owner_id='+VKid+'&v=5.80&access_token='+VKAccessToken;
      if LogVKAPIToConsole then
       begin
        Form12.EWriteLog('--VKAPI--');
        Form12.EWriteLog('Запрос: ' + vkapiquery);
       end;
      VKrespRAW:=HTTP1.Get('https://api.vk.com/method/' + vkapiquery);
      if LogVKAPIToConsole then
       begin
        Form12.EWriteLog('Ответ:');
        Form12.ERawWriteLog(VKrespRAW);
        Form12.EWriteLog('--VKAPI--');
       end;
      SongCount:=TStringList.Create;
      SongCount.Text:=VKrespRAW;
      if Copy(SongCount.Strings[0],3,8)='response' then
       SongsCount:=StrToInt(Copy(SongCount.Strings[0],13,Length(SongCount.Strings[0])-13))
      else
       SongsCount:=0;
      if SongsCount>0 then
       begin
        vkapiquery:='audio.get?owner_id='+VKid+'&need_user=0&count='+IntToStr(SongsCount)+'&v=5.80&access_token='+VKAccessToken;
        if LogVKAPIToConsole then
         begin
          Form12.EWriteLog('--VKAPI--');
          Form12.EWriteLog('Запрос: ' + vkapiquery);
         end;
        VKrespRAW:=HTTP1.Get('https://api.vk.com/method/' + vkapiquery);
        if LogVKAPIToConsole then
         begin
          Form12.EWriteLog('Ответ:');
          Form12.ERawWriteLog(VKrespRAW);
          Form12.EWriteLog('--VKAPI--');
         end;
        SongList:=TStringList.Create;
        SongList.Text:=VKrespRAW;
        Form2.ClearPlaylist;
        Form8.ProgressBar1.Max:=SongList.Count-1;
        Form8.Show;
        TagsReady:=True;
        for i:= 0 To SongList.Count-1 Do
         begin
          Form8.ProgressBar1.Position:=i;
          Application.ProcessMessages;
          if TagsReady then
           begin
            SongInfo.Arti:='';
            SongInfo.Title:='';
            SongInfo.Album:='';
            SongInfo.Duration:=0;
            SongInfo.AddThis:=False;
            TagsReady:=False;
           end;
          if Copy(SongList.Strings[i],4,8)='<artist>' then
           begin
            SongInfo.Arti:=Copy(SongList.Strings[i],12,Length(SongList.Strings[i])-20);
           end;
          if Copy(SongList.Strings[i],4,7)='<title>' then
           begin
            SongInfo.Title:=Copy(SongList.Strings[i],11,Length(SongList.Strings[i])-18);
           end;
          if Copy(SongList.Strings[i],4,10)='<duration>' then
           begin
            SongInfo.Duration:=StrToInt(Copy(SongList.Strings[i],14,Length(SongList.Strings[i])-24))/(60*60*24);
            SongInfo.AddThis:=True;
           end;
          if Copy(SongList.Strings[i],4,5)='<url>' then
           begin
            SongURL:=Copy(SongList.Strings[i],9,Length(SongList.Strings[i])-14);
            Form2.PlaylistAddSong(SongURL,True,True);
            TagsReady:=True;
           end;
         end;
        Form8.Close;
        Form2.CalcTotalDuration;
        if N14.Checked then snum:=Form2.ListView1.Items.Count-1
        else snum:=0;
        PlayFileByNum(snum);
       end
      else
       ShowMessage('Нет ни одной песни');
     end;
   end;
end;

procedure TForm1.PlayFile(Stop:Boolean=False;ChannelAlreadySetUp:Boolean=False);
var
{PTags:Pointer;
Tags:^TAG_ID3;}
 Bitrate:Extended;
 Metrics:TMetrics;
 tmpStr,mts:String;
begin
 if not ChannelAlreadySetUp then
  begin
   BASS_ChannelStop(MediaFile);
   BASS_StreamFree(MediaFile);
   BASS_MusicFree(MediaFile);
  end;
 ABreset;
 if not ChannelAlreadySetUp then
  begin
   if (Copy(MediaFilePath,1,7)='http://') or (Copy(MediaFilePath,1,8)='https://') or (Copy(MediaFilePath,1,6)='ftp://') then
    MediaFile:=BASS_StreamCreateURL(PChar(MediaFilePath),0,BASS_UNICODE,nil,nil)
   else
    begin
     MediaFile:=BASS_StreamCreateFile(False,PChar(MediaFilePath),0,0,BASS_UNICODE);
     if MediaFile=0 then
      MediaFile:=BASS_MusicLoad(False,PChar(MediaFilePath),0,0,BASS_MUSIC_RAMP or BASS_MUSIC_PRESCAN or BASS_UNICODE,1);
    end;
  end;
 Form3.ChangeDevice(Form3.ComboBox1.ItemIndex+1,True);
 if not Stop then BASS_ChannelPlay(MediaFile,not ChannelAlreadySetUp);
 if Playing then
  UpdateStatsPlayedTime;
 Playing:=not Stop;
 BASS_ChannelGetInfo(MediaFile,MediaInfo);
 Bitrate:=GetConvertedBitrate(MediaFile,Metrics);
 Label4.Caption:='Частота: '+IntToStr(MediaInfo.freq)+' Гц'+#13+'Каналы: '+IntToStr(MediaInfo.chans)+#13+'Битрейт: ';
 cfrc:=MediaInfo.freq;
 if Frac(Bitrate)=0 then
  Label4.Caption:=Label4.Caption+FloatToStr(Bitrate)
 else
  Label4.Caption:=Label4.Caption+Format('%f',[Bitrate]);
 if Metrics=Tbyte then
  Label4.Caption:=Label4.Caption+' Тбит/сек'
 else if Metrics=Gbyte then
  Label4.Caption:=Label4.Caption+' Гбит/сек'
 else if Metrics=Mbyte then
  Label4.Caption:=Label4.Caption+' Мбит/сек'
 else if Metrics=kbyte then
 Label4.Caption:=Label4.Caption+' кбит/сек';
 {PTags:=BASS_ChannelGetTags(MediaFile,BASS_TAG_ID3);
 Tags:=PTags;
 SetTitleCaption(Tags.artist + ' - ' + Tags.title);}
 //tmpStr:=UTF8ToString(TAGS_Read(MediaFile,'%ARTI')) + ' - ' + UTF8ToString(TAGS_Read(MediaFile,'%TITL'));
 tmpStr:=GetSongArtist(CurSongNum) + ' - ' + GetSongName(CurSongNum);
 SetTitleCaption(IntToStr(Form2.ListView1.ItemIndex+1) + '. ' + tmpStr);
 if AppLoaded then
  begin
   if Stop then
    begin
     tmpOSDtext:=tmpStr;
     StartedFirstTime:=True;
    end
   else FormOSD.ShowOSDText(tmpStr);
  end
 else
  begin
   ShowOSDNeeded:=True;
   tmpOSDtext:=tmpStr;
  end;
 PosBar1.Max:=SecondsToIntValue(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetLength(MediaFile,BASS_POS_BYTE)));
 //PosBar1.Position:=PosBar1.Min;
 mts:=GetMetaKey(CurSongNum,'Start');
 if mts='' then
  RewExact(0)
 else
  RewExact(CueIndexToSeconds(mts));
 Label2.Caption:=MyTimeToStr(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetLength(MediaFile,BASS_POS_BYTE))/(60*60*24));
 Form3.ApplyAllSettings;
 if not ChannelAlreadySetUp then
  Form16.AddHistory(MediaFilePath);
 Stats.PlayedTraxThisRun:=Stats.PlayedTraxThisRun+1;
 Stats.PlayedTraxTotal:=Stats.PlayedTraxTotal+1;
 if GTC64loaded then
  PTstamp:=GetTickCount64
 else
  PTstamp:=GetTickCount;
 TaskBar1.ProgressMaxValue:=PosBar1.Max;
 //TaskBar1.Buttons.TaskButton2.IconId:=1;
 //TaskBar1.OIconID:=2;
 TaskBar1.OverlayIcon:=IPl.Picture.Icon;
 TaskBar1.ProgressState:=TTaskBarProgressState.Normal;
 {TB.ProgressMax:=PosBar1.Max;
 TB.Buttons.TaskButton2.IconId:=1;
 TB.OIconID:=2;
 TB.ProgressState:=TaskBarW7.TBPF_NORMAL;}
end;

procedure TForm1.StopFile;
begin
 BASS_ChannelStop(MediaFile);
 BASS_ChannelSetPosition(MediaFile,0,BASS_POS_BYTE);
 if Playing then
  UpdateStatsPlayedTime;
 TaskBar1.ProgressState:=TTaskBarProgressState.None;
 TaskBar1.OverlayIcon:=nil;
 {TB.Buttons.TaskButton2.IconId:=2;
 TB.OIconID:=-1;
 TB.ProgressState:=TaskBarW7.TBPF_NOPROGRESS;}
end;

procedure TForm1.PausePlay;
var
 snum:Integer;
begin
 if Form2.ListView1.Items.Count=0 then Exit;
 if Playing then
  begin
   BASS_ChannelPause(MediaFile);
   UpdateStatsPlayedTime;
   Playing:=False;
   TaskBar1.ProgressState:=TTaskBarProgressState.Paused;
   TaskBar1.OverlayIcon:=IPa.Picture.Icon;
   {TB.Buttons.TaskButton2.IconId:=2;
   TB.OIconID:=1;
   TB.ProgressState:=TaskBarW7.TBPF_PAUSED;}
  end
 else
  begin
   if StartedFirstTime then
    begin
     FormOSD.ShowOSDText(tmpOSDtext);
     StartedFirstTime:=False;
    end;
   BASS_ChannelPlay(MediaFile,False);
   if GTC64loaded then
    PTstamp:=GetTickCount64
   else
    PTstamp:=GetTickCount;
   Playing:=True;
   TaskBar1.ProgressState:=TTaskBarProgressState.Normal;
   TaskBar1.OverlayIcon:=IPl.Picture.Icon;
   {TB.Buttons.TaskButton2.IconId:=1;
   TB.OIconID:=2;
   TB.ProgressState:=TaskBarW7.TBPF_NORMAL;}
  end;
 if MediaFile=0 then
  if Form2.ListView1.Items.Count>0 then
   begin
    if N14.Checked then snum:=Form2.ListView1.Items.Count-1
    else snum:=0;
    PlayFileByNum(snum);
   end;
end;

procedure TForm1.ABrepeat;
var
 Buf:Int64;
begin
 if Playing then
  if ABstage=0 then
   begin
    PointA:=BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE);
    ABstage:=1;
    Label_A.Caption:='A: ' + TimeToStr(BASS_ChannelBytes2Seconds(MediaFile,PointA)/(60*60*24));
    Label_A.Visible:=True;
    S_PointA.Left:=GetMarkPos(PointA);
    S_PointA.Visible:=True;
   end
  else if ABstage=1 then
   begin
    PointB:=BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE);
    if PointA>PointB then
     begin
      Buf:=PointA;
      PointA:=PointB;
      PointB:=Buf;
      Label_A.Caption:='A: ' + TimeToStr(BASS_ChannelBytes2Seconds(MediaFile,PointA)/(60*60*24));
      S_PointA.Left:=GetMarkPos(PointA);
     end;
    ABstage:=2;
    Label_B.Caption:='B: ' + TimeToStr(BASS_ChannelBytes2Seconds(MediaFile,PointB)/(60*60*24));
    Label_B.Visible:=True;
    S_PointB.Left:=GetMarkPos(PointB);
    S_PointB.Visible:=True;
   end
  else if ABstage=2 then ABreset;
end;

procedure TForm1.ABreset;
begin
 ABstage:=0;
 PointA:=0;
 PointB:=0;
 Label_A.Visible:=False;
 Label_B.Visible:=False;
 S_PointA.Visible:=False;
 S_PointB.Visible:=False;
 PosBar1.Repaint;
end;

procedure TForm1.Action1Execute(Sender: TObject);
begin
 PrevButton;
end;

procedure TForm1.Action2Execute(Sender: TObject);
begin
 PausePlay;
end;

procedure TForm1.Action3Execute(Sender: TObject);
begin
 StopPlaying;
end;

procedure TForm1.Action4Execute(Sender: TObject);
begin
 Form2.PlayNextSong;
end;

procedure TForm1.AfterPlaybackStopTask;
var
 snum:Integer;
 ei:TShellExecuteInfoA;
begin
 Form1.UpdateStatsPlayedTime;
 if N18.Checked then
  begin
   TotalTerminate;
  end
 else if N19.Checked then
  ShellExecute(Form1.Handle,'','shutdown',' -s -t 00','',SW_SHOWNORMAL)
 else if N21.Checked then
  begin
   ShellExecute(Form1.Handle,'',PChar(LaunchProgram),PChar(LaunchProgramParams),'',SW_SHOWNORMAL);
   if Form14.CheckBox1.Checked then TotalTerminate;
   N17.Checked:=True;
   N18.Checked:=False;
   N19.Checked:=False;
   N21.Checked:=False;
  end
 else if N23.Checked then
  begin
   if not Form13.CheckBox1.Checked then
    begin
     Form12.Show;
     Form12.Edit1.SetFocus;
    end;
   Form12.ParseCommands(PerformCommand);
  end;
 TaskBar1.ProgressState:=TTaskBarProgressState.None;
 TaskBar1.OverlayIcon:=nil;
 {TB.OIconID:=-1;
 TB.Buttons.TaskButton2.IconId:=2;
 TB.ProgressState:=TaskBarW7.TBPF_NOPROGRESS;}
 if N14.Checked then snum:=Form2.ListView1.Items.Count-1
 else snum:=0;
 PlayFileByNum(snum,True);
 StopPlaying;
end;

procedure TForm1.PrevButton;
var
 mts:String;
 mtss:Cardinal;
begin
 mts:=GetMetaKey(CurSongNum,'Start');
 if mts='' then
  mtss:=0
 else
  mtss:=CueIndexToSeconds(mts);
 if BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE))<(mtss+2) then
  Form2.PlayPrevSong
 else
  begin
   RewExact(mtss);
   {Label1.Caption:='0:00:00';
   Application.Title:=APP_NAME + ' 0:00:00/' + Label2.Caption;
   PosBar1.Position:=0;}
  end;
end;

procedure TForm1.SwapSpecMode;
begin
 SetSpecMode((SpecMode + 1) mod SPEC_MODES_COUNT);
end;

function TForm1.SetSpecMode(ID:Byte):Boolean;
begin
 Result:=(ID>=0) and (ID<SPEC_MODES_COUNT);
 if Result then
  begin
   SpecMode := ID;
   if SpecMode = 2 then
    SpecPos := 0;
   FillChar(SpecBuf^, SPECWIDTH * SPECHEIGHT, 0);
   Form3.ComboBox3.ItemIndex:=ID;
   SpecModeMenu.Items.Items[ID].Checked:=True;
  end;
end;

function TForm1.LoadGTC64func:Boolean;
var
 hndDLLHandle:THandle;
begin
 try
  hndDLLHandle:=LoadLibrary(kernel32);
  if hndDLLHandle<>0 then
   begin
    @GetTickCount64:=GetProcAddress(hndDLLHandle,'GetTickCount64');
    Result:=addr(GetTickCount64)<>nil;
   end
  else
   Result:=False;
 finally
  FreeLibrary(hndDLLHandle);
 end;
end;

procedure TForm1.SaveStats;
begin
 AssignFile(StatsFile,StatsPath);
 Rewrite(StatsFile);
 Write(StatsFile,Stats);
 CloseFile(StatsFile);
end;

procedure TForm1.LoadStats;
var
 tmpTTR,tmpTT:Int64;
begin
 if FileExists(StatsPath) then
  begin
   AssignFile(StatsFile,StatsPath);
   Reset(StatsFile);
   if not AppLoaded then
    begin
     tmpTTR:=Stats.PlayedTraxThisRun;
     tmpTT:=Stats.PlayedTraxTotal;
    end;
   Read(StatsFile,Stats);
   CloseFile(StatsFile);
   if AppLoaded then Stats.PlayedTraxThisRun:=0
   else
    begin
     Stats.PlayedTraxThisRun:=tmpTTR;
     if tmpTT>0 then Stats.PlayedTraxTotal:=Stats.PlayedTraxTotal+tmpTT;
    end;
  end;
 Stats.PlayedTimeMSECThisRun:=0;
end;

procedure TForm1.ClearStats;
begin
 Stats.PlayedTimeMSECThisRun:=0;
 Stats.PlayedTimeMSECTotal:=0;
 Stats.PlayedTraxThisRun:=0;
 Stats.PlayedTraxTotal:=0;
 Stats.UptimeMSECTotal:=0;
 Stats.LaunchedTimesTotal:=0;
 Stats.ConsoleCmdsUsedTimesTotal:=0;
end;

procedure TForm1.UpdateStatsUptime;
var
 tempStamp:Int64;
begin
 if GTC64loaded then
  tempStamp:=GetTickCount64
 else
  tempStamp:=GetTickCount;
 Stats.UptimeMSECTotal:=Stats.UptimeMSECTotal+(tempStamp-LaunchTimeStamp);
 LaunchTimeStamp:=tempStamp;
end;

procedure TForm1.UpdateStatsPlayedTime;
var
 tempStamp:Int64;
begin
 if GTC64loaded then
  tempStamp:=GetTickCount64
 else
  tempStamp:=GetTickCount;
 Stats.PlayedTimeMSECThisRun:=Stats.PlayedTimeMSECThisRun+(tempStamp-PTstamp);
 PTstamp:=tempStamp;
end;

procedure WriteBASSPluginInfo(pinf:PBASS_PLUGININFO;fname:String);
var
 i:Integer;
 tmpn:String;
 stls:TStyles;
begin
 Form12.EWriteLog('');
 SetLength(stls,1);
 stls[0].Start:=23;
 stls[0].Length:=Length(fname);
 stls[0].Style:=[fsBold];
 stls[0].Color:=clGreen;
 Form12.EWriteLogStyleExtended('Загружен BASS плагин - ' + fname,stls);
 Form12.EWriteLog('Поддерживаемые форматы:');
 for i:= 0 to pinf.formatc-1 do
  Form12.EWriteLog(' - ' + pinf.formats[i].name + ' (' + pinf.formats[i].exts + ')');
 if pinf.formatc>0 then
  begin
   if pinf.formats[0].name='Free Lossless Audio Codec' then
    tmpn:='BASSFLAC'
   else if pinf.formats[0].name='Apple Lossless Audio Codec' then
    tmpn:='ALAC'
   else if pinf.formats[0].name='Opus' then
    tmpn:='OPUS'
   else
    tmpn:=pinf.formats[0].name;
  end
 else
  tmpn:='UNKNOWN';
 Form1.AddErrorLog('Загружен BASS плагин - ' + tmpn);
end;

procedure TForm1.LoadBASSPlugins;
var
 list:TStringList;
 i,C:Integer;
 tmp:HPLUGIN;
 pinf:PBASS_PLUGININFO;
begin
 list:=TStringList.Create;
 ScanDir(ProgDir+'plugins','*.dll',list,False);
 C:=list.Count;
 if C>0 then
  for i:= 0 to C-1 do
   begin
    tmp:=BASS_PluginLoad(PChar(list.Strings[i]),BASS_UNICODE);
    if tmp<>0 then
     begin
      pinf:=BASS_PluginGetInfo(tmp);
      WriteBASSPluginInfo(pinf,ExtractFileName(list.Strings[i]));
     end;
   end;
end;

procedure TForm1.AfterAppLoadTasks;
begin
 if MediaInfoUpdateNeeded then Form11.UpdateMediaInfo;
end;

procedure TForm1.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

procedure TForm1.WMXMouseButtonsHandler(var Message:TMessage);
begin
 case Message.LParamHi of
  32769: PrevButton;
  32770: Form2.PlayNextSong;
  46: if not Playing then PausePlay;
  47: if Playing then PausePlay;
  48: N20Click(Self);
 end;
 inherited;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
 StopPlaying;
end;

procedure TForm1.FormCreate(Sender: TObject);
const
 FOLDERID_RoamingAppData:TGUID='{3EB685DB-65F9-4CF6-A03A-E3EF65729F3D}';
begin
 InitErrorLog;
 CheckBASSVersion;
 ClearStats;
 Application.Title:=APP_NAME;
 AppClosing:=False;
 MediaInfoUpdateNeeded:=False;
 VKAuth:=False;
 VKNameGet:=False;
 CheckFileExt:=True;
 InitBASS;
 Rew:=False;
 MediaInfoLoaded:=MediaInfoDLL_Load(ExtractFilePath(Application.ExeName)+'\libs\MediaInfo.dll');
 if MediaInfoLoaded then
  begin
   MediaInfoHandle:=MediaInfo_New;
   MediaInfo1.Enabled:=True;
   MediaInfo1.Visible:=True;
  end;
 OcilloScope:=TOcilloScope.Create(PaintBox1.Width,PaintBox1.Height);
 OcilloScope.BackColor:=clBlack;
 OcilloScope.Pen:=RGB(0,255,0);
 OcilloScope.Mode:=0;
 OcilloScopeThread:=TOcilloScopeThread.Create(False);
 CommandsThread:=TCommandsThread.Create(False);
 MMKeysHandler:=TMMKeysHandler.Create(False);
 ProgDir:=ExtractFilePath(Application.ExeName);
 Randomize;
 ABreset;
 SetsPath:=ProgDir + SETTINGS_FILE_NAME;
 StatsPath:=ProgDir + STATS_FILE_NAME;
 {TB:=TaskBarW7.TTaskBar.Create(Form1);
 TB.Buttons.TaskButton1.Visible:=True;
 TB.Buttons.TaskButton2.Visible:=True;
 TB.Buttons.TaskButton3.Visible:=True;
 TB.Buttons.TaskButton4.Visible:=True;
 TB.ThumbnailClip.Left:=8;
 TB.ThumbnailClip.Top:=108;
 TB.ThumbnailClip.Right:=255;
 TB.ThumbnailClip.Bottom:=49;
 TB.ThumbnailClipEnabled:=True;
 TB.ImageList:=ImageList1;
 TB.Buttons.TaskButton1.IconId:=3;
 TB.Buttons.TaskButton2.IconId:=2;
 TB.Buttons.TaskButton3.IconId:=4;
 TB.Buttons.TaskButton4.IconId:=0;
 TB.Buttons.TaskButton1.OnClick:=Action1Execute;
 TB.Buttons.TaskButton2.OnClick:=Action2Execute;
 TB.Buttons.TaskButton3.OnClick:=Action3Execute;
 TB.Buttons.TaskButton4.OnClick:=Action4Execute;
 TB.OIconID:=-1; // Да бред, но иначе иконки на кнопках не появляются}
 TAGS_SetUTF8(True);
 DragAcceptFiles(Form1.Handle,True);
 Form1.Caption:=Form1.Caption+' '+APP_VERSION;
 if NON_PUBLIC then
  Form1.Caption:=Form1.Caption+' [НЕ ПУБЛИЧНАЯ ВЕРСИЯ]';
 RegisterHotKeys;
 IsVista:=CInfo.OS.VersionMajor>=6;
 GlobalFormats.DateSeparator:='.';
 GlobalFormats.TimeSeparator:=':';
 GlobalFormats.LongTimeFormat:='h:mm:ss';
 if IsVista then GTC64loaded:=LoadGTC64func;
 if GTC64loaded then
  LaunchTimeStamp:=GetTickCount64
 else
  LaunchTimeStamp:=GetTickCount;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
 PausePlay;
end;

procedure TForm1.N3Click(Sender: TObject);
begin
 Close;
end;

procedure TForm1.N2Click(Sender: TObject);
begin
 OpenFile;
end;

procedure TForm1.PlayPause1Click(Sender: TObject);
begin
 PausePlay;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var
 cpos:Int64;
begin
 if Playing then
  begin
   if ABstage>0 then
    if MarkCovered then NeededRepaint:=True
    else if NeededRepaint then
     begin
      PosBar1.Repaint;
      NeededRepaint:=False;
     end;
   if NeededInstantRepaintInNextItr then
    begin
     Itr:=Itr-1;
     if Itr=0 then
      begin
       PosBar1.Repaint;
       NeededInstantRepaintInNextItr:=False;
      end;
    end;
    begin
     if (Form3.CheckBox5.Checked) and (Form3.SpeedTrackBar.Position>0) and (speedprc>0) then
      begin
       cpos:=BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE);
       cpos:=Round(cpos/speedprc*100);
       Label1.Caption:=MyTimeToStr(BASS_ChannelBytes2Seconds(MediaFile,cpos)/(60*60*24));
      end
     else Label1.Caption:=MyTimeToStr(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE))/(60*60*24));
    end;
   Application.Title:=APP_NAME + ' ' + Label1.Caption + '/' + Label2.Caption;
   if MetaKeyExists(CurSongNum,'Start')<>-1 then DetermineCurSongNum;
   PosBar1.Position:=SecondsToIntValue(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)));
   if ABstage=2 then
    if BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)>=PointB then
     begin
      BASS_ChannelSetPosition(MediaFile,PointA,BASS_POS_BYTE);
      NeededInstantRepaintInNextItr:=True;
      Itr:=2;
     end;
   if (BASS_ChannelIsActive(MediaFile)=BASS_ACTIVE_STOPPED) or (BASS_ChannelIsActive(MediaFile)=BASS_ACTIVE_PAUSED) then
    begin
     if (BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE)=BASS_ChannelGetLength(MediaFile,BASS_POS_BYTE)) then
     if N7.Checked then
      begin
       BASS_ChannelPlay(MediaFile,True);
      end
     else if N13.Checked then
      begin
       if Form2.PlayNextSong=False then
        if N8.Checked then
         begin
          Form2.ListView1.ItemIndex:=0;
          Form2.PlaySelectedSong;
         end
        else
         begin
          Playing:=False;
          AfterPlaybackStopTask;
         end;
      end
     else if N14.Checked then
      begin
       if Form2.PlayPrevSong=False then
        if N8.Checked then
         begin
          Form2.ListView1.ItemIndex:=Form2.ListView1.Items.Count-1;
          Form2.PlaySelectedSong;
         end
        else
         begin
          Playing:=False;
          AfterPlaybackStopTask;
         end;
      end
     else if N15.Checked then
      begin
       if Form2.PlayRandomSong=False then
        if N8.Checked then
         begin
          Form2.ListView1.ItemIndex:=Form2.ListView1.Items.Count-1;
          Form2.PlaySelectedSong;
         end
        else
         begin
          Playing:=False;
          AfterPlaybackStopTask;
         end;
      end;
    end;
 end;
 Label3.Caption:='CPU: ' + Format('%f',[BASS_GetCPU]) + '%';
end;

procedure TForm1.PosBar1Change(Sender: TObject);
var
 bts,cpos:Int64;
begin
 if Rew then
  begin
   bts:=BASS_ChannelSeconds2Bytes(MediaFile,IntValueToSeconds(PosBar1.Position));
   BASS_ChannelSetPosition(MediaFile,bts,BASS_POS_BYTE);
   if MetaKeyExists(CurSongNum,'Start')<>-1 then DetermineCurSongNum;
   if (Form3.CheckBox5.Checked) and (Form3.SpeedTrackBar.Position>0) and (speedprc>0) then
    begin
     cpos:=BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE);
     cpos:=Round(cpos/speedprc*100);
     Label1.Caption:=MyTimeToStr(BASS_ChannelBytes2Seconds(MediaFile,cpos)/(60*60*24));
    end
   else Label1.Caption:=MyTimeToStr(BASS_ChannelBytes2Seconds(MediaFile,BASS_ChannelGetPosition(MediaFile,BASS_POS_BYTE))/(60*60*24));
  end;
 TaskBar1.ProgressValue:=PosBar1.Position;
 //TB.ProgressValue:=PosBar1.Position;
end;

procedure TForm1.PosBar1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbLeft then Rew:=True;
 if Button=mbLeft then
  PosBar1.Position:=DoSomeUnicornMagic(X,PosBar1.Width,PosBar1.Max);
end;

procedure TForm1.PosBar1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbLeft then Rew:=False;
end;

procedure TForm1.N6Click(Sender: TObject);
begin
 Form2.Show;
end;

procedure TForm1.N7Click(Sender: TObject);
begin
 N7.Checked:=not N7.Checked;
 if N8.Checked then N8.Checked:=False;
end;

procedure TForm1.N8Click(Sender: TObject);
begin
 N8.Checked:=not N8.Checked;
 if N7.Checked then N7.Checked:=False;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
 PrevButton;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
 Form2.PlayNextSong;
end;

procedure TForm1.N9Click(Sender: TObject);
begin
 Form3.Show;
end;

procedure TForm1.N13Click(Sender: TObject);
begin
 N13.Checked:=True;
end;

procedure TForm1.N14Click(Sender: TObject);
begin
 N14.Checked:=True;
end;

procedure TForm1.N15Click(Sender: TObject);
begin
 N15.Checked:=True;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
 Form4.Show;
end;

procedure TForm1.AB1Click(Sender: TObject);
begin
 ABrepeat;
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 ClosingTasks;
 AppClosing:=True;
end;

procedure TForm1.URL1Click(Sender: TObject);
begin
 OpenURL;
end;

procedure TForm1.VK1Click(Sender: TObject);
begin
 if TryVKImportAnyway then OpenVKPlaylist
 else MessageBox(Form1.Handle,'С 16 декабря 2016 года ВКонтакте отключили публичный доступ к API для аудио'+#13#13+'Подробнее тут: vk.com/dev/audio_api','Нипаслушать больше',MB_OK or MB_ICONINFORMATION or MB_RTLREADING);
end;

procedure TForm1.N17Click(Sender: TObject);
begin
 N17.Checked:=True;
 N18.Checked:=False;
 N19.Checked:=False;
 N21.Checked:=False;
 N23.Checked:=False;
end;

procedure TForm1.N18Click(Sender: TObject);
begin
 N17.Checked:=False;
 N18.Checked:=True;
 N19.Checked:=False;
 N21.Checked:=False;
 N23.Checked:=False;
end;

procedure TForm1.N19Click(Sender: TObject);
begin
 N17.Checked:=False;
 N18.Checked:=False;
 N19.Checked:=True;
 N21.Checked:=False;
 N23.Checked:=False;
end;

procedure TForm1.MVolumeTrackBarChange(Sender: TObject);
begin
 Form3.SetVolume(MVolumeTrackBar.Position);
end;

procedure TForm1.N20Click(Sender: TObject);
begin
 if not Form10.Visible then
  begin
   if InitRecord then
    begin
     Form10.Button1.Caption:='Начать запись';
     Form10.Button2.Enabled:=False;
     Form10.Button3.Enabled:=False;
     Form10.ComboBox1.Enabled:=True;
     Unit10.WaveStream:=TMemoryStream.Create;
     Unit10.Rec:=False;
     Unit10.RecTimer:=0;
     Form10.Timer1.Enabled:=True;
     Form10.Timer2.Enabled:=True;
     Form10.GetRecDevices;
     Form10.Show;
    end;
  end
 else Form10.Show;
end;

procedure TForm1.MediaInfo1Click(Sender: TObject);
begin
 if MediaInfoLoaded then Form11.Show;
end;

procedure TForm1.N21Click(Sender: TObject);
begin
 if Form14.ShowModal=mrOk then
  if FileExists(Form14.Edit1.Text) then
   begin
    LaunchProgram:=Form14.Edit1.Text;
    LaunchProgramParams:=Form14.Edit2.Text;
    N17.Checked:=False;
    N18.Checked:=False;
    N19.Checked:=False;
    N21.Checked:=True;
    N23.Checked:=False;
   end;
end;

procedure TForm1.N22Click(Sender: TObject);
begin
 Form12.Show;
 Form12.Edit1.SetFocus;
end;

procedure TForm1.N23Click(Sender: TObject);
begin
 if Form13.ShowModal=mrOk then
  begin
   PerformCommand:=Form13.Edit1.Text;
   N17.Checked:=False;
   N18.Checked:=False;
   N19.Checked:=False;
   N22.Checked:=False;
   N23.Checked:=True;
  end;
end;

procedure TForm1.N24Click(Sender: TObject);
begin
 AboutBox.Show;
end;

procedure TForm1.N25Click(Sender: TObject);
var
 tmp:String;
 i:Integer;
begin
 tmp:=Label5.Caption;
 if Length(tmp)>0 then
  begin
   i:=0;
   repeat
    i:=i+1;
   until tmp[i]='.';
   Delete(tmp,1,i+1);
   Clipboard.AsText:=tmp;
  end;
end;

procedure TForm1.N26Click(Sender: TObject);
begin
 Form16.Show;
 //TaskBar1.TaskBarButtons.Items[1].Hint:='Пауза';
 //TB.Buttons.TaskButton2.Caption:='Пауза';
end;

procedure TForm1.PaintBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbLeft then SwapSpecMode;
end;

procedure TForm1.MVolumeTrackBarMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbLeft then
  MVolumeTrackBar.Position:=DoSomeUnicornMagic(X,MVolumeTrackBar.Width,MVolumeTrackBar.Max);
end;

procedure TForm1.N27Click(Sender: TObject);
begin
 SetSpecMode(0);
end;

procedure TForm1.N28Click(Sender: TObject);
begin
 SetSpecMode(1);
end;

procedure TForm1.N29Click(Sender: TObject);
begin
 SetSpecMode(2);
end;

procedure TForm1.N30Click(Sender: TObject);
begin
 SetSpecMode(3);
end;

procedure TForm1.N31Click(Sender: TObject);
begin
 SetSpecMode(4);
end;

procedure TForm1.N32Click(Sender: TObject);
var
 tmpStrs:TStringList;
begin
 tmpStrs:=TStringList.Create;
 if Playing then
  Form1.UpdateStatsPlayedTime;
 Form1.UpdateStatsUptime;
 tmpStrs.Add('Общее время воспроизведения (за эту сессию): ' + MyTimeToStr(Stats.PlayedTimeMSECThisRun/(1000 * 60 * 60 * 24),True));
 tmpStrs.Add('Общее время воспроизведения (всего): ' + MyTimeToStr((Stats.PlayedTimeMSECTotal+Stats.PlayedTimeMSECThisRun)/(1000 * 60 * 60 * 24),True));
 tmpStrs.Add('Воспроизведено треков (за эту сессию): ' + IntToStr(Stats.PlayedTraxThisRun));
 tmpStrs.Add('Воспроизведено треков (всего): ' + IntToStr(Stats.PlayedTraxTotal));
 tmpStrs.Add('Общее время работы программы: ' + MyTimeToStr(Stats.UptimeMSECTotal/(1000 * 60 * 60 * 24),True));
 tmpStrs.Add('Количество запусков программы: ' + IntToStr(Stats.LaunchedTimesTotal));
 tmpStrs.Add('Использовано команд в консоли: ' + IntToStr(Stats.ConsoleCmdsUsedTimesTotal));
 MessageBox(Form1.Handle,PChar(tmpStrs.Text),'Статистика',MB_ICONINFORMATION or MB_OK);
 FreeAndNil(tmpStrs);
end;

procedure TForm1.N33Click(Sender: TObject);
begin
 Form17.Show;
end;

end.
