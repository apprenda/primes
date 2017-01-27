# build version
ifeq ($(origin VERSION), undefined)
	VERSION := $(shell git describe --tags --always --dirty)
endif

# build date
ifeq ($(origin BUILD_DATE), undefined)
	BUILD_DATE := $(shell date -u)
endif

# Setup some useful vars
HOST_GOOS = $(shell go env GOOS)
HOST_GOARCH = $(shell go env GOARCH)
PLATFORM = $(GLIDE_GOOS)-$(HOST_GOARCH)

GLIDE_VERSION = v0.12.3

# Build configuration
BUILD_ENV = CGO_ENABLED=0
STATIC_FLAGS = -a -installsuffix cgo
LD_FLAGS = "-X main.version=$(VERSION) -X 'main.buildDate=$(BUILD_DATE)'"

# go-bindata vendor path
GO_BINDATA_SRC = vendor/github.com/jteeuwen/go-bindata/go-bindata

# Names and repos
GIT_REPO = github.com
DOCKER_REPO = dockerhub.com
ORG = apprenda
NAME = primes
IMAGE = $(ORG)/$(NAME)
BUILD_IMAGE = $(IMAGE)-build
APP_PATH = /go/src/$(GIT_REPO)/$(ORG)/$(NAME)

ifeq ($(origin GLIDE_GOOS), undefined)
	GLIDE_GOOS := $(HOST_GOOS)
endif
ifeq ($(origin GOOS), undefined)
	GOOS := $(HOST_GOOS)
endif

ifeq ("$(shell docker images -q $(BUILD_IMAGE))", "")
	DOCKER_DEPS = build-container
endif

.PHONY: build clean clean-build-container clean-local vendor build-container docker generated help

.DEFAULT_GOAL: help
default: help

clean: clean-build-container clean-local

clean-build-container:
	-docker rmi $(BUILD_IMAGE)

clean-local:
	rm -rf tools
	rm -rf bin
	rm -rf out
	rm -rf vendor
	rm -rf generated

vendor: tools/$(PLATFORM)/glide
	./tools/$(PLATFORM)/glide install

tools/$(PLATFORM)/glide:
	mkdir -p tools
	curl -L https://github.com/Masterminds/glide/releases/download/$(GLIDE_VERSION)/glide-$(GLIDE_VERSION)-$(PLATFORM).tar.gz | tar -xz -C tools

tools/$(PLATFORM)/go-bindata: vendor
	mkdir -p tools/$(PLATFORM)
	cd $(GO_BINDATA_SRC) && go build
	mv $(GO_BINDATA_SRC)/go-bindata tools/$(PLATFORM)/go-bindata

build-container: clean
	docker build -t $(ORG)/$(NAME)-build -f Dockerfile.build .

generated: tools/$(PLATFORM)/go-bindata
	rm -rf generated
	mkdir -p generated
	tools/$(PLATFORM)/go-bindata -prefix bindata -pkg generated -o generated/bindata.go bindata

build: vendor generated
	mkdir -p bin/$(HOST_GOOS)
	$(BUILD_ENV) GOOS=$(HOST_GOOS) go build $(STATIC_FLAGS) -o bin/$(HOST_GOOS)/$(NAME) -ldflags $(LD_FLAGS) .

docker: $(DOCKER_DEPS)
	docker run --rm -v `pwd`:$(APP_PATH) -w $(APP_PATH) $(BUILD_IMAGE) "./docker-build.sh" | tar -xz
	docker build -t $(IMAGE):$(VERSION) .
	docker tag $(IMAGE):$(VERSION) $(IMAGE):latest

help:
	@cat bindata/header
	@echo ""