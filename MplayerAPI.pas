unit MplayerAPI;

interface
uses SysUtils;

function PlistEmpty:Boolean;
function GetSongArtist(n:Cardinal):String;
function GetSongName(n:Cardinal):String;
function GetSongAlbum(n:Cardinal):String;
function GetSongDuration(n:Cardinal):String;
function GetSongDurationSeconds(n:Cardinal):Int64;
function GetSongFilePath(n:Cardinal):String;
function GetCurrentSongNum:Cardinal;
function GetConsoleOutputPlainText:String;

implementation
uses Unit1, Unit2, Unit3, Unit12;

function PlistEmpty:Boolean;
begin
 Result:=Form2.ListView1.Items.Count=0;
end;

function pnf(n,s:Cardinal):String;
begin
 Result:='';
 if not PlistEmpty then
  Result:=Form2.ListView1.Items.Item[n].SubItems.Strings[s];
end;

function GetSongArtist(n:Cardinal):String;
begin
 Result:=pnf(n,0);
end;

function GetSongName(n:Cardinal):String;
begin
 Result:=pnf(n,1);
end;

function GetSongAlbum(n:Cardinal):String;
begin
 Result:=pnf(n,2);
end;

function GetSongDuration(n:Cardinal):String;
begin
 Result:=pnf(n,3);
end;

function GetSongDurationSeconds(n:Cardinal):Int64;
begin
 Result:=Round(StrToTime(GetSongDuration(n))*24*60*60);
end;

function GetSongFilePath(n:Cardinal):String;
begin
 Result:=pnf(n,4);
end;

function GetCurrentSongNum:Cardinal;
begin
 Result:=CurSongNum;
end;

function GetConsoleOutputPlainText:String;
begin
 Result:=Form12.Memo1.Lines.Text;
end;

end.
