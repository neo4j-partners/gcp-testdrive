## Overview

Google internal docs for how to create testdrives:
https://cloud.google.com/launcher/docs/partners/test-drive-single-vm

Files in this repo store the content of the test drive (the browser autoplay
guide) and notes about how the VM was set up and configured.

## Quick Deploy

```
gcloud config set project my-project-id

gcloud deployment-manager deployments create my-testdrive \
    --template deployment/install.jinja
```

## Google Stuff

Two GCP projects are relevant for this work:

```
PROJECT_ID                   NAME                    PROJECT_NUMBER
test-drive-development       test-drive-development  751718636122
test-drive-public            test-drive-public       533290682560
```

## Orbitera / Marketo Integration

[Relevant docs here](https://www.orbitera.com/marketo-joins-orbitera-callback-club/).

Ryan Fisher on the neo4j side set up the callback.

Our callback URL:

```
http://app-ab10.marketo.com/index.php/leadCapture/save
```

Magic values (check instructions above to understand how they fit in)

- AAA: ab10
- XXX-BBB-YYY: 710-RRC-335
- NNNN: 1983

## How to prepare a new VM Image (i.e. neo4j version upgrade)

- Launch a regular test drive.
- `gcloud compute ssh` into that VM, do whatever needs to be done.
- Make sure to change neo4j user password back to "testdrive" because VM setup
script expects this.  Setting initial secure password won't work if underlying VM
already has one.
- Stop the VM
- Delete the VM but keep its underlying disks: `gcloud compute instances delete td-sample-vm --keep-disks=all`
- Use the provided google disk cleanup script to prepare the disk: `./cleanup-disk.sh  --disk my-testdrive-vm --project test-drive-development --zone us-central1-a`.  Be aware this script has been buggy, the version you're provided with includes some of my manual modifications to make it work. Depending on how much time elapses, you may want to download a fresh copy from `https://storage.googleapis.com/partner-utils/disk-cleanup/cleanup-disk.zip`.
- (Disk cleanup takes ~10 minutes to complete)
- Create a fresh image from the cleaned up disk.  Note the image family here, this is critical

```
gcloud compute images create test-drive-vX-neo4j-vWhatever \
  --source-disk td-sample-cleaned-up-disk \
  --source-disk-zone whatever-zone \
  --family neo4j-test-drive
```

**Make sure to keep the image family consistent**.  This is because Orbitera will pick up the latest image in the given image family. If the image family isn't set, your new image won't affect Oribitera in any way, and you'll end up re-doing this or modifying the deployment template.  

To see the linkage between the deployment template and the image, check the `sourceImage` setting in `install.jinja`.

## Managing what Live Users Run

They always run the latest version of the image in the given image family.  So if you messed up an image, just delete it or deprecate it and you've auto-reverted to the last good one.