#!/bin/sh

### https://softlayer-python.readthedocs.io/en/latest/cli/dns/#dns-zone-print
### Script para fazer DUMP com FOR de zonas de DNS na IBMCLOUD via CLI.
### Importante ter a API criada na IBM Cloud e o setup do CLI, conforme acima. Após configurado a credencial fica no .conf
### Estou considerando apenas o script básico, exportação da Zona e comparação
### Faz o "FOR" no caso de várias zonas


TIMESTAMP_FULL=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y-%m)
DAYOFMONTH=$(date +"%d")
YESTERDAY=$(date +"%d" -d"$arquivodia day ago")
DUMP_DIR="/tmp/export-dns"
LOGS="/tmp/export-dns/log-dns.txt"


backup_dns(){

		echo -e "($TIMESTAMP_FULL) - Iniciando o processo de Backup do DNS" >> $LOGS
		
		DNS_ZONES=$(slcli dns zone-list | awk '{print $2}'| tr -s ' '  '\n')
		    
  for DNS_ZONE in $DNS_ZONES; do
        /usr/bin/slcli dns zone-print $DNS_ZONE > "$DUMP_DIR""$DNS_ZONE-$TIMESTAMP-$DAYOFMONTH.txt"
        ECDUMPDNS=$(echo $?)
        DIFF_RESULT=$(diff -I "Serial" "$DUMP_DIR""$DNS_ZONE-$TIMESTAMP-$DAYOFMONTH.txt" "$DUMP_DIR""$DNS_ZONE-$TIMESTAMP-$YESTERDAY.txt")
    ECDIFF=$(echo $?)

    if [ $ECDIFF -ne 0 ]; then
        echo -e "($TIMESTAMP_FULL) - Diferença das entradas de DNS - Zona $DNS_ZONE\n" >> $LOGS
        echo -e "$DIFF_RESULT" >> $LOGS
        echo -e "\n($TIMESTAMP_FULL) - Fim da diferença das entradas de DNS - Zona $DNS_ZONE" >> $LOGS
    else
        echo -e "($TIMESTAMP_FULL) - Não encontrada diferença na Zona $DNS_ZONE" >> $LOGS
    fi
    done
}

main(){
    backup_dns
}
main
