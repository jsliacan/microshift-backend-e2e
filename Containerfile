FROM docker.io/library/golang:1.18-alpine as builder

ARG OPENSHIFT_VERSION
ARG OS 
ARG ARCH

ENV GOOS=${OS} \
    GOARCH=${ARCH} \
    UPSTREAM=https://github.com/openshift/origin.git \
    BRANCH=release-${OPENSHIFT_VERSION}

RUN apk add git gcc g++ linux-headers curl \
    && git clone --depth 1 --branch ${BRANCH} ${UPSTREAM} \
    && cd origin \
    && go build -o ./build/ms-backend-e2e -mod=vendor -trimpath github.com/openshift/origin/cmd/openshift-tests

RUN if [[ "${OS}" == "windows" ]]; then curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/windows/${ARCH}/kubectl.exe"; else \
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${OS}/${ARCH}/kubectl"; fi 

FROM quay.io/rhqp/deliverest:v0.0.1

LABEL org.opencontainers.image.authors="Adrian Riobo<ariobolo@redhat.com>"

ENV ASSETS_FOLDER /opt/ms-backend-e2e

COPY --from=builder /go/origin/build/ms-backend-e2e /go/kubectl* ${ASSETS_FOLDER}/
ARG OS 
COPY /lib/${OS}/* /lib/common/* ${ASSETS_FOLDER}/
RUN chmod +x ${ASSETS_FOLDER}/run.* \
    && chmod +x ${ASSETS_FOLDER}/kubectl*
COPY /hooks /

