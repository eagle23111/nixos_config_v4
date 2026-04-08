{
  perSystem = {
    pkgs,
    inputs',
    ...
  }: {
    packages.zapretMod = pkgs.zapret.overrideAttrs (oldAttrs: let
      tlsClientHelloMax = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Flowseal/zapret-discord-youtube/22a9ca3bc067441789c83bd80c00d38e54be51c4/bin/tls_clienthello_max_ru.bin";
        sha256 = "TuCHCr4KAShgCwCVGJmHuh0hDa6L+WO8clr/Sc+SJiQ=";
      };
      stub = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/Flowseal/zapret-discord-youtube/22a9ca3bc067441789c83bd80c00d38e54be51c4/bin/stun.bin";
        sha256 = "nNVGkwl4DKVsC9lyZlJKSMfuUp0Cwxec/ssgsmCllkE=";
      };
    in {
      installPhase = ''
        ${oldAttrs.installPhase}
        # mkdir -p $out/usr/share/zapret/files/fake
        cp ${tlsClientHelloMax} $out/usr/share/zapret/files/fake/tls_clienthello_max_ru.bin
        cp ${stub} $out/usr/share/zapret/files/fake/stub.bin
      '';
    });
  };
}
