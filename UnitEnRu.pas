unit UnitEnRu;

interface

procedure EnRu(var str:String);
procedure RuEn(var str:String);

implementation

procedure EnRu(var str:String);
var
 j,L:Integer;
begin
 L:=Length(str);
 if L>0 then
  for j:= 1 to L do
   begin
       if str[j]='q' then str[j]:='é';
       if str[j]='w' then str[j]:='ö';
       if str[j]='e' then str[j]:='ó';
       if str[j]='r' then str[j]:='ê';
       if str[j]='t' then str[j]:='å';
       if str[j]='y' then str[j]:='í';
       if str[j]='u' then str[j]:='ã';
       if str[j]='i' then str[j]:='ø';
       if str[j]='o' then str[j]:='ù';
       if str[j]='p' then str[j]:='ç';
       if str[j]='[' then str[j]:='õ';
       if str[j]=']' then str[j]:='ú';
       if str[j]='a' then str[j]:='ô';
       if str[j]='s' then str[j]:='û';
       if str[j]='d' then str[j]:='â';
       if str[j]='f' then str[j]:='à';
       if str[j]='g' then str[j]:='ï';
       if str[j]='h' then str[j]:='ğ';
       if str[j]='j' then str[j]:='î';
       if str[j]='k' then str[j]:='ë';
       if str[j]='l' then str[j]:='ä';
       if str[j]=';' then str[j]:='æ';
       if str[j]=#39 then str[j]:='ı';
       if str[j]='z' then str[j]:='ÿ';
       if str[j]='x' then str[j]:='÷';
       if str[j]='c' then str[j]:='ñ';
       if str[j]='v' then str[j]:='ì';
       if str[j]='b' then str[j]:='è';
       if str[j]='n' then str[j]:='ò';
       if str[j]='m' then str[j]:='ü';
       if str[j]=',' then str[j]:='á';
       if str[j]='.' then str[j]:='ş';
       if str[j]='`' then str[j]:='¸';
       if str[j]='Q' then str[j]:='É';
       if str[j]='W' then str[j]:='Ö';
       if str[j]='E' then str[j]:='Ó';
       if str[j]='R' then str[j]:='Ê';
       if str[j]='T' then str[j]:='Å';
       if str[j]='Y' then str[j]:='Í';
       if str[j]='U' then str[j]:='Ã';
       if str[j]='I' then str[j]:='Ø';
       if str[j]='O' then str[j]:='Ù';
       if str[j]='P' then str[j]:='Ç';
       if str[j]='{' then str[j]:='Õ';
       if str[j]='}' then str[j]:='Ú';
       if str[j]='A' then str[j]:='Ô';
       if str[j]='S' then str[j]:='Û';
       if str[j]='D' then str[j]:='Â';
       if str[j]='F' then str[j]:='À';
       if str[j]='G' then str[j]:='Ï';
       if str[j]='H' then str[j]:='Ğ';
       if str[j]='J' then str[j]:='Î';
       if str[j]='K' then str[j]:='Ë';
       if str[j]='L' then str[j]:='Ä';
       if str[j]=':' then str[j]:='Æ';
       if str[j]='"' then str[j]:='İ';
       if str[j]='Z' then str[j]:='ß';
       if str[j]='X' then str[j]:='×';
       if str[j]='C' then str[j]:='Ñ';
       if str[j]='V' then str[j]:='Ì';
       if str[j]='B' then str[j]:='È';
       if str[j]='N' then str[j]:='Ò';
       if str[j]='M' then str[j]:='Ü';
       if str[j]='<' then str[j]:='Á';
       if str[j]='>' then str[j]:='Ş';
       if str[j]='~' then str[j]:='¨';
   end;
end;

procedure RuEn(var str:String);
var
 j,L:Integer;
begin
 L:=Length(str);
 if L>0 then
  for j:= 1 to L do
   begin
       if str[j]='é' then str[j]:='q';
       if str[j]='ö' then str[j]:='w';
       if str[j]='ó' then str[j]:='e';
       if str[j]='ê' then str[j]:='r';
       if str[j]='å' then str[j]:='t';
       if str[j]='í' then str[j]:='y';
       if str[j]='ã' then str[j]:='u';
       if str[j]='ø' then str[j]:='i';
       if str[j]='ù' then str[j]:='o';
       if str[j]='ç' then str[j]:='p';
       if str[j]='õ' then str[j]:='[';
       if str[j]='ú' then str[j]:=']';
       if str[j]='ô' then str[j]:='a';
       if str[j]='û' then str[j]:='s';
       if str[j]='â' then str[j]:='d';
       if str[j]='à' then str[j]:='f';
       if str[j]='ï' then str[j]:='g';
       if str[j]='ğ' then str[j]:='h';
       if str[j]='î' then str[j]:='j';
       if str[j]='ë' then str[j]:='k';
       if str[j]='ä' then str[j]:='l';
       if str[j]='æ' then str[j]:=';';
       if str[j]='ı' then str[j]:=#39;
       if str[j]='ÿ' then str[j]:='z';
       if str[j]='÷' then str[j]:='x';
       if str[j]='ñ' then str[j]:='c';
       if str[j]='ì' then str[j]:='v';
       if str[j]='è' then str[j]:='b';
       if str[j]='ò' then str[j]:='n';
       if str[j]='ü' then str[j]:='m';
       if str[j]='á' then str[j]:=',';
       if str[j]='ş' then str[j]:='.';
       if str[j]='¸' then str[j]:='`';
       if str[j]='É' then str[j]:='Q';
       if str[j]='Ö' then str[j]:='W';
       if str[j]='Ó' then str[j]:='E';
       if str[j]='Ê' then str[j]:='R';
       if str[j]='Å' then str[j]:='T';
       if str[j]='Í' then str[j]:='Y';
       if str[j]='Ã' then str[j]:='U';
       if str[j]='Ø' then str[j]:='I';
       if str[j]='Ù' then str[j]:='O';
       if str[j]='Ç' then str[j]:='P';
       if str[j]='Õ' then str[j]:='{';
       if str[j]='Ú' then str[j]:='}';
       if str[j]='Ô' then str[j]:='A';
       if str[j]='Û' then str[j]:='S';
       if str[j]='Â' then str[j]:='D';
       if str[j]='À' then str[j]:='F';
       if str[j]='Ï' then str[j]:='G';
       if str[j]='Ğ' then str[j]:='H';
       if str[j]='Î' then str[j]:='J';
       if str[j]='Ë' then str[j]:='K';
       if str[j]='Ä' then str[j]:='L';
       if str[j]='Æ' then str[j]:=':';
       if str[j]='İ' then str[j]:='"';
       if str[j]='ß' then str[j]:='Z';
       if str[j]='×' then str[j]:='X';
       if str[j]='Ñ' then str[j]:='C';
       if str[j]='Ì' then str[j]:='V';
       if str[j]='È' then str[j]:='B';
       if str[j]='Ò' then str[j]:='N';
       if str[j]='Ü' then str[j]:='M';
       if str[j]='Á' then str[j]:='<';
       if str[j]='Ş' then str[j]:='>';
       if str[j]='¨' then str[j]:='~';
   end;
end;

end.
 