package main

import (
	"context"
	"fmt"

	"github.com/gebhn/peekadee/internal/config"
	"github.com/gebhn/peekadee/internal/db"
	"github.com/gebhn/peekadee/internal/db/sqlc"
)

func main() {
	conn, err := db.NewDB(config.MustGetConnectionString())
	if err != nil {
		panic(err)
	}

	if err := db.Up(conn); err != nil {
		panic(err)
	}

	queries := sqlc.New(conn)

	npcs, err := queries.GetNPCsWhichDropsItemByID(context.Background(), 13006)
	if err != nil {
		panic(err)
	}

	for _, npc := range npcs {
		fmt.Println(npc.ID, npc.Name)
	}

	if err := db.Down(conn); err != nil {
		panic(err)
	}
}
