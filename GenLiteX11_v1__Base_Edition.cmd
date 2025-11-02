@echo off
:: GenLiteX11 v1 - Full-Performance ENHANCED (Safe)
title GenLiteX11 v1 Enhanced - Optimizacion Windows 11 (Safe)

:: ---------- Verificar Administrador ----------
net session >nul 2>&1
if %errorlevel% neq 0 (
  echo ERROR: Ejecuta este script como Administrador.
  pause
  exit /b 1
)

:: ---------- Variables y Fecha Portable ----------
for /f "usebackq delims=" %%D in (`powershell -NoProfile -Command "(Get-Date).ToString('yyyyMMdd')"`) do set BACKUP_DATE=%%D
set "LOG_FILE=%~dp0GenLiteX11_Log_%BACKUP_DATE%.txt"
set "BACKUP_REG=%~dp0Registry_Backup_%BACKUP_DATE%.reg"

echo [%date% %time%] Iniciando GenLiteX11 v1 Enhanced (Safe) > "%LOG_FILE%"

:: ---------- Backup Registro ----------
echo Creando backup del registro...
reg export HKLM\SOFTWARE "%BACKUP_REG%" /y >nul 2>&1
if %errorlevel%==0 (
  echo [OK] Backup guardado: %BACKUP_REG% >> "%LOG_FILE%"
) else (
  echo [WARN] No se pudo exportar HKLM\SOFTWARE >> "%LOG_FILE%"
)

:: ---------- Info hardware ----------
for /f "usebackq tokens=*" %%R in (`powershell -NoProfile -Command "Get-ComputerInfo -Property CsTotalPhysicalMemory | Select -ExpandProperty CsTotalPhysicalMemory"`) do set RAM_BYTES=%%R
:: Convertir a MB (simple)
set /a RAM_MB=%RAM_BYTES:~0,-6%
if "%RAM_MB%"=="" set RAM_MB=0

for /f "usebackq tokens=*" %%D in (`powershell -NoProfile -Command "Get-PhysicalDisk | Select-Object -First 1 -ExpandProperty MediaType"`) do set DISKTYPE=%%D

echo RAM_MB=%RAM_MB% >> "%LOG_FILE%"
echo DISKTYPE=%DISKTYPE% >> "%LOG_FILE%"

:: ---------- MENU: por si quieres usar opciones ----------
:menu
cls
echo ===============================================
echo GenLiteX11 v1 Enhanced (Safe)
echo ===============================================
echo 1. Optimizacion COMPLETA (con protecciones)
echo 2. Optimizacion GAMING (segura)
echo 3. Optimizacion BASICA (segura, conservadora)
echo 4. DESINSTALAR Bloatware (pregunta antes)
echo 5. Ver LOG
echo 6. Salir
echo.
set /p opcion="Selecciona opcion [1-6]: "
if "%opcion%"=="1" goto full_optimize
if "%opcion%"=="2" goto gaming_optimize
if "%opcion%"=="3" goto basic_optimize
if "%opcion%"=="4" goto remove_bloatware
if "%opcion%"=="5" goto view_log
if "%opcion%"=="6" exit
goto menu

:: ---------- OPTIMIZACION COMPLETA (con protecciones) ----------
:full_optimize
cls
echo Iniciando Optimizacion COMPLETA (Safe)...
echo [%date% %time%] Iniciando Optimizacion COMPLETA >> "%LOG_FILE%"

:: Punto de restauracion (intenta; si falla, continua)
powershell -Command "try{Checkpoint-Computer -Description 'GenLiteX11_Full_Backup' -RestorePointType 'MODIFY_SETTINGS' -ErrorAction Stop; Write-Output 'OK'}catch{Write-Output 'FAIL'}" > "%~dp0._rp_tmp.txt" 2>&1
findstr /i "OK" "%~dp0._rp_tmp.txt" >nul 2>&1
if %errorlevel%==0 (
  echo [OK] Punto de restauracion creado >> "%LOG_FILE%"
) else (
  echo [WARN] No se pudo crear punto de restauracion >> "%LOG_FILE%"
)
del "%~dp0._rp_tmp.txt" >nul 2>&1

:: Energia - crear y activar Ultimate Performance si es aplicable
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61 >nul 2>&1
powercfg -change -monitor-timeout-ac 0 >nul 2>&1
powercfg -change -disk-timeout-ac 0 >nul 2>&1
powercfg -change -standby-timeout-ac 0 >nul 2>&1
echo [OK] Energia optimizada >> "%LOG_FILE%"

:: Hibernacion
powercfg -h off >nul 2>&1
echo [OK] Hibernacion desactivada >> "%LOG_FILE%"

:: Memoria y prefetch - aplicar solo si RAM_MB > 2048 (evitar bajas RAM cambios agresivos)
if %RAM_MB% GEQ 3072 (
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnablePrefetcher /t REG_DWORD /d 0 /f >nul 2>&1
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableSuperfetch /t REG_DWORD /d 0 /f >nul 2>&1
  echo [OK] Prefetch/Superfetch ajustado >> "%LOG_FILE%"
) else (
  echo [SKIP] Prefetch/Superfetch: maquina con RAM baja (%RAM_MB% MB) - saltado >> "%LOG_FILE%"
)

:: DisablePagingExecutive - NO aplicar en equipos con <=4096 MB
if %RAM_MB% GEQ 4096 (
  reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v DisablePagingExecutive /t REG_DWORD /d 1 /f >nul 2>&1
  echo [OK] DisablePagingExecutive activado >> "%LOG_FILE%"
) else (
  echo [SKIP] DisablePagingExecutive (riesgo en baja RAM) >> "%LOG_FILE%"
)

