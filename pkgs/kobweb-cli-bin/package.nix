{
  lib,
  stdenvNoCC,
  pkgs,
  fetchurl,
  unzip,
  jdk ? pkgs.jdk25,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "kobweb-cli-bin";
  version = "0.9.23";

  src = fetchurl {
    url = "https://github.com/varabyte/kobweb-cli/releases/download/v${finalAttrs.version}/kobweb-${finalAttrs.version}.zip";
    hash = "sha256:75e92124e6f8c54814fbbab8615add5a68f2a264386bdc7d767b33e27cbe0087"; # Copied from GitHub. Nix converts it to base64 SRI internally
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
