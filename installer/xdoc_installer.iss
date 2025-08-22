[Setup]
AppName=XDoc
AppVersion=1.0.0
AppPublisher=XDoc App
AppPublisherURL=https://xdocapp.com
DefaultDirName=C:\XDoc
DefaultGroupName=XDoc
AllowNoIcons=yes
OutputDir=.
OutputBaseFilename=XDoc_Setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
UninstallDisplayIcon={app}\flutter_starter.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "launch_xdoc.bat"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\XDoc"; Filename: "{app}\flutter_starter.exe"; IconFilename: "{app}\flutter_starter.exe"
Name: "{autodesktop}\XDoc"; Filename: "{app}\flutter_starter.exe"; Tasks: desktopicon; IconFilename: "{app}\flutter_starter.exe"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\XDoc"; Filename: "{app}\flutter_starter.exe"; Tasks: quicklaunchicon; IconFilename: "{app}\flutter_starter.exe"

[Registry]
Root: HKCR; Subkey: "xdoc"; ValueType: string; ValueName: ""; ValueData: "URL:XDoc Protocol"; Flags: uninsdeletekey
Root: HKCR; Subkey: "xdoc"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletekey
Root: HKCR; Subkey: "xdoc"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKCR; Subkey: "xdoc\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\launch_xdoc.bat"""; Flags: uninsdeletekey

[Run]
Filename: "{app}\flutter_starter.exe"; Description: "{cm:LaunchProgram,XDoc}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then
  begin
    // Additional post-install tasks can be added here
  end;
end;
