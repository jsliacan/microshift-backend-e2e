OPENSHIFT_VERSION ?= 4.14.3
CONTAINER_MANAGER ?= podman

# Image URL to use all building/pushing image targets
IMG ?= quay.io/rhqp/microshift-backend-e2e:v${OPENSHIFT_VERSION}
TKN_IMG ?= quay.io/rhqp/microshift-backend-e2e-tkn:v${OPENSHIFT_VERSION}

TOOLS_DIR := tools
include tools/tools.mk

OS ?= $(shell go env GOOS)
ARCH ?= $(shell go env GOARCH)

# Build the container image
.PHONY: oci-build
oci-build:
# Transform openshift_version to remove Z version number
	${CONTAINER_MANAGER} build -t ${IMG}-${OS}-${ARCH} -f oci/Containerfile --build-arg=OPENSHIFT_VERSION=$(basename ${OPENSHIFT_VERSION}) --build-arg=OS=${OS} --build-arg=ARCH=${ARCH} oci

# Build the container image
.PHONY: oci-push
oci-push: 
	${CONTAINER_MANAGER} push ${IMG}-${OS}-${ARCH}

# Create tekton task bundle
.PHONY: tkn-push
tkn-push: install-out-of-tree-tools
	$(TOOLS_BINDIR)/tkn bundle push $(TKN_IMG) -f tkn/task.yaml