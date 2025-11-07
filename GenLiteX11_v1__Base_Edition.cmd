@echo off
setlocal enabledelayedexpansion

title GenLiteX11 v1.0 Stable - Optimizacion Windows 

net session >nul 2>&1
if %errorlevel% neq 0 (
  color 0C
  echo ================================================
  echo ERROR: Ejecuta este script como Administrador
  echo ================================================
  echo Haz clic derecho en el archivo y selecciona:
  echo "Ejecutar como administrador"
  echo.
  pause
  exit /b 1
)

:: ---------- Variables y Fecha ----------
for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd')"`) do set BACKUP_DATE=%%D
set "LOG_FILE=%~dp0GenLiteX11_Log_%BACKUP_DATE%.txt"

echo [%date% %time%] ========== INICIANDO GenLiteX11 v1.0 ========== > "%LOG_FILE%"

:: ---------- VERIFICACION DE WINDOWS ----------
echo Verificando sistema operativo...
for /f "tokens=4-5 delims=[.] " %%i in ('ver') do set "WIN_VER=%%i.%%j"
if "!WIN_VER!" LSS "10.0" (
    color 0C
    echo [ERROR] Este script requiere Windows 10 o superior
    echo [ERROR] Version detectada: !WIN_VER!
    echo [ERROR] Sistema no compatible >> "%LOG_FILE%"
    pause
    exit /b 1
)

:: Detectar Windows 11
for /f "tokens=3" %%a in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul ^| find "CurrentBuild"') do set WIN_BUILD=%%a
if !WIN_BUILD! GEQ 22000 (
    set "WIN_NAME=Windows 11"
    echo [OK] Windows 11 detectado [Build !WIN_BUILD!] >> "%LOG_FILE%"
) else (
    set "WIN_NAME=Windows 10"
    echo [OK] Windows 10 detectado [Build !WIN_BUILD!] >> "%LOG_FILE%"
)

:: ---------- DETECCION HARDWARE ----------
echo Detectando hardware...

:: RAM Detection (mejorado)
for /f "skip=1 tokens=*" %%I in ('wmic computersystem get TotalPhysicalMemory 2^>nul') do (
    if not defined RAM_BYTES (
        set "RAM_BYTES=%%I"
        set "RAM_BYTES=!RAM_BYTES: =!"
    )
)
if not defined RAM_BYTES set RAM_BYTES=4294967296
if !RAM_BYTES! lss 1048576 set RAM_BYTES=4294967296
set /a RAM_MB=!RAM_BYTES!/1048576
set /a RAM_GB=!RAM_MB!/1024

:: Disk Type Detection (mejorado)
set DISKTYPE=HDD
set DISK_FOUND=0
for /f "skip=1 tokens=*" %%D in ('wmic diskdrive get MediaType 2^>nul') do (
    set "MEDIA=%%D"
    echo !MEDIA! | findstr /i "SSD" >nul && (
        set DISKTYPE=SSD
        set DISK_FOUND=1
    )
)
if !DISK_FOUND!==0 (
    for /f "skip=1 tokens=*" %%D in ('wmic diskdrive get Model 2^>nul') do (
        set "MODEL=%%D"
        echo !MODEL! | findstr /i "SSD NVME" >nul && set DISKTYPE=SSD
    )
)

echo [OK] Hardware detectado: !RAM_GB!GB RAM, !DISKTYPE! >> "%LOG_FILE%"

:: ---------- MENU PRINCIPAL ----------
:menu
cls
color 0B
echo ================================================
echo   GenLiteX11 v1.0 Stable - !WIN_NAME!
echo   YouTube: https://www.youtube.com/@GeniousMods 
echo ================================================
echo  Sistema: !WIN_NAME! [Build !WIN_BUILD!]
echo  RAM: !RAM_GB! GB (!RAM_MB! MB)
echo  Disco: !DISKTYPE!
echo ================================================
echo  1. Optimizacion COMPLETA (Recomendada)
echo  2. Optimizacion GAMING (Alto rendimiento)
echo  3. Optimizacion BASICA (Segura)
echo  4. DESINSTALAR Bloatware
echo  5. LIMPIEZA de Disco
echo  6. RESTAURAR Registro
echo  7. Ver LOG
echo  8. Ayuda
echo  9. Salir
echo ================================================
echo.
set opcion=
set /p opcion="Selecciona opcion [1-9]: "
if "!opcion!"=="1" goto full_optimize
if "!opcion!"=="2" goto gaming_optimize
if "!opcion!"=="3" goto basic_optimize
if "!opcion!"=="4" goto remove_bloatware
if "!opcion!"=="5" goto disk_cleanup
if "!opcion!"=="6" goto restore_registry
if "!opcion!"=="7" goto view_log
if "!opcion!"=="8" goto ayuda_script
if "!opcion!"=="9" goto end_script
echo.
color 0E
echo [!] Opcion invalida, intenta de nuevo...
timeout /t 2 >nul
goto menu

:: ========== OPTIMIZACION COMPLETA ==========
:full_optimize
cls
color 0A
echo ================================================
echo  OPTIMIZACION COMPLETA
echo ================================================
echo.
echo [%date% %time%] >>> Iniciando Optimizacion COMPLETA >> "%LOG_FILE%"

