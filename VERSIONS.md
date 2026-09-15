If you want to use pinned versions of this repo in your Nix configuration, feel free to confer with the following table
and use those values anywhere you direct Nix to fetch from GitHub, as in:

```nix
kobwebRepo = fetchTarball {
  url = "https://github.com/varabyte/kobweb-cli-nix/archive/vX.Y.Z.tar.gz";
  sha256 = "sha256-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX=";
};
```

<!--
IMPORTANT!

The following table is automatically updated by the `publish.yml` 
workflow in the `varabyte/kobweb-cli` repository.

Editing it by hand can break the script, so just don't do it -- or, be
careful!
-->

| Version | sha256 |
|---|---| 
| v0.9.23 | sha256-1J1sVEcJuogf5w+q2IebbuIizRnzhZvhtYdc9jTXu/4= |
