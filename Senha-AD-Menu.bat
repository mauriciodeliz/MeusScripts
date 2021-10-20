rem Linha 18 alterar o DOMAIN exemplo: (CONTOSO)
rem Alterar a senha para senha desejada (Senha@123)
rem Usuário que vai executar deve ter permissão no Active Directory

@ECHO off

title Troca de Senhas Automatizada

set LOGIN=""
echo Entre com o LOGIN e pressione ENTER: 
set /p "LOGIN="

cls

Echo.
Echo.
Echo #### Usuario selecionado ####
Echo.
Echo.
dsquery user -samid %LOGIN% | dsget user |  find /i "DC=CONTOSO"
Echo.
Echo.

IF errorlevel=1 GOTO :ERRO
IF errorlevel=0 GOTO :OK

:OK
Echo.
Echo.
choice /C RV /M "O que deseja fazer ? Digite R p/ Reset e V p/ Visualizar"
Echo.
Echo.

IF errorlevel=3 goto :RESET
IF errorlevel=2 goto :VISUALIZAR

:RESET
dsquery user -samid %LOGIN% | dsmod user -pwd Senha@123 -mustchpwd yes
CLS
Echo.
Echo.
ECHO Aplicado reset de Senha, Senha: Senha@123 (Solicitado a troca no prox. Logon) chamado pode ser solucionado!!!
Echo.
Echo.
Echo Texto Default para solucao: 
Echo.
Echo Prezado Cliente, sua demanda foi atendida com sucesso.
Echo Segue nova senha,
Echo Senha: Senha@123
Echo Att,
Echo.
Echo.
PAUSE
GOTO :FINAL

:VISUALIZAR
CLS
Echo.
Echo.
dsquery user -samid %LOGIN% | dsget user -samid -display -desc -mustchpwd -pwdneverexpires -disabled
Echo.
Echo.

PAUSE

GOTO :FINAL

:ERRO
color fc
CLS
Echo.
Echo.
Echo.
Echo.
Echo "User nao encontrado, realizar consulta via DSA.MSC"
Echo.
Echo.
Echo.
Echo.
PAUSE
GOTO :FINAL

:FINAL
