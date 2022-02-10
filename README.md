# AppIconResizer
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

AppIconResizer renders a given app icon png file into the different sizes Xcode needs for iOS projects in pure Swift, with no special dependencies on external tools. It also generates the required folder structure and json files.

Minimum iOS Version supported is iOS 10.0

# Installation

## [Mint](https://github.com/yonaskolb/mint)

```sh
mint install num42/icon-resizer-swift
```

PRs for additional installation methods welcome!

# Usage
## Examples
```shell
mint run icon-resizer-swift icon-resizer-swift --devices iphone,ipad inputIcon.png
```

Resizes `inputIcon.png` to iPhone and iPad sizes.

```shell
mint run icon-resizer-swift icon-resizer-swift --devices iphone --badge badge.png --targetPath /Users/steve/dev/icons inputIcon.png
```

Resizes `inputIcon.png` to iPhone sizes with badge `badge.png` and saves it to `/Users/steve/dev/icons`.


Just run the tool to get all available options:

```shell
> mint run icon-resizer-swift icon-resizer-swift
🌱  Using num42/icon-resizer-swift 1.0.0 from Mintfile.
🌱  icon-resizer-swift 1.0.0 already installed
🌱  Running icon-resizer-swift 1.0.0...
Arguments:

    inputPath - The path of your input app icon.

Options:
    --devices [default: all] - The devices you need app icons for. Valid devices are iphone, ipad, watch and marketing. Use multiple devices by separating them with a comma.
    --badge - Use this if you want a badge rendered on top of your app icon. Just give the path to the badge PNG.
    --targetPath [default: /Users/admin/dev/Apps/template-app-beta-ios] - The path that the xcassets folder structure and app icons will be written to. If no path is given by the user, icons are written into the current path.
```

## Related tools

- [jkmathew/Assetizer](https://github.com/jkmathew/Assetizer) - Creates Assets from raster images
- [LinusU/RasterizeXCAssets](https://github.com/LinusU/RasterizeXCAssets) - Create AppIcons & Assets from SVGs
