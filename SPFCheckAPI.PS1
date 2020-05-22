#Work in progress
#does not work with child domains, ex mydomain.domain.com
#Script will pull results from Get-msoldomain, query each domain against securitytrails api to reteive txt results. Limited to 50 queries a month. 


$csv = Get-MsolDomain

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

$headers.Add("apikey", "<ENTER KEY>")

$csv | ForEach-Object {
    $Domain = $_.Name
    $url = "https://api.securitytrails.com/v1/domain/"+$domain
    
    $response = Invoke-RestMethod -uri $url -Method 'GET' -Headers $headers

    $txtvalues = $response.current_dns.txt.values
    
    ForEach($i in $txtvalues ){
        $i | Add-Member -NotePropertyName DomainName -NotePropertyValue $response.hostname
        $i | Export-csv <ENTER LOCATION>  -Append -NoTypeInformation
    }

}
