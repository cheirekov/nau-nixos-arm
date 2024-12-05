{ lib, stdenv, buildPackages, fetchFromGitHub, pkg-config, popt }:

stdenv.mkDerivation rec {
  pname = "efivar";
  version = "39";

  outputs = [ "bin" "out" "dev" "man" ];

  src = fetchFromGitHub {
    owner = "rhboot";
    repo = "efivar";
    rev = version;
    hash = "sha256-s/1k5a3n33iLmSpKQT5u08xoj8ypjf2Vzln88OBrqf0=";
  };

  #patches = [ ./remove-docs.patch ];

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ popt ];
  depsBuildBuild = [ buildPackages.stdenv.cc ];

  preConfigure = ''
    # Remove '-Werror' from the compiler flags
    sed -i 's/-Werror//g' src/include/defaults.mk
    rm -rf docs
  '';

  NIX_CFLAGS_COMPILE = [
    "-Wno-error"
    "-Wno-error=format"
    "-Wno-error=int-to-pointer-cast"
  ];

makeFlags = [
  "ENABLE_DOCS=0"
  "prefix=$(out)"
  "libdir=$(out)/lib"
  "bindir=$(bin)/bin"
  "includedir=$(dev)/include"
  "PCDIR=$(dev)/lib/pkgconfig"
];

buildFlags = [ "ENABLE_DOCS=0" ];
  doCheck = false;
  dontUseParallelBuilding = true;

  meta = with lib; {
    description = "Tools and library to manipulate EFI variables";
    homepage = "https://github.com/rhboot/efivar";
    platforms = platforms.linux;
    license = licenses.lgpl21Only;
  };
}
