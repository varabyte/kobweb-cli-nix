{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nix-update-script,
  jdk21,
  gradle-packages,
}:
let
  gradle = (gradle-packages.mkGradle {
    version = "9.7.1";
    hash = "sha256-rNU/HtrwLxqP+Zh5+KNLMCZhoFfZsGOunjW1UvgE0go=";
    defaultJava = jdk21;
  }).wrapped;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "kobweb-cli";
  version = "0.9.23";

  src = fetchFromGitHub {
    owner = "varabyte";
    repo = "kobweb-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+rT7GH5rYkYUxKZta1aM3Cf+XcmJW/XGEjLdhzQxAUk=";
  };

  gradleFlags = [ "-Dfile.encoding=utf-8" ];

  gradleUpdateTask = "dependencies --write-verification-metadata sha256";
  gradleBuildTask = "assembleShadowDist";

  nativeBuildInputs = [
    gradle
    makeWrapper
  ];

  mitmCache = gradle.fetchDeps {
    pkg = finalAttrs.finalPackage;
    data = ./deps.json;
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    mkdir -p $out/lib
    cp -r kobweb/build/scriptsShadow/* $out/bin
    rm -f $out/bin/kobweb.bat
    cp -r kobweb/build/libs/* $out/lib
    chmod +x $out/bin/kobweb
    wrapProgram $out/bin/kobweb \
      --prefix PATH : ${jdk21}/bin
    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    homepage = "https://github.com/varabyte/kobweb-cli";
    changelog = "https://github.com/varabyte/kobweb-cli/releases/tag/v${finalAttrs.version}";
    description = "CLI binary that drives the interactive Kobweb experience";
    mainProgram = "kobweb";
    platforms = lib.platforms.linux;
    license = lib.licenses.asl20;
  };
})
