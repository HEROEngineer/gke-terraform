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
6. Prompted variables | Expected value 
--- | ---
cluster_name<br />cluster_location<br />node_count<br />master_auth_username<br />master_auth_password<br />cluster_label<br />cluster_tag<br />project<br />gcp_machine_type<br />helm_install_jenkins<br />install_prometheus_grafana<br />patch_prom_graf_lbr_externa<br />install_ibm_mq<br />patch_ibm_mq_lbr_external | Name of the GKE Cluster<br />us-central1 or eu-westeurope2<br />1 master is to three works<br />admin<br />16 letters and strong<br />dev/tst/uat/prod<br />gke_dev/tst/uat/prod<br />The project name<br />https://cloud.google.com/compute/docs/machine-types<br />Install Jenkins OR Not<br />Install prometheus and Grafana for cluster as helm package and install<br />true or false<br />Install IBM MQ v9 OR Not<br />install_ibm_mq<br />true or false