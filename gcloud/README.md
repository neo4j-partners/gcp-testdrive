## Overview

Google internal docs for how to create testdrives:
https://cloud.google.com/launcher/docs/partners/test-drive-single-vm

Files in this repo store the content of the test drive (the browser autoplay
guide) and notes about how the VM was set up and configured.

## Quick Deploy

```
gcloud config set project test-drive-development

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

## How the Test Drive gets Launched

On the [Orbitera Test Drive Admin screen](https://neo4j.orbitera.com/c2m/testDrives), by editing the test
drive there's an item labeled "credentials".  These are the JSON credentials of a service account.

It's not obvious, but which project the test drives get launched into is a function of what service account
is provided.  The key used for deploys is the Orbitera test drive SA account in `test-drive-public`.

This in turn requires that whatever test drive development image you're using, has to be copied to the test-drive-public
project.  This encapsulates all running test drives to one place, which can be managed separately, and means that you
can do development in test-drive-development without accidentally breaking any live test drives.

Here's how to copy a development image over to production:

```
export IMAGE=test-drive-v4-neo4j-3-4-9
gcloud compute --project=test-drive-public images create $IMAGE \
   --source-image=$IMAGE --family neo4j-test-drive \
   --source-image-project=test-drive-development
```

The test drive picks up whatever the latest image is in this image family, so tagging to a family is critical.

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
- Make whatever changes you need.  E.g. `apt-get upgrade` to catch a new neo4j release.
- Ensure that the test data is still there, do not empty the db contents.
- Make sure to change neo4j user password back to "testdrive" because VM setup
script expects this.  Setting initial secure password won't work if underlying VM
already has one.
- Stop the VM
- Delete the VM but keep its underlying disks: `gcloud compute instances delete prep --keep-disks=all --project test-drive-public`
- Use the provided google disk cleanup script to prepare the disk: `cd  google-disk-cleanup && ./cleanup-disk.sh  --disk prep --project test-drive-public --zone us-east1-b`.  Be aware this script has been buggy, the version you're provided with includes some of my manual modifications to make it work. Depending on how much time elapses, you may want to download a fresh copy from `https://storage.googleapis.com/partner-utils/disk-cleanup/cleanup-disk.zip`.
- (Disk cleanup takes ~10 minutes to complete)
- Create a fresh image from the cleaned up disk.  Note the image family here, this is critical

In the install.jinja file, you select the latest VM by family.  As of the DBaaS launch with
Google at NEXT '19, moved to image family neo4j-test-drive2 because we added significant new
stuff around DNS and other features in the test drive.   Images with a family prior to 
neo4j-test-drive are older versions with different setups.

```
gcloud compute images create test-drive-v7-neo4j-3-5-3 \
  --source-disk prep \
  --source-disk-zone us-east1-b \
  --family neo4j-test-drive2 \
  --project test-drive-public
```

**Make sure to keep the image family consistent**.  This is because Orbitera will pick up the latest image in the given image family. If the image family isn't set, your new image won't affect Oribitera in any way, and you'll end up re-doing this or modifying the deployment template.  

To see the linkage between the deployment template and the image, check the `sourceImage` setting in `install.jinja`.

## Managing what Live Users Run

They always run the latest version of the image in the given image family.  So if you messed up an image, just delete it or deprecate it and you've auto-reverted to the last good one.
