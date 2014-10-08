unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, SembaFields, DBClient, SembaClientDataSet, DBGridEh, SembaDBGrid,
  Buttons, ActnList, AppEvnts, ExtCtrls, GridsEh, DBGridEhGrouping, System.Actions, DBAxisGridsEh;

type
  TfmMain = class(TForm)
    alMain: TActionList;
    actConfig: TAction;
    cdsProjects: TSembaClientDataSet;
    cdsSCMCommands: TSembaClientDataSet;
    dsProjectCommands: TDataSource;
    cdsSCMCommandsCOMMAND_NAME: TSembaWideStringField;
    cdsSCMCommandsCOMMAND_ARGUMENTS: TSembaWideStringField;
    cdsSCMCommandsIS_FAVORITE: TSembaFloatField;
    cdsProjectsPROJECT_NAME: TSembaWideStringField;
    cdsProjectsPROJECT_DIR: TSembaWideStringField;
    cdsProjectsIS_FAVORITE: TSembaFloatField;
    cdsProjectCommands: TSembaClientDataSet;
    cdsProjectsPROJECT_NO: TSembaFloatField;
    cdsSCMCommandsCOMMAND_NO: TSembaFloatField;
    pnlMain: TPanel;
    grdProjectCommands: TSembaDBGrid;
    actShowMore: TAction;
    aeAppEvents: TApplicationEvents;
    pnlConfig: TPanel;
    btnConfig: TSpeedButton;
    pnlShowMore: TPanel;
    btnShowMore: TSpeedButton;
    cdsProjects_MAX_NO: TAggregateField;
    cdsSCMCommands_MAX_NO: TAggregateField;
    cdsProjectsPROJECT_TYPE: TSembaWideStringField;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure grdProjectCommandsCellClick(Column: TColumnEh);
    procedure actShowMoreExecute(Sender: TObject);
    procedure aeAppEventsDeactivate(Sender: TObject);
    procedure actConfigExecute(Sender: TObject);
    procedure grdProjectCommandsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure cdsProjectsNewRecord(DataSet: TDataSet);
    procedure cdsSCMCommandsNewRecord(DataSet: TDataSet);
    procedure grdProjectCommandsDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumnEh;
      State: TGridDrawState);
  private
    FTortoiseSVNProcFileName: string;
    FTortoiseGitProcFileName: string;
    FIsNearMousePosition: Boolean;
    FSavedMousePos: TPoint;
    procedure CommitTasks;
    procedure LoadConfig;
    procedure SaveConfig;
    procedure RefreshProjectCommands;
    procedure RefreshGridColumns;
    procedure RefreshProjectCommandsDataSet;
    procedure SetFormHeight;
    procedure SetFormPosition;
    procedure SetFormWidth;
    function GetDefaultTortoiseProcFileName(const ATortoiseProcFileName: string): string;
    procedure RecalcFormDimensionsAndPosition;
    function GetTortoiseProcFileName(const AProjectType: string): string;
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

uses
  dwJumpLists, Registry, Math, fConfig, JclStrings, uUtils, StrUtils;

const
  RegKeySembaSCMProjects = 'Software\SEMBA\SembaSCMProjects';

  RegValueTortoiseSVNProcFileName = 'TortoiseSVNProcFileName';
  RegValueTortoiseGitProcFileName = 'TortoiseGitProcFileName';
  RegValueProjects = 'Projects';
  RegValueSCMCommands = 'SCMCommands';

  EnvVarProgramFiles = 'ProgramW6432';
  EnvVarProgramFilesX86 = 'ProgramFiles(x86)';
  DefaultTortoiseSVNProcFileName = '\TortoiseSVN\bin\TortoiseProc.exe';
  DefaultTortoiseGitProcFileName = '\TortoiseGit\bin\TortoiseGitProc.exe';
  CommandPrefix = 'CMD_';
  ProjectPathMacro = '%ProjectDir%';
  ProjectsGridRowHeight = 25;
  ProjectNameColumnWidth = 200;
  CommandColumnWidth = 80;
  NearMousePositionTolerancePixelCount = 30;

{$R *.dfm}

function TfmMain.GetDefaultTortoiseProcFileName(const ATortoiseProcFileName: string): string;

  function GetFullTortoiseProcFileName(const AEnvVarProgramFiles: string): string;
  begin
    Result:= ExcludeTrailingPathDelimiter(GetEnvironmentVariable(AEnvVarProgramFiles)) + ATortoiseProcFileName;
  end;

begin
  Result:= '';

  if FileExists(GetFullTortoiseProcFileName(EnvVarProgramFiles)) then
    Exit(StrDoubleQuote(GetFullTortoiseProcFileName(EnvVarProgramFiles)));

  if FileExists(GetFullTortoiseProcFileName(EnvVarProgramFilesX86)) then
    Exit(StrDoubleQuote(GetFullTortoiseProcFileName(EnvVarProgramFilesX86)));
end;

procedure TfmMain.LoadConfig;

  procedure LoadDataSet(ADataSet: TSembaClientDataSet; AReg: TRegistry; const AValueName: string);
  var
    s: TMemoryStream;
    DataSize: Integer;
  begin
    DataSize:= AReg.GetDataSize(AValueName);
    if (DataSize > 0) then
      begin
        s:= TMemoryStream.Create;
        try
          s.SetSize(DataSize);
          AReg.ReadBinaryData(AValueName, s.Memory^, DataSize);
          s.Seek(0, soFromBeginning);
          ADataSet.LoadFromStream(s);
        finally
          FreeAndNil(s);
        end;
      end;
  end;

var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey(RegKeySembaSCMProjects, False) then
      try
        FTortoiseSVNProcFileName:= Reg.ReadString(RegValueTortoiseSVNProcFileName);
        FTortoiseGitProcFileName:= Reg.ReadString(RegValueTortoiseGitProcFileName);
        LoadDataSet(cdsProjects, Reg, RegValueProjects);
        LoadDataSet(cdsSCMCommands, Reg, RegValueSCMCommands);
      finally
        Reg.CloseKey;
      end;
  finally
    FreeAndNil(Reg);
  end;

  if (FTortoiseSVNProcFileName = '') then
    FTortoiseSVNProcFileName:= GetDefaultTortoiseProcFileName(DefaultTortoiseSVNProcFileName);

  if (FTortoiseGitProcFileName = '') then
    FTortoiseGitProcFileName:= GetDefaultTortoiseProcFileName(DefaultTortoiseGitProcFileName);

  if cdsSCMCommands.IsEmpty then
    begin
      cdsSCMCommands.AppendRecord([1, 'Changes', '/command:repostatus /path:%ProjectDir%', 1]);
      cdsSCMCommands.AppendRecord([2, 'Update', '/command:update /path:%ProjectDir%', 1]);
      cdsSCMCommands.AppendRecord([3, 'Log', '/command:log /path:%ProjectDir%', 0]);
    end;
end;

procedure TfmMain.SaveConfig;

  procedure SaveDataSet(ADataSet: TSembaClientDataSet; AReg: TRegistry; const ARegValueName: string);
  var
    s: TMemoryStream;
  begin
    s:= TMemoryStream.Create;
    try
      ADataSet.SaveToStream(s);
      AReg.WriteBinaryData(ARegValueName, s.Memory^, s.Size);
    finally
      FreeAndNil(s);
    end;
  end;

var
  Reg: TRegistry;
begin
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    Reg.OpenKey(RegKeySembaSCMProjects, True);
    try
      Reg.WriteString(RegValueTortoiseSVNProcFileName, FTortoiseSVNProcFileName);
      Reg.WriteString(RegValueTortoiseGitProcFileName, FTortoiseGitProcFileName);
      SaveDataSet(cdsSCMCommands, Reg, RegValueSCMCommands);
      SaveDataSet(cdsProjects, Reg, RegValueProjects);
    finally
      Reg.CloseKey;
    end;
  finally
    FreeAndNil(Reg);
  end;
end;

procedure TfmMain.RefreshProjectCommandsDataSet;

  procedure AddFieldDef(const AName: string; ADataType: TFieldType; ASize: Integer = 0);
  var
    fd: TFieldDef;
  begin
    fd:= cdsProjectCommands.FieldDefs.AddFieldDef;
    fd.Name:= AName;
    fd.DataType:= ADataType;
    fd.Size:= ASize;
  end;

begin
  cdsProjectCommands.Close;
  cdsProjectCommands.FieldDefs.Clear;

  AddFieldDef('PROJECT_NAME', ftWideString, 50);
  AddFieldDef('PROJECT_DIR', ftWideString, 250);
  AddFieldDef('PROJECT_TYPE', ftWideString, 50);
  AddFieldDef('IS_FAVORITE', ftFloat);

  cdsSCMCommands.First;
  while not cdsSCMCommands.Eof do
    begin
      AddFieldDef(CommandPrefix + cdsSCMCommandsCOMMAND_NO.AsString, ftWideString, 250);
      cdsSCMCommands.Next;
    end;

  cdsProjectCommands.CreateDataSet;

  cdsProjects.First;
  while not cdsProjects.eof do
    begin
      cdsProjectCommands.Append;
      try
        cdsProjectCommands.FieldByName('PROJECT_NAME').Assign(cdsProjectsPROJECT_NAME);
        cdsProjectCommands.FieldByName('PROJECT_DIR').Assign(cdsProjectsPROJECT_DIR);
        cdsProjectCommands.FieldByName('PROJECT_TYPE').Assign(cdsProjectsPROJECT_TYPE);
        cdsProjectCommands.FieldByName('IS_FAVORITE').Assign(cdsProjectsIS_FAVORITE);

        cdsSCMCommands.First;
        while not cdsSCMCommands.Eof do
          begin
            cdsProjectCommands.FieldByName(CommandPrefix + cdsSCMCommandsCOMMAND_NO.AsString).Assign(cdsSCMCommandsCOMMAND_NAME);
            cdsSCMCommands.Next;
          end;

        cdsProjectCommands.Post;
      except
        cdsProjectCommands.Cancel;
        raise;
      end;

      cdsProjects.Next;
    end;

  cdsProjectCommands.First;
