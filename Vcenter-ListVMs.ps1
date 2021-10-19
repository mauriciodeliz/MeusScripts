add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy


$CREDENTIAL = Get-Credential
$AUTH = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($CREDENTIAL.UserName+':'+$CREDENTIAL.GetNetworkCredential().Password))
$HEAD = @{
  'Authorization' = "Basic $AUTH"
}
$REQUEST = Invoke-WebRequest -Uri "https://FQDN-MYVCENTER/rest/com/vmware/cis/session" -Method Post -Headers $HEAD
$TOKEN = (ConvertFrom-Json $REQUEST.Content).value
$SESSION = @{'vmware-api-session-id' = $TOKEN}

$REQUEST1 = Invoke-WebRequest -Uri "https://FQDN-MYVCENTER/rest/vcenter/vm" -Method Get -Headers $SESSION
$LIST_VMS = (ConvertFrom-Json $REQUEST1.Content).value
$LIST_VMS
$LIST_VMS.Count
