{
  stdenv,
  fetchurl,
  buildFHSEnv,
  makeDesktopItem,
  copyDesktopItems,
}: let
  pkg = stdenv.mkDerivation (finalAttrs: {
    pname = "manatan";
    version = "6.0.99";

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
          x86_64-linux = "sha256-VkdvLpuY7A+Om3BQ/y+nrfTqrHcGoWNSr7NK+OUeb2c=";
          aarch64-linux = "sha256-feIJXVyxsP5hHO3UNLWRWfOa7Y0M6HP9OilguLifAa0=";
        };
      };

    dontBuild = true;
    dontConfigure = true;

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
      mainProgram = "manatan";
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
        curl
        dbus
        expat
        fontconfig
        freetype
        fribidi
        gdk-pixbuf
        giflib
        glib
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
        gtk3
        harfbuzz
        lcms2
        libGL
        libdrm
        libepoxy
        libgbm
        libjpeg8
        libva
        libvpl
        libx11
        libxcb
        libxcomposite
        libxdamage
        libxext
        libxfixes
        libxi
        libxkbcommon
        libxrandr
        libxrender
        libxtst
        libz
        lsof
        mpv
        nspr
        nss
        openssl
        pango
        pcsclite
        udev
        wayland
      ];
  }