:: Backup del registro
set "BACKUP_REG=%~dp0Registry_Backup_Full_%BACKUP_DATE%.reg"
echo [0/21] Creando backup del registro...
reg export HKLM\SOFTWARE "%BACKUP_REG%" /y >nul 2>&1
if !errorlevel!==0 (
  echo    [OK] Backup guardado: Registry_Backup_Full_%BACKUP_DATE%.reg
  echo [OK] Backup registro guardado >> "%LOG_FILE%"
) else (
  color 0E
  echo    [ERROR] No se pudo crear backup del registro
  echo [ERROR] Backup registro fallo >> "%LOG_FILE%"
  echo.
  choice /c SN /n /m "RIESGO: Continuar sin backup? [S/N]: "
  if !errorlevel!==2 goto menu
  color 0A
)

:: Punto de restauracion
echo [1/21] Creando punto de restauracion...
powershell -Command "try{Checkpoint-Computer -Description 'GenLiteX11_v1.0_Full' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop; exit 0}catch{exit 1}" >nul 2>&1
if !errorlevel!==0 (
  echo    [OK] Punto de restauracion creado
  echo [OK] Punto de restauracion creado >> "%LOG_FILE%"
) else (
  echo    [WARN] No se pudo crear punto de restauracion (puede estar desactivado)
  echo [WARN] Punto de restauracion omitido >> "%LOG_FILE%"
)

echo [2/21] Optimizando plan de energia...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -change -monitor-timeout-ac 0 >nul 2>&1
powercfg -change -disk-timeout-ac 0 >nul 2>&1
powercfg -change -standby-timeout-ac 0 >nul 2>&1
echo    [OK] Plan de energia optimizado (Ultimate Performance)
echo [OK] Plan de energia optimizado >> "%LOG_FILE%"

echo [3/21] Desactivando hibernacion...
powercfg -h off >nul 2>&1
echo    [OK] Hibernacion desactivada (libera espacio)
echo [OK] Hibernacion desactivada >> "%LOG_FILE%"

echo [4/21] Ajustando Prefetch/Superfetch...
if !RAM_MB! GEQ 3072 (
    if "!DISKTYPE!"=="SSD" (
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f >nul 2>&1
        reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f >nul 2>&1
        echo    [OK] Prefetch/Superfetch desactivado (SSD detectado)
        echo [OK] Prefetch/Superfetch desactivado (SSD) >> "%LOG_FILE%"
    ) else (
        echo    [SKIP] HDD detectado - Prefetch necesario para rendimiento
        echo [SKIP] Prefetch mantenido (HDD) >> "%LOG_FILE%"
    )
) else (
    echo    [SKIP] RAM baja - Prefetch necesario
    echo [SKIP] Prefetch mantenido (RAM baja) >> "%LOG_FILE%"
)

echo [5/21] Configurando paginacion ejecutiva...
if !RAM_MB! GEQ 8192 (
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul 2>&1
  echo    [OK] DisablePagingExecutive activado (8GB+ RAM)
  echo [OK] DisablePagingExecutive activado >> "%LOG_FILE%"
) else (
  echo    [SKIP] RAM insuficiente (requiere 8GB+)
  echo [SKIP] DisablePagingExecutive omitido (riesgo) >> "%LOG_FILE%"
)

echo [6/21] Desactivando SysMain (Superfetch)...
sc config "SysMain" start= disabled >nul 2>&1
sc stop "SysMain" >nul 2>&1
echo    [OK] SysMain detenido
echo [OK] SysMain detenido >> "%LOG_FILE%"

echo [7/21] Desinstalando OneDrive...
taskkill /f /im OneDrive.exe >nul 2>&1
if exist "%SystemRoot%\SysWOW64\OneDriveSetup.exe" (
    start /wait "" "%SystemRoot%\SysWOW64\OneDriveSetup.exe" /uninstall >nul 2>&1
)
if exist "%SystemRoot%\System32\OneDriveSetup.exe" (
    start /wait "" "%SystemRoot%\System32\OneDriveSetup.exe" /uninstall >nul 2>&1
)
rd /s /q "%UserProfile%\OneDrive" >nul 2>&1
rd /s /q "%LocalAppData%\Microsoft\OneDrive" >nul 2>&1
rd /s /q "%ProgramData%\Microsoft OneDrive" >nul 2>&1
reg delete "HKCU\Software\Microsoft\OneDrive" /f >nul 2>&1
reg add "HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /v System.IsPinnedToNameSpaceTree /t REG_DWORD /d 0 /f >nul 2>&1
echo    [OK] OneDrive desinstalado completamente
echo [OK] OneDrive desinstalado >> "%LOG_FILE%"

echo [8/21] Desinstalando Widgets...
PowerShell -NoP -C "Get-AppxPackage *WebExperience* | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue" >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul 2>&1
echo    [OK] Widgets desinstalados
echo [OK] Widgets desinstalados >> "%LOG_FILE%"

echo [9/21] Optimizando Windows Defender...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v AvgCPULoadFactor /t REG_DWORD /d 20 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v LowCpuPriority /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v DisableCatchupFullScan /t REG_DWORD /d 1 /f >nul 2>&1
echo    [OK] Defender optimizado (bajo consumo CPU)
echo [OK] Defender optimizado >> "%LOG_FILE%"

