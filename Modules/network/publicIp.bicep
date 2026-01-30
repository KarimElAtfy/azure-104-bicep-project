@description('Public IP resource name.')
param name string
@description('Azure region for the public IP.')
param location string

@description('SKU for Bastion, needs to be Standard')
param sku string = 'Standard'

@description('Public IP allocation method.')
param allocation string = 'Static'


resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: name
  location: location
  sku: {name: sku}

  properties: {
    
    publicIPAllocationMethod: allocation

  }
}

output publicIpId string = publicIPAddress.id
