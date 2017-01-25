package worker

import (
	"github.com/golang-collections/go-datastructures/bitarray"
)

// EratosthenesOdd calculates prime numbers in given range inclusive
func EratosthenesOdd(from uint64, to uint64, c chan uint64) {
	size := (to - from + 1) / 2

	// initialize all candidates as prime
	primes := bitarray.NewBitArray(size, true)

	var i uint64
	for i = 3; i*i <= to; i += 2 {

		// skip numbers before current slice
		var minj uint64
		minj = ((from + i - 1) / i) * i
		if minj < i*i {
			minj = i * i
		}

		// start value must be odd
		if (minj & 1) == 0 {
			minj++
		}

		// find all odd non-primes
		for j := minj; j <= to; j += 2 * i {
			index := j - from
			primes.ClearBit(index / 2)
		}
	}

	itr := primes.Blocks()
	for itr.Next() {
		value, _ := itr.Value()
		c <- value + from
	}
}
