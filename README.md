# <img src="https://cdn.jsdelivr.net/gh/brogers5/chocolatey-package-multimonitortool@f92d7f6582ba2047f4b089a2ed5da97741c3163e/multimonitortool.png" width="48" height="48"/> Chocolatey Package: [MultiMonitorTool](https://community.chocolatey.org/packages/multimonitortool/)
[![Chocolatey package version](https://img.shields.io/chocolatey/v/multimonitortool.svg)](https://community.chocolatey.org/packages/multimonitortool/)
[![Chocolatey package download count](https://img.shields.io/chocolatey/dt/multimonitortool.svg)](https://community.chocolatey.org/packages/multimonitortool/)

## Install
[Install Chocolatey](https://chocolatey.org/install), and run the following command to install the latest approved version on the community repository:
```shell
choco install multimonitortool
```

Alternatively, the packages as published on the Chocolatey Community Repository (starting with v1.96) will also be mirrored on this repository's [Releases page](https://github.com/brogers5/chocolatey-package-multimonitortool/releases). The install command can also target the distributed `nupkg` file:

```shell
choco install multimonitortool.1.96.nupkg
```

## Build
[Install Chocolatey](https://chocolatey.org/install), clone this repository, and run the following command in the cloned repository:
```shell
choco pack
```

A successful build will create `multimonitortool.x.y.nupkg`, where `x.y` should be the Nuspec's `version` value at build time.

Note that Chocolatey package builds are non-deterministic. Consequently, an independently built package will fail a checksum validation against officially published packages.

## Update
This package should be automatically updated by [au](https://github.com/majkinetor/au). If it is outdated by more than a few days, please [open an issue](https://github.com/brogers5/chocolatey-package-multimonitortool/issues).

AU expects the parent directory that contains this repository to share a name with the Nuspec (`multimonitortool`). The local repository should therefore be cloned accordingly:
```shell
git clone git@github.com:brogers5/chocolatey-package-multimonitortool.git multimonitortool
```

Alternatively, a junction point can be created that points to the local repository (preferably within a repository adopting the [AU packages template](https://github.com/majkinetor/au-packages-template)):
```shell
mklink /J multimonitortool ..\chocolatey-package-multimonitortool
```

Once created, simply run `update.ps1` from within the created directory/junction point. Assuming all goes well, the Nuspec and install script should change to reflect the latest version available. This will also build a new package version using the modified files.

Before submitting a pull request, please test the package install/uninstall process using the [Chocolatey Testing Environment](https://github.com/chocolatey-community/chocolatey-test-environment) first.