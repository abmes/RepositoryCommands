{$WARN UNIT_PLATFORM OFF}
unit fConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, StdCtrls, Buttons, ExtCtrls, DBCtrls,
  ActnList, ColorNavigator, ImgList, Mask,
  System.Actions, Vcl.Grids, Vcl.DBGrids, Vcl.ComCtrls, Vcl.ToolWin;

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
    gbProjects: TGroupBox;
    gbCommands: TGroupBox;
    alMain: TActionList;
    actAddProject: TAction;
    navProjects: TDBColorNavigator;
    navCommands: TDBColorNavigator;
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
    grdProjects: TDBGrid;
    grdCommands: TDBGrid;
    edtTortoiseProcFileName: TEdit;
    odTortoiseProcFileName: TOpenDialog;
    tlbSelectTortoiseProc: TToolBar;
    btnSelectTortoiseProc: TToolButton;
    actSelectTortoiseProc: TAction;
    procedure actAddProjectExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actMoveProjectUpExecute(Sender: TObject);
    procedure actMoveProjectDownExecute(Sender: TObject);
    procedure actMoveCommandUpExecute(Sender: TObject);
    procedure actMoveCommandDownExecute(Sender: TObject);
    procedure navProjectsBeforeAction(Sender: TObject; Button: TNavigateBtn);
    procedure grdProjectsDblClick(Sender: TObject);
    procedure grdCommandsDblClick(Sender: TObject);
    procedure grdCommandsCellClick(Column: TColumn);
    procedure actSelectTortoiseProcExecute(Sender: TObject);
  private
    function GetTortoiseProcFileName: string;
    procedure SetTortoiseProcFileName(const Value: string);
    procedure MoveRecord(ADataSet: TDataSet; const ANoFieldName: string; AMoveDirection: TMoveDirection);
    function GetProjectName(const APath: string): string;
    procedure CheckProjectType(const APath: string);
    procedure NegateBooleanField(ADataSet: TDataSet; const AFieldName: string);
  public
    property TortoiseProcFileName: string read GetTortoiseProcFileName write SetTortoiseProcFileName;
  end;

implementation

uses
  IOUtils, DBConsts, uUtils, Types, FileCtrl;

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
var
  ProjectDir: string;
begin
  if SelectDirectory('Project Dir', '', ProjectDir) then
    begin
      dsProjects.DataSet.Append;
      try
        CheckProjectType(ProjectDir);
        dsProjects.DataSet.FieldByName('PROJECT_DIR').AsString:= ProjectDir;
        dsProjects.DataSet.FieldByName('PROJECT_NAME').AsString:= GetProjectName(ProjectDir);
        dsProjects.DataSet.Post;
      except
        dsProjects.DataSet.Cancel;
        raise;
      end;
    end;
end;

function TfmConfig.GetTortoiseProcFileName: string;
begin
  Result:= edtTortoiseProcFileName.Text;
end;

procedure TfmConfig.SetTortoiseProcFileName(const Value: string);
begin
  edtTortoiseProcFileName.Text:= Value;
end;

procedure TfmConfig.NegateBooleanField(ADataSet: TDataSet; const AFieldName: string);
var
  BooleanField: TField;
begin
  ADataSet.CheckBrowseMode;

  ADataSet.DisableControls;
  try
    ADataSet.Edit;
    try
      BooleanField:= ADataSet.FieldByName(AFieldName);
      BooleanField.AsBoolean:= not BooleanField.AsBoolean;
      ADataSet.Post;
    except
      ADataSet.Cancel;
      raise;
    end;
  finally
    ADataSet.EnableControls;
  end;
end;

procedure TfmConfig.grdProjectsDblClick(Sender: TObject);
begin
  NegateBooleanField(dsProjects.DataSet, 'IS_FAVORITE');
end;

procedure TfmConfig.grdCommandsDblClick(Sender: TObject);
begin
  NegateBooleanField(dsCommands.DataSet, 'IS_FAVORITE');
end;

procedure TfmConfig.grdCommandsCellClick(Column: TColumn);
begin
  if (Column.FieldName = 'IS_FAVORITE') then
    grdCommands.Options:= grdCommands.Options - [dgEditing]
  else
    grdCommands.Options:= grdCommands.Options + [dgEditing];
end;

procedure TfmConfig.FormClose(Sender: TObject; var Action: TCloseAction);

  procedure CheckRequiredFileName(AFileNameEdit: TEdit; const AFieldName: string);
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
      CheckRequiredFileName(edtTortoiseProcFileName, 'TortoiseProc');
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

procedure TfmConfig.actSelectTortoiseProcExecute(Sender: TObject);
var
  FileName: string;
begin
  if (edtTortoiseProcFileName.Text <> '') then
    begin
      FileName:= StringReplace(edtTortoiseProcFileName.Text, '"', '', [rfReplaceAll]);
      odTortoiseProcFileName.InitialDir:= ExtractFilePath(FileName);
      odTortoiseProcFileName.FileName:= ExtractFileName(FileName);
    end;

  if odTortoiseProcFileName.Execute() then
    edtTortoiseProcFileName.Text:= Format('"%s"', [odTortoiseProcFileName.FileName]);
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
