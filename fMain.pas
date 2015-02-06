unit fMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, DB, DBClient, Buttons, ActnList, AppEvnts, ExtCtrls, System.Actions, Vcl.Grids,
  Vcl.DBGrids;

type
  TfmMain = class(TForm)
    alMain: TActionList;
    actConfig: TAction;
    dsProjectCommands: TDataSource;
    pnlMain: TPanel;
    actShowMore: TAction;
    aeAppEvents: TApplicationEvents;
    pnlConfig: TPanel;
    btnConfig: TSpeedButton;
    pnlShowMore: TPanel;
    btnShowMore: TSpeedButton;
    cdsProjects: TClientDataSet;
    cdsProjectsPROJECT_NO: TFloatField;
    cdsProjectsPROJECT_NAME: TWideStringField;
    cdsProjectsPROJECT_DIR: TWideStringField;
    cdsProjectsIS_FAVORITE: TBooleanField;
    cdsProjects_MAX_NO: TAggregateField;
    cdsCommands: TClientDataSet;
    cdsCommandsCOMMAND_NO: TFloatField;
    cdsCommandsCOMMAND_NAME: TWideStringField;
    cdsCommandsCOMMAND_ARGUMENTS: TWideStringField;
    cdsCommandsIS_FAVORITE: TBooleanField;
    cdsCommands_MAX_NO: TAggregateField;
    cdsProjectCommands: TClientDataSet;
    grdProjectCommands: TDBGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actShowMoreExecute(Sender: TObject);
    procedure aeAppEventsDeactivate(Sender: TObject);
    procedure actConfigExecute(Sender: TObject);
    procedure cdsProjectsNewRecord(DataSet: TDataSet);
    procedure cdsCommandsNewRecord(DataSet: TDataSet);
    procedure grdProjectCommandsMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure grdProjectCommandsCellClick(Column: TColumn);
    procedure grdProjectCommandsDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer; Column: TColumn;
      State: TGridDrawState);
  private
    FTortoiseProcFileName: string;
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
    function ConfigurationRegKey: string;
    procedure HideGridScrollBar;
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

uses
  dwJumpLists, Registry, Math, fConfig, JclStrings, uUtils, StrUtils;

const
  RegValueTortoiseProcFileName = 'TortoiseProcFileName';
  RegValueProjects = 'Projects';
  RegValueCommands = 'Commands';

  EnvVarProgramFiles = 'ProgramW6432';
  EnvVarProgramFilesX86 = 'ProgramFiles(x86)';
  CommandPrefix = 'CMD_';
  ProjectPathMacro = '%ProjectDir%';
  ProjectsGridRowHeight = 23;
  ProjectNameColumnWidth = 200;
  CommandColumnWidth = 80;
  NearMousePositionTolerancePixelCount = 30;
  OddRowColor = clCream;
  EvenRowColor = 15137255;

{$R *.dfm}

function TfmMain.ConfigurationRegKey: string;
const
  RegKeyAbmesRepositoryCommands = 'Software\Abmes\RepositoryCommands';
begin
  Result:= RegKeyAbmesRepositoryCommands + '\' + RepositoryTypeName;
end;

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

  procedure LoadDataSet(ADataSet: TClientDataSet; AReg: TRegistry; const AValueName: string);
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
    if Reg.OpenKey(ConfigurationRegKey, False) then
      try
        FTortoiseProcFileName:= Reg.ReadString(RegValueTortoiseProcFileName);
        LoadDataSet(cdsProjects, Reg, RegValueProjects);
        LoadDataSet(cdsCommands, Reg, RegValueCommands);
      finally
        Reg.CloseKey;
      end;
  finally
    FreeAndNil(Reg);
  end;

  if (FTortoiseProcFileName = '') then
    FTortoiseProcFileName:= GetDefaultTortoiseProcFileName(DefaultTortoiseProcFileName);

  if cdsCommands.IsEmpty then
    begin
      if (RepositoryTypeName = RepositoryTypeNameSVN) then
        begin
          cdsCommands.AppendRecord([1, 'Changes', '/command:repostatus /path:%ProjectDir%', True]);
          cdsCommands.AppendRecord([2, 'Update', '/command:update /path:%ProjectDir%', True]);
          cdsCommands.AppendRecord([3, 'Log', '/command:log /path:%ProjectDir%', True]);
        end;

      if (RepositoryTypeName = RepositoryTypeNameGit) then
        begin
          cdsCommands.AppendRecord([1, 'Push', '/command:push /path:%ProjectDir%', True]);
          cdsCommands.AppendRecord([2, 'Pull', '/command:pull /path:%ProjectDir%', True]);
          cdsCommands.AppendRecord([3, 'Changes', '/command:repostatus /path:%ProjectDir%', True]);
          cdsCommands.AppendRecord([4, 'Log', '/command:log /path:%ProjectDir%', True]);
        end;
    end;
end;

