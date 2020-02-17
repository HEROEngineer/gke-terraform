Table of Contents (GKE and tools with Terraform)
=================

1. [Google Kubernetes Engine with Terraform ](#google-cloud-with-terraform)
2. [Terraform graph](#terraform-graph)
3. [Automatic provisioning](#automatic-provisioning)
4. [Reporting bugs](#reporting-bugs)
5. [Patches and pull requests](#patches-and-pull-requests)
6. [License](#license)
7. [Code of conduct](#code-of-conduct)

# Google Kubernetes Engine with Terraform

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. [Download and install google cloud sdk](https://cloud.google.com/sdk/docs/downloads-interactive)
    * One may install gcloud sdk silently for all users as root with access to GCLOUD_HOME for only speficic user:

       `export USERNAME="<<you_user_name>>"`

       `export SHARE_DATA=/data`

       `su -c "export SHARE_DATA=/data && export CLOUDSDK_INSTALL_DIR=$SHARE_DATA export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash" $USER_NAME`
       
       OR
       `export SHARE_DATA=/data && export CLOUDSDK_INSTALL_DIR=$SHARE_DATA export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash`

       `echo "source $SHARE_DATA/google-cloud-sdk/path.bash.inc" >> /etc/profile.d/gcloud.sh`

       `echo "source $SHARE_DATA/google-cloud-sdk/completion.bash.inc" >> /etc/profile.d/gcloud.sh`

3. Clone this repository
4. Please create **Service Credential** of type **JSON** via https://console.cloud.google.com/apis/credentials, download and save as **google.json** in **credentials** folder.
5. `terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`. Please note the tags name prompted during plan may be dev/tst or any other stage.
6. 

|   Prompted variables	| Expected value  	|
|---	|---	|
|   cluster_name	|Name of the GKE Cluster  	|
|   cluster_location	|us-central1 or europe-west2 (UK)  or  europe-west4 (NL) any other region  	|
|   node_count	| master count - 1 master is to three minimum workers e.g: 1  	|
|   master_auth_username	|admin 	|
|   master_auth_password	|16 letters and strong like e.g: !@#olie!@#olie!@#23D# 	|
|   cluster_tag	|gke_devor gke_tst or gke_uat or gke_prod	|
|   project	|The GCP project name	|

 ### Automatic Provisioning

https://github.com/cloudgear-io/gke-terraform

Pre-req: 
1. gcloud should be installed. Silent install is - 
`export $USERNAME="<<you_user_name>>" && export SHARE_DATA=/data && su -c "export SHARE_DATA=/data && export CLOUDSDK_INSTALL_DIR=$SHARE_DATA export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash" $USER_NAME && echo "source $SHARE_DATA/google-cloud-sdk/path.bash.inc" >> /etc/profile.d/gcloud.sh && echo "source $SHARE_DATA/google-cloud-sdk/completion.bash.inc" >> /etc/profile.d/gcloud.sh &&`

2. Please create Service Credential of type JSON via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder of the gke-terraform
3. **Default user name is the local username**

Plan:

`terraform init && terraform plan -var cluster_label=devgke -var cluster_location=us-west1 -var cluster_name=devgkeclus -var cluster_tag=devgkeuswest  -var master_auth_password=\!@#olie\!@#olie\!@#23D# -var master_auth_username=admin -var node_count=1 -var project=<<your-google-cloud-project-name>> -out "run.plan"`

Apply:

`terraform apply "run.plan"`

Destroy:

`terraform destroy -var cluster_label=devgke -var cluster_location=us-west1 -var cluster_name=devgkeclus -var cluster_tag=devgkeuswest -var master_auth_password=\!@#olie\!@#olie\!@#23D# -var master_auth_username=admin -var node_count=1 -var project=<<your-google-cloud-project-name>>`

### Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/cloudgear-io/gke-terraform/issues).
Bugs have auto template defined. Please view it [here](https://github.com/cloudgear-io/gke-terraform/blob/master/.github/ISSUE_TEMPLATE/bug_report.md)

### Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary.

### License
  * Please see the [LICENSE file](https://github.com/cloudgear-io/gke-terraform/blob/master/LICENSE) for licensing information.

### Code of Conduct
  * Please see the [Code of Conduct](https://github.com/cloudgear-io/gke-terraform/blob/master/CODE_OF_CONDUCT.md)
