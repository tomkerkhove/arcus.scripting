# Use this script to upload a certificate as plain text (multiline-support) into Azure Key Vault.

param (
    [string][Parameter(Mandatory=$true)] $KeyVaultName = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $SecretName = $(throw "The path to the file is required."),
    [string][Parameter(Mandatory=$true)] $FilePath = $(throw "The path to the file is required."),
    [System.Nullable[System.DateTime]][Parameter(Mandatory=$false)] $Expires,
    [switch][Parameter(Mandatory=$false)] $Base64 = $false
)

$isFileFound = Test-Path -Path $FilePath -PathType Leaf
if ($false -eq $isFileFound) {
    Write-Error "No file could containing the secret certificate at '$FilePath'"
    return;
}

Write-Host "Creating KeyVault secret..."

$secretValue = $null
if ($Base64) {
    $content = Get-Content $filePath -AsByteStream -Raw
    $contentBase64 = [System.Convert]::ToBase64String($content)
    $secretValue = ConvertTo-SecureString -String $contentBase64 -Force -AsPlainText
} else {
    $rawContent = Get-Content $FilePath -Raw
    $secretValue = ConvertTo-SecureString $rawContent -Force -AsPlainTex
}

$secret = $null
if ($Expires -ne $null) {
    $secret = Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName -SecretValue $secretValue -Expires $Expires -ErrorAction Stop
} else {
    $secret = Set-AzKeyVaultSecret -VaultName $KeyVaultName -SecretName $SecretName -SecretValue $secretValue -ErrorAction Stop
}

$version = $secret.Version
Write-Host "Secret '$SecretName' (Version: '$version') has been created."
