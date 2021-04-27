#! /bin/bash

set -e

##Tags (NOT BRANCH)
##NOTE1: dotnet5 installer (aka SDK version number) is currently under v5.0.2xx but originally was v5.0.1xx for v5.0.0 to v5.0.3 and is why revision numbers do not match
##NOTE2: For best results use all the same tags as found here: https://github.com/dotnet/core/tags for each component. 

RUNTIMETAG=v5.0.5
ASPNETTAG=v5.0.5
INSTALLERTAG=v5.0.202

####

## Build Runtime Block
git clone --depth 1 --branch $RUNTIMETAG https://github.com/dotnet/runtime.git
sed -i '/\/dnceng\/internal\//d' runtime/NuGet.config
### Build Runtime in Docker (we look for the freebsd 11 variant as it still has support until end of 2021 and gives most compatibility)
DOTNET_DOCKER_TAG="mcr.microsoft.com/dotnet-buildtools/prereqs:$(curl -s https://raw.githubusercontent.com/dotnet/versions/master/build-info/docker/image-info.dotnet-dotnet-buildtools-prereqs-docker-main.json | jq -r '.repos[0].images[] | select(.platforms[0].dockerfile | contains("freebsd/11")) | .platforms[0].simpleTags[0]')"
docker run -e ROOTFS_DIR=/crossrootfs/x64 -v $(pwd)/runtime:/runtime $DOTNET_DOCKER_TAG /runtime/build.sh -c Release -cross -os freebsd -ci /p:OfficialBuildId=$(date +%Y%m%d)-99

######

## Build AspNetCore
git clone --recursive --depth 1 --branch $ASPNETTAG https://github.com/dotnet/aspnetcore.git
### Fixup (adds support for RID freebsd-x64, removes Microsoft internal NuGet feeds because Microsoft does not do this!)
sed -i '/linux-x64;/a \ \ \ \ \ \ freebsd-x64;' aspnetcore/Directory.Build.props
sed -i '/<LatestPackageReference Include="Microsoft.NETCore.App.Runtime.linux-x64" \/>/a \ \ \ \ <LatestPackageReference Include="Microsoft.NETCore.App.Runtime.freebsd-x64" \/>' aspnetcore/eng/Dependencies.props
sed -i '/\/dnceng\/internal\//d' aspnetcore/NuGet.config
### dotnet NuGet Source Fix (add prior build output)
dotnet nuget add source ../runtime/artifacts/packages/Release/Shipping --name runtime --configfile aspnetcore/NuGet.config
### Copy Missing Item (restore will try but fail to find this so we have to add it manually)
mkdir -p aspnetcore/artifacts/obj/Microsoft.AspNetCore.App.Runtime
cp runtime/artifacts/packages/Release/Shipping/dotnet-runtime-5.*-freebsd-x64.tar.gz aspnetcore/artifacts/obj/Microsoft.AspNetCore.App.Runtime
### Build AspNetCore (no crossgen because not actually supported and it will fail if it tries)
aspnetcore/build.sh -c Release -ci --os-name freebsd -pack -nobl /p:CrossgenOutput=false /p:OfficialBuildId=$(date +%Y%m%d)-99

#####

## Build Installer
git clone --depth 1 --branch $INSTALLERTAG https://github.com/dotnet/installer.git
### Fixup (adds support for RID freebsd-x64)
git -C installer apply ../patches/0001-freebsd-support.patch
sed -i 's/NetCore5AppHostRids Include="/NetCore5AppHostRids Include="freebsd-x64;/' installer/src/redist/targets/GenerateBundledVersions.targets
sed -i 's/AspNetCore50RuntimePackRids Include="@(AspNetCore31RuntimePackRids)/AspNetCore50RuntimePackRids Include="@(AspNetCore31RuntimePackRids);freebsd-x64/' installer/src/redist/targets/GenerateBundledVersions.targets
### dotnet NuGet Source Fixes (remove historically problematic/private feed that seem to only appear here, add prior build outputs, and remove any internal feeds)
dotnet nuget remove source msbuild --configfile installer/NuGet.config || true
dotnet nuget remove source nuget-build --configfile installer/NuGet.config || true
dotnet nuget add source ../runtime/artifacts/packages/Release/Shipping --name runtime --configfile installer/NuGet.config
dotnet nuget add source ../aspnetcore/artifacts/packages/Release/Shipping --name aspnetcore --configfile installer/NuGet.config
sed -i '/\/dnceng\/internal\//d' installer/NuGet.config
### Copy Missing Items (same as aspnetcore step but we need its output too)
mkdir -p installer/artifacts/obj/redist/Release/downloads/
cp runtime/artifacts/packages/Release/Shipping/dotnet-runtime-*-freebsd-x64.tar.gz installer/artifacts/obj/redist/Release/downloads/
cp aspnetcore/artifacts/installers/Release/aspnetcore-runtime-* installer/artifacts/obj/redist/Release/downloads/
### Build Installer (yes both of those crossgen flags are needed and aspnetcore flag needed because it is not added by default)
installer/build.sh -c Release -ci -pack --runtime-id freebsd-x64 /p:OSName=freebsd /p:CrossgenOutput=false /p:OfficialBuildId=$(date +%Y%m%d)-99 /p:IncludeAspNetCoreRuntime=True /p:DISABLE_CROSSGEN=True
#Hopefully everything worked!
