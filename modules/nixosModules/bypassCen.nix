{inputs, ...}: {
  flake.nixosModules.bypassCen = {pkgs, ...}: let
    package = inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.zapretMod;
    #package = pkgs.zapret;
    /**/
    zapretConfig1 = [
      "--filter-tcp=80,443"
      "--hostlist-domains=googlevideo.com,googleapis.com"
      "--ip-id=zero"
      "--dpi-desync=fake,multisplit"
      "--dpi-desync-split-seqovl=681"
      "--dpi-desync-split-pos=1"
      "--dpi-desync-fooling=ts"
      "--dpi-desync-repeats=8"
      "--dpi-desync-split-seqovl-pattern=${package}/usr/share/zapret/files/fake/tls_clienthello_www_google_com.bin"
      "--dpi-desync-fake-tls=${package}/usr/share/zapret/files/fake/tls_clienthello_www_google_com.bin"
      "--new"
      "--filter-udp=80,443,500,27000-27030,27036,3074,27015-27030,27036-27037,1935,3478-3480" # 27000-27030, 27036 - elite dangerous
      "--dpi-desync=fake"
      "--dpi-desync-repeats=10"
      "--dpi-desync-fake-quic=${package}/usr/share/zapret/files/fake/quic_initial_www_google_com.bin"
      "--new"
      "--filter-tcp=80,443,500,6900-6999,8080" # 6900-6999 - warframe 8080 - elite dangerous
      "--dpi-desync=fake"
      "--dpi-desync-fooling=ts"
      "--dpi-desync-repeats=6"
      "--dpi-desync-fake-tls=${package}/usr/share/zapret/files/fake/tls_clienthello_max_ru.bin"
    ];
    zapretConfig2 = [
      "--filter-udp=443"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=11"
      "--dpi-desync-fake-quic=${package}/usr/share/zapret/files/fake/quic_initial_www_google_com.bin"
      "--new"
      "--filter-udp=19294-19344,50000-50100"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=6"
      "--new"
      "--filter-tcp=2053,2083,2087,2096,8443"
      "--dpi-desync=fake,multisplit"
      "--dpi-desync-split-seqovl=681"
      "--dpi-desync-split-pos=1"
      "--dpi-desync-fooling=ts"
      "--dpi-desync-repeats=8"
      "--dpi-desync-split-seqovl-pattern=${package}/usr/share/zapret/files/fake/tls_clienthello_www_google_com.bin"
      "--dpi-desync-fake-tls=${package}/usr/share/zapret/files/fake/tls_clienthello_www_google_com.bin"
      "--new"
      "--filter-udp=443"
      "--dpi-desync=fake"
      "--dpi-desync-repeats=11"
      "--dpi-desync-fake-quic=${package}/usr/share/zapret/files/fake/quic_initial_www_google_com.bin"
      "--new"
      "--filter-tcp=80,443"
      "--dpi-desync=fake,multisplit"
      "--dpi-desync-split-seqovl=664"
      "--dpi-desync-split-pos=1"
      "--dpi-desync-fooling=ts"
      "--dpi-desync-repeats=8"
      "--dpi-desync-split-seqovl-pattern=${package}/usr/share/zapret/files/fake/tls_clienthello_max_ru.bin"
      "--dpi-desync-fake-tls=${package}/usr/share/zapret/files/fake/stun.bin"
      "--dpi-desync-fake-tls=${package}/usr/share/zapret/files/fake/tls_clienthello_max_ru.bin"
      "--dpi-desync-fake-http=${package}/usr/share/zapret/files/fake/tls_clienthello_max_ru.bin"
    ];
  in {
    services.zapret = {
      enable = true;
      package = package;
      params = zapretConfig2;
      blacklist = [
        "qwen.ai"
        "aliyuncs.com"
        "archlinux.org"
      ];
    };
    services.cloudflare-warp.enable = true;
    programs.wireshark.enable = true;
  };
}
