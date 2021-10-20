rem Teste de resoluçao de DNS
rem Utilzado para analise de DNS VIA Windows
rem DNS.TXT é salvo no diretório

:loop
ping 127.0.0.1 -n 10 > nul
@echo. >> DNS.txt
echo Hora da consulta: %date:~0,2%-%date:~3,2%-%date:~-4% - Hora: %time:~0,8% >> DNS.txt
nslookup google.com.br 208.67.220.220 >> DNS.txt
@echo. >> DNS.txt
ping -n 
goto loop
