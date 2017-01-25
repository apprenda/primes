# Set the build version
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
GLIDE_VERSION = v0.12.3
BUILD_ENV = CGO_ENABLED=0
STATIC_FLAGS = -a -installsuffix cgo
LD_FLAGS = "-X main.version=$(VERSION) -X 'main.buildDate=$(BUILD_DATE)'"

ifeq ($(origin GLIDE_GOOS), undefined)
	GLIDE_GOOS := $(HOST_GOOS)
endif
ifeq ($(origin GOOS), undefined)
	GOOS := $(HOST_GOOS)
endif

# Define docker container and bin names
REPO = github.com
ORG = apprenda
NAME = primes
APP_PATH = /go/src/$(REPO)/$(ORG)/$(NAME)

ifeq ("$(shell docker images -q $(ORG)/$(NAME)-build)", "")
	DOCKER_DEPS = build-container
endif

all: build

build: vendor
	mkdir -p bin/$(HOST_GOOS)
	$(BUILD_ENV) GOOS=$(HOST_GOOS) go build $(STATIC_FLAGS) -o bin/$(HOST_GOOS)/$(NAME) -ldflags $(LD_FLAGS) .

clean:
	rm -rf tools
	rm -rf bin
	rm -rf out
	rm -rf vendor

vendor: tools/$(GLIDE_GOOS)-$(HOST_GOARCH)/glide
	./tools/$(GLIDE_GOOS)-$(HOST_GOARCH)/glide install

tools/$(GLIDE_GOOS)-$(HOST_GOARCH)/glide:
	mkdir -p tools
	curl -L https://github.com/Masterminds/glide/releases/download/$(GLIDE_VERSION)/glide-$(GLIDE_VERSION)-$(GLIDE_GOOS)-$(HOST_GOARCH).tar.gz | tar -xz -C tools

build-container: clean
	docker build -t $(ORG)/$(NAME)-build -f Dockerfile.build .

docker: $(DOCKER_DEPS)
	docker run --rm -v `pwd`:$(APP_PATH) -w $(APP_PATH) $(ORG)/$(NAME)-build "./docker-build.sh" | tar -xz
	docker build -t $(ORG)/$(NAME):$(VERSION) .
	docker tag $(ORG)/$(NAME):$(VERSION) $(ORG)/$(NAME):latest