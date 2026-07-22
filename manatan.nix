{
  stdenv,
  fetchurl,
  libgcc,
  wayland,
  libxkbcommon,
  buildFHSEnv,
  makeDesktopItem,
  copyDesktopItems,
}: let
  pkg = stdenv.mkDerivation (finalAttrs: {
    pname = "manatan";
    version = "6.0.44";

    src = let
      selectSystem = attrs:
        attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
      system = selectSystem {
        x86_64-linux = "amd64";
        aarch64-linux = "arm64";
      };
    in
      fetchurl {
        url = "https://github.com/KolbyML/Manatan/releases/download/v${finalAttrs.version}/Manatan-v${finalAttrs.version}-Linux-${system}.tar.gz";
        sha256 = selectSystem {
          x86_64-linux = "sha256-IKkaqJClINccZ+l+gM+dXuzMkjrQNivM40g5baXJEtw=";
          aarch64-linux = "sha256-O9nb2UiLFdOEWupa0IPnxaAWyxj98F/Bt7iQCZc1nxE=";
        };
      };

    buildInputs = [
      libgcc
    ];

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -m755 -D manatan $out/bin/manatan
      runHook postInstall
    '';

    nativeBuildInputs = [copyDesktopItems];

    desktopItems = [
      (makeDesktopItem {
        name = "manatan";
        exec = "manatan";
        comment = "Seamless immersion language learning for anime, manga, novels on all platforms";
        desktopName = "Manatan";
        categories = ["Education"];
      })
    ];

    meta = {
      homepage = "https://manatan.com";
      description = "Seamless immersion language learning for anime, manga, novels on all platforms";
    };
  });
in
  buildFHSEnv {
    inherit (pkg) pname version meta;

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cp -r ${pkg}/share/applications/* $out/share/applications/
    '';

    runScript = "${pkg.outPath}/bin/manatan";

    targetPkgs = pkgs:
      with pkgs; [
        alsa-lib
        at-spi2-core
        cairo
        cups
        dbus
        expat
        fontconfig
        freetype
        gdk-pixbuf
        glib
        gtk3
        harfbuzz
        libGL
        libepoxy
        libgbm
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxi
        libxkbcommon
        libxrandr
        libz
        lsof
        mpv
        nspr
        nss
        pango
        udev
        wayland
      ];
  }
