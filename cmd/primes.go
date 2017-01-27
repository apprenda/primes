package cmd

import (
	"errors"
	"io"

	"github.com/apprenda/primes/generated"
	"github.com/spf13/cobra"
)

// NewPrimesCommand creates a new worker command
func NewPrimesCommand(version string, buildDate string, in io.Reader, out io.Writer) (*cobra.Command, error) {

	header, err := generated.Asset("header")
	if err != nil {
		return nil, errors.New("header asset not found")
	}

	headerString := string(header)

	cmd := &cobra.Command{
		Use:   "primes",
		Short: "primes is a distributed system for calculating prime numbers",
		Long: headerString + "\n\n" + `primes is a distributed system for calculating prime numbers
		
primes calculation is done using the sieve of Eratosthenes
more information is available at https://github.com/apprenda/primes`,
		Run: func(cmd *cobra.Command, args []string) {
			cmd.Help()
		},
		SilenceUsage:  false,
		SilenceErrors: true,
	}

	cmd.AddCommand(NewVersionCommand(version, buildDate, out))
	cmd.AddCommand(NewWorkerCommand())
	cmd.AddCommand(NewManagerCommand())

	return cmd, nil
}
