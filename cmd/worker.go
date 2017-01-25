package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

// NewWorkerCommand creates a new worker server
func NewWorkerCommand() *cobra.Command {
	cmd := &cobra.Command{
		Use:   "worker",
		Short: "start a primes worker server process",
		Long:  "start a primes worker server process",
		RunE: func(cmd *cobra.Command, args []string) error {
			fmt.Println("worker called")
			return nil
		},
	}

	return cmd
}
