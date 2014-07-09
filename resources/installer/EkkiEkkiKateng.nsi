; NSIS-installer for EkkiEkkiKateng project.
;--------------------------------------------
!include "WinMessages.nsh"

;!define /date VERSION "%Y-%m-%d_%H-%M-%S"
!define /date VERSION "%Y-%m-%d_%H-%M"
!define /date VERSION2 "%Y.%m.%d.%H.%M"

!define BASE_DIR "..\.."

; The name of the installer
Name "EkkiEkkiKateng ${VERSION}"

; The file to write
OutFile "EkkiEkkiKateng_Installer_${VERSION}.exe"

; The default installation directory
InstallDir $PROGRAMFILES\EkkiEkkiKateng

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
InstallDirRegKey HKCU "Software\EkkiEkkiKateng" "Install_Dir"

; Request application privileges for Windows Vista
RequestExecutionLevel user
; RequestExecutionLevel admin

Icon "icon.ico"
BrandingText " "

VIProductVersion "${VERSION2}"
VIAddVersionKey "ProductName" "EkkiEkkiKateng"
VIAddVersionKey "Comments" "https://github.com/ClaudiusJ/EkkiEkkiKateng"
;VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "Fake company"
;VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalTrademarks" "Test Application is a trademark of Fake company"
VIAddVersionKey "LegalCopyright" "©Claudius Jähn(ClaudiusJ@live.de)"
VIAddVersionKey "FileDescription" "Build file generator"
VIAddVersionKey "FileVersion" "${VERSION2}"

Caption "EkkiEkkiKateng"

;--------------------------------

; Pages

Page license
Page components
Page directory
Page instfiles

;UninstPage uninstConfirm
;UninstPage instfiles
;--------------------------------
LicenseText "EkkiEkkiKateng ${VERSION}" "Ok"
LicenseData "Notice.txt"
;--------------------------------
InstType "Default"
InstType "Complete"

; The stuff to install
SectionGroup "EScript"

Section "Install EScript.exe (required)"
SectionIn 1 2
SetOutPath $INSTDIR\EScript
File /oname=EScript.exe ${BASE_DIR}\EScript\EScript.exe 
File /oname=LICENSE ${BASE_DIR}\EScript\LICENSE
File /oname=AUTHORS ${BASE_DIR}\EScript\AUTHORS
SectionEnd
; ---
Section "Cleanup old Std-Lib"
RMdir /r $INSTDIR\Std
SectionEnd
; ---
Section "Install Std-Lib (required)"
SectionIn 1 2
SetOutPath $INSTDIR\EScript\Std
File /r /x .git ${BASE_DIR}\EScript\Std\*.*
SectionEnd
; ---
Section "Install EScript sources and docs"
SectionIn 2
SetOutPath $INSTDIR\EScript\EScript
File /r /x .git ${BASE_DIR}\EScript\EScript\*.*
SetOutPath $INSTDIR\EScript\E_Libs
File /r /x .git ${BASE_DIR}\EScript\E_Libs\*.*
SetOutPath $INSTDIR\EScript\docs
File /r /x .git ${BASE_DIR}\EScript\docs\*.*
SetOutPath $INSTDIR\EScript
File /oname=EScriptConfig.cmake.in ${BASE_DIR}\EScript\EScriptConfig.cmake.in
File /oname=CMakeLists.txt ${BASE_DIR}\EScript\CMakeLists.txt
File /oname=EScript.ekki ${BASE_DIR}\EScript\EScript.ekki
SectionEnd
; ---

SectionGroupEnd
;--------------

SectionGroup "EkkiEkkiKateng"
; ---
Section "Cleanup old Files"
RMdir /r $INSTDIR\EkkiEkkiKateng
SectionEnd
; ---
Section "Install EkkiEkkiKateng (required)"
SectionIn 1 2
SetOutPath $INSTDIR\EkkiEkkiKateng
File /r /x .git /x *.exe ${BASE_DIR}\EkkiEkkiKateng\*.*
SetOutPath $INSTDIR
File /oname=LICENSE ${BASE_DIR}\LICENSE
File /oname=README.md ${BASE_DIR}\README.md
SectionEnd

; ---
Section "Install Resources"
SectionIn 1 2
SetOutPath $INSTDIR\resources
File /r /x .git /x *.exe ${BASE_DIR}\resources\*.*
SectionEnd

SectionGroupEnd

; -----------------------------------

Section "Store install path in registry"
SectionIn 1 2
WriteRegStr HKCU "Software\EkkiEkkiKateng" "Install_Dir" "$INSTDIR"

SectionEnd
; ---
Section "Associate with .ekki files (requires admin privilidges)"
SectionIn 1 2
; old
; WriteRegStr HKCR ".ekki" "" "EkkiEkkiKateng.ProjectDescription"
; WriteRegStr HKCR "EkkiEkkiKateng.ProjectDescription" "" "EkkiEkkiKateng project description"
; WriteRegStr HKCR "EkkiEkkiKateng.ProjectDescription\DefaultIcon" "" "$INSTDIR\EScript.exe,0"
;WriteRegStr HKCR "EkkiEkkiKateng.ProjectDescription\shell\open\command" "" '"$INSTDIR\EScript.exe" "%1"'
; new [http://msdn.microsoft.com/en-us/library/windows/desktop/cc144158%28v=vs.85%29.aspx]
WriteRegStr HKCR "EkkiEkkiKateng.1" "" "EkkiEkkiKateng project generator"
WriteRegStr HKCR "EkkiEkkiKateng.1" "FriendlyTypeName" "@EkkiEkkiKateng, -120"
WriteRegStr HKCR "EkkiEkkiKateng.1\CurVer" "" "EkkiEkkiKateng.1"
WriteRegStr HKCR "EkkiEkkiKateng.1\DefaultIcon" "" "$INSTDIR\EScript\EScript.exe,0"
WriteRegStr HKCR "EkkiEkkiKateng.1\shell\open\command" "" '"$INSTDIR\EScript\EScript.exe" "%1"'
WriteRegStr HKCR ".ekki" "" "EkkiEkkiKateng.1"

SectionEnd

