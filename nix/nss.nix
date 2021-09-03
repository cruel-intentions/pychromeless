{ pkgs }:
pkgs.nss.overrideAttrs (oldAttrs: oldAttrs // {
  propagatedBuildInputs = [ pkgs.nspr ];
  buildPhase =
    let
      getArch = platform:
        if platform.isx86_64 then "x64"
        else platform.parsed.cpu.name;
      target = getArch pkgs.stdenv.hostPlatform;
      host = getArch pkgs.stdenv.buildPlatform;
    in
    ''
      runHook preBuild
      sed -i 's|nss_dist_dir="$dist_dir"|nss_dist_dir="'$out'"|;s|nss_dist_obj_dir="$obj_dir"|nss_dist_obj_dir="'$out'"|' build.sh
      ./build.sh -v --opt \
        --with-nspr=${pkgs.nspr.dev}/include:${pkgs.nspr.out}/lib \
        --system-sqlite \
        --enable-legacy-db \
        --target ${target} \
        -Dhost_arch=${host} \
        -Duse_system_zlib=1 \
        --static \
        --disable-tests
      runHook postBuild
    '';
})
