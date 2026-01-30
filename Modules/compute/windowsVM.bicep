param lbBackendPoolId string


@description('URI to the script file (e.g., SAS URL from Storage or a raw GitHub URL)')
param scriptUri string

@secure()
@description('Command to execute on the VM after the file is downloaded')
param scriptCommand string = 'powershell -ExecutionPolicy Bypass -File .\\install-webserver.ps1'



param location string

param vmSize string

param adminUsername string = 'AzureAdmin'

@secure()
param adminPassword string 

@description('Name of the VM. This is a int.')
param count int

param basename string

var indexes = [for i in range(1, count) : i]
var vmNames = [for i in indexes: 'vm-${basename}-${i}']

var nicNames = [for i in indexes: 'nic-${basename}-${i}']

param subnetId string



resource nics 'Microsoft.Network/networkInterfaces@2025-05-01' = [for (nicName, i) in nicNames : {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [

      {
        name: 'ipconfig1'

        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {id: subnetId}
          loadBalancerBackendAddressPools: [
            {
              id: lbBackendPoolId
            }
          ]
        }
      }

    ]
  }
}
]

resource vms 'Microsoft.Compute/virtualMachines@2025-04-01' = [for (vmName, i) in vmNames : {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }

    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }

    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2025-Datacenter'
        version: 'latest'
      }

      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }

    networkProfile: {
      networkInterfaces: [
        {
          id: nics[i].id
          properties: {primary: true}
        }
      ]
    }

  }
}]


resource vmCse 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = [
  for i in range(0, length(vmNames)): {
    name: 'cse-init'                      
    location: location
    parent: vms[i]                        
    properties: {
      publisher: 'Microsoft.Compute'
      type: 'CustomScriptExtension'
      typeHandlerVersion: '1.10'
      autoUpgradeMinorVersion: true
      settings: {
        fileUris: [
          scriptUri                       
        ]
      }
      protectedSettings: {
        commandToExecute: scriptCommand   
      }
    }
  }
]
