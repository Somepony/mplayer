unit Unit17;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, RzTrkBar, Math,
  Vcl.ExtCtrls, acPNG, BASS;

type
  TForm17 = class(TForm)
    FreqBar: TRzTrackBar;
    Label1: TLabel;
    Edit1: TEdit;
    VolumeTrackBar: TRzTrackBar;
    Label2: TLabel;
    BalanceTrackBar: TRzTrackBar;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    Image4: TImage;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Shape1: TShape;
    Button1: TButton;
    procedure UpdateSample;
    procedure FreqBarChange(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit1KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Image1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image3Click(Sender: TObject);
    procedure Image4Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure VolumeTrackBarChange(Sender: TObject);
    procedure BalanceTrackBarChange(Sender: TObject);
    procedure VolumeTrackBarMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TWaveForm=(wfSine,wfSquare,wfTriangle,wfSawtooth);

var
  Form17: TForm17;
  GenFreq:Integer;
  ChangedByUser:Boolean=False;
  WaveForm:TWaveForm=wfSine;
  GenSample:HSAMPLE;
  GenChannel:HCHANNEL;
  data,datai:PSmallInt;
  GenPlaying:Boolean=False;

implementation

{$R *.dfm}

uses Unit1;

procedure TForm17.UpdateSample;
var
 period,period4,period2,cycles,a,frequency:Integer;
 tp:Pointer;
 tmp:SmallInt;
begin
 BASS_SampleFree(GenSample);
 frequency:=StrToIntDef(Edit1.Text,0);
 if frequency<1 then frequency:=1
 else if frequency>20000 then frequency:=20000;
 if frequency<=1562 then
  period:=128
 else if frequency<=3125 then
  period:=64
 else if frequency<=6250 then
  period:=32
 else if frequency<=12500 then
  period:=16
 else
  period:=8;
 cycles:=frequency;
 GenSample:=BASS_SampleCreate(cycles * period * 2, frequency * period, 1, 1, BASS_SAMPLE_LOOP);
 data:=AllocMem(SizeOf(SmallInt)*cycles*period);
 datai:=data;
 case WaveForm of
  wfSine:
   begin
    for a := 0 to period-1 do
     begin
      Integer(datai):=Integer(data)+a*SizeOf(SmallInt);
      tmp:=Round(32767*sin(a*6.283185/period));
      datai^:=tmp;
     end;
   end;
  wfSquare:
   begin
    period2:=period div 2;
    for a := 0 to period2-1 do
     begin
      Integer(datai):=Integer(data)+a*SizeOf(SmallInt);
      tmp:=32767;
      datai^:=tmp;
      Integer(datai):=Integer(data)+(period2+a)*SizeOf(SmallInt);
      datai^:=-tmp;
     end;
   end;
  wfTriangle:
   begin
    period4:=period div 4;
    for a := 0 to period4-1 do
     begin
      Integer(datai):=Integer(data)+a*SizeOf(SmallInt);
      tmp:=Round(32767*a/period4);
      datai^:=tmp;
      Integer(datai):=Integer(data)+(period4+a)*SizeOf(SmallInt);
      datai^:=32767-tmp;
      Integer(datai):=Integer(data)+(2*period4+a)*SizeOf(SmallInt);
      datai^:=-tmp;
      Integer(datai):=Integer(data)+(3*period4+a)*SizeOf(SmallInt);
      datai^:=-32767+tmp;
     end;
   end;
  wfSawtooth:
   begin
    for a := 0 to period-1 do
     begin
      Integer(datai):=Integer(data)+a*SizeOf(SmallInt);
      tmp:=Round(65534*(a/(period-1))-32767);
      datai^:=tmp;
     end;
   end;
 end;
 for a := 1 to cycles-1 do
  begin
   Integer(tp):=Integer(data)+Round(a*period*2);
   CopyMemory(tp,data,period*2);
  end;
 BASS_SampleSetData(GenSample,data);
 FreeMem(data);
 GenChannel:=BASS_SampleGetChannel(GenSample,False);
 BASS_ChannelSetAttribute(GenChannel,BASS_ATTRIB_VOL,VolumeTrackBar.Position/1000);
 BASS_ChannelSetAttribute(GenChannel,BASS_ATTRIB_PAN,BalanceTrackBar.Position/1000);
 if GenPlaying then BASS_ChannelPlay(GenChannel,False);
end;

procedure TForm17.VolumeTrackBarChange(Sender: TObject);
begin
 BASS_ChannelSetAttribute(GenChannel,BASS_ATTRIB_VOL,VolumeTrackBar.Position/1000);
end;

procedure TForm17.VolumeTrackBarMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Button=mbLeft then
  (Sender as TRzTrackBar).Position:=Form1.DoSomeUnicornMagic(X,(Sender as TRzTrackBar).Width,(Sender as TRzTrackBar).Max,(Sender as TRzTrackBar).Min);
end;

procedure TForm17.BalanceTrackBarChange(Sender: TObject);
begin
 BASS_ChannelSetAttribute(GenChannel,BASS_ATTRIB_PAN,BalanceTrackBar.Position/1000);
end;

procedure TForm17.Button1Click(Sender: TObject);
begin
 GenPlaying:=not GenPlaying;
 if GenPlaying then
  BASS_ChannelPlay(GenChannel,False)
 else
  BASS_ChannelPause(GenChannel);
end;

procedure TForm17.Edit1Change(Sender: TObject);
var
 val,ps:Integer;
begin
 val:=StrToIntDef(Edit1.Text,0);
 if val<1 then
  val:=1
 else if val>20000 then
  val:=20000;
 if val<=100 then
  ps:=Round(val*25)
 else if val<=500 then
  ps:=Round((val-100)*3.125)+2500
 else if val<=1000 then
  ps:=Round((val-500)*2.5)+3750
 else if val<=5000 then
  ps:=Round((val-1000)*0.3125)+5000
 else if val<=20000 then
  ps:=Round((val-5000)*0.25)+6250;
 FreqBar.Position:=ps;
 UpdateSample;
end;

procedure TForm17.Edit1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 ChangedByUser:=True;
end;

procedure TForm17.Edit1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 ChangedByUser:=False;
end;

procedure TForm17.FormCreate(Sender: TObject);
begin
 Edit1.Text:='440';
end;

procedure TForm17.FreqBarChange(Sender: TObject);
var
 ps:Integer;
begin
 ps:=FreqBar.Position;
 if ps<=2500 then
  GenFreq:=Round(ps/25)
 else if ps<=3750 then
  GenFreq:=Round((ps-2500)/3.125)+100
 else if ps<=5000 then
  GenFreq:=Round((ps-3750)/2.5)+500
 else if ps<=6250 then
  GenFreq:=Round((ps-5000)/0.3125)+1000
 else if ps<=10000 then
  GenFreq:=Round((ps-6250)/0.25)+5000;
 if GenFreq=0 then GenFreq:=1;
 if not ChangedByUser then Edit1.Text:=GenFreq.ToString();
end;

procedure TForm17.Image1Click(Sender: TObject);
begin
 Shape1.Left:=Image1.Left-2;
 WaveForm:=wfSine;
 UpdateSample;
end;

procedure TForm17.Image2Click(Sender: TObject);
begin
 Shape1.Left:=Image2.Left-2;
 WaveForm:=wfSquare;
 UpdateSample;
end;

procedure TForm17.Image3Click(Sender: TObject);
begin
 Shape1.Left:=Image3.Left-2;
 WaveForm:=wfTriangle;
 UpdateSample;
end;

procedure TForm17.Image4Click(Sender: TObject);
begin
 Shape1.Left:=Image4.Left-2;
 WaveForm:=wfSawtooth;
 UpdateSample;
end;

end.
