package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// NewManagerCommand creates a new worker server
func NewManagerCommand() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "manager",
		Short: "start a primes manager server process",
		Long:  "start a primes manager server process",
		RunE: func(cmd *cobra.Command, args []string) error {
			fmt.Println("manager called")
			return nil
		},
	}

	return cmd
}
