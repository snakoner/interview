### Строки

```go
  s := "Hello 🤗"
  for i, val := range s {
    fmt.Println(val)  // rune (int32)
  }

  // out:
  // 104
  // 101
  // 108
  // 108
  // 111
  // 129303

  for i := 0; i < len(s); i++ {
    fmt.Println(s[i]) // byte (uint8)
  }

  // 104
  // 101
  // 108
  // 108
  // 111
  // 240
  // 159
  // 164
  // 151

```
