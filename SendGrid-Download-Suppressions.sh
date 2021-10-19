#!/bin/bash

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

# Conversão de Json para CSV
    converte_json_csv(){
        echo -e "$DATA - Iniciando conversão dos arquivos JSON -> CSV" >> $ARQUIVO_LOG

        JQ_BLOCKS=$(/usr/bin/jq -r 'map({status,reason,email,created}) | (first | keys_unsorted) as $keys | map([to_entries[] | .value]) as $rows | $keys,$rows[] | @csv' "$TEMP_DIR/suppression_blocks.json" > "$TEMP_DIR/suppression_blocks.csv")
        EC_JQ_BLOCKS=$(echo $?)
        
        JQ_BOUNCES=$(/usr/bin/jq -r 'map({status,reason,email,created}) | (first | keys_unsorted) as $keys | map([to_entries[] | .value]) as $rows | $keys,$rows[] | @csv' "$TEMP_DIR/suppression_bounces.json" > "$TEMP_DIR/suppression_bounces.csv")
        EC_JQ_BOUNCES=$(echo $?)

        JQ_INVALID_EMAILS=$(/usr/bin/jq -r 'map({reason,email,created}) | (first | keys_unsorted) as $keys | map([to_entries[] | .value]) as $rows | $keys,$rows[] | @csv' "$TEMP_DIR/suppression_invalid_emails.json" > "$TEMP_DIR/suppression_invalid_emails.csv")
        EC_JQ_INVALID_EMAILS=$(echo $?)

        JQ_SPAM_REPORTS=$(/usr/bin/jq -r 'map({ip,email,created}) | (first | keys_unsorted) as $keys | map([to_entries[] | .value]) as $rows | $keys,$rows[] | @csv' "$TEMP_DIR/suppression_spam_reports.json" > "$TEMP_DIR/suppression_spam_reports.csv")
        EC_JQ_SPAM_REPORTS=$(echo $?)
		
### Pode colocar um ELSE para tratar o ERRO.  
  
    if [ $EC_JQ_BLOCKS -eq 0 ] && [ $EC_JQ_BOUNCES -eq 0 ] && [ $EC_JQ_INVALID_EMAILS -eq 0 ] && [ $EC_JQ_SPAM_REPORTS -eq 0 ]; then
        echo -e "$DATA - Conversões foram realizados com sucesso" >> $ARQUIVO_LOG
	fi
}
        

# Gera a lista de emails (Suppression Blocks, Bounces, Invalid, Spam), com base nos arquivos CSV (Sendgrid)    
ajuste_arquivos_csv(){

        echo "$DATA - gerando a lista de emails (Suppression Blocks, Bounces, Invalid, Spam) com base nos arquivos CSV (Sendgrid)" >> $ARQUIVO_LOG

        grep -v 'status,reason,email,created' $TEMP_DIR/suppression_blocks.csv  | egrep ",[0-9]{10}" | grep @ | rev | cut -d',' -f2 | rev | tr -d '"' | sort > $TEMP_DIR/listasendgrid.txt
        grep -v 'status,reason,email,created' $TEMP_DIR/suppression_bounces.csv | egrep ",[0-9]{10}" | grep @ | rev | cut -d',' -f2 | rev | tr -d '"' | sort >> $TEMP_DIR/listasendgrid.txt
        grep -v 'reason,email,created' $TEMP_DIR/suppression_invalid_emails.csv | egrep ",[0-9]{10}" | grep @ | cut -d',' -f2 | tr -d '"' | sort >> $TEMP_DIR/listasendgrid.txt
        grep -v 'ip,email,created' $TEMP_DIR/suppression_spam_reports.csv | egrep ",[0-9]{10}" | grep @ | cut -d',' -f2 | tr -d '"' | sort >> $TEMP_DIR/listasendgrid.txt
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
        converte_json_csv
        ajuste_arquivos_csv
        limpeza
}
main
