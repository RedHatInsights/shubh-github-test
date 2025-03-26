package main

import (
	"fmt"
	"math/rand"
)

func RandomFunction() int {
	return rand.Int()
}

func main() {
	rV := RandomFunction()
	fmt.Println("Random generated value", rV)
}
