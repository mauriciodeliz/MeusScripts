#!/bin/bash

# Apenas incluir a <APIKEY> para geração dos dados via JSON - APIKEY deve ser gerada no Portal da IBM
# Se desejar tratar via Shell, segue JQ <jq '.resources[] | {resource_id, billable_cost, non_billable_cost, plans} '>

ibmUrlIam="iam.cloud.ibm.com"
ibmUrlBilling="billing.cloud.ibm.com"
anoMes=$(date +'%Y-%m') #Ano-Mes corrente
authToken=$(curl -X POST "https://$ibmUrlIam/identity/token" -H 'Content-Type: application/x-www-form-urlencoded' -H 'Accept: application/json' -d 'grant_type=urn:ibm:params:oauth:grant-type:apikey' -d 'apikey=<APIKEY>' | cut -d'"' -f4)
curl -X GET -H "Authorization: Bearer "$authToken"" -H "Accept: application/json" "https://$ibmUrlBilling/v4/accounts/f9cd5461572c476188c88525587cad0c/usage/$anoMes"
