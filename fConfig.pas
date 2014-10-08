unit fConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, StdCtrls, Buttons, ExtCtrls, GridsEh, DBGridEh, SembaDBGrid, DBCtrls,
  ActnList, ColorNavigator, JvBaseDlg, JvSelectDirectory, ImgList, Mask, JvExMask, JvToolEdit, DBGridEhGrouping,
  System.Actions, DBAxisGridsEh;

type
  TMoveDirection = (mdUp, mdDown);

type
  TfmConfig = class(TForm)
    dsSCMCommands: TDataSource;
    dsProjects: TDataSource;
    pnlOkCancelButtons: TPanel;
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    gbTortoiseSVNProcFileName: TGroupBox;
    fneTortoiseSVNProcFileName: TJvFilenameEdit;
    gbTortoiseGitProcFileName: TGroupBox;
    fneTortoiseGitProcFileName: TJvFilenameEdit;
    gbProjects: TGroupBox;
    grdProjects: TSembaDBGrid;
    gbSCMCommands: TGroupBox;
    grdSCMCommands: TSembaDBGrid;
    alMain: TActionList;
    actAddProject: TAction;
    navProjects: TDBColorNavigator;
    navSCMCommands: TDBColorNavigator;
    sdProjectDir: TJvSelectDirectory;
    actMoveProjectUp: TAction;
    actMoveProjectDown: TAction;
    actMoveCommandUp: TAction;
    actMoveCommandDown: TAction;
    btnMoveProjectUp: TSpeedButton;
    btnMoveProjectDown: TSpeedButton;
    ilActions: TImageList;
    btnMoveCommandDown: TSpeedButton;
    btnMoveCommandUp: TSpeedButton;
    lblMacroHint: TLabel;
    procedure actAddProjectExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actMoveProjectUpExecute(Sender: TObject);
    procedure actMoveProjectDownExecute(Sender: TObject);
    procedure actMoveCommandUpExecute(Sender: TObject);
    procedure actMoveCommandDownExecute(Sender: TObject);
    procedure navProjectsBeforeAction(Sender: TObject; Button: TNavigateBtn);
  private
    function GetTortoiseSVNProcFileName: string;
    procedure SetTortoiseSVNProcFileName(const Value: string);
    function GetTortoiseGitProcFileName: string;
    procedure SetTortoiseGitProcFileName(const Value: string);
    procedure MoveRecord(ADataSet: TDataSet; const ANoFieldName: string; AMoveDirection: TMoveDirection);
    function GetProjectName(const APath: string): string;
    function GetProjectType(const APath: string): string;
  public
    property TortoiseSVNProcFileName: string read GetTortoiseSVNProcFileName write SetTortoiseSVNProcFileName;
    property TortoiseGitProcFileName: string read GetTortoiseGitProcFileName write SetTortoiseGitProcFileName;
  end;

implementation

uses
  IOUtils, DBConsts, uUtils, Types;

{$R *.dfm}

{ TfmConfig }

function TfmConfig.GetProjectName(const APath: string): string;
begin
  Result:= GetLastToken(ExcludeTrailingPathDelimiter(APath), PathDelim);
end;

function TfmConfig.GetProjectType(const APath: string): string;
begin
  if (Length(TDirectory.GetDirectories(sdProjectDir.Directory, SVNSubDir)) = 1) then
    Exit(SVNSubDir);

  if (Length(TDirectory.GetDirectories(sdProjectDir.Directory, GitSubDir)) = 1) then
    Exit(GitSubDir);

  raise Exception.Create('Unknown SCM type!');
end;

procedure TfmConfig.actAddProjectExecute(Sender: TObject);
begin
  if sdProjectDir.Execute then
    begin
      dsProjects.DataSet.Append;
      try
        dsProjects.DataSet.FieldByName('PROJECT_DIR').AsString:= sdProjectDir.Directory;
        dsProjects.DataSet.FieldByName('PROJECT_NAME').AsString:= GetProjectName(sdProjectDir.Directory);
        dsProjects.DataSet.FieldByName('PROJECT_TYPE').AsString:= GetProjectType(sdProjectDir.Directory);
        dsProjects.DataSet.Post;
      except
        dsProjects.DataSet.Cancel;
        raise;
      end;
    end;
