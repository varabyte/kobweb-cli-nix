{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  jdk25,
  jdk ? jdk25,
  gradle-packages,
  gradlePackage ? null
}:
let
  gradleMetadata = import ../gradle-metadata.nix;
  gradleWrapped = if gradlePackage != null then gradlePackage else (gradle-packages.mkGradle {
    inherit (gradleMetadata) version hash;
    defaultJava = jdk;
  }).wrapped;
  kobwebMetadata = import ../kobweb-metadata.nix;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "kobweb-cli-src";
  inherit (kobwebMetadata) version;

  src = fetchFromGitHub {
    owner = "varabyte";
    repo = "kobweb-cli";
    tag = "v${finalAttrs.version}";
    hash = kobwebMetadata.srcHash;
  };

  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  gradleUpdateTask = "dependencies --write-verification-metadata sha256";
  gradleBuildTask = "assembleShadowDist";

  nativeBuildInputs = [
    gradleWrapped
  ];

  mitmCache = gradleWrapped.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp -r kobweb/build/scriptsShadow/* $out/bin
    cp -r kobweb/build/libs/* $out/lib
    chmod +x $out/bin/kobweb
    substituteInPlace $out/bin/kobweb \
      --replace-fail 'JAVACMD=java' 'JAVACMD=${lib.getExe jdk}' \
      --replace-fail 'if ! command -v java >/dev/null 2>&1' 'if [ ! -x "$JAVACMD" ]'
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/varabyte/kobweb-cli";
    changelog = "https://github.com/varabyte/kobweb-cli/releases/tag/v${finalAttrs.version}";
    description = "CLI binary that drives the interactive Kobweb experience";
    mainProgram = "kobweb";
    platforms = lib.platforms.unix;
    license = lib.licenses.asl20;
  };
})
