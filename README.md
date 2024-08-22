# Naturblick iOS

This project contains the code for the [iOS app
Naturblick](https://apps.apple.com/de/app/naturblick/id1206911194). The
project is hosted at the [Museum für Naturkunde
Berlin](https://www.museumfuernaturkunde.berlin/en).  The code is
licensed under MIT license (see [LICENSE.txt](LICENSE.txt) for details). If you want
to contribute please take a look at [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) and
[CONTRIBUTING.md](CONTRIBUTING.md).

## Open Source

We believe in the advantages of open source to foster transparency and
accountability. Anyone interested can view and verify our work. While
reusability of the code is not our primary goal, we welcome and
appreciate any feedback on the security and quality of our code. Feel
free to open up an issue or just contact us <naturblick@mfn.berlin>.

## Release a new version

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
When new files `base.json`, `global.json` or `dark.json` are delivered
the following script must be executed

```
xcrun --sdk macosx swiftc -parse-as-library AddColors.swift -o add_colors && ./add_colors && rm add_colors
```

It is assumed that every color exists in global and dark.
