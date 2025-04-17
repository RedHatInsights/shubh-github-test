package main

import (
	"fmt"
	"testing"
)

func TestRandomFunction(t *testing.T) {
	// Test multiple calls to ensure we get valid random numbers
	c := make(chan int)

	for i := 0; i < 100; i++ {
		fmt.Println("start")
		go RandomFunction(c)
		result := <-c

		// Verify that the random number is not negative
		if result < 0 {
			t.Errorf("RandomFunction() returned negative number: %d", result)
		}

		fmt.Println("test complete")
	}
}

func TestRandomFunctionUniqueness(t *testing.T) {
	// Test that we get different numbers (though there's a tiny chance they could be the same)
	dc1 := make(chan int)
	dc2 := make(chan int)
	go RandomFunction(dc1)
	go RandomFunction(dc2)

	first := <-dc1
	second := <-dc2
	if first == second {
		t.Log("Warning: Generated same random number twice. This is possible but rare.")
	}
}
