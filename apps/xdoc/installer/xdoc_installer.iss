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
UninstallDisplayIcon={app}\xdoc.exe

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1

[Files]
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\XDoc"; Filename: "{app}\xdoc.exe"; IconFilename: "{app}\xdoc.exe"
Name: "{autodesktop}\XDoc"; Filename: "{app}\xdoc.exe"; Tasks: desktopicon; IconFilename: "{app}\xdoc.exe"
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\XDoc"; Filename: "{app}\xdoc.exe"; Tasks: quicklaunchicon; IconFilename: "{app}\xdoc.exe"

[Registry]
Root: HKCR; Subkey: "xdoc"; ValueType: string; ValueName: ""; ValueData: "URL:XDoc Protocol"; Flags: uninsdeletekey
Root: HKCR; Subkey: "xdoc"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""; Flags: uninsdeletekey
Root: HKCR; Subkey: "xdoc"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Flags: uninsdeletekey
Root: HKCR; Subkey: "xdoc\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\xdoc.exe"""; Flags: uninsdeletekey

[Run]
Filename: "{app}\xdoc.exe"; Description: "{cm:LaunchProgram,XDoc}"; Flags: nowait postinstall skipifsilent

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
