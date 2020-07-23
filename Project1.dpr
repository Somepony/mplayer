program Project1;

uses
  Forms,
  Windows,
  Classes,
  DCPmd5,
  SysUtils,
  Dialogs,
  Unit1 in 'Unit1.pas' {Form1},
  bass in 'bass.pas',
  CommonTypes in 'CommonTypes.pas',
  osc_vis in 'osc_vis.pas',
  tags in 'tags.pas',
  Unit2 in 'Unit2.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  Unit4 in 'Unit4.pas' {Form4},
  Unit5 in 'Unit5.pas' {Form5},
  Unit6 in 'Unit6.pas' {Form6},
  Unit7 in 'Unit7.pas' {Form7},
  Unit8 in 'Unit8.pas' {Form8},
  Unit9 in 'Unit9.pas' {Form9},
  Unit10 in 'Unit10.pas' {Form10},
  MediaInfoDLL in 'MediaInfoDLL.pas',
  Unit11 in 'Unit11.pas' {Form11},
  Unit12 in 'Unit12.pas' {Form12},
  Unit13 in 'Unit13.pas' {Form13},
  hashes in 'hashes.pas',
  Unit14 in 'Unit14.pas' {Form14},
  FuckDaRipprXM in 'FuckDaRipprXM.pas',
  Unit15 in 'Unit15.pas' {AboutBox},
  Unit16 in 'Unit16.pas' {Form16},
  MMDevApi in 'MMDevApi.pas',
  Unit_Spectrum in 'Unit_Spectrum.pas',
  basswasapi in 'basswasapi.pas',
  bassmix in 'bassmix.pas',
  UnitOSD in 'UnitOSD.pas' {FormOSD},
  SomeponyUtils in 'SomeponyUtils.pas',
  MplayerAPI in 'MplayerAPI.pas',
  UnitEnRu in 'UnitEnRu.pas',
  VarInt in 'VarInt.pas',
  b64 in 'b64.pas',
  FantomenK in 'FantomenK.pas',
  Unit17 in 'Unit17.pas' {Form17},
  AtomCleaner in 'AtomCleaner.pas';

{$R *.res}

const
 MailslotName='\\.\mailslot\mplayer_fluttershy_commands';
 EventName='mplayer_fluttershy_event';

var
 ClientMailslotHandle:THandle;
 Letter:String;
 BytesWritten:DWORD;
 i:Integer;

 function ParamStrContainFiles:Boolean;
 var
  i:Integer;
 begin
  Result:=False;
  if ParamCount>0 then
   for i:= 1 To ParamCount Do
    if FileExists(ParamStr(i)) then
     begin
      Result:=True;
      Exit;
     end;
 end;

 function MD5DigestToHexString(var Digest:array of Byte):String;
 var
  i:Byte;
 begin
  for i:= 0 To 15 Do
   Result:=Result + AnsiLowerCase(IntToHex(Digest[i],2));
 end;

 function MD5File(Path:String):String;
 var
  Digest16:array[0..15] of Byte;
  fl:TFileStream;
  h:TDCP_md5;
 begin
  fl:=TFileStream.Create(Path,fmOpenRead);
  h:=TDCP_md5.Create(nil);
  h.Init;
  h.UpdateStream(fl,fl.Size);
  h.Final(Digest16);
  FreeAndNil(fl);
  FreeAndNil(h);
  Result:=MD5DigestToHexString(Digest16);
 end;

begin
  ServerMailslotHandle:=CreateMailSlot(MailslotName,0,MAILSLOT_WAIT_FOREVER,nil);
  if ServerMailslotHandle=INVALID_HANDLE_VALUE then
   begin
    if GetLastError=ERROR_ALREADY_EXISTS then
     begin
      ClientMailslotHandle:=CreateFile(MailslotName,GENERIC_WRITE,FILE_SHARE_READ,nil,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0);
      if ParamCount>0 then
       begin
        if ParamStrContainFiles then
         begin
          Letter:='o';
          for i:= 1 To ParamCount Do
           Letter:=Letter+' "'+ParamStr(i)+'"';
         end
        else
         begin
          Letter:='c';
          for i:= 1 To ParamCount Do
           Letter:=Letter+' '+ParamStr(i);
         end;
       end
      else Letter:='s';
      WriteFile(ClientMailslotHandle,Letter[1],Length(Letter)*2,BytesWritten,nil);
      CommandEvent:=OpenEvent(EVENT_MODIFY_STATE,False,EventName);
      SetEvent(CommandEvent);
      CloseHandle(CommandEvent);
      CloseHandle(ClientMailslotHandle);
     end;
   end
  else
   begin
    CommandEvent:=CreateEvent(nil,False,False,EventName);
    Application.Initialize;
    AppLoaded:=False;
    Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.CreateForm(TForm4, Form4);
  Application.CreateForm(TForm5, Form5);
  Application.CreateForm(TForm7, Form7);
  Application.CreateForm(TForm8, Form8);
  Application.CreateForm(TForm9, Form9);
  Application.CreateForm(TForm10, Form10);
  Application.CreateForm(TForm11, Form11);
  Application.CreateForm(TForm12, Form12);
  Application.CreateForm(TForm13, Form13);
  Application.CreateForm(TForm14, Form14);
  Application.CreateForm(TAboutBox, AboutBox);
  Application.CreateForm(TForm16, Form16);
  Application.CreateForm(TFormOSD, FormOSD);
  Application.CreateForm(TForm17, Form17);
  AppLoaded:=True;
    Form1.AfterAppLoadTasks;
    Application.Run;
    CloseHandle(ServerMailslotHandle);
    CloseHandle(CommandEvent);
   end;
end.
