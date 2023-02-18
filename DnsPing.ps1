$subdomains = Get-Content "dnslist.txt"
$output = @()
$errorIPs = @()

foreach ($subdomain in $subdomains) {
    $ip = [System.Net.Dns]::GetHostAddresses($subdomain) | Select-Object -First 1
    if ($ip) {
        $ping = Test-Connection $ip.IPAddressToString -Count 1
        if ($ping.StatusCode -eq 0) {
            $output += New-Object PSObject -Property @{
                Subdomain = $subdomain
                IP = $ip.IPAddressToString
                MS = $ping.ResponseTime
            }
        } else {
            $errorIPs += "$subdomain - Error"
        }
    }
}

$output = $output | Sort-Object -Property MS
$output = $output | ForEach-Object { "$($_.Subdomain) - $($_.IP) - $($_.MS) ms" }
$output += $errorIPs

$datetime = Get-Date -Format "yyyy-MM-dd-HH_mm"
Set-Content "result/$($datetime).txt" $output
