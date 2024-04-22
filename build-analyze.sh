#!/bin/bash

# SonarQube needs a full clone to work correctly but some CIs perform shallow clones
# so we first need to make sure that the source repository is complete
git fetch --unshallow

export SONAR_HOST_URL="${SONAR_HOST_URL}" # Comes from a Github secret
#SONAR_TOKEN= # Access token coming from SonarQube projet creation page. In this example, it is defined in the environement through a Github secret.
export SONAR_SCANNER_VERSION="5.0.1.3006" # Find the latest version in the "Mac OS" link on this page:
                                          # https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
export BUILD_WRAPPER_OUT_DIR="bw-output" # Directory where build-wrapper output will be placed

mkdir $HOME/.sonar

# Download build-wrapper
curl -sSLo $HOME/.sonar/build-wrapper-macosx-x86.zip "${SONAR_HOST_URL}/static/cpp/build-wrapper-macosx-x86.zip"
unzip -o $HOME/.sonar/build-wrapper-macosx-x86.zip -d $HOME/.sonar/
export PATH=$HOME/.sonar/build-wrapper-macosx-x86:$PATH

# Download sonar-scanner
curl -sSLo $HOME/.sonar/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-$SONAR_SCANNER_VERSION-macosx.zip 
unzip -o $HOME/.sonar/sonar-scanner.zip -d $HOME/.sonar/
export PATH=$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-macosx/bin:$PATH

# Setup the build system
xcodebuild -project macos-xcode.xcodeproj clean

# Build inside the build-wrapper
build-wrapper-macosx-x86 --out-dir $BUILD_WRAPPER_OUT_DIR xcodebuild -project macos-xcode.xcodeproj -configuration Release

# Run sonar scanner
sonar-scanner -Dsonar.host.url="${SONAR_HOST_URL}" -Dsonar.login=$SONAR_TOKEN -Dsonar.cfamily.compile-commands=$BUILD_WRAPPER_OUT_DIR/compile-commands.json
