unit Unit5;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Clipbrd;

type
  TForm5 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    function ShowModal:Integer; override;
  private
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

var
  Form5: TForm5;

implementation

{$R *.dfm}

procedure TForm5.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

function TForm5.ShowModal:Integer;
begin
 if (Copy(Trim(Clipboard.AsText),1,7)='http://')
       or
    (Copy(Trim(Clipboard.AsText),1,8)='https://')
       or
    (Copy(Trim(Clipboard.AsText),1,6)='ftp://')
 then Edit1.Text:=Trim(Clipboard.AsText)
 else Edit1.Text:='http://';
 Result:= inherited ShowModal;
end;

end.
