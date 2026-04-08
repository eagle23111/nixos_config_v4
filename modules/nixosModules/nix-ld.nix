{
  pkgs,
  inputs,
  ...
}: {
  flake.nixosModules.nixLD = {
    pkgs,
    config,
    ...
  }: {
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      # Core system and compression
      glibc
      zstd
      stdenv.cc.cc.lib
      curl
      openssl
      attr
      libssh
      bzip2
      libxml2
      acl
      libsodium
      util-linux
      xz
      systemd

      # Graphics and display (your originals + expansions)
      config.hardware.graphics.package # mesa/nvidia
      glib
      zlib
      libgccjit
      libGL
      libGLU
      libva
      libgbm
      libdrm
      vulkan-loader
      libvdpau
      libxkbcommon
      pipewire

      # X11 essentials
      libX11
      libXcomposite
      libXcursor
      libXdamage
      libXext
      libXfixes
      libXi
      libXinerama
      libXrandr
      libXrender
      libXScrnSaver
      libXxf86vm
      libxcb
      libxshmfence
      libXt
      libXtst
      libXmu

      # NVIDIA/CUDA (your originals)
      config.boot.kernelPackages.nvidiaPackages.stable
      cudaPackages.cudatoolkit

      # GUI and desktop
      gtk2
      gtk3
      glib
      pango
      cairo
      atk
      gdk-pixbuf
      fontconfig
      freetype
      dbus
      dbus-glib
      gsettings-desktop-schemas
      libnotify
      libappindicator-gtk2
      libdbusmenu-gtk2
      libindicator-gtk2

      # Audio and multimedia
      alsa-lib
      libcanberra
      libvorbis
      libogg
      flac
      libsamplerate
      libmikmod
      libtheora
      libvpx
      ffmpeg

      # Misc runtime essentials
      libelf
      nspr
      nss
      cups
      libcap
      libusb1
      libudev0-shim
      libxcrypt-legacy
      icu
      expat
      fuse
      e2fsprogs
      pciutils
      coreutils

      # Gaming/media extras
      SDL2
      SDL2_image
      SDL2_ttf
      SDL2_mixer
      SDL_image
      SDL_ttf
      SDL_mixer
      libjpeg
      libpng
      libtiff
      pixman
      librsvg
      libgcrypt
      speex
      tbb
      glew_1_10
      libcaca
    ];
  };
}