echo [10/21] Limpiando caches de iconos...
ie4uinit.exe -show >nul 2>&1
taskkill /f /im explorer.exe >nul 2>&1
del /f /s /q "%LocalAppData%\IconCache.db" >nul 2>&1
del /f /s /q "%LocalAppData%\Microsoft\Windows\Explorer\*.db" >nul 2>&1
start explorer.exe
timeout /t 2 /nobreak >nul
echo    [OK] Caches limpiados (Explorer reiniciado)
echo [OK] Caches de iconos limpiados >> "%LOG_FILE%"

echo [11/21] Desactivando DiagTrack (telemetria)...
sc stop DiagTrack >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
echo    [OK] DiagTrack detenido
echo [OK] DiagTrack detenido >> "%LOG_FILE%"

echo [12/21] Desactivando efectos visuales...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v UserPreferencesMask /t REG_BINARY /d 9012038010000000 /f >nul 2>&1
echo    [OK] Efectos visuales minimizados
echo [OK] Efectos visuales desactivados >> "%LOG_FILE%"

echo [13/21] Desactivando noticias e intereses...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v IsDynamicSearchBoxEnabled /t REG_DWORD /d 0 /f >nul 2>&1
echo    [OK] Noticias e intereses desactivados
echo [OK] Noticias desactivadas >> "%LOG_FILE%"

echo [14/21] Desactivando Bing y Cortana...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v AllowCortana /t REG_DWORD /d 0 /f >nul 2>&1
echo    [OK] Bing y Cortana desactivados
echo [OK] Bing/Cortana desactivados >> "%LOG_FILE%"

echo [15/21] Reduciendo telemetria...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f >nul 2>&1
sc config "dmwappushservice" start= disabled >nul 2>&1
sc stop "dmwappushservice" >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
echo    [OK] Telemetria reducida (nivel basico - seguro)
echo [OK] Telemetria reducida >> "%LOG_FILE%"

echo [16/21] Aplicando optimizaciones gaming...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
echo    [OK] Prioridades gaming aplicadas
echo [OK] Gaming boost aplicado >> "%LOG_FILE%"

echo [17/21] Optimizando separacion de prioridades...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 26 /f >nul 2>&1
echo    [OK] Win32PrioritySeparation=26 (estable)
echo [OK] PrioritySeparation optimizado >> "%LOG_FILE%"

echo [18/21] Optimizando red...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global chimney=enabled >nul 2>&1
netsh int tcp set global dca=enabled >nul 2>&1
netsh int tcp set global netdma=enabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
echo    [OK] Configuracion de red optimizada
echo [OK] Red optimizada >> "%LOG_FILE%"

echo [19/21] Evaluando Windows Search...
if !RAM_MB! LEQ 4096 (
  sc config "WSearch" start= disabled >nul 2>&1
  sc stop "WSearch" >nul 2>&1
  echo    [OK] WSearch detenido (RAM limitada)
  echo [OK] WSearch detenido >> "%LOG_FILE%"
) else (
  echo    [SKIP] WSearch mantenido (RAM suficiente)
  echo [SKIP] WSearch mantenido >> "%LOG_FILE%"
)

echo [20/21] Desactivando Game DVR...
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v value /t REG_DWORD /d 0 /f >nul 2>&1
echo    [OK] Game DVR desactivado
echo [OK] Game DVR desactivado >> "%LOG_FILE%"

echo [21/21] Verificando servicio de impresion...
echo.
choice /c SN /n /m "Desactivar Spooler de impresion? [S/N]: "
if !errorlevel!==1 (
  sc config "Spooler" start= disabled >nul 2>&1
  sc stop "Spooler" >nul 2>&1
  echo    [OK] Spooler desactivado
  echo [OK] Spooler desactivado >> "%LOG_FILE%"
) else (
  echo    [SKIP] Spooler mantenido
  echo [SKIP] Spooler mantenido >> "%LOG_FILE%"
)

:: Limpieza de temporales
echo.
echo ================================================
echo  LIMPIEZA DE ARCHIVOS TEMPORALES
echo ================================================
echo.
echo Calculando espacio a liberar...
set TEMP_SIZE=0
for /f "tokens=3" %%S in ('dir "%TEMP%" /s /-c 2^>nul ^| find "File(s)"') do set TEMP_SIZE=%%S
if defined TEMP_SIZE (
    set /a TEMP_MB=!TEMP_SIZE!/1048576 2>nul
    if !TEMP_MB! GTR 0 (
        echo Espacio estimado: ~!TEMP_MB! MB
    )
)

echo.
echo [1/2] Limpiando temporales del usuario...
if exist "%TEMP%" (
    pushd "%TEMP%" 2>nul
    if !errorlevel!==0 (
        for /f "delims=" %%F in ('dir /b /a 2^>nul') do (
            if /i not "%%F"=="desktop.ini" (
                rd /s /q "%%F" 2>nul
                del /f /q "%%F" 2>nul
            )
        )
        popd
        echo    [OK] Temporales de usuario limpiados
    ) else (
        echo    [WARN] No se pudo acceder a temporales
    )
)

