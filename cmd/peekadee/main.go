package main

import (
	"github.com/gebhn/peekadee/internal/config"
	"github.com/gebhn/peekadee/internal/db"
)

func main() {
	conn, err := db.NewDB(config.MustGetConnectionString())
	if err != nil {
		panic(err)
	}
	if err := conn.Ping(); err != nil {
		panic(err)
	}
}
