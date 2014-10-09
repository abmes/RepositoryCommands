program SembaRepositories;

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
  if (ParamCount > 0) then
    ExecCommandAndHalt(ParamStr(1), ParamStr(2));

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Semba Repositories';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
