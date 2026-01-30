param name string
param location string

param subnetId string
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
