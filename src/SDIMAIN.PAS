unit SDIMAIN;

interface

uses Windows, Classes, Graphics, Forms, Controls, Menus,
  Dialogs, StdCtrls, Buttons, ExtCtrls, ComCtrls, ImgList, StdActns,
  ActnList, ToolWin, SysUtils, Messages;

type
  TSDIAppForm = class(TForm)
    Timer1: TTimer;
    Label3: TLabel;
    lblRightScore: TLabel;
    Label4: TLabel;
    lblLeftScore: TLabel;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseEnter(Sender: TObject);
    procedure FormMouseLeave(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    xMax : integer;
    YMax : integer;
    ballX,ballY : integer;
    rBatX,rBatY : integer;
    lBatX,lBatY : integer;
    randX,randY : integer;
    rMouseX, rMouseY : integer;
    lMouseX, lMouseY : integer;
    leftScore,rightScore : integer;
    { Private declarations }
    procedure StartGameLoop();
    procedure StopGameLoop();
    procedure Draw();
    procedure DrawBall();
    procedure DrawRightBat();
    procedure DrawLeftBat();
    procedure DrawMedian();
    procedure ResetBall();
    procedure OnIdleHandler(Sender: TObject; var Done: Boolean);
  public
    { Public declarations }
  end;

var
  SDIAppForm: TSDIAppForm;
const
  xMin : integer = 0;
  yMin : integer = 0;
  randFactor : integer = 10;
  ballRadius : integer = 10;
  batWidth : integer = 20;
  batLength : integer = 100;


implementation

uses about;

{$R *.dfm}

procedure TSDIAppForm.FormCreate(Sender: TObject);
begin
  self.DoubleBuffered := true;

  xMax := ClientWidth;
  yMax := ClientHeight;

  rMouseX := 0;
  rMouseY := 0;

  ballX := Trunc(xMax/2);
  ballY := Trunc(yMax/2);

  Canvas.Pen.Width := 2;
  Canvas.Pen.Color := clDkGray;

  Randomize();
  randX := Random(randFactor)+1;
  randY := Random(randFactor)+1;

  leftScore := 0;
  rightScore := 0;
  StartGameLoop();
end;

procedure TSDIAppForm.FormDestroy(Sender: TObject);
begin
  StopGameLoop();
end;

procedure TSDIAppForm.FormMouseEnter(Sender: TObject);
begin
  //ShowCursor(false);
end;

procedure TSDIAppForm.FormMouseLeave(Sender: TObject);
begin
  //ShowCursor(true);
end;

procedure TSDIAppForm.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if (X < Trunc(ClientWidth/2)) then begin
    lMouseX := X;
    lMouseY := Y;
  end
  else if (X > Trunc(ClientWidth/2)) then begin
    rMouseX := X;
    rMouseY := Y;
  end;
end;


procedure TSDIAppForm.FormResize(Sender: TObject);
begin
  xMax := ClientWidth;
  yMax := ClientHeight;
  Label3.Left := xMax-110;
  lblRightScore.Left := xMax-50;
end;

procedure TSDIAppForm.StartGameLoop();
begin
  Timer1.Enabled := true;
end;

procedure TSDIAppForm.StopGameLoop();
begin
  Timer1.Enabled := false;
end;

procedure TSDIAppForm.Timer1Timer(Sender: TObject);
begin
  Self.Repaint();
  lblLeftScore.Caption := IntToStr(leftScore);
  lblRightScore.Caption := IntToStr(rightScore);
  Draw();
end;

procedure TSDIAppForm.Draw();
begin
  Canvas.Pen.Color := clDkGray;
  Canvas.Brush.Color := clWhite;
  DrawBall();
  Canvas.Brush.Color := clWhite;
  DrawRightBat();
  DrawLeftBat();
  Canvas.Pen.Color := clWhite;
  DrawMedian();
end;

procedure TSDIAppForm.DrawBall();
begin
  ballX := ballX+randX;
  ballY := ballY+randY;

  if ballX+ballRadius >= xMax then begin
    Inc(rightScore);
    ResetBall();
  end;
  if ballX-ballRadius <= xMin then begin
    Inc(leftScore);
    ResetBall();
  end;
  if ballY+ballRadius >= yMax then begin
    ballY := yMax-ballRadius;
    randY := (Random(randFactor)+1)*(-1);
  end;
  if ballY-ballRadius <= yMin then
    randY := Random(randFactor)+1;

  if ((ballX+ballRadius)>= xMax-batWidth) and (ballY >= rBatY) and (ballY <= rBatY+batLength) then
    randX := Random(randFactor)*(-1);

  if ((ballX-ballRadius)<= xMin+batWidth) and (ballY >= lBatY) and (ballY <= lBatY+batLength) then
    randX := Random(randFactor);

  Canvas.Ellipse(ballX-ballRadius, ballY-ballRadius, ballX+ballRadius,ballY+ballRadius);
end;

procedure TSDIAppForm.DrawRightBat();
begin
  rBatY := rMouseY;
  if rBatY <= yMin then
    rBatY := 0;
  if rBatY+batLength >= yMax then
    rBatY := yMax-batLength;
  
  Canvas.Rectangle(xMax-batWidth,rBatY,xMax,rBatY+batLength);
end;

procedure TSDIAppForm.DrawLeftBat();
begin
  lBatY := lMouseY;
  if lBatY <= yMin then
    lBatY := 0;
  if lBatY+batLength >= yMax then
    lBatY := yMax-batLength;

  Canvas.Rectangle(xMin,lBatY,xMin+batWidth,lBatY+batLength);
end;

procedure TSDIAppForm.DrawMedian();
  var xMid : integer;
begin
  xMid := Trunc(ClientWidth/2);
  Canvas.MoveTo(xMid,yMin+50);
  Canvas.LineTo(xMid, yMax-50);
end;

procedure TSDIAppForm.ResetBall();
  var
    rand : integer;
    negative : integer;
begin
  negative := Random(2);
  rand := Random(randFactor)+1;
  if negative = 0 then
    randX := rand
  else
    randX := rand*(-1);
  negative := Random(2);
  rand := Random(randFactor)+1;
  if negative = 0 then
    randY := rand
  else
    randY := rand*(-1);

  ballX := Trunc(xMax/2);
  ballY := Trunc(yMax/2);
end;

procedure TSDIAppForm.OnIdleHandler(Sender: TObject; var Done: Boolean); 
const
  LOOP_TIME = 10;
var 
  start_time: DWORD; 
begin 
  // Get loop start time 
  start_time := GetTickCount();
  Refresh;
  Draw();
  // Wait until LOOP_TIME 
  while(GetTickCount() - start_time < LOOP_TIME) do; 
end;

end.
