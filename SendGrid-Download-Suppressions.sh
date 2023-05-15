#!/bin/bash

# Script para coletar infos do SendGrid e tratar os dados (blocs/bouces/invalid/spam). Baseado nessa lista pode ser alimentado outro ambiente para não enviar para esses e-mails.
# Criar API com as devidas permissões.


DATA=$(date +%d-%-m-%Y)
ARQUIVO_LOG="/var/log/sendgrid.log"
TEMP_DIR="/tmp"
API_KEY="Bearer MYAPIKEY"
SENDGRID_SITE="https://api.sendgrid.com/v3" ##Validar versão da API (homologado com a v3)

#Download das listas do SendGrid, pode ser incluido outras listas
download_json(){
        echo -e "$DATA - Iniciando Download dos arquivo JSON" >> $ARQUIVO_LOG

        CURL_BLOCKS=$(curl --fail -X "GET" "$SENDGRID_SITE/suppression/blocks" -H "Authorization: $API_KEY" > "$TEMP_DIR/suppression_blocks.json")
        EC_CURL_BLOCKS=$(echo $?)
        CURL_BOUNCES=$(curl --fail -X "GET" "$SENDGRID_SITE/suppression/bounces" -H "Authorization: $API_KEY" > "$TEMP_DIR/suppression_bounces.json")
        EC_CURL_BOUNCES=$(echo $?)
        CURL_INVALID_EMAILS=$(curl --fail -X "GET" "$SENDGRID_SITE/suppression/invalid_emails" -H "Authorization: $API_KEY" > "$TEMP_DIR/suppression_invalid_emails.json")
        EC_CURL_INVALID_EMAILS=$(echo $?)
        CURL_SPAM_REPORTS=$(curl --fail -X "GET" "$SENDGRID_SITE/suppression/spam_reports" -H "Authorization: $API_KEY" > "$TEMP_DIR/suppression_spam_reports.json")
        EC_CURL_SPAM_REPORTS=$(echo $?)

### Pode colocar um ELSE para tratar o ERRO.
  
    if [ $EC_CURL_BLOCKS -eq 0 ] && [ $EC_CURL_BOUNCES -eq 0 ] && [ $EC_CURL_INVALID_EMAILS -eq 0 ] && [ $EC_CURL_SPAM_REPORTS -eq 0 ]; then
        echo -e "$DATA - Todos os Download foram realizados com sucesso" >> $ARQUIVO_LOG
    fi
}

# Conversão de Json para TXT
    converte_json_txt(){
        echo -e "$DATA - Iniciando conversão dos arquivos JSON -> CSV" >> $ARQUIVO_LOG

        CAT_BLOCKS=$(cat "$TEMP_DIR/suppression_blocks.json" | tr -s ',' '\n' |tr -d "{}[]'" | grep '"email"' | tr -d "'" | cut -d':' -f2 | uniq | tr -d '"' > "$TEMP_DIR/suppression_blocks.txt")
        EC_CAT_BLOCKS=$(echo $?)
        
        
        CAT_BOUNCES=$(cat "$TEMP_DIR/suppression_bounces.json" | tr -s ',' '\n' |tr -d "{}[]'" | grep '"email"' | tr -d "'" | cut -d':' -f2 | uniq | tr -d '"' > "$TEMP_DIR/suppression_bounces.txt")
        EC_CAT_BOUNCES=$(echo $?)

        CAT_INVALID_EMAILS=$(cat "$TEMP_DIR/suppression_invalid_emails.json" | tr -s ',' '\n' |tr -d "{}[]'" | grep '"email"' | tr -d "'" | cut -d':' -f2 | uniq | tr -d '"' > "$TEMP_DIR/suppression_invalid_emails.txt")
        EC_CAT_INVALID_EMAILS=$(echo $?)

        CAT_SPAM_REPORTS=$(cat "$TEMP_DIR/suppression_spam_reports.json" | tr -s ',' '\n' |tr -d "{}[]'" | grep '"email"' | tr -d "'" | cut -d':' -f2 | uniq | tr -d '"' > "$TEMP_DIR/suppression_spam_reports.txt")
        EC_CAT_SPAM_REPORTS=$(echo $?)
		
### Pode colocar um ELSE para tratar o ERRO.  
  
    if [ $EC_JQ_BLOCKS -eq 0 ] && [ $EC_JQ_BOUNCES -eq 0 ] && [ $EC_JQ_INVALID_EMAILS -eq 0 ] && [ $EC_JQ_SPAM_REPORTS -eq 0 ]; then
        echo -e "$DATA - Conversões foram realizados com sucesso" >> $ARQUIVO_LOG
	fi
}
        
limpeza(){
### Limpeza teporarios Servidor
        rm -f $TEMP_DIR/*
### Limpeza das listas SendGrid (Site) - Validar permissões da  API
        CURL_DELETE_BLOCKS=$(curl --fail -X DELETE --url "$SENDGRID_SITE/suppression/blocks" -H "Authorization: $API_KEY" -H "content-type: application/json" -d '{"delete_all":true}')
        EC_CURL_DELETE_BLOCKS=$(echo $?)
        CURL_DELETE_BOUNCES=$(curl --fail -X DELETE --url "$SENDGRID_SITE/suppression/bounces" -H "Authorization: $API_KEY" -H "content-type: application/json" -d '{"delete_all":true}')
        EC_CURL_DELETE_BOUNCES=$(echo $?)
        CURL_DELETE_INVALID_EMAILS=$(curl --fail -X DELETE --url "$SENDGRID_SITE/suppression/invalid_emails" -H "Authorization: $API_KEY" -H "content-type: application/json" -d '{"delete_all":true}')
        EC_CURL_DELETE_INVALID_EMAILS=$(echo $?)
        CURL_DELETE_SPAM_REPORTS=$(curl --fail -X DELETE --url "$SENDGRID_SITE/suppression/spam_reports" -H "Authorization: $API_KEY" -H "content-type: application/json" -d '{"delete_all":true}')
        EC_CURL_DELETE_SPAM_REPORTS=$(echo $?)

### Pode colocar um ELSE para tratar o ERRO.
    
    if [ $EC_CURL_DELETE_BLOCKS -eq 0 ] && [ $EC_CURL_DELETE_BOUNCES -eq 0 ] && [ $EC_CURL_DELETE_INVALID_EMAILS -eq 0 ] && [ $EC_CURL_DELETE_SPAM_REPORTS -eq 0 ]; then
        echo -e "$DATA - Todos os Download foram realizados com sucesso" >> $ARQUIVO_LOG
    fi 

}

main(){
        download_json
        converte_json_txt
        limpeza
}
main
