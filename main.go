package main

import (
	"log"
	"math/rand"
	"time"

	clowder "github.com/redhatinsights/app-common-go/pkg/api/v1"
)

func RandomFunction(c chan int) {
	c <- rand.Int()
}

func main() {

	if !clowder.IsClowderEnabled() {
		log.Println("clowder is not enabled.Loading local config")
		data, err := clowder.LoadConfig("test-config.json")
		if err != nil {
			log.Println("error while loading custom config", err)
			return
		}

		clowder.LoadedConfig = data
	}

	log.Println(clowder.LoadedConfig.Kafka.Brokers[0].Hostname)

	dc := make(chan int)

	for {
		go RandomFunction(dc)
		log.Println(<-dc)
		time.Sleep(time.Second * 2)
	}
}
