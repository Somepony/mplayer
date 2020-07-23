unit VarInt;

interface
uses SysUtils;

function ReadFromByteArr(BAr:TByteArray;Index:Integer;var BytesRead:Integer):Int64;
procedure WriteToByteArr(var BAr:TByteArray;Index:Integer;var BytesWritten:Integer;Value:Int64);

implementation

function MSBis1(b:Int64):Boolean;
begin
 b:=b shr 7;
 Result:=b=1;
end;

procedure SetMSBtoZero(var b:Int64);
begin
 b:=b-128;
end;

function ReadFromByteArr(BAr:TByteArray;Index:Integer;var BytesRead:Integer):Int64;
var
 curbyte:Int64;
 msb1:Boolean;
begin
 Result:=0;
 BytesRead:=0;
 repeat
  curbyte:=BAr[Index+BytesRead];
  msb1:=MSBis1(curbyte);
  if msb1 then SetMSBtoZero(curbyte);
  curbyte:=curbyte shl (7*BytesRead);
  Result:=Result or curbyte;
  Inc(BytesRead);
 until not msb1;
end;

function Get7Bits(Value:Int64):Byte;
var
 tmp:Int64;
begin
 tmp:=Value shl 1;
 Result:=tmp;
 Result:=Result shr 1;
end;

procedure SetMSBtoOne(var b:Byte);
begin
 b:=b+128;
end;

procedure WriteToByteArr(var BAr:TByteArray;Index:Integer;var BytesWritten:Integer;Value:Int64);
var
 tmpbyte:Byte;
 ended:Boolean;
begin
 BytesWritten:=0;
 repeat
  tmpbyte:=Get7Bits(Value);
  Value:=Value shr 7;
  ended:=Value=0;
  if not ended then SetMSBToOne(tmpbyte);
  BAr[Index+BytesWritten]:=tmpbyte;
  Inc(BytesWritten);
 until ended;
end;

end.
