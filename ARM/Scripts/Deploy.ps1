
#!
# use your repo absolute path here and run this command before continuing. PowerShell hates relative paths.
$repoDir = "C:\path\to\netconf2018demo"
$resourceGroupName = "<resource group name>"
$region = "westus2"

# Login and subsription stuff
Login-AzureRmAccount
Set-AzureRmContext -Subscription "<your subscription name>"

# Resource group
New-AzureRmResourceGroup -Name $resourceGroupName -Location $region

# create a keyvault and upload a certificate to it
Import-Module "$repoDir\ARM\Scripts\ServiceFabricRPHelpers\ServiceFabricRPHelpers.psm1"

# New cert
$keyvault = Invoke-AddCertToKeyVault -SubscriptionId "<subscription GUID>" -ResourceGroupName $resourceGroupName -Location $region -VaultName '<keyvault name>' -CertificateName 'clustercert' -CreateSelfSignedCertificate -OutputPath "$repoDir\ARM\Certs" -DnsName 'mycluster.io' -Password "<password>"

# or existing cert
$keyvault = Invoke-AddCertToKeyVault -SubscriptionId "<subscription GUID>" -ResourceGroupName $resourceGroupName -Location $region -VaultName '<keyvault name>' -CertificateName 'clustercert' -UseExistingCertificate -ExistingPfxFilePath "$repoDir\ARM\Certs\clustercert.pfx" -Password "<password>"

# template test and deploy
Test-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile "$repoDir\ARM\Templates\cluster-deploy.json" -TemplateParameterFile "$repoDir\ARM\Templates\cluster-deploy.parameters.json" -Verbose -clusterCertificateThumbprint $keyvault.CertificateThumbprint -sourceVaultValue $keyvault.SourceVault -clusterCertificateUrlValue $keyvault.CertificateURL -Debug
New-AzureRmResourceGroupDeployment  -ResourceGroupName $resourceGroupName -TemplateFile "$repoDir\ARM\Templates\cluster-deploy.json" -TemplateParameterFile "$repoDir\ARM\Templates\cluster-deploy.parameters.json" -Verbose -clusterCertificateThumbprint $keyvault.CertificateThumbprint -sourceVaultValue $keyvault.SourceVault -clusterCertificateUrlValue $keyvault.CertificateURL
