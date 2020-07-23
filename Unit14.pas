unit Unit14;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm14 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    OpenDialog2: TOpenDialog;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    Edit2: TEdit;
    procedure Button1Click(Sender: TObject);
  private
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  public
    { Public declarations }
  end;

var
  Form14: TForm14;

implementation

{$R *.dfm}

procedure TForm14.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

procedure TForm14.Button1Click(Sender: TObject);
begin
 if OpenDialog2.Execute then
  Edit1.Text:=OpenDialog2.FileName;
end;

end.