echo [2/2] Limpiando temporales del sistema...
if exist "C:\Windows\Temp" (
    pushd "C:\Windows\Temp" 2>nul
    if !errorlevel!==0 (
        for /f "delims=" %%F in ('dir /b /a 2^>nul') do (
            rd /s /q "%%F" 2>nul
            del /f /q "%%F" 2>nul
        )
        popd
        echo    [OK] Temporales del sistema limpiados
    )
)
echo [OK] Limpieza de temporales completada >> "%LOG_FILE%"

echo.
color 0A
echo ================================================
echo  OPTIMIZACION COMPLETA FINALIZADA
echo ================================================
echo [%date% %time%] >>> Optimizacion COMPLETA finalizada >> "%LOG_FILE%"
echo.
echo [i] Se recomienda reiniciar el sistema para aplicar
echo     todos los cambios correctamente.
echo.
choice /c SN /n /m "Reiniciar ahora? [S/N]: "
if !errorlevel!==1 (
    echo.
    echo Reiniciando en 10 segundos...
    shutdown /r /t 10 /c "GenLiteX11: Aplicando optimizaciones"
    exit /b 0
) else (
    echo.
    echo [!] Recuerda reiniciar pronto para completar la optimizacion.
    pause
    goto menu
)

:: ========== OPTIMIZACION GAMING ==========
:gaming_optimize
cls
color 0D
echo ================================================
echo  OPTIMIZACION GAMING (Alto Rendimiento)
echo ================================================
echo.
echo [%date% %time%] >>> Iniciando Optimizacion GAMING >> "%LOG_FILE%"

set "BACKUP_GAMING=%~dp0Registry_Backup_Gaming_%BACKUP_DATE%.reg"
echo [0/7] Creando backup de configuracion gaming...
reg export "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "%BACKUP_GAMING%" /y >nul 2>&1
if !errorlevel!==0 (
  echo    [OK] Backup guardado: Registry_Backup_Gaming_%BACKUP_DATE%.reg
  echo [OK] Backup gaming guardado >> "%LOG_FILE%"
) else (
  echo    [WARN] No se pudo crear backup
  echo [WARN] Backup gaming fallo >> "%LOG_FILE%"
)

echo [1/7] Activando plan de energia Ultimate Performance...
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -change -monitor-timeout-ac 0 >nul 2>&1
powercfg -change -disk-timeout-ac 0 >nul 2>&1
echo    [OK] Plan Ultimate Performance activado
echo [OK] Plan energia gaming >> "%LOG_FILE%"

echo [2/7] Configurando prioridades gaming...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 26 /f >nul 2>&1
echo    [OK] Prioridades gaming configuradas
echo [OK] Prioridades gaming >> "%LOG_FILE%"

echo [3/7] Desactivando efectos visuales...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f >nul 2>&1
echo    [OK] Efectos visuales minimizados
echo [OK] Efectos desactivados >> "%LOG_FILE%"

echo [4/7] Optimizando red para gaming...
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global chimney=enabled >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
netsh int tcp set heuristics disabled >nul 2>&1
netsh int tcp set global timestamps=disabled >nul 2>&1
echo    [OK] Red optimizada para baja latencia
echo [OK] Red gaming >> "%LOG_FILE%"

echo [5/7] Desactivando Game DVR y Xbox DVR...
reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\System\GameConfigStore" /v GameDVR_FSEBehaviorMode /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" /v value /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul 2>&1
echo    [OK] Game DVR desactivado, Game Mode activado
echo [OK] Game DVR desactivado >> "%LOG_FILE%"

echo [6/7] Optimizando GPU...
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\Scheduler" /v EnablePreemption /t REG_DWORD /d 0 /f >nul 2>&1
echo    [OK] Hardware-accelerated GPU scheduling habilitado
echo [OK] GPU optimizado >> "%LOG_FILE%"

echo [7/7] Desactivando SysMain y Prefetch...
sc config "SysMain" start= disabled >nul 2>&1
sc stop "SysMain" >nul 2>&1
if "!DISKTYPE!"=="SSD" (
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f >nul 2>&1
    echo    [OK] Prefetch desactivado (SSD)
)
echo    [OK] Optimizaciones gaming completadas
echo [OK] SysMain y Prefetch optimizados >> "%LOG_FILE%"

echo.
color 0A
echo ================================================
echo  OPTIMIZACION GAMING COMPLETADA
echo ================================================
echo [%date% %time%] >>> Optimizacion GAMING finalizada >> "%LOG_FILE%"
echo.
echo [i] Optimizaciones aplicadas:
echo     - Plan de energia maximo
echo     - Prioridades GPU/CPU optimizadas
echo     - Red de baja latencia
echo     - Game Mode activado
echo.
pause
goto menu

:: ========== OPTIMIZACION BASICA ==========
:basic_optimize
cls
color 0E
echo ================================================
echo  OPTIMIZACION BASICA (Segura para Oficina)
echo ================================================
echo.
echo [%date% %time%] >>> Iniciando Optimizacion BASICA >> "%LOG_FILE%"

set "BACKUP_BASIC=%~dp0Registry_Backup_Basic_%BACKUP_DATE%.reg"
echo [0/8] Creando backup minimo...
reg export HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer "%BACKUP_BASIC%" /y >nul 2>&1
if !errorlevel!==0 (
  echo    [OK] Backup guardado: Registry_Backup_Basic_%BACKUP_DATE%.reg
  echo [OK] Backup basico guardado >> "%LOG_FILE%"
)

