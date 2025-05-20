1. TreasuryCap - владелец может делать mint/burn
```move
public struct TreasuryCap<phantom T> has key, store {
    id: UID,
    total_supply: Supply<T>,
}
```

2. DenyCapV2 - владелец может блэклистить
3. 
