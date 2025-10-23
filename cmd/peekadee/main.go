package main

import (
	"context"
	"database/sql"
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

	// if err := db.Up(conn); err != nil {
	// 	panic(err)
	// }

	queries := sqlc.New(conn)

	npcs, err := queries.GetSpawns(context.Background(), sql.NullString{String: "crushbone", Valid: true})
	if err != nil {
		panic(err)
	}

	for _, row := range npcs {
		fmt.Println(row.NpcName, row.Class)
	}

	// npcs, err := queries.GetDroppedBy(context.Background(), "words of refuge")
	// if err != nil {
	// 	panic(err)
	// }
	//
	// for _, npc := range npcs {
	// 	fmt.Println(npc.Name, npc.Chance)
	// }

	// npcs, err := queries.GetNPCsWhichDropsItemByID(context.Background(), 13006)
	// if err != nil {
	// 	panic(err)
	// }
	//
	// loot, err := queries.GetNpcLootTable(context.Background(), 38225)
	// if err != nil {
	// 	panic(err)
	// }

	// for _, item := range loot {
	// 	fmt.Println(item.Chance, item.ItemName)
	// }
	//
	// for _, npc := range npcs {
	// 	fmt.Println(npc.ID, npc.Name)
	// }

	// if err := db.Down(conn); err != nil {
	// 	panic(err)
	// }
}
