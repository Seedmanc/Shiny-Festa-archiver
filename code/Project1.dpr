program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {About};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'Shiny Festa  patcher';
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TAbout, About);
  Application.Run;
end.
