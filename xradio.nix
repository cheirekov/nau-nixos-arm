{ stdenv, pkgs, lib, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  name = "xradio-${version}-${kernel.version}";
  version = "2020-01-21";

  src = fetchFromGitHub {
    owner = "fifteenhex";
    repo = "xradio";
    rev = "180aafb14191c78c1529d5a28ca58c7c9dcf2c55";
    sha256 = "1g4zj4zmi1b14czs153xrjas71h5jgx15a308hvm5zi9cy36r0ry";
  };

  hardeningDisable = [ "pic" ];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  phases = [ "buildPhase" "installPhase" ];

  buildPhase = ''
    cp -r ${src} xradio
    chmod -R 755 xradio
    pushd xradio >/dev/null
      make \
        ARCH=arm \
        CROSS_COMPILE=armv7l-unknown-linux-gnueabihf- \
        -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
        M=$(pwd) \
        modules
    popd
  '';

  installPhase = ''
    mkdir $out
    pushd xradio >/dev/null
      make \
        ARCH=arm \
        CROSS_COMPILE=armv7l-unknown-linux-gnueabihf- \
        -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
        M=$(pwd) \
        INSTALL_MOD_PATH=$out \
        modules_install
    popd
  '';
}