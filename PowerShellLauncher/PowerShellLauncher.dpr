program PowerShellLauncher;

{$R *.res}

uses
  System.SysUtils, Windows, WinApi.ShellApi;

begin
  ShellExecute(0, '', 'powershell.exe', '', '', SW_SHOW);
end.
