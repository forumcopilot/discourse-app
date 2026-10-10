@echo off
REM Bootstrap after a fresh clone, and again after changing an ARB file or an
REM annotated SDK class. See buildlib.sh for why each nested package needs
REM its own pub get: root `flutter pub get` writes no package_config for them.
setlocal
cd /d "%~dp0"

for %%p in (forumcopilot_sdk forum_kit discourse_core discourse_appearance discourse_notifications discourse_ui) do (
  echo Resolving packages\%%p...
  pushd packages\%%p
  call dart pub get
  if errorlevel 1 exit /b 1
  popd
)

call build_forumcopilot_sdk.bat
if errorlevel 1 exit /b 1

REM Each package with an l10n.yaml generates its own; gen-l10n must run there.
echo Generating localizations...
pushd packages\forum_kit
call flutter gen-l10n
if errorlevel 1 exit /b 1
popd
pushd packages\discourse_ui
call flutter gen-l10n
if errorlevel 1 exit /b 1
popd
echo Done.
