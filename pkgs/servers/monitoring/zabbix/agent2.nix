{
  lib,
  buildGoModule,
  fetchurl,
  autoreconfHook,
  pkg-config,
  libiconv,
  openssl,
  pcre,
  pcre2,
  zlib,
}:

import ./versions.nix (
  {
    version,
    hash,
    ...
  }:
  buildGoModule {
    pname = "zabbix-agent2";
    inherit version;

    src = fetchurl {
      url = "https://cdn.zabbix.com/zabbix/sources/stable/${lib.versions.majorMinor version}/zabbix-${version}.tar.gz";
      inherit hash;
    };

    modRoot = "src/go";

    vendorHash = null;

    nativeBuildInputs = [
      autoreconfHook
      pkg-config
    ];
    buildInputs = [
      libiconv
      openssl
      (if (lib.versions.major version >= "7" && lib.versions.minor version >= "4") then pcre2 else pcre)
      zlib
    ];

    # need to provide GO* env variables & patch for reproducibility
    postPatch = ''
      substituteInPlace src/go/Makefile.am \
        --replace '`go env GOOS`' "$GOOS" \
        --replace '`go env GOARCH`' "$GOARCH" \
        --replace '`date +%H:%M:%S`' "00:00:00" \
        --replace '`date +"%b %_d %Y"`' "Jan 1 1970"
    '';

    # manually configure the c dependencies
    preConfigure = ''
      ./configure \
        --prefix=${placeholder "out"} \
        --enable-agent2 \
        --enable-ipv6 \
        --with-iconv \
        --with-libpcre \
        --with-openssl=${openssl.dev}
    '';

    # zabbix build process is complex to get right in nix...
    # use automake to build the go project ensuring proper access to the go vendor directory
    buildPhase = ''
      cd ../..
      make
    '';

    installPhase = ''
      mkdir -p $out/sbin

      install -Dm0644 src/go/conf/zabbix_agent2.conf $out/etc/zabbix_agent2.conf
      install -Dm0755 src/go/bin/zabbix_agent2 $out/bin/zabbix_agent2

      # create a symlink which is compatible with the zabbixAgent module
      ln -s $out/bin/zabbix_agent2 $out/sbin/zabbix_agentd
    '';

    meta = {
      description = "Enterprise-class open source distributed monitoring solution (client-side agent)";
      homepage = "https://www.zabbix.com/";
      license =
        if (lib.versions.major version >= "7") then lib.licenses.agpl3Only else lib.licenses.gpl2Plus;
      maintainers = with lib.maintainers; [
        aanderse
        bstanderline
      ];
      platforms = lib.platforms.unix;
    };
  }
)
