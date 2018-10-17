Table of Contents (Google Cloud with Terraform with disks)
=================

1. [Google Kubernetes Engine with Terraform ](#google-cloud-with-terraform)
2. [All Services](#all-services)
3. [Obtaining users and passes](#obtaining-users-and-passes)
4. [Terraform graph](#terraform-graph)
5. [Automatic provisioning](#automatic-provisioning)
6. [Reporting bugs](#reporting-bugs)
7. [Patches and pull requests](#patches-and-pull-requests

# Google Kubernetes Engine with Terraform

1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. [Download and install google cloud sdk](https://cloud.google.com/sdk/docs/downloads-interactive)
    * One may install gcloud sdk silently for all users as root with access to GCLOUD_HOME for only speficic user:

       `export $USERNAME="<<you_user_name>>"`

       `export SHARE_DATA=/data`

       `su -c "export SHARE_DATA=/data && export CLOUDSDK_INSTALL_DIR=$SHARE_DATA export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash" $USER_NAME`

       `echo "source $SHARE_DATA/google-cloud-sdk/path.bash.inc" >> /etc/profile.d/gcloud.sh`

       `echo "source $SHARE_DATA/google-cloud-sdk/completion.bash.inc" >> /etc/profile.d/gcloud.sh`

3. Clone this repository
4. Please create Service Credential of type **JSON** via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder.
5. `terraform init && terraform plan -out "run.plan" && terraform apply "run.plan"`. Please note the tags name prompted during plan may be dev/tst or any other stage.
6. 

|   Prompted variables	| Expected value  	|
|---	|---	|
|   cluster_name	|Name of the GKE Cluster  	|
|   cluster_location	|us-central1 or eu-westeurope2 (UK)  or  eu-westeurope4 (NL) any other region  	|
|   node_count	| master count - 1 master is to three minimum workers e.g: 1  	|
|   master_auth_username	|admin 	|
|   master_auth_password	|16 letters and strong like e.g: !@#olie!@#olie!@#23D# 	|
|   cluster_label	|dev or tst or uat/prod	|
|   cluster_tag	|gke_devor gke_tst or gke_uat or gke_prod	|
|   project	|The GCP project name	|
|   gcp_machine_type	|https://cloud.google.com/compute/docs/machine-types   	|
|   helm_install_jenkins	|Install Jenkins OR Not [with auto PV] as per values in yaml   	|
|   install_prometheus_grafana	|Install prometheus and Grafana for cluster as helm package   	|
|   install_ibm_mq	|Install IBM MQ v9 OR Not with PV  	|
|   patch_prom_graf_lbr_external	|true or false   	|
|   patch_ibm_mq_lbr_external	|true or false   	|
|   install_suitecrm	|true or false   	|

### All Services

`kubectl get svc --all-namespaces`

if prometheus/grafana or MQ patch to load balancer is `yes`, then External IP would be available and accessible for prometheus and MQ.

> Jenkins and SuiteCRM are defaulted to Load balancer and hence always have external IP

---
**NOTE**

For 1 master gke, it is preferable besides prometheus/grafana to install only MQ or SuiteCRM.
One can also `helm install` any other apps.

---
### Obtaining users and passes
1. MQ Web console
user is `admin`

`MQ_ADMIN_PASSWORD=$(kubectl get secret --namespace ibm mqserver-ibm-mq -o jsonpath="{.data.adminPassword}" | base64 --decode; echo)`

`MQ_APP_PASSWORD=$(kubectl get secret --namespace ibm mqserver-ibm-mq -o jsonpath="{.data.appPassword}" | base64 --decode; echo)`

2. Suite CRM
user is `user`
`kubectl get secret --namespace sugarcrm sugarcrm-dev-suitecrm -o jsonpath="{.data.suitecrm-password}" | base64 --decode`

3. Jenkins Master
user is `admin`

`printf $(kubectl get secret --namespace default hclaks-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode);echo`

4. Grafana (with kube-prom)

User/Password for grafana (generally `admin/admin`)

`kubectl get secret --namespace monitoring kube-prometheus-grafana -o jsonpath="{.data.password}" | base64 --decode ; echo`

`kubectl get secret --namespace monitoring kube-prometheus-grafana -o jsonpath="{.data.user}" | base64 --decode ; echo`


### Terraform Graph
Please generate dot format (Graphviz) terraform configuration graphs for visual representation of the repo.

`terraform graph | dot -Tsvg > graph.svg`

Also, one can use [Blast Radius](https://github.com/28mm/blast-radius) on live initialized terraform project to view graph.
Please shoot in dockerized format:

`docker ps -a|grep blast-radius|awk '{print $1}'|xargs docker kill && rm -rf gke-terraform && git clone https://github.com/cloudgear-io/gke-terraform && cd gke-terraform && terraform init && docker run --cap-add=SYS_ADMIN -dit --rm -p 5003:5000 -v $(pwd):/workdir:ro 28mm/blast-radius`

 A live example is [here](http://buildservers.westeurope.cloudapp.azure.com:5003/) for this project. 

  ### Automatic Provisioning

https://github.com/cloudgear-io/gke-terraform

Pre-req: 
1. gcloud should be installed. Silent install is - 
`export $USERNAME="<<you_user_name>>" && export SHARE_DATA=/data && su -c "export SHARE_DATA=/data && export CLOUDSDK_INSTALL_DIR=$SHARE_DATA export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash" $USER_NAME && echo "source $SHARE_DATA/google-cloud-sdk/path.bash.inc" >> /etc/profile.d/gcloud.sh && echo "source $SHARE_DATA/google-cloud-sdk/completion.bash.inc" >> /etc/profile.d/gcloud.sh &&`

2. Please create Service Credential of type JSON via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder of the gke-terraform
3. **Default user name is the local username**

Plan:

`terraform init && terraform plan -var cluster_label=devgke -var cluster_location=europe-west4 -var cluster_name=devgkeclus -var cluster_tag=devgkeeuwest4 -var helm_install_jenkins=false -var install_ibm_mq=true -var install_prometheus_grafana=true -var install_suitecrm=false -var master_auth_password=\!@#olie\!@#olie\!@#23D# -var master_auth_username=admin -var node_count=1 -var patch_ibm_mq_lbr_external=true -var patch_prom_graf_lbr_external=true -var project=<<your-google-cloud-project-name>> "run.plan"`

Apply:

`terraform apply "run.plan"`

Destroy:

`terraform destroy -var cluster_label=devgke -var cluster_location=europe-west4 -var cluster_name=devgkeclus -var cluster_tag=devgkeeuwest4 -var helm_install_jenkins=false -var install_ibm_mq=true -var install_prometheus_grafana=true -var install_suitecrm=false -var master_auth_password=\!@#olie\!@#olie\!@#23D# -var master_auth_username=admin -var node_count=1 -var patch_ibm_mq_lbr_external=true -var patch_prom_graf_lbr_external=true -var project=<<your-google-cloud-project-name>>`

### Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/cloudgear-io/gke-terraform/issues).
Bugs have auto template defined. Please view it [here](https://github.com/cloudgear-io/gke-terraform/blob/master/.github/ISSUE_TEMPLATE/bug_report.md)

### Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary.
