package main

import (
	"testing"
)

func TestRandomFunction(t *testing.T) {
	// Test multiple calls to ensure we get valid random numbers
	for i := 0; i < 100; i++ {
		result := RandomFunction()

		// Verify that the random number is not negative
		if result < 0 {
			t.Errorf("RandomFunction() returned negative number: %d", result)
		}
	}
}

func TestRandomFunctionUniqueness(t *testing.T) {
	// Test that we get different numbers (though there's a tiny chance they could be the same)
	first := RandomFunction()
	second := RandomFunction()

	if first == second {
		t.Log("Warning: Generated same random number twice. This is possible but rare.")
	}
}
