{ pkgs, fetchzip ? pkgs.fetchzip }:
let
  chromeium = fetchzip {
    url = "https://github.com/adieuadieu/serverless-chrome/releases/download/v1.0.0-57/stable-headless-chromium-amazonlinux-2.zip";
    sha256 = "sha256-hi0uaGQz1zYzzEzTUr+/tjWFQ6ukBhJEcRXSj8HG+Bg=";
  };
  chromedriver = fetchzip {
    url ="https://chromedriver.storage.googleapis.com/2.32/chromedriver_linux64.zip";
    sha256 = "sha256-o1LZQqliDM/Vu9euSEp7+TFjkz0klaApbWDg69A2HRg=";
  };
  mkdrv = pkgs.stdenv.mkDerivation;
in
mkdrv {
  name = "pychromeless";
  buildInputs = [
    pkgs.nss
    pkgs.expat
    pkgs.cacert
    (pkgs.python39.withPackages (ps: [ ps.pip ps.setuptools ]))
  ];
  src = ./.;
  installPhase = ''
    PYTHONPYCACHEPREFIX=./ pip install \
        -r requirements.txt \
        -t $out/python
    LAYER_DIR=$out/python/pychromeless
    mkdir -p $LAYER_DIR/bin
    mkdir -p $out/lib
    cp --no-preserve=mode -r ./src/* $LAYER_DIR/
    cp --no-preserve=mode -r ./lib/* $out/lib/
    cp --no-preserve=mode ${pkgs.nss}/lib/libnss3.so $out/lib/libnss3.so
    cp --no-preserve=mode -rL ${pkgs.expat}/lib/libexpat.so.1 $out/lib/
    cp --no-preserve=mode -r ${chromeium}/* $LAYER_DIR/bin/
    cp --no-preserve=mode -r ${chromedriver}/* $LAYER_DIR/bin/
    find $out -type f -name '*.c' -delete
    find $out -type f -name '*.pyc' -delete
    find $out -type f -name '*.so' -exec strip -s {} +
  '';
}
