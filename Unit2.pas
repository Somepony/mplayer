unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, BASS, tags, Menus, ShellAPI, MediaInfoDLL, uFMOD, WinInet, MplayerAPI;

type
  TPlistType = (ptM3U, ptCUE);

  TForm2 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    ListView1: TListView;
    Label1: TLabel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    FD1: TFindDialog;
    Button4: TButton;
    SD2: TSaveDialog;
    procedure UpdateTitleCaption;
    procedure ClearPlaylist;
    procedure FillPlaylist;
    procedure PlaylistAddSong(Path:String;NoGetTags:Boolean=False;NoCalcTD:Boolean=False;PArti:String='';PName:String='';PAlbum:String='';PDuration:Int64=0);
    procedure PlaylistSave;
    procedure PlaylistOpen(Path:String='';PlistType:TPlistType=ptM3U);
    procedure PlaylistOpenByURL(URL:String);
    procedure PlaylistRefreshInfo;
    procedure PlaylistRemoveDeadFiles;
    function PlayNextSong:Boolean;
    function PlayPrevSong:Boolean;
    function PlayRandomSong:Boolean;
    function PlaySelectedSong(Stop:Boolean=False):Boolean;
    procedure MoveSelectedSongUp;
    procedure MoveSelectedSongDown;
    procedure RemoveSong(II:Integer=-1);
    procedure FixListNumbers(Start:Integer=0);
    procedure CalcTotalDuration;
    function FindANeedleInAHaystack(Needle,Haystack:String):Integer;
    function FindANeedleAtTheBeginningOfHaystack(Needle,Haystack:String):Integer;
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure ListView1KeyPress(Sender: TObject; var Key: Char);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure N3Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure N8Click(Sender: TObject);
    procedure FD1Find(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    procedure WMDROPFILES(var Message:TWMDROPFILES); message WM_DROPFILES;
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

  TSongMeta=record
   Num:Cardinal;
   Name,Value:String;
  end;

function CueIndexToSeconds(CI:String):Int64;
function CueIndexToDateTime(CI:String):TDateTime;
function MetaKeyExists(Num:Cardinal;Name:String):Integer;
procedure SetMetaKey(Num:Cardinal;Name,Value:String);
function GetMetaKey(Num:Cardinal;Name:String):String;

var
  Form2: TForm2;
  PlaylistTempStream:HSTREAM;
  SongMetaData:array of TSongMeta;

implementation
uses Unit1, Unit4, Unit5, Unit11, Unit12;

{$R *.dfm}

function CueIndexToSeconds(CI:String):Int64;
var
 tm:String;
 tmpd:TDateTime;
begin
 tm:='0:'+Copy(CI,1,Length(CI)-3);
 tmpd:=StrToTimeDef(tm,0);
 Result:=Round(tmpd*24*60*60);
end;

function CueIndexToDateTime(CI:String):TDateTime;
var
 tm:String;
 tmpd:TDateTime;
begin
 tm:='0:'+Copy(CI,1,Length(CI)-3);
 Result:=StrToTimeDef(tm,0);
end;

function MetaKeyExists(Num:Cardinal;Name:String):Integer;
var
 L,i:Integer;
begin
 L:=Length(SongMetaData);
 Result:=-1;
 if L>0 then
  for i := 0 to L-1 do
   if (SongMetaData[i].Num=Num) and (SongMetaData[i].Name=Name) then
    begin
     Result:=i;
     Exit;
    end;
end;

function CreateMetaKey(Num:Cardinal;Name:String):Integer;
var
 L:Integer;
begin
 L:=Length(SongMetaData);
 SetLength(SongMetaData,L+1);
 SongMetaData[L].Num:=Num;
 SongMetaData[L].Name:=Name;
 Result:=L;
end;

procedure DeleteMetaData(an:Integer);
var
 L,i:Cardinal;
begin
 L:=Length(SongMetaData);
 if L>0 then
  if an<L then
   for i := an+1 to L-1 do
    SongMetaData[i-1]:=SongMetaData[i];
 SetLength(SongMetaData,L-1);
end;

procedure SwapMetaDataNums(Num1,Num2:Cardinal);
var
 i,L:Integer;
begin
 L:=Length(SongMetaData);
 if L>0 then
  for i := 0 to L-1 do
   if SongMetaData[i].Num=Num1 then
    SongMetaData[i].Num:=Num2
   else if SongMetaData[i].Num=Num2 then
    SongMetaData[i].Num:=Num1;
end;

procedure DeleteMetaKey(Num:Cardinal;Name:String);
var
 an:Integer;
begin
 an:=MetaKeyExists(Num,Name);
 if an>-1 then
  DeleteMetaData(an);
end;

procedure DeleteMetaKeysByNum(Num:Cardinal);
var
 i,L:Integer;
begin
 L:=Length(SongMetaData);
 if L>0 then
  begin
   i:=0;
   repeat
    if SongMetaData[i].Num=Num then
     begin
      DeleteMetaData(i);
      i:=i-1;
      L:=L-1;
     end;
    i:=i+1;
   until i=L;
  end;
end;

procedure SetMetaKey(Num:Cardinal;Name,Value:String);
var
 an:Integer;
begin
 an:=MetaKeyExists(Num,Name);
 if an=-1 then
  an:=CreateMetaKey(Num,Name);
 SongMetaData[an].Value:=Value;
end;

function GetMetaKey(Num:Cardinal;Name:String):String;
var
 an:Integer;
begin
 Result:='';
 an:=MetaKeyExists(Num,Name);
 if an>-1 then
  Result:=SongMetaData[an].Value;
end;

procedure EnabledAndVisible(Obj:TControl;State:Boolean);
begin
 Obj.Enabled:=State;
 Obj.Visible:=State;
end;

procedure TForm2.WMDROPFILES(var Message:TWMDROPFILES);
var
 Files:Longint;
 I,J,ans:Integer;
 Buffer:array[0..MAX_PATH] of Char;
 FL:TStringList;
 tmp_ext:String;
 dont_ask:Boolean;
begin
 dont_ask:=False;
 Files:=DragQueryFile(Message.Drop,$FFFFFFFF,nil,0);
 Form12.EWriteLog('Зарегистрирован сброс файлов');
 Form12.EWriteLog('Место: Окно плейлиста');
 if Files=0 then Form12.EWriteLog('Файлы не обнаружены! Что-то пошло не так?')
 else Form12.EWriteLog('Обнаружены файлы:');
 for I := 0 to Files - 1 do
  begin
   DragQueryFile(Message.Drop,I,@Buffer,SizeOf(Buffer));
   Form12.EWriteLog('- '+Buffer);
   if FileExists(Buffer) then
    if LowerCase(ExtractFileExt(Buffer))='.m3u' then
     Form2.PlaylistOpen(Buffer)
    else
     begin
      tmp_ext:=LowerCase(ExtractFileExt(Buffer));
      if Form1.IsValidExt(tmp_ext) then
       Form2.PlaylistAddSong(Buffer,False,True);
     end
   else if DirectoryExists(Buffer) then
    begin
     FL:=TStringList.Create;
     if dont_ask=False then
      ans:=MessageDlg('Открыть файлы в подпапках (если они есть)?',mtConfirmation,[mbYes,mbNo],0);
     if ans=mrYes then Form1.ScanDir(Buffer,'',FL,True)
     else Form1.ScanDir(Buffer,'',FL,False);
     dont_ask:=True;
     if FL.Count>0 then
      for J:= 0 To FL.Count-1 Do
       begin
        tmp_ext:=LowerCase(ExtractFileExt(FL.Strings[J]));
        if Form1.IsValidExt(tmp_ext) then
         Form2.PlaylistAddSong(FL.Strings[J],False,True);
       end;
    end;
  end;
 Form2.CalcTotalDuration;
 DragFinish(Message.Drop);
 Form12.EWriteLog('');
end;

procedure TForm2.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

function RandomRange(A,B:Integer):Integer;
begin
 Result:=Round(Random*(B-A)+A);
end;

procedure TForm2.UpdateTitleCaption;
var
 tmp:String;
 i:Integer;
begin
 tmp:=Form1.Label5.Caption;
 if Length(tmp)>0 then
  begin
   i:=0;
   repeat
    i:=i+1;
   until tmp[i]='.';
   Delete(tmp,1,i-1);
   Insert(IntToStr(CurSongNum+1),tmp,1);
   Form1.SetTitleCaption(tmp);
  end;
end;

procedure TForm2.ClearPlaylist;
begin
 ListView1.Clear;
 SetLength(SongMetaData,0);
 EnabledAndVisible(Button4,False);
 Form1.DropChannel;
end;

procedure TForm2.FillPlaylist;
var
i,C:Cardinal;
Path:String;
begin
 C:=Form1.OpenDialog1.Files.Count;
 if C>0 then
  for i:= 0 To C-1 Do
   begin
    Path:=Form1.OpenDialog1.Files.Strings[i];
    PlaylistAddSong(Path,False,True);
   end;
 CalcTotalDuration;
end;

procedure TForm2.PlaylistAddSong(Path:String;NoGetTags:Boolean=False;NoCalcTD:Boolean=False;PArti:String='';PName:String='';PAlbum:String='';PDuration:Int64=0);
var
 Magic:Integer;
 AddSong:Boolean;
begin
 AddSong:=False;
 if (Copy(Path,1,7)='http://') or (Copy(Path,1,8)='https://') or (Copy(Path,1,6)='ftp://') then
  begin
   if NoGetTags=False then PlaylistTempStream:=BASS_StreamCreateURL(PChar(Path),BASS_UNICODE,0,nil,nil);
   AddSong:=True;
  end
 else if FileExists(Path) then
  begin
   if NoGetTags=False then
    begin
     PlaylistTempStream:=BASS_StreamCreateFile(False,PChar(Path),0,0,BASS_UNICODE);
     if PlaylistTempStream=0 then
      PlaylistTempStream:=BASS_MusicLoad(False,PChar(Path),0,0,BASS_MUSIC_RAMP or BASS_MUSIC_PRESCAN or BASS_UNICODE,1);
    end;
   AddSong:=True;
  end;
 if (PlaylistTempStream=0) and (NoGetTags=False) then Exit;
 if AddSong then
  begin
   ListView1.Items.Add;
   Magic:=ListView1.Items.Count-1;
   ListView1.Items.Item[Magic].Caption:=IntToStr(ListView1.Items.Count);
   if NoGetTags=False then
    begin
     if PArti='' then
      PArti:=UTF8ToString(TAGS_Read(PlaylistTempStream,'%ARTI'));
     ListView1.Items.Item[Magic].SubItems.Add(PArti);
     if PName='' then
      PName:=UTF8ToString(TAGS_Read(PlaylistTempStream,'%TITL'));
     ListView1.Items.Item[Magic].SubItems.Add(PName);
     if PAlbum='' then
      PAlbum:=UTF8ToString(TAGS_Read(PlaylistTempStream,'%ALBM'));
     ListView1.Items.Item[Magic].SubItems.Add(PAlbum);
     if PDuration=0 then
      PDuration:=Round(BASS_ChannelBytes2Seconds(PlaylistTempStream,BASS_ChannelGetLength(PlaylistTempStream,BASS_POS_BYTE)));
     ListView1.Items.Item[Magic].SubItems.Add(TimeToStr(PDuration/(60*60*24)));
    end
   else
    if SongInfo.AddThis then
     begin
      ListView1.Items.Item[Magic].SubItems.Add(SongInfo.Arti);
      ListView1.Items.Item[Magic].SubItems.Add(SongInfo.Title);
      ListView1.Items.Item[Magic].SubItems.Add(SongInfo.Album);
      ListView1.Items.Item[Magic].SubItems.Add(TimeToStr(SongInfo.Duration));
     end
    else
     begin
      ListView1.Items.Item[Magic].SubItems.Add('');
      ListView1.Items.Item[Magic].SubItems.Add('');
      ListView1.Items.Item[Magic].SubItems.Add('');
      ListView1.Items.Item[Magic].SubItems.Add('');
     end;
   ListView1.Items.Item[Magic].SubItems.Add(Path);
   if NoGetTags=False then
    begin
     BASS_StreamFree(PlaylistTempStream);
     BASS_MusicFree(PlaylistTempStream);
    end;
   if NoCalcTD=False then CalcTotalDuration;
  end;
end;

procedure TForm2.PlaylistSave;
var
 i,C:Cardinal;
 Plst:TStringList;
begin
 if SaveDialog1.Execute then
  begin
   C:=ListView1.Items.Count;
   Plst:=TStringList.Create;
   Plst.Clear;
   if C>0 then
    for i:= 0 To C-1 Do
     Plst.Add(ListView1.Items.Item[i].SubItems[4]);
   Plst.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TForm2.PlaylistOpen(Path:String='';PlistType:TPlistType=ptM3U);
var
 Plst:TStringList;
 i,C,j,z,Magic:Cardinal;
 snum:Integer;
 PlistDir,tpath:String;
 ExtendedM3U,EF:Boolean;
 PArti,PName,PAlbum:String;
 PDuration:Int64;
 extinfo,tmpc:String;
 GlobalArtist,GlobalFile,CIndex:String;
 FileMode:Boolean;
 tmpdt:TDateTime;
begin
 if Path='' then
  if OpenDialog1.Execute then
   begin
    Path:=OpenDialog1.FileName;
    if WideLowerCase(ExtractFileExt(Path))='.cue' then
     PlistType:=ptCUE;
   end;
 if FileExists(Path) then
  begin
   PlistDir:=ExtractFileDir(Path)+'\';
   Plst:=TStringList.Create;
   Plst.LoadFromFile(Path);
   C:=Plst.Count;
   if C>0 then
    begin
     ClearPlaylist;
     case PlistType of
      ptM3U:
       begin
        ExtendedM3U:=Trim(Plst.Strings[0])='#EXTM3U';
        for i:= 0 To C-1 Do
         begin
          tpath:=Trim(Plst.Strings[i]);
          EF:=FileExists(tpath);
          if not EF then
           begin
            tpath:=PlistDir+tpath;
            EF:=FileExists(tpath);
           end;
          if EF then
           begin
            PArti:='';
            PName:='';
            PAlbum:='';
            PDuration:=0;
            if ExtendedM3U then
             begin
              extinfo:=Trim(Plst.Strings[i-1]);
              if Copy(extinfo,1,8)='#EXTINF:' then
               begin
                j:=8;
                repeat
                 j:=j+1;
                until (extinfo[j]=',') or (j>=Length(extinfo));
                PDuration:=StrToIntDef(Copy(extinfo,9,j-9),0);
                if PDuration<0 then PDuration:=0;
                if j<Length(extinfo) then
                 begin
                  z:=j;
                  repeat
                   z:=z+1;
                  until (extinfo[z]='-') or (z>=Length(extinfo));
                  PArti:=Trim(Copy(extinfo,j+1,z-(j+1)));
                  PName:=Trim(Copy(extinfo,z+1,Length(extinfo)-z));
                 end;
               end;
             end;
            PlaylistAddSong(tpath,False,True,PArti,PName,PAlbum,PDuration);
           end;
         end;
        if Form1.N14.Checked then snum:=Form2.ListView1.Items.Count-1
        else snum:=0;
       end;
      ptCUE:
       begin
        FileMode:=False;
        for i := 0 to C-1 do
         begin
          tmpc:=Trim(Plst.Strings[i]);
          if Copy(tmpc,1,9)='PERFORMER' then
           begin
            if FileMode then
             PArti:=Copy(tmpc,12,Length(tmpc)-12)
            else
             GlobalArtist:=Copy(tmpc,12,Length(tmpc)-12);
           end
          else if Copy(tmpc,1,5)='TITLE' then
           begin
            if FileMode then
             PName:=Copy(tmpc,8,Length(tmpc)-8)
            else
             PAlbum:=Copy(tmpc,8,Length(tmpc)-8);
           end
          else if Copy(tmpc,1,4)='FILE' then
           begin
            j:=6;
            repeat
             j:=j+1;
            until (tmpc[j]='"') or (j>=Length(tmpc));
            GlobalFile:=Copy(tmpc,7,j-7);
            if not FileExists(GlobalFile) then
             GlobalFile:=PlistDir+GlobalFile;
            FileMode:=True;
            z:=i;
           end
          else if Copy(tmpc,1,5)='TRACK' then
           begin
            if z<>(i-1) then
             begin
              PlaylistAddSong(GlobalFile,False,True,PArti,PName,PAlbum,PDuration);
              Magic:=ListView1.Items.Count-1;
              SetMetaKey(Magic,'Start',CIndex);
             end;
           end
          else if Copy(tmpc,1,5)='INDEX' then
           begin
            j:=Length(tmpc);
            repeat
             j:=j-1;
            until (tmpc[j]=' ') or (j<=0);
            CIndex:=Copy(tmpc,j+1,Length(tmpc)-j);
           end;
         end;
        PlaylistAddSong(GlobalFile,False,True,PArti,PName,PAlbum,PDuration);
        Magic:=ListView1.Items.Count-1;
        SetMetaKey(Magic,'Start',CIndex);
        for j := 0 to Magic-1 do
         begin
          tmpdt:=CueIndexToDateTime(GetMetaKey(j+1,'Start')) - CueIndexToDateTime(GetMetaKey(j,'Start'));
          ListView1.Items.Item[j].SubItems.Strings[3]:=TimeToStr(tmpdt);
         end;
        tmpdt:=StrToTime(GetSongDuration(Magic)) - CueIndexToDateTime(GetMetaKey(Magic,'Start'));
        ListView1.Items.Item[Magic].SubItems.Strings[3]:=TimeToStr(tmpdt);
       end;
     end;
     CalcTotalDuration;
     Form1.PlayFileByNum(snum);
    end;
   FreeAndNil(Plst);
  end;
end;

procedure TForm2.PlaylistOpenByURL(URL:String);
var
 Plst:TStringList;
 i,C:Cardinal;
 snum:Integer;
begin
 Plst:=TStringList.Create;
 Plst.Text:=Form1.HTTP1.Get(URL);
 C:=Plst.Count;
 if C>0 then
  begin
   ClearPlaylist;
   for i:= 0 To C-1 Do
    PlaylistAddSong(Plst.Strings[i]);
   if Form1.N14.Checked then snum:=Form2.ListView1.Items.Count-1
   else snum:=0;
   Form1.PlayFileByNum(snum);
  end;
end;

procedure TForm2.PlaylistRefreshInfo;
var
 i,C:Integer;
 Path:String;
begin
 C:=ListView1.Items.Count;
 if C>0 then
  begin
   for i:= 0 To C-1 Do
    begin
     Path:=ListView1.Items.Item[i].SubItems[4];
     if (Copy(Path,1,7)='http://') or (Copy(Path,1,8)='https://') or (Copy(Path,1,6)='ftp://') then
      PlaylistTempStream:=BASS_StreamCreateURL(PChar(Path),0,BASS_UNICODE,nil,nil)
     else
      PlaylistTempStream:=BASS_StreamCreateFile(False,PChar(Path),0,0,BASS_UNICODE);
     ListView1.Items.Item[i].Caption:=IntToStr(i+1);
     ListView1.Items.Item[i].SubItems[0]:=UTF8ToString(TAGS_Read(PlaylistTempStream,'%ARTI'));
     ListView1.Items.Item[i].SubItems[1]:=UTF8ToString(TAGS_Read(PlaylistTempStream,'%TITL'));
     ListView1.Items.Item[i].SubItems[2]:=UTF8ToString(TAGS_Read(PlaylistTempStream,'%ALBM'));
     ListView1.Items.Item[i].SubItems[3]:=TimeToStr(BASS_ChannelBytes2Seconds(PlaylistTempStream,BASS_ChannelGetLength(PlaylistTempStream,BASS_POS_BYTE))/(60*60*24));
     BASS_StreamFree(PlaylistTempStream);
     BASS_MusicFree(PlaylistTempStream);
    end;
   CalcTotalDuration;
  end;
end;

procedure TForm2.PlaylistRemoveDeadFiles;
var
 i,C:Integer;
 Path:String;
begin
 C:=ListView1.Items.Count;
 i:=-1;
 if C>0 then
  repeat
   i:=i+1;
   Path:=ListView1.Items.Item[i].SubItems[4];
   if ((Copy(Path,1,7)='http://') or (Copy(Path,1,8)='https://') or (Copy(Path,1,6)='ftp://'))=False then
   if FileExists(Path)=False then
    begin
     RemoveSong(i);
     C:=C-1;
     i:=i-1;
    end;
  until i=(C-1);
end;

function TForm2.PlayNextSong:Boolean;
var
 Path:String;
 Stop:Boolean;
begin
 Stop:=not Playing;
 if CurSongNum>=ListView1.Items.Count-1 then Result:=False
 else
  begin
   ListView1.ItemIndex:=CurSongNum+1;
   Path:=ListView1.Items.Item[ListView1.ItemIndex].SubItems[4];
   if (FileExists(Path)) or (Copy(Path,1,7)='http://') or (Copy(Path,1,8)='https://') or (Copy(Path,1,6)='ftp://') then
    begin
     PlaySelectedSong(Stop);
     Result:=True;
    end
   else
    begin
     CurSongNum:=CurSongNum+1;
     Result:=PlayNextSong;
    end;
  end;
end;

function TForm2.PlayPrevSong:Boolean;
var
 Path:String;
 Stop:Boolean;
begin
 Stop:=not Playing;
 if CurSongNum=0 then Result:=False
 else
  begin
   ListView1.ItemIndex:=CurSongNum-1;
   Path:=ListView1.Items.Item[ListView1.ItemIndex].SubItems[4];
   if (FileExists(Path)) or (Copy(Path,1,7)='http://') or (Copy(Path,1,8)='https://') or (Copy(Path,1,6)='ftp://') then
    begin
     PlaySelectedSong(Stop);
     Result:=True;
    end
   else
    begin
     CurSongNum:=CurSongNum-1;
     Result:=PlayPrevSong;
    end;
  end;
end;

function TForm2.PlayRandomSong:Boolean;
begin
 ListView1.ItemIndex:=RandomRange(0,ListView1.Items.Count-1);
 Result:=PlaySelectedSong;
end;

function TForm2.PlaySelectedSong(Stop:Boolean=False):Boolean;
var
 Path:String;
 SameFile:Boolean;
begin
 Result:=False;
 if ListView1.ItemIndex>-1 then
  begin
   Path:=ListView1.Items.Item[ListView1.ItemIndex].SubItems[4];
   if (FileExists(Path)) or (Copy(Path,1,7)='http://') or (Copy(Path,1,8)='https://') or (Copy(Path,1,6)='ftp://') then
    begin
     SameFile:=MediaFilePath=Path;
     MediaFilePath:=Path;
     if AppLoaded then Form11.UpdateMediaInfo
     else MediaInfoUpdateNeeded:=True;
     CurSongNum:=ListView1.ItemIndex;
     Form1.PlayFile(Stop,SameFile);
     Result:=True;
    end;
  end;
end;

procedure TForm2.MoveSelectedSongUp;
var
 II:Integer;
begin
 if (ListView1.ItemIndex>0) and (ListView1.Items.Count>1) then
  begin
   II:=ListView1.ItemIndex;
   ListView1.Items.Add;
   ListView1.Items.Item[ListView1.Items.Count-1]:=ListView1.Items.Item[II];
   ListView1.Items.Item[II]:=ListView1.Items.Item[II-1];
   ListView1.Items.Item[II-1]:=ListView1.Items.Item[ListView1.Items.Count-1];
   ListView1.ItemIndex:=II-1;
   ListView1.Items.Delete(ListView1.Items.Count-1);
   SwapMetaDataNums(II,II-1);
   FixListNumbers;
   if II=CurSongNum then CurSongNum:=CurSongNum-1
   else if II-1=CurSongNum then CurSongNum:=CurSongNum+1;
   UpdateTitleCaption;
  end;
end;

procedure TForm2.MoveSelectedSongDown;
var
 II:Integer;
begin
 if (ListView1.ItemIndex<ListView1.Items.Count-1) and (ListView1.Items.Count>1) and (ListView1.ItemIndex>-1) then
  begin
   II:=ListView1.ItemIndex;
   ListView1.Items.Add;
   ListView1.Items.Item[ListView1.Items.Count-1]:=ListView1.Items.Item[II];
   ListView1.Items.Item[II]:=ListView1.Items.Item[II+1];
   ListView1.Items.Item[II+1]:=ListView1.Items.Item[ListView1.Items.Count-1];
   ListView1.ItemIndex:=II+1;
   ListView1.Items.Delete(ListView1.Items.Count-1);
   SwapMetaDataNums(II,II+1);
   FixListNumbers;
   if II=CurSongNum then CurSongNum:=CurSongNum+1
   else if II+1=CurSongNum then CurSongNum:=CurSongNum-1;
   UpdateTitleCaption;
  end;
end;

procedure TForm2.RemoveSong(II:Integer=-1);
begin
 if II=-1 then II:=ListView1.ItemIndex;
 if II>-1 then
  begin
   if II=CurSongNum then
    if ListView1.Items.Count>1 then
     begin
      if not PlayNextSong then Form1.DropChannel;
     end
    else
     Form1.DropChannel;
   ListView1.Items.Delete(II);
   DeleteMetaKeysByNum(II);
   FixListNumbers(II);
   CalcTotalDuration;
   if II<=CurSongNum then
    begin
     CurSongNum:=CurSongNum-1;
     UpdateTitleCaption;
    end;
   if II=ListView1.Items.Count then
    ListView1.ItemIndex:=II-1
   else
    ListView1.ItemIndex:=II;
  end;
end;

procedure TForm2.FixListNumbers(Start:Integer=0);
var
 i:Integer;
begin
 if ListView1.Items.Count>0 then
  for i:= Start To ListView1.Items.Count-1 Do
   ListView1.Items.Item[i].Caption:=IntToStr(i+1);
end;

procedure TForm2.CalcTotalDuration;
var
 i:Integer;
 Days:Integer;
 TotalDuration:TDateTime;
begin
 TotalDuration:=0;
 if ListView1.Items.Count>0 then
  for i:= 0 To ListView1.Items.Count-1 Do
   TotalDuration:=TotalDuration+StrToTime(ListView1.Items.Item[i].SubItems[3],GlobalFormats);
 if TotalDuration>=1 then
  begin
   Days:=Trunc(TotalDuration);
   TotalDuration:=TotalDuration-Days;
   Label1.Caption:='Общая продолжительность: ' + IntToStr(Days) + ':' + TimeToStr(TotalDuration);
  end
 else
  Label1.Caption:='Общая продолжительность: ' + TimeToStr(TotalDuration);
end;

function TForm2.FindANeedleInAHaystack(Needle,Haystack:String):Integer;
var
 i,L1,L2:Integer;
begin
 Result:=0;
 L1:=Length(Needle);
 L2:=Length(Haystack);
 if (L1>0) and (L2>0) and (L2>=L1) then
  for i:= 1 to L2 do
   if AnsiLowerCase(Copy(Haystack,i,L1))=AnsiLowerCase(Needle) then
    begin
     Result:=i;
     Exit;
    end;
end;

function TForm2.FindANeedleAtTheBeginningOfHaystack(Needle,Haystack:String):Integer;
var
 L1,L2:Integer;
begin
 Result:=0;
 L1:=Length(Needle);
 L2:=Length(Haystack);
 if (L1>0) and (L2>0) and (L2>=L1) then
  if AnsiLowerCase(Copy(Haystack,1,L1))=AnsiLowerCase(Needle) then
   begin
    Result:=1;
    Exit;
   end;
end;

procedure TForm2.Button3Click(Sender: TObject);
begin
 ClearPlaylist;
 CalcTotalDuration;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
 if Form1.OpenDialog1.Execute then FillPlaylist;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
 if Form5.ShowModal=mrOK then
  PlaylistAddSong(Form5.Edit1.Text);
end;

procedure TForm2.ListView1DblClick(Sender: TObject);
begin
 PlaySelectedSong;
end;

procedure TForm2.ListView1KeyPress(Sender: TObject; var Key: Char);
begin
 if Key=#13 then PlaySelectedSong;
end;

procedure TForm2.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if Key=33 then
  begin
   MoveSelectedSongUp;
   Key:=0;
  end;
 if Key=34 then
  begin
   MoveSelectedSongDown;
   Key:=0;
  end;
 if Key=46 then RemoveSong;
end;

procedure TForm2.N3Click(Sender: TObject);
begin
 if ListView1.Items.Count>0 then PlaylistSave
 else ShowMessage('Плейлист пуст. Сохранять нечего.');
end;

procedure TForm2.N2Click(Sender: TObject);
begin
 PlaylistOpen;
end;

procedure TForm2.N5Click(Sender: TObject);
begin
 PlaylistRefreshInfo;
end;

procedure TForm2.N6Click(Sender: TObject);
begin
 PlaylistRemoveDeadFiles;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
 DragAcceptFiles(Form2.Handle,True);
end;

procedure TForm2.N8Click(Sender: TObject);
begin
 FD1.Execute;
end;

procedure TForm2.FD1Find(Sender: TObject);
var
 i,C,II:Integer;
 tofind:String;
begin
 tofind:=FD1.FindText;
 C:=ListView1.Items.Count;
 II:=ListView1.ItemIndex;
 if C>0 then
  if frDown in FD1.Options then
   begin
    for i:= II+1 to C-1 do
     if
       (FindANeedleInAHaystack(tofind,ListView1.Items.Item[i].SubItems.Strings[0])<>0)
        or
       (FindANeedleInAHaystack(tofind,ListView1.Items.Item[i].SubItems.Strings[1])<>0)
        or
       (FindANeedleInAHaystack(tofind,ListView1.Items.Item[i].SubItems.Strings[2])<>0)
        or
       (FindANeedleInAHaystack(tofind,ListView1.Items.Item[i].SubItems.Strings[4])<>0)
     then
      begin
       ListView1.ItemIndex:=i;
       Exit;
      end;
   end
  else
   begin
    for i:= II-1 downto 0 do
     if
       (FindANeedleInAHaystack(tofind,ListView1.Items.Item[i].SubItems.Strings[0])<>0)
        or
       (FindANeedleInAHaystack(tofind,ListView1.Items.Item[i].SubItems.Strings[1])<>0)
        or
       (FindANeedleInAHaystack(tofind,ListView1.Items.Item[i].SubItems.Strings[2])<>0)
        or
       (FindANeedleInAHaystack(tofind,ListView1.Items.Item[i].SubItems.Strings[4])<>0)
     then
      begin
       ListView1.ItemIndex:=i;
       Exit;
      end;
   end;
end;

function GetInetFile(const fileURL, FileName: String): boolean;
var
  hSession, hURL: HInternet;
  Buffer: array[1..1024] of Byte;
  BufferLen: DWORD;
  f: File;
  sAppName: String;
begin
  Result:=False;
  sAppName:=ExtractFileName(Application.ExeName);
  hSession:=InternetOpen(PChar(sAppName),INTERNET_OPEN_TYPE_PRECONFIG,nil,nil,0);
  try
    hURL:=InternetOpenURL(hSession, PChar(fileURL), nil, 0, 0, 0);
    try
      AssignFile(f,FileName);
      ReWrite(f,1);
      repeat
        InternetReadFile(hURL,@Buffer,SizeOf(Buffer),BufferLen);
        BlockWrite(f,Buffer,BufferLen);
        Application.ProcessMessages;
      until
        BufferLen = 0;
      CloseFile(f);
      Result:=True;
    finally
      InternetCloseHandle(hURL);
    end;
  finally
    InternetCloseHandle(hSession);
  end;
end;

function CLEANTHISSHIT(Suka:String):String;
const
 ILLEGAL=['\','/',':','*','?','"','<','>','|'];
var
 i,L:Integer;
begin
 L:=Length(Suka);
 if L>0 then
  begin
   i:=0;
   repeat
    i:=i+1;
    if Suka[i] in ILLEGAL then
     begin
      Delete(Suka,i,1);
      i:=i-1;
     end;
   until i>=L;
   Result:=Suka;
  end;
end;

procedure TForm2.Button4Click(Sender: TObject);
var
 idd:Integer;
 fpath,fname:String;
begin
 idd:=ListView1.ItemIndex;
 if idd>-1 then
  if SD2.Execute then
   begin
    fpath:=ExtractFilePath(SD2.FileName);
    fname:=CLEANTHISSHIT(ListView1.Items[idd].SubItems[0]+' - '+ListView1.Items[idd].SubItems[1]+'.mp3');
    fname:=fpath+fname;
    if not GetInetFile(ListView1.Items[idd].SubItems[4],fname) then
     MessageBox(Form1.Handle,'Не удалось скачать файл. Попробуйте ещё раз.',APP_NAME,0);
   end;
end;

procedure TForm2.ListView1SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
var
 tmpstr:String;
begin
 tmpstr:=Item.SubItems[4];
 if Copy(tmpstr,1,4)='http' then
  EnabledAndVisible(Button4,Form2.FindANeedleInAHaystack('vk.me',tmpstr)<>0)
 else
  EnabledAndVisible(Button4,False);
end;

end.

