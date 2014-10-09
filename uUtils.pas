unit uUtils;

interface

procedure ExecCommandAndHalt(const AExeFileName, AArguments: string);
procedure OpenDirectoryAndHalt(const ADirectory: string);
function GetLastToken(const AStr: string; ADelimiter: Char): string;
function VarToInt(const AValue: Variant): Integer;
function GetTaskBarHeight: Integer;
function IsTaskBarAtBottom: Boolean;

const
  SVNSubDir = '.svn';
  GitSubDir = '.git';

implementation

uses
  JclShell, SysUtils, JclStrings, StrUtils, Variants, Windows, Classes;

procedure ExecCommandAndHalt(const AExeFileName, AArguments: string);
var
  UnquotedExeFileName: string;
begin
  UnquotedExeFileName:= StrEnsureNoSuffix('"', StrEnsureNoPrefix('"', AExeFileName));

  if not FileExists(UnquotedExeFileName) then
    raise Exception.CreateFmt('File %s does not exist!', [AExeFileName]);

  ShellExec(0, 'open', AExeFileName, AArguments, '', 0);
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

end.