end;

function TfmConfig.GetTortoiseSVNProcFileName: string;
begin
  Result:= fneTortoiseSVNProcFileName.Text;
end;

procedure TfmConfig.SetTortoiseSVNProcFileName(const Value: string);
begin
  fneTortoiseSVNProcFileName.Text:= Value;
end;

function TfmConfig.GetTortoiseGitProcFileName: string;
begin
  Result:= fneTortoiseGitProcFileName.Text;
end;

procedure TfmConfig.SetTortoiseGitProcFileName(const Value: string);
begin
  fneTortoiseGitProcFileName.Text:= Value;
end;

procedure TfmConfig.FormClose(Sender: TObject; var Action: TCloseAction);

  procedure CheckRequiredFileName(AFileNameEdit: TJvFileNameEdit; const AFieldName: string);
  begin
    if (AFileNameEdit.Text = '') then
      begin
        ActiveControl:= AFileNameEdit;
        raise Exception.CreateFmt(SFieldRequired, [AFieldName]);
      end;
  end;

begin
  if (ModalResult = mrOk) then
    begin
      CheckRequiredFileName(fneTortoiseSVNProcFileName, 'TortoiseSVNProc');
      CheckRequiredFileName(fneTortoiseGitProcFileName, 'TortoiseGitProc');

      dsProjects.DataSet.CheckBrowseMode;
      dsSCMCommands.DataSet.CheckBrowseMode;
    end;
end;

procedure TfmConfig.actMoveCommandDownExecute(Sender: TObject);
begin
  MoveRecord(dsSCMCommands.DataSet, 'COMMAND_NO', mdDown);
end;

procedure TfmConfig.actMoveCommandUpExecute(Sender: TObject);
begin
  MoveRecord(dsSCMCommands.DataSet, 'COMMAND_NO', mdUp);
end;

procedure TfmConfig.actMoveProjectDownExecute(Sender: TObject);
begin
  MoveRecord(dsProjects.DataSet, 'PROJECT_NO', mdDown);
end;

procedure TfmConfig.actMoveProjectUpExecute(Sender: TObject);
begin
  MoveRecord(dsProjects.DataSet, 'PROJECT_NO', mdUp);
end;

procedure TfmConfig.MoveRecord(ADataSet: TDataSet; const ANoFieldName: string; AMoveDirection: TMoveDirection);

  procedure MoveToOtherRecord;
  begin
    if (AMoveDirection = mdUp) then
      begin
        ADataSet.Prior;
        if ADataSet.Bof then
          Abort;
      end
    else
      begin
        ADataSet.Next;
        if ADataSet.Eof then
          Abort;
      end;
  end;

  procedure AssignNoField(AOldValue, ANewValue: Integer);
  begin
    if not ADataSet.Locate(ANoFieldName, AOldValue, []) then
      raise Exception.CreateFmt('Internal error: Record with no "%d" not found!', [AOldValue]);

    ADataSet.Edit;
    try
      ADataSet.FieldByName(ANoFieldName).AsInteger:= ANewValue;
      ADataSet.Post;
    except
      ADataSet.Cancel;
      raise;
    end;
  end;

var
  CurrentNo: Integer;
  OtherNo: Integer;
begin
  ADataSet.CheckBrowseMode;

  ADataSet.DisableControls;
  try
    CurrentNo:= ADataSet.FieldByName(ANoFieldName).AsInteger;
    MoveToOtherRecord;
    OtherNo:= ADataSet.FieldByName(ANoFieldName).AsInteger;

    AssignNoField(CurrentNo, -1);
    AssignNoField(OtherNo, CurrentNo);
    AssignNoField(-1, OtherNo);
  finally
    ADataSet.EnableControls;
  end;
end;

procedure TfmConfig.navProjectsBeforeAction(Sender: TObject; Button: TNavigateBtn);
begin
  if (Button = nbInsert) then
    begin
      actAddProject.Execute;
      Abort;
    end;
end;

end.
