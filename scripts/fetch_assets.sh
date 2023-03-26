#!/bin/bash

VERSION="0.1.0"
DOWNLOADS="https://github.com/bluedot-community/consumers-ui-assets/releases/download"
PACKAGE="consumers_assets-$VERSION.zip"
RELEASE="$DOWNLOADS/v$VERSION/$PACKAGE"

cd consumers_frontend && rm -rf images && wget -q $RELEASE && unzip -q $PACKAGE && rm $PACKAGE

