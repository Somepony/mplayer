unit Unit6;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm6 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
  private
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.dfm}

procedure TForm6.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

end.
