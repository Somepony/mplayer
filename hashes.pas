unit hashes;

interface

uses
  Classes, SysUtils, Windows, Forms,
  DCPsha512, DCPsha256, DCPsha1, DCPmd4, DCPmd5,
  DCPhaval, DCPripemd128, DCPripemd160, DCPtiger,
  DCPcrypt2, Clipbrd;

type
  TDigest=array of Byte;

  THashingCore=class
   function DigestToHexString(var Digest:array of Byte):String;
   function DoTheRest:String;
   procedure HashFile(FilePath:String);
   function HashString(str:WideString):String;
   procedure ChangeHashEngine(HEIDn:Byte);
   function GetHashEngineName:String;
  end;

  THashingThread=class(TThread)
   FilePath:String;
   Parts,pos,Percent,OldPercent:Cardinal;
   constructor Create(susp:Boolean;path:String);
   procedure ECannotOpenFile;
   procedure UpdateHashEdit;
   procedure ShowElapsedTime;
   procedure Update;
   procedure Execute; override;
  end;

var
  HashEngine:TDCP_hash;
  DIGEST_LENGTH:Byte;
  HEID:Byte;
  Hashed:String;
  ElapsedTime:Integer;
  HashingCore:THashingCore;
  JobDone:Boolean=False;
  StopRightNow:Boolean=False;

implementation
uses Unit12;

function THashingCore.DigestToHexString(var Digest:array of Byte):String;
var
 i:Byte;
begin
 for i:= 0 To DIGEST_LENGTH-1 Do
  Result:=Result + AnsiLowerCase(IntToHex(Digest[i],2));
end;

function THashingCore.DoTheRest:String;
var
 Digest16:array[0..15] of Byte;
 Digest20:array[0..19] of Byte;
 Digest24:array[0..23] of Byte;
 Digest32:array[0..31] of Byte;
 Digest48:array[0..47] of Byte;
 Digest64:array[0..63] of Byte;
begin
 if DIGEST_LENGTH=16 then
  begin
   HashEngine.Final(Digest16);
   Result:=DigestToHexString(Digest16);
  end
 else if DIGEST_LENGTH=20 then
  begin
   HashEngine.Final(Digest20);
   Result:=DigestToHexString(Digest20);
  end
 else if DIGEST_LENGTH=24 then
  begin
   HashEngine.Final(Digest24);
   Result:=DigestToHexString(Digest24);
  end
 else if DIGEST_LENGTH=32 then
  begin
   HashEngine.Final(Digest32);
   Result:=DigestToHexString(Digest32);
  end
 else if DIGEST_LENGTH=48 then
  begin
   HashEngine.Final(Digest48);
   Result:=DigestToHexString(Digest48);
  end
 else if DIGEST_LENGTH=64 then
  begin
   HashEngine.Final(Digest64);
   Result:=DigestToHexString(Digest64);
  end;
end;

constructor THashingThread.Create(susp:Boolean;path:String);
begin
 inherited Create(susp);
 FilePath:=path;
end;

procedure THashingThread.ECannotOpenFile;
begin
 Form12.EWriteLog('�� ���� ������� ����. �������� �� ������������ ������ �����������.');
end;

procedure THashingThread.UpdateHashEdit;
begin
 //Form12.EWriteLog(HashingCore.GetHashEngineName + '(' + FilePath + ') = ' + Hashed);
end;

procedure THashingThread.ShowElapsedTime;
begin
 Form12.EWriteLog('����������� ���������!');
end;

procedure THashingThread.Update;
begin
 Percent:=Round(pos*100/Parts);
 if Percent>OldPercent then
  begin
   Form12.EWriteLog('�����������: ' + IntToStr(Percent) + '%');
   OldPercent:=Percent;
  end;
end;

procedure THashingThread.Execute;
var
 TimeStamp,i:Cardinal;
 fl:TFileStream;
begin
 TimeStamp:=GetTickCount;
 try
  fl:=TFileStream.Create(FilePath,fmOpenRead);
 except
  Synchronize(ECannotOpenFile);
  Exit;
 end;
 HashEngine.Init;
 Parts:=Trunc(fl.Size/8388608)+1;
 for i:= 1 To Parts Do
  begin
   if StopRightNow then
    begin
     FreeAndNil(fl);
     JobDone:=True;
     Exit;
    end;
   HashEngine.UpdateStream(fl,8388608);
   pos:=i;
   Synchronize(Update);
  end;
 FreeAndNil(fl);
 Hashed:=HashingCore.DoTheRest;
 ElapsedTime:=GetTickCount-TimeStamp;
 Synchronize(ShowElapsedTime);
 Synchronize(UpdateHashEdit);
 JobDone:=True;
end;

procedure THashingCore.HashFile(FilePath:String);
var
 Hashing:THashingThread;
begin
 JobDone:=False;
 Hashing:=THashingThread.Create(False,FilePath);
 repeat
  Application.ProcessMessages;
  Sleep(1);
 until JobDone;
 FreeAndNil(Hashing);
end;

function THashingCore.HashString(str:WideString):String;
begin
 Result:='';
 HashEngine.Init;
 HashEngine.UpdateStr(str);
 Result:=DoTheRest;
end;

procedure THashingCore.ChangeHashEngine(HEIDn:Byte);
begin
 if HEIDn<10 then
  begin
   FreeAndNil(HashEngine);
   if HEIDn=0 then // SHA-512
    HashEngine:=TDCP_sha512.Create(Form12)
   else if HEIDn=1 then // SHA-384
    HashEngine:=TDCP_sha384.Create(Form12)
   else if HEIDn=2 then // SHA-256
    HashEngine:=TDCP_sha256.Create(Form12)
   else if HEIDn=3 then // SHA-1
    HashEngine:=TDCP_sha1.Create(Form12)
   else if HEIDn=4 then // MD4
    HashEngine:=TDCP_md4.Create(Form12)
   else if HEIDn=5 then // MD5
    HashEngine:=TDCP_md5.Create(Form12)
   else if HEIDn=6 then // HAVAL
    HashEngine:=TDCP_haval.Create(Form12)
   else if HEIDn=7 then // RIPEMD-128
    HashEngine:=TDCP_ripemd128.Create(Form12)
   else if HEIDn=8 then // RIPEMD-160
    HashEngine:=TDCP_ripemd160.Create(Form12)
   else if HEIDn=9 then // Tiger
    HashEngine:=TDCP_tiger.Create(Form12);
   DIGEST_LENGTH:=(Round(HashEngine.GetHashSize/8));
   HEID:=HEIDn;
  end;
end;

function THashingCore.GetHashEngineName:String;
begin
 case HEID of
  0: Result:='SHA-512';
  1: Result:='SHA-384';
  2: Result:='SHA-256';
  3: Result:='SHA-1';
  4: Result:='MD4';
  5: Result:='MD5';
  6: Result:='HAVAL';
  7: Result:='RIPEMD-128';
  8: Result:='RIPEMD-160';
  9: Result:='Tiger';
  else Result:='INVALID!';
 end;
end;

end.
