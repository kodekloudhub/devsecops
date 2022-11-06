#Set Compute Zone
gcloud config set compute/zone us-central1-a

#Create ALLOW ALL Ingress Rule
gcloud compute firewall-rules create allow-all \
		--direction=INGRESS \
		--priority=1000 \
		--network=default \
		--action=ALLOW \
		--rules=all \
		--source-ranges=0.0.0.0/0 \
		--target-tags=allow-all	

#Create a Static IP to use it as a GCE External IP Address
gcloud compute addresses create static-ip --region=us-central1

#Fetch the Static IP 
gcloud compute addresses describe static-ip --region=us-central1

#Create GCE Instance
gcloud compute instances create devsecops-cloud --zone=us-central1-a \
    --image=ubuntu-1804-bionic-v20210514 \
    --image-project=ubuntu-os-cloud \
    --machine-type=e2-standard-4 \
    --address=<add-static-ip-from-previous-step> \
    --network-tier=PREMIUM \
    --boot-disk-size=512GB \
    --tags=allow-all 

gcloud compute ssh dev-cloud