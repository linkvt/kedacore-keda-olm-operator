FROM registry.ci.openshift.org/ocp/builder:rhel-9-golang-1.26-openshift-5.0 AS builder

ARG BUILD_VERSION=main
ARG GIT_COMMIT=HEAD

WORKDIR /workspace
COPY . .

RUN CGO_ENABLED=0 go build -mod=vendor \
    -ldflags "-X=github.com/kedacore/keda-olm-operator/version.GitCommit=${GIT_COMMIT} -X=github.com/kedacore/keda-olm-operator/version.Version=${BUILD_VERSION}" \
    -o bin/manager cmd/main.go

FROM registry.ci.openshift.org/ocp/5.0:base-rhel9
COPY --from=builder /workspace/resources/keda.yaml /workspace/resources/keda.yaml
COPY --from=builder /workspace/resources/keda-olm-operator.yaml /workspace/resources/keda-olm-operator.yaml
COPY --from=builder /workspace/resources/keda-http-addon.yaml /workspace/resources/keda-http-addon.yaml
COPY --from=builder /workspace/bin/manager /usr/bin/
ENTRYPOINT ["/usr/bin/manager"]
