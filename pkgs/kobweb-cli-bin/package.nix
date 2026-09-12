{
  lib,
  stdenvNoCC,
  pkgs,
  fetchurl,
  unzip,
  jdk ? pkgs.jdk25,
}:
let
  kobwebMetadata = import ../kobweb-metadata.nix;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kobweb-cli-bin";
  inherit (kobwebMetadata) version;

  src = fetchurl {
    url = "https://github.com/varabyte/kobweb-cli/releases/download/v${finalAttrs.version}/kobweb-${finalAttrs.version}.zip";
    hash = kobwebMetadata.zipHash;
  };

  nativeBuildInputs = [ unzip ];

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    cd kobweb-${finalAttrs.version}
    substituteInPlace ./bin/kobweb \
      --replace-fail 'JAVACMD=java' 'JAVACMD=${lib.getExe jdk}' \
      --replace-fail 'if ! command -v java >/dev/null 2>&1' 'if [ ! -x "$JAVACMD" ]'
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin $out/lib
    cp -r bin/* $out/bin
    cp -r lib/* $out/lib
    chmod +x $out/bin/kobweb
    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/varabyte/kobweb-cli";
    changelog = "https://github.com/varabyte/kobweb-cli/releases/tag/v${finalAttrs.version}";
    description = "CLI binary that drives the interactive Kobweb experience";
    mainProgram = "kobweb";
    platforms = lib.platforms.unix;
    license = lib.licenses.asl20;
  };
})
