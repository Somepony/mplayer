unit AtomCleaner;

interface

uses
  Windows,
  SysUtils;

const
  THREAD_QUERY_INFORMATION = $0040;

procedure EngageAtomCleaner;

implementation
uses Unit12;

function OpenThread(dwDesiredAccess: DWORD; bInheritHandle: BOOL; dwThreadId: DWORD): THandle; stdcall; external kernel32;

function ThreadExists(const ThreadID: Cardinal): Boolean;
var h: THandle;
begin
  h := OpenThread(THREAD_QUERY_INFORMATION, False, ThreadID);
  if h = 0 then
  begin
    Result := False;
  end
  else
  begin
    Result := True;
    CloseHandle(h);
  end;
end;

function TryHexChar(c: Char; out b: Byte): Boolean;
begin
  Result := True;
  case c of
    '0'..'9':  b := Byte(c) - Byte('0');
    'a'..'f':  b := (Byte(c) - Byte('a')) + 10;
    'A'..'F':  b := (Byte(c) - Byte('A')) + 10;
  else
    Result := False;
  end;
end;

function TryHexToInt(const s: string; out value: Cardinal): Boolean;
var i: Integer;
    chval: Byte;
begin
  Result := True;
  value := 0;
  for i := 1 to Length(s) do
  begin
    if not TryHexChar(s[i], chval) then
      begin
        Result := False;
        Exit;
      end;
    value := value shl 4;
    value := value + chval;
  end;
end;

function GetAtomName(nAtom: TAtom): string;
var n: Integer;
    tmpstr: array [0..255] of Char;
begin
  n := GlobalGetAtomName(nAtom, PChar(@tmpstr[0]), 256);
  if n = 0 then
    Result := ''
  else
    Result := tmpstr;
end;

function CloseAtom(nAtom: TAtom): Boolean;
var n: Integer;
    s: string;
begin
  Result := False;
  s := GetAtomName(nAtom);
  if s = '' then Exit;
  Form12.EWriteLog('Closing atom: '+IntToHex(nAtom, 4)+' '+s);
  GlobalDeleteAtom(nAtom);
  Result := True;
end;

function ProcessAtom(nAtom: TAtom): Boolean;
var s: string;
    n: Integer;
    id: Cardinal;
begin
  Result := False;
  s := GetAtomName(nAtom);

  n := Pos('ControlOfs', s);
  if n = 1 then
  begin
    Delete(s, 1, Length('ControlOfs'));
    if Length(s) <> 16 then Exit;
    Delete(s, 1, 8);
    if not TryHexToInt(s, id) then Exit;
    if not ThreadExists(id) then
        Exit(CloseAtom(nAtom));
    Exit;
  end;

  n := Pos('WndProcPtr', s);
  if n = 1 then
  begin
    Delete(s, 1, Length('WndProcPtr'));
    if Length(s) <> 16 then Exit;
    Delete(s, 1, 8);
    if not TryHexToInt(s, id) then Exit;
    if not ThreadExists(id) then
        Exit(CloseAtom(nAtom));
    Exit;
  end;

  n := Pos('Delphi', s);
  if n = 1 then
  begin
    Delete(s, 1, Length('Delphi'));
    if Length(s) <> 8 then Exit;
    if not TryHexToInt(s, id) then Exit;
    if GetProcessVersion(id) = 0 then
      if GetLastError = ERROR_INVALID_PARAMETER then
        Exit(CloseAtom(nAtom));
    Exit;
  end;
end;

procedure EnumAndCloseAtoms;
var i: Integer;
begin
  i := MAXINTATOM;
  while i <= MAXWORD do
  begin
    if not ProcessAtom(i) then
        Inc(i);
  end;
end;

procedure EngageAtomCleaner;
begin
 try
  EnumAndCloseAtoms;
 except
  on E: Exception do
   Form12.EWriteLog(E.ClassName+': '+E.Message);
 end;
end;

begin
end.

