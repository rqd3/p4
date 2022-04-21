#!/bin/bash

# Variables
# Cloud Lab users should use the existing Resource group name, such as, resourceGroup="cloud-demo-153430" 
resourceGroup="acdnd-c4-exercise"
location="westeurope"
osType="UbuntuLTS"
vmssName="udacity-vmss"
adminName="udacityadmin"
storageAccount="udacitydiag$RANDOM"
bePoolName="$vmssName-bepool"
lbName="$vmssName-lb"
lbRule="$lbName-network-rule"
nsgName="$vmssName-nsg"
vnetName="$vmssName-vnet"
subnetName="$vnetName-subnet"
probeName="tcpProbe"
vmSize="Standard_B1ls"
storageType="Standard_LRS"

# Create resource group. 
# This command will not work for the Cloud Lab users. 
# Cloud Lab users can comment this command and 
# use the existing Resource group name, such as, resourceGroup="cloud-demo-153430" 
echo "STEP 0 - Creating resource group $resourceGroup..."

az group create --name p4_udacity --location westeurope --verbose

echo "Resource group created: $resourceGroup"

# Create Storage account
echo "STEP 1 - Creating storage account $storageAccount"

az storage account create --name p4Storage --resource-group p4_udacity --location westeurope --sku Standard_LRS

echo "Storage account created: $storageAccount"

# Create Network Security Group
echo "STEP 2 - Creating network security group $nsgName"

az network nsg create --resource-group p4_udacity --name p4 --verbose

echo "Network security group created: $nsgName"

# Create VM Scale Set
echo "STEP 3 - Creating VM scale set $vmssName"

az vmss create --resource-group p4_udacity --name udacity-vmss --image UbuntuLTS --vm-sku Standard_B1ls --nsg p4 --subnet vnetname --vnet-name vmssName --backend-pool-name poolname --storage-sku Standard_LRS --load-balancer loadbalancer --custom-data cloud-init.txt --upgrade-policy-mode automatic --admin-username udacityadmin --generate-ssh-keys --verbose 

echo "VM scale set created: $vmssName"

# Associate NSG with VMSS subnet
echo "STEP 4 - Associating NSG: $nsgName with subnet: $subnetName"

az network vnet subnet update --resource-group p4_udacity --name vnetname --vnet-name vmssName --network-security-group p4 --verbose

echo "NSG: $nsgName associated with subnet: $subnetName"

# Create Health Probe
echo "STEP 5 - Creating health probe $probeName"

az network lb probe create --resource-group p4_udacity --lb-name loadbalancer --name tcpProbe --protocol tcp --port 80 --interval 5 --threshold 2 --verbose

echo "Health probe created: $probeName"

# Create Network Load Balancer Rule
echo "STEP 6 - Creating network load balancer rule $lbRule"

az network lb rule create --resource-group p4_udacity --name lbRule --lb-name loadbalancer --probe-name tcpProbe --backend-pool-name poolname --backend-port 80 --frontend-ip-name loadBalancerFrontEnd --frontend-port 80 --protocol tcp --verbose

echo "Network load balancer rule created: $lbRule"
# Add port 80 to inbound rule NSG

echo "STEP 7 - Adding port 80 to NSG $nsgName"

az network nsg rule create --resource-group p4_udacity --nsg-name p4 --name Port_80 --destination-port-ranges 80 --direction Inbound --priority 100 --verbose

echo "Port 80 added to NSG: $nsgName"

# Add port 22 to inbound rule NSG
echo "STEP 8 - Adding port 22 to NSG $nsgName"

az network nsg rule create --resource-group p4_udacity --nsg-name p4 --name Port_22 --destination-port-ranges 22 --direction Inbound --priority 110 --verbose

echo "Port 22 added to NSG: $nsgName"

echo "VMSS script completed!"
