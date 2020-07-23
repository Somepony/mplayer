unit Unit7;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw;

type
  TForm7 = class(TForm)
    Web: TWebBrowser;
    function ShowModal(URL:String):Integer; overload;
    procedure WebNavigateComplete2(Sender: TObject; const pDisp: IDispatch;
      var URL: OleVariant);
  private
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

var
  Form7: TForm7;

implementation
uses Unit1;

{$R *.dfm}

procedure TForm7.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

function TForm7.ShowModal(URL:String):Integer;
begin
 Web.Navigate(URL);
 Result:= inherited ShowModal;
end;

procedure TForm7.WebNavigateComplete2(Sender: TObject;
  const pDisp: IDispatch; var URL: OleVariant);
var
 i,j,o:Integer;
 URLstr:String;
begin
 URLstr:=Web.LocationURL;
 if Copy(URLstr,1,45)='https://oauth.vk.com/blank.html#access_token=' then
  for i:= 1 To Length(URL) Do
   if Copy(URLstr,i,8)='&expires' then
    begin
     VKAccessToken:=Copy(URLstr,46,i-46);
     VKauth:=True;
     for j:= 1 To Length(URL) Do
      if Copy(URLstr,j,8)='&user_id' then
       begin
        for o:= j To Length(URLstr) Do
         begin
          if Copy(URLstr,o,7)='&secret' then
           begin
            VKDefaultID:=Copy(URLstr,j+9,o-(j+9));
            VKSecret:=Copy(URLstr,o+8,Length(URLstr)-(o+8));
            Break;
           end;
          VKDefaultID:=Copy(URLstr,j+9,Length(URLstr)-(j+8));
         end;
        Break;
       end;
     Form7.ModalResult:=mrOK;
     Break;
    end;
end;

end.
