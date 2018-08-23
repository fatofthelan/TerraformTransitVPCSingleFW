### AWS Transit VPC (and Spoke VPC) Terraform Template
This is the first draft of the AWS Transit VPC/Subscribing VPC Terraform templates.

#### This Terraform template will:
- Create the Transit VPC and Subscribing (Spokes) VPCs.
- Create and populate the S3 Bucket used for bootstrapping the VM-Series firewalls.
- Spin up a Palo Alto Networks VM-Series Firewall in the Transit VPC.
- Configure VPNs between the Spoke VPC and the VM-Series Firewall.
- Configure BGP and add routes for the Spoke VPCs.
- Create a Bastion Host in the Transit VPC's Trust network.
- Create a Bastion Host in the Spoke VPC.

#### To use this terraform template, you will need to do the following:
- Download and install terraform
- Change any variables in the __vars.tf__ file to suit your needs.
- Define a unique name for the `"bootstrap_bucket"` variable in the __vars.tf__ file.
- Accept the EULA for the Palo Alto Networks Firewall in your preferred region.
- Create a keypair in the key/ directory:
  ```
  ssh-keygen -f transit-vpc-key
  ```
- Duplicate the __spoke.tf__ file for each desired spoke VPC you wish to create and find/replace
  "spoke" with with the name of the new spoke, "prod" for example. (Automated VPNs/Configs only
  work for the first Spoke VPC at this point. This will be addressed in v2.)
- Change the name of the `"spoke_name"` and `"spoke_vpc_cidr_prefix"` variables in each __spoke.tf__ file
  you created in the previous step.
- Run
  ```
  terraform init
  terraform apply
  ```
- After the template runs, you will see the firewall's IP as well as the PSKs for the VPNs.
- Log in to the firewall and import/load the firewall's configuration file from the templates
  directory. __DO NOT COMMIT YET__. Go to the Network tab, IKE Gateways, and open each entry and enter
  the PSKs from the Terraform output. (I'll automate this in v2.)
- Commit and you should all of the VPN tunnels become active as well as their BGP entries.

#### NOTES:
- The username and password from the bootstrap.xml is __paloalto__ / __in*4ksh8JN2kdh__ (be sure to change this once your FWs come up!)
- The AMI used by default is for the _Pay As You Go_ instance of PANOS 8.1. Change the `"palo_alto_fw_ami"` variable to suit your needs.
- Validate - ssh into the Bastion host (command is output to the console). You should be able to connect out to the internet as well as ssh to the Bastion Host in the Spoke VPC.
