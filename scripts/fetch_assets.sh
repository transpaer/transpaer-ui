#!/bin/bash

VERSION="0.1.2"
DOWNLOADS="https://github.com/transpaer/transpaer-ui-assets/releases/download"
PACKAGE="transpaer_assets-$VERSION.zip"
RELEASE="$DOWNLOADS/v$VERSION/$PACKAGE"

cd transpaer_frontend && rm -rf images && wget -q $RELEASE && unzip -q $PACKAGE && rm $PACKAGE

