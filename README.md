# Nix support for Kobweb

This project makes it easy for [Nix](https://nix.dev) users to use the latest Kobweb CLI.

It is a fork of [e-psi-lon/kobweb-cli-nix](https://github.com/e-psi-lon/kobweb-cli-nix), originally released under the MIT license which we are happy to carry forward.
User [e-ψ-lon](https://github.com/e-psi-lon) did _all_ of the heavy lifting -- feature proposal, research, and implementation. We are forever
grateful for their contribution.

Installing and understanding Nix is beyond the scope of this document, but you can learn more starting
here: https://nix.dev/tutorials/

## Packages

This project provides two packages:

- `kobweb-cli-bin` - instructs how to fetch the Kobweb CLI binary from the official release distribution.
- `kobweb-cli-src` - instructs how to build the Kobweb CLI from the latest published tag.

If you do not specify the package explicitly in various Nix commands, the default one that will get used is
`kobweb-cli-bin`.

## Usage

### Enabling Nix flakes

First (assuming Nix is already installed), you must enable flakes, which are widely used by the Nix community at this
point but still technically experimental.

**If you are using Nix on Linux or Mac:**

Create `~/.config/nix/nix.conf`
```properties
experimental-features = nix-command flakes
```

**Or, if NixOS:**

Edit `/etc/nixos/configuration.nix` and add somewhere:
```nix
nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

### Installing Kobweb

**If you are using Nix on Linux or Mac:**

```bash
$ nix profile add github:varabyte/kobweb-cli-nix
# Test successful installation
$ kobweb version
```

If you'd prefer to instruct Nix to build the CLI from source, use the `kobweb-cli-src` target:

```bash
$ nix profile add github:varabyte/kobweb-cli-nix#kobweb-cli-src
```

**Or, if NixOS:**

Understanding your `flake.nix` file is out of scope for this document, but if you already have one, open it up and add a
reference to this project.

For example, edit `/etc/nixos/flake.nix`:
```diff
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  # ...
+ kobweb = {
+   url = "github:varabyte/kobweb-cli-nix";
+   inputs.nixpkgs.follows = "nixpkgs";
+ };
};

outputs = {
  self,
  nixpkgs,
  # ...
+ kobweb,
  ...
}: {
  nixosConfigurations.host = nixpkgs.lib.nixosSystem {
    # ...
    modules = [
      {
        nixpkgs.overlays = [
+         kobweb.overlays.default
        ];
      }

      ./configuration.nix

      ({ pkgs, ... }: {
        environment.systemPackages = with pkgs; [
+         kobweb-cli-bin # `kobweb-cli-src` could also work here 
        ];
      })
    ];
  };
};
```

> [!NOTE]
> For simplicity, we assumed a `flake.nix` where everything is all contained in a single file, but your own system may
> have a different location where you add packages to `environment.systemPackages` . Adding `kobweb-cli-bin` there instead
> should also work fine!

If you do not have one, you may consider copying this minimal `flake.nix`:
```nix
{
  description = "My NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    kobweb = {
      url = "github:varabyte/kobweb-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, kobweb, ... }: {
    # Replace "<YOUR-HOSTNAME>"!!!! In a terminal, run `hostname` to get the value
    # to use here. Then delete this comment.
    nixosConfigurations.<YOUR-HOSTNAME> = nixpkgs.lib.nixosSystem {
      modules = [
        {
          nixpkgs.overlays = [
            kobweb.overlays.default
          ];
        }

        ./configuration.nix

        ({ pkgs, ... }: {
          environment.systemPackages = [
            pkgs.kobweb-cli-bin
          ];
        })
      ];
    };
  };
}
```
> [!IMPORTANT]
> Replace `<YOUR-HOSTNAME>` before continuing! See the comment we left above in the code for how to do this.

> [!WARNING]
> The first time this flake is built, Nix will fetch the `nixpkgs` repository tree. This requires ~5–6 GiB of bandwidth
> and disk space in `/nix/store`. Ensure you have sufficient disk space before rebuilding with this flake.

When ready, rebuild:
```bash
$ sudo nixos-rebuild switch
```

*(If you did not have a `flake.nix` file, and you did not want to create one, we explain a non-flake way to install Kobweb
later in this document.)*

### Updating Kobweb

At some point in the future, you may be using the Kobweb CLI and get notified that a new version is available. This
section shows you how to upgrade.

**If you are using Nix on Linux or Mac:**

```bash
$ nix profile upgrade kobweb-cli-nix
# Or if installed from source
$ nix profile upgrade kobweb-cli-src
```
> [!TIP]
> If neither of the above names work, use `nix profile list` to see the names of what kobweb profiles are installed.

**Or, if NixOs:**

```bash
$ cd /etc/nixos
$ nix flake update kobweb
$ sudo nixos-rebuild switch
```

### The no-flake zone

If you have a Nix installation where you don't have or want flakes enabled, you can still use this project to help you
install the Kobweb CLI.

#### Building Kobweb

Nix provides the `nix-build` command which is the classic, pre-flake approach for building packages.

If you've cloned this project locally, then you can run

```bash
$ nix-build .
# or `nix-build binary.nix` also works
```

which will put the Kobweb CLI (downloaded from the official release distribution) in `./result/bin/kobweb`.

If you'd prefer to build the CLI from source, then targeting `source.nix` will work instead:

```bash
$ nix-build source.nix
```

Once built, you can call `./result/bin/kobweb` to run the CLI or symlink it to a location in your `$PATH`.

#### Nix configuration

You can have Nix manage downloading and building the Kobweb CLI for you, instead of doing it yourself with `nix-build`.
We can use `fetchTarball`, provided by Nix, for this.

> [!IMPORTANT]
> We will need to pass a version and a sha256 hash into `fetchTarball`; grab these values from [VERSIONS.md](VERSIONS.md).

Edit `/etc/nixos/configuration.nix`, and search for `environment.systemPackages` in the file (it may be commented out if
you haven't added your first package yet). We'll use the Nix overlays system to make our CLI packages available in
`pkgs`, and then add whichever one we prefer as a system package:
```nix
nixpkgs.overlays = let
  kobwebRepo = fetchTarball {
    url = "https://github.com/varabyte/kobweb-cli-nix/archive/vX.Y.Z.tar.gz";
    sha256 = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";
  };
in [
  (import "${kobwebRepo}/overlay.nix")
];

environment.systemPackages = with pkgs; [
  kobweb-cli-bin # `kobweb-cli-src` could also work here
];
```
> [!IMPORTANT]
> Note that we suggest pinning the URL to a specific version / sha, unlike the flake version earlier. Technically, you
> can set the URL to use `main` instead, as in `"https://github.com/varabyte/kobweb-cli-nix/archive/main.tar.gz"`, and
> leave out the hash, and that would work! However...
>
> With the flake version, the user is in control of when kobweb gets upgraded. With the non-flake version, referencing
> `main` would result in the Kobweb CLI being upgraded as a side effect when someone went to rebuild their NixOS system
> for any other reason.
>
> Since Nix users pride themselves on predictability, determinism, and reproducibility, we
> believe pinning to a specific version is the idiomatic approach in this case.

And then rebuild:
```bash
$ sudo nixos-rebuild switch
```

If you get notified of a new version later, simply update the kobweb metadata in `/etc/nixos/configuration.nix` with
latest. [VERSIONS.md](VERSIONS.md) will have be updated at that time. And then, again, rebuild:
```bash
$ sudo nixos-rebuild switch
```

> [!TIP]
> If you ever want to let Nix tell you what `sha256` value to use for a fetch, you can set `sha256 = ""`. At that point, you
> will get an error when rebuilding the system, which will include the correct hash to replace the hash placeholder
> with.

## Miscellaneous

### Enable `nix-ld` (NixOS only)

The Kotlin/JS toolchain (which Kobweb relies on) downloads prebuilt binaries under the hood. On NixOS, those binaries
will fail to run unless a setting called `nix-ld` is enabled.

`nix-ld` acts as a bridge for running Linux binaries on NixOS. Standard executables are hardcoded to look for the dynamic
system linker under `/lib64`, a path that does not exist on NixOS due to its isolated `/nix/store` architecture. Enabling
`nix-ld` places a lightweight shim at the that standard path, which dynamically redirects the binary to the correct
library paths inside the Nix Store.

You'll know if you need it if you hit this error during the execution of Gradle tasks:
```
Execution failed for task ':kotlinNpmInstall'.
> Process 'Resolving NPM dependencies using yarn' returns 127
```

If you see this, we recommend enabling the value explicitly in your Nix configuration.

`/etc/nixos/configuration.nix`
```diff
{ pkgs, ... }: {
+ programs.nix-ld.enable = true;
  environment.systemPackages = [
    # ...
  ];
}
```

## Modifications

The (minor!) modifications we applied on top of the original work:

* This README.
* Updated the package targets to support MacOS as well (and tested that it worked).
* Renamed the packages to `kobweb-cli-bin` and `kobweb-cli-src` which seemed to be a common convention in the Nix community.
* Extract Kobweb metadata out into its own script so that we can overwrite it when we publish a new version of the
  Kobweb CLI.

We do not intend to maintain this list of modifications going forward (or honestly expect it to change much outside of
version increases), but you can always see a full accounting of changes by
visiting https://github.com/varabyte/kobweb-cli-nix/commits/main/.