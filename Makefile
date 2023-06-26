OPENSHIFT_VERSION ?= 4.13.3
CONTAINER_MANAGER ?= podman

# Image URL to use all building/pushing image targets
IMG ?= quay.io/rhqp/microshift-backend-e2e:v${OPENSHIFT_VERSION}
OS ?= $(shell go env GOOS)
ARCH ?= $(shell go env GOARCH)

# Build the container image
.PHONY: oci-build
oci-build:
# Transform openshift_version to remove Z version number
	${CONTAINER_MANAGER} build -t ${IMG}-${OS}-${ARCH} -f Containerfile --build-arg=OPENSHIFT_VERSION=$(basename ${OPENSHIFT_VERSION}) --build-arg=OS=${OS} --build-arg=ARCH=${ARCH} .

# Build the container image
.PHONY: oci-push
oci-push: 
	${CONTAINER_MANAGER} push ${IMG}-${OS}-${ARCH}