end;

procedure TfmMain.RefreshGridColumns;

  procedure AddColumn(const AFieldName: string; AWidth: Integer; AIsCommandColumn: Boolean);
  var
    col: TColumnEh;
  begin
    col:= grdProjectCommands.Columns.Add;
    col.FieldName:= AFieldName;
    col.Width:= AWidth;
    col.Font.Size:= 11;
    if AIsCommandColumn then
      begin
        col.Alignment:= taCenter;
        col.Font.Color:= clBlue;
        col.Font.Style:= [fsUnderline];
      end;
  end;

begin
  grdProjectCommands.Columns.Clear;

  AddColumn('PROJECT_NAME', ProjectNameColumnWidth, False);

  cdsSCMCommands.First;
  while not cdsSCMCommands.Eof do
    begin
      AddColumn(CommandPrefix + cdsSCMCommandsCOMMAND_NO.AsString, CommandColumnWidth, True);
      cdsSCMCommands.Next;
    end;
end;

procedure TfmMain.RefreshProjectCommands;
begin
  RefreshProjectCommandsDataSet;

  RefreshGridColumns;

  cdsProjects.First;
  cdsSCMCommands.First;

  RecalcFormDimensionsAndPosition;
end;

procedure TfmMain.SetFormHeight;
begin
  ClientHeight:=
    4 + // bevel
    IfThen(pnlShowMore.Visible, pnlShowMore.Height) +
    IfThen(pnlConfig.Visible, pnlConfig.Height) +
    cdsProjectCommands.RecordCount * ProjectsGridRowHeight;
end;

procedure TfmMain.SetFormWidth;
begin
  ClientWidth:=
    4 + // bevel
    ProjectNameColumnWidth +
    cdsSCMCommands.RecordCount * CommandColumnWidth;
end;

procedure TfmMain.SetFormPosition;

  function CalcLeft: Integer;
  begin
    Result:= FSavedMousePos.X - ProjectNameColumnWidth - ((cdsSCMCommands.RecordCount * CommandColumnWidth) div 2);
    Result:= Max(Result, 0);
    Result:= Min(Result, Screen.Width - Width);
  end;

begin
  if FIsNearMousePosition then
    begin
      Position:= poDesigned;
      Left:= CalcLeft;
      Top:= Screen.Height - GetTaskBarHeight - Height;
    end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  cdsProjects.CreateDataSet;
  cdsSCMCommands.CreateDataSet;

  LoadConfig;

  if cdsProjects.IsEmpty then
    actConfig.Execute;

  grdProjectCommands.RowHeight:= ProjectsGridRowHeight;

  FSavedMousePos:= Mouse.CursorPos;
  FIsNearMousePosition:=
    IsTaskBarAtBottom and
    InRange(FSavedMousePos.Y, Screen.Height - GetTaskBarHeight - NearMousePositionTolerancePixelCount, Screen.Height);

  RefreshProjectCommands;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  CommitTasks;
  SaveConfig;
end;

procedure TfmMain.CommitTasks;
var
  JumpLists: TdwJumpLists;
  Category: TdwLinkCategoryItem;
  Task: TdwLinkObjectItem;
begin
  JumpLists:= TdwJumpLists.Create(Self);
  try
    cdsProjects.First;
    while not cdsProjects.Eof do
      begin
        if cdsProjectsIS_FAVORITE.AsBoolean then
          begin
            Category:= JumpLists.Categories.Add;
            Category.Title:= cdsProjectsPROJECT_NAME.AsString;

            cdsSCMCommands.First;
            while not cdsSCMCommands.eof do
              begin
                if cdsSCMCommandsIS_FAVORITE.AsBoolean then
                  begin
                    Task:= Category.Items.Add;
                    Task.ObjectType:= lotShellLink;
                    Task.ShellLink.DisplayName:= cdsSCMCommandsCOMMAND_NAME.AsString;
                    Task.ShellLink.Arguments:=
                      Format('%s "%s"', [
                        GetTortoiseProcFileName(cdsProjectsPROJECT_TYPE.AsString),
                        StringReplace(cdsSCMCommandsCOMMAND_ARGUMENTS.AsString, ProjectPathMacro, cdsProjectsPROJECT_DIR.AsString, [rfReplaceAll])]);
                  end;

                cdsSCMCommands.Next
              end;
          end;

        cdsProjects.Next;
      end;

    JumpLists.Commit;
  finally
    FreeAndNil(JumpLists);
  end;