:: Desactivar SysMain (opcional)
sc config "SysMain" start= disabled >nul 2>&1
sc stop "SysMain" >nul 2>&1
echo [OK] SysMain intentado detener >> "%LOG_FILE%"

:: Efectos visuales (aplicar, seguro)
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul 2>&1
echo [OK] Efectos visuales desactivados >> "%LOG_FILE%"

:: Widgets y noticias
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarDa /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v ShellFeedsTaskbarViewMode /t REG_DWORD /d 2 /f >nul 2>&1
echo [OK] Widgets/panel ajustado >> "%LOG_FILE%"

:: Bing / Cortana
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v BingSearchEnabled /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v CortanaConsent /t REG_DWORD /d 0 /f >nul 2>&1
echo [OK] Bing/Cortana ajustes >> "%LOG_FILE%"

:: Telemetria - aplicar políticas (seguro en la mayoria)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" /v AllowTelemetry /t REG_DWORD /d 0 /f >nul 2>&1
sc config "DiagTrack" start= disabled >nul 2>&1
sc config "dmwappushservice" start= disabled >nul 2>&1
sc stop "DiagTrack" >nul 2>&1
sc stop "dmwappushservice" >nul 2>&1
echo [OK] Telemetria intentado deshabilitar >> "%LOG_FILE%"

:: Tareas programadas de telemetria (silenciosas si no existen)
schtasks /Change /TN "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\Customer Experience Improvement Program\Consolidator" /Disable >nul 2>&1
schtasks /Change /TN "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector" /Disable >nul 2>&1
echo [OK] Tareas de telemetria modificadas >> "%LOG_FILE%"

:: Gaming boost (aplicar, es estable)
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "GPU Priority" /t REG_DWORD /d 8 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >nul 2>&1
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 38 /f >nul 2>&1
echo [OK] Gaming boost aplicado >> "%LOG_FILE%"

:: Windows Defender: ajustes suaves (no desactivar por defecto)
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Scan" /v AvgCPULoadFactor /t REG_DWORD /d 10 /f >nul 2>&1
echo [OK] Defender ajustes leves >> "%LOG_FILE%"

:: Red: autotune y RSS (no forzar chimney)
netsh int tcp set global autotuninglevel=normal >nul 2>&1
netsh int tcp set global rss=enabled >nul 2>&1
echo [OK] Red optimizada (ajustes seguros) >> "%LOG_FILE%"

:: Windows Search: detener si RAM baja y SSD/HDD decision
if %RAM_MB% LEQ 2048 (
  sc config "WSearch" start= disabled >nul 2>&1
  sc stop "WSearch" >nul 2>&1
  echo [OK] WSearch detenido (maquina con RAM baja) >> "%LOG_FILE%"
) else (
  echo [SKIP] WSearch mantenido (RAM suficiente) >> "%LOG_FILE%"
)

:: Spooler: preguntar antes de deshabilitar (evitar romper al usuario)
echo.
echo Se detecto que podria desactivarse el servicio Spooler (impresion). Si no tienes impresoras instaladas, es seguro.
choice /m "Deseas desactivar Spooler (impresoras)?"
if %errorlevel%==1 (
  sc config "Spooler" start= disabled >nul 2>&1
  sc stop "Spooler" >nul 2>&1
  echo [OK] Spooler desactivado >> "%LOG_FILE%"
) else (
  echo [SKIP] Spooler mantenido >> "%LOG_FILE%"
)

:: Limpieza temporales (silenciosa)
del /f /s /q "%TEMP%\*.*" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*.*" >nul 2>&1
echo [OK] Temporales intentados eliminar >> "%LOG_FILE%"

:: Logs: limpiar Application y System (no Security por defecto)
wevtutil cl Application >nul 2>&1
wevtutil cl System >nul 2>&1
echo [OK] Logs Application/System limpiados >> "%LOG_FILE%"
echo [NOTE] Security log no fue limpiado por seguridad >> "%LOG_FILE%"

:: Limpieza de componentes: preguntar antes de ResetBase (irrevocable)
echo.
choice /m "Deseas ejecutar DISM /StartComponentCleanup /ResetBase (irreversible para desinstalar updates)?"
if %errorlevel%==1 (
  Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase >nul 2>&1
  echo [OK] DISM ResetBase ejecutado >> "%LOG_FILE%"
) else (
  echo [SKIP] DISM ResetBase omitido >> "%LOG_FILE%"
)

:: Optimizar disco: SSD vs HDD
if /i "%DISKTYPE%"=="SSD" (
  echo SSD detectado -> Ejecutando TRIM/Optimize...
  defrag C: /L /H /U >nul 2>&1
  echo [OK] TRIM/Optimize intentado >> "%LOG_FILE%"
) else (
  echo HDD detectado (o no detectado) -> Ejecutando defrag optimizado...
  defrag C: /O /H /U >nul 2>&1
  echo [OK] Defrag intentado >> "%LOG_FILE%"
)

:: Reinicio final (choice seguro)
echo.
choice /m "Reiniciar ahora para aplicar todos los cambios?"
if %errorlevel%==1 (
    echo Reiniciando en 10 segundos...
    shutdown /r /t 10
) else (
    echo.
    echo [!] Listo! Algunos cambios requieren reinicio. Se recomienda reiniciar pronto.
    pause
)

exit /b 0