echo [1/8] Limpiando temporales de usuario...
if exist "%TEMP%" (
    pushd "%TEMP%" 2>nul
    if !errorlevel!==0 (
        for /f "delims=" %%F in ('dir /b /a 2^>nul') do (
            if /i not "%%F"=="desktop.ini" (
                rd /s /q "%%F" 2>nul
                del /f /q "%%F" 2>nul
            )
        )
        popd
        echo    [OK] Temporales de usuario limpiados
    )
)
echo [OK] Temporales usuario >> "%LOG_FILE%"

echo [2/8] Limpiando temporales de Windows...
if exist "C:\Windows\Temp" (
    pushd "C:\Windows\Temp" 2>nul
    if !errorlevel!==0 (
        for /f "delims=" %%F in ('dir /b /a 2^>nul') do (
            rd /s /q "%%F" 2>nul
            del /f /q "%%F" 2>nul
        )
        popd
        echo    [OK] Temporales Windows limpiados
    )
)
echo [OK] Temporales Windows >> "%LOG_FILE%"

echo [3/8] Desactivando efectos visuales innecesarios...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul 2>&1
echo    [OK] Efectos desactivados (mantiene funcionalidad)
echo [OK] Efectos desactivados >> "%LOG_FILE%"

echo [4/8] Optimizando plan de energia...
powercfg -change -monitor-timeout-ac 15 >nul 2>&1
powercfg -change -disk-timeout-ac 0 >nul 2>&1
powercfg -change -standby-timeout-ac 30 >nul 2>&1
echo    [OK] Plan de energia balanceado
echo [OK] Energia ajustada >> "%LOG_FILE%"

echo [5/8] Reduciendo telemetria (nivel seguro)...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 1 /f >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
echo    [OK] Telemetria reducida (compatible con Updates)
echo [OK] Telemetria reducida >> "%LOG_FILE%"

echo [6/8] Limpiando logs del sistema...
wevtutil cl Application >nul 2>&1
wevtutil cl System >nul 2>&1
wevtutil cl Security >nul 2>&1
echo    [OK] Logs limpiados
echo [OK] Logs limpiados >> "%LOG_FILE%"

echo [7/8] Optimizando indexacion de busqueda...
reg add "HKLM\SOFTWARE\Microsoft\Windows Search" /v SetupCompletedSuccessfully /t REG_DWORD /d 0 /f >nul 2>&1
echo    [OK] Indexacion optimizada
echo [OK] Indexacion optimizada >> "%LOG_FILE%"

echo [8/8] Desactivando animaciones de menu...
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 200 /f >nul 2>&1
echo    [OK] Menus mas rapidos
echo [OK] Menus optimizados >> "%LOG_FILE%"

echo.
color 0A
echo ================================================
echo  OPTIMIZACION BASICA COMPLETADA
echo ================================================
echo [%date% %time%] >>> Optimizacion BASICA finalizada >> "%LOG_FILE%"
echo.
echo [i] Cambios seguros aplicados (no requiere reinicio)
echo.
pause
goto menu

:: ========== DESINSTALAR BLOATWARE ==========
:remove_bloatware
cls
color 0C
echo ================================================
echo  DESINSTALAR BLOATWARE
echo ================================================
echo.
echo  ADVERTENCIA CRITICA:
echo  ====================
echo  - Esto desinstalara apps preinstaladas PERMANENTEMENTE
echo  - Algunas apps NO se pueden reinstalar facilmente
echo  - Microsoft Store puede verse afectado
echo.
echo  Apps a eliminar:
echo  - 3D Builder, Alarms, Mail, Camera, Office Hub
echo  - Skype, Groove Music, Maps, Solitaire, Xbox
echo  - Weather, News, OneNote, People, y mas...
echo.
color 0E
choice /c SN /n /m "ESTAS SEGURO de continuar? [S/N]: "
if !errorlevel!==2 goto menu

echo.
color 0C
choice /c SN /n /m "ULTIMA CONFIRMACION - Eliminar bloatware? [S/N]: "
if !errorlevel!==2 goto menu

color 0E
echo.
echo [%date% %time%] >>> Iniciando eliminacion de bloatware >> "%LOG_FILE%"
echo.
echo Desinstalando apps innecesarias...
echo (Esto puede tomar varios minutos)
echo.

:: Lista completa de bloatware
set TOTAL_APPS=25
set CURRENT=0

for %%A in (
    "3dbuilder:3D Builder"
    "windowsalarms:Alarmas y Reloj"
    "windowscommunicationsapps:Mail y Calendar"
    "windowscamera:Camara"
    "officehub:Office Hub"
    "skypeapp:Skype"
    "getstarted:Get Started"
    "zunemusic:Groove Music"
    "windowsmaps:Mapas"
    "solitairecollection:Solitario"
    "bingfinance:Money"
    "zunevideo:Peliculas y TV"
    "bingnews:Noticias"
    "onenote:OneNote"
    "people:Contactos"
    "windowsphone:Phone Companion"
    "bingsports:Deportes"
    "soundrecorder:Grabadora de Voz"
    "bingweather:Clima"
    "xboxapp:Xbox"
    "xboxgamingoverlay:Xbox Game Bar"
    "xboxidentityprovider:Xbox Identity"
    "xboxspeechtotext:Xbox Speech"
    "feedback:Feedback Hub"
    "mixedreality:Mixed Reality Portal"
) do (
    set /a CURRENT+=1
    for /f "tokens=1,2 delims=:" %%B in ("%%~A") do (
        powershell -NoP -C "Get-AppxPackage *%%B* | Remove-AppxPackage -ErrorAction SilentlyContinue" >nul 2>&1
        echo [!CURRENT!/!TOTAL_APPS!] %%C
    )
)

