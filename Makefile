BINDIR := ./bin
PKGDIR := ./build/package/peekadee
BIN    := peekadee
DUMP   := dump
SCHEMA := schema

GOBIN  := $(shell go env GOPATH)/bin
GOSRC  := $(shell find . -type f -name '*.go' -print) go.mod go.sum
SQLSRC := $(shell find $(PKGDIR) -type f -name '*.sql' -print)

GOIMPORTS := $(GOBIN)/goimports
SQLC      := $(GOBIN)/sqlc
MIGRATE   := $(GOBIN)/migrate

SQLGEN := ./internal/db/sqlc

LDFLAGS := -w -s

COUNT       ?= 1
DB_PASSWORD ?= password
DB_NAME     ?= database

# -----------------------------------------------------------------
#  build

.PHONY: all
all: build

.PHONY: build
build: $(BINDIR)/$(BIN) 

$(BINDIR)/$(BIN): $(GOSRC) $(SQLGEN)/.sqlgen
	go build -trimpath -ldflags '$(LDFLAGS)' -o $(BINDIR)/$(BIN) ./cmd/$(BIN)

# -----------------------------------------------------------------
#  development

.PHONY: develop
develop: $(PKGDIR)/$(DUMP)/.extracted
	docker-compose up -d

# -----------------------------------------------------------------
#  test

.PHONY: test
test:
	go test -race -v -count=$(COUNT) ./...

# -----------------------------------------------------------------
#  generate

.PHONY: generate
generate: $(SQLC) $(PKGDIR)/$(SCHEMA)/schema.sql $(SQLGEN)/.sqlgen

.SECONDEXPANSION:
$(SQLGEN)/.sqlgen: $(PKGDIR)/schema/schema.sql $$(SQLSRC)
	$(SQLC) -f $(PKGDIR)/sqlc.yaml generate
	sed -i \
		's/Casttime\s\+int32\s\+`json:"casttime_"`/Casttime_ int32 `json:"casttime_"`/' \
		$(SQLGEN)/*.go
	touch $(SQLGEN)/.sqlgen

$(PKGDIR)/schema/schema.sql: $(PKGDIR)/dump/.extracted
	mkdir -p $(PKGDIR)/$(SCHEMA)
	docker exec mysql mysqldump \
	  -u root \
	  -p$(DB_PASSWORD) \
	  --no-data \
	  --skip-triggers \
	  --skip-add-drop-table \
	  $(DB_NAME) > $(PKGDIR)/$(SCHEMA)/schema.sql

# -----------------------------------------------------------------
#  extract

$(PKGDIR)/$(DUMP)/.extracted:
	./scripts/extract-migrations.sh 
	touch $(PKGDIR)/$(DUMP)/.extracted

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
	GO111MODULE=on go list -f '{{.Dir}}' ./... | \
				xargs $(GOIMPORTS) -w -local github.com/gebhn/$(BIN)

.PHONY: clean
clean:
	rm -rf $(SQLGEN)
	rm -rf $(BINDIR)
	rm -rf $(PKGDIR)/$(DUMP)
	rm -rf $(PKGDIR)/$(SCHEMA)
