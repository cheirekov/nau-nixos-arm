{ lib, stdenv, buildPackages, fetchFromGitHub, pkg-config, popt }:

stdenv.mkDerivation rec {
  pname = "efivar";
  version = "39";

  outputs = [ "bin" "out" "dev" "man" ];

  src = fetchFromGitHub {
    owner = "rhboot";
    repo = "efivar";
    rev = "${version}";
    hash = "sha256-s/1k5a3n33iLmSpKQT5u08xoj8ypjf2Vzln88OBrqf0=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ popt ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  # Remove '-Werror' from 'src/include/defaults.mk'
  preConfigure = ''
    sed -i 's/-Werror//g' src/include/defaults.mk
  '';

  # Suppress specific warnings
  NIX_CFLAGS_COMPILE = [
    "-Wno-error=format"
    "-Wno-error=int-to-pointer-cast"
  ];

  makeFlags = [
    "prefix=$(out)"
    "libdir=$(out)/lib"
    "bindir=$(bin)/bin"
    # Exclude 'mandir' to skip man pages
    #"mandir=$(man)/share/man"
    "includedir=$(dev)/include"
    "PCDIR=$(dev)/lib/pkgconfig"
  ];

  # Skip building man pages
  buildFlags = [ "NO_MANPAGE=1" ];

  meta = with lib; {
    description = "Tools and library to manipulate EFI variables";
    homepage = "https://github.com/rhboot/efivar";
    platforms = platforms.linux;
    license = licenses.lgpl21Only;
  };
}
