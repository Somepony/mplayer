unit Unit12;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DCPsha512, ShellAPI, JvComponentBase, JvComputerInfoEx, JclSysInfo,
  uFMOD, ExtCtrls, hashes, FuckDaRipprXM, BASS, IdBaseComponent,
  IdComponent, IdTCPServer, IdCustomHTTPServer, IdHTTPServer, BassWASAPI,
  AppEvnts, ComCtrls, Math, RemoteControlWebFace, UnitEnRu, VarInt, B64, tags, FantomenK,
  IdCustomTCPServer, System.JSON, IPPeerClient, REST.Client,
  Data.Bind.Components, Data.Bind.ObjectScope, JvBaseDlg, AtomCleaner;

type
  TCommandHandler=procedure(SubCommand:String);
  TExternalHandler=procedure(SubCommand:String); stdcall;

  TCommand=record
   Name:String;
   Handler:TCommandHandler;
   ShortDesc:String;
   LongDesc:String;
   ExternalProc:Boolean;
   ExternalHandler:TExternalHandler;
  end;

  TWindowInfo=record
   Name:String;
   Handle:Cardinal;
  end;

  TVar=record
   Name,Value:String;
  end;

  TStyle=record
   Start,Length:Integer;
   Style:TFontStyles;
   Color:TColor;
  end;

  TStyles=array of TStyle;

  TExtArr=array of array of Extended;

  TCustomChannels=array of HSTREAM;

  TForm12 = class(TForm)
    Edit1: TEdit;
    Timer1: TTimer;
    HTTPSrv: TIdHTTPServer;
    Timer2: TTimer;
    AE: TApplicationEvents;
    Memo1: TRichEdit;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    procedure EWriteLog(Str:String);
    procedure ERawWriteLog(Str:String);
    procedure EWriteLogStyle(Str:String;Style:TFontStyles;Color:TColor);
    procedure EWriteLogStyleExtended(Str:String;Styles:TStyles);
    procedure InitCommands;
    procedure RemakeSortedCmdList;
    function AddCommand(Name:String;Handler:TCommandHandler;ShortDesc,LongDesc:String;ExternalProc:Boolean=False;ExternalHandler:TExternalHandler=nil):Boolean; overload;
    function RemoveCommand(Name:String):Boolean;
    function GetCommandID(Cmd:String):Integer;
    function NormalizeSemicolons(RawCommand:String):String;
    function GetRawCommandsCount(RawCommand:String):Integer;
    function GetRawCommandPos(RawCommand:String;Num:Integer):Integer;
    function ExtRawCommand(RawCommand:String;Num:Integer):String;
    procedure ParseCommand(RawCommand:String;History:Boolean=False);
    procedure ParseCommands(RawCommand:String);
    function HistoryAlreadyExists(Cmd:String;var Pos:Byte):Boolean;
    procedure AddHistory(Cmd:String);
    procedure NextHistory;
    procedure PrevHistory;
    procedure CommandsAutorun;
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Timer1Timer(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure TABCommList;
    procedure AEMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure RESTRequest1AfterExecute(Sender: TCustomRESTRequest);
  private
    procedure WMDROPFILES(var Message:TWMDROPFILES); message WM_DROPFILES;
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
    function AddCommand(Cmd:TCommand):Boolean; overload;
  public
    { Public declarations }
  end;

  TWarmingThread=class(TThread)
   procedure Execute; override;
  end;

const
 CommandsBlacklist:array[0..12] of String=('test','removecmd','cmdtofile','dinfo','var','getcmdaddr','setcmdaddr','addcmd','rdinfo','riinfo','wadinfo','wasinfo','logvkapi');
 CONSOLE_VERSION='0.1.6 - Alpha';

var
  Form12: TForm12;
  Commands:array of TCommand;
  Unlocked:Boolean=False;
  SortedCmdList:TStringList;
  CommandsHistory:array[0..19] of String;
  HistoryLength:Byte=0;
  HistoryPos:Byte=0;
  ToFileFlag:Boolean=False;
  ToFile:TStringList;
  ToFilePath:String;
  TimerSeconds:Int64=0;
  TimerSeconds2:Int64=0;
  HashingInProgress:Boolean=False;
  RestoreWinVolFlag:Boolean=False;
  RestoreWinVolValue:Byte;
  WarmingThread:array of TWarmingThread;
  Cores:Integer;
  WarmingUp:Boolean=False;
  WindowList:array of TWindowInfo;
  CommandsCount:Integer;
  TAB_mod:Boolean=False;
  TAB_clist:array of String;
  TAB_cur:Integer;
  TAB_addition:String;
  LogVKAPIToConsole:Boolean=False;
  Vars:array of TVar;
  JSONCardData:WideString;
  CustomChannels:TCustomChannels;
  Fantom:Boolean=False;
  FantomChan:HSTREAM;

implementation
uses Unit1, Unit2, Unit3, Unit4, UnitOSD;

{$R *.dfm}

function GetVarNumByName(Name:String):Integer;
var
 i,C:Integer;
begin
 Result:=-1;
 C:=Length(Vars);
 if C>0 then
  for i:= 0 to C-1 do
   if Vars[i].Name=Name then
    begin
     Result:=i;
     Exit;
    end;
end;

function AddNewVar(Name:String):Integer;
begin
 if GetVarNumByName(Name)<>-1 then
  Result:=-1
 else
  begin
   Result:=Length(Vars);
   SetLength(Vars,Result+1);
   Vars[Result].Name:=Name;
   Vars[Result].Value:='';
  end;
end;

function DeleteVar(Name:String):Boolean;
var
 num,i,c:Integer;
begin
 Result:=False;
 num:=GetVarNumByName(Name);
 if num>-1 then
  begin
   C:=Length(Vars);
   for i:= num to C-2 do
    Vars[i]:=Vars[i+1];
   SetLength(Vars,C-1);
   Result:=True;
  end;
end;

function IsSchoolboy:Boolean;
begin
 Result:=(Screen.Width=1366) and (Screen.Height=768);
end;

function MakeLongDescStringForSetPlayDeviceCmd:String;
var
 c,i:Integer;
begin
 Result:='������� ���������� ��������������� (���� � ��� �� ���������).' + #13#13 + '�������������: setplaydevice [ID]' + #13 + '�������� ��� ID:';
 c:=Form3.ComboBox1.Items.Count;
 if c>0 then
  for i:= 0 To c-1 Do
   Result:=Result + #13 + IntToStr(i) + ' - ' + Form3.ComboBox1.Items.Strings[i];
end;

procedure TWarmingThread.Execute;
begin
 while not Terminated do;
end;

procedure TForm12.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

procedure TForm12.WMDROPFILES(var Message:TWMDROPFILES);
var
 Files:Longint;
 I,L:Integer;
 Buffer:array[0..MAX_PATH] of Char;
begin
 Files:=DragQueryFile(Message.Drop,$FFFFFFFF,nil,0);
 Edit1.Text:=Trim(Edit1.Text);
 for I := 0 to Files - 1 do
  begin
   DragQueryFile(Message.Drop,I,@Buffer,SizeOf(Buffer));
   L:=Length(Edit1.Text);
   if L>0 then
    Edit1.Text:=Edit1.Text+' "'+Buffer+'"'
   else
    Edit1.Text:=Edit1.Text+'"'+Buffer+'"';
  end;
 DragFinish(Message.Drop);
 Edit1.SelStart:=Length(Edit1.Text);
 Edit1.SelLength:=0;
end;

function MyTimeToStr(D:TDateTime;Msec:Boolean=False):String;
var
 days:Int64;
 h:Extended;
begin
 if D<1 then Result:=TimeToStr(D)
 else
  begin
   days:=Trunc(D);
   D:=D-days;
   h:=D*24;
   if h<10 then
    Result:=IntToStr(days) + ':0' + TimeToStr(D)
   else
    Result:=IntToStr(days) + ':' + TimeToStr(D);
  end;
 if Msec then
  begin
   D:=D-StrToTime(TimeToStr(D));
   D:=D*(1000 * 60 * 60 * 24);
   Result:=Result+'.'+IntToStr(Round(D));
  end;
end;

function SHA512(str:String):String;
var
 Digest:array[0..63] of Byte;
 hashm:TDCP_sha512;
 i:Byte;
begin
 Result:='';
 hashm:=TDCP_sha512.Create(Form12);
 hashm.Init;
 hashm.UpdateStr(str);
 hashm.Final(Digest);
 FreeAndNil(hashm);
 for i:= 0 To 63 Do
  Result:=Result+IntToHex(Digest[i],2);
end;

function InCommandsBlacklist(Name:String):Boolean;
var
 i,L:Integer;
begin
 Result:=False;
 if not Unlocked then
  begin
   L:=Length(CommandsBlacklist);
   for i:= 0 To L-1 Do
    if Name=CommandsBlacklist[i] then
     begin
      Result:=True;
      Exit;
     end;
  end;
end;

function Normalize(Str:String):String;
var
 i,L:Integer;
 IgnoreSpace:Boolean;
begin
 Str:=Trim(Str);
 L:=Length(Str);
 IgnoreSpace:=False;
 if L>0 then
  begin
   i:=0;
   repeat
    i:=i+1;
    if Str[i]='"' then
     IgnoreSpace:=not IgnoreSpace;
    if (Str[i]=' ') and (not IgnoreSpace) then
     if Str[i+1]=' ' then
      begin
       Delete(Str,i,1);
       i:=i-1;
       L:=L-1;
     end;
   until i=L;
  end;
 Result:=Str;
end;

function Fmt(Str:String):String;
var
 i,L:Integer;
begin
 Str:=Trim(Str);
 L:=Length(Str);
 i:=0;
 if L>0 then
  repeat
   i:=i+1;
   if Str[i]='"' then
    begin
     Delete(Str,i,1);
     i:=i-1;
     L:=L-1;
    end;
  until i=L;
 Result:=Str;
end;

function SubCommandCount(SubCommandStr:String):Integer;
var
 i,L:Integer;
 IgnoreSpace:Boolean;
begin
 Result:=0;
 L:=Length(SubCommandStr);
 IgnoreSpace:=False;
 if L>0 then
  begin
   Result:=1;
   for i:= 1 To L Do
    begin
     if SubCommandStr[i]='"' then
      IgnoreSpace:=not IgnoreSpace;
     if (SubCommandStr[i]=' ') and (not IgnoreSpace) then
      Result:=Result+1;
    end;
  end;
end;

function GetSubCommandPos(SubCommandStr:String;Num:Integer):Integer;
var
 i,L,count:Integer;
 IgnoreSpace:Boolean;
begin
 count:=0;
 Result:=0;
 L:=Length(SubCommandStr);
 IgnoreSpace:=False;
 if L>0 then
  begin
   if Num=1 then
    begin
     Result:=1;
     Exit;
    end
   else
    for i:= 1 To L Do
     begin
      if SubCommandStr[i]='"' then
       IgnoreSpace:=not IgnoreSpace;
      if (SubCommandStr[i]=' ') and (not IgnoreSpace) then
       begin
        count:=count+1;
        if count=Num-1 then
         begin
          Result:=i+1;
          Exit;
         end;
       end;
     end;
  end;
end;

function ExtSubCommand(SubCommandStr:String;Num:Integer;LowerCased:Boolean=False):String;
var
 start,i,L:Integer;
 IgnoreSpace:Boolean;
begin
 start:=GetSubCommandPos(SubCommandStr,Num);
 IgnoreSpace:=False;
 L:=Length(SubCommandStr);
 for i:= start To L Do
  begin
   if SubCommandStr[i]='"' then
    IgnoreSpace:=not IgnoreSpace;
   if ((SubCommandStr[i]=' ') and (not IgnoreSpace)) or (i=L) then
    begin
     Result:=Fmt(Copy(SubCommandStr,start,i-start+1));
     if LowerCased then Result:=AnsiLowerCase(Result);
     Exit;
    end;
  end;
end;

procedure WriteLog(Str:String);
begin
 if ToFileFlag then ToFile.Add(Str)
 else Form12.Memo1.Lines.Add(Str);
end;

procedure RawWriteLog(Str:String);
var
 tmp:TStringList;
begin
 tmp:=TStringList.Create;
 tmp.Text:=Str;
 if ToFileFlag then ToFile.AddStrings(tmp)
 else Form12.Memo1.Lines.AddStrings(tmp);
end;

procedure WriteLogStyle(Str:String;Style:TFontStyles;Color:TColor);
var
 tmp,bck,nl:Integer;
begin
 tmp:=Form12.Memo1.SelStart;
 WriteLog(Str);
 if not ToFileFlag then
  begin
   bck:=Form12.Memo1.SelStart;
   nl:=bck-tmp;
   Form12.Memo1.SelStart:=tmp;
   Form12.Memo1.SelLength:=nl;
   Form12.Memo1.SelAttributes.Color:=Color;
   Form12.Memo1.SelAttributes.Style:=Style;
   Form12.Memo1.SelStart:=bck;
   Form12.Memo1.SelLength:=0;
  end;
end;

procedure WriteLogStyleExtended(Str:String;Styles:TStyles);
var
 tmp,bck,C,i:Integer;
begin
 Form12.Memo1.SelStart:=Length(Form12.Memo1.Text);
 tmp:=Form12.Memo1.SelStart;
 WriteLog(Str);
 C:=Length(Styles);
 if (not ToFileFlag) and (C>0) then
  begin
   bck:=Form12.Memo1.SelStart;
   for i:= 0 to C-1 do
    begin
     if Styles[i].Start<0 then Styles[i].Start:=0;
     if Styles[i].Length<0 then Styles[i].Length:=0;
     Form12.Memo1.SelStart:=tmp+Styles[i].Start;
     Form12.Memo1.SelLength:=Styles[i].Length;
     Form12.Memo1.SelAttributes.Color:=Styles[i].Color;
     Form12.Memo1.SelAttributes.Style:=Styles[i].Style;
    end;
   Form12.Memo1.SelStart:=bck;
   Form12.Memo1.SelLength:=0;
  end;
end;

procedure HelpHandler(SubCommand:String);
var
 i,C,tid:Integer;
 tmp:String;
 tgl:Boolean;
begin
 C:=SubCommandCount(SubCommand);
 tgl:=False;
 if C=0 then
  begin
   WriteLog('������ ������:');
   for i:= 0 To Length(Commands)-1 Do
    if not InCommandsBlacklist(SortedCmdList.Strings[i]) then
     begin
      tid:=Form12.GetCommandID(SortedCmdList.Strings[i]);
      if tgl then WriteLogStyle(Commands[tid].Name + ' - ' + Commands[tid].ShortDesc,[],clGray)
      else WriteLog(Commands[tid].Name + ' - ' + Commands[tid].ShortDesc);
      tgl:=not tgl;
     end
    else
     begin
      if tgl then WriteLogStyle(SortedCmdList.Strings[i] + ' - [�������������]',[],clGray)
      else WriteLog(SortedCmdList.Strings[i] + ' - [�������������]');
      tgl:=not tgl;
     end;
   WriteLog('');
   WriteLog('��� ����� ���������� �������� ������� ������� help cmd.');
   WriteLog('���� ����� �������� �������, ���������� ��������� ��� ���� ��������, ��������� �� � �������. ��������: command param1 "param 2" param3');
   WriteLog('����� ��������� ��������� ������ �� ���� ���. ��� ����� ��������� �� ������ � �������. ��������: command1 args;command2 args');
   WriteLog('��� �� ����� ��������� ��������� ���������� ������� � ����, ������� ����� �� ">" � ���� � �����. ��������: command args > C:\file.txt');
   WriteLog('� ���� �������� ">>", �� ���� �� �������������, � ��������� ����� ������ ������� � ����� �����.');
   WriteLog('��������� ���������� �������� ������: [param] - ������������ ��������, <param> - ��������������.');
   WriteLog('����� ���������� ������� �� ���������� ������ � �������� ������. ��� ����� �������� ���� autorun.txt � ��� �� �����, ��� ��������� exe � �������� � ���� ������������������ ������.');
  end
 else
  begin
   tmp:=ExtSubCommand(SubCommand,1,True);
   tid:=Form12.GetCommandID(tmp);
   if tid=-1 then
    WriteLog('������� "' + tmp + '" �� ����������.')
   else if tid=-2 then
    begin
     WriteLog('������� "' + tmp + '" �������������, ��� ��� ��� ���� �� �����. ��� ������������� ����� ������.');
     WriteLog('���� �� �� �� ������, ��� ��� ���� ����� � �� ����� ������, ��� ������ �������,');
     WriteLog('�� ���� �� ������ ������, ���� ������� ������ ���������� � ��� ������.');
     WriteLog('� ���� ��� ���� ��������� ���������: ��� ����� ����� �������� � ������ ��������� ����� ���� ��� � 0 �� 1 xD');
     WriteLog('�� ��� ����� ������? ������ ;)');
    end
   else
    begin
     WriteLog('������� �� ������� "' + tmp + '":');
     WriteLog('');
     RawWriteLog(Commands[tid].LongDesc);
    end;
  end;
end;

procedure PlistHandler(SubCommand:String);
var
 i,C:Integer;
 tmp:String;
begin
 C:=SubCommandCount(SubCommand);
 if C=0 then
  begin
   WriteLog('��������.');
  end
 else
  begin
   if ExtSubCommand(SubCommand,1,True)='add' then
    if C>1 then
     begin
      for i:= 2 To C Do
       begin
        tmp:=ExtSubCommand(SubCommand,i);
        if (FileExists(tmp)) or (Copy(tmp,1,7)='http://') or (Copy(tmp,1,8)='https://') or (Copy(tmp,1,6)='ftp://') then
         begin
          Form2.PlaylistAddSong(tmp);
          WriteLog('���� �������� � ��������: ' + tmp);
         end
        else
         WriteLog('������� ����� �� ����������: ' + tmp);
       end;
     end
      else
       WriteLog('������������ ����������');
  end;
end;

procedure TestHandler(SubCommand:String);
var
 i,C:Integer;
 es:TStyles;
begin
 C:=SubCommandCount(SubCommand);
 if C=0 then
  begin
   WriteLog('������.');
  end
 else
  begin
   WriteLog(IntToStr(C));
   WriteLog('');
   for i:= 1 To C Do
    WriteLog('"' + ExtSubCommand(SubCommand,i) + '"');
  end;
 WriteLogStyle('������',[fsBold],clBlack);
 WriteLogStyle('������',[fsItalic],clBlack);
 WriteLogStyle('������������',[fsUnderline],clBlack);
 WriteLogStyle('�����������',[fsStrikeOut],clBlack);
 WriteLogStyle('�������',[],clRed);
 WriteLogStyle('������',[],clGreen);
 WriteLogStyle('�����',[],clBlue);
  SetLength(es,7);
  for i:= 0 to 6 do
   begin
    es[i].Start:=i;
    es[i].Length:=1;
    es[i].Style:=[fsBold,fsUnderline];
   end;
  es[0].Color:=RGB(255,0,0);
  es[1].Color:=RGB(255,185,0);
  es[2].Color:=RGB(255,255,0);
  es[3].Color:=RGB(0,255,0);
  es[4].Color:=RGB(0,255,255);
  es[5].Color:=RGB(0,0,255);
  es[6].Color:=RGB(178,0,255);
 WriteLogStyleExtended('RAINBOW',es);
end;

procedure RemoveCmdHandler(SubCommand:String);
var
 i,C:Integer;
 tmp:String;
begin
 C:=SubCommandCount(SubCommand);
 if C>0 then
  begin
   for i:= 1 To C Do
    begin
     tmp:=ExtSubCommand(SubCommand,i,True);
     if Form12.RemoveCommand(tmp) then
      WriteLog('������� "' + tmp + '" �������.')
     else
      WriteLog('������� "' + tmp + '" �� ����������.');
    end;
  end
 else HelpHandler('removecmd');
end;

procedure HashHandler(SubCommand:String);
type
 HR=record
  ET:Cardinal;
  Hash,Path:String;
  IsString:Boolean;
 end;
var
 i,C:Integer;
 param,HN:String;
 HRS:array of HR;
begin
 C:=SubCommandCount(SubCommand);
 if C=0 then
  begin
   if not HashingInProgress then HelpHandler('hash');
  end
 else
  begin
   param:=ExtSubCommand(SubCommand,1,True);
   if param='stop' then
    begin
     hashes.StopRightNow:=True;
     HashingInProgress:=False;
     WriteLog('����������� �����������');
    end
   else
    if C=1 then
     WriteLog('������������ ����������.')
    else if not HashingInProgress then
     begin
      HashingInProgress:=True;
      if param='sha512' then
       HashingCore.ChangeHashEngine(0)
      else if param='sha384' then
       HashingCore.ChangeHashEngine(1)
      else if param='sha256' then
       HashingCore.ChangeHashEngine(2)
      else if param='sha1' then
       HashingCore.ChangeHashEngine(3)
      else if param='md4' then
       HashingCore.ChangeHashEngine(4)
      else if param='md5' then
       HashingCore.ChangeHashEngine(5)
      else if param='haval' then
       HashingCore.ChangeHashEngine(6)
      else if param='ripemd128' then
       HashingCore.ChangeHashEngine(7)
      else if param='ripemd160' then
       HashingCore.ChangeHashEngine(8)
      else if param='tiger' then
       HashingCore.ChangeHashEngine(9)
      else
       begin
        WriteLog('������ � �������� ��������� �����������. ��������� ������������ �����.');
        HashingInProgress:=False;
        Exit;
       end;
      HN:=HashingCore.GetHashEngineName;
      WriteLog('���������� �������� �����������: ' + HN);
      hashes.StopRightNow:=False;
      for i:= 2 To C Do
       begin
        if hashes.StopRightNow then Exit;
        param:=ExtSubCommand(SubCommand,i);
        if FileExists(param) then
         begin
          HashingCore.HashFile(param);
          SetLength(HRS,Length(HRS)+1);
          HRS[Length(HRS)-1].ET:=hashes.ElapsedTime;
          HRS[Length(HRS)-1].Hash:=hashes.Hashed;
          HRS[Length(HRS)-1].Path:=param;
          HRS[Length(HRS)-1].IsString:=False;
         end
        else
         begin
          SetLength(HRS,Length(HRS)+1);
          HRS[Length(HRS)-1].ET:=0;
          HRS[Length(HRS)-1].Hash:=HashingCore.HashString(param);
          HRS[Length(HRS)-1].Path:=param;
          HRS[Length(HRS)-1].IsString:=True;
          WriteLog('����������� ���������!');
         end;
       end;
      if Length(HRS)>0 then
       for i:= 0 To Length(HRS)-1 Do
        begin
         if HRS[i].IsString then
          begin
           WriteLog(HN + '("' + HRS[i].Path + '") = ' + HRS[i].Hash);
          end
         else
          begin
           WriteLog(HN + '(' + HRS[i].Path + ') = ' + HRS[i].Hash);
           WriteLog('����������� �����: ' + IntToStr(HRS[i].ET) + ' ��');
          end;
        end;
      HashingInProgress:=False;  
     end;
  end;
end;

procedure ExitHandler(SubCommand:String);
begin
 if AppLoaded then
  Form1.TotalTerminate
 else
  WriteLog('������� exit �� �������� �� ����������� ��� � ���� ��� ������.');
end;

procedure CloseHandler(SubCommand:String);
begin
 Form12.Close;
end;

procedure RestartHandler(SubCommand:String);
begin
 if AppLoaded then
  begin
   CloseHandle(ServerMailslotHandle);
   CloseHandle(CommandEvent);
   ShellExecute(Application.Handle,'open',PChar(Application.ExeName),'',nil,0);
   Form1.TotalTerminate;
  end
 else
  WriteLog('������� restart �� �������� �� ����������� �� ��������� ����������� ������.');
end;

procedure WHvideoHandler(SubCommand:String);
var
 C:Integer;
 Owid,Ohei,Dwid,Dhei,Nwid,Nhei:Integer;
 p:Double;
 calc:Boolean;
 function Round2(Num:Extended):Integer;
 var
  tmp:Integer;
  raw:Extended;
 begin
  tmp:=Round(Num);
  if Odd(tmp) then
   begin
    raw:=Frac(Num);
    if raw>=0.5 then
     tmp:=tmp-1
    else
     tmp:=tmp+1;
   end;
  Result:=tmp;
 end;
 function CheckInput(Owid,Ohei,Dwid,Dhei:Integer):Boolean;
  begin
   Result:=True;
   if (Owid=0) or (Ohei=0) or (Dwid=0) or (Dhei=0) then
    begin
     WriteLog('��������� ������� ������');
     Result:=False;
    end
   else if Odd(Owid) or Odd(Ohei) or Odd(Dwid) or Odd(Dhei) then
    begin
     WriteLog('��������� ������� ������!');
     WriteLog('������ ��� ������ ����� �� ����� ���� ��������');
     Result:=False;
    end;
  end;
 function IsConst(ss:String;var w,h:Integer):Boolean;
  begin
   Result:=False;
   if ss='hd' then
    begin
     w:=1280;
     h:=720;
     Result:=True;
    end
   else if ss='fullhd' then
    begin
     w:=1920;
     h:=1080;
     Result:=True;
    end
   else if ss='4k' then
    begin
     w:=3840;
     h:=2160;
     Result:=True;
    end
   else if ss='8k' then
    begin
     w:=7680;
     h:=4320;
     Result:=True;
    end
   else if ss='16k' then
    begin
     w:=15360;
     h:=8640;
     Result:=True;
    end
  end;
begin
 C:=SubCommandCount(SubCommand);
 calc:=False;
 if C>0 then
  begin
   if C<2 then
    WriteLog('������������ ����������. �������������� �������� �� ������� help whvideo')
   else if C=2 then
    begin
     if
      (IsConst(ExtSubCommand(SubCommand,1,True),Owid,Ohei)) and
      (IsConst(ExtSubCommand(SubCommand,2,True),Dwid,Dhei)) then
       calc:=True;
    end
   else if C=3 then
    begin
     if IsConst(ExtSubCommand(SubCommand,1,True),Owid,Ohei) then
      begin
       Dwid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       Dhei:=StrToIntDef(ExtSubCommand(SubCommand,3),0);
       calc:=True;
      end
     else if IsConst(ExtSubCommand(SubCommand,3,True),Dwid,Dhei) then
      begin
       Owid:=StrToIntDef(ExtSubCommand(SubCommand,1),0);
       Ohei:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       calc:=True;
      end
     else
      WriteLog('������������ ����������. �������������� �������� �� ������� help whvideo');
    end
   else
    begin
     if IsConst(ExtSubCommand(SubCommand,1,True),Owid,Ohei) then
      begin
       if IsConst(ExtSubCommand(SubCommand,2,True),Dwid,Dhei) then
        calc:=True
       else
        begin
         Dwid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
         Dhei:=StrToIntDef(ExtSubCommand(SubCommand,3),0);
         calc:=True;
        end;
      end
     else
      begin
       Owid:=StrToIntDef(ExtSubCommand(SubCommand,1),0);
       Ohei:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       if IsConst(ExtSubCommand(SubCommand,3,True),Dwid,Dhei) then
        calc:=True
       else
        begin
         Dwid:=StrToIntDef(ExtSubCommand(SubCommand,3),0);
         Dhei:=StrToIntDef(ExtSubCommand(SubCommand,4),0);
         calc:=True;
        end
      end;
    end;
   if calc then
    begin
     if CheckInput(Owid,Ohei,Dwid,Dhei) then
      begin
       Nwid:=Dwid;
       p:=Owid/Dwid;
       Nhei:=Round2(Ohei/p);
        if Odd(Nhei) then Nhei:=Nhei+1;
       if Nhei>Dhei then
        begin
         Nhei:=Dhei;
         p:=Ohei/Dhei;
         Nwid:=Round2(Owid/p);
        if Odd(Nwid) then Nwid:=Nwid+1;
        end;
       WriteLog('�������� ���������� ' + IntToStr(Owid) + 'x' + IntToStr(Ohei) + ' ��� '  + IntToStr(Dwid) + 'x' + IntToStr(Dhei) + ' �� ����������.');
       WriteLog('���������: ' + IntToStr(Nwid) + 'x' + IntToStr(Nhei));
      end;
    end;
  end
 else
  WriteLog('�������� �������� ����� �� ����������.');
end;

procedure TimeHandler(SubCommand:String);
begin
 WriteLog(DateToStr(Date) + ' ' + TimeToStr(Time));
end;

procedure SystemInfoHandler(SubCommand:String);
var
 tmp:TJvComputerInfoEx;
 function BuildSSEString:String;
 begin
  Result:='';
  if sse in tmp.CPU.SSE then
   Result:=Result + 'SSE, ';
  if sse2 in tmp.CPU.SSE then
   Result:=Result + 'SSE2, ';
  if sse3 in tmp.CPU.SSE then
   Result:=Result + 'SSE3, ';
  if ssse3 in tmp.CPU.SSE then
   Result:=Result + 'SSSE3, ';
  if sse41 in tmp.CPU.SSE then
   Result:=Result + 'SSE4.1, ';
  if sse42 in tmp.CPU.SSE then
   Result:=Result + 'SSE4.2, ';
  if sse4A in tmp.CPU.SSE then
   Result:=Result + 'SSE4a, ';
  if sse5 in tmp.CPU.SSE then
   Result:=Result + 'SSE5, ';
  if avx in tmp.CPU.SSE then
   Result:=Result + 'AVX, ';
  Delete(Result,Length(Result)-1,2);
 end;
begin
 tmp:=Form1.CInfo;
 WriteLog('���������:');
 WriteLog(' ��������: ' + tmp.CPU.Name);
 WriteLog(' �������������: ' + tmp.CPU.Manufacturer);
 WriteLog(' Vendor ID String: ' + tmp.CPU.VendorIDString);
 WriteLog(' ������������� � DEP: ' + BoolToStr(tmp.CPU.DEPCapable,True));
 WriteLog(' 3DNow!: ' + BoolToStr(tmp.CPU._3DNow,True));
 WriteLog(' 3DNowExt: ' + BoolToStr(tmp.CPU.Ex3DNow,True));
 WriteLog(' MMX: ' + BoolToStr(tmp.CPU.MMX,True));
 WriteLog(' MMXEXT: ' + BoolToStr(tmp.CPU.ExMMX,True));
 WriteLog(' SSE: ' + BuildSSEString);
 WriteLog(' HasCacheInfo: ' + BoolToStr(tmp.CPU.HasCacheInfo,True));
 WriteLog(' HasExtendedInfo: ' + BoolToStr(tmp.CPU.HasExtendedInfo,True));
 WriteLog(' HasInstruction: ' + BoolToStr(tmp.CPU.HasInstruction,True));
 WriteLog(' Hyper-Threading Technology: ' + BoolToStr(tmp.CPU.HyperThreadingTechnology,True));
 WriteLog(' 64-bit: ' + BoolToStr(tmp.CPU.Is64Bits,True));
 WriteLog(' FDIVOK: ' + BoolToStr(tmp.CPU.IsFDIVOK,True));
 WriteLog(' L1 Code Cache: ' + IntToStr(tmp.CPU.L1CodeCache));
 WriteLog(' L1 Data Cache: ' + IntToStr(tmp.CPU.L1DataCache));
 WriteLog(' L2 Cache: ' + IntToStr(tmp.CPU.L2Cache));
 WriteLog(' L3 Cache: ' + IntToStr(tmp.CPU.L3Cache));
 WriteLog(' ������� �������: ' + IntToStr(tmp.CPU.NormFreq) + ' MHz');
 WriteLog(' ������� �������: ' + IntToStr(tmp.CPU.RawFreq) + ' MHz');
 WriteLog(' ��������: ' + IntToStr(tmp.CPU.Stepping));
 WriteLog('');
 WriteLog('�������������:');
 WriteLog(' �����: ' + tmp.Identification.DomainName);
 WriteLog(' IP-�����: ' + tmp.Identification.IPAddress);
 WriteLog(' ��� ����������: ' + tmp.Identification.LocalComputerName);
 WriteLog(' ��� ������������: ' + tmp.Identification.LocalUserName);
 WriteLog(' ������� ������: ' + tmp.Identification.LocalWorkgroup);
 WriteLog(' ������������������ ��������: ' + tmp.Identification.RegisteredCompany);
 WriteLog(' ������������������ ��������: ' + tmp.Identification.RegisteredOwner);
 WriteLog('');
 WriteLog('������:');
 WriteLog(' �������� � ����� ��������: ' + IntToStr(tmp.Memory.FreePageFileMemory) + ' bytes');
 WriteLog(' �������� � ���������� ������: ' + IntToStr(tmp.Memory.FreePhysicalMemory) + ' bytes');
 WriteLog(' �������� � ����������� ������: ' + IntToStr(tmp.Memory.FreeVirtualMemory) + ' bytes');
 WriteLog(' ����� � ����� ��������: ' + IntToStr(tmp.Memory.TotalPageFileMemory) + ' bytes');
 WriteLog(' ����� ���������� ������: ' + IntToStr(tmp.Memory.TotalPhysicalMemory) + ' bytes');
 WriteLog(' ����� ����������� ������: ' + IntToStr(tmp.Memory.TotalVirtualMemory) + ' bytes');
 WriteLog('');
 WriteLog('������������ �������:');
 WriteLog(' ��: ' + tmp.OS.ProductName);
 WriteLog(' Service Pack: ' + IntToStr(tmp.OS.ServicePackVersion));
 WriteLog(' Build: ' + IntToStr(tmp.OS.VersionBuild));
 WriteLog(' ������ NT: ' + IntToStr(tmp.OS.VersionMajor) + '.' + IntToStr(tmp.OS.VersionMinor));
 WriteLog(' ���� ��������: ' + tmp.OS.ProductID);
 WriteLog('');
 WriteLog('�����:');
 WriteLog(' ����������: ' + IntToStr(tmp.Screen.Width) + 'x' + IntToStr(tmp.Screen.Height));
 WriteLog(' ������� ����������: ' + IntToStr(tmp.Screen.Hz) + ' Hz');
 WriteLog(' ������� �����: ' + IntToStr(tmp.Screen.BitsPerPixel) + ' bits');
end;

procedure CmdToFileHandler(SubCommand:String);
var
 Cmd:String;
 s:Boolean;
begin
 if SubCommandCount(SubCommand)>1 then
  begin
   ToFilePath:=ExtSubCommand(SubCommand,1);
   Cmd:=Copy(SubCommand,GetSubCommandPos(SubCommand,2),Length(SubCommand)-Length(ToFilePath)-1);
   ToFileFlag:=True;
   ToFile.Clear;
   Form12.ParseCommand(Cmd);
   s:=True;
   try
    ToFile.SaveToFile(ToFilePath);
   except
    s:=False;
   end;
   ToFileFlag:=False;
   if s then WriteLog('��������� ���������� ������� ' + Cmd + ' �������� � ���� ' + ToFilePath)
   else WriteLog('���������� ��������� ���� �� ���������� ����.');
  end
 else
  WriteLog('������������ ����������');
end;

procedure CmdToFile2Handler(SubCommand:String);
var
 Cmd:String;
 s:Boolean;
begin
 if SubCommandCount(SubCommand)>1 then
  begin
   ToFilePath:=ExtSubCommand(SubCommand,1);
   Cmd:=Copy(SubCommand,GetSubCommandPos(SubCommand,2),Length(SubCommand)-Length(ToFilePath)-1);
   ToFileFlag:=True;
   ToFile.Clear;
   if FileExists(ToFilePath) then
    ToFile.LoadFromFile(ToFilePath);
   Form12.ParseCommand(Cmd);
   s:=True;
   try
    ToFile.SaveToFile(ToFilePath);
   except
    s:=False;
   end;
   ToFileFlag:=False;
   if s then WriteLog('��������� ���������� ������� ' + Cmd + ' �������� � ���� ' + ToFilePath)
   else WriteLog('���������� ��������� ���� �� ���������� ����.');
  end
 else
  WriteLog('������������ ����������');
end;

procedure TimerHandler(SubCommand:String);
var
 param,paramNext:String;
 C,i:Integer;
 tmpsec,tmpsecGlobal:Int64;
begin
 C:=SubCommandCount(SubCommand);
 if C=0 then
  begin
   if Form12.Timer1.Enabled then
    begin
     WriteLog('������ �������.');
     WriteLog('��������: ' + MyTimeToStr(TimerSeconds/(24*60*60)));
    end
   else WriteLog('������ ��������.');
  end
 else if C=1 then
  begin
   param:=ExtSubCommand(SubCommand,1,True);
   if param='stop' then
    begin
     Form12.Timer1.Enabled:=False;
     WriteLog('������ ����������.');
    end
   else if param='resume' then
    begin
     if TimerSeconds=0 then
      begin
       WriteLog('������ ��� �� ��� ����������.');
      end
     else
      begin
       Form12.Timer1.Enabled:=True;
       WriteLog('������ ����������.');
       WriteLog('��������: ' + MyTimeToStr(TimerSeconds/(24*60*60)));
      end;
    end
   else
    begin
     if StrToIntDef(param,0)=0 then
      begin
       WriteLog('��������� ������������ �����.');
      end
     else
      begin
       TimerSeconds:=StrToInt64Def(param,0);
       Form12.Timer1.Enabled:=True;
       WriteLog('������ �������.');
       WriteLog('��������: ' + MyTimeToStr(TimerSeconds/(24*60*60)));
      end;
    end;
  end
 else
  begin
   i:=0;
   tmpsecGlobal:=0;
   repeat
    i:=i+1;
    param:=ExtSubCommand(SubCommand,i);
    tmpsec:=StrToInt64Def(param,0);
    if C>i then
     begin
      paramNext:=ExtSubCommand(SubCommand,i+1,True);
      if paramNext='s' then
       i:=i+1
      else if paramNext='m' then
       begin
        tmpsec:=tmpsec*60;
        i:=i+1;
       end
      else if paramNext='h' then
       begin
        tmpsec:=tmpsec*60*60;
        i:=i+1;
       end
      else if paramNext='d' then
       begin
        tmpsec:=tmpsec*60*60*24;
        i:=i+1;
       end;
     end;
    tmpsecGlobal:=tmpsecGlobal + Abs(tmpsec);
   until i>=C;
   if tmpsecGlobal=0 then
    begin
     WriteLog('��������� ������������ �����.');
    end
   else
    begin
     TimerSeconds:=tmpsecGlobal;
     Form12.Timer1.Enabled:=True;
     WriteLog('������ �������.');
     WriteLog('��������: ' + MyTimeToStr(TimerSeconds/(24*60*60)));
    end;
  end;
end;

procedure hscrlHandler(SubCommand:String);
begin
 if Form12.Memo1.ScrollBars=ssVertical then
  begin
   Form12.Memo1.ScrollBars:=ssBoth;
   WriteLog('�������������� ��������� �������.');
  end
 else if Form12.Memo1.ScrollBars=ssBoth then
  begin
   Form12.Memo1.ScrollBars:=ssVertical;
   WriteLog('�������������� ��������� ��������.');
  end;
end;

procedure ClearHandler(SubCommand:String);
begin
 Form12.Memo1.Clear;
end;

procedure TitleHandler(SubCommand:String);
begin
 if Length(SubCommand)=0 then
  WriteLog(Form12.Caption)
 else
  begin
   Form12.Caption:=SubCommand;
   WriteLog('��������� �������.');
  end;
end;

procedure AboutHandler(SubCommand:String);
begin
 WriteLog(APP_NAME + ' ' + APP_VERSION);
 WriteLog('�����: Somepony');
 WriteLog('�������� �� Delphi');
 WriteLog('');
 WriteLog('������ ��������� ��������� � ���������������� ��������.');
 WriteLog('');
 WriteLog('������������ ����������:');
 WriteLog(' ���������� � EXE:');
 WriteLog('  - DCPcrypt 2.0 (����������� � ���������� ���������� �����������)');
 WriteLog('  - Oscilloscope Visualyzation 0.8 �� Alessandro Cappellozza (������� ����������������) (��������� ������������ �� ������� �����)');
 WriteLog('  - uFMOD 1.25.2a (������������ ��������� ������ � ������� XM)');
 WriteLog(' DLL (������������, ��� ��� ����� �� ����������):');
 WriteLog('  - BASS 2.4.11 (��������������� � ������ �����)');
 WriteLog('  - BASSWASAPI 2.4.1.2 (���������� BASS ��� ������ � WASAPI (Windows Vista � ����))');
 WriteLog('  - BASSmix 2.4.8 (���������� BASS ��� ����������� �����, ����������� � WASAPI)');
 WriteLog('  - Tags (���������� BASS ��� ���������� �����)');
 WriteLog(' DLL (��������������, ����� ���������� � ��� ���, ������ �� ����� �������� ��������� �������):');
 WriteLog('  - MediaInfoLib 0.7.7.6 (��������� ���������� � ����������, ����� "MediaInfo" � ���� (��� ������� ������� ���� ����������))');
 WriteLog('  - libeay32 � ssleay32 (������������� ��������� SSL ��� ������ � �����. ��� ���� ��������� �� ����� �������� ������ ���������� �� ���������)');
end;

procedure RestoreWinVolHandler(SubCommand:String);
var
 tmp_val:Byte;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   if ExtSubCommand(SubCommand,1,True)='clear' then
    begin
     RestoreWinVolFlag:=False;
     WriteLog('����� ������� ��������� �� ����� �������.');
     Exit;
    end;
   tmp_val:=StrToIntDef(ExtSubCommand(SubCommand,1),101);
   if tmp_val<=100 then
    begin
     RestoreWinVolFlag:=True;
     RestoreWinVolValue:=tmp_val;
     WriteLog('����� ������� ��������� ����� ���������� �� ' + IntToStr(tmp_val) + '.');
    end
   else WriteLog('��������� ������� ������.');
  end
 else
  HelpHandler('restorewinvol');
end;

procedure WebFaceHandler(SubCommand:String);
var
 tmpport:Integer;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   if ExtSubCommand(SubCommand,1,True)='stop' then
    begin
     Form12.HTTPSrv.Active:=False;
     WriteLog(APP_NAME + ' Remote ��������');
     Exit;
    end;
   tmpport:=StrToIntDef(ExtSubCommand(SubCommand,1),5000);
   Form12.HTTPSrv.Active:=False;
   Form12.HTTPSrv.DefaultPort:=tmpport;
   Form12.HTTPSrv.Active:=True;
   WriteLog(APP_NAME + ' Remote ������� �� ����� ' + IntToStr(tmpport));
  end;
end;

procedure DInfoHandler(SubCommand:String);
var
 ID:Integer;
 info:BASS_DEVICEINFO;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   ID:=StrToIntDef(ExtSubCommand(SubCommand,1),0);
   if BASS_GetDeviceInfo(ID,info) then
    begin
     WriteLog('name: ' + info.name);
     WriteLog('driver: ' + info.driver);
    end
   else
    begin
     WriteLog('device is invalid');
    end;
  end;
end;

procedure SetWinVolHandler(SubCommand:String);
var
 tmp_val:Byte;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   tmp_val:=StrToIntDef(ExtSubCommand(SubCommand,1),101);
   if tmp_val<=100 then
    begin
     if IsVista then
      Form1.SetVistaVolume(tmp_val)
     else
      Form1.SetWinXPVolume(tmp_val);
     WriteLog('����� ������� ��������� ���������� �� ' + IntToStr(tmp_val) + '.');
    end
   else WriteLog('��������� ������� ������.');
  end
 else
  HelpHandler('setwinvol');
end;

procedure QEHandler(SubCommand:String);
var
 a,b,c:Extended;
 function QEStr:String;
  begin
   Result:=FloatToStr(a)+'x^2';
   if b<0 then
    Result:=Result+FloatToStr(b)+'x'
   else
    Result:=Result+'+'+FloatToStr(b)+'x';
   if c<0 then
    Result:=Result+FloatToStr(c)+'=0'
   else
    Result:=Result+'+'+FloatToStr(c)+'=0';
  end;
 function LEStr:String;
  begin
   Result:=FloatToStr(b)+'x';
   if c<0 then
    Result:=Result+FloatToStr(c)+'=0'
   else
    Result:=Result+'+'+FloatToStr(c)+'=0';
  end;
 function D:Extended;
  begin
   Result:=b*b-4*a*c;
  end;
 function X(id:Byte):Extended;
  begin
   Result:=0;
   case id of
    1: Result:=((-b)+sqrt(D))/(2*a);
    2: Result:=((-b)-sqrt(D))/(2*a);
   end;
  end;
 function XC(id:Byte):String;
  var
   n1,n2,cC,bC:Extended;
  begin
   cC:=2*a;
   bC:=sqrt(abs(D));
   n1:=(-b)/cC;
   n2:=bC/cC;
   case id of
    1: Result:=FloatToStr(n1)+'+'+FloatToStr(n2)+'i';
    2: Result:=FloatToStr(n1)+'-'+FloatToStr(n2)+'i';
   end;
  end;
begin
 if SubCommandCount(SubCommand)>2 then
  begin
   a:=StrToFloatDef(ExtSubCommand(SubCommand,1),1);
   b:=StrToFloatDef(ExtSubCommand(SubCommand,2),1);
   c:=StrToFloatDef(ExtSubCommand(SubCommand,3),0);
   WriteLog(QEStr);
   WriteLog('');
   if a=0 then
    begin
     WriteLog('a=0 - ��������� �� �������� ���������� � ����� ������ ��� ��������.');
     WriteLog('');
     WriteLog(LEStr);
     if b=0 then
      if c=0 then
       begin
        WriteLog('');
        WriteLog('a=b=0 - ��������� ����� ����������� ��������� �������.');
        WriteLog('X�R : x*0=0');
        Exit;
       end
      else
       begin
        WriteLog('');
        WriteLog('a=0; b<>0 - ��������� �� ����� �������.');
        Exit;
       end;
     WriteLog(FloatToStr(b)+'x='+FloatToStr(0-c));
     WriteLog('x='+FloatToStr((0-c)/b));
     Exit;
    end;
   WriteLog('����� ������������');
   WriteLog('D='+FloatToStr(D));
   if D<0 then
    begin
     WriteLog('');
     WriteLog('D<0 - ��������� �� ����� ������ �� ��������� �������������� �����.');
     WriteLog('����� ��������� ����� �� ��������� ����������� �����.');
     WriteLog('');
     WriteLog('X1='+XC(1));
     WriteLog('X2='+XC(2));
    end
   else if D=0 then
    begin
     WriteLog('');
     WriteLog('D=0 - ��������� ����� ���� ������ (��� ����������� �����/������ ��������� 2).');
     WriteLog('');
     WriteLog('X='+FloatToStr(X(1)));
    end
   else if D>0 then
    begin
     WriteLog('');
     WriteLog('D>0 - ��������� ����� ��� �����.');
     WriteLog('');
     WriteLog('X1='+FloatToStr(X(1)));
     WriteLog('X2='+FloatToStr(X(2)));
    end;
  end
 else if SubCommandCount(SubCommand)>0 then
  begin
   WriteLog('������������ ����������.');
  end
 else
  HelpHandler('qe');
end;

procedure SetSpecModeHandler(SubCommand:String);
var
 ID:Byte;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   ID:=StrToIntDef(ExtSubCommand(SubCommand,1),255);
   if Form1.SetSpecMode(ID) then
    WriteLog('����� ������������ �������.')
   else
    WriteLog('��������� ������� ������.');
  end
 else
  HelpHandler('setspecmode');
end;

procedure WarmUpHandler(SubCommand:String);
var
 ID:Integer;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   if ExtSubCommand(SubCommand,1,True)='start' then
    if not WarmingUp then
     begin
      for ID:= 0 To Cores-1 Do
       WarmingThread[ID]:=TWarmingThread.Create(False);
      WriteLog('�������� �����.');
      WarmingUp:=True;
     end
    else WriteLog('�������� ��� ������������!');
   if ExtSubCommand(SubCommand,1,True)='stop' then
    if WarmingUp then
     begin
      for ID:= 0 To Cores-1 Do
       begin
        WarmingThread[ID].Terminate;
        WarmingThread[ID].WaitFor;
        FreeAndNil(WarmingThread[ID]);
       end;
      WriteLog('�������� �������.');
      WarmingUp:=False;
     end
    else WriteLog('�������� �� ������������.');
  end
 else
  if WarmingUp then WriteLog('�������� ������������.')
  else WriteLog('�������� �� ������������.');
end;

procedure VarHandler(SubCommand:String);
var
 cmd,nname,tmp:String;
 tmpnum,i,C:Integer;
 tgl:Boolean;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   cmd:=ExtSubCommand(SubCommand,1,True);
   if cmd='create' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       nname:=ExtSubCommand(SubCommand,2);
       if AddNewVar(nname)=-1 then
        WriteLog('���������� � ����� ������ ��� ����������.')
       else
        WriteLog('���������� "'+nname+'" �������.');
      end
     else WriteLog('��������� ������������ �����.');
    end
   else if cmd='delete' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       nname:=ExtSubCommand(SubCommand,2);
       if DeleteVar(nname) then
        WriteLog('���������� "'+nname+'" �������.')
       else
        WriteLog('���������� "'+nname+'" �� ����������.');
      end
     else WriteLog('��������� ������������ �����.');
    end
   else if cmd='set' then
    begin
     if SubCommandCount(SubCommand)>2 then
      begin
       nname:=ExtSubCommand(SubCommand,2);
       tmpnum:=GetVarNumByName(nname);
       if tmpnum=-1 then
        WriteLog('���������� "'+nname+'" �� ����������.')
       else
        begin
         tmp:=ExtSubCommand(SubCommand,3);
         Vars[tmpnum].Value:=tmp;
         WriteLog('�������� ���������� "'+nname+'" ���������.');
        end;
      end
     else WriteLog('��������� ������������ �����.');
    end
   else if cmd='get' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       nname:=ExtSubCommand(SubCommand,2);
       tmpnum:=GetVarNumByName(nname);
       if tmpnum=-1 then
        WriteLog('���������� "'+nname+'" �� ����������.')
       else
        WriteLog('"'+nname+'" = "'+Vars[tmpnum].Value+'"');
      end
     else WriteLog('��������� ������������ �����.');
    end
   else if cmd='list' then
    begin
     C:=Length(Vars);
     tgl:=False;
     if C>0 then
      begin
       for i:= 0 to C-1 do
        begin
         if tgl then WriteLogStyle(IntToStr(i+1)+'. '+Vars[i].Name,[],clGray)
         else WriteLog(IntToStr(i+1)+'. '+Vars[i].Name);
         tgl:=not tgl;
        end;
      end
     else WriteLog('��� �� ����� ����������.');
    end
   else HelpHandler('var');
  end
 else
  HelpHandler('var');
end;

procedure BatteryInfoHandler(SubCommand:String);
var
 st:TSystemPowerStatus;
 s:String;
begin
 GetSystemPowerStatus(st);
 case st.ACLineStatus of
  0: s := '�� �������';
  1: s := '�� ����';
  else s := '�� ��������';
 end;
 WriteLog('�������: ' + s);
 case st.BatteryFlag of
  0: s := '����������';
  1: s := '�������';
  2: s := '������';
  4: s := '�����������';
  8: s := '����������';
  128: s := '������� �����������';
  else s := '��� ����������';
 end;
 WriteLog('����� �������: ' + s);
 WriteLog('������� ������: ' + IntToStr(st.BatteryLifePercent) + '%');
 if Integer(st.BatteryLifeTime) < 0 then s := '����������'
 else s := TimeToStr(st.BatteryLifeTime / SecsPerDay);
 WriteLog('����� ������ �� �������: ' + s);
 if Integer(st.BatteryFullLifeTime) = -1 then s := '����������'
 else s := TimeToStr(st.BatteryFullLifeTime / SecsPerDay);
 WriteLog('������������ ����� ������: ' + s);
end;

procedure RollHandler(SubCommand:String);
var
 Res,X,Y:Int64;
 C:Integer;
begin
 C:=SubCommandCount(SubCommand);
 if C>=2 then
  begin
   X:=StrToInt64Def(ExtSubCommand(SubCommand,1),1);
   Y:=StrToInt64Def(ExtSubCommand(SubCommand,2),100);
  end
 else if C=1 then
  begin
   X:=1;
   Y:=StrToInt64Def(ExtSubCommand(SubCommand,1),100);
  end
 else
  begin
   X:=1;
   Y:=100;
  end;
 Res:=Round(Random*(Y-X)+X);
 WriteLog('�����: ' + IntToStr(Res) + '. (' + IntToStr(X) + '..' + IntToStr(Y) + ')');
end;

procedure StartInHandler(SubCommand:String);
var
 param,paramNext:String;
 C,i:Integer;
 tmpsec,tmpsecGlobal:Int64;
begin
 C:=SubCommandCount(SubCommand);
 if C>=1 then
  begin
   i:=0;
   tmpsecGlobal:=0;
   repeat
    i:=i+1;
    param:=ExtSubCommand(SubCommand,i);
    tmpsec:=StrToInt64Def(param,0);
    if C>i then
     begin
      paramNext:=ExtSubCommand(SubCommand,i+1,True);
      if paramNext='s' then
       i:=i+1
      else if paramNext='m' then
       begin
        tmpsec:=tmpsec*60;
        i:=i+1;
       end
      else if paramNext='h' then
       begin
        tmpsec:=tmpsec*60*60;
        i:=i+1;
       end
      else if paramNext='d' then
       begin
        tmpsec:=tmpsec*60*60*24;
        i:=i+1;
       end;
     end;
    tmpsecGlobal:=tmpsecGlobal + Abs(tmpsec);
   until i>=C;
   if tmpsecGlobal=0 then
    begin
     WriteLog('��������� ������������ �����.');
    end
   else
    begin
     TimerSeconds2:=tmpsecGlobal;
     Form12.Timer2.Enabled:=True;
     WriteLog('������ �������.');
     WriteLog('��������: ' + MyTimeToStr(TimerSeconds2/(24*60*60)));
    end;
  end
 else
  begin
   if Form12.Timer2.Enabled then
    begin
     WriteLog('������ �������.');
     WriteLog('��������: ' + MyTimeToStr(TimerSeconds2/(24*60*60)));
    end
   else WriteLog('������ ��������.');
  end;
end;

procedure GetCmdAddrHandler(SubCommand:String);
var
 C,tid:Integer;
 tmp:String;
begin
 C:=SubCommandCount(SubCommand);
 if C>=1 then
  begin
   tmp:=ExtSubCommand(SubCommand,1,True);
   tid:=Form12.GetCommandID(tmp);
   if tid=-1 then
    WriteLog('������� "' + tmp + '" �� ����������.')
   else
    begin
     WriteLog('hex: ' + IntToHex(Integer(@Commands[tid].Handler),1));
     WriteLog('dec: ' + IntToStr(Integer(@Commands[tid].Handler)));
    end;
  end;
end;

procedure SetCmdAddrHandler(SubCommand:String);
var
 C,tid:Integer;
 tmp:String;
begin
 C:=SubCommandCount(SubCommand);
 if C>=2 then
  begin
   tmp:=ExtSubCommand(SubCommand,1,True);
   tid:=Form12.GetCommandID(tmp);
   if tid=-1 then
    WriteLog('������� "' + tmp + '" �� ����������.')
   else
    begin
     Integer(@Commands[tid].Handler):=StrToIntDef(ExtSubCommand(SubCommand,2),Integer(@Commands[tid].Handler));
     WriteLog('����� ������ �������.');
     WriteLog('hex: ' + IntToHex(Integer(@Commands[tid].Handler),1));
     WriteLog('dec: ' + IntToStr(Integer(@Commands[tid].Handler)));
    end;
  end;
end;

procedure SetVolumeHandler(SubCommand:String);
var
 C,tmp:Integer;
begin
 C:=SubCommandCount(SubCommand);
 if C>=1 then
  begin
   tmp:=StrToIntDef(ExtSubCommand(SubCommand,1),-1);
   if (tmp>=0) and (tmp<=1000) then
    begin
     Form3.SetVolume(tmp);
     WriteLog('��������� ��������.');
    end
   else WriteLog('��������� ������� ���������.');
  end
 else HelpHandler('setvolume');
end;

procedure SetPlaySpeedHandler(SubCommand:String);
var
 C,tmp:Integer;
begin
 C:=SubCommandCount(SubCommand);
 if C>=1 then
  begin
   tmp:=StrToIntDef(ExtSubCommand(SubCommand,1),-1);
   if (tmp>=0) and (tmp<=100000) then
    begin
     Form3.SetSpeed(tmp);
     if tmp=0 then
      WriteLog('�������� ��������� � �����.')
     else if tmp<100 then
      WriteLog('�������� �� ����������. ������� �������� ������ 100.')
     else
      WriteLog('�������� �������� � ��������� ' + FormatFloat('0.####',speedprc) + '% �� ���������� (' + IntToStr(cfrc) + ').');
    end
   else WriteLog('��������� ������� ���������.');
  end
 else HelpHandler('setplayspeed');
end;

procedure SetBalanceHandler(SubCommand:String);
var
 C,tmp:Integer;
begin
 C:=SubCommandCount(SubCommand);
 if C>=1 then
  begin
   tmp:=StrToIntDef(ExtSubCommand(SubCommand,1),9001);
   if (tmp>=-1000) and (tmp<=1000) then
    begin
     Form3.SetBalance(tmp);
     WriteLog('������ ������ � ������� ������� �������.');
    end
   else WriteLog('��������� ������� ���������.');
  end
 else HelpHandler('setbalance');
end;

procedure SetPlayDeviceHandler(SubCommand:String);
var
 C,tmp,dc:Integer;
begin
 C:=SubCommandCount(SubCommand);
 if C>=1 then
  begin
   tmp:=StrToIntDef(ExtSubCommand(SubCommand,1),-1);
   dc:=Form3.ComboBox1.Items.Count;
   if (tmp>=0) and (tmp<=(dc-1)) then
    begin
     Form3.ChangeDevice(tmp+1);
     WriteLog('������������ ���������� ��������������� ������� �� ' + Form3.ComboBox1.Items.Strings[tmp] + '.');
    end
   else WriteLog('��������� ������� ���������.');
  end
 else HelpHandler('setplaydevice');
end;

procedure ToggleReverbHandler(SubCommand:String);
var
 tmp:Boolean;
begin
 tmp:=not Form3.CheckBox1.Checked;
 Form3.CheckBox1.Checked:=tmp;
 if tmp then
  WriteLog('������ ������������ �������.')
 else
  WriteLog('������ ������������ ��������.');
end;

procedure RewindHandler(SubCommand:String);
var
 tmp:String;
 tmpval,C:Integer;
 totalsongsec,cursongsec:Integer;
 cursongprc:Extended;
begin
 C:=SubCommandCount(SubCommand);
 if C>=1 then
  begin
   tmp:=ExtSubCommand(SubCommand,1);
   totalsongsec:=Form1.PosBar1.Max;
   cursongsec:=Form1.PosBar1.Position;
   cursongprc:=cursongsec*100/totalsongsec;
   if Length(tmp)>0 then
    begin
     if tmp[Length(tmp)]='%' then
      begin
       Delete(tmp,Length(tmp),1);
       if tmp[1]='+' then
        begin
         Delete(tmp,1,1);
         tmpval:=StrToIntDef(tmp,-1);
         if tmpval=-1 then
          WriteLog('��������� ������� ���������.')
         else
          begin
           if (tmpval+cursongprc)>100 then
            WriteLog('��������� ������� ���������. �� ��������� ���������� ������ �����.')
           else
            begin
             Form1.RewForwardPrc(tmpval);
             WriteLog('�������� ��������� ����� �� ' + tmp + ' ���������.');
            end;
          end;
        end
       else if tmp[1]='-' then
        begin
         Delete(tmp,1,1);
         tmpval:=StrToIntDef(tmp,-1);
         if tmpval=-1 then
          WriteLog('��������� ������� ���������.')
         else
          begin
           Form1.RewBackwardPrc(tmpval);
           if tmpval>cursongprc then
            tmp:=IntToStr(Round(cursongprc));
           WriteLog('�������� ��������� ����� �� ' + tmp + ' ���������.');
          end;
        end
       else
        begin
         tmpval:=StrToIntDef(tmp,-1);
         if tmpval=-1 then
          WriteLog('��������� ������� ���������.')
         else
          begin
           if tmpval>100 then
            WriteLog('��������� ������� ���������. �� ��������� ���������� ������ �����.')
           else
            begin
             Form1.RewExactPrc(tmpval);
             WriteLog('�������� ��������� �� ' + tmp + '-� �������.');
            end;
          end;
        end;
      end
     else
      begin
       if tmp[1]='+' then
        begin
         Delete(tmp,1,1);
         tmpval:=StrToIntDef(tmp,-1);
         if tmpval=-1 then
          WriteLog('��������� ������� ���������.')
         else
          begin
           if ((tmpval*1000)+cursongsec)>totalsongsec then
            WriteLog('��������� ������� ���������. �� ��������� ���������� ������ �����.')
           else
            begin
             Form1.RewForward(tmpval);
             WriteLog('�������� ��������� ����� �� ' + tmp + ' ������.');
            end;
          end;
        end
       else if tmp[1]='-' then
        begin
         Delete(tmp,1,1);
         tmpval:=StrToIntDef(tmp,-1);
         if tmpval=-1 then
          WriteLog('��������� ������� ���������.')
         else
          begin
           Form1.RewBackward(tmpval);
           if (tmpval*1000)>cursongsec then
            tmp:=IntToStr(Round(cursongsec/1000));
           WriteLog('�������� ��������� ����� �� ' + tmp + ' ������.');
          end;
        end
       else
        begin
         tmpval:=StrToIntDef(tmp,-1);
         if tmpval=-1 then
          WriteLog('��������� ������� ���������.')
         else
          begin
           if (tmpval*1000)>totalsongsec then
            WriteLog('��������� ������� ���������. �� ��������� ���������� ������ �����.')
           else
            begin
             Form1.RewExact(tmpval);
             WriteLog('�������� ��������� �� ' + tmp + '-� �������.');
            end;
          end;
        end;
      end;
    end;
  end
 else HelpHandler('rewind');
end;

procedure AddCmdHandler(SubCommand:String);
var
 C:Integer;
 tmpcmd:TCommand;
begin
 C:=SubCommandCount(SubCommand);
 if C>=4 then
  begin
   tmpcmd.Name:=ExtSubCommand(SubCommand,1,True);
   Integer(@tmpcmd.Handler):=StrToIntDef(ExtSubCommand(SubCommand,2),0);
   tmpcmd.ShortDesc:=ExtSubCommand(SubCommand,3);
   tmpcmd.LongDesc:=ExtSubCommand(SubCommand,4);
   if Form12.AddCommand(tmpcmd) then
    WriteLog('������� ���������.')
   else
    WriteLog('������� �� ���������. ��������� �������� �������, ��� �� ������ ��������� � ��� �������������.');
  end
 else
  HelpHandler('addcmd');
end;

procedure StatsHandler(SubCommand:String);
var
 C:Integer;
 tmp:String;
begin
 C:=SubCommandCount(SubCommand);
 if C>0 then
  tmp:=ExtSubCommand(SubCommand,1,True)
 else tmp:='';
 if tmp='clear' then
  begin
   Form1.ClearStats;
   Form1.SaveStats;
   WriteLog('���������� ��������.');
   Exit;
  end
 else
  begin
   if Playing then
    Form1.UpdateStatsPlayedTime;
   Form1.UpdateStatsUptime;
   WriteLog('����� ����� ��������������� (�� ��� ������): ' + MyTimeToStr(Stats.PlayedTimeMSECThisRun/(1000 * 60 * 60 * 24),True));
   WriteLog('����� ����� ��������������� (�����): ' + MyTimeToStr((Stats.PlayedTimeMSECTotal+Stats.PlayedTimeMSECThisRun)/(1000 * 60 * 60 * 24),True));
   WriteLog('�������������� ������ (�� ��� ������): ' + IntToStr(Stats.PlayedTraxThisRun));
   WriteLog('�������������� ������ (�����): ' + IntToStr(Stats.PlayedTraxTotal));
   WriteLog('����� ����� ������ ���������: ' + MyTimeToStr(Stats.UptimeMSECTotal/(1000 * 60 * 60 * 24),True));
   WriteLog('���������� �������� ���������: ' + IntToStr(Stats.LaunchedTimesTotal));
   WriteLog('������������ ������ � �������: ' + IntToStr(Stats.ConsoleCmdsUsedTimesTotal));
  end;
end;

procedure DropChanHandler(SubCommand:String);
begin
 Form1.DropChannel;
 WriteLog('������.');
end;

procedure RDInfoHandler(SubCommand:String);
var
 ID:Integer;
 info:BASS_DEVICEINFO;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   ID:=StrToIntDef(ExtSubCommand(SubCommand,1),0);
   if BASS_RecordGetDeviceInfo(ID,info) then
    begin
     WriteLog('name: ' + info.name);
     WriteLog('driver: ' + info.driver);
    end
   else
    begin
     WriteLog('device is invalid');
    end;
  end;
end;

procedure RIInfoHandler(SubCommand:String);
var
 ID,errcode:Integer;
 info:PAnsiChar;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   ID:=StrToIntDef(ExtSubCommand(SubCommand,1),0);
   info:=BASS_RecordGetInputName(ID);
   if info=nil then
    begin
     errcode:=BASS_ErrorGetCode;
     case errcode of
      BASS_ERROR_INIT: WriteLog('BASS_RecordInit has not been successfully called');
      BASS_ERROR_ILLPARAM: WriteLog('input is invalid');
      else WriteLog('unknown problem');
     end;
    end
   else
    begin
     WriteLog(info);
    end;
  end;
end;

procedure WADInfoHandler(SubCommand:String);
var
 ID:Integer;
 info:BASS_WASAPI_DEVICEINFO;
 function BuildTypeString(tType:Integer):String;
 begin
  Result:='';
  case tType of
   BASS_WASAPI_TYPE_NETWORKDEVICE:
    Result:='Network Device';
   BASS_WASAPI_TYPE_SPEAKERS:
    Result:='Speakers';
   BASS_WASAPI_TYPE_LINELEVEL:
    Result:='Line-Level';
   BASS_WASAPI_TYPE_HEADPHONES:
    Result:='Headphones';
   BASS_WASAPI_TYPE_MICROPHONE:
    Result:='Microphone';
   BASS_WASAPI_TYPE_HEADSET:
    Result:='Headset';
   BASS_WASAPI_TYPE_HANDSET:
    Result:='Handset';
   BASS_WASAPI_TYPE_DIGITAL:
    Result:='Digital';
   BASS_WASAPI_TYPE_SPDIF:
    Result:='S/PDIF';
   BASS_WASAPI_TYPE_HDMI:
    Result:='HDMI';
   BASS_WASAPI_TYPE_UNKNOWN:
    Result:='Unknown';
   else
    Result:='Unknown';
  end;
 end;
 function BuildFlagsString(Flags:Integer):String;
 begin
  Result:='';
  if Flags=0 then
   begin
    Result:='Flags are not set.';
    Exit;
   end;
  if BASS_DEVICE_ENABLED = (Flags and BASS_DEVICE_ENABLED) then
   Result:=Result + 'ENABLED';
  if BASS_DEVICE_DEFAULT = (Flags and BASS_DEVICE_DEFAULT) then
   begin
    if Result<>'' then Result:=Result + ', ';
   Result:=Result+'DEFAULT';
   end;
  if BASS_DEVICE_INIT = (Flags and BASS_DEVICE_INIT) then
   begin
    if Result<>'' then Result:=Result + ', ';
   Result:=Result+'INIT';
   end;
  if BASS_DEVICE_INPUT = (Flags and BASS_DEVICE_INPUT) then
   begin
    if Result<>'' then Result:=Result + ', ';
   Result:=Result+'INPUT';
   end;
  if BASS_DEVICE_LOOPBACK = (Flags and BASS_DEVICE_LOOPBACK) then
   begin
    if Result<>'' then Result:=Result + ', ';
   Result:=Result+'LOOPBACK';
   end;
  if BASS_DEVICE_UNPLUGGED = (Flags and BASS_DEVICE_UNPLUGGED) then
   begin
    if Result<>'' then Result:=Result + ', ';
   Result:=Result+'UNPLUGGED';
   end;
  if BASS_DEVICE_DISABLED = (Flags and BASS_DEVICE_DISABLED) then
   begin
    if Result<>'' then Result:=Result + ', ';
   Result:=Result+'DISABLED';
   end;
 end;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   ID:=StrToIntDef(ExtSubCommand(SubCommand,1),0);
   if BASS_WASAPI_GetDeviceInfo(ID,info) then
    begin
     WriteLog('name: ' + info.name);
     WriteLog('id: ' + info.id);
     WriteLog('type: ' + BuildTypeString(info.ttype));
     WriteLog('flags: ' + BuildFlagsString(info.flags));
     WriteLog('minperiod: ' + FloatToStr(info.minperiod));
     WriteLog('defperiod: ' + FloatToStr(info.defperiod));
     WriteLog('mixfreq: ' + IntToStr(info.mixfreq));
     WriteLog('mixchans: ' + IntToStr(info.mixchans));
    end
   else
    begin
     WriteLog('device is invalid');
    end;
  end;
end;

procedure WASInfoHandler(SubCommand:String);
var
 info:BASS_WASAPI_INFO;
 ErrCode:Integer;
 function BuildFlagsString(Flags:Integer):String;
 begin
  Result:='';
  if Flags=0 then
   begin
    Result:='Flags are not set.';
    Exit;
   end;
  if BASS_WASAPI_AUTOFORMAT = (Flags and BASS_WASAPI_AUTOFORMAT) then
   Result:=Result + 'AUTOFORMAT';
  if BASS_WASAPI_BUFFER = (Flags and BASS_WASAPI_BUFFER) then
   begin
    if Result<>'' then Result:=Result + ', ';
   Result:=Result+'BUFFER';
   end;
  if BASS_WASAPI_EVENT = (Flags and BASS_WASAPI_EVENT) then
   begin
    if Result<>'' then Result:=Result + ', ';
   Result:=Result+'EVENT';
   end;
  if BASS_WASAPI_EXCLUSIVE = (Flags and BASS_WASAPI_EXCLUSIVE) then
   begin
    if Result<>'' then Result:=Result + ', ';
   Result:=Result+'EXCLUSIVE';
   end;
 end;
 function BuildFormatString(Format:Integer):String;
 begin
  Result:='';
  case Format of
   BASS_WASAPI_FORMAT_8BIT:
    Result:='8-bit integer';
   BASS_WASAPI_FORMAT_16BIT:
    Result:='16-bit integer';
   BASS_WASAPI_FORMAT_24BIT:
    Result:='24-bit integer';
   BASS_WASAPI_FORMAT_32BIT:
    Result:='32-bit integer';
   BASS_WASAPI_FORMAT_FLOAT:
    Result:='32-bit floating-point';
   else
    Result:='Unknown';
  end;
 end;
begin
 if BASS_WASAPI_GetInfo(info) then
  begin
   WriteLog('initflags: ' + BuildFlagsString(info.initflags));
   WriteLog('freq: ' + IntToStr(info.freq));
   WriteLog('chans: ' + IntToStr(info.chans));
   WriteLog('format: ' + BuildFormatString(info.format));
   WriteLog('buflen: ' + IntToStr(info.buflen));
   WriteLog('volmax: ' + FloatToStr(info.volmax));
   WriteLog('volmin: ' + FloatToStr(info.volmin));
   WriteLog('volstep: ' + FloatToStr(info.volstep));
  end
 else
  begin
   ErrCode:=BASS_ErrorGetCode;
   case ErrCode of
    BASS_ERROR_INIT:
     WriteLog('BASS_WASAPI_Init has not been successfully called.');
    else
     WriteLog('Unknown problem.');
   end;
  end;
end;

procedure WindowHandler(SubCommand:String);
var
 prm,newname,sstr:String;
 i,wid,alvl,old,nx,ny:Integer;
 found:Boolean;
 winrect:TRect;
 procedure UpdateWindowList;
 var
  wnd:hwnd;
  buff:array[0..127] of Char;
 begin
  SetLength(WindowList,0);
  wnd:=GetWindow(Form1.Handle,gw_hwndfirst);
  while wnd <> 0 do
   begin
    if (GetWindowText(wnd,buff,SizeOf(buff))<>0) then
     begin
      GetWindowText(wnd,buff,SizeOf(buff));
      if StrPas(buff)<>'Program Manager' then
       begin
        SetLength(WindowList,Length(WindowList)+1);
        WindowList[Length(WindowList)-1].Name:=StrPas(buff);
        WindowList[Length(WindowList)-1].Handle:=wnd;
       end;
     end;
    wnd:=GetWindow(wnd,gw_hwndnext);
   end;
 end;
begin
 if SubCommandCount(SubCommand)>0 then
  begin
   prm:=ExtSubCommand(SubCommand,1,True);
   if prm='update' then
    begin
     UpdateWindowList;
     WriteLog('������ ���� �������.');
    end
   else if prm='list' then
    begin
     if Length(WindowList)>0 then
      for i:= 0 to Length(WindowList)-1 do
       WriteLog(IntToStr(i+1) + ' - ' + WindowList[i].Name)
     else WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.');
    end
   else if prm='hide' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       wid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       if (wid<1) or (wid>Length(WindowList)) then
        WriteLog('����� �������� ����� ����.')
       else
        begin
         if Length(WindowList)=0 then
          WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.')
         else
          begin
           if ShowWindow(WindowList[wid-1].Handle,SW_HIDE) then
            WriteLog('���� "' + WindowList[wid-1].Name + '" ������.')
           else
            if GetLastError=ERROR_INVALID_WINDOW_HANDLE then
             WriteLog('������: ���� "' + WindowList[wid-1].Name + '" �� ����������. ���������� ��������� ������� "window update"')
            else
             WriteLog('�� ������� ������ ���� "' + WindowList[wid-1].Name + '". �������� ��� ��� ������.');
          end;
        end;
      end
     else WriteLog('����� ���� �� �����.');
    end
   else if prm='show' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       wid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       if (wid<1) or (wid>Length(WindowList)) then
        WriteLog('����� �������� ����� ����.')
       else
        begin
         if Length(WindowList)=0 then
          WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.')
         else
          begin
           SetLastError(0);
           if not ShowWindow(WindowList[wid-1].Handle,SW_SHOW) then
            begin
             if GetLastError=ERROR_INVALID_WINDOW_HANDLE then
              WriteLog('������: ���� "' + WindowList[wid-1].Name + '" �� ����������. ���������� ��������� ������� "window update"')
             else
              WriteLog('���� "' + WindowList[wid-1].Name + '" ��������.');
            end
           else
            WriteLog('�� ������� �������� ���� "' + WindowList[wid-1].Name + '". �������� ��� �� ������.');
          end;
        end;
      end
     else WriteLog('����� ���� �� �����.');
    end
   else if prm='rename' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       wid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       if (wid<1) or (wid>Length(WindowList)) then
        WriteLog('����� �������� ����� ����.')
       else
        begin
         if Length(WindowList)=0 then
          WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.')
         else
          begin
           if SubCommandCount(SubCommand)>2 then
            begin
             newname:=ExtSubCommand(SubCommand,3);
             if SetWindowText(WindowList[wid-1].Handle,PChar(newname)) then
              WriteLog('��� ���� "' + WindowList[wid-1].Name + '" ��������.')
             else
              if GetLastError=ERROR_INVALID_WINDOW_HANDLE then
               WriteLog('������: ���� "' + WindowList[wid-1].Name + '" �� ����������. ���������� ��������� ������� "window update"')
              else
               WriteLog('�� ������� �������� ��� ���� "' + WindowList[wid-1].Name + '".');
            end
           else WriteLog('����� ��� �� �������.');
          end;
        end;
      end
     else WriteLog('����� ���� �� �����.');
    end
   else if prm='alpha' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       wid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       if (wid<1) or (wid>Length(WindowList)) then
        WriteLog('����� �������� ����� ����.')
       else
        begin
         if Length(WindowList)=0 then
          WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.')
         else
          begin
           if SubCommandCount(SubCommand)>2 then
            begin
             old:=GetWindowLong(WindowList[wid-1].Handle,GWL_EXSTYLE);
             alvl:=StrToIntDef(ExtSubCommand(SubCommand,3),255);
             if alvl<0 then alvl:=0;
             if alvl>255 then alvl:=255;
             SetWindowLong(WindowList[wid-1].Handle,GWL_EXSTYLE,old or $80000);
             SetLayeredWindowAttributes(WindowList[wid-1].Handle,0,alvl,$2);
             WriteLog('������� �������������� ���� "' + WindowList[wid-1].Name + '" �������.');
            end
           else WriteLog('����� ������� �������������� �� �����.');
          end;
        end;
      end
     else WriteLog('����� ���� �� �����.');
    end
   else if prm='ghost' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       wid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       if (wid<1) or (wid>Length(WindowList)) then
        WriteLog('����� �������� ����� ����.')
       else
        begin
         if Length(WindowList)=0 then
          WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.')
         else
          begin
           old:=GetWindowLongA(WindowList[wid-1].Handle,GWL_EXSTYLE);
           SetWindowLong(WindowList[wid-1].Handle,GWL_EXSTYLE,old or WS_EX_TRANSPARENT or $80000);
           SetWindowPos(WindowList[wid-1].Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
           WriteLog('���� "' + WindowList[wid-1].Name + '" ������ �������.');
          end;
        end;
      end
     else WriteLog('����� ���� �� �����.');
    end
   else if prm='search' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       sstr:=ExtSubCommand(SubCommand,2);
       if Length(WindowList)=0 then
        WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.')
       else
        begin
         found:=False;
         for i:= 0 to Length(WindowList)-1 do
          if Form2.FindANeedleInAHaystack(sstr,WindowList[i].Name)<>0 then
           begin
            WriteLog(IntToStr(i+1) + ' - ' + WindowList[i].Name);
            found:=True;
           end;
         if not found then
          WriteLog('�� ������ ���� �� ���� �������.');
        end;
      end
     else WriteLog('������ ��� ������ �� �������.');
    end
   else if prm='move' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       wid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       if (wid<1) or (wid>Length(WindowList)) then
        WriteLog('����� �������� ����� ����.')
       else
        begin
         if Length(WindowList)=0 then
          WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.')
         else
          begin
           if SubCommandCount(SubCommand)>3 then
            begin
             nx:=StrToIntDef(ExtSubCommand(SubCommand,3),0);
             ny:=StrToIntDef(ExtSubCommand(SubCommand,4),0);
             GetWindowRect(WindowList[wid-1].Handle,winrect);
             SetWindowPos(WindowList[wid-1].Handle,HWND_TOP,nx,ny,winrect.Right-winrect.Left,winrect.Bottom-winrect.Top,0);
             WriteLog('���� "' + WindowList[wid-1].Name + '" ��������.');
            end
           else WriteLog('����� ���������� ���� �� �������.');
          end;
        end;
      end
     else WriteLog('����� ���� �� �����.');
    end
   else if prm='resize' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       wid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       if (wid<1) or (wid>Length(WindowList)) then
        WriteLog('����� �������� ����� ����.')
       else
        begin
         if Length(WindowList)=0 then
          WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.')
         else
          begin
           if SubCommandCount(SubCommand)>3 then
            begin
             nx:=StrToIntDef(ExtSubCommand(SubCommand,3),0);
             ny:=StrToIntDef(ExtSubCommand(SubCommand,4),0);
             GetWindowRect(WindowList[wid-1].Handle,winrect);
             SetWindowPos(WindowList[wid-1].Handle,HWND_TOP,winrect.Left,winrect.Top,nx,ny,0);
             WriteLog('������ ���� "' + WindowList[wid-1].Name + '" �������.');
            end
           else WriteLog('����� ������� ���� �� �������.');
          end;
        end;
      end
     else WriteLog('����� ���� �� �����.');
    end
   else if prm='topmost' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       wid:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
       if (wid<1) or (wid>Length(WindowList)) then
        WriteLog('����� �������� ����� ����.')
       else
        begin
         if Length(WindowList)=0 then
          WriteLog('� ������ ��� �� ������ ����. �������� ������� "window update" �� ���� ������������.')
         else
          begin
           SetWindowPos(WindowList[wid-1].Handle,HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
           WriteLog('���� "' + WindowList[wid-1].Name + '" ������ ������ ����.');
          end;
        end;
      end
     else WriteLog('����� ���� �� �����.');
    end
   else WriteLog('����������� �������. ��������� ������������ ����� ��� �������������� �������� "help window".');
  end
 else
  HelpHandler('window');
end;

procedure FloodHandler(SubCommand:String);
const
 kbytes=1024;
 mbytes=1048576;
 gbytes=1073741824;
var
 fpath,metr:String;
 FLOOD:TFileStream;
 C:Integer;
 fsize:Int64;
 b:Byte;
begin
 C:=SubCommandCount(SubCommand);
 if C>=2 then
  begin
   b:=0;
   fpath:=ExtSubCommand(SubCommand,1);
   fsize:=StrToIntDef(ExtSubCommand(SubCommand,2),0);
   if C>=3 then
    metr:=ExtSubCommand(SubCommand,3)
   else
    metr:='b';
   case metr[1] of
    'k': fsize:=fsize*kbytes;
    'm': fsize:=fsize*mbytes;
    'g': fsize:=fsize*gbytes;
   end;
   try
    FLOOD:=TFileStream.Create(fpath,fmOpenWrite or fmCreate);
    FLOOD.Seek(fsize-1,soEnd);
    FLOOD.Write(b,1);
    FreeAndNil(FLOOD);
    WriteLog('���� ������.');
   except
    WriteLog('�� ������� ������� ����.');
   end;
  end
 else
  HelpHandler('flood');
end;

procedure GetErrorLogHandler(SubCommand:String);
begin
 RawWriteLog(ErrorLog.Text);
end;

procedure WriteErrorLogHandler(SubCommand:String);
begin
 Form1.AddErrorLog('[�������] ' + Trim(SubCommand));
 WriteLog('������ ��������� � ��� ������.');
end;

procedure OSDHandler(SubCommand:String);
var
 cmd:String;
begin
 if not AppLoaded then WriteLog('������� "osd" ���������� �� autorun.txt')
 else
 if SubCommandCount(SubCommand)>0 then
  begin
   cmd:=ExtSubCommand(SubCommand,1,True);
   if cmd='settext' then
    begin
     if SubCommandCount(SubCommand)>1 then
      begin
       FormOSD.SetOSDText(ExtSubCommand(SubCommand,2));
       WriteLog('����� OSD ����������.');
      end
     else
      WriteLog('����� �� �����.');
    end
   else if cmd='gettext' then
    begin
     WriteLog('����� OSD: ' + FormOSD.Label1.Caption);
    end
   else if cmd='show' then
    begin
     FormOSD.ShowOSD(True);
     WriteLog('OSD �������.');
    end
   else HelpHandler('osd');
  end
 else
  HelpHandler('osd');
end;

procedure LogVKAPIHandler(SubCommand:String);
begin
 LogVKAPIToConsole:=not LogVKAPIToConsole;
 if LogVKAPIToConsole then
  WriteLog('����� ������� VKAPI � ������� �������.')
 else
  WriteLog('����� ������� VKAPI � ������� ��������.');
end;

procedure DetHandler(SubCommand:String);
var
 size:Extended;
 scc,sizeT:Integer;
 M:TExtArr;
 procedure FillMatrix;
 var
  i,j,x:Integer;
 begin
  SetLength(M,sizeT,sizeT);
  x:=0;
  for i:= 0 to sizeT-1 do
  for j:= 0 to sizeT-1 do
   begin
    x:=x+1;
    M[i,j]:=StrToFloatDef(ExtSubCommand(SubCommand,x),0);
   end;
 end;
 procedure PrintMatrix;
 var
  i,j,cw:Integer;
  tmp:String;
  function GetColWidth(cid:Integer):Integer;
  var
   i,L:Integer;
  begin
   Result:=0;
   for i:= 0 to sizeT-1 do
    begin
     L:=Length(FloatToStr(M[i,cid]));
     if L>Result then Result:=L;
    end;
  end;
  function FloatToStrFW(Value:Extended;Width:Integer):String;
  var
   i:Integer;
  begin
   Result:=FloatToStr(Value);
   if Length(Result)<Width then
    for i:= 1 to Width-Length(Result) do
     Result:=Result+' ';
  end;
 begin
  if sizeT>0 then
   for i:= 0 to sizeT-1 do
    begin
     tmp:='';
     for j:= 0 to sizeT-1 do
      begin
       cw:=GetColWidth(j);
       tmp:=tmp+FloatToStrFW(M[i,j],cw)+' ';
      end;
     WriteLog('| ' + tmp + '|');
    end;
 end;
 function Det(Matrix:TExtArr):Extended;
 var
  L,x:Integer;
  SubMatrix:TExtArr;
  procedure FillSubMatrix(num:Integer);
  var
   i,j:Integer;
  begin
   for i:= 1 to L-1 do
   for j:= 0 to L-1 do
    if j<>num then
     begin
      if j<num then
       SubMatrix[i-1,j]:=Matrix[i,j]
      else
       SubMatrix[i-1,j-1]:=Matrix[i,j];
     end;
  end;
 begin
  L:=Length(Matrix);
  case L of
   0: Result:=0;
   1: Result:=Matrix[0,0];
   2: Result:=Matrix[0,0]*Matrix[1,1] - Matrix[1,0]*Matrix[0,1];
   else
    begin
     SetLength(SubMatrix,L-1,L-1);
     Result:=0;
     for x:= 0 to L-1 do
      begin
       FillSubMatrix(x);
       Result:=Result+Power(-1,x)*Matrix[0,x]*Det(SubMatrix);
      end;
    end;
  end;
 end;
begin
 scc:=SubCommandCount(SubCommand);
 if scc>0 then
  begin
   size:=sqrt(scc);
   if Frac(size)=0 then
    begin
     sizeT:=Trunc(size);
     WriteLog('������� ' + IntToStr(sizeT)  + ' �������');
     FillMatrix;
     PrintMatrix;
     WriteLog('Det = ' + FloatToStr(Det(M)));
    end;
  end
 else HelpHandler('det');
end;

procedure VKTryAnywayHandler(SubCommand:String);
begin
 TryVKImportAnyway:=True;
 WriteLog('���������� ���������� ������������� ������ �� ��.');
end;

procedure EnRuHandler(SubCommand:String);
var
 mode:Boolean;
 str:String;
 i,L:Integer;
begin
 //if SubCommandCount(SubCommand)>0 then
  begin
   str:=SubCommand;
   L:=Length(str);
   if L>0 then
    begin
     mode:=(str[1] in ['a'..'z']) or (str[1] in ['A'..'Z']) or (str[1] in ['[',']',';',#39,',','.','{','}',':','"','<','>']);
     for i:= 1 to L do
      if mode then
       EnRu(str)
      else
       RuEn(str);
     WriteLog(str);
    end
   else WriteLog('������ �����!');
  end;
end;

procedure VKAccessTokenHandler(SubCommand:String);
var
 mode:Boolean;
 nt:String;
 i,L:Integer;
begin
  begin
   nt:=SubCommand;
   L:=Length(nt);
   if L>0 then
    begin
     VKAuth:=True;
     VKAccessToken:=nt;
     WriteLog('AccessToken �������.');
    end
   else WriteLog('������ �����!');
  end;
end;

procedure VKPretendToBeAnOfficialAppHandler(SubCommand:String);
var
 mode:Boolean;
 nt:String;
 i,L:Integer;
begin
 VKPretendOfficial:=True;
 VKAuth:=False;
 WriteLog('���������� ��������� ������������ ����������� ����������� VK ��� Android.');
end;

procedure HSDeckHandler(SubCommand:String);
var
 DS:String;
 JSON:TJSONArray;
 RawData:TByteArray;
 DSInput:TByteArray;
 DecodedData:array of Integer;
 i,x:Integer;
 buf,L,L2,L3,L4:Integer;
 //crd:TCard;
 lulkek:Boolean;
 CDL,tmp:Integer;
 procedure CleanUpDS(var DS:String);
 var
  i,L:Integer;
 begin
  DS:=Trim(DS);
  L:=Length(DS);
  if L>0 then
   begin
    i:=1;
    repeat
     if not (DS[i] in ['A'..'Z','a'..'z','0'..'9','+','/','=']) then
      begin
       Delete(DS,i,1);
       i:=i-1;
       L:=L-1;
      end;
     i:=i+1;
    until i>L;
   end;
 end;
 function FindCard(DBF:Integer):Integer;
 var
  j:Integer;
 begin
  Result:=-1;
  {for j:= 0 to CDL-1 do
   if CD.AsArray[j].I['dbfId']=DBF then
    begin
     Result:=j;
     Exit;
    end;}
 end;
 function GetClassNameByID(ID:Integer):String;
 begin
  //Result:=CD.AsArray[ID].S['cardClass'];
 end;
begin
 FillChar(RawData,32768,1);
 FillChar(DSInput,32768,1);
 DS:=SubCommand;
 CleanUpDS(DS);
 for i:= 1 to Length(DS) do
  DSInput[i-1]:=Ord(DS[i]);
 B64.Base64Decode(DSInput,Length(DS),RawData);
 SetLength(DecodedData,0);
 i:=0;
 repeat
  SetLength(DecodedData,Length(DecodedData)+1);
  DecodedData[Length(DecodedData)-1]:=ReadFromByteArr(RawData,i,buf);
  i:=i+buf;
 until (RawData[i]=1) and (RawData[i+1]=1) and (RawData[i+2]=1) and (RawData[i+3]=1) and (RawData[i+4]=1);
 L:=Length(DecodedData);
 if JSONCardData='' then
  JSONCardData:=Form1.HTTP1.Get('https://api.hearthstonejson.com/v1/latest/ruRU/cards.json');
  //Form12.RESTRequest1.Execute;
 JSONCardData:=Copy(JSONCardData,4,Length(JSONCardData)-3);
 JSON:=TJSONObject.ParseJSONValue(JSONCardData) as TJSONArray;
 CDL:=JSON.Count;
 WriteLog(IntToStr(CDL));
 if L>0 then
  if DecodedData[0]=0 then // ��������� ����. ������ ���� ����� 0
   if DecodedData[1]=1 then // ������. ������ ���� ����� 1
    begin
     if DecodedData[2]=1 then // ������ ������
      WriteLog('������: �������')
     else if DecodedData[2]=2 then
      WriteLog('������: �����������')
     else
      WriteLog('������: �����������');
     if DecodedData[3]=1 then // ������ ������� � ������. ������ ���� ����� 1
      begin
       tmp:=FindCard(DecodedData[4]);
       if tmp<>-1 then // ����� ����� ������ �� �����
        WriteLog('�����: ' + GetClassNameByID(tmp))
       else
        WriteLog('�����: �����������');
       L2:=DecodedData[5]; // ������ ������� � �������, ������� � ������ �� 1 �����
       if L2>0 then
        for i:= 6 to L2+5 do
         //if GetCardByDBF(DecodedData[i],crd) then
          //begin
           //DL.Items.Add('('+IntToStr(crd.Manacost)+') ['+GetRarityAsOneChar(crd.Rarity)+'] ' + crd.Name + ' x1');
           //AddCardToDeck(crd,1,False);
          //end
         //else
          begin
           //DL.Items.Add('���������� x1');
           //AddUnknownCardToDeck(1,False,DecodedData[i]);
          end;
       //if L2<30 then
        begin
         L3:=DecodedData[6+L2]; // ������ ������� � �������, ������� � ������ �� 2 �����
         if L3>0 then
          for i:= 7+L2 to L3+L2+6 do
           //if GetCardByDBF(DecodedData[i],crd) then
            //begin
             //DL.Items.Add('('+IntToStr(crd.Manacost)+') ['+GetRarityAsOneChar(crd.Rarity)+'] ' + crd.Name + ' x2');
             //AddCardToDeck(crd,2,False);
            //end
           //else
            begin
             //DL.Items.Add('���������� x2');
             //AddUnknownCardToDeck(2,False,DecodedData[i]);
            end;
         //if (L2+(L3*2))<30 then
          begin
           lulkek:=False;
           L4:=DecodedData[7+L2+L3]; // ������ ������� � �������, ������� � ������ ����� 2 ����
           if L4>0 then
            for i:= 8+L2+L3 to (L4*2)+L3+L2+7 do
             begin
              if lulkek then
               begin
                lulkek:=False;
                Continue;
               end
              else lulkek:=True;
              //if GetCardByDBF(DecodedData[i],crd) then
               //begin
                //DL.Items.Add('('+IntToStr(crd.Manacost)+') ['+GetRarityAsOneChar(crd.Rarity)+'] ' + crd.Name + ' x' + IntToStr(DecodedData[i+1]));
                //AddCardToDeck(crd,DecodedData[i+1],False);
               //end
              //else
               begin
                //DL.Items.Add('���������� x' + IntToStr(DecodedData[i+1]));
                //AddUnknownCardToDeck(DecodedData[i+1],False,DecodedData[i]);
               end;
             end;
          end;
        end;
      end;
    end;
end;

procedure MCMHHandler(SubCommand:String);
begin
 MinecraftMacromodHook:=not MinecraftMacromodHook;
 WriteLog('done');
end;

procedure TagHandler(SubCommand:String);
var
 resp:String;
 tmpr:PAnsiChar;
 tmp:AnsiString;
begin
 tmp:=SubCommand;
 tmpr:=TAGS_Read(MediaFile,PAnsiChar(tmp));
 resp:=UTF8ToString(tmpr);
 WriteLog(resp);
end;

procedure METARHandler(SubCommand:String);
var
 cmd,Station,resp:String;
 cc:Integer;
 function StationValid(s:String):Boolean;
 begin
  Result:=(Length(s)=4)  and
          (s[1] in ['A'..'Z']) and
          (s[2] in ['A'..'Z']) and
          (s[3] in ['A'..'Z']) and
          (s[4] in ['A'..'Z']);
 end;
begin
 cc:=SubCommandCount(SubCommand);
 if cc>0 then
  begin
   cmd:=ExtSubCommand(SubCommand,1,True);
   if cmd='get' then
    begin
     if cc>1 then
      begin
       Station:=ExtSubCommand(SubCommand,2);
       Station:=AnsiUpperCase(Station);
       if StationValid(Station) then
        begin
         resp:=Form1.HTTP1.Get('https://avwx.rest/api/metar/'+Station);
         WriteLog(resp);
        end
       else WriteLog('��� ������� - 4 ��������� �������!');
      end
     else WriteLog('������� �� �������!');
    end;
  end
 else HelpHandler('metar');
end;

procedure DeleteElement(var anArray:TCustomChannels; const aPosition:integer);
var
   lg, j : integer;
begin   
   lg := length(anArray);
   if aPosition > lg-1 then
     exit
   else if aPosition = lg-1 then begin //if is the last element
           //if TSomeType is a TObject descendant don't forget to free it
           //for example anArray[aPosition].free;
           SetLength(anArray, lg-1);
           exit;
        end;
   for j := aPosition to lg-2 do//we move all elements from aPosition+1 left...
     anArray[j] := anArray[j+1];//...with a position
   SetLength(anArray, lg-1);//now we have one element less
   //that's all...
end;

procedure ChannelHandler(SubCommand:String);
var
 cc,cl,i,num:Integer;
 cmd,ct,path:String;
 cdata:BASS_CHANNELINFO;
 tmp:HSTREAM;
begin
 cc:=SubCommandCount(SubCommand);
 if cc>0 then
  begin
   cmd:=ExtSubCommand(SubCommand,1,True);
   if cmd='list' then
    begin
     WriteLog('������:');
     if BASS_ChannelGetInfo(MediaFile,cdata) then
      WriteLog('0 - '+cdata.filename)
     else
      WriteLog('0 - �� ������������');
     cl:=Length(CustomChannels);
     if cl>0 then
      for i:= 0 to cl-1 do
       if BASS_ChannelGetInfo(CustomChannels[i],cdata) then
        WriteLog(IntToStr(i+1)+' - '+cdata.filename)
       else
        WriteLog(IntToStr(i+1)+' - �� ������������');
    end
   else if cmd='create' then
    begin
     if cc>2 then
      begin
       ct:=ExtSubCommand(SubCommand,2,True);
       path:=ExtSubCommand(SubCommand,3);
       if ct='file' then
        begin
         if FileExists(path) then
          begin
           cl:=Length(CustomChannels);
           SetLength(CustomChannels,cl+1);
           CustomChannels[cl]:=BASS_StreamCreateFile(False,PChar(path),0,0,BASS_UNICODE);
           BASS_ChannelPlay(CustomChannels[cl],True);
           WriteLog('����� ������ � ������� '+IntToStr(cl+1));
          end
         else WriteLog('���� �� ������!');
        end
       else if ct='net' then
        begin
         cl:=Length(CustomChannels);
         SetLength(CustomChannels,cl+1);
         CustomChannels[cl]:=BASS_StreamCreateURL(PChar(path),0,BASS_UNICODE,nil,nil);
         BASS_ChannelPlay(CustomChannels[cl],True);
         WriteLog('����� ������ � ������� '+IntToStr(cl+1));
        end
       else WriteLog('����������� �������! ��������� ������������ �����.');
      end
     else WriteLog('������������ ����������!');
    end
   else if cmd='delete' then
    begin
     if cc>1 then
      begin
       num:=StrToIntDef(ExtSubCommand(SubCommand,2),-1);
       if num=0 then WriteLog('�������� �������� ������ �������� ����������. ��������� ��� ������� � ������ �������.')
       else if num>0 then
        begin
         cl:=Length(CustomChannels);
         if cl>0 then
          begin
           num:=num-1;
           if num<cl then
            begin
             BASS_ChannelStop(CustomChannels[num]);
             BASS_StreamFree(CustomChannels[num]);
             DeleteElement(CustomChannels,num);
             WriteLog('����� �����.');
            end
           else WriteLog('�������� ����� ������. ��������� ������������ �����.');
          end
         else WriteLog('��� �� ������ ��������������� ������.');
        end
       else WriteLog('�������� ����� ������. ��������� ������������ �����.');
      end
     else WriteLog('������������ ����������!');
    end
   else if cmd='switch' then
    begin
     if cc>1 then
      begin
       num:=StrToIntDef(ExtSubCommand(SubCommand,2),-1);
       if num=0 then WriteLog('������ ����� ������� ��� � ����� �� ���������.')
       else if num>0 then
        begin
         cl:=Length(CustomChannels);
         if cl>0 then
          begin
           num:=num-1;
           if num<cl then
            begin
             tmp:=CustomChannels[num];
             CustomChannels[num]:=MediaFile;
             MediaFile:=tmp;
             Form1.PlayFile(False,True);
             WriteLog('����� ��������.');
            end
           else WriteLog('�������� ����� ������. ��������� ������������ �����.');
          end
         else WriteLog('��� �� ������ ��������������� ������.');
        end
       else WriteLog('�������� ����� ������. ��������� ������������ �����.');
      end
     else WriteLog('������������ ����������!');
    end
   else WriteLog('����������� �������! ��������� ������������ �����.');
  end
 else HelpHandler('channel');
end;

procedure TForm12.EWriteLog(Str:String);
begin
 WriteLog(Str);
end;

procedure TForm12.ERawWriteLog(Str:String);
begin
 RawWriteLog(Str);
end;

procedure TForm12.EWriteLogStyle(Str:String;Style:TFontStyles;Color:TColor);
begin
 WriteLogStyle(Str,Style,Color);
end;

procedure TForm12.EWriteLogStyleExtended(Str:String;Styles:TStyles);
begin
 WriteLogStyleExtended(Str,Styles);
end;

procedure TForm12.InitCommands;
var
 s:WideString;
begin
 AddCommand('help',HelpHandler,'������ �� �������� �������.','������� ������ ���������.');
 AddCommand('plist',PlistHandler,'���������� ����������.','������� ������ ���������.');
 AddCommand('test',TestHandler,'�������� �������.','������� ��� ������������ ������� �� ����� ����������. ����� �� ����� ������������ ������.');
 AddCommand('removecmd',RemoveCmdHandler,'�������� ������.','������� ������� � ������� ������.' + #13 + '�������������: removecmd [cmd1] <cmd2> <cmd3>...');
 AddCommand('hash',HashHandler,'����������� ������ � ����� ���������� �����������.','����������� ������ � ����� ���������� �����������.' + #13#13 + '������������� 1: hash [a] [file path/string] <file path/string> <file path/string>...' + #13 + 'file path/string - ���� � ����� ��� ������. ���� �� ���������� ���� ���� ����� �� ������, �� ����� ��������� ��� ������.' + #13 + '�������� ��������, ��� ����������� ������� ������ ����� ������ ���������� �����.' + #13 + 'a - �������� �����������. ����� ��������� ��������� ��������: ' + #13 + ' sha512' + #13 + ' sha384' + #13 + ' sha256' + #13 + ' sha1' + #13 + ' md4' + #13 + ' md5' + #13 + ' haval' + #13 + ' ripemd128' + #13 + ' ripemd160' + #13 + ' tiger' + #13#13 + '������������� 2: hash stop' + #13 + '���������� �����������.');
 AddCommand('exit',ExitHandler,'��������� �����.','��������� �����.');
 AddCommand('close',CloseHandler,'��������� �������.','��������� �������.');
 AddCommand('restart',RestartHandler,'���������� ������.','���������� ������.');
 AddCommand('whvideo',WHvideoHandler,'�������� �������� ����� �� ����������.','�������� �������� ����� �� ����������.' + #13 + '�������������: whvideo [Width] [Height] [DestinationWidth] [DestinationHeight]' + #13#13 + '��� ��������� ������ � ������ ����� �������� ����������:' + #13 + 'hd - 1280x720' + #13 + 'fullhd - 1920x1080' + #13 + '4k - 3840x2160' + #13 + '8k - 7680x4320' + #13 + '16k - 15360x8640' + #13#13 + '�������� ������� "whvideo 500 600 fullhd" ������������ ������� "whvideo 500 600 1920 1080"');
 AddCommand('time',TimeHandler,'������� ���� � �����.','������� ���� � �����.');
 AddCommand('systeminfo',SystemInfoHandler,'���������� � �������.','���������� � �������.');
 AddCommand('cmdtofile',CmdToFileHandler,'���������� ������� � ������ ���������� � ����.','���������� ������� � ������ ���������� � ����.' + #13 + '�������������: cmdtofile [FilePath] [command] <attr1> <attr2>...');
 AddCommand('timer',TimerHandler,'���������� �� �������.','���������� ������ �� �������. (��� ������ ��������, ��������� � ���� "����� ���������� ���������������")' + #13#13 + '������������� 1: timer' + #13 + '�������� ������� �������. ������� ��� ���, � ���� �������, ������� ������� ��������.' + #13#13 + '������������� 2: timer stop' + #13 + '��������� �������.' + #13#13 + '������������� 3: timer resume' + #13
 + '������������� �������.' + #13#13 + '������������� 4: timer [time] <metrics> <time2> <metrics>...' + #13 + '��������� �������. time - �����. �� ��������� ������� � ��������, �� ��� ����� �������� ������ �������������� �������� metrics. �� ����� ��������� �������� ��������: ' + #13 + ' s - �������' + #13 + ' m - ������' + #13 + ' h - ����' + #13 + ' d - �����' + #13 + '����� ������� ��������� �������� �������, ����� ��� �����������. ��������: timer 2 h 30 m' + #13 + '��� �� �������� ��������, ��� metrics �������������� ��������. �� ����, ����� �������� � ���: timer 3 h 40 43 64 21 m 40 m 43 59');
 AddCommand('hscrl',hscrlHandler,'������������ �������������� ���������.','������������ �������������� ���������.');
 AddCommand('clear',ClearHandler,'������� �������.','������� �������.');
 AddCommand('title',TitleHandler,'������� ��������� ���� �������.','������� ��������� ���� �������.');
 CommandsCount:=59;
 SetLength(Commands,CommandsCount);
 Commands[16].Name:='about';
 Commands[16].Handler:=AboutHandler;
 Commands[16].ShortDesc:='� ���������.';
 Commands[16].LongDesc:='� ���������.';
 Commands[17].Name:='restorewinvol';
 Commands[17].Handler:=RestoreWinVolHandler;
 Commands[17].ShortDesc:='�������������� ������ ������ ����� � Windows ����� �������� ������.';
 Commands[17].LongDesc:='�������������� ������ ������ ����� � Windows ����� �������� ������.' + #13#13 + '������������� 1: restorewinvol [value]' + #13 + '���������� ����� ������� ��������� Windows �� ��������� �������� ����� �������� ������. value - �������� �� 0 �� 100' + #13#13 + '������������� 2: restorewinvol clear' + #13 + '�� ������ ������� ���������';
 Commands[18].Name:='remote';
 Commands[18].Handler:=WebFaceHandler;
 Commands[18].ShortDesc:=APP_NAME + ' Remote. [ALPHA]';
 Commands[18].LongDesc:=APP_NAME + ' Remote. [ALPHA]' + #13#13 + '������������� 1: remote [Port]' + #13 + '��������� Remote �� ��������� �����.' + #13#13 + '������������� 2: remote stop' + #13 + '��������� Remote.';
 Commands[19].Name:='dinfo';
 Commands[19].Handler:=DInfoHandler;
 Commands[19].ShortDesc:='���������� �� ���������� ���������������. [DEBUG]';
 Commands[19].LongDesc:='���������� �� ���������� ���������������. [DEBUG]';
 Commands[20].Name:='setwinvol';
 Commands[20].Handler:=SetWinVolHandler;
 Commands[20].ShortDesc:='��������� ������ ������ ����� � Windows.';
 Commands[20].LongDesc:='��������� ������ ������ ����� � Windows.' + #13#13 + '�������������: setwinvol [value]' + #13 + '���������� ����� ������� ��������� Windows �� ��������� ��������. value - �������� �� 0 �� 100';
 Commands[21].Name:='qe';
 Commands[21].Handler:=QEHandler;
 Commands[21].ShortDesc:='������� ����������� ���������.';
 Commands[21].LongDesc:='������� ����������� ���������.' + #13#13 + '�������������: qe [a] [b] [c]';
 Commands[22].Name:='setspecmode';
 Commands[22].Handler:=SetSpecModeHandler;
 Commands[22].ShortDesc:='��������� ����������� ������ ������������.';
 Commands[22].LongDesc:='��������� ����������� ������ ������������.' + #13#13 + '�������������: setspecmode [ID]' + #13 + 'ID - ����� ������ ������������. ��������: �� 0 �� ' + IntToStr(SPEC_MODES_COUNT-1) + '.' + #13#13 + '0 - �����������' + #13 + '1 - ��������������� ������' + #13 + '2 - �������������' + #13 + '3 - �����������' + #13 + '4 - ������������� �����������';
 Commands[23].Name:='warmup';
 Commands[23].Handler:=WarmUpHandler;
 Commands[23].ShortDesc:='�������� ����������, ���� �������� ��� �� 100%.';
 Commands[23].LongDesc:='�������� ����������, ���� �������� ��� �� 100%.' + #13#13 + '�������������: warmup [CMD]' + #13 + '�������� CMD:' + #13 + 'start - ������ ��������' + #13 + 'stop - ��������� ��������';
 Commands[24].Name:='var';
 Commands[24].Handler:=VarHandler;
 Commands[24].ShortDesc:='���������� �����������.';
 Commands[24].LongDesc:='���������� �����������. get, set, list. �� �� �����.';
 Commands[25].Name:='batteryinfo';
 Commands[25].Handler:=BatteryInfoHandler;
 Commands[25].ShortDesc:='���������� � �������.';
 Commands[25].LongDesc:='���������� � �������.';
 Commands[26].Name:='roll';
 Commands[26].Handler:=RollHandler;
 Commands[26].ShortDesc:='������ ��������� �����.';
 Commands[26].LongDesc:='�������� ��������� �����.' + #13#13 + '������������� 1: roll' + #13 + '��������� ����� � ��������� �� 1 �� 100' + #13#13 + '������������� 2: roll [x]' + #13 + '��������� ����� � ��������� �� 1 �� x' + #13#13 + '������������� 3: roll [x] [y]' + #13 + '��������� ����� � ��������� �� x �� y' + #13#13 + '����� ������� ������������� �����';
 Commands[27].Name:='startin';
 Commands[27].Handler:=StartInHandler;
 Commands[27].ShortDesc:='������ ��������������� �� �������.';
 Commands[27].LongDesc:='������ ��������������� �� �������.' + #13#13 + '�������������: startin [time] <metrics> <time2> <metrics>...' + #13 + '��������� ������� �� ������ ���������������. time - �����. �� ��������� ������� � ��������, �� ��� ����� �������� ������ �������������� �������� metrics. �� ����� ��������� �������� ��������: ' + #13 + ' s - �������' + #13 + ' m - ������' + #13 + ' h - ����' + #13 + ' d - �����' + #13 + '����� ������� ��������� �������� �������, ����� ��� �����������. ��������: startin 2 h 30 m' + #13 + '��� �� �������� ��������, ��� metrics �������������� ��������. �� ����, ����� �������� � ���: startin 30 2 m';
 Commands[28].Name:='getcmdaddr';
 Commands[28].Handler:=GetCmdAddrHandler;
 Commands[28].ShortDesc:='�������� ����� ����������� �������.';
 Commands[28].LongDesc:='�������� ����� ����������� �������.' + #13 + '��������� ��� ������� ��������� � ���, ��� �� ����� ������, ��� �������.';
 Commands[29].Name:='setcmdaddr';
 Commands[29].Handler:=SetCmdAddrHandler;
 Commands[29].ShortDesc:='�������� ����� ����������� �������.';
 Commands[29].LongDesc:='�������� ����� ����������� �������.' + #13 + '��������� ��� ������� ��������� � ���, ��� �� ����� ������, ��� �������.';
 Commands[30].Name:='setvolume';
 Commands[30].Handler:=SetVolumeHandler;
 Commands[30].ShortDesc:='�������� ��������� ���������������.';
 Commands[30].LongDesc:='�������� ��������� ���������������.' + #13#13 + '�������������: setvolume [Level]' + #13 + '��������� ��������� ��������������� �� �������� �������.' + #13 + 'Level ����� ��������� �������� �� 0 �� 1000.';
 Commands[31].Name:='setplayspeed';
 Commands[31].Handler:=SetPlaySpeedHandler;
 Commands[31].ShortDesc:='�������� �������� ���������������.';
 Commands[31].LongDesc:='�������� �������� ���������������.' + #13#13 + '�������������: setplayspeed [Level]' + #13 + '��������� �������� ��������������� �� �������� �������.' + #13 + 'Level ����� ��������� �������� 0 ��� �� 100 �� 100000.' + #13 + '(0 - ���������� ��������)';
 Commands[32].Name:='setbalance';
 Commands[32].Handler:=SetBalanceHandler;
 Commands[32].ShortDesc:='�������� ������ ������ � ������� �������.';
 Commands[32].LongDesc:='�������� ������ ������ � ������� �������.' + #13#13 + '�������������: setbalance [Level]' + #13 + '��������� ������� ������ � ������� ������� �� �������� �������.' + #13 + 'Level ����� ��������� �������� �� -1000 �� 1000.';
 Commands[33].Name:='setplaydevice';
 Commands[33].Handler:=SetPlayDeviceHandler;
 Commands[33].ShortDesc:='������� ���������� ��������������� (���� � ��� �� ���������).';
 Commands[33].LongDesc:=MakeLongDescStringForSetPlayDeviceCmd;
 Commands[34].Name:='togglereverb';
 Commands[34].Handler:=ToggleReverbHandler;
 Commands[34].ShortDesc:='���/���� ������ ������������.';
 Commands[34].LongDesc:='���/���� ������ ������������.';
 Commands[35].Name:='rewind';
 Commands[35].Handler:=RewindHandler;
 Commands[35].ShortDesc:='��������� ���������������� ����� �����, ����� ��� �� ���������� �������.';
 Commands[35].LongDesc:='��������� ���������������� ����� �����, ����� ��� �� ���������� �������.' + #13#13 + '�������������: rewind <+/->[num]<%>' + #13 + 'num - �����' + #13#13 + '�������:' + #13#13 + 'rewind 20 - ��������� �� 20-� �������' + #13 + 'rewind +10 - ��������� �� 10 ������ �����' + #13 + 'rewind -10 - ��������� �� 10 ������ �����' + #13 + 'rewind 50% - ��������� �� 50-� �������' + #13 + 'rewind +20% - ��������� �� 20 ��������� �����' + #13 + 'rewind -10% - ��������� �� 10 ��������� �����';
 Commands[36].Name:='addcmd';
 Commands[36].Handler:=AddCmdHandler;
 Commands[36].ShortDesc:='���������� ������.';
 Commands[36].LongDesc:='��������� ������� � ������� ������.' + #13#13 + '�������������: addcmd [name] [addr] [sd] [ld]' + #13 + 'name - �������� �������. �� ������ ��������� � ��� �������������.' + #13 + 'addr - ����� ���������-����������� �������. ������ � ���������� ����.' + #13 + 'sd - ������� ��������. ��������� � ������ ������ (help).' + #13 + 'ld - ��������� ��������. ��������� ��� ������� ���������� �������� �������� help';
 Commands[37].Name:='stats';
 Commands[37].Handler:=StatsHandler;
 Commands[37].ShortDesc:='����������.';
 Commands[37].LongDesc:='����������.' + #13#13 + '������������� 1: stats' + #13 + '����� ����������' + #13#13 + '������������� 2: stats clear' + #13 + '�������� ����������';
 Commands[38].Name:='dropchan';
 Commands[38].Handler:=DropChanHandler;
 Commands[38].ShortDesc:='�������� ������� ����� ���������������.';
 Commands[38].LongDesc:='�������� ������� ����� ���������������..' + #13#13 + '�������������: dropchan';
 Commands[39].Name:='rdinfo';
 Commands[39].Handler:=RDInfoHandler;
 Commands[39].ShortDesc:='���������� �� ���������� ������. [DEBUG]';
 Commands[39].LongDesc:='���������� �� ���������� ������. [DEBUG]';
 Commands[40].Name:='riinfo';
 Commands[40].Handler:=RIInfoHandler;
 Commands[40].ShortDesc:='���������� �� ��������� ������. [DEBUG]';
 Commands[40].LongDesc:='���������� �� ��������� ������. [DEBUG]';
 Commands[41].Name:='wadinfo';
 Commands[41].Handler:=WADInfoHandler;
 Commands[41].ShortDesc:='���������� �� ���������� WASAPI. [DEBUG]';
 Commands[41].LongDesc:='���������� �� ���������� WASAPI. [DEBUG]';
 Commands[42].Name:='wasinfo';
 Commands[42].Handler:=WASInfoHandler;
 Commands[42].ShortDesc:='���������� � WASAPI. [DEBUG]';
 Commands[42].LongDesc:='���������� � WASAPI. [DEBUG]';
 Commands[43].Name:='window';
 Commands[43].Handler:=WindowHandler;
 Commands[43].ShortDesc:='�������� � ��������.';
 Commands[43].LongDesc:='�������� � ��������.' + #13#13 + '������������� 1: window update' + #13 + '���������� ������ ����. ���������� ������������ ����� ������� ����������.' + #13#13 + '������������� 2: window list' + #13 + '����� ������� ������ ����.' + #13#13 + '������������� 3: window search [str]' + #13 + '����� ���� �� ���������.' + #13 + 'str - ������ ������. ����� ������ �� ���������.' + #13#13 + '������������� 4: window hide [wnum]' + #13 + '������ ����.' + #13 + 'wnum - ����� ����.' + #13#13 + '������������� 5: window show [wnum]'
  + #13 + '�������� ����.' + #13 + 'wnum - ����� ����.' + #13#13 + '������������� 6: window rename [wnum] [name]' + #13 + '�������� ��������� ����.' + #13 + 'wnum - ����� ����.' + #13 + 'name - ����� ���������.' + #13#13 + '������������� 7: window alpha [wnum] [level]' + #13 + '���������� ������� �������������� ����.'
  + #13 + 'wnum - ����� ����.' + #13 + 'level - ������� �� 0 �� 255. (0 - ��������� ����������, 255 - ��������� ������������).' + #13#13 + '������������� 8: window move [wnum] [x] [y]' + #13 + '����������� ���� �� ��������� ���������� (����������� ���������� �������� ������ ����).' + #13 + '(����� (0,0) - ������� ����� ���� ������)' + #13 + 'wnum - ����� ����.' + #13 + 'x - ���������� �� ��� X.' + #13 + 'y - ���������� �� ��� Y.' + #13#13 + '������������� 9: window resize [wnum] [width] [height]' + #13 + '�������� ������ ���� �� ���������.' + #13 + 'wnum - ����� ����.' + #13 + 'width - ������.' + #13 + 'height - ������.'
  + #13#13 + '������������� 10: window ghost [wnum]' + #13 + '���� ����� ������ ������ � �� ��������� �� �������, ��������� �� ������ ����.' + #13 + 'wnum - ����� ����.'+ #13#13 + '������������� 11: window topmost [wnum]' + #13 + '���� ����� ������ ������.' + #13 + 'wnum - ����� ����.';
 Commands[44].Name:='geterrorlog';
 Commands[44].Handler:=GetErrorLogHandler;
 Commands[44].ShortDesc:='�������� ��� ������.';
 Commands[44].LongDesc:='�������� ��� ������.';
 Commands[45].Name:='writeerrorlog';
 Commands[45].Handler:=WriteErrorLogHandler;
 Commands[45].ShortDesc:='������� ������ � ��� ������.';
 Commands[45].LongDesc:='������� ������ � ��� ������.';
 Commands[46].Name:='flood';
 Commands[46].Handler:=FloodHandler;
 Commands[46].ShortDesc:='������� ���� ���������� �������.';
 Commands[46].LongDesc:='������� ���� ���������� �������.' + #13#13 + '�������������: flood [path] [size] <metrics>' + #13 + 'path - ���� � �����.' + #13 + 'size - ������ �����. (��-��������� ������� � ������)' + #13 + 'metrics - ��. ���������. ��������:' + #13 + ' k - ��������' + #13 + ' m - ��������' + #13 + ' g - ��������' + #13 + '���� �������� �� ������ ��� ������ �������, �� ���������, ��� ������ ����� � ������.';
 Commands[47].Name:='osd';
 Commands[47].Handler:=OSDHandler;
 Commands[47].ShortDesc:='���������� OSD.';
 Commands[47].LongDesc:='���������� OSD.' + #13#13 + '������������� 1: osd settext [text]' + #13 + '���������� ����� OSD.' + #13#13 + '������������� 2: osd gettext' + #13 + '�������� ����� OSD.' + #13#13 + '������������� 3: osd show' + #13 + '�������� OSD.';
 Commands[48].Name:='logvkapi';
 Commands[48].Handler:=LogVKAPIHandler;
 Commands[48].ShortDesc:='������������ ������ ������� VKAPI � �������.';
 Commands[48].LongDesc:='������������ ������ ������� VKAPI � �������.';
 Commands[49].Name:='det';
 Commands[49].Handler:=DetHandler;
 Commands[49].ShortDesc:='������������ �������.';
 Commands[49].LongDesc:='������������ �������.';
 Commands[50].Name:='vktryanyway';
 Commands[50].Handler:=VKTryAnywayHandler;
 Commands[50].ShortDesc:='����������� ��������� �� �����������.';
 Commands[50].LongDesc:='����������� ��������� �� �����������.';
 Commands[51].Name:='enru';
 Commands[51].Handler:=EnRuHandler;
 Commands[51].ShortDesc:='��������� ����� �� ������������ ���������.';
 Commands[51].LongDesc:='��������� ����� �� ������������ ���������.';
 Commands[52].Name:='vkaccesstoken';
 Commands[52].Handler:=VKAccessTokenHandler;
 Commands[52].ShortDesc:='������������� ��������� ��������� ����� ��� VK API.';
 Commands[52].LongDesc:='������������� ��������� ��������� ����� ��� VK API.';
 Commands[53].Name:='vkpretendtobeanofficialapp';
 Commands[53].Handler:=VKPretendToBeAnOfficialAppHandler;
 Commands[53].ShortDesc:='������������ ����������� ����������� VK ��� Android.';
 Commands[53].LongDesc:='������������ ����������� ����������� VK ��� Android.';
 Commands[54].Name:='hsdeck';
 Commands[54].Handler:=HSDeckHandler;
 Commands[54].ShortDesc:='��������� deckstring.';
 Commands[54].LongDesc:='��������� deckstring.';
 Commands[55].Name:='mcmh';
 Commands[55].Handler:=MCMHHandler;
 Commands[55].ShortDesc:='����� �������� �������� ����� � ���� Minecraft, ��� ������� �������������� Macro Mod.';
 Commands[55].LongDesc:='����� �������� �������� ����� � ���� Minecraft, ��� ������� �������������� Macro Mod.';
 Commands[56].Name:='tag';
 Commands[56].Handler:=TagHandler;
 Commands[56].ShortDesc:='Tags.';
 Commands[56].LongDesc:='Tags.'+#13#13+'%TITL  - ��������'+#13+'%ARTI  - �����������'+#13+'%ALBM  - ������'+#13+'%GNRE  - ����'+#13+'%YEAR  - ���'+#13+'%CMNT  - �����������'+#13+'%TRCK  - ����� �����'+#13+'%COMP  - ����������'+#13+'%COPY  - ��������'+#13+'%SUBT  - ��������'+#13+'%AART  - ����������� �������'+#13+'%DISC  - ����� �����';
 Commands[57].Name:='metar';
 Commands[57].Handler:=METARHandler;
 Commands[57].ShortDesc:='��������� � ����������� ������ METAR.';
 Commands[57].LongDesc:='��������� � ����������� ������ METAR.'+#13+'��� ��������� ������ ����� ��������!';
 Commands[58].Name:='channel';
 Commands[58].Handler:=ChannelHandler;
 Commands[58].ShortDesc:='������ � ��������.';
 Commands[58].LongDesc:='������ � ��������.'+#13#13+'��� �� ���� ����� �������� ������ � ����� ������� � �� ������������� ��������� ������ ������������.'+#13+'� ������� ���� ������� �� ������ ��������� ��� ������ ���.'
   +#13#13+'�������������: channel [cmd] <args>'+#13+'cmd - �������.'+#13+'args - Ÿ ���������.'+#13#13+'������ ������ � ����������:'+#13+'list - ������ �������.'+#13+' ���������� ���. ���������� ������ ������������ �������.'+#13+' ����� ��� ������� 0 - ����������� �������. ���������� ������, �������� �������� ����������.'
   +#13+' * ����� �������, ���� �������� ������� � ������ �������.'+#13#13+'create - ������� �����. ���������:'+#13+' type - ��� ������. file - ���� �� ����������, net - ���� ��� ����� � ���������.'+#13+' path - ���������� ���� � ����� ��� ������.'+#13#13+'delete - ������� �����. ���������:'+#13+' num - ����� ������. ����� �������� �������� channel list.'+#13#13+'switch - �������� ����� ������� � �������. ���������:'+#13;
 Commands[58].LongDesc:=Commands[58].LongDesc+' num - ����� ������. ����� �������� �������� channel list.'+#13+' * ����� num ������� ��� ���������� ������, � ������� ������� ����� ������� �� ����� num.';
end;

procedure TForm12.RemakeSortedCmdList;
var
 i,L:Integer;
begin
 L:=Length(Commands);
 if L>0 then
  begin
   SortedCmdList.Clear;
   for i:= 0 To L-1 Do
    SortedCmdList.Add(Commands[i].Name);
   SortedCmdList.Sort;
  end;
end;

function TForm12.AddCommand(Cmd:TCommand):Boolean;
var
 L,i:Integer;
begin
 Cmd.Name:=LowerCase(Trim(Cmd.Name));
 L:=Length(Commands);
 for i:= 0 To L-1 Do
  if Commands[i].Name=Cmd.Name then
   begin
    Result:=False;
    Exit;
   end;
 CommandsCount:=L+1;
 SetLength(Commands,CommandsCount);
 Commands[L]:=Cmd;
 RemakeSortedCmdList;
 Result:=True;
end;

function TForm12.AddCommand(Name:String;Handler:TCommandHandler;ShortDesc,LongDesc:String;ExternalProc:Boolean=False;ExternalHandler:TExternalHandler=nil):Boolean;
var
 tmpc:TCommand;
begin
 tmpc.Name:=Name;
 tmpc.Handler:=Handler;
 tmpc.ShortDesc:=ShortDesc;
 tmpc.LongDesc:=LongDesc;
 tmpc.ExternalProc:=ExternalProc;
 tmpc.ExternalHandler:=ExternalHandler;
 Result:=AddCommand(tmpc);
end;

function TForm12.RemoveCommand(Name:String):Boolean;
var
 i,j,L:Integer;
begin
 Result:=False;
 L:=Length(Commands);
 Name:=LowerCase(Trim(Name));
 if L>0 then
  for i:= 0 To L-1 Do
   if Commands[i].Name=Name then
    begin
     for j:= i To L-2 Do
      Commands[j]:=Commands[j+1];
     CommandsCount:=L-1;
     SetLength(Commands,CommandsCount);
     Result:=True;
     RemakeSortedCmdList;
     Exit;
    end;
end;

procedure TForm12.RESTRequest1AfterExecute(Sender: TCustomRESTRequest);
begin
 ShowMessage(RESTResponse1.Content);
end;

function TForm12.GetCommandID(Cmd:String):Integer;
var
 i:Integer;
begin
 Result:=-1;
 for i:= 0 To Length(Commands)-1 Do
  if Cmd=Commands[i].Name then
   if not InCommandsBlacklist(Cmd) then
    begin
     Result:=i;
     Exit;
    end
   else
    begin
     Result:=-2;
     Exit;
    end;
end;

function TForm12.NormalizeSemicolons(RawCommand:String):String;
var
 i,L:Integer;
 IgnoreSemicolon:Boolean;
begin
 RawCommand:=Trim(RawCommand);
 L:=Length(RawCommand);
 IgnoreSemicolon:=False;
 if L>0 then
  begin
   i:=0;
   repeat
    i:=i+1;
    if RawCommand[i]='"' then
     IgnoreSemicolon:=not IgnoreSemicolon;
    if (RawCommand[i]=';') and (not IgnoreSemicolon) then
     if RawCommand[i+1]=';' then
      begin
       Delete(RawCommand,i,1);
       i:=i-1;
       L:=L-1;
     end;
   until i=L;
   if RawCommand[L]=';' then Delete(RawCommand,L,1);
   if RawCommand[1]=';' then Delete(RawCommand,1,1);
  end;
 Result:=RawCommand;
end;

function TForm12.GetRawCommandsCount(RawCommand:String):Integer;
var
 i,L:Integer;
 IgnoreSemicolon:Boolean;
begin
 Result:=0;
 L:=Length(RawCommand);
 IgnoreSemicolon:=False;
 if L>0 then
  begin
   Result:=1;
   for i:= 1 To L Do
    begin
     if RawCommand[i]='"' then
      IgnoreSemicolon:=not IgnoreSemicolon;
     if (RawCommand[i]=';') and (not IgnoreSemicolon) then
      Result:=Result+1;
    end;
  end;
end;

function TForm12.GetRawCommandPos(RawCommand:String;Num:Integer):Integer;
var
 i,L,count:Integer;
 IgnoreSemicolon:Boolean;
begin
 count:=0;
 Result:=0;
 L:=Length(RawCommand);
 IgnoreSemicolon:=False;
 if L>0 then
  begin
   if Num=1 then
    begin
     Result:=1;
     Exit;
    end
   else
    for i:= 1 To L Do
     begin
      if RawCommand[i]='"' then
       IgnoreSemicolon:=not IgnoreSemicolon;
      if (RawCommand[i]=';') and (not IgnoreSemicolon) then
       begin
        count:=count+1;
        if count=Num-1 then
         begin
          Result:=i+1;
          Exit;
         end;
       end;
     end;
  end;
end;

function TForm12.ExtRawCommand(RawCommand:String;Num:Integer):String;
var
 start,i,L:Integer;
 IgnoreSemicolon:Boolean;
begin
 start:=GetRawCommandPos(RawCommand,Num);
 IgnoreSemicolon:=False;
 L:=Length(RawCommand);
 for i:= start To L Do
  begin
   if RawCommand[i]='"' then
    IgnoreSemicolon:=not IgnoreSemicolon;
   if ((RawCommand[i]=';') and (not IgnoreSemicolon)) or (i=L) then
    begin
     Result:=Trim(Copy(RawCommand,start,i-start+1));
     if Length(Result)>0 then
      if Result[Length(Result)]=';' then Delete(Result,Length(Result),1);
     Exit;
    end;
  end;
end;

procedure TForm12.ParseCommand(RawCommand:String;History:Boolean=False);
var
 MainCommand,SubCommand,Hashed:String;
 i,L,CommandID,C:Integer;
 es:TStyles;
begin
 if History then AddHistory(RawCommand);
 SetLength(es,2);
 es[0].Start:=0;
 es[0].Length:=1;
 es[0].Style:=[fsBold];
 es[0].Color:=clRed;
 es[1].Start:=2;
 es[1].Length:=Length(RawCommand);
 es[1].Style:=[];
 es[1].Color:=clGreen;
 L:=Length(RawCommand);
 i:=0;
 repeat
  i:=i+1;
 until (RawCommand[i]=' ') or (i=L);
 if i<L then
  begin
   SetLength(es,3);
   es[1].Length:=i;
   es[2].Start:=i+1;
   es[2].Length:=Length(RawCommand)-i+1;
   es[2].Style:=[];
   es[2].Color:=clPurple;
  end;
 WriteLogStyleExtended('> ' + RawCommand,es);
 Hashed:=SHA512(RawCommand);
 if Hashed='C55B42784FD64C13CC298FBD6209423340F3EE238EEDAF2D78D04B1001EDC520824B0544F60993116EA2DB70492A242630D0410290D5F86317AC7FDF6011F56C' then // FluttershyIsBestPony
  begin
   {if AppLoaded then
    begin}
     WriteLog('��� �������, ������� ����� �������, ��������������!');
     Unlocked:=True;
    {end
   else
    WriteLog('������������� ������ �� �������� �� �����������.');}
   Exit;
  end;
 if Hashed='181BB6DE826743B62E822B2B33C443EB9044A744913603B76D31DC528AE0D5DED7E88EFDBFAAA6A21E2B256011852778591617E2D44A061E80A7A7496EB52673' then // IamNotBrony
  begin
   WriteLog('��� �������, ������� ����� �������, �������������!');
   Unlocked:=False;
   Exit;
  end;
 if Hashed='1D96EEE97C49CA64CD53C32B1F21FA1A16ECA8ACD9EC9BAB38B6660D20C3A9C7DFFE446B037B28055F29440CAEF956ECA0A50DCCE377235EDD8DDABFD5E26ECE' then // MadTrax
  begin
   uFMOD_PlaySong(@xm,Length(xm),XM_MEMORY);
   WriteLog('����� ���������� ������ StopIt');
   Exit;
  end;
 if Hashed='6A378E5FF22491989B6A82B7BF67FC0651222D7DABC7F81A5C1F25403D5CC9CF57BC6061309BAFFD250FABAAD3A96A11213FA3C49FFD176404B9B82517F9DF12' then // StopIt
  begin
   uFMOD_StopSong;
   WriteLog('�����������');
   Exit;
  end;
 if Hashed='2964BF6C35B281020463284902150FC75DF543D31A2C1A94FBB2E6E18D935BBDF410E79D79CB3DC28E4B3CFA3C916884C9D6E170C16A8CC1DE51DE4E8BE14D6F' then // 4 8 15 16 23 42
  begin
   WriteLog('108');
   Exit;
  end;
 if Hashed='EA0F546B977922359418984997C0BD73967696253CB5032E50C0B819AD941767B755FAD27F5551CAC3276C2482BB896BDBD9860083770BB9F93D24C209E88BFD' then // APB Reloaded
  begin
   if not Fantom then
    begin
     FantomChan:=BASS_StreamCreateFile(True,@fantomenkf,0,SizeOf(fantomenkf),0);
     Fantom:=FantomChan<>0;
    end;
   if Fantom then
    BASS_ChannelPlay(FantomChan,True);
   Exit;
  end;
 RawCommand:=Normalize(RawCommand);
 L:=Length(RawCommand);
 if L>0 then
  begin
   i:=0;
   repeat
    i:=i+1;
   until (RawCommand[i]=' ') or (i=L);
   MainCommand:=Trim(Copy(RawCommand,1,i));
   SubCommand:=Trim(Copy(RawCommand,i+1,L-i));
    C:=SubCommandCount(SubCommand);
    if C>1 then
     if ExtSubCommand(SubCommand,C-1)='>' then
      begin
       CmdToFileHandler(ExtSubCommand(SubCommand,C) + ' ' + Copy(RawCommand,1,Length(RawCommand)-Length(ExtSubCommand(SubCommand,C))-3));
       Exit;
      end
     else if ExtSubCommand(SubCommand,C-1)='>>' then
      begin
       CmdToFile2Handler(ExtSubCommand(SubCommand,C) + ' ' + Copy(RawCommand,1,Length(RawCommand)-Length(ExtSubCommand(SubCommand,C))-4));
       Exit;
      end;
   CommandID:=GetCommandID(LowerCase(MainCommand));
   if CommandID=-1 then
    begin
     WriteLog('������� "' + MainCommand + '" �� ����������. ��������� ������������ ����� ��� �������������� �������� help.');
    end
   else if CommandID=-2 then
    begin
     WriteLog('������� "' + MainCommand + '" �������������, ��� ��� ��� ���� �� �����. ��� ������������� ����� ������.');
     WriteLog('���� �� �� �� ������, ��� ��� ���� ����� � �� ����� ������, ��� ������ �������,');
     WriteLog('�� ���� �� ������ ������, ���� ������� ������ ���������� � ��� ������.');
    end
   else
    begin
     Stats.ConsoleCmdsUsedTimesTotal:=Stats.ConsoleCmdsUsedTimesTotal+1;
     {if Commands[CommandID].ExternalProc then
      Commands[CommandID].ExternalHandler(SubCommand)
     else}
      Commands[CommandID].Handler(SubCommand);
    end;
  end;
end;

procedure TForm12.ParseCommands(RawCommand:String);
var
 i,j:Integer;
 ecmd:String;
begin
 AddHistory(RawCommand);
 RawCommand:=NormalizeSemicolons(RawCommand);
 i:=GetRawCommandsCount(RawCommand);
 if i>0 then
  for j:= 1 To i Do
   begin
    ecmd:=ExtRawCommand(RawCommand,j);
    if Length(ecmd)>0 then
     ParseCommand(ecmd);
   end;
end;

function TForm12.HistoryAlreadyExists(Cmd:String;var Pos:Byte):Boolean;
var
 i:Byte;
begin
 Result:=False;
 if HistoryLength>0 then
  for i:= 0 To HistoryLength-1 Do
   if Cmd=CommandsHistory[i] then
    begin
     Result:=True;
     Pos:=i;
    end;
end;

procedure TForm12.AddHistory(Cmd:String);
var
 i,Pos:Byte;
begin
 if ToFileFlag then Exit;
 if not HistoryAlreadyExists(Cmd,Pos) then
  begin
   if HistoryLength<20 then
    begin
     HistoryLength:=HistoryLength+1;
     CommandsHistory[HistoryLength-1]:=Cmd;
    end
   else
    begin
     for i:= 0 To 18 Do
      CommandsHistory[i]:=CommandsHistory[i+1];
     CommandsHistory[19]:=Cmd;
    end;
  end
 else
  begin
   if Pos<19 then
    for i:= Pos To 18 Do
     CommandsHistory[i]:=CommandsHistory[i+1];
    CommandsHistory[HistoryLength-1]:=Cmd;
  end;
 HistoryPos:=HistoryLength;
end;

procedure TForm12.NextHistory;
begin
 if (HistoryLength>0) and (HistoryPos<HistoryLength-1) then
  begin
   HistoryPos:=HistoryPos+1;
   Edit1.Text:=CommandsHistory[HistoryPos];
   Edit1.SelStart:=Length(Edit1.Text);
   Edit1.SelLength:=0;
  end;
end;

procedure TForm12.PrevHistory;
begin
 if (HistoryLength>0) and (HistoryPos>0) then
  begin
   HistoryPos:=HistoryPos-1;
   Edit1.Text:=CommandsHistory[HistoryPos];
   Edit1.SelStart:=Length(Edit1.Text);
   Edit1.SelLength:=0;
  end;
end;

procedure TForm12.CommandsAutorun;
var
 autorunpath,cmd:String;
 autorun:TStringList;
 C,i:Integer;
begin
 autorunpath:=ProgDir + 'autorun.txt';
 if FileExists(autorunpath) then
  begin
   autorun:=TStringList.Create;
   autorun.Clear;
   autorun.LoadFromFile(autorunpath);
   C:=autorun.Count;
   if C>0 then
    begin
     Form12.Show;
     for i:= 0 To C-1 Do
      begin
       cmd:=autorun.Strings[i];
       ParseCommands(cmd);
      end;
    end;
  end;
end;

procedure TForm12.Edit1KeyPress(Sender: TObject; var Key: Char);
var
 tmp:String;
begin
 TAB_mod:=True;
 if Key=#13 then
  begin
   tmp:=Trim(Edit1.Text);
   if Length(tmp)>0 then
    begin
     Edit1.Clear;
     ParseCommands(tmp);
    end;
   Key:=#0;
  end;
end;

procedure TForm12.FormCreate(Sender: TObject);
var
 tmp:TSystemInfo;
 es:TStyles;
begin
 SortedCmdList:=TStringList.Create;
 InitCommands;
 ToFile:=TStringList.Create;
 RemakeSortedCmdList;
 SetLength(es,1);
 es[0].Start:=16;
 es[0].Length:=5;
 es[0].Style:=[fsBold];
 es[0].Color:=clRed;
 WriteLogStyleExtended('������� ' + CONSOLE_VERSION,es);
 if IsSchoolboy then
  begin
   WriteLog('�������� ���������, ��� ��, ��������, ��������.');
   Form1.AddErrorLog('�������� �������� � ��������� ���������.');
  end;
 WriteLog('');
 EngageAtomCleaner;
 Form1.LoadBASSPlugins;
 if NON_PUBLIC then
  begin
   WriteLog('');
   WriteLogStyle('��� ������ ������ �� ������������� ��� ����������.',[fsBold],clRed);
   WriteLogStyle('���� ��� ��������� ��� �� ������, �������� ��� ����� ������ �� � �����.',[fsBold],clRed);
   Form1.AddErrorLog('NON PUBLIC VERSION!');
  end;
 hashes.HashingCore:=THashingCore.Create;
 CommandsAutorun;
 DragAcceptFiles(Form12.Handle,True);
 GetSystemInfo(tmp);
 Cores:=tmp.dwNumberOfProcessors;
 SetLength(WarmingThread,Cores);
 WriteLog(DEBUG_Params);
end;

procedure TForm12.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=38 then
  begin
   PrevHistory;
   Key:=0;
  end
 else if Key=40 then
  begin
   NextHistory;
   Key:=0;
  end
 else HistoryPos:=HistoryLength;
end;

procedure TForm12.Timer1Timer(Sender: TObject);
begin
 TimerSeconds:=TimerSeconds-1;
 if TimerSeconds=0 then
  begin
   Timer1.Enabled:=False;
   if Form1.N17.Checked then Form1.TotalTerminate
   else Form1.AfterPlaybackStopTask;
  end;
end;

procedure TForm12.Timer2Timer(Sender: TObject);
begin
 TimerSeconds2:=TimerSeconds2-1;
 if TimerSeconds2=0 then
  begin
   Timer2.Enabled:=False;
   Form1.StopPlaying;
   Form1.PausePlay;
  end;
end;

function WhereIsTheLastSemicolon(str:String):Integer;
var
 i,L:Integer;
begin
 L:=Length(str);
 i:=L+1;
 repeat
  i:=i-1;
 until (i=0) or (str[i]=';');
 Result:=i;
end;

procedure TForm12.TABCommList;
var
 searchStr:String;
 i,ls:Integer;
begin
 if TAB_mod then
  begin
   searchStr:=Trim(Edit1.Text);
   TAB_addition:='';
   ls:=WhereIsTheLastSemicolon(searchStr);
   if ls>0 then
    begin
     TAB_addition:=Copy(searchStr,1,ls);
     searchStr:=Trim(Copy(searchStr,ls+1,Length(searchStr)-ls));
    end;
   SetLength(TAB_clist,0);
   for i:= 0 to CommandsCount-1 do
    if Form2.FindANeedleAtTheBeginningOfHaystack(searchStr,SortedCmdList.Strings[i])<>0 then
     begin
      SetLength(TAB_clist,Length(TAB_clist)+1);
      TAB_clist[Length(TAB_clist)-1]:=SortedCmdList.Strings[i];
     end;
   TAB_cur:=0;
   TAB_mod:=False;
  end;
 if Length(TAB_clist)>0 then
  begin
   Edit1.Text:=TAB_addition + TAB_clist[TAB_cur] + ' ';
   Edit1.SelStart:=Length(Edit1.Text);
   Edit1.SelLength:=0;
   TAB_cur:=TAB_cur+1;
   if TAB_cur=Length(TAB_clist) then TAB_cur:=0;
  end;
end;

procedure TForm12.AEMessage(var Msg: tagMSG; var Handled: Boolean);
begin
 case Msg.message of
  WM_KEYDOWN:
   if msg.wParam=VK_TAB then
    if Edit1.Focused then
     begin
      if Length(Trim(Edit1.Text))>0 then TABCommList;
      Handled:=True;
     end;
 end;
end;

end.
