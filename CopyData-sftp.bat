rem https://isabelcastillo.com/winscp-script-upload-sync-local-directory-server
rem https://winscp.net/eng/docs/commandline#scripting
rem Script.bat para automações, utilizado para copiar dados (Origem -> Destino) 
rem Alterar a origem e destino na linha 20

Rem Limpeza de Logs
set _robodel=%TEMP%\~robodel
MD %_robodel%
start ROBOCOPY "C:\Program Files (x86)\WinSCP\Logs\" %_robodel% /move /minage:5
del /F "C:\Program Files (x86)\WinSCP\Logs\winscp-com.log"

cd \
cd "C:\Program Files (x86)\WinSCP\"
"WinSCP.com" /log="C:\Program Files (x86)\WinSCP\Logs\winscp-com.log" /loglevel=normal /logsize=5MB ^
 /command ^
	"open sftp://USER:PASSWORD@fqdnftp.com.br:9090" ^
	"option batch abort" ^
	"option confirm off" ^
	"option transfer binary" ^
	"synchronize local -delete C:\Temp\XML teste" ^
    "exit"
