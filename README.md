# tf-gcp-infra
Terraform assignments for the course CSYE 6225 Newtwork Structures and Cloud Computing 

# GCP Commands

```
gcloud init
```
```
gcloud auth login --no-launch-browser
```
```
gcloud config set project csye6225-414117
```

Enable compute API
```
gcloud services enable compute.googleapis.com
gcloud services enable sqladmin.googleapis.com
```

List Enabled APIs 
gcloud services list --enabled --project csye6225-414117

terraform apply -var 'region=us-east1' -var 'vpc_name=app-vpc-demo' -var 'zone=us-east1-a'