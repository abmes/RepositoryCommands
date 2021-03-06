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
    procedure aeAppEventsMessage(var Msg: tagMSG; var Handled: Boolean);
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
    procedure SetFormPosition(const APreserveLeft: Boolean = False);
    function GetVisibleCommandCount: Integer;
    procedure SetFormWidth;
    function GetDefaultTortoiseProcFileName(const ATortoiseProcFileName: string): string;
    procedure RecalcFormDimensionsAndPosition(const APreserveLeft: Boolean = False);
    function ConfigurationRegKey: string;
    procedure HideGridScrollBar;
    function GetOrganizationName(ASourceDataSet: TDataSet): string;
    function ResolveMacros(const AValue: string; ASourceDataSet: TDataSet): string;
  public
    { Public declarations }
  end;

var
  fmMain: TfmMain;

implementation

uses
  dwJumpLists, Registry, Math, fConfig, JclStrings, uUtils, StrUtils, System.Types, System.IOUtils;

const
  RegValueTortoiseProcFileName = 'TortoiseProcFileName';
  RegValueProjects = 'Projects';
  RegValueCommands = 'Commands';

  EnvVarProgramFiles = 'ProgramW6432';
  EnvVarProgramFilesX86 = 'ProgramFiles(x86)';
  CommandPrefix = 'CMD_';
  ProjectPathMacro = '%ProjectDir%';
  ProjectNameMacro = '%ProjectName%';
  OrganizationNameMacro = '%OrganizationName%';
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

function TfmMain.GetOrganizationName(ASourceDataSet: TDataSet): string;
var
  ProjectDirParts: TStringDynArray;
begin
  if (Pos('.', cdsProjectsPROJECT_NAME.AsString) > 0) then
    Exit(SplitString(cdsProjectCommands.FieldByName('PROJECT_NAME').AsString, '.')[0]);

  ProjectDirParts:= SplitString(cdsProjectCommands.FieldByName('PROJECT_DIR').AsString, '\');

  if (Length(ProjectDirParts) < 3) then
    raise Exception.Create('Cannot resolve OrganizationName from ProjectDir');

  Result:= ProjectDirParts[Length(ProjectDirParts)-2];
end;

function TfmMain.GetVisibleCommandCount: Integer;
begin
  Result:= 0;

  cdsCommands.First;
  while not cdsCommands.Eof do
    begin
      if cdsCommandsIS_FAVORITE.AsBoolean or not pnlShowMore.Visible then
        Inc(Result);
      cdsCommands.Next;
    end;
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
  ArgumentsSaveSize: Integer;
  MS: TMemoryStream;
begin
  Reg:= TRegistry.Create;
  try
    Reg.RootKey:= HKEY_CURRENT_USER;
    if Reg.OpenKey(ConfigurationRegKey, False) then
      try
        FTortoiseProcFileName:= Reg.ReadString(RegValueTortoiseProcFileName);
        LoadDataSet(cdsProjects, Reg, RegValueProjects);

        ArgumentsSaveSize:= cdsCommandsCOMMAND_ARGUMENTS.Size;

        LoadDataSet(cdsCommands, Reg, RegValueCommands);

        if (cdsCommandsCOMMAND_ARGUMENTS.Size <> ArgumentsSaveSize) then
          begin
            MS:= TMemoryStream.Create;
            try
              cdsCommands.SaveToStream(MS, dfXMLUTF8);
              cdsCommands.Close;
              cdsCommands.FieldDefs.Find('COMMAND_ARGUMENTS').Size:= ArgumentsSaveSize;
              cdsCommandsCOMMAND_ARGUMENTS.Size:= ArgumentsSaveSize;
              cdsCommands.CreateDataSet;
              cdsCommands.LoadFromStream(MS);
            finally
              MS.Free;
            end;
          end;
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
      AddFieldDef(CommandPrefix + cdsCommandsCOMMAND_NO.AsString, ftWideString, 2000);
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

function TfmMain.ResolveMacros(const AValue: string; ASourceDataSet: TDataSet): string;
begin
  Result:= AValue;

  Result:= StringReplace(Result, ProjectPathMacro, ASourceDataSet.FieldByName('PROJECT_DIR').AsString, [rfReplaceAll]);
  Result:= StringReplace(Result, ProjectNameMacro, ASourceDataSet.FieldByName('PROJECT_NAME').AsString, [rfReplaceAll]);

  if (Pos(OrganizationNameMacro, Result) > 0) then
    Result:= StringReplace(Result, OrganizationNameMacro, GetOrganizationName(ASourceDataSet), [rfReplaceAll]);
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
  grdProjectCommands.Columns.BeginUpdate;
  try
    grdProjectCommands.Columns.Clear;

    AddColumn('PROJECT_NAME', ProjectNameColumnWidth, False);

    cdsCommands.First;
    while not cdsCommands.Eof do
      begin
        if cdsCommandsIS_FAVORITE.AsBoolean or not pnlShowMore.Visible then
          AddColumn(CommandPrefix + cdsCommandsCOMMAND_NO.AsString, CommandColumnWidth, True);
        cdsCommands.Next;
      end;

    HideGridScrollBar;
  finally
    grdProjectCommands.Columns.EndUpdate;
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
    GetVisibleCommandCount * CommandColumnWidth;
end;

procedure TfmMain.SetFormPosition(const APreserveLeft: Boolean = False);

  function CalcLeft: Integer;
  begin
    Result:= FSavedMousePos.X - ProjectNameColumnWidth - ((GetVisibleCommandCount * CommandColumnWidth) div 2);
    Result:= Max(Result, 0);
    Result:= Min(Result, Screen.Width - Width);
  end;

begin
  if FIsNearMousePosition then
    begin
      Position:= poDesigned;

      if not APreserveLeft then
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
            Category.Title:= Trim(cdsProjectsPROJECT_NAME.AsString);

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
                        ResolveMacros(cdsCommandsCOMMAND_ARGUMENTS.AsString, cdsProjects)]);
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
  ArgumentTokens: TStringList;
  ExeFileName: string;
  NewExeFileName: string;
  ExeFileNameFromPath: string;
  token: string;
