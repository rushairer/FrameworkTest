#!/bin/sh

#  build_sdks.sh
#
#  Created by Abenx on 2021/2/27.
#

ROOT_DIR=`PWD`
BUILD_DIR=$ROOT_DIR/\build
TARGET_LIST=(FrameworkTest)

clean() {
rm -rf build/*
mkdir -p build/release
}

build() {
for element in ${TARGET_LIST[@]}
do
buildTarget $element
done
}

buildTarget() {
cd $ROOT_DIR

xcodebuild archive \
-scheme $1 \
-configuration Release \
-destination 'generic/platform=iOS' \
-archivePath './build/'$1'.framework-iphoneos.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild archive \
-scheme $1 \
-configuration Release \
-destination 'generic/platform=iOS Simulator' \
-archivePath './build/'$1'.framework-iphonesimulator.xcarchive' \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
-framework './build/'$1'.framework-iphonesimulator.xcarchive/Products/Library/Frameworks/'$1'.framework' \
-framework './build/'$1'.framework-iphoneos.xcarchive/Products/Library/Frameworks/'$1'.framework' \
-output './build/'$1'.xcframework'

BundleShortVersion=`xcodebuild -scheme $1 -showBuildSettings | grep MARKETING_VERSION | tr -d 'MARKETING_VERSION ='`
BundleVersion=`xcodebuild -scheme $1 -showBuildSettings | grep CURRENT_PROJECT_VERSION | tr -d 'CURRENT_PROJECT_VERSION ='`

cd $BUILD_DIR/$1.framework-iphoneos.xcarchive/Products/Library/Frameworks
tar zcf $BUILD_DIR/release/$1-framework-iphoneos-$BundleShortVersion-$BundleVersion.tar.gz $1.framework

cd $BUILD_DIR/$1.framework-iphonesimulator.xcarchive/Products/Library/Frameworks
tar zcf $BUILD_DIR/release/$1-framework-iphonesimulator-$BundleShortVersion-$BundleVersion.tar.gz $1.framework

cd $BUILD_DIR
tar zcf $BUILD_DIR/release/$1-xcframework-$BundleShortVersion-$BundleVersion.tar.gz $1.xcframework

cd $ROOT_DIR
}

clean
build
