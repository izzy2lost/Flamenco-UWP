@echo off
setlocal enabledelayedexpansion

echo Setting UWP environment...
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" (
  call "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvarsall.bat" x64 uwp
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" (
  call "%ProgramFiles%\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 uwp
) else (
  echo Visual Studio 2022 not found.
  goto error
)

set SEVENZIP="C:\Program Files\7-Zip\7z.exe"

if defined DEBUG (
  echo DEBUG=%DEBUG%
) else (
  set DEBUG=1
)

pushd %~dp0
set "SCRIPTDIR=%CD%"
cd ..\dep\msvc
mkdir deps-build
cd deps-build || goto error
set "BUILDDIR=%CD%"
cd ..
mkdir deps-x64
cd deps-x64 || goto error
set "INSTALLDIR=%CD%"
popd

echo SCRIPTDIR=%SCRIPTDIR%
echo BUILDDIR=%BUILDDIR%
echo INSTALLDIR=%INSTALLDIR%

cd "%BUILDDIR%"

set QT=6.6.2
set QTMINOR=6.6
set SDL=SDL2-2.30.1

call :downloadfile "%SDL%.zip" "https://libsdl.org/release/%SDL%.zip" || goto error
call :downloadfile "qtbase-everywhere-src-%QT%.zip" "https://download.qt.io/official_releases/qt/%QTMINOR%/%QT%/submodules/qtbase-everywhere-src-%QT%.zip" || goto error
call :downloadfile "qtimageformats-everywhere-src-%QT%.zip" "https://download.qt.io/official_releases/qt/%QTMINOR%/%QT%/submodules/qtimageformats-everywhere-src-%QT%.zip" || goto error
call :downloadfile "qtsvg-everywhere-src-%QT%.zip" "https://download.qt.io/official_releases/qt/%QTMINOR%/%QT%/submodules/qtsvg-everywhere-src-%QT%.zip" || goto error
call :downloadfile "qttools-everywhere-src-%QT%.zip" "https://download.qt.io/official_releases/qt/%QTMINOR%/%QT%/submodules/qttools-everywhere-src-%QT%.zip" || goto error
call :downloadfile "qttranslations-everywhere-src-%QT%.zip" "https://download.qt.io/official_releases/qt/%QTMINOR%/%QT%/submodules/qttranslations-everywhere-src-%QT%.zip" || goto error

if %DEBUG%==1 (
  echo Building debug and release libraries...
) else (
  echo Building release libraries...
)

set FORCEPDB=-DCMAKE_SHARED_LINKER_FLAGS_RELEASE="/DEBUG"

echo Building SDL...
rmdir /S /Q "%SDL%"
%SEVENZIP% x "%SDL%.zip" || goto error
cd "%SDL%" || goto error

rem Build SDL using MSBuild instead of CMake
set SDL_SLN="VisualC-WinRT/SDL-UWP.sln"

if %DEBUG%==1 (
  echo Building SDL Debug...
  msbuild %SDL_SLN% /p:Configuration=Debug /p:Platform=x64 || goto error
  copy "D:\a\Flamenco-UWP\Flamenco-UWP\dep\msvc\deps-build\SDL2-2.30.1\VisualC-WinRT\x64\Debug\SDL-UWP\SDL2.dll" "%INSTALLDIR%\bin\" || goto error
  copy "D:\a\Flamenco-UWP\Flamenco-UWP\dep\msvc\deps-build\SDL2-2.30.1\VisualC-WinRT\x64\Debug\SDL-UWP\SDL2.lib" "%INSTALLDIR%\lib\" || goto error
  copy "D:\a\Flamenco-UWP\Flamenco-UWP\dep\msvc\deps-build\SDL2-2.30.1\VisualC-WinRT\x64\Debug\SDL-UWP\SDL2.pdb" "%INSTALLDIR%\bin\" || goto error
)

echo Building SDL Release...
msbuild %SDL_SLN% /p:Configuration=Release /p:Platform=x64 || goto error
copy "D:\a\Flamenco-UWP\Flamenco-UWP\dep\msvc\deps-build\SDL2-2.30.1\VisualC-WinRT\x64\Release\SDL-UWP\SDL2.dll" "%INSTALLDIR%\bin\" || goto error
copy "D:\a\Flamenco-UWP\Flamenco-UWP\dep\msvc\deps-build\SDL2-2.30.1\VisualC-WinRT\x64\Release\SDL-UWP\SDL2.lib" "%INSTALLDIR%\lib\" || goto error
copy "D:\a\Flamenco-UWP\Flamenco-UWP\dep\msvc\deps-build\SDL2-2.30.1\VisualC-WinRT\x64\Release\SDL-UWP\SDL2.pdb" "%INSTALLDIR%\bin\" || goto error

