#!/bin/bash
LOGS="/tmp/infos.log"
USER_VCENTER="USER"
PASSWD_VCENTER="PASSWORD"
FQDN_VCENTER="https://FQDN-MY-VCNTER"
TEMP_DIR="/tmp"
HOSTS_LIST="$TEMP_DIR/hosts.txt"
VMS_LIST="$TEMP_DIR/vms.txt"


autentica_vcenter(){
        echo "$(date +%Y%m%d%H%M%S) - Autenticando no Vcenter" >> $LOGS
        curl -sik -X POST "$FQDN_VCENTER/rest/com/vmware/cis/session" -u "$USER_VCENTER":"$PASSWD_VCENTER" > $TEMP_DIR/session-id
        SESSION_ID=$(tac $TEMP_DIR/session-id | head -n1 | cut -d":" -f2 | tr -d '"[]{}' | tr -d '\r')
}

coleta_hosts(){
        echo "$(date +%Y%m%d%H%M%S) - Coletando infos no Vcenter" >> $LOGS
        curl -sik -X GET "$FQDN_VCENTER/rest/vcenter/host" -H "Accept: application/json" -H "vmware-api-session-id: $SESSION_ID" > $TEMP_DIR/hosts.json
        cat $TEMP_DIR/hosts.json | grep name | tr -d '{[],{}:' | tr '"' '\n'| grep host- > $TEMP_DIR/hosts.txt
}

coleta_vms(){
        echo "$(date +%Y%m%d%H%M%S) - Coletando VMs baseado na Lista de HOSTs" >> $LOGS        
for HOST_NAME in $(cat $HOSTS_LIST | uniq) ; do

        curl -sik -X GET "$FQDN_VCENTER/rest/vcenter/vm?filter.hosts=$HOST_NAME" -H "Accept: application/json" -H "vmware-api-session-id: $SESSION_ID" > $TEMP_DIR/$HOST_NAME-vms.json

done
}

## Nessa linha precisamos declarar o nome (interno) do ESXI e o nome visivel pelo Vcenter (linhas 37, 38, 39 e 40). Aumentar de acordo com o ambiente. Ficar atento as colunas, depende do diretório.
identifica_esxi(){
        echo "$(date +%Y%m%d%H%M%S) - Identificando VM por HOST" >> $LOGS      
       RESULT_GREP=$(grep -i $VMHOSTNAME $TEMP_DIR/*.json | cut -d"/" -f3 | cut -d"-" -f1,2)

    if [ $RESULT_GREP == "host-XXX" ] ; then
        HOST_ESXI_NAME="NAME_HOST_VCENTER"
    elif [ $RESULT_GREP == "host-XXX" ] ; then
        HOST_ESXI_NAME="NAME_HOST_VCENTER"
    fi

}

## Evidência de qual HOST a VM esta.
registra_log(){
echo "Estou no ESXI: $HOST_ESXI_NAME" >> $LOGS
}

main(){
    autentica_vcenter
    coleta_hosts
    coleta_vms
    identifica_esxi
    registra_log
}
main