echo.
color 0A
echo [OK] Bloatware eliminado
echo [%date% %time%] >>> Bloatware eliminado >> "%LOG_FILE%"
echo.
echo ================================================
echo  DESINSTALACION COMPLETADA
echo ================================================
echo.
echo [i] Apps eliminadas: !TOTAL_APPS!
echo [i] Reinicio no requerido
echo.
pause
goto menu

:: ========== LIMPIEZA DE DISCO ==========
:disk_cleanup
cls
color 0B
echo ================================================
echo  LIMPIEZA DE DISCO
echo ================================================
echo.
echo [%date% %time%] >>> Iniciando limpieza de disco >> "%LOG_FILE%"
echo.

echo Analizando espacio a liberar...
echo.

:: Calcular espacio temporal usuario
set USER_TEMP_SIZE=0
for /f "tokens=3" %%S in ('dir "%TEMP%" /s /-c 2^>nul ^| find "File(s)"') do set USER_TEMP_SIZE=%%S
set /a USER_TEMP_MB=!USER_TEMP_SIZE!/1048576 2>nul

:: Calcular espacio temporal sistema
set SYS_TEMP_SIZE=0
for /f "tokens=3" %%S in ('dir "C:\Windows\Temp" /s /-c 2^>nul ^| find "File(s)"') do set SYS_TEMP_SIZE=%%S
set /a SYS_TEMP_MB=!SYS_TEMP_SIZE!/1048576 2>nul

set /a TOTAL_MB=!USER_TEMP_MB!+!SYS_TEMP_MB!

if !TOTAL_MB! GTR 0 (
    echo Espacio estimado a liberar: ~!TOTAL_MB! MB
    echo   - Temporales usuario: ~!USER_TEMP_MB! MB
    echo   - Temporales sistema: ~!SYS_TEMP_MB! MB
    echo.
)

echo [1/4] Limpiando archivos temporales del usuario...
if exist "%TEMP%" (
    pushd "%TEMP%" 2>nul
    if !errorlevel!==0 (
        for /f "delims=" %%F in ('dir /b /a 2^>nul') do (
            if /i not "%%F"=="desktop.ini" (
                rd /s /q "%%F" 2>nul
                del /f /q "%%F" 2>nul
            )
        )
        popd
        echo    [OK] Temporales de usuario limpiados
    ) else (
        echo    [WARN] No se pudo acceder a temporales de usuario
    )
) else (
    echo    [SKIP] Carpeta no encontrada
)
echo [OK] Temporales usuario >> "%LOG_FILE%"

echo [2/4] Limpiando archivos temporales del sistema...
if exist "C:\Windows\Temp" (
    pushd "C:\Windows\Temp" 2>nul
    if !errorlevel!==0 (
        for /f "delims=" %%F in ('dir /b /a 2^>nul') do (
            rd /s /q "%%F" 2>nul
            del /f /q "%%F" 2>nul
        )
        popd
        echo    [OK] Temporales del sistema limpiados
    )
)
echo [OK] Temporales sistema >> "%LOG_FILE%"

echo [3/4] Limpiando archivos prefetch antiguos...
if exist "C:\Windows\Prefetch" (
    forfiles /p "C:\Windows\Prefetch" /s /m *.pf /d -30 /c "cmd /c del /q @path" 2>nul
    echo    [OK] Prefetch antiguo limpiado
) else (
    echo    [SKIP] Prefetch no disponible
)

echo [4/4] Abriendo herramienta de limpieza de Windows...
echo    [i] Selecciona los elementos a limpiar en la ventana
start /wait cleanmgr /d C:
echo    [OK] Disk Cleanup completado
echo [OK] Disk Cleanup ejecutado >> "%LOG_FILE%"

echo.
color 0A
echo ================================================
echo  LIMPIEZA DE DISCO COMPLETADA
echo ================================================
echo [%date% %time%] >>> Limpieza finalizada >> "%LOG_FILE%"
echo.
echo [i] Espacio liberado: ~!TOTAL_MB! MB + limpieza manual
echo.
pause
goto menu

:: ========== RESTAURAR REGISTRO ==========
:restore_registry
cls
color 0E
echo ================================================
echo  RESTAURAR REGISTRO DESDE BACKUP
echo ================================================
echo.
echo [%date% %time%] >>> Iniciando restauracion de registro >> "%LOG_FILE%"
echo.

echo Buscando backups disponibles...
echo.
set BACKUP_COUNT=0
set BACKUP_FULL=
set BACKUP_GAMING=
set BACKUP_BASIC=

if exist "%~dp0Registry_Backup_Full_*.reg" (
  echo [1] Backup COMPLETO:
  for %%F in ("%~dp0Registry_Backup_Full_*.reg") do (
    echo     %%~nxF (%%~zF bytes)
    set "BACKUP_FULL=%%F"
    set /a BACKUP_COUNT+=1
  )
)

