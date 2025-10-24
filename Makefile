BINDIR := ./bin
PKGDIR := ./build/package/peekadee
BIN    := peekadee

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
#  test

.PHONY: test
test:
	go test -race -v -count=$(COUNT) ./...

# -----------------------------------------------------------------
#  generate

.PHONY: generate
generate: $(SQLC) $(PKGDIR)/schema/schema.sql $(SQLGEN)/.sqlgen

$(PKGDIR)/dump/.extracted:
	@./scripts/extract-migrations.sh 
	@touch $(PKGDIR)/dump/.extracted

$(PKGDIR)/schema/schema.sql: $(PKGDIR)/dump/.extracted
	@until docker exec mysql mysqladmin ping -u root -p$(DB_PASSWORD) --silent 2>/dev/null; do \
		sleep 1; \
	done
	@mkdir -p $(PKGDIR)/schema
	@docker exec mysql mysqldump \
	  -u root \
	  -p$(DB_PASSWORD) \
	  --no-data \
	  --skip-triggers \
	  --skip-add-drop-table \
	  $(DB_NAME) > $(PKGDIR)/schema/schema.sql

.SECONDEXPANSION:
$(SQLGEN)/.sqlgen: $(PKGDIR)/schema/schema.sql $$(SQLSRC)
	$(SQLC) -f $(PKGDIR)/sqlc.yaml generate
	@sed -i \
		's/Casttime\s\+int32\s\+`json:"casttime_"`/Casttime_ int32 `json:"casttime_"`/' \
		$(SQLGEN)/*.go
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
	GO111MODULE=on go list -f '{{.Dir}}' ./... | \
				xargs $(GOIMPORTS) -w -local github.com/gebhn/peekadee

.PHONY: clean
clean:
	rm -rf $(SQLGEN)
	rm -rf $(BINDIR)
	rm -rf $(PKGDIR)/schema
	rm -rf $(PKGDIR)/dump
