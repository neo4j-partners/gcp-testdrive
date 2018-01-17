# gcloud-testdrive

Files related to GCP test-drive for neo4j-enterprise

Google internal docs for how to create testdrives:
https://cloud.google.com/launcher/docs/partners/test-drive-single-vm

Files in this repo store the content of the test drive (the browser autoplay
guide) and notes about how the VM was set up and configured.

## Google Stuff

Two GCP projects are relevant for this work:

```
PROJECT_ID                   NAME                    PROJECT_NUMBER
test-drive-development       test-drive-development  751718636122
test-drive-public            test-drive-public       533290682560
```

## Content Stuff

The way this repo works is that test drive content is stored in `content/*.adoc`.

`neo4j-guides` is used to generate HTML from that asciidoc, and then the resulting
content is staged to the Amazon S3 bucket guides.neo4j.com.  The google test drive
is then set up to autoplay that guide.

## Questions?

Ask David Allen <david.allen@neo4j.com> / moxious on github.