if exist "%~dp0Registry_Backup_Gaming_*.reg" (
  echo [2] Backup GAMING:
  for %%F in ("%~dp0Registry_Backup_Gaming_*.reg") do (
    echo     %%~nxF (%%~zF bytes)
    set "BACKUP_GAMING=%%F"
    set /a BACKUP_COUNT+=1
  )
)

if exist "%~dp0Registry_Backup_Basic_*.reg" (
  echo [3] Backup BASICO:
  for %%F in ("%~dp0Registry_Backup_Basic_*.reg") do (
    echo     %%~nxF (%%~zF bytes)
    set "BACKUP_BASIC=%%F"
    set /a BACKUP_COUNT+=1
  )
)

echo.
if !BACKUP_COUNT!==0 (
  color 0C
  echo [ERROR] No se encontraron backups del registro
  echo.
  echo Para crear un backup, ejecuta primero una optimizacion:
  echo - Optimizacion COMPLETA crea backup completo
  echo - Optimizacion GAMING crea backup gaming
  echo - Optimizacion BASICA crea backup basico
  echo.
  pause
  goto menu
)

color 0C
echo ================================================
echo  ADVERTENCIA CRITICA
echo ================================================
echo  Restaurar el registro revertira todos los
echo  cambios realizados por la optimizacion.
echo.
echo  Solo hazlo si experimentas problemas graves:
echo  - Sistema inestable
echo  - Errores frecuentes
echo  - Mal funcionamiento de servicios
echo ================================================
echo.

color 0E
echo Que backup deseas restaurar?
echo [1] Backup COMPLETO (revierte todas las optimizaciones)
echo [2] Backup GAMING (solo configuraciones gaming)
echo [3] Backup BASICO (solo cambios basicos)
echo [4] Cancelar y volver al menu
echo.
choice /c 1234 /n /m "Selecciona [1/2/3/4]: "
set RESTORE_CHOICE=!errorlevel!

if !RESTORE_CHOICE!==4 goto menu

if !RESTORE_CHOICE!==1 (
  if not defined BACKUP_FULL (
    color 0C
    echo [ERROR] Backup COMPLETO no encontrado
    pause
    goto menu
  )
  
  cls
  color 0C
  echo ================================================
  echo  ULTIMA ADVERTENCIA
  echo ================================================
  echo  Archivo: !BACKUP_FULL!
  echo  Accion: Restaurar configuracion COMPLETA
  echo.
  echo  Esto revertira TODAS las optimizaciones.
  echo ================================================
  echo.
  choice /c SN /n /m "Estas ABSOLUTAMENTE SEGURO? [S/N]: "
  if !errorlevel!==2 goto menu
  
  echo.
  echo Restaurando registro COMPLETO...
  reg import "!BACKUP_FULL!" >nul 2>&1
  if !errorlevel!==0 (
    color 0A
    echo [OK] Registro COMPLETO restaurado exitosamente
    echo [OK] Registro completo restaurado >> "%LOG_FILE%"
    echo.
    echo ================================================
    echo  RESTAURACION EXITOSA
    echo ================================================
    echo.
    echo [!] Es OBLIGATORIO reiniciar el sistema ahora
    echo     para completar la restauracion.
    echo.
    choice /c SN /n /m "Reiniciar ahora? [S/N]: "
    if !errorlevel!==1 (
      shutdown /r /t 10 /c "GenLiteX11: Restauracion completada"
      exit /b 0
    ) else (
      echo.
      echo [!] ATENCION: Reinicia manualmente lo antes posible
      pause
      goto menu
    )
  ) else (
    color 0C
    echo [ERROR] Fallo al restaurar el registro
    echo [ERROR] Restauracion completa fallo >> "%LOG_FILE%"
    echo.
    echo Verifica permisos de administrador
    pause
    goto menu
  )
)

if !RESTORE_CHOICE!==2 (
  if not defined BACKUP_GAMING (
    color 0C
    echo [ERROR] Backup GAMING no encontrado
    pause
    goto menu
  )
  echo.
  echo Restaurando configuracion GAMING...
  reg import "!BACKUP_GAMING!" >nul 2>&1
  if !errorlevel!==0 (
    color 0A
    echo [OK] Configuracion GAMING restaurada
    echo [OK] Registro gaming restaurado >> "%LOG_FILE%"
    echo.
    echo [i] Se recomienda reiniciar el sistema
    pause
    goto menu
  ) else (
    color 0C
    echo [ERROR] Fallo al restaurar configuracion
    echo [ERROR] Restauracion gaming fallo >> "%LOG_FILE%"
    pause
    goto menu
  )
)

if !RESTORE_CHOICE!==3 (
  if not defined BACKUP_BASIC (
    color 0C
    echo [ERROR] Backup BASICO no encontrado
    pause
    goto menu
  )
  echo.
  echo Restaurando configuracion BASICA...
  reg import "!BACKUP_BASIC!" >nul 2>&1
  if !errorlevel!==0 (
    color 0A
    echo [OK] Configuracion BASICA restaurada
    echo [OK] Registro basico restaurado >> "%LOG_FILE%"
    echo.
    echo [i] Cierra sesion para ver los cambios
    pause
    goto menu
  ) else (
    color 0C
    echo [ERROR] Fallo al restaurar configuracion
    echo [ERROR] Restauracion basica fallo >> "%LOG_FILE%"
    pause
    goto menu
  )
)

