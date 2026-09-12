# Nix support for Kobweb

This project makes it easy for [Nix](https://nix.dev) users to use the latest Kobweb CLI. 

It is a fork of [e-psi-lon/kobweb-cli-nix](https://github.com/e-psi-lon/kobweb-cli-nix), originally released under the MIT license which we are happy to carry forward.
User [e-ψ-lon](https://github.com/e-psi-lon) did _all_ of the heavy lifting -- feature proposal, research, and implementation. We are forever
grateful for their contribution.

Installing and understanding Nix is beyond the scope of this document, but you can learn more starting
here: https://nix.dev/tutorials/

## Packages

This project provides two packages:

- `kobweb-cli-bin` - the Kobweb CLI binary, downloaded from the official release distribution.
- `kobweb-cli-src` - the Kobweb CLI, built from the latest published tag branch.

If not specified explicitly, the default package is `kobweb-cli-bin`.

## Usage

### Nix Flakes

First (assuming Nix is already installed), you must enable flakes, which are widely used by the Nix community at this
point but still technically experimental.

**If you are using Nix on Linux or Mac:**

Create `~/.config/nix/nix.conf`
```properties
experimental-features = nix-command flakes
```

**Or, if NixOs:**

Edit `/etc/nixos/configuration.nix`
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### Installing Kobweb

```bash
$ nix profile install github:varabyte/kobweb-cli-nix
# Test successful installation
$ kobweb version
```

If you'd prefer to instruct Nix to build the CLI from source, use the `kobweb-cli-src` target:

```bash
$ nix profile install github:varabyte/kobweb-cli-nix#kobweb-cli-src
```

### Updating Kobweb

```bash
$ nix profile upgrade github:varabyte/kobweb-cli-nix
```

## Modifications

The main (minor!) modifications we applied on top of the original work:

* Updated the package targets to support MacOS as well (and tested that it worked)
* Renamed the packages to `kobweb-cli-bin` and `kobweb-cli-src` which seemed to be a common convention in the Nix community.
* Set this up in a way where we will update the packages automatically when a new version of the CLI is published.

We do not intend to maintain this list of modifications going forward, but you can always see the full list of
changes by visited https://github.com/varabyte/kobweb-cli-nix/commits/main/. 