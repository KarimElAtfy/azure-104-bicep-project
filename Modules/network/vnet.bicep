@description('Name of the VNet. This is a string.')
param name string

@description('Location of the VNet. This is a string.')
param location string

@description('Address space of the VNet. This is an array of strings.')
param addressPrefixes array

@description('Subnets to create in the VNet. This is an array of objects with a name and addressPrefix.')
param subnets array


resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: name
  location: location

  properties: {

    addressSpace:{addressPrefixes:addressPrefixes}

    subnets: [
      for s in subnets : {
        
        name: s.name
        properties: {
          addressPrefix: s.prefix
        }
      }
    ]
  }
}

output subnetIds array = [
  for s in subnets : {
    name: s.name
    id: resourceId('Microsoft.Network/virtualNetworks/subnets', name, s.name)
  }
]
