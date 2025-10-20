package db

import (
	"database/sql"
	"io"
	"os"
	"path/filepath"
	"strings"

	_ "github.com/go-sql-driver/mysql"
)

const (
	migrationsDir      = "build/package/peekadee/migrations"
	upMigrationPattern = "quarm_*.sql"
	downMigrationPath  = "drop_system.sql"
)

func Up(conn *sql.DB) error {
	return migrate(conn, upMigrationPattern)
}

func Down(conn *sql.DB) error {
	return migrate(conn, downMigrationPath)
}

func migrate(conn *sql.DB, pattern string) error {
	var path string
	var err error

	if strings.Contains(pattern, "*") {
		path, err = findMatchingFile(migrationsDir, pattern)
		if err != nil {
			return err
		}
	} else {
		path = filepath.Join(migrationsDir, pattern)
	}

	file, err := os.Open(path)
	if err != nil {
		return err
	}
	defer file.Close()

	content, err := io.ReadAll(file)
	if err != nil {
		return err
	}

	query := string(content)
	tx, err := conn.Begin()
	if err != nil {
		return err
	}
	if _, err := tx.Exec(query); err != nil {
		tx.Rollback()
		return err
	}
	if err := tx.Commit(); err != nil {
		return err
	}

	return nil
}

func findMatchingFile(dir, pattern string) (string, error) {
	matches, err := filepath.Glob(filepath.Join(dir, pattern))
	if err != nil {
		return "", err
	}
	if len(matches) == 0 {
		return "", err
	}
	return matches[0], nil
}
