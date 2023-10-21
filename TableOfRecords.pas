//program ff;

unit TableOfRecords;
uses GraphABC, ABCObjects, ABCButtons;

type
  Player = class
    public
    Name : string;
    Score : integer;
  end;

var Records : text;
    fName, fScore : string;
    Players : array of Player;// := ArrFill(10, new Player);
    
var name : string;
var WarnMaxLong : TextABC;
var InputLine : RectangleABC;
var ButInput : ButtonABC;
var MouseClick : boolean;
var MousePos : Point;


procedure KeyPress(ch : char);
begin
  if length(name) < 20 then
  begin
    name += ch;
    InputLine.Text := name;
    WarnMaxLong.Visible := False;
  end
  else
    WarnMaxLong.Visible := True;
end;

procedure KeyDown(key : integer);
begin
  if key = VK_Back then 
  begin
    name := name[1 : length(name) - 1];
    InputLine.Text := name;
  end;
end;



function InputName() : string;
const x = 200; //положение контецнера ввода
const y = 200; //
const h = 30; //высота строки ввода
  
begin
  OnKeyPress := KeyPress;
  OnKeyDown := KeyDown;
  OnMouseMove := procedure(x, y, cl : integer) ->
  begin
    MousePos.X := x;
    MousePos.Y := y;
  end;
  OnMouseDown := procedure(x, y, cl : integer) -> if cl = 1 then MouseClick := True;
  OnMouseUp := procedure(x, y, cl : integer) -> if cl = 1 then MouseClick := False;
  
  InputLine := new RectangleABC(x, y, 300, h, rgb(220, 220, 220));
  ButInput := new ButtonABC(x + 310, y, 50, h, 'Input', clWhite);
  WarnMaxLong := new TextABC(x, y + h, 10, 'Max long of name', clBlack);
  WarnMaxLong.Visible := False;

  while True do
    if ButInput.PtInside(MousePos.X, MousePos.Y) and MouseClick then break;

  Result := InputLine.Text;
  
  OnKeyPress := nil;
  OnKeyDown := nil;
  OnMouseMove := nil; 
  OnMouseDown := nil; 
  OnMouseUp := nil;
  
  InputLine.Destroy;
  ButInput.Destroy;
  WarnMaxLong.Destroy;
end;
    
    
procedure WriteNewRecord(newScore : integer);
var minScore : integer;
begin
  Assign(Records, 'Table of records.txt');
  Reset(Records);
  Readln(Records);
  Read(Records, minScore);
  Close(Records);
  Reset(Records);
  if newScore > minScore then 
  begin
    Players := new Player[11];
    for var i := 0 to 10 do
      Players[i] := new Player;
    
    var NewName : string;
    NewName := InputName;
    Players[10].Name := NewName;
    Players[10].Score := newScore;
    
    for var i := 0 to 9 do
    begin 
      Readln(Records, fName);
      Readln(Records, fScore);
      Players[i].Name := fName;
      Players[i].Score := fScore.ToInteger;
    end;
    Close(Records);
    
    Sort(Players, i -> i.Score);
    
    Rewrite(Records);
    for var i := 1 to 10 do
    begin
      writeln(Records, Players[i].Name);
      writeln(Records, Players[i].Score);
    end;
    Close(Records);
  end;
end;


begin
  //WriteNewRecord(98);
end.