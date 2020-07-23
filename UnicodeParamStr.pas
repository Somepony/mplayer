unit UnicodeParamStr;

interface

uses Windows;

function GetParamStr(P: PWideChar; var Param: Widestring): PWideChar;
function ParamStr(Index: Integer): Widestring;

implementation

function GetParamStr(P: PWideChar; var Param: Widestring): PWideChar;
var
  i, Len: Integer;
  Start, S, Q: PWideChar;
begin
  while True do
  begin
    while (P[0] <> #0) and (P[0] <= ' ') do
      P := CharNextW(P);
    if (P[0] = '"') and (P[1] = '"') then Inc(P, 2) else Break;
  end;
  Len := 0;
  Start := P;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNextW(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNextW(P);
        Inc(Len, Q - P);
        P := Q;
      end;
      if P[0] <> #0 then
        P := CharNextW(P);
    end
    else
    begin
      Q := CharNextW(P);
      Inc(Len, Q - P);
      P := Q;
    end;
  end;

  SetLength(Param, Len);

  P := Start;
  S := Pointer(Param);
  i := 0;
  while P[0] > ' ' do
  begin
    if P[0] = '"' then
    begin
      P := CharNextW(P);
      while (P[0] <> #0) and (P[0] <> '"') do
      begin
        Q := CharNextW(P);
        while P < Q do
        begin
          S[i] := P^;
          Inc(P);
          Inc(i);
        end;
      end;
      if P[0] <> #0 then P := CharNextW(P);
    end
    else
    begin
      Q := CharNextW(P);
      while P < Q do
      begin
        S[i] := P^;
        Inc(P);
        Inc(i);
      end;
    end;
  end;

  Result := P;
end;

function ParamStr(Index: Integer): Widestring;
var
  P: PWideChar;
  Buffer: array[0..260] of WideChar;
begin
  Result := '';
  if Index = 0 then
    SetString(Result, Buffer, GetModuleFileNameW(0, Buffer, SizeOf(Buffer)))
  else
  begin
    P := GetCommandLineW;
    while True do
    begin
      P := GetParamStr(P, Result);
      if (Index = 0) or (Result = '') then Break;
      Dec(Index);
    end;
  end;
end;

end.
 