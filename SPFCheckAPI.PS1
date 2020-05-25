#Work in progress
#does not work with child domains, ex mydomain.domain.com
#Script will pull results from Get-msoldomain, query each domain against securitytrails api to reteive txt results. Limited to 50 queries a month. 
#SecurityTrails API Header
#$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
#$headers.Add("apikey", "<ENTER KEY>")

$csv = import-csv C:\users\mikeb\desktop\Book1.csv
$apiurl = "https://api.exana.io/dns/"
$spfarray = @()
$mxarray = @()
$txt = "txt"
$mx = "mx"
$csv | ForEach-Object {
    $Domain = $_.Name
    $url = "https://api.exana.io/dns/"+$domain+"/"+$txt
    
    $response = Invoke-RestMethod -uri $url -Method 'GET'
    $txtvalues = $response.answer.rdata

    $spfrecord =""

    ForEach($obj in $txtvalues ){
       $txtrecord = $obj
       $txtrecord = $txtrecord -replace '" "', ""
       $txtrecord = $txtrecord.Trim('"')
       $spfrecord =""
       if ($txtrecord -match "v=spf1"){
           $spfrecord = $txtrecord
       }
       
        $obj = New-Object psobject
        
        $obj | Add-Member -MemberType NoteProperty -Name "DomainName" -Value $Domain
        $obj | Add-Member -MemberType NoteProperty -Name "TXT" -Value $txtrecord
        $obj | Add-Member -MemberType NoteProperty -Name "SPF" -Value $spfrecord
        $spfarray += $obj
    }
    
}

$spfarray 

$csv | ForEach-Object {
    $Domain = $_.Name
    $url = $apiurl+$domain+"/"+$mx
    $response = Invoke-RestMethod -uri $url -Method 'GET'
    $mxvalues = $response.answer.rdata

    $mxrecord =""

    ForEach($obj in $mxvalues ){
       $mxrecord = $obj
       $mxpriority = $mxrecord.Split()[0]
       $mxdomain = $mxrecord.Split()[1]
       $mxdomain = $mxdomain.Trim('.')

        $obj = New-Object psobject
        $obj | Add-Member -MemberType NoteProperty -Name "DomainName" -Value $Domain
        $obj | Add-Member -MemberType NoteProperty -Name "Priority" -Value $mxpriority
        $obj | Add-Member -MemberType NoteProperty -Name "MX" -Value $mxdomain
        $mxarray += $obj
    }
}
 $mxarray