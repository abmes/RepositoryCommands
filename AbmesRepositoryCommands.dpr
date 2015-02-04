program AbmesRepositoryCommands;

uses
  MidasLib,
  Forms,
  Dialogs,
  fMain in 'fMain.pas' {fmMain},
  dwCustomDestinationList in 'JumpLists\dwCustomDestinationList.pas',
  dwJumpLists in 'JumpLists\dwJumpLists.pas',
  dwObjectArray in 'JumpLists\dwObjectArray.pas',
  dwShellItem in 'JumpLists\dwShellItem.pas',
  uUtils in 'uUtils.pas',
  fConfig in 'fConfig.pas' {fmConfig};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Abmes Repository Commands';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
