# aro-terraform
Basic ARO deployment and configuration using Terraform and OpenShift GitOps

## Cluster build

The cluster build Terraform code is in the cluster subdirectory.

### Red Hat demo platform variables

When creating the cluster in the RH demo environment, we have to use an existing Azure Service Principal as we do not have access to the Azure AD for the Red Hat tenancy.

After creating a demo environment, you will receive an email with the following details:

- Resource Group: openenv-xxxxx
- DNS Zone: xxxxx.azure.redhatworkshops.io
- Application: openenv-xxxxx
- Application/Client/Service Principal ID: <client ID>
- Password: <password>>
- Tenant ID: redhat0.onmicrosoft.com
- Red Hat pull secret, or the equivalent pull secret for a private container registry.

Copy the appropriare values into the private __secrets.tfvars__ file

You will need to generate the object_id:

```
export CLIENT_ID=<clientID>>
az ad sp show --id $CLIENT_ID --query id -o tsv
```

The redhat_openshift_provider_id can be extracted (note you need to `az login` first):
`az provider show -n Microsoft.RedHatOpenShift --query "authorizations[0].applicationId" -o tsv`

### Cluster build

Login to Azure using your RH credentials (redirects to a browser):

`az login`

Update the secrets.tfvars with your settings

Update vars.tfvars if you want to override any of the default variables, such as the cluster name.

Kick off the build:

```
$ terraform init
$ terraform validate
$ terraform plan -var-file vars.tfvars -var-file secrets.tfvars -out ocp.out
$ terraform apply ocp.out
```

It will take ~<= 1 hour to build

### Get details

The terraform will output the cluster URL, API URL and associated IP addresses to the console on completion.  A kubeconfig file that is used by the subsequent steps to apply and configure OpenShift GitOps and that can be used for cluster authentication is also exported.

The DNS configuration will need to be updated with the cluster IP addresses.

Other useful values can be extracted using the `az aro` command:

```
az aro list
az aro show --name aro --resource-group craig-aro-terraform
az aro list-credentials --name aro --resource-group craig-aro-terraform
az aro get-admin-kubeconfig --name aro --resource-group craig-aro-terraform
```

## Cluster Configuration

The cluster configuration is in the bootstrap-gitops and bootstrap-gitops-application subdirectories. The Terraform in bootstrap-gitops has to be run before that in bootstrap-gitops-application.

The GitOps application needs to be created in a separate step as the CRDs are not created until the Operator is installed and so the plan bootstrap-gitops-application fails if they are combined.

The Terraform Kubernetes provider used to apply the configuration is expecting the kubeconfig file that was exported at the end of the cluster build to enable cluster authentication.

### bootstrap-gitops 

This code uses the Terraform Kubernetes provider to apply the following changes to the cluster:

- Disable the default Red Hat catalogue sources
- Apply the ImageContentSourcePolicy and CatalogSource YAML files generated when populating the ACR registry with Operator and other images using the **oc mirror** plugin (Note that these files need to be made available to the code by placing them in the same subdirectory.  Also, the ImageContentSourcePolicy has to be split into 2 files, one for each policy.)
- Create the ClusterRoleBinding to give OpenShift GitOps ClusterAdmin permissions
- Install the OpenShift GitOps Operator

### bootstrap-gitops-application

This code uses the Terraform Kubernetes provider to apply the OpenShift "application of applications" to the cluster.  The repository and path variables need to be updated to where the application YAML resides.