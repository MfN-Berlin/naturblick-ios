# naturblick-ios

## Design Token
When new files `base.json`, `global.json` or `dark.json` are delivered the following script must be executed

```
xcrun --sdk macosx swiftc -parse-as-library AddColors.swift -o add_colors && ./add_colors && rm add_colors
```

It is assumed that every color exists in global and dark.
