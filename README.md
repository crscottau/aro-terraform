# aro-terraform
Basic ARO deployment and configuration using Terraform and OpenShift GitOps

## Cluster 

### Red Hat demo platform variables

When creating the cluster in the RH demo environment, we have to use an existing Axure Service Principal as we do not have access to the Azure AD for the Red Hat tenancy.

After creating a demo environment, you will receive an email with the following details:

- Resource Group: openenv-xxxxx
- DNS Zone: xxxxx.azure.redhatworkshops.io
- Application: openenv-xxxxx
- Application/Client/Service Principal ID: <client ID>
- Password: <password>>
- Tenant ID: redhat0.onmicrosoft.com

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

``

It will take ~<~= 1 hour to build

### Get details

The terraform will output the cluster URL, API URL and associated IP addresses to the console on completion.  The DNS configuration will need to be updated with these IP addresses.

Other useful values can be extracted using the `az aro` command:

```
az aro list
az aro show --name aro --resource-group craig-aro-terraform
az aro list-credentials --name aro --resource-group craig-aro-terraform
az aro get-admin-kubeconfig --name aro --resource-group craig-aro-terraform
```

## Current issues

1. Getting the kubeconfig file automatically - need to check the documentation but it is probably simple enough
2. Need to automate the edit of the file to add **insecure-skip-tls-verify: true** to the cluster stanza
3. Need to be able to apply the local catalogsource and imagecontentsourcepolicy YAML
4. Need to be able to disable the default catalogsources (Adding a pull secret appears to enable them automatically, alternative might be to not provide a pull secret and update it later)
5. Need a delay between the gitops helm chart and the gitops-application helm chart

### Problem 1

Run the **az aro** command to extract the kubeconfig file after the cluster is built

### Problem 2

Include a **sed** command to add the string

### problem 3

These might need to be hard coded into a helm chart

### problem 4

Do include the pull secretm, and disable the default catalogue sources this as part of a gitops application

### problem 5

Could ADO do this?