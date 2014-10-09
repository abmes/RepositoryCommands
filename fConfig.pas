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
    dsCommands: TDataSource;
    dsProjects: TDataSource;
    pnlOkCancelButtons: TPanel;
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    gbTortoiseProcFileName: TGroupBox;
    fneTortoiseProcFileName: TJvFilenameEdit;
    gbProjects: TGroupBox;
    grdProjects: TSembaDBGrid;
    gbCommands: TGroupBox;
    grdCommands: TSembaDBGrid;
    alMain: TActionList;
    actAddProject: TAction;
    navProjects: TDBColorNavigator;
    navCommands: TDBColorNavigator;
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
    function GetTortoiseProcFileName: string;
    procedure SetTortoiseProcFileName(const Value: string);
    procedure MoveRecord(ADataSet: TDataSet; const ANoFieldName: string; AMoveDirection: TMoveDirection);
    function GetProjectName(const APath: string): string;
    procedure CheckProjectType(const APath: string);
  public
    property TortoiseProcFileName: string read GetTortoiseProcFileName write SetTortoiseProcFileName;
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

procedure TfmConfig.CheckProjectType(const APath: string);
begin
  if (Length(TDirectory.GetDirectories(APath, RepositoryTypeSubDirName)) = 0) then
    raise Exception.Create('Unknown Repository type!');
end;

procedure TfmConfig.actAddProjectExecute(Sender: TObject);
begin
  if sdProjectDir.Execute then
    begin
      dsProjects.DataSet.Append;
      try
        CheckProjectType(sdProjectDir.Directory);
        dsProjects.DataSet.FieldByName('PROJECT_DIR').AsString:= sdProjectDir.Directory;
        dsProjects.DataSet.FieldByName('PROJECT_NAME').AsString:= GetProjectName(sdProjectDir.Directory);
        dsProjects.DataSet.Post;
      except
        dsProjects.DataSet.Cancel;
        raise;
      end;
    end;
end;

function TfmConfig.GetTortoiseProcFileName: string;
begin
  Result:= fneTortoiseProcFileName.Text;
end;

procedure TfmConfig.SetTortoiseProcFileName(const Value: string);
begin
  fneTortoiseProcFileName.Text:= Value;
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
      CheckRequiredFileName(fneTortoiseProcFileName, 'TortoiseProc');
      dsProjects.DataSet.CheckBrowseMode;
      dsCommands.DataSet.CheckBrowseMode;
    end;
end;

procedure TfmConfig.actMoveCommandDownExecute(Sender: TObject);
begin
  MoveRecord(dsCommands.DataSet, 'COMMAND_NO', mdDown);
end;

procedure TfmConfig.actMoveCommandUpExecute(Sender: TObject);
begin
  MoveRecord(dsCommands.DataSet, 'COMMAND_NO', mdUp);
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
