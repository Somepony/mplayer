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
       if str[j]='q' then str[j]:='�';
       if str[j]='w' then str[j]:='�';
       if str[j]='e' then str[j]:='�';
       if str[j]='r' then str[j]:='�';
       if str[j]='t' then str[j]:='�';
       if str[j]='y' then str[j]:='�';
       if str[j]='u' then str[j]:='�';
       if str[j]='i' then str[j]:='�';
       if str[j]='o' then str[j]:='�';
       if str[j]='p' then str[j]:='�';
       if str[j]='[' then str[j]:='�';
       if str[j]=']' then str[j]:='�';
       if str[j]='a' then str[j]:='�';
       if str[j]='s' then str[j]:='�';
       if str[j]='d' then str[j]:='�';
       if str[j]='f' then str[j]:='�';
       if str[j]='g' then str[j]:='�';
       if str[j]='h' then str[j]:='�';
       if str[j]='j' then str[j]:='�';
       if str[j]='k' then str[j]:='�';
       if str[j]='l' then str[j]:='�';
       if str[j]=';' then str[j]:='�';
       if str[j]=#39 then str[j]:='�';
       if str[j]='z' then str[j]:='�';
       if str[j]='x' then str[j]:='�';
       if str[j]='c' then str[j]:='�';
       if str[j]='v' then str[j]:='�';
       if str[j]='b' then str[j]:='�';
       if str[j]='n' then str[j]:='�';
       if str[j]='m' then str[j]:='�';
       if str[j]=',' then str[j]:='�';
       if str[j]='.' then str[j]:='�';
       if str[j]='`' then str[j]:='�';
       if str[j]='Q' then str[j]:='�';
       if str[j]='W' then str[j]:='�';
       if str[j]='E' then str[j]:='�';
       if str[j]='R' then str[j]:='�';
       if str[j]='T' then str[j]:='�';
       if str[j]='Y' then str[j]:='�';
       if str[j]='U' then str[j]:='�';
       if str[j]='I' then str[j]:='�';
       if str[j]='O' then str[j]:='�';
       if str[j]='P' then str[j]:='�';
       if str[j]='{' then str[j]:='�';
       if str[j]='}' then str[j]:='�';
       if str[j]='A' then str[j]:='�';
       if str[j]='S' then str[j]:='�';
       if str[j]='D' then str[j]:='�';
       if str[j]='F' then str[j]:='�';
       if str[j]='G' then str[j]:='�';
       if str[j]='H' then str[j]:='�';
       if str[j]='J' then str[j]:='�';
       if str[j]='K' then str[j]:='�';
       if str[j]='L' then str[j]:='�';
       if str[j]=':' then str[j]:='�';
       if str[j]='"' then str[j]:='�';
       if str[j]='Z' then str[j]:='�';
       if str[j]='X' then str[j]:='�';
       if str[j]='C' then str[j]:='�';
       if str[j]='V' then str[j]:='�';
       if str[j]='B' then str[j]:='�';
       if str[j]='N' then str[j]:='�';
       if str[j]='M' then str[j]:='�';
       if str[j]='<' then str[j]:='�';
       if str[j]='>' then str[j]:='�';
       if str[j]='~' then str[j]:='�';
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
       if str[j]='�' then str[j]:='q';
       if str[j]='�' then str[j]:='w';
       if str[j]='�' then str[j]:='e';
       if str[j]='�' then str[j]:='r';
       if str[j]='�' then str[j]:='t';
       if str[j]='�' then str[j]:='y';
       if str[j]='�' then str[j]:='u';
       if str[j]='�' then str[j]:='i';
       if str[j]='�' then str[j]:='o';
       if str[j]='�' then str[j]:='p';
       if str[j]='�' then str[j]:='[';
       if str[j]='�' then str[j]:=']';
       if str[j]='�' then str[j]:='a';
       if str[j]='�' then str[j]:='s';
       if str[j]='�' then str[j]:='d';
       if str[j]='�' then str[j]:='f';
       if str[j]='�' then str[j]:='g';
       if str[j]='�' then str[j]:='h';
       if str[j]='�' then str[j]:='j';
       if str[j]='�' then str[j]:='k';
       if str[j]='�' then str[j]:='l';
       if str[j]='�' then str[j]:=';';
       if str[j]='�' then str[j]:=#39;
       if str[j]='�' then str[j]:='z';
       if str[j]='�' then str[j]:='x';
       if str[j]='�' then str[j]:='c';
       if str[j]='�' then str[j]:='v';
       if str[j]='�' then str[j]:='b';
       if str[j]='�' then str[j]:='n';
       if str[j]='�' then str[j]:='m';
       if str[j]='�' then str[j]:=',';
       if str[j]='�' then str[j]:='.';
       if str[j]='�' then str[j]:='`';
       if str[j]='�' then str[j]:='Q';
       if str[j]='�' then str[j]:='W';
       if str[j]='�' then str[j]:='E';
       if str[j]='�' then str[j]:='R';
       if str[j]='�' then str[j]:='T';
       if str[j]='�' then str[j]:='Y';
       if str[j]='�' then str[j]:='U';
       if str[j]='�' then str[j]:='I';
       if str[j]='�' then str[j]:='O';
       if str[j]='�' then str[j]:='P';
       if str[j]='�' then str[j]:='{';
       if str[j]='�' then str[j]:='}';
       if str[j]='�' then str[j]:='A';
       if str[j]='�' then str[j]:='S';
       if str[j]='�' then str[j]:='D';
       if str[j]='�' then str[j]:='F';
       if str[j]='�' then str[j]:='G';
       if str[j]='�' then str[j]:='H';
       if str[j]='�' then str[j]:='J';
       if str[j]='�' then str[j]:='K';
       if str[j]='�' then str[j]:='L';
       if str[j]='�' then str[j]:=':';
       if str[j]='�' then str[j]:='"';
       if str[j]='�' then str[j]:='Z';
       if str[j]='�' then str[j]:='X';
       if str[j]='�' then str[j]:='C';
       if str[j]='�' then str[j]:='V';
       if str[j]='�' then str[j]:='B';
       if str[j]='�' then str[j]:='N';
       if str[j]='�' then str[j]:='M';
       if str[j]='�' then str[j]:='<';
       if str[j]='�' then str[j]:='>';
       if str[j]='�' then str[j]:='~';
   end;
end;

end.
 