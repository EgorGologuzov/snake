uses graphABC, ABCobjects, Timers, ABCButtons;
uses TableOfRecords;

var direct : byte;  //напраление движения : 0 - вверх, 1 - вправо, 2 - вниз, 3 - влево
    w, h : integer; //ширина и высота поля в клетках
    x, y : integer; //координаты головы
    speed : integer;   //скорость
    ScoreLabel : RectangleABC; //
    body : array of RectangleABC; //тело змейки
    queue : array of integer; //очередь на передвижение сегментов тела змеи
    apple : RectangleABC; //яблоко  и 
    head : RectangleABC; //PictureABC; //голова змеи
    stepTimer : Timer; //отмеряет время шага
    iFirst : integer; //хранит индекс первого в очереди сегмента тела
    mayCnangeDirect : boolean; //разрешение на смену направления, обновляется на True каждый шаг, на False каждое нажатие на клавишу
    butPlay, butPause : ButtonABC; //объект кнопка пауза
    LooseParametr : boolean; //пересекается ли голова с телом, обновляется каждый шаг в процедуре Step
    CheckOnLooseTimer : Timer;
    GameInProgress : boolean;
    

//предописание подпрограмм
procedure Launch; forward;
procedure StartGame; forward;
procedure CheckOnLooseProcedure; forward;
procedure Pause; forward;
function BoolToStr (bool : boolean) : string; forward;
procedure FinishGame; forward;


procedure DrawMap;
begin
  SetBrushColor(clBlack);
  FillRectangle(0,0,w*20,h*20);
  SetPenColor(clWhite);
  //SetPenWidth(1);
  for var i := 0 to w do
  begin
    Line(i*20,0,i*20,h*20);
  end;
  for var i := 0 to h do
  begin
    Line(0,i*20,w*20,i*20);
  end;
end;
procedure KeyDown(key: integer);
  begin
    if mayCnangeDirect then
    begin
      case key of
        VK_Up: if (direct <> 1) then direct := 3;
        VK_Down: if (direct <> 3) then direct := 1;
        VK_Right: if (direct <> 0) then direct := 2;
        VK_Left: if (direct <> 2) then direct := 0;
      end;
      mayCnangeDirect := False;
    end;

    case key of
      VK_Space : if GameInProgress then Pause else StartGame;
      VK_Enter : if GameInProgress then FinishGame else StartGame;
    end;
  end;


function NotInBody(p : Point) : boolean;
begin
  for var i := 0 to length(body)- 1 do
    if p = body[i].Position then
    begin
      Result := False;
      exit;
    end;
  Result := True;
end;
procedure MoveApple;
begin
  repeat
    apple.MoveTo(random(w-1)*20,random(h-1)*20);
  until NotInBody(apple.Position) and (apple.Position <> head.Position);
end;
function BoolToStr (bool : boolean) : string;
begin
  if bool then Result := 'True' else Result := 'False';
end;

function NewCrd(c : integer; IsX,plus : boolean) : integer;
begin
  if plus = true then c += 20 else c -= 20;
  if IsX = True then
    if c < 0 then result := w*20 - 20
    else if c > w*20 - 20 then result := 0
    //else if plus = true then result := c+20
    else result := c
  else
    if c < 0 then result := h*20-20
    else if c > h*20-20 then result := 0
    //else if plus = true then result := c+20
    else result := c;
end;
procedure Step;
begin
  //перемещение тела
    //если съели яблоко
  if head.Position = apple.Position then
  begin
    SetLength(body,length(body) + 1);
    //строка создает новый прямоугольник в конце массива body с координатами первого в очереди на перемещение сегмента
    body[length(body) - 1] := new RectangleABC(body[queue.FindIndex(i -> i = 0)].Position.X, body[queue.FindIndex(i -> i = 0)].Position.Y, 20, 20, clGreen);
    queue.Transform(i -> i + 1);
    SetLength(queue,length(queue) + 1);
    queue[length(queue) - 1] := 0;
    MoveApple;
    ScoreLabel.Number += 1;
  end;
    //перемещение 1го в очереди элемента к голове
  iFirst := queue.FindIndex(i -> i = 0);
  body[iFirst].MoveTo(head.Position.X, head.Position.Y);
  queue[iFirst] := length(queue);
  queue.Transform(i -> i - 1);
  //перемещение головы
  case direct of
    0: begin x := NewCrd(x,true,false); head.MoveTo(x,y); end;
    1: begin y := NewCrd(y,false,true); head.MoveTo(x,y); end;
    2: begin x := NewCrd(x,true,true); head.MoveTo(x,y); end;
    3: begin y := NewCrd(y,false,false); head.MoveTo(x,y); end;
  end;
  head.ToFront;
  //если пересечение с телом, то 
  if not NotInBody(head.Position) then 
  begin
    LooseParametr := True;
  end;
  //разрешение на смену направления движения (дается толко 1 на шаг)
  mayCnangeDirect := True;
