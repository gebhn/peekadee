// Package config manages environment variables
package config

import (
	"fmt"
	"os"
)

func MustGetConnectionString() string {
	return mustReadEnvVar("CONNECTION_STRING", "mysql://user:password@tcp(host:port)/dbname")
}

func mustReadEnvVar(envVar, suggestion string) string {
	if value, ok := os.LookupEnv(envVar); ok {
		return value
	}
	panic(fmt.Sprintf("env var %s is not set, suggested value: %s", envVar, suggestion))
}
