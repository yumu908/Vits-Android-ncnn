@echo off
rem =============================================================
rem   Copy pre‑built ncnn Android libraries into the project
rem   ---------------------------------------------------------
rem   Prerequisites:
rem     • Pre‑built ncnn Android Vulkan package (already extracted)
rem     • Android NDK (optional – only needed if you want to patch toolchain)
rem =============================================================

:: ---------- Locate Android NDK (optional) ----------
if defined ANDROID_NDK (
    set "NDK_ROOT=%ANDROID_NDK%"
) else (
    set "NDK_ROOT=C:\Users\intel\AppData\Local\Android\Sdk\ndk\27.0.12077973"
)

if exist "%NDK_ROOT%" (
    echo Using Android NDK at: %NDK_ROOT%
    :: Optional: patch toolchain to remove "-g" flag (skip if not needed)
    set "TOOLCHAIN=%NDK_ROOT%\build\cmake\android.toolchain.cmake"
    if exist "%TOOLCHAIN%" (
        if not exist "%TOOLCHAIN%.bak" copy "%TOOLCHAIN%" "%TOOLCHAIN%.bak" > nul
        powershell -Command "(Get-Content -Path '%TOOLCHAIN%') | Where-Object { $_ -notmatch '-g' } | Set-Content -Path '%TOOLCHAIN%'"
        echo Patched toolchain file to remove "-g".
    ) else (
        echo [INFO] Android toolchain not found – skipping patch.
    )
) else (
    echo [WARNING] Android NDK not found at %NDK_ROOT% – proceeding without patch.
)

rem ---------- 1. Define paths ----------
set "NCNN_PREBUILT=%~dp0ncnn-20221128-android-vulkan"
if not exist "%NCNN_PREBUILT%" (
    echo [ERROR] Pre‑built ncnn folder not found: %NCNN_PREBUILT%
    pause
    exit /b 1
)

set "DEST_ROOT=%~dp0app\src\main\cpp\ncnn"
if not exist "%DEST_ROOT%" md "%DEST_ROOT%"

rem ---------- 2. Copy pre‑built libraries ----------
xcopy /e /i /y "%NCNN_PREBUILT%" "%DEST_ROOT%"
if errorlevel 1 (
    echo [ERROR] Copying pre‑built ncnn failed.
    pause
    exit /b 1
)

echo Pre‑built ncnn libraries have been copied to "%DEST_ROOT%".

rem =============================================================
echo All required ncnn files are now in the project.
pause
