# aro-terraform
Basic ARO deployment and configuration using Terraform and OpenShift GitOps

## demo platform variables

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

## Cluster build

Login to Azure using your RH credentials (redirects to a browser):

`az login`

Update the secrets.tfvars with your settings

Update vars.tfvars if you want to override any of the default variables, such as the cluster name.

Kick off the build:

``

It will take ~<~= 1 hour to build
