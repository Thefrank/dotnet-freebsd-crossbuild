#! /bin/bash

set -e

#Tags (NOT BRANCH)
#NOTE: For best results use all the same tags as found here: https://github.com/dotnet/core/tags for each component. 

RUNTIMETAG=v6.0.7
ASPNETTAG=v6.0.7
INSTALLERTAG=v6.0.302

#Use a helper script for reverse engineering BUILDID calculations
source ./common.sh

#### Build Runtime Block
git clone --depth 1 --branch $RUNTIMETAG https://github.com/dotnet/runtime.git
### Patches, if any
sed -i '/\/dnceng\/internal\//d' runtime/NuGet.config
git -C runtime apply ../patches/patch_runtimeRTM.patch
git -C runtime apply ../patches/6c2758897402e88562fa9875c2c359ac6ef15b1f.patch
### Build Runtime in Docker (we look for the freebsd 12 variant as 11 is EOL).
## We also use the helper script to make sure the BUILDID is correct
calculate_build_id $(git -C runtime tag --points-at HEAD)
DOTNET_DOCKER_TAG="mcr.microsoft.com/dotnet-buildtools/prereqs:$(curl -s https://raw.githubusercontent.com/dotnet/versions/master/build-info/docker/image-info.dotnet-dotnet-buildtools-prereqs-docker-main.json | jq -r '.repos[0].images[] | select(.platforms[0].dockerfile | contains("freebsd/12")) | .platforms[0].simpleTags[0]')"
docker run -e ROOTFS_DIR=/crossrootfs/x64 -v $(pwd)/runtime:/runtime $DOTNET_DOCKER_TAG /runtime/build.sh -c Release -cross -os freebsd -ci /p:OfficialBuildId=$OFFICIALBUILDID

######

## Build AspNetCore
git clone --recursive --depth 1 --branch $ASPNETTAG https://github.com/dotnet/aspnetcore.git
### Patches, if any
sed -i '/\/dnceng\/internal\//d' aspnetcore/NuGet.config
git -C aspnetcore apply ../patches/patch_aspnetcoreRTM.patch
### dotnet NuGet Source Fix (add prior build output)
dotnet nuget add source ../runtime/artifacts/packages/Release/Shipping --name runtime --configfile aspnetcore/NuGet.config
### Copy Missing Item (restore will try but fail to find this so we have to add it manually)
mkdir -p aspnetcore/artifacts/obj/Microsoft.AspNetCore.App.Runtime
cp runtime/artifacts/packages/Release/Shipping/dotnet-runtime-*-freebsd-x64.tar.gz aspnetcore/artifacts/obj/Microsoft.AspNetCore.App.Runtime
### Build AspNetCore (no crossgen because not actually supported and it will fail if it tries)
#From v6.0.1 forward build script is in ./eng and not ./
calculate_build_id $(git -C aspnetcore tag --points-at HEAD)
aspnetcore/eng/build.sh -c Release -ci --os-name freebsd -pack /p:CrossgenOutput=false /p:OfficialBuildId=$OFFICIALBUILDID

#####

## Build Installer
git clone --depth 1 --branch $INSTALLERTAG https://github.com/dotnet/installer.git
### Patches, if any
## adds support for RID freebsd-x64
git -C installer apply ../patches/patch_installer607.patch
### dotnet NuGet Source Fixes (remove historically problematic/private feed that seem to only appear here, add prior build outputs, and remove any internal feeds)
dotnet nuget remove source msbuild --configfile installer/NuGet.config || true
dotnet nuget remove source nuget-build --configfile installer/NuGet.config || true
dotnet nuget add source ../runtime/artifacts/packages/Release/Shipping --name runtime --configfile installer/NuGet.config || true
dotnet nuget add source ../aspnetcore/artifacts/packages/Release/Shipping --name aspnetcore --configfile installer/NuGet.config || true
sed -i '/\/dnceng\/internal\//d' installer/NuGet.config
### Copy Missing Items (same as aspnetcore step but we need its output too)
mkdir -p installer/artifacts/obj/redist/Release/downloads/
cp runtime/artifacts/packages/Release/Shipping/dotnet-runtime-*-freebsd-x64.tar.gz installer/artifacts/obj/redist/Release/downloads/
cp aspnetcore/artifacts/installers/Release/aspnetcore-runtime-* installer/artifacts/obj/redist/Release/downloads/
### Build Installer (yes both of those crossgen flags are needed and aspnetcore flag needed because it is not added by default)
calculate_build_id $(git -C installer tag --points-at HEAD)
installer/build.sh -c Release -ci -pack --runtime-id freebsd-x64 /p:OSName=freebsd /p:CrossgenOutput=false /p:OfficialBuildId=$OFFICIALBUILDID /p:IncludeAspNetCoreRuntime=True /p:DISABLE_CROSSGEN=True
#Hopefully everything worked!
