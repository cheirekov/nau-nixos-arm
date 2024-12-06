{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "xradio-wireless-firmware";
  version = "2020-11-28";

  src = fetchFromGitHub {
    owner = "armbian";
    repo = "firmware";
    rev = "8dbb28d2ee8fa3d5f67a9d9dbc64c3d2b3b0adac";
    sha256 = "02f5cz6zjwps44fkzvnanbq5gsla2g24daylykx74lqa1m7byswp";
  };

  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/firmware/xr819"

    for filename in $src/xr819/*.bin; do
      cp "$filename" "$out/lib/firmware/xr819"
      echo $filename
    done

    runHook postInstall
  '';
}