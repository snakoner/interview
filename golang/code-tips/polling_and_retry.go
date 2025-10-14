// status polling with pollInterval and retry callback to retrigger status polling
package main

import (
	"fmt"
	"sync"
	"time"
)

type Service struct {
	pollInterval time.Duration
	retryMap     sync.Map
}

func NewService(pollInterval time.Duration) *Service {
	return &Service{
		pollInterval: pollInterval,
	}
}

func (s *Service) GetRetryChan(id string) chan bool {
	cAny, _ := s.retryMap.LoadOrStore(id, make(chan bool, 1))
	return cAny.(chan bool)
}

const (
	reasonRetry   = "retry"
	reasonPolling = "polling"
)

func (s *Service) Polling(id string) {
	for {
		var reason string
		select {
		case <-time.After(s.pollInterval):
			reason = reasonPolling
		case <-s.GetRetryChan(id):
			reason = reasonRetry
		}

		fmt.Printf("reason: %s\n", reason)

		switch reason {
		case reasonRetry:
			return
		case reasonPolling:
			break
		}
	}
}

func main() {
	s := NewService(time.Second * 10)
	wg := sync.WaitGroup{}
	wg.Add(1)
	go func() {
		defer wg.Done()
		s.Polling("1234")
	}()

	time.Sleep(time.Second * 2)
	s.GetRetryChan("1234") <- true

	wg.Wait()
}
