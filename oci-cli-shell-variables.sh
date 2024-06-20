#!/bin/bash

#################################################################################
# Descricao : Script para listar o espaço consumido utilizando o OCI CLI, com passagem de parametros, pode usar para Zabbix e outros modelos
# Uso       : script parametro1<string> parametro2<string> parametro3<string> [parametro4<string>] [parametro5<string>] [parametro6<string>] [parametro7<string>] [parametro8<string>]
# Autor     : Nome Autor
# Versao    : 2024-01-01
##################################################################################

###<VARIAVEIS>###
param1=$1
param2=$2
param3=$3
param4=${4:-}
param5=${5:-}
param6=${6:-}
param7=${7:-}
param8=${8:-}
availability_domains=("ZxXC:US-ASHBURN-AD-1" "ZxXC:US-ASHBURN-AD-2" "ZxXC:US-ASHBURN-AD-3")
###</VARIAVEIS>##

###<FUNCOES>###
fun_oci_cli(){
    all_outputs=()
    for ad in "${availability_domains[@]}"; do
        oci_output=$(oci $param1 $param2 $param3 --availability-domain $ad $param4 $param5 $param6 $param7 $param8 2>/dev/null)
        
        # Process the output using sed to remove " (Boot Volume)" and extract data array with jq
        processed_output=$(echo "$oci_output" | sed 's/ (Boot Volume)//g' | jq '.data')
        
        all_outputs+=("$processed_output")
    done

    # Join all outputs into a single JSON array, removing trailing commas
    combined_output=$(printf '%s\n' "${all_outputs[@]}" | jq -s 'add')
    echo "{\"data\": ${combined_output}}"
}

main() {
    if [[ -z "$param1" || -z "$param2" || -z "$param3" ]]; then
        echo "Uso: $0 parametro1<string> parametro2<string> parametro3<string> [parametro4<string>] [parametro5<string>] [parametro6<string>] [parametro7<string>] [parametro8<string>]"
        exit 1
    fi

    fun_oci_cli
}
###</FUNCOES>##

###<ACOES>###
main
###</ACOES>##