begin
  if (Column.FieldName = 'PROJECT_NAME') then
    OpenDirectoryAndHalt(cdsProjectCommands.FieldByName('PROJECT_DIR').AsString);

  Assert(StartsStr('CMD_', Column.FieldName));

  if not cdsCommands.Locate('COMMAND_NO', StrToInt(GetLastToken(Column.FieldName, '_')), []) then
    raise Exception.Create('Internal error: Command not found');

  Arguments:= ResolveMacros(cdsCommandsCOMMAND_ARGUMENTS.AsString, cdsProjectCommands);

  ExeFileName:= FTortoiseProcFileName;

  ArgumentTokens:= TStringList.Create;
  try
    ExtractStrings([' '], [], PChar(Arguments), ArgumentTokens);

    if (ArgumentTokens.Count > 0) then
      begin
        NewExeFileName:= AnsiDequotedStr(ArgumentTokens[0], '"');

        if SameText(ExtractFileExt(NewExeFileName), '.exe') then
          begin
            if (ExtractFilePath(NewExeFileName) = '') then
              begin
                ExeFileNameFromPath:= FileFromPath(NewExeFileName);
                if (ExeFileNameFromPath <> '') then
                  NewExeFileName:= ExeFileNameFromPath;
              end;

            ExeFileName:= NewExeFileName;
            ArgumentTokens.Delete(0);

            Arguments:= '';
            for token in ArgumentTokens do
              Arguments:= Arguments + token + ' ';
            Arguments:= Trim(Arguments);
          end;
      end;
  finally
    ArgumentTokens.Free;
  end;

  ExecCommandAndHalt(ExeFileName, Arguments, cdsProjectCommands.FieldByName('PROJECT_DIR').AsString);
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

procedure TfmMain.aeAppEventsMessage(var Msg: tagMSG; var Handled: Boolean);
var
  p: TPoint;
  Command: string;
  GridCoord: TGridCoord;
begin
  if ((Msg.message = WM_MBUTTONDOWN) or
      (Msg.message = WM_RBUTTONDOWN) or
      ((Msg.message = WM_LBUTTONDOWN) and ControlIsPressed)) and
     grdProjectCommands.MouseInClient then
    begin
      p:= grdProjectCommands.ScreenToClient(Mouse.CursorPos);
      GridCoord:= grdProjectCommands.MouseCoord(p.X, p.Y);

      if (GridCoord.X = 0) then
        begin
          cdsProjectCommands.RecNo:= GridCoord.Y + 1;

          if (Msg.message = WM_MBUTTONDOWN) then
            begin
              OpenDefaultDocumentAndHalt(cdsProjectCommands.FieldByName('PROJECT_DIR').AsString);
            end
          else
            begin
              Command:= TPath.Combine(TPath.GetDirectoryName(ParamStr(0)), 'PowerShellLauncher.exe');
              ExecCommandAndHalt(Command, '', cdsProjectCommands.FieldByName('PROJECT_DIR').AsString);
            end;
        end;
    end;
end;

procedure TfmMain.actShowMoreExecute(Sender: TObject);
begin
  cdsProjectCommands.Filtered:= False;
  pnlShowMore.Visible:= False;
  pnlConfig.Visible:= True;
  RecalcFormDimensionsAndPosition(True);
  RefreshGridColumns;
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

procedure TfmMain.RecalcFormDimensionsAndPosition(const APreserveLeft: Boolean = False);
begin
  SetFormHeight;
  SetFormWidth;
  SetFormPosition(APreserveLeft);
  HideGridScrollBar;
end;

end.
