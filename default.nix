{ pkgs ? import <nixpkgs> { }, fetchzip ? pkgs.fetchzip }:
let
  # too heavy
  # headless-chromium-rpm = builtins.fetchurl "https://mirror1.cl.netactuate.com/fedora-epel/7/x86_64/Packages/c/chromium-headless-90.0.4430.212-1.el7.x86_64.rpm";
  # chromedriver-rpm = builtins.fetchurl "https://mirror1.cl.netactuate.com/fedora-epel/7/x86_64/Packages/c/chromedriver-90.0.4430.212-1.el7.x86_64.rpm";
  nss-rpm = builtins.fetchurl "https://cdn.amazonlinux.com/blobstore/27a22ecd84fb4046a329580e8cbb0128d66cb2fd0a22ad620d07fd09e2df4ff2/nss-3.53.1-7.amzn2.x86_64.rpm";
  chromeium = fetchzip {
    url = "https://github.com/adieuadieu/serverless-chrome/releases/download/v1.0.0-57/stable-headless-chromium-amazonlinux-2.zip";
    sha256 = "sha256-hi0uaGQz1zYzzEzTUr+/tjWFQ6ukBhJEcRXSj8HG+Bg=";
  };
  chromedriver = fetchzip {
    url = "https://chromedriver.storage.googleapis.com/2.32/chromedriver_linux64.zip";
    sha256 = "sha256-o1LZQqliDM/Vu9euSEp7+TFjkz0klaApbWDg69A2HRg=";
  };
  mkdrv = pkgs.stdenv.mkDerivation;
in
mkdrv {
  name = "pychromeless";
  buildInputs = with pkgs;[
    rpm
    cpio
    expat
    cacert
    (python39.withPackages (ps: [ ps.pip ps.setuptools ]))
  ];
  src = ./.;
  installPhase = ''
    PYTHONPYCACHEPREFIX=./ pip install \
        -r requirements.txt \
        -t $out/python
    rm -rf $out/python/selenium/webdriver/firefox
    sed -i '18d' $out/python/selenium/webdriver/__init__.py
    sed -i '18d' $out/python/selenium/webdriver/__init__.py
    LAYER_DIR=$out/python/pychromeless
    mkdir -p $LAYER_DIR/bin
    mkdir -p $out/lib
    mkdir -p rpm/nss3
    cd rpm/nss3
    rpm2cpio ${nss-rpm} | cpio -idmv
    cp -r usr/lib64/* $out/lib/
    cd $src
    ls -lah
    cp --no-preserve=mode -r ./src/* $LAYER_DIR/
    cp --no-preserve=mode -r ./lib/* $out/lib/
    cp --no-preserve=mode -L ${pkgs.expat}/lib/libexpat.so.1 $out/lib/
    cp -r ${chromeium}/* $LAYER_DIR/bin/
    cp -r ${chromedriver}/* $LAYER_DIR/bin/
    chmod +wx -R $out/*
    find $out -type f -name '*.c' -delete
    find $out -type f -name '*.pyc' -delete
    find $out/lib -type f -exec strip -s {} +
    find $LAYER_DIR/bin -type f -exec strip -s {} +
  '';
}
