#Work in progress
#does not work with child domains, ex mydomain.domain.com
#Script will pull results from Get-msoldomain, query each domain against securitytrails api to reteive txt results. Limited to 50 queries a month. 
#SecurityTrails API Header
#$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#$headers.Add("apikey", "<ENTER KEY>")

$csv = import-csv C:\users\mikeb\desktop\Book1.csv
$array = @()
$csv | ForEach-Object {
    $Domain = $_.Name
    $url = "https://api.exana.io/dns/"+$domain+"/txt"
    #SecurityTrails API call
    #$url = "https://api.securitytrails.com/v1/domain/"+$domain
    #$response = Invoke-RestMethod -uri $url -Method 'GET' -Headers $headers
    #$txtvalues = $response.current_dns.txt.values
    
    $response = Invoke-RestMethod -uri $url -Method 'GET'
    $txtvalues = $response.answer.rdata
    
       
    ForEach($obj in $txtvalues ){
       $txtrecord = $obj
       $txtrecord = $txtrecord.Trim('"')
       
        $obj = New-Object psobject
        
        $obj | Add-Member -MemberType NoteProperty -Name "DomainName" -Value $Domain
        $obj | Add-Member -MemberType NoteProperty -Name "TXT" -Value $txtrecord
        $array += $obj
    }
    
}
#$array 
$array | export-csv C:\Users\mikeb\Desktop\spf.csv
