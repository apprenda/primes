package cmd

import (
	"fmt"
	"io"
	"runtime"

	"github.com/spf13/cobra"
)

// NewVersionCommand creates a new version command
func NewVersionCommand(version string, buildDate string, out io.Writer) *cobra.Command {
	versionCmd := &cobra.Command{
		Use:   "version",
		Short: "display the current version",
		Long:  "display the current version",
		Run: func(cmd *cobra.Command, args []string) {
			fmt.Fprintf(out, "Primes Worker:\n")
			fmt.Fprintf(out, "  Version: %s\n", version)
			fmt.Fprintf(out, "  Built: %s\n", buildDate)
			fmt.Fprintf(out, "  Go Version: %s\n", runtime.Version())
		},
	}

	return versionCmd
}
