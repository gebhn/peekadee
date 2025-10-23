BINDIR := ./bin
SQLDIR := ./build/package/peekadee
BIN    := peekadee

GOBIN  := $(shell go env GOPATH)/bin
GOSRC  := $(shell find . -type f -name '*.go' -print) go.mod go.sum
SQLSRC := $(shell find $(SQLDIR) -type f -name '*.sql' -print)

GOIMPORTS := $(GOBIN)/goimports
SQLC      := $(GOBIN)/sqlc
MIGRATE   := $(GOBIN)/migrate

SQLGEN := ./internal/db/sqlc

LDFLAGS := -w -s

COUNT ?= 1

# -----------------------------------------------------------------
#  build

.PHONY: all
all: build

.PHONY: build
build: $(BINDIR)/$(BIN)

$(BINDIR)/$(BIN): $(GOSRC)
	go build -trimpath -ldflags '$(LDFLAGS)' -o $(BINDIR)/$(BIN) ./cmd/$(BIN)

# -----------------------------------------------------------------
#  test

.PHONY: test
test:
	go test -race -v -count=$(COUNT) ./...

# -----------------------------------------------------------------
#  generate

.PHONY: generate
generate: $(SQLC) $(SQLGEN)/.sqlgen

.SECONDEXPANSION:
$(SQLGEN)/.sqlgen: $$(SQLSRC)
	$(SQLC) -f $(SQLDIR)/sqlc.yaml generate
	@sed -i 's/Casttime\s\+int32\s\+`json:"casttime_"`/Casttime_ int32 `json:"casttime_"`/' $(SQLGEN)/*.go
	@touch $(SQLGEN)/.sqlgen

# -----------------------------------------------------------------
#  dependencies

$(GOIMPORTS):
	(cd /; go install golang.org/x/tools/cmd/goimports@latest)

$(SQLC):
	(cd /; go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest)

# -----------------------------------------------------------------
#  misc

.PHONY: format
format: $(GOIMPORTS)
	GO111MODULE=on go list -f '{{.Dir}}' ./... | xargs $(GOIMPORTS) -w -local github.com/gebhn/peekadee

.PHONY: clean
clean:
	rm -rf $(SQLGEN)
	rm -rf $(BINDIR)
