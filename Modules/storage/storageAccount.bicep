
@description('Name of the Storage Account. This is a string.')
param name string

@description('Location of the Storage Account. This is a string.')
param location string


resource stgAccount 'Microsoft.Storage/storageAccounts@2025-06-01' = {
  name: name
  location: location
  sku: {name:'Standard_LRS'}
  kind: 'StorageV2'
}
