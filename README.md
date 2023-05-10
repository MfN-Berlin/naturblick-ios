# naturblick-ios

# Release a new version

* Checkout the `main` branch `git checkout main`
* Sync the repo with origin `git pull`
* Update the version in xcode to the new version
* Add the xcode project file `git add naturblick.xcodeproj/project.pbxproj`
* Commit the version update `git commit -m "Releasing version <x.y.z>"`, e.g. "Releasing version 1.2.3"
* Push the commit  `git push`
* Tag the commit `git tag v<x.y.z>`, e.g. "v1.2.3"
* Push the tag `git push origin v<x.y.z>`
* Xcode cloud will now build the new released version and add it to test flight

## Design Token
When new files `base.json`, `global.json` or `dark.json` are delivered the following script must be executed

```
xcrun --sdk macosx swiftc -parse-as-library AddColors.swift -o add_colors && ./add_colors && rm add_colors
```

It is assumed that every color exists in global and dark.