end;
procedure Pause;
begin
  if GameInProgress then
    if stepTimer.Enabled then
    begin
      stepTimer.Stop;
      butPause.Text := 'Возобновить';
    end
    else
    begin
      stepTimer.Start;
      butPause.Text := 'Пауза';
    end;
end;

//рисуем карту, создаем змею (длиной 3), яблоко, таймер, счет в первый раз
procedure Launch;
begin
  //рисуем карту и счет
  DrawMap;
  ScoreLabel := new RectangleABC(w*20, 0, WindowWidth - w*20, 60, clWhite);
  ScoreLabel.Bordered := False;
  ScoreLabel.Number := 0;
  //создаем тело змеи и голову
  SetLength(body,3);
  SetLength(queue,3);
  for var i := 0 to 2 do
  begin
    body[i] := new RectangleABC(x,y,20,20,clGreen);
    queue[i] := i;
  end;
  head := new RectangleABC(x, y, 20, 20, clRed);//PictureABC(x,y,'C:\PABCWork.NET\Snake\Smale');
  head.ToFront;
  head.FontStyle := fsBold;
  head.Text := ':)';
  //создаем яблоко
  apple := new RectangleABC(random(w-1)*20,random(h-1)*20,20,20,clYellow);
  apple.ToBack;
  MoveApple;
end;

procedure StartGame;
begin
  if not GameInProgress then
  begin
    GameInProgress := True;
    butPlay.Text := 'Заново';
    stepTimer.Start;
    CheckOnLooseTimer.Start;
    end
  else
  begin
    FinishGame;
  end;
end;


procedure FinishGame;
begin
  WriteNewRecord(ScoreLabel.Number);
  GameInProgress := False;
  LooseParametr := False;
  CheckOnLooseTimer.Stop;
  butPlay.Text := 'Играть';
  butPause.Text := 'Пауза';
  //уничтожение всех объектов
  head.Destroy;
  apple.Destroy;
  stepTimer.Stop;
  x := 300; y := 300;
  direct := 0;
  ScoreLabel.Number := 0; 
  for var i := 0 to length(body) - 1 do
    body[i].Destroy;
  //создаем обекты заново
    //создаем тело змеи
  SetLength(body,3);
  SetLength(queue,3);
  for var i := 0 to 2 do
  begin
    body[i] := new RectangleABC(x,y,20,20,clGreen);
    queue[i] := i;
  end;
  head := new RectangleABC(x, y, 20, 20, clRed);//PictureABC(x,y,'C:\PABCWork.NET\Snake\Smale');
  head.ToFront;
  head.FontStyle := fsBold;
  head.Text := ':)';
    //создаем яблоко
  apple := new RectangleABC(random(w-1)*20,random(h-1)*20,20,20,clYellow);
  apple.ToBack;
  MoveApple;
end;

procedure CheckOnLooseProcedure;
begin
  if LooseParametr then 
    begin
      stepTimer.Stop;
      butPlay.Text := 'Заново';
      head.Text := ':(';
    end;
end;

begin
  SetWindowCaption('SNAKE');
  //MaximizeWindow;
  //SetWindowSize(1000,1000);
  SetWindowPos(100,0);
  SetFontSize(35);
  
  w := (WindowWidth div 20) - 5; h := WindowHeight div 20;
  x := 300; y := 300;
  speed := 2;
  
  Launch;
  
  //создание кнопок
  butPlay := new ButtonABC(w*20 + 2, 100, 97, 'Играть', clWhite);
  butPause := new ButtonABC(w*20 + 2, 100 + butPlay.Height, 97, 'Пауза', clWhite);
  //связывание событий и процедур
  OnKeyDown := KeyDown;
  butPlay.OnClick := StartGame;
  butPause.OnClick := Pause;
  
  stepTimer := new Timer(round(100/speed),Step);
  CheckOnLooseTimer := new Timer(round(100/speed/2), CheckOnLooseProcedure)
end.