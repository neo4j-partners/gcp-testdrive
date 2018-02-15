# gcloud-testdrive

Files related to GCP test-drive for neo4j-enterprise

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

## Node Configuration

See `neo4j.conf`; this is the configuration that is live in the test-drive image.

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

## Content Stuff (Browser Guides)

The way this repo works is that test drive content is stored in `content/*.adoc`.

See git submodules in this repo, a lot of this content was
borrowed from other places and just molded editorially.

### Generating Content

`neo4j-guides` is used to generate HTML from that asciidoc, and then the resulting
content is staged to the Amazon S3 bucket guides.neo4j.com.  The google test drive
is then set up to autoplay that guide.

### Deploying Content to the Test Drive

`./deploy-content.sh`

Which basically just copies generated HTML and images to the proper S3 bucket to be referenced by the test drive.  (See content hosting below)

### Local Testing Content

Run:

```
python neo4j-guides/http-server.py
```

This serves the repo from `http://localhost:8001/`.  In the neo4j instance, ensure that the following
config is set:

```
browser.remote_content_hostname_whitelist=*
```

Then simply run `:play http://localhost:8001/content/index.html`

### Content Hosting Destination

`gcloud-testdrive` folder in the `guides.neo4j.com` S3 bucket:

https://s3.console.aws.amazon.com/s3/buckets/guides.neo4j.com/gcloud-testdrive/?region=us-west-2&tab=overview

## Questions?

Ask David Allen <david.allen@neo4j.com> / moxious on github.
