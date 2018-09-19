### Pre-reqs
1. [Download and Install Terraform](https://www.terraform.io/downloads.html)
2. [Download and install google cloud sdk](https://cloud.google.com/sdk/docs/downloads-interactive)
    * One may install gcloud sdk silently for all users as root with access to GCLOUD_HOME for only speficic user:

       `export $USERNAME="<<you_user_name>>"`

       `export SHARE_DATA=/data`

       `su -c "export SHARE_DATA=/data && export CLOUDSDK_INSTALL_DIR=$SHARE_DATA export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash" $USER_NAME`

       `echo "source $SHARE_DATA/google-cloud-sdk/path.bash.inc" >> /etc/profile.d/gcloud.sh`

       `echo "source $SHARE_DATA/google-cloud-sdk/completion.bash.inc" >> /etc/profile.d/gcloud.sh`

3. Clone this repository and cd into dataproc folder. `git clone https://github.com/cloudgear-io/gke-terraform && cd dataproc`
4. Please create Service Credential of type **JSON** via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder.

### Creation
`terraform init`

`terraform plan -out "run.plan`

`terraform apply "run.plan"`

### Destroying
`terraform destroy`

>Please note - `firewall.tf` has all ports open and please switch them off before creation if you so want.

### Cluster details

Name | Role | Staging Bucket
--- | --- | ---
poccluster-m<br />poccluster-w-*| Default 1 Master <br />Default 2 Workers| dataproc-poc-staging-bucket

### Cloud Dataproc version
Version | Includes | Base OS | Released On | Last Updated (sub-minor version) | Notes
--- | --- | --- | --- |--- |---
1.3-deb9 | [Apache Spark 2.3.0](https://spark.apache.org/docs/2.3.0/)<br />[Apache Hadoop 2.9.0](https://hadoop.apache.org/docs/r2.9.0/index.html)<br />[Apache Pig 0.17.0](https://pig.apache.org/docs/r0.17.0/)<br />Apache Hive 2.3.2<br />[Apache Tez 0.9.0*](https://tez.apache.org/releases/apache-tez-0-9-0.html)<br />[Cloud Storage connector 1.9.0-hadoop2](https://github.com/GoogleCloudPlatform/bigdata-interop/releases/tag/v1.9.0) | Debian 9 | 2018/08/16 | 2018/09/14<br />([1.3.8-deb9](https://cloud.google.com/dataproc/docs/release-notes#september_14_2018)) | All releases on and after November 2, 2018 will be based on Debian 9.

### URLs and extra components via dataproc-initialization-actions
* YARN ResourceManager: `http://<<Master_External_IP>>:8088/cluster`

* HDFS NameNode: `http://<<Master_External_IP>>:9870`

* Hadoop Job History Server: `http://<<Master_External_IP>>:19888/jobhistory`

* Node Managers: `http://<<Individual_Node_External_IP>>:8042`

* Ganglia: `http://<<Master_External_IP>>:80/ganglia`