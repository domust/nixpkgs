{ fetchurl, dpkg, patchelf, stdenv
}:

stdenv.mkDerivation rec {
  pname = "nordvpn";
  version = "3.8.10";

  src = fetchurl {
    url = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/${pname}_${version}_amd64.deb";
    sha256 = "e27ba637dffc766b99161805f525b87716c8d36186d09abea61f6094af87a9fe";
  };

  nativeBuildInputs = [
    dpkg
    patchelf
  ];

  phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

  unpackPhase = "dpkg -x $src unpacked";

  installPhase = ''
      mkdir -p $out
      cp -r unpacked/* $out/
      mv $out/usr/* $out
      rmdir $out/usr
  '';

  fixupPhase = ''
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/nordvpn
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/sbin/nordvpnd
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/var/lib/nordvpn/openvpn

      sed "/ExecStart/c\ExecStart=$out/sbin/nordvpnd" -i $out/lib/systemd/system/nordvpnd.service
  '';

  meta = with stdenv.lib; {
    homepage = "https://nordvpn.com";
    description = "Client for NordVPN";
    changelog = "https://repo.nordvpn.com/deb/nordvpn/debian/pool/main/${pname}_${version}_amd64.changelog";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
   };
}
