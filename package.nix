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
    pkgs.cacert
    (pkgs.python39.withPackages (ps: [ ps.pip ps.setuptools ]))
  ];
  src = ./.;
  installPhase = ''
    PYTHONPYCACHEPREFIX=./ pip install \
        -r requirements.txt \
        -t $out/libs/python
    LAYER_DIR=$out/libs/python/pychromeless
    mkdir -p $LAYER_DIR/bin
    cp -r ./src/* $LAYER_DIR/
    cp -r ${chromeium}/* $LAYER_DIR/bin/
    cp -r ${chromedriver}/* $LAYER_DIR/bin/
    find $out/libs/python -type f -name '*.c' -delete
    find $out/libs/python -type f -name '*.pyc' -delete
    find $out/libs/python -type f -name '*.so' -exec strip -s {} +
  '';
}