end;

procedure TfmMain.grdProjectCommandsCellClick(Column: TColumnEh);
var
  Arguments: string;
begin
  if (Column.FieldName = 'PROJECT_NAME') then
    OpenDirectoryAndHalt(cdsProjectCommands.FieldByName('PROJECT_DIR').AsString);

  Assert(StartsStr('CMD_', Column.FieldName));

  if not cdsSCMCommands.Locate('COMMAND_NO', StrToInt(GetLastToken(Column.FieldName, '_')), []) then
    raise Exception.Create('Internal error: Command not found');

  Arguments:=
    StringReplace(
      cdsSCMCommandsCOMMAND_ARGUMENTS.AsString,
      ProjectPathMacro,
      cdsProjectCommands.FieldByName('PROJECT_DIR').AsString,
      [rfReplaceAll]);

  ExecCommandAndHalt(GetTortoiseProcFileName(cdsProjectCommands.FieldByName('PROJECT_TYPE').AsString), Arguments);
end;

procedure TfmMain.grdProjectCommandsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if (X > ProjectNameColumnWidth) then
    grdProjectCommands.Cursor:= crHandPoint
  else
    grdProjectCommands.Cursor:= crDefault;
end;

procedure TfmMain.aeAppEventsDeactivate(Sender: TObject);
begin
  if (Screen.ActiveForm = Self) then
    Close;
end;

procedure TfmMain.actShowMoreExecute(Sender: TObject);
begin
  cdsProjectCommands.Filtered:= False;
  pnlShowMore.Visible:= False;
  pnlConfig.Visible:= True;
  RecalcFormDimensionsAndPosition;
end;

procedure TfmMain.actConfigExecute(Sender: TObject);
var
  fmConfig: TfmConfig;
  ProjectsSavePoint: Integer;
  SCMCommandsSavePoint: Integer;
begin
  fmConfig:= TfmConfig.Create(Self);
  try
    ProjectsSavePoint:= cdsProjects.SavePoint;
    try
      SCMCommandsSavePoint:= cdsSCMCommands.SavePoint;
      try
        fmConfig.dsProjects.DataSet:= cdsProjects;
        fmConfig.dsSCMCommands.DataSet:= cdsSCMCommands;
        fmConfig.TortoiseSVNProcFileName:= FTortoiseSVNProcFileName;
        fmConfig.TortoiseGitProcFileName:= FTortoiseGitProcFileName;

        if (fmConfig.ShowModal <> mrOk) then
          Abort;

        FTortoiseSVNProcFileName:= fmConfig.TortoiseSVNProcFileName;
        FTortoiseGitProcFileName:= fmConfig.TortoiseGitProcFileName;
      except
        cdsSCMCommands.SavePoint:= SCMCommandsSavePoint;
        raise;
      end;
    except
      cdsProjects.SavePoint:= ProjectsSavePoint;
      raise;
    end;
  finally
    FreeAndNil(fmConfig);
  end;

  RefreshProjectCommands;
end;

procedure TfmMain.cdsProjectsNewRecord(DataSet: TDataSet);
begin
  cdsProjectsPROJECT_NO.AsInteger:= VarToInt(cdsProjects_MAX_NO.AsVariant) + 1;
  cdsProjectsIS_FAVORITE.AsBoolean:= True;
end;

procedure TfmMain.cdsSCMCommandsNewRecord(DataSet: TDataSet);
begin
  cdsSCMCommandsCOMMAND_NO.AsInteger:= VarToInt(cdsSCMCommands_MAX_NO.AsVariant) + 1;
  cdsSCMCommandsIS_FAVORITE.AsBoolean:= True;
end;

procedure TfmMain.grdProjectCommandsDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer;
  Column: TColumnEh; State: TGridDrawState);
begin
  grdProjectCommands.DefaultDrawColumnCell(Rect, DataCol, Column, []);
end;

procedure TfmMain.RecalcFormDimensionsAndPosition;
begin
  SetFormHeight;
  SetFormWidth;
  SetFormPosition;
end;

function TfmMain.GetTortoiseProcFileName(const AProjectType: string): string;
begin
  if (AProjectType = SVNSubDir) then
    Exit(FTortoiseSVNProcFileName);

  if (AProjectType = GitSubDir) then
    Exit(FTortoiseGitProcFileName);

  raise Exception.CreateFmt('Unknown Project type "%s"', [AProjectType]);
end;

end.
