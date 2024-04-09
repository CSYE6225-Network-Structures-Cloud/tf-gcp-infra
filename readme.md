## GCP Commands

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
```

List Enabled APIs 
gcloud services list --enabled --project csye6225-414117

## Deleting terraform resources in a module

```
terraform destroy -target=module.vpc
```

gcloud kms keyrings create key_ring_webapp \
--location us-central1