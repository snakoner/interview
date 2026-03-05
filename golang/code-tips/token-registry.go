package main

import (
	"fmt"
	"math/big"
	"sync"
)

type Token interface {
	Name() string
	Address() string
	Decimals() int
	Tolerance() *big.Int
	MaxTransferCost() *big.Int
}

type AToken struct{ address string }

func (t *AToken) Name() string              { return "AToken" }
func (t *AToken) Address() string           { return t.address }
func (t *AToken) Decimals() int             { return 6 }
func (t *AToken) Tolerance() *big.Int       { return big.NewInt(10) }
func (t *AToken) MaxTransferCost() *big.Int { return big.NewInt(1_600_000) }

type USDTToken struct{ address string }

func (t *USDTToken) Name() string              { return "USDT" }
func (t *USDTToken) Address() string           { return t.address }
func (t *USDTToken) Decimals() int             { return 6 }
func (t *USDTToken) Tolerance() *big.Int       { return big.NewInt(10) }
func (t *USDTToken) MaxTransferCost() *big.Int { return big.NewInt(1_600_000) }

const (
	EthereumChainID = 1
	TronChainID     = 728126428

	ATokenID = 0
	USDTID   = 1

	ATokenEthereumAddress = "0x0000000000000000000000000000000000000000"
	ATokenTronAddress     = "TVywPRYUo51QfQJzQnZt68pC15kFz1ZQ6N"

	USDTEthereumAddress = "0x0000000000000000000000000000000000000001"
	USDTTronAddress     = "TVywPRYUo51QfQJzQnZt68pC15kFz1ZQ6X"
)

type TokenRegistry struct {
	mu sync.RWMutex
	m  map[uint64]map[uint16]Token
}

var (
	regOnce sync.Once
	reg     *TokenRegistry
)

func GetTokenRegistry() *TokenRegistry {
	regOnce.Do(func() {
		fmt.Println("Initializing token registry")
		reg = &TokenRegistry{m: make(map[uint64]map[uint16]Token)}
	})
	return reg
}

func (r *TokenRegistry) Get(chainID uint64, tokenID uint16) (Token, error) {
	r.mu.RLock()
	if chainTokens, ok := r.m[chainID]; ok {
		if tok, ok := chainTokens[tokenID]; ok {
			r.mu.RUnlock()
			return tok, nil
		}
	}
	r.mu.RUnlock()

	r.mu.Lock()
	defer r.mu.Unlock()

	if chainTokens, ok := r.m[chainID]; ok {
		if tok, ok := chainTokens[tokenID]; ok {
			return tok, nil
		}
	} else {
		r.m[chainID] = make(map[uint16]Token)
	}

	tok, err := construct(chainID, tokenID)
	if err != nil {
		return nil, err
	}

	r.m[chainID][tokenID] = tok

	return tok, nil
}

func construct(chainID uint64, tokenID uint16) (Token, error) {
	switch tokenID {
	case ATokenID:
		addr := ATokenEthereumAddress
		if chainID == TronChainID {
			addr = ATokenTronAddress
		}
		return &AToken{address: addr}, nil
	case USDTID:
		addr := USDTEthereumAddress
		if chainID == TronChainID {
			addr = USDTTronAddress
		}
		return &USDTToken{address: addr}, nil
	default:
		return nil, fmt.Errorf("invalid token id: %d", tokenID)
	}
}

func main() {
	r := GetTokenRegistry()

	in, err := r.Get(EthereumChainID, ATokenID)
	if err != nil {
		fmt.Println(err)
		return
	}

	out, err := r.Get(TronChainID, USDTID)
	if err != nil {
		fmt.Println(err)
		return
	}

	fmt.Println(in.Name(), in.Address())
	fmt.Println(out.Name(), out.Address())
}

/*

cmd/
    app/
        main.go

internal/
    domain/
        token/
            token.go
            registry.go
            factory.go

    service/
        order/
            service.go

    infrastructure/
        blockchain/
            ethereum/
            tron/
*/
