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

## Node Configuration

See `neo4j.conf`; this is the configuration that is live in the test-drive image.

## Content Stuff

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
