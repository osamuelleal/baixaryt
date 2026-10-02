; Inno Setup script for BaixarYT. Build the release first, then compile:
;   flutter build windows --release
;   iscc installer\baixaryt.iss        -> dist\BaixarYT-Setup-<version>.exe
#define AppVersion "1.0.0"
#define Release "..\build\windows\x64\runner\Release"

[Setup]
AppId={{93FBE5C0-C33E-4BC6-8019-0882F3F2CF14}
AppName=BaixarYT
AppVersion={#AppVersion}
AppPublisher=osamuelleal
AppPublisherURL=https://github.com/osamuelleal/baixaryt
; Per-user install (no admin) so yt-dlp can update itself inside {app}\bin.
PrivilegesRequired=lowest
DefaultDirName={localappdata}\Programs\BaixarYT
DisableProgramGroupPage=yes
OutputDir=..\dist
OutputBaseFilename=BaixarYT-Setup-{#AppVersion}
SetupIconFile=..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\baixaryt.exe
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "ptbr"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "en"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "{#Release}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\BaixarYT"; Filename: "{app}\baixaryt.exe"
Name: "{autodesktop}\BaixarYT"; Filename: "{app}\baixaryt.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\baixaryt.exe"; Description: "{cm:LaunchProgram,BaixarYT}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
; yt-dlp self-updates leave files Setup didn't install.
Type: filesandordirs; Name: "{app}\bin"
