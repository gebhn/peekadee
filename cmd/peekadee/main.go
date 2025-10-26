package main

import (
	"context"
	"log"

	"github.com/gebhn/peekadee/internal/config"
	"github.com/gebhn/peekadee/internal/db"
	"github.com/gebhn/peekadee/internal/db/sqlc"
)

func main() {
	conn, err := db.NewDB(config.MustGetConnectionString())
	if err != nil {
		panic(err)
	}
	if err := conn.Ping(); err != nil {
		panic(err)
	}

	q := sqlc.New(conn)

	npcs, _ := q.SearchNPCsByName(context.Background(), "a_skeleton")
	for _, npc := range npcs {
		lt, _ := q.GetNPCLootTable(context.Background(), npc.ID)
		drops, _ := q.GetLootTableDrops(context.Background(), lt)

		for _, drop := range drops {
			items, _ := q.GetLootDropItems(context.Background(), drop.LootdropID)
			for _, item := range items {
				log.Println(npc.Name, item.ItemName, item.Chance)
			}
		}
	}
}