cd .. || goto error

set QTBUILDSPEC=^
  -DQT_QMAKE_TARGET_MKSPEC=winrt-x64-msvc ^
  -DCMAKE_SYSTEM_NAME=WindowsStore ^
  -DCMAKE_SYSTEM_VERSION=10.0 ^
  -G "Ninja"

echo Building Qt base for UWP...
rmdir /S /Q "qtbase-everywhere-src-%QT%"
%SEVENZIP% x "qtbase-everywhere-src-%QT%.zip" || goto error
cd "qtbase-everywhere-src-%QT%" || goto error
cmake -B build ^
  -DFEATURE_sql=OFF ^
  -DCMAKE_INSTALL_PREFIX="%INSTALLDIR%" ^
  %FORCEPDB% ^
  -DINPUT_gui=yes ^
  -DINPUT_ssl=yes ^
  -DINPUT_openssl=no ^
  -DINPUT_schannel=yes ^
  %QTBUILDSPEC% || goto error
cmake --build build --parallel || goto error
ninja -C build install || goto error
cd .. || goto error

echo Building Qt SVG for UWP...
rmdir /S /Q "qtsvg-everywhere-src-%QT%"
%SEVENZIP% x "qtsvg-everywhere-src-%QT%.zip" || goto error
cd "qtsvg-everywhere-src-%QT%" || goto error
mkdir build || goto error
cd build || goto error
call "%INSTALLDIR%\bin\qt-configure-module.bat" .. -- %FORCEPDB% %QTBUILDSPEC% || goto error
cmake --build . --parallel || goto error
ninja install || goto error
cd ..\.. || goto error

echo Building Qt Image Formats for UWP...
rmdir /S /Q "qtimageformats-everywhere-src-%QT%"
%SEVENZIP% x "qtimageformats-everywhere-src-%QT%.zip" || goto error
cd "qtimageformats-everywhere-src-%QT%" || goto error
mkdir build || goto error
cd build || goto error
call "%INSTALLDIR%\bin\qt-configure-module.bat" .. -- %FORCEPDB% %QTBUILDSPEC% || goto error
cmake --build . --parallel || goto error
ninja install || goto error
cd ..\.. || goto error

echo Building Qt Tools for UWP...
rmdir /S /Q "qttools-everywhere-src-%QT%"
%SEVENZIP% x "qttools-everywhere-src-%QT%.zip" || goto error
cd "qttools-everywhere-src-%QT%" || goto error
mkdir build || goto error
cd build || goto error
call "%INSTALLDIR%\bin\qt-configure-module.bat" .. -- %FORCEPDB% %QTBUILDSPEC% -DFEATURE_assistant=OFF -DFEATURE_clang=OFF -DFEATURE_designer=OFF -DFEATURE_kmap2qmap=OFF -DFEATURE_pixeltool=OFF -DFEATURE_pkg_config=OFF || goto error
cmake --build . --parallel || goto error
ninja install || goto error
cd ..\.. || goto error

echo Building Qt Translations for UWP...
rmdir /S /Q "qttranslations-everywhere-src-%QT%"
%SEVENZIP% x "qttranslations-everywhere-src-%QT%.zip" || goto error
cd "qttranslations-everywhere-src-%QT%" || goto error
mkdir build || goto error
cd build || goto error
call "%INSTALLDIR%\bin\qt-configure-module.bat" .. -- %FORCEPDB% %QTBUILDSPEC% || goto error
cmake --build . --parallel || goto error
ninja install || goto error
cd ..\.. || goto error

echo Cleaning up...
cd ..
rd /S /Q deps-build

echo UWP build completed successfully.
exit 0

:error
echo Failed with error #%errorlevel%.
pause
exit %errorlevel%

:downloadfile
if not exist "%~1" (
  echo Downloading %~1 from %~2...
  curl -L -o "%~1" "%~2"
  if errorlevel 1 exit /B 1
)
exit /B 0
