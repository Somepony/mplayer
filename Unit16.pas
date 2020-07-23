unit Unit16;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, JvExExtCtrls, JvExtComponent, JvItemsPanel, RzTabs,
  ComCtrls, StdCtrls;

type
  OLD_THistoryRecord=record
   Date:TDateTime;
   Path:String[255];
  end;

  THistoryRecord=record
   Date:TDateTime;
   Path:String;
  end;

  TForm16 = class(TForm)
    JvItemsPanel1: TJvItemsPanel;
    RzPageControl1: TRzPageControl;
    TabSheet1: TRzTabSheet;
    TabSheet2: TRzTabSheet;
    TabSheet3: TRzTabSheet;
    TabSheet4: TRzTabSheet;
    TabSheet5: TRzTabSheet;
    TabSheet6: TRzTabSheet;
    TabSheet7: TRzTabSheet;
    Shape1: TShape;
    ListView1: TListView;
    ListView2: TListView;
    ListView3: TListView;
    ListView4: TListView;
    ListView5: TListView;
    ListView6: TListView;
    ListView7: TListView;
    Button1: TButton;
    function CompareRecords(R1,R2:THistoryRecord):Boolean;
    procedure DeleteUnnecessaryRecords;
    procedure RebuildGUI;
    procedure LocateAndDeleteHistoryRecord(UnicornMagic:Byte;GID:Integer);
    procedure DeleteHistoryRecord(ID:Cardinal);
    procedure ClearHistory;
    procedure SaveHistory;
    procedure OLD_LoadHistory;
    procedure LoadHistory;
    procedure AddHistory(Path:String;CustomDate:TDateTime=0);
    procedure AddRecordGUI(HID:Cardinal);
    procedure SetHistoryDepth(Depth:Byte);
    procedure JvItemsPanel1ItemClick(Sender: TObject; ItemIndex: Integer);
    procedure FormCreate(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ListView1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

  YoBitch=Byte;

const
  MENU_LABELS:array[1..7] of String=('�������','�����','��������� 7 ����','��������� �����','��������� 6 �������','��������� ���','������ ����');
  HISTORY_FILE_NAME='history.dat';

var
  Form16: TForm16;
  History:array of THistoryRecord;
  CurHDpth:Byte;
  HistoryFilePath:String;

implementation
uses Unit1, Unit2, Unit3;

{$R *.dfm}

procedure WriteStrToFile(Str:String;var fl:TFileStream;WritePreLength:Boolean=False);
var
 i,L:Cardinal;
 ttt:TWordArray;
begin
 L:=Length(Str);
 if L>0 then
  begin
   if WritePreLength then fl.Write(L,4);
   for i:= 0 to L-1 do
    ttt[i]:=Ord(Str[i+1]);
   fl.Write(ttt,L*2);
  end
 else if WritePreLength then
  fl.Write(L,4);
end;

function ReadStrFromFile(var fl:TFileStream;LNG:Cardinal;PreLengthWritten:Boolean=False):String;
var
 ttt:TWordArray;
begin
 Result:='';
 FillChar(ttt,32768,0);
 if PreLengthWritten then fl.Read(LNG,4);
 if LNG>0 then
  begin
   fl.Read(ttt,LNG*2);
   Result:=PWideChar(@ttt);
  end;
end;

procedure TForm16.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

function TForm16.CompareRecords(R1,R2:THistoryRecord):Boolean;
var
 DTStr1,DTStr2:String;
begin
 DTStr1:=DateToStr(R1.Date) + ' ' + TimeToStr(R1.Date);
 DTStr2:=DateToStr(R2.Date) + ' ' + TimeToStr(R2.Date);
 Result:=(DTStr1=DTStr2) and (R1.Path=R2.Path);
end;

procedure TForm16.DeleteUnnecessaryRecords;
var
 MaxR,L:Cardinal;
begin
 MaxR:=Form3.SpinEdit1.Value;
 L:=Length(History);
 if MaxR<>0 then
  if L>MaxR then
   begin
    repeat
     DeleteHistoryRecord(0);
    until Length(History)=MaxR;
    RebuildGUI;
   end;
end;

procedure TForm16.RebuildGUI;
var
 LVdest:TListView;
 i:Byte;
 j,L:Cardinal;
begin
 for i:= 1 To 7 Do
  begin
   LVdest:=(Form16.FindComponent('ListView'+IntToStr(i)) as TListView);
   LVdest.Clear;
  end;
 SetHistoryDepth(1);
 L:=Length(History);
 for j:= 0 To L-1 Do
  AddRecordGUI(j);
end;

procedure TForm16.LocateAndDeleteHistoryRecord(UnicornMagic:Byte;GID:Integer);
var
 tmpLV:TListView;
 i,j,L:Cardinal;
 NeededHistoryRecord:THistoryRecord;
 tmpDateString:String;
begin
 if (UnicornMagic<8) and (UnicornMagic>0) and (GID>-1) then
  begin
   tmpLV:=(Form16.FindComponent('ListView' + IntToStr(UnicornMagic)) as TListView);
   L:=Length(History);
   tmpDateString:=tmpLV.Items.Item[GID].Caption;
   j:=0;
   repeat
    j:=j+1;
   until tmpDateString[j]=' ';
   NeededHistoryRecord.Date:=StrToDate(Copy(tmpDateString,1,j-1)) + StrToTime(Copy(tmpDateString,j+1,Length(tmpDateString)-j));
   NeededHistoryRecord.Path:=tmpLV.Items.Item[GID].SubItems[0];
   for i:= 0 To L-1 Do
    if CompareRecords(NeededHistoryRecord,History[i]) then
     begin
      DeleteHistoryRecord(i);
      Break;
     end;
   tmpLV.Items.Delete(GID);
  end;
end;

procedure TForm16.DeleteHistoryRecord(ID:Cardinal);
var
 i,L:Cardinal;
begin
 L:=Length(History);
 if L>0 then
  begin
   L:=L-1;
   if ID<L then
    begin
     for i:= ID To L-1 Do
      History[i]:=History[i+1];
    end;
   SetLength(History,L);
   Form3.Label10.Caption:='������� � �������: ' + IntToStr(L);
  end;
end;

procedure TForm16.ClearHistory;
var
 LVdest:TListView;
 i:Byte;
begin
 for i:= 1 To 7 Do
  begin
   LVdest:=(Form16.FindComponent('ListView'+IntToStr(i)) as TListView);
   LVdest.Clear;
  end;
 SetLength(History,0);
 Form3.Label10.Caption:='������� � �������: 0';
 DeleteFile(HistoryFilePath);
 SetHistoryDepth(1);
end;

procedure TForm16.SaveHistory;
var
 HFile:TFileStream;
 L,i:Cardinal;
begin
 L:=Length(History);
 if L>0 then
  begin
   HFile:=TFileStream.Create(HistoryFilePath,fmOpenWrite or fmCreate);
   WriteStrToFile('FluttershyIsBestPony',HFile);
   HFile.Write(L,SizeOf(Cardinal));
   for i:= 0 To L-1 Do
    begin
     HFile.Write(History[i].Date,SizeOf(TDateTime));
     WriteStrToFile(History[i].Path,HFile,True);
    end;
   FreeAndNil(HFile);
  end;
end;

procedure TForm16.OLD_LoadHistory;
var
 HFile:file of OLD_THistoryRecord;
 OLD_History:OLD_THistoryRecord;
 L,i:Cardinal;
begin
 if FileExists(HistoryFilePath) then
  begin
   AssignFile(HFile,HistoryFilePath);
   Reset(HFile);
   L:=FileSize(HFile);
   if L>0 then
    begin
     SetLength(History,L);
     Form3.Label10.Caption:='������� � �������: ' + IntToStr(L);
     for i:= 0 To L-1 Do
      begin
       Read(HFile,OLD_History);
       History[i].Date:=OLD_History.Date;
       History[i].Path:=OLD_History.Path;
       AddRecordGUI(i);
      end;
    end;
   CloseFile(HFile);
  end;
end;

procedure TForm16.LoadHistory;
var
 HFile:TFileStream;
 L,i:Cardinal;
 buf:String;
 bufDT:TDateTime;
begin
 if FileExists(HistoryFilePath) then
  begin
   HFile:=TFileStream.Create(HistoryFilePath,fmOpenRead);
   buf:=ReadStrFromFile(HFile,20);
   if buf<>'FluttershyIsBestPony' then
    begin
     FreeAndNil(HFile);
     OLD_LoadHistory;
     Exit;
    end;
   if HFile.Position<HFile.Size then
    begin
     HFile.Read(L,SizeOf(Cardinal));
     SetLength(History,L);
     Form3.Label10.Caption:='������� � �������: ' + IntToStr(L);
     for i:= 0 to L-1 do
      begin
       HFile.Read(bufDT,SizeOf(TDateTime));
       buf:=ReadStrFromFile(HFile,0,True);
       History[i].Date:=bufDT;
       History[i].Path:=buf;
       AddRecordGUI(i);
      end;
    end;
   FreeAndNil(HFile);
  end;
end;

procedure TForm16.AddHistory(Path:String;CustomDate:TDateTime=0);
var
 UnicornMagic:Integer;
begin
 UnicornMagic:=Length(History);
 SetLength(History,UnicornMagic+1);
 Form3.Label10.Caption:='������� � �������: ' + IntToStr(UnicornMagic+1);
 if CustomDate=0 then
  History[UnicornMagic].Date:=Date + Time
 else
  History[UnicornMagic].Date:=CustomDate;
 History[UnicornMagic].Path:=Path;
 AddRecordGUI(UnicornMagic);
 DeleteUnnecessaryRecords;
end;

procedure TForm16.AddRecordGUI(HID:Cardinal);
var
 UnicornMagic:Integer;
 tmpDate:TDateTime;
 dpthID:Byte;
 LVdest:TListView;
begin
 tmpDate:=History[HID].Date;
 if tmpDate>=Date then
  dpthID:=1
 else if tmpDate<Date then
  if tmpDate>(Date-1) then
   dpthID:=2
  else if tmpDate>(Date-7) then
   dpthID:=3
  else if tmpDate>(Date-30) then
   dpthID:=4
  else if tmpDate>(Date-180) then
   dpthID:=5
  else if tmpDate>(Date-360) then
   dpthID:=6
  else
   dpthID:=7;
 if dpthID>CurHDpth then
  SetHistoryDepth(dpthID);
 LVdest:=(Form16.FindComponent('ListView'+IntToStr(dpthID)) as TListView);
 UnicornMagic:=LVdest.Items.Count;
 LVdest.Items.Add.Caption:=DateToStr(History[HID].Date) + ' ' + TimeToStr(History[HID].Date);
 LVdest.Items.Item[UnicornMagic].SubItems.Add(History[HID].Path);
end;

procedure TForm16.SetHistoryDepth(Depth:Byte);
var
 i:Byte;
begin
 if (Depth>0) and (Depth<8) then
  begin
   CurHDpth:=Depth;
   JvItemsPanel1.Items.Clear;
   for i:= 1 To Depth Do
    JvItemsPanel1.Items.Add(MENU_LABELS[i]);
   JvItemsPanel1.Repaint;
  end;
end;

procedure TForm16.JvItemsPanel1ItemClick(Sender: TObject;
  ItemIndex: Integer);
begin
 RzPageControl1.TabIndex:=ItemIndex;
end;

procedure TForm16.FormCreate(Sender: TObject);
begin
 HistoryFilePath:=ProgDir+HISTORY_FILE_NAME;
 SetHistoryDepth(1);
 LoadHistory;
 Form1.LaunchCheckParams;
 Form1.LoadStats;
 Stats.LaunchedTimesTotal:=Stats.LaunchedTimesTotal+1;
end;

procedure TForm16.ListView1DblClick(Sender: TObject);
var
 LVdest:TListView;
begin
 LVdest:=(Sender as TListView);
 if LVdest.ItemIndex>-1 then
  begin
   Form2.ClearPlaylist;
   Form2.PlaylistAddSong(LVdest.Items.Item[LVdest.ItemIndex].SubItems[0]);
   Form1.PlayFileByNum;
  end;
end;

procedure TForm16.Button1Click(Sender: TObject);
begin
 ClearHistory;
end;

procedure TForm16.ListView1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
 CastingSpell:Byte;
 GID:Integer;
begin
 if Key=46 then
  begin
   CastingSpell:=StrToInt(Copy((Sender as TListView).Name,9,1));
   GID:=(Sender as TListView).ItemIndex;
   LocateAndDeleteHistoryRecord(CastingSpell,GID);
  end;
end;

end.
