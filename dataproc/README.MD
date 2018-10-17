Table of Contents (dataproc cluster debian-9 with zookeeper, kafka ,BigQuery and other tools with Terraform)
=================

1. [Pre-reqs ](#pre-reqs)
2. [Creation and destroying](#creation-and-destroying)
3. [Cluster details](#cluster-details)
4. [Cloud Dataproc version](#cloud-dataproc-version)
5. [URLs and extra components via dataproc-initialization-actions](#urls-and-extra-components-via-dataproc-initialization-actions)
6. [Terraform graph](#terraform-graph)
7. [Automatic provisioning](#automatic-provisioning)
8. [Testing Kafka](testing-kafka)
9. [Reporting bugs](#reporting-bugs)
10. [Patches and pull requests](#patches-and-pull-requests)

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

### Creation and destroying
`terraform init`

`terraform plan -out "run.plan`

`terraform apply "run.plan"`

`terraform destroy`

>Please note - `firewall.tf` has all ports open and please switch them off before creation if you so want.

### Cluster details

Name | Role | Staging Bucket
--- | --- | ---
poccluster-m<br />poccluster-w-*| Default 1 Master <br />Default 2 Workers| dataproc-poc-staging-bucket

### Cloud Dataproc version
Version | Includes | Base OS | Released On | Last Updated (sub-minor version) | Notes
--- | --- | --- | --- |--- |---
1.3-deb9 | [Apache Spark 2.3.1](https://spark.apache.org/docs/2.3.1/)<br />[Apache Hadoop 2.9.0](https://hadoop.apache.org/docs/r2.9.0/index.html)<br />[Apache Pig 0.17.0](https://pig.apache.org/docs/r0.17.0/)<br />Apache Hive 2.3.2<br />[Apache Tez 0.9.0*](https://tez.apache.org/releases/apache-tez-0-9-0.html)<br />[Cloud Storage connector 1.9.8-hadoop2](https://github.com/GoogleCloudPlatform/bigdata-interop/releases/tag/v1.9.8) | Debian 9 | 2018/08/16 | 2018/10/12<br />([1.3.12-deb9](https://cloud.google.com/dataproc/docs/release-notes#october_12_2018)) | All releases on and after November 2, 2018 will be based on Debian 9.

### URLs and extra components via dataproc-initialization-actions

* YARN ResourceManager: `http://<<Master_External_IP>>:8088/cluster`

* HDFS NameNode: `http://<<Master_External_IP>>:9870`

* Hadoop Job History Server: `http://<<Master_External_IP>>:19888/jobhistory`

* Node Managers: `http://<<Individual_Node_External_IP>>:8042`

* Ganglia: `http://<<Master_External_IP>>:80/ganglia`

* Livy: `http://<<Master_External_IP>>:8998`

* docker latest is installed on all nodes.

 ### Terraform Graph
 Please generate dot format (Graphviz) terraform configuration graphs for visual representation of the repo.

 `terraform graph | dot -Tsvg > graph.svg`
 
 Also, one can use [Blast Radius](https://github.com/28mm/blast-radius) on live initialized terraform project to view graph.
 Please shoot in dockerized format:

 `docker ps -a|grep blast-radius|awk '{print $1}'|xargs docker kill && rm -rf gke-terraform && git clone https://github.com/cloudgear-io/gke-terraform && cd gke-terraform/dataproc/ && terraform init && docker run --cap-add=SYS_ADMIN -dit --rm -p 5004:5000 -v $(pwd):/workdir:ro 28mm/blast-radius && cd ../../`

  A live example is [here](http://buildservers.westeurope.cloudapp.azure.com:5004/) for this project.

  ### Automatic Provisioning

https://github.com/cloudgear-io/gke-terraform/tree/master/dataproc

Pre-req: 
1. gcloud should be installed. Silent install is - 
`export $USERNAME="<<you_user_name>>" && export SHARE_DATA=/data && su -c "export SHARE_DATA=/data && export CLOUDSDK_INSTALL_DIR=$SHARE_DATA export CLOUDSDK_CORE_DISABLE_PROMPTS=1 && curl https://sdk.cloud.google.com | bash" $USER_NAME && echo "source $SHARE_DATA/google-cloud-sdk/path.bash.inc" >> /etc/profile.d/gcloud.sh && echo "source $SHARE_DATA/google-cloud-sdk/completion.bash.inc" >> /etc/profile.d/gcloud.sh &&`

2. Please create Service Credential of type JSON via https://console.cloud.google.com/apis/credentials, download and save as google.json in credentials folder of the gke-terraform

3. **Default user name is the local username**

Plan:

`terraform init && terraform plan -var cluster_location=europe-west2 -var project=r<<your-google-cloud-project-name>> -out "run.plan"`

Apply:

`terraform apply "run.plan"`

Destroy:

`terraform destroy -var cluster_location=europe-west2 -var project=<<your-google-cloud-project-name>>`


 ### Testing Kafka

  Once the cluster has been created Kafka should be running on all worker nodes in the cluster, and Kafka libraries should be installed on the master node(s). You can test your Kafka setup by creating a simple topic and publishing to it with Kafka's command-line tools, after SSHing into one of your master nodes:

  `gcloud compute ssh gcloud compute ssh poccluster-m --zone europe-west2-b`

    Create a test topic, just talking to the local master's zookeeper server.
    ```
    ` /usr/lib/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --create  --replication-factor 1 --partitions 1 --topic test /usr/lib/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --list `    
    
    Use worker 0 as broker to publish 10 messages over 10 seconds asynchronously.

    `export CLUSTER_NAME=$(/usr/share/google/get_metadata_value attributes/dataproc-cluster-name)for i in {0..10}; do echo "message${i}"; sleep 1; done |/usr/lib/kafka/bin/kafka-console-producer.sh --broker-list ${CLUSTER_NAME}-w-0:9092 --topic test &`

    User worker 1 as broker to consume those 100 messages as they come.This can also be run in any other master or worker node of the cluster.
    
    `/usr/lib/kafka/bin/kafka-console-consumer.sh --bootstrap-server ${CLUSTER_NAME}-w-1:9092 --topic test --from-beginning`
    ```


### Reporting bugs

Please report bugs  by opening an issue in the [GitHub Issue Tracker](https://github.com/cloudgear-io/gke-terraform/issues).
Bugs have auto template defined. Please view it [here](https://github.com/cloudgear-io/gke-terraform/blob/master/.github/ISSUE_TEMPLATE/bug_report.md)

### Patches and pull requests

Patches can be submitted as GitHub pull requests. If using GitHub please make sure your branch applies to the current master as a 'fast forward' merge (i.e. without creating a merge commit). Use the `git rebase` command to update your branch to the current master if necessary
