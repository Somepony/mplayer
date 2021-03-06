unit Unit9;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, BASS, MMSystem, osc_vis;

type
  TForm9 = class(TForm)
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    procedure WMSetIcon(var Message:TWMSetIcon); message WM_SETICON;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  end;

const
  SPECWIDTH	= 256 {368};	// display width
  SPECHEIGHT	= 49 {127};	// height (changing requires palette adjustments too)
  BANDS		= 28;

var
  Form9: TForm9;
  SpecMode:Integer=4;
  SpecPos:Integer=0;
  SpecBuf:Pointer;
  SpecDC:HDC=0;
  SpecBmp:HBITMAP=0;
  BI:TBITMAPINFO;
  pal:array[Byte] of TRGBQUAD;
  Timer:DWORD=0;

implementation

uses Unit1;

{$R *.dfm}

function IntPower(const Base: Extended; const Exponent: Integer): Extended;
asm
        mov     ecx, eax
        cdq
        fld1                      { Result := 1 }
        xor     eax, edx
        sub     eax, edx          { eax := Abs(Exponent) }
        jz      @@3
        fld     Base
        jmp     @@2
@@1:    fmul    ST, ST            { X := Base * Base }
@@2:    shr     eax,1
        jnc     @@1
        fmul    ST(1),ST          { Result := Result * X }
        jnz     @@1
        fstp    st                { pop X from FPU stack }
        cmp     ecx, 0
        jge     @@3
        fld1
        fdivrp                    { Result := 1 / Result }
@@3:
        fwait
end;

function Power(const Base, Exponent: Extended): Extended;
begin
  if Exponent = 0.0 then
    Result := 1.0               { n**0 = 1 }
  else if (Base = 0.0) and (Exponent > 0.0) then
    Result := 0.0               { 0**n = 0, n > 0 }
  else if (Frac(Exponent) = 0.0) and (Abs(Exponent) <= MaxInt) then
    Result := IntPower(Base, Integer(Trunc(Exponent)))
  else
    Result := Exp(Exponent * Ln(Base))
end;

function Log10(const X : Extended) : Extended;
asm
	FLDLG2     { Log base ten of 2 }
	FLD	X
	FYL2X
	FWAIT
end;

procedure TForm9.WMSetIcon(var Message:TWMSetIcon);
begin
 if (csDesigning in ComponentState) or not (csDestroying in ComponentState) then
  inherited;
end;

procedure TForm9.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_THICKFRAME;
end;

procedure TForm9.WMNCHitTest(var Message: TWMNCHitTest);
begin
  inherited;
  with Message do begin
    Result := HTCLIENT;
  end;
end;

procedure UpdateSpectrum(uTimerID, uMsg, dwUser, dw1, dw2 : Integer); stdcall;
type
  TSingleArray	= array of Single;
var
  DC		: HDC;
  X, Y, Z,
  I, J, sc	: Integer;
  Sum		: Single;
  fft		: array[0..1023] of Single; // get the FFT data
  ci		: BASS_CHANNELINFO;
  Buf		: TSingleArray;
begin
if Playing then
 begin
  if SpecMode = 3 then  // waveform
  begin
    FillChar(SpecBuf^, SPECWIDTH * SPECHEIGHT, 0);
    BASS_ChannelGetInfo(MediaFile, ci); // get number of channels
    SetLength(Buf, ci.chans * SPECWIDTH);
    Y := 0;
    BASS_ChannelGetData(MediaFile, buf, (ci.chans * SPECWIDTH * SizeOf(Single)) or BASS_DATA_FLOAT); // get the sample data (floating-point to avoid 8 & 16 bit processing)
    for I := 0 to ci.chans - 1 do
    begin
      for X := 0 to SPECWIDTH - 1 do
      begin
	Z := Trunc((1 - Buf[X * Integer(ci.chans) + I]) * SPECHEIGHT / 2); // invert and scale to fit display
	if Z < 0 then
	  Z := 0
	else if Z >= SPECHEIGHT then
	  Z := SPECHEIGHT - 1;
	if X = 0 then
	  Y := Z;
	repeat  // draw line from previous sample...
	  if Y < Z then
	    inc(Y)
	  else if Y > Z then
	    dec(Y);
	  if (I and 1) = 1 then
	    Byte(Pointer(Longint(SpecBuf) + Y * SPECWIDTH + X)^) := 127
	  else
	    Byte(Pointer(Longint(SpecBuf) + Y * SPECWIDTH + X)^) := 1;
	until Y = Z;
      end;
    end;
  end
  else
  begin
    BASS_ChannelGetData(MediaFile, @fft, BASS_DATA_FFT2048);
    case SpecMode of
      0 :  // "normal" FFT
      begin
	FillChar(SpecBuf^, SPECWIDTH * SPECHEIGHT, 0);
	Z := 0;
	for X := 0 to pred(SPECWIDTH) div 2 do
	begin
	  Y := Trunc(sqrt(fft[X + 1]) * 3 * SPECHEIGHT - 4); // scale it (sqrt to make low values more visible)
