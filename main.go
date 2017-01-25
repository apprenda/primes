package main

import (
	"fmt"
	"os"

	"github.com/apprenda/primes/cmd"
)

// Set via linker flag
var version string
var buildDate string

func main() {
	primesCmd, err := cmd.NewPrimesCommand(version, buildDate, os.Stdin, os.Stdout)
	if err != nil {
		fmt.Printf("Error initializing command: %v\n", err)
		os.Exit(1)
	}
	if err = primesCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
