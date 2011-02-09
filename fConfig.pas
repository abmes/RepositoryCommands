unit fConfig;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DB, StdCtrls, Buttons, ExtCtrls, GridsEh, DBGridEh, SembaDBGrid, DBCtrls,
  ActnList, ColorNavigator, JvBaseDlg, JvSelectDirectory, ImgList, Mask, JvExMask, JvToolEdit;

type
  TMoveDirection = (mdUp, mdDown);

type
  TfmConfig = class(TForm)
    dsSVNCommands: TDataSource;
    dsProjects: TDataSource;
    pnlOkCancelButtons: TPanel;
    btnCancel: TBitBtn;
    btnOk: TBitBtn;
    gbTortoiseSVNProcFileName: TGroupBox;
    fneTortoiseSVNProcFileName: TJvFilenameEdit;
    gbProjects: TGroupBox;
    grdProjects: TSembaDBGrid;
    gbSVNCommands: TGroupBox;
    grdSVNCommands: TSembaDBGrid;
    alMain: TActionList;
    actAddProject: TAction;
    navProjects: TDBColorNavigator;
    navSVNCommands: TDBColorNavigator;
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
    procedure MoveRecord(ADataSet: TDataSet; const ANoFieldName: string; AMoveDirection: TMoveDirection);
    function GetProjectName(const APath: string): string;
  public
    property TortoiseSVNProcFileName: string read GetTortoiseSVNProcFileName write SetTortoiseSVNProcFileName;
  end;

implementation

uses
  IOUtils, DBConsts, uUtils, Types;

const
  SVNSubDir = '.svn';

{$R *.dfm}

{ TfmConfig }

function TfmConfig.GetProjectName(const APath: string): string;
begin
  Result:= GetLastToken(ExcludeTrailingPathDelimiter(APath), PathDelim);
end;

procedure TfmConfig.actAddProjectExecute(Sender: TObject);
begin
  if sdProjectDir.Execute then
    begin
      if (Length(TDirectory.GetDirectories(sdProjectDir.Directory, SVNSubDir)) = 0) then
        raise Exception.Create('This is not an svn monitored directory!');

      dsProjects.DataSet.Append;
      try
        dsProjects.DataSet.FieldByName('PROJECT_DIR').AsString:= sdProjectDir.Directory;
        dsProjects.DataSet.FieldByName('PROJECT_NAME').AsString:= GetProjectName(sdProjectDir.Directory);
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

procedure TfmConfig.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (ModalResult = mrOk) then
    begin
      if (fneTortoiseSVNProcFileName.Text = '') then
        begin
          ActiveControl:= fneTortoiseSVNProcFileName;
          raise Exception.CreateFmt(SFieldRequired, ['TortoiseSVNProc']);
        end;

      dsProjects.DataSet.CheckBrowseMode;
      dsSVNCommands.DataSet.CheckBrowseMode;
    end;
end;

procedure TfmConfig.actMoveCommandDownExecute(Sender: TObject);
begin
  MoveRecord(dsSVNCommands.DataSet, 'COMMAND_NO', mdDown);
end;

procedure TfmConfig.actMoveCommandUpExecute(Sender: TObject);
begin
  MoveRecord(dsSVNCommands.DataSet, 'COMMAND_NO', mdUp);
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