//	Y := Trunc(fft[X + 1] * 10 * SPECHEIGHT); // scale it (linearly)
	  if Y > SPECHEIGHT then
	    Y := SPECHEIGHT; // cap it

	  if (X > 0) and (Z = (Y + Z) div 2) then // interpolate from previous to make the display smoother
	    while (Z >= 0) do
	    begin
	      Byte(Pointer(Longint(SpecBuf) + Z * SPECWIDTH + X * 2 - 1)^) := Z + 1;
	      dec(Z);
	    end;

	  Z := Y;
	  while (Y >= 0) do
	  begin
	    Byte(Pointer(Longint(SpecBuf) + Y * SPECWIDTH + X * 2)^) := Y + 1; // draw level
	    dec(Y);
	  end;
        end;
      end;
      1 :   // logarithmic, acumulate & average bins
      begin
        I := 0;
        FillChar(SpecBuf^, SPECWIDTH * SPECHEIGHT, 0);
	for X := 0 to BANDS - 1 do
	begin
	  Sum := 0;
	  J  := Trunc(Power(2, X * 10.0 / (BANDS - 1)));
	  if J > 1023 then
	    J := 1023;
	  if J <= I then
	    J := I + 1; // make sure it uses at least 1 FFT bin
	  sc := 10 + J - I;

	  while I < J do
	  begin
	    Sum := Sum + fft[1 + I];
	    inc(I);
	  end;

	  Y := Trunc((sqrt(Sum / log10(sc)) * 1.7 * SPECHEIGHT) - 4); // scale it
	  if Y > SPECHEIGHT then
	    Y := SPECHEIGHT; // cap it
	  while (Y >= 0) do
	  begin
	    FillChar(Pointer(Longint(SpecBuf) + Y * SPECWIDTH + X * (SPECWIDTH div BANDS))^, SPECWIDTH div BANDS - 2, Y + 1); // draw bar
	    dec(Y);
	  end;
	end;
      end;
      2 :  // "3D"
      begin
	for X := 0 to SPECHEIGHT - 1 do
	begin
	  Y := Trunc(sqrt(fft[x + 1]) * 3 * 127); // scale it (sqrt to make low values more visible)
	  if Y > 127 then
	    Y := 127; // cap it
    if Y=0 then Y:=1; // ���� ������ �������� ��� ������
	  Byte(Pointer(Longint(SpecBuf) + X * SPECWIDTH + SpecPos)^) := 128 + Y; // plot it
	end;
	// move marker onto next position
	SpecPos := (SpecPos + 1) mod SPECWIDTH;
	for X := 0 to SPECHEIGHT do
	  Byte(Pointer(Longint(SpecBuf) + X * SPECWIDTH + SpecPos)^) := 255;
      end;
    end;
  end;
  // update the display
  if SpecMode<>4 then
   begin
    DC := GetDC(Form1.Handle);
    try
      BitBlt(DC, 8, 88, SPECWIDTH, SPECHEIGHT, SpecDC, 0, 0, SRCCOPY);
    finally
      ReleaseDC(Form1.Handle, DC);
    end;
   end;
 end;
end;

procedure TForm9.FormCreate(Sender: TObject);
var
  I	: Integer;
begin
 FillChar(BI, SizeOf(BI), 0);
      with BI.bmiHeader do        // fill structure with parameter bitmap
      begin
        biSize		:= SizeOf(BI.bmiHeader);
        biWidth		:= SPECWIDTH;
        biHeight	:= SPECHEIGHT; // upside down (line 0=bottom)
        biPlanes	:= 1;
        biBitCount	:= 8;
        biClrImportant	:= 256;
        biClrUsed	:= 256;
      end;

      // setup palette
      for I := 0 to 127 do
      begin
	pal[I].rgbGreen := 255 - 2 * I;
	pal[I].rgbRed   := 2 * I;
      end;

      for I := 0 to 32 do
      begin
	pal[128 + I].rgbBlue       := 8 * I;
	pal[128 + 32 + I].rgbBlue  := 255;
	pal[128 + 32 + I].rgbRed   := 8 * I;
	pal[128 + 64 + I].rgbRed   := 255;
	pal[128 + 64 + I].rgbBlue  := 8 * (31 - I);
	pal[128 + 64 + I].rgbGreen := 8 * I;
	pal[128 + 96 + I].rgbRed   := 255;
	pal[128 + 96 + I].rgbGreen := 255;
	pal[128 + 96 + I].rgbBlue  := 8 * I;
      end;

      // create the bitmap
      SpecBmp := CreateDIBSection(0, BI, DIB_RGB_COLORS, SpecBuf, 0, 0);
      SpecDC  := CreateCompatibleDC(0);
      SelectObject(SpecDC, SpecBmp);

      // setup update timer (40hz)
      timer := timeSetEvent(25, 25, @UpdateSpectrum, 0, TIME_PERIODIC);
end;

end.
