#!/bin/bash

set -e

cd "$(dirname "$0")"

WORKING_LOCATION="$(pwd)"
APPLICATION_NAME="permasigneriOS"

# TIMESTAMP="$(date +%s)"
# ==============================================================================

rm -rf build || true
mkdir build

cd build

rm -rf dpkg || true
mkdir dpkg

# ==============================================================================

echo "[*] starting build..."

xcodebuild -project "$WORKING_LOCATION/$APPLICATION_NAME.xcodeproj" \
    -scheme "$APPLICATION_NAME" \
    -configuration Release \
    -derivedDataPath "$WORKING_LOCATION/build/DerivedDataApp" \
    -destination 'generic/platform=iOS' \
    clean build \
    ONLY_ACTIVE_ARCH="NO" \
    CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGN_ENTITLEMENTS="" CODE_SIGNING_ALLOWED="NO" \

echo "[i] build passed, removing temp log file..."
rm -f "$TEMP_LOG_FILE"

# copy .app out of DerivedData
DD_APP_PATH="$WORKING_LOCATION/build/DerivedDataApp/Build/Products/Release-iphoneos/$APPLICATION_NAME.app"
TARGET_APP="$WORKING_LOCATION/build/$APPLICATION_NAME.app"
cp -r "$DD_APP_PATH" "$TARGET_APP"

# clean the app
codesign --remove "$TARGET_APP"
if [ -e "$TARGET_APP/_CodeSignature" ]; then
    rm -rf "$TARGET_APP/_CodeSignature"
fi
if [ -e "$TARGET_APP/embedded.mobileprovision" ]; then
    rm -rf "$TARGET_APP/embedded.mobileprovision"
fi

# make our sign
ldid -S"$WORKING_LOCATION/Entitlements.plist" "$TARGET_APP/$APPLICATION_NAME"

CONTROL_VERSION="$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$TARGET_APP/Info.plist")"
BUILD_VERSION="$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$TARGET_APP/Info.plist")"

# ==============================================================================


echo "[*] preparing package layout..."

# make dpkg layer
cd "$WORKING_LOCATION/build/dpkg"
mkdir ./Applications
cp -r "$TARGET_APP" ./Applications/
cp -r "$WORKING_LOCATION/DEBIAN" ./
sed -i '' "s/@@VERSION@@/$CONTROL_VERSION.$BUILD_VERSION/g" ./DEBIAN/control

# fix permission
cd "$WORKING_LOCATION/build/dpkg"
chmod -R 0755 DEBIAN

echo "[*] verifying binary architectures..."

cd "$WORKING_LOCATION/build/dpkg"
FILE_LIST=$(find . -type f)

echo "[*] packaging..."

cd "$WORKING_LOCATION/build/dpkg"
PKG_NAME="com.powen.permasignerios.$CONTROL_VERSION.$BUILD_VERSION.deb"
dpkg-deb -b . "../$PKG_NAME"

# print done
echo "Package is at $WORKING_LOCATION/build/$PKG_NAME"
