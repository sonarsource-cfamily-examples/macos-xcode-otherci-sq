SONAR_SCANNER_VERSION=4.6.1.2450 # Find the latest version in the "MacOS" link on this page:
                                 # https://docs.sonarqube.org/latest/analysis/scan/sonarscanner/
SONAR_SERVER_URL="<url to your SonarQube server>" # To fill in
BW_OUTPUT=bw-output # same directory than the one set in `sonar-project.properties`

curl --create-dirs -sSLo $HOME/.sonar/sonar-scanner.zip "https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_SCANNER_VERSION}-macosx.zip"
unzip -o $HOME/.sonar/sonar-scanner.zip -d $HOME/.sonar/
export PATH=$HOME/.sonar/sonar-scanner-$SONAR_SCANNER_VERSION-macosx/bin:$PATH

curl --create-dirs -sSLo $HOME/.sonar/build-wrapper.zip "${SONAR_SERVER_URL}/static/cpp/build-wrapper-macosx-x86.zip"
unzip -o $HOME/.sonar/build-wrapper.zip -d $HOME/.sonar/
export PATH=$HOME/.sonar/build-wrapper-macosx-x86:$PATH

autoreconf --install
./configure
build-wrapper-macosx-x86 --out-dir $BW_OUTPUT xcodebuild clean build

sonar-scanner
