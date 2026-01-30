@description('Azure Bastion host name.')
param name string
@description('Azure region for the Bastion host.')
param location string

@description('Subnet resource ID for Azure Bastion.')
param subnetId string
@description('Public IP resource ID for Azure Bastion.')
param pipId string

resource azBastion 'Microsoft.Network/bastionHosts@2025-05-01' = {
  name: name
  location: location
  sku: {name: 'Standard'}
  properties: {
    enableTunneling: true
    scaleUnits: 2
    ipConfigurations: [
      {
        name: 'bastion-ipconfig'
        properties: {
          subnet: {id: subnetId}
          publicIPAddress: {id: pipId}
        }
      }
    ]
  }
}
