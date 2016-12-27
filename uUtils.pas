unit uUtils;

interface

procedure ExecCommandAndHalt(const AExeFileName, AArguments, AWorkingDir: string);
procedure OpenDirectoryAndHalt(const ADirectory: string);
function GetLastToken(const AStr: string; ADelimiter: Char): string;
function VarToInt(const AValue: Variant): Integer;
function GetTaskBarHeight: Integer;
function IsTaskBarAtBottom: Boolean;
function RepositoryTypeName: string;
function RepositoryTypeSubDirName: string;
function DefaultTortoiseProcFileName: string;
function FileFromPath(const AFileName: string): string;

const
  RepositoryTypeNameSVN = 'svn';
  RepositoryTypeNameGit = 'git';

implementation

uses
  JclShell, SysUtils, JclStrings, StrUtils, Variants, Windows, Classes;

function RepositoryTypeName: string;
var
  Param: string;
begin
  if (ParamCount = 0) then
    Exit(RepositoryTypeNameGit);

  Param:= LowerCase(ParamStr(1));

  if (Param <> RepositoryTypeNameSVN) and (Param <> RepositoryTypeNameGit) then
    raise Exception.CreateFmt('Unknown repository type "%s"', [Param])
  else
    Result:= Param;
end;

function RepositoryTypeSubDirName: string;
begin
  Result:= Format('.%s', [RepositoryTypeName]);
end;

function DefaultTortoiseProcFileName: string;
const
  DefaultTortoiseSVNProcFileName = '\TortoiseSVN\bin\TortoiseProc.exe';
  DefaultTortoiseGitProcFileName = '\TortoiseGit\bin\TortoiseGitProc.exe';
begin
  if (RepositoryTypeName = RepositoryTypeNameSVN) then
    Exit(DefaultTortoiseSVNProcFileName);

  if (RepositoryTypeName = RepositoryTypeNameGit) then
    Exit(DefaultTortoiseGitProcFileName);

  raise Exception.Create('Unknown repository type');
end;

procedure ExecCommandAndHalt(const AExeFileName, AArguments, AWorkingDir: string);
var
  UnquotedExeFileName: string;
begin
  UnquotedExeFileName:= StrEnsureNoSuffix('"', StrEnsureNoPrefix('"', AExeFileName));

  if not FileExists(UnquotedExeFileName) then
    raise Exception.CreateFmt('File %s does not exist!', [AExeFileName]);

  ShellExec(0, 'open', AExeFileName, AArguments, AWorkingDir, SW_SHOWNORMAL);
  Halt(0);
end;

procedure OpenDirectoryAndHalt(const ADirectory: string);
begin
  if not DirectoryExists(ADirectory) then
    raise Exception.CreateFmt('Directory %s does not exist!', [ADirectory]);

  ShellExec(0, 'open', ADirectory, '', '', SW_SHOWNORMAL);
  Halt(0);
end;

function GetLastToken(const AStr: string; ADelimiter: Char): string;
begin
  Result:= RightStr(AStr, Length(AStr) - LastDelimiter(ADelimiter, AStr));
end;

function VarToInt(const AValue: Variant): Integer;
begin
  if VarIsEmpty(AValue) or VarIsNull(AValue) then
    Result:= 0
  else
    Result:= AValue;
end;

function GetTaskBarRect: TRect;
var
  TaskBarHandle: HWND;
begin
  Result:= Rect(0, 0, 0, 0);

  TaskBarHandle:= FindWindow('Shell_TrayWnd', '');
  if (TaskBarHandle <> 0) then
    GetWindowRect(TaskBarHandle, Result);
end;

function GetTaskBarHeight: Integer;
var
  TaskBarRect: TRect;
begin
  TaskBarRect:= GetTaskBarRect;
  Result:= TaskBarRect.Bottom - TaskBarRect.Top;
end;

function IsTaskBarAtBottom: Boolean;
var
  TaskBarRect: TRect;
begin
  TaskBarRect:= GetTaskBarRect;
  Result:= (TaskBarRect.Top > 0);
end;

function FileFromPath(const AFileName: string): string;
var
  a: PChar;
  len: Integer;
begin
  SetLength(Result, 1024 * 8);
  a:= nil;
  len:= SearchPath(nil, PChar(AFileName), nil, Length(Result), PChar(Result), a);
  if (len > 0) then
    Result:= LeftStr(Result, len)
  else
    Result:= '';
end;

end.
