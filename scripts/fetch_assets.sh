#!/bin/bash

VERSION="0.1.2"
DOWNLOADS="https://github.com/sustainity-dev/sustainity-ui-assets/releases/download"
PACKAGE="sustainity_assets-$VERSION.zip"
RELEASE="$DOWNLOADS/v$VERSION/$PACKAGE"

cd sustainity_frontend && rm -rf images && wget -q $RELEASE && unzip -q $PACKAGE && rm $PACKAGE

