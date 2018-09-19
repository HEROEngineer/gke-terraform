### Creation
`terraform init`
`terraform plan -out "run.plan`
`terraform apply "run.plan"`

### Destroying
`terraform destroy`

### Cluster details

Name | Role | Staging Bucket
--- | --- | ---
poccluster-m<br />poccluster-w-0<br />poccluster-w-1 | Master<br />Worker<br />Worker | dataproc-poc-staging-bucket

### Cloud Dataproc version
Version | Includes | Base OS | Released On | Last Updated (sub-minor version) | Notes
--- | --- | --- | --- |--- |---
1.3-deb9 | [Apache Spark 2.3.0](https://spark.apache.org/docs/2.3.0/)<br />[Apache Hadoop 2.9.0](https://hadoop.apache.org/docs/r2.9.0/index.html)<br />[Apache Pig 0.17.0](https://pig.apache.org/docs/r0.17.0/)<br />Apache Hive 2.3.2<br />[Apache Tez 0.9.0*](https://tez.apache.org/releases/apache-tez-0-9-0.html)<br />[Cloud Storage connector 1.9.0-hadoop2](https://github.com/GoogleCloudPlatform/bigdata-interop/releases/tag/v1.9.0) | Debian 9 | 2018/08/16 | 2018/09/14<br />([1.3.8-deb9](https://cloud.google.com/dataproc/docs/release-notes#september_14_2018)) | All releases on and after November 2, 2018 will be based on Debian 9.