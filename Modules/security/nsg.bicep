@description('Network security group name.')
param name string
@description('Azure region for the NSG.')
param location string

@description('Security rules for the NSG. This is an array of objects.')
param securityRules array
@description('Attachements for the NSG. This is an array of objects.')
param attachements array


resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: name
  location: location
  properties: {
    securityRules: [
      for r in securityRules: r
    ]
  }
}

resource subnetAssociation 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = [
  for a in attachements: {
    name: '${a.vnetName}/${a.subnetName}'
    properties: {
      networkSecurityGroup: {id: networkSecurityGroup.id}
      addressPrefix: a.addressPrefix
    }
  }
]
