#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
UNITY="/Applications/Unity/Hub/Editor/2019.2.3f1/Unity.app/Contents/MacOS/Unity"

rm "${DIR}/*.unitypackage"
${UNITY} -projectPath "${DIR}/project/" -quit -batchmode -exportPackage Assets/Plugins/StarTools "${DIR}/com.samberdino.startools.unitypackage"

exit

# iOS

cd "${DIR}/apple/StarTools/" || exit

rm -Rf ./build

xcodebuild clean -project StarTools.xcodeproj -scheme StarTools
xcodebuild build -project StarTools.xcodeproj -scheme StarTools -derivedDataPath build -configuration Release

DST="${DIR}/project/Assets/Plugins/StarTools/Platform/iOS"
rm -Rf "${DST}/*"
mv ./build/Build/Products/Release-iphoneos/StarTools.framework "${DST}/"

# Android

cd "${DIR}/google/application/" || exit

./gradlew :startools:clean
./gradlew :startools:build
./gradlew :startools:assemble

DST="${DIR}/project/Assets/Plugins/StarTools/Platform/Android"
rm -Rf "${DST}/*"
mv ./startools/build/outputs/aar/startools-release.aar "${DST}/com.samberdino.startools.aar"

# Unity

rm -f "${DIR}/*.unitypackage"
${UNITY} -projectPath "{DIR}/project/" -batchmode -exportPackage Assets/Plugins/StarTools "${DIR}/com.samberdino.startools.unitypackage"