# microshift-backend-e2e

A wrapper on top of MicroShift upstream e2e tests to be run on hosts with a running MicroShift cluster.

## Overview

The container is based on [deliverest](https://github.com/adrianriobo/deliverest), which handles the remote execution.

## Usage

`PWD` should contain `id_rsa` (and eventually also `pull-secret`; right now this is assumed to be on the target host already, just like a custom bundle).

### Windows amd64

For debug purposes (e.g. when run outside of the sanitized environment ensured by the pipeline), use `--pull=always` policy for `podman run`. Otherwise you might end up running an old local image instead of pulling a fresh one.

```bash
TARGET_FOLDER=ms-backend-e2e
USER=crcqe
HOST=windows-crcqe.tpb.lab.eng.brq.redhat.com
PULL_SECRET_FILE="C:/Users/crcqe/crc-pull-secret"
BUNDLE_PATH="C:/Users/crcqe/Downloads/crc_microshift_hyperv_4.13.3_amd64.crcbundle"

podman run --pull=always --network=host --rm -it --name microshift-backend-e2e \
    -e TARGET_HOST=${HOST} \
    -e TARGET_HOST_USERNAME=${USER} \
    -e TARGET_HOST_KEY_PATH=/data/id_rsa \
    -e PULL_SECRET_FILE=/data/pull-secret \
    -e HOOK_SCRIPT=/hooks/assets.sh \
    -e TARGET_FOLDER=${TARGET_FOLDER} \
    -e TARGET_RESULTS=junit/junit*.xml \
    -e OUTPUT_FOLDER=/data \
    -v $PWD:/data:z \
    quay.io/rhqp/microshift-backend-e2e:v4.13.3-windows-amd64 \
        ms-backend-e2e/run.ps1 \
            -targetFolder ${TARGET_FOLDER} \
            -junitResultsPath ${TARGET_FOLDER}/junit \
            -pullSecretFile ${PULL_SECRET_FILE} \
            -bundlePath ${BUNDLE_PATH}
```

### darwin amd64

```bash
TARGET_FOLDER=ms-backend-e2e
USER=crcqe
HOST=macmini-crcqe-1.tpb.lab.eng.brq.redhat.com
PULL_SECRET_FILE="/Users/${USER}/Downloads/pull-secret"
BUNDLE_PATH="/Users/${USER}/Downloads/crc_microshift_vfkit_4.13.3_amd64.crcbundle"

podman run --pull=always --network=host --rm -it --name microshift-backend-e2e-darwin \
    -e TARGET_HOST=${HOST} \
    -e TARGET_HOST_USERNAME=${USER} \
    -e TARGET_HOST_KEY_PATH=/data/id_rsa \
    -e PULL_SECRET_FILE=/data/pull-secret \
    -e HOOK_SCRIPT=/hooks/assets.sh \
    -e TARGET_FOLDER=${TARGET_FOLDER} \
    -e TARGET_RESULTS=junit/junit*.xml \
    -e OUTPUT_FOLDER=/data \
    -v $PWD:/data:z \
    quay.io/rhqp/microshift-backend-e2e:v4.13.3-darwin-amd64 \
        ms-backend-e2e/run.sh \
            -t ${TARGET_FOLDER} \
            -p ${PULL_SECRET_FILE} \
            -r ${TARGET_FOLDER}/junit \
            -b ${BUNDLE_PATH}
```

### linux amd64

```bash
TARGET_FOLDER=ms-backend-e2e
USER=cloud-user
HOST=rhel-crcqe.tpb.lab.eng.brq.redhat.com
PULL_SECRET_FILE="/home/${USER}/Downloads/pull-secret"
BUNDLE_PATH="/home/${USER}/Downloads/crc_microshift_libvirt_4.13.3_amd64.crcbundle"

podman run --pull=always --network=host --rm -it --name microshift-backend-e2e \
    -e TARGET_HOST=${HOST} \
    -e TARGET_HOST_USERNAME=${USER} \
    -e TARGET_HOST_KEY_PATH=/data/id_rsa \
    -e PULL_SECRET_FILE=/data/pull-secret \
    -e HOOK_SCRIPT=/hooks/assets.sh \
    -e TARGET_FOLDER=${TARGET_FOLDER} \
    -e TARGET_RESULTS=junit/junit*.xml \
    -e OUTPUT_FOLDER=/data \
    -v $PWD:/data:z \
    quay.io/rhqp/microshift-backend-e2e:v4.13.3-linux-amd64 \
        ms-backend-e2e/run.sh \
            -t ${TARGET_FOLDER} \
            -p ${PULL_SECRET_FILE} \
            -r ${TARGET_FOLDER}/junit \
            -b ${BUNDLE_PATH}
```

## Updating OpenShift version

1. Create a new branch, e.g. `v4.13.3` and add all changes needed alongside this version change.
2. Merge the branch into `main`. 
3. Create a tag, e.g. `v4.13.3` and push it to `main` with `git push origin v4.13.3`. 
4. GH-Actions will trigger a build based on the presence of the new tag and push the new image to quay.io.