procedure TfmMain.SaveConfig;

  procedure SaveDataSet(ADataSet: TClientDataSet; AReg: TRegistry; const ARegValueName: string);
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
    Reg.OpenKey(ConfigurationRegKey, True);
    try
      Reg.WriteString(RegValueTortoiseProcFileName, FTortoiseProcFileName);
      SaveDataSet(cdsCommands, Reg, RegValueCommands);
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
  AddFieldDef('IS_FAVORITE', ftBoolean);

  cdsCommands.First;
  while not cdsCommands.Eof do
    begin
      AddFieldDef(CommandPrefix + cdsCommandsCOMMAND_NO.AsString, ftWideString, 250);
      cdsCommands.Next;
    end;

  cdsProjectCommands.CreateDataSet;

  cdsProjects.First;
  while not cdsProjects.eof do
    begin
      cdsProjectCommands.Append;
      try
        cdsProjectCommands.FieldByName('PROJECT_NAME').Assign(cdsProjectsPROJECT_NAME);
        cdsProjectCommands.FieldByName('PROJECT_DIR').Assign(cdsProjectsPROJECT_DIR);
        cdsProjectCommands.FieldByName('IS_FAVORITE').Assign(cdsProjectsIS_FAVORITE);

        cdsCommands.First;
        while not cdsCommands.Eof do
          begin
            cdsProjectCommands.FieldByName(CommandPrefix + cdsCommandsCOMMAND_NO.AsString).Assign(cdsCommandsCOMMAND_NAME);
            cdsCommands.Next;
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
    col: TColumn;
  begin
    col:= grdProjectCommands.Columns.Add;
    col.FieldName:= AFieldName;
    col.Width:= AWidth;
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

  cdsCommands.First;
  while not cdsCommands.Eof do
    begin
      AddColumn(CommandPrefix + cdsCommandsCOMMAND_NO.AsString, CommandColumnWidth, True);
      cdsCommands.Next;
    end;
end;

procedure TfmMain.HideGridScrollBar;
begin
  ShowScrollBar(grdProjectCommands.Handle, SB_VERT, False);
end;

procedure TfmMain.RefreshProjectCommands;
begin
  RefreshProjectCommandsDataSet;

  RefreshGridColumns;

  cdsProjects.First;
  cdsCommands.First;

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
    cdsCommands.RecordCount * CommandColumnWidth;
end;

procedure TfmMain.SetFormPosition;

  function CalcLeft: Integer;
  begin
    Result:= FSavedMousePos.X - ProjectNameColumnWidth - ((cdsCommands.RecordCount * CommandColumnWidth) div 2);
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
  cdsCommands.CreateDataSet;

  LoadConfig;

  if cdsProjects.IsEmpty then
    actConfig.Execute;

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

            cdsCommands.First;
            while not cdsCommands.eof do
              begin
                if cdsCommandsIS_FAVORITE.AsBoolean then
                  begin
                    Task:= Category.Items.Add;
                    Task.ObjectType:= lotShellLink;
                    Task.ShellLink.DisplayName:= cdsCommandsCOMMAND_NAME.AsString;
                    Task.ShellLink.Arguments:=
                      Format('%s "%s"', [
                        FTortoiseProcFileName,
                        StringReplace(cdsCommandsCOMMAND_ARGUMENTS.AsString, ProjectPathMacro, cdsProjectsPROJECT_DIR.AsString, [rfReplaceAll])]);
                  end;

                cdsCommands.Next
              end;
          end;

        cdsProjects.Next;
      end;

    JumpLists.Commit;
  finally
    FreeAndNil(JumpLists);
  end;
end;

procedure TfmMain.grdProjectCommandsCellClick(Column: TColumn);
var
  Arguments: string;
begin
  if (Column.FieldName = 'PROJECT_NAME') then
    OpenDirectoryAndHalt(cdsProjectCommands.FieldByName('PROJECT_DIR').AsString);

  Assert(StartsStr('CMD_', Column.FieldName));

  if not cdsCommands.Locate('COMMAND_NO', StrToInt(GetLastToken(Column.FieldName, '_')), []) then
    raise Exception.Create('Internal error: Command not found');

  Arguments:=
    StringReplace(
      cdsCommandsCOMMAND_ARGUMENTS.AsString,
      ProjectPathMacro,
      cdsProjectCommands.FieldByName('PROJECT_DIR').AsString,
      [rfReplaceAll]);

  ExecCommandAndHalt(FTortoiseProcFileName, Arguments);
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
  CommandsSavePoint: Integer;
begin
  fmConfig:= TfmConfig.Create(Self);
  try
    ProjectsSavePoint:= cdsProjects.SavePoint;
    try
      CommandsSavePoint:= cdsCommands.SavePoint;
      try
        fmConfig.dsProjects.DataSet:= cdsProjects;
        fmConfig.dsCommands.DataSet:= cdsCommands;
        fmConfig.TortoiseProcFileName:= FTortoiseProcFileName;

        if (fmConfig.ShowModal <> mrOk) then
          Abort;

        FTortoiseProcFileName:= fmConfig.TortoiseProcFileName;
      except
        cdsCommands.SavePoint:= CommandsSavePoint;
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

procedure TfmMain.cdsCommandsNewRecord(DataSet: TDataSet);
begin
  cdsCommandsCOMMAND_NO.AsInteger:= VarToInt(cdsCommands_MAX_NO.AsVariant) + 1;
  cdsCommandsIS_FAVORITE.AsBoolean:= True;
end;

procedure TfmMain.cdsProjectsNewRecord(DataSet: TDataSet);
begin
  cdsProjectsPROJECT_NO.AsInteger:= VarToInt(cdsProjects_MAX_NO.AsVariant) + 1;
  cdsProjectsIS_FAVORITE.AsBoolean:= True;
end;

procedure TfmMain.grdProjectCommandsDrawColumnCell(Sender: TObject; const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
var
  RecNo: Integer;
begin
  RecNo:= grdProjectCommands.DataSource.DataSet.RecNo;
  grdProjectCommands.Canvas.Brush.Color:= IfThen(Odd(RecNo), OddRowColor, EvenRowColor);
  grdProjectCommands.DefaultDrawColumnCell(Rect, DataCol, Column, []);
end;

procedure TfmMain.RecalcFormDimensionsAndPosition;
begin
  SetFormHeight;
  SetFormWidth;
  SetFormPosition;
  HideGridScrollBar;
end;

end.