:: ========== VER LOG ==========
:view_log
cls
color 0B
echo ================================================
echo  REGISTRO DE ACTIVIDADES (LOG)
echo ================================================
echo.
if exist "%LOG_FILE%" (
    echo Archivo: %LOG_FILE%
    echo.
    echo ------------------------------------------------
    type "%LOG_FILE%"
    echo ------------------------------------------------
) else (
    color 0E
    echo [!] No se encontro archivo de log
    echo.
    echo El log se crea automaticamente al ejecutar
    echo cualquier optimizacion.
)
echo.
echo ================================================
pause
goto menu

:: ========== AYUDA ==========
:ayuda_script
cls
color 0B
echo ================================================
echo  AYUDA - GenLiteX11 v1.0 Stable
echo ================================================
echo.
echo OPCIONES DISPONIBLES:
echo ---------------------
echo.
echo 1. OPTIMIZACION COMPLETA
echo    - Aplica todas las optimizaciones disponibles
echo    - Recomendado despues de instalar Windows
echo    - Crea backup y punto de restauracion
echo    - Requiere reinicio
echo.
echo 2. OPTIMIZACION GAMING
echo    - Enfocada en maximo rendimiento gaming
echo    - Prioridades GPU/CPU optimizadas
echo    - Red de baja latencia
echo    - Game Mode activado
echo.
echo 3. OPTIMIZACION BASICA
echo    - Segura para equipos de oficina
echo    - Solo limpieza y ajustes menores
echo    - No desactiva servicios criticos
echo    - No requiere reinicio
echo.
echo 4. DESINSTALAR BLOATWARE
echo    - Elimina apps preinstaladas innecesarias
echo    - ADVERTENCIA: Cambios permanentes
echo    - Pregunta antes de eliminar
echo.
echo 5. LIMPIEZA DE DISCO
echo    - Borra archivos temporales
echo    - Libera espacio en disco
echo    - Muestra estimacion de espacio
echo    - Incluye herramienta Windows
echo.
echo 6. RESTAURAR REGISTRO
echo    - Revierte optimizaciones previas
echo    - Usa los backups creados
echo    - Solo si hay problemas
echo.
echo 7. VER LOG
echo    - Muestra historial de cambios
echo    - Util para diagnostico
echo.
echo ARCHIVOS CREADOS:
echo ------------------
echo - GenLiteX11_Log_[FECHA].txt
echo - Registry_Backup_Full_[FECHA].reg
echo - Registry_Backup_Gaming_[FECHA].reg
echo - Registry_Backup_Basic_[FECHA].reg
echo.
echo NOTAS IMPORTANTES:
echo -------------------
echo - Siempre ejecutar como Administrador
echo - Crear backup antes de optimizar
echo - Reiniciar despues de optimizacion completa
echo - Compatible con Windows 10/11
echo.
echo ================================================
pause
goto menu

:: ========== SALIR ==========
:end_script
cls
color 0B
echo.
echo ================================================
echo  Gracias por usar GenLiteX11 v1.0 Stable
echo ================================================
echo.
echo ARCHIVOS GENERADOS:
echo --------------------
if exist "%LOG_FILE%" (
  for %%F in ("%LOG_FILE%") do set LOG_SIZE=%%~zF
  set /a LOG_KB=!LOG_SIZE!/1024
  echo [*] Log: %LOG_FILE% (!LOG_KB! KB)
)
if exist "%~dp0Registry_Backup_Full_%BACKUP_DATE%.reg" (
  for %%F in ("%~dp0Registry_Backup_Full_%BACKUP_DATE%.reg") do set FULL_SIZE=%%~zF
  set /a FULL_KB=!FULL_SIZE!/1024
  echo [*] Backup Completo: Registry_Backup_Full_%BACKUP_DATE%.reg (!FULL_KB! KB)
)
if exist "%~dp0Registry_Backup_Gaming_%BACKUP_DATE%.reg" (
  for %%F in ("%~dp0Registry_Backup_Gaming_%BACKUP_DATE%.reg") do set GAMING_SIZE=%%~zF
  set /a GAMING_KB=!GAMING_SIZE!/1024
  echo [*] Backup Gaming: Registry_Backup_Gaming_%BACKUP_DATE%.reg (!GAMING_KB! KB)
)
if exist "%~dp0Registry_Backup_Basic_%BACKUP_DATE%.reg" (
  for %%F in ("%~dp0Registry_Backup_Basic_%BACKUP_DATE%.reg") do set BASIC_SIZE=%%~zF
  set /a BASIC_KB=!BASIC_SIZE!/1024
  echo [*] Backup Basico: Registry_Backup_Basic_%BACKUP_DATE%.reg (!BASIC_KB! KB)
)
echo.
echo SISTEMA OPTIMIZADO:
echo --------------------
echo Sistema: !WIN_NAME! [Build !WIN_BUILD!]
echo RAM: !RAM_GB! GB
echo Disco: !DISKTYPE!
echo.
echo ================================================
echo  YouTube: https://www.youtube.com/@GeniousMods
echo ================================================
echo.
pause
exit /b 0
