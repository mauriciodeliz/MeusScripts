rem Avalia se tem a instalação 32 Bits
rem Definir diretório compartilhado para copia dos arquivos e setup.

@echo off
SET DIR_INSTALACAO_x64="C:\Program Files\NSClient++\"
SET DIR_SCRIPTS="C:\Program Files\NSClient++\scripts\"

if not exist "C:\Program Files\NSClient++\NSClient++.exe" goto install
"C:\Program Files\NSClient++\NSClient++.exe" /stop
"C:\Program Files\NSClient++\NSClient++.exe" /uninstall
rmdir /s /q "C:\Program Files\NSClient++

:install
msiexec.exe /i "\\SHARED_FOLDER\NagiosClient\NSClient***.msi" /quiet
ping 1.1.1.1 -n 1 -w 10000
xcopy \\SHARED_FOLDER\NagiosClient\NSC.INI /y %DIR_INSTALACAO_x64%
xcopy \\SHARED_FOLDER\NagiosClient\check*.* %DIR_SCRIPTS%
net start "nsclient++ (x64)"
