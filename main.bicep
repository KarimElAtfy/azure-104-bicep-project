param location string
param vnet object
param storageAccount object
param NSG object
param WinWebConfig object
param lbname string

@secure()
param winWebAdminPassword string

param bastion object
var nsgAttachements = [
  {
   vnetName: vnet.name
   subnetName:  vnet.subnets[0].name
   addressPrefix: vnet.subnets[0].prefix
  }
  {
   vnetName: vnet.name
   subnetName: vnet.subnets[1].name
   addressPrefix: vnet.subnets[1].prefix
  }
]

module devnet 'Modules/network/vnet.bicep' = {
  name: 'dev-network'
  params: {
    name:  vnet.name
    location: location
    addressPrefixes:  vnet.addressPrefixes
    subnets: vnet.subnets
  }
}

module devStorage 'Modules/storage/storageAccount.bicep' = {
  name: 'dev-storage'
  params: {
    name: storageAccount.name
    location: location
  }
}

module devNSG 'Modules/security/nsg.bicep' = {
  name: 'dev-NSG'
  params: {
    name: NSG.name
    location: location
    securityRules: NSG.rules
    attachements: nsgAttachements
  }

  dependsOn: [devnet]
}

module winWeb 'Modules/compute/windowsVM.bicep' = {
  name: 'windows-web-dev'
  params: {
    location: location
    basename: WinWebConfig.basename
    count: WinWebConfig.count
    vmSize: WinWebConfig.vmSize
    adminUsername: WinWebConfig.adminUsername
    subnetId: devnet.outputs.subnetIds[0].id
    adminPassword: winWebAdminPassword
    scriptUri: WinWebConfig.scriptUri
    lbBackendPoolId: devLoadBalancer.outputs.backendPoolId
  }

  dependsOn: [devNSG]
}


module devPip 'Modules/network/publicIp.bicep' = {
  name: 'Bastion-Ip'
  params: {
    name: bastion.pipName
    location: location
  }
}

module bastionHost 'Modules/security/bastion.bicep' = {
  name: 'Bastion-Host'
  params:{
    name: bastion.name
    location: location
    subnetId: devnet.outputs.subnetIds[2].id
    pipId: devPip.outputs.publicIpId
  }
}


module devLoadBalancer 'Modules/network/internal-lb.bicep' = {
  name: 'dev-lb'
  params: {
    lbName: lbname
    location: location
    subnetId: devnet.outputs.subnetIds[0].id
  }
}
