# AppIconResizer
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

AppIconResizer renders a given app icon png file into the different sizes Xcode needs for iOS projects. It also generates the required folder structure and json files. 

# Installation

## [Mint](https://github.com/yonaskolb/mint)

```sh
mint install num42/icon-resizer-swift
```

## Make

```shell
git clone https://github.com/num42/icon-resizer-swift.git
cd icon-resizer-swift
make
```

# Usage
## Examples
```shell
icon-resizer-swift --device iphone --device ipad inputIcon.png
```
Resizes `inputIcon.png` to iPhone and iPad sizes.

```shell
icon-resizer-swift --device iphone --badge badge.png --targetPath /Users/steve/dev/icons inputIcon.png
```
Resizes `inputIcon.png` to iPhone sizes with badge `badge.png` and saves it to `/Users/steve/dev/icons`.

## Parameters

Options:

* **--device**: Devices are `iphone`, `ipad`, `watch`, `ios-marketing` and `all` for all iOS resolutions. Multiple device options are also possible. When not given, all resolutions get written.
* **--badge**: Enables you to give a path to a badge image, which will be printed upon the app icon (e.g. a "Debug" badge)
* **--targetPath**: The path that the folder structure and app icons will be written in. If no path is given by the user, icons get written into current path. 

Arguments:

* **inputPath**: Path to the input app icon file
