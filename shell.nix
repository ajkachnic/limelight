with (import <nixpkgs> {});
let
    zig = stdenv.mkDerivation {
    name = "zig";
    src = fetchTarball ({
        url = "https://ziglang.org/builds/zig-linux-x86_64-0.9.0-dev.1324+598db831f.tar.xz";
        sha256 = "0vpi3cwcknav7mc7yyw52hv0lf00plpqsjv77d2pvfyj79jmsr0x";
    });
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
    mkdir -p $out
    mv ./lib $out/
    mkdir -p $out/bin
    mv ./zig $out/bin
    mkdir -p $out/doc
    #mv ./langref.html $out/doc
    '';
  };

in

mkShell rec {
  buildInputs = [
    zig
    pkg-config
    patchelf
    xorg.libX11.dev
    xlibs.xorgproto
    SDL2.all
    SDL2_ttf.all
  ];
  NIX_GCC=gcc;
  NIX_SDL2_LIB=SDL2;
  NIX_SDL2_TTF_LIB=SDL2_ttf;
  NIX_LIBX11_DEV=xorg.libX11.dev;
  NIX_XORGPROTO_DEV=xlibs.xorgproto;
  NIX_SDL2_DEV=SDL2.dev;
  NIX_SDL2_TTF_DEV=SDL2_ttf; # no .dev
  # TODO with SDL_VIDEODRIVER=wayland, SDL doesn't seem to respect xkb settings eg caps vs ctrl
  # but without, sometimes causes https://github.com/swaywm/sway/issues/5227
  # SDL_VIDEODRIVER="wayland";
}

