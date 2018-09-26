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
|   cluster_location	|us-central1 or eu-westeurope2   	|
|   node_count	| master count - 1 master is to three minimum workers   	|
|   master_auth_username	|admin 	|
|   master_auth_password	|16 letters and strong 	|
|   cluster_label	|dev/tst/uat/prod	|
|   cluster_tag	|gke_dev/tst/uat/prod	|
|   project	|The GCP project name	|
|   gcp_machine_type	|https://cloud.google.com/compute/docs/machine-types   	|
|   helm_install_jenkins	|Install Jenkins OR Not [with auto PV as per values in yaml   	|
|   install_prometheus_grafana	|Install prometheus and Grafana for cluster as helm package   	|
|   install_ibm_mq	|Install IBM MQ v9 OR Not with PV  	|
|   patch_prom_graf_lbr_external	|true or false   	|
|   patch_ibm_mq_lbr_external	|true or false   	|

### Terraform Graph
Please generate dot format (Graphviz) terraform configuration graphs for visual representation of the repo.

`terraform graph | dot -Tsvg > graph.svg`

Also, one can use [Blast Radius](https://github.com/28mm/blast-radius) on live initialized terraform project to view graph.
Please shoot in dockerized format:

`docker ps -a|grep blast-radius|awk '{print $1}'|xargs docker kill && rm -rf gke-terraform && git clone https://github.com/cloudgear-io/gke-terraform && cd gke-terraform && terraform init && docker run --cap-add=SYS_ADMIN -dit --rm -p 5003:5000 -v $(pwd):/workdir:ro 28mm/blast-radius`

 A live example is [here](http://buildservers.westeurope.cloudapp.azure.com:5003/) for this project. 