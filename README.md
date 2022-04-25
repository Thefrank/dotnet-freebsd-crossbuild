# dotnet-freebsd-crossbuild
Bash script and patches for building dotNET for FreeBSD under Linux

Currently working for: v6.0.3 / v6.0.201 SDK and older (check commits if you want to build old versions)

## Why would I use this?
You don't need / want SDK builds in Azure DevOPS

or

You are allergic to YAML

## How do I use this?

run as root/sudo:

1. setup.sh
2. build.sh
3. (optional) gather_nuget.sh

## How do I use the output?

For just running it please look here:

- https://github.com/dotnet/runtime/blob/main/docs/workflow/requirements/freebsd-requirements.md#running-on-freebsd

For building code, you will need:

- either the tarball or zip from `./installer/artifacts/packages/Release/Shipping/`
 - from runtime (also found in `./nuget/`):
    - Microsoft.NETCore.App.Host.freebsd-x64.VERSION.nupkg
    - Microsoft.NETCore.App.Runtime.freebsd-x64.VERSION.nupkg
 - from ASPNetCore (also found in `./nuget/`):
    - Microsoft.AspNetCore.App.Runtime.freebsd-x64.VERSION.nupkg

For building dotNET under FreeBSD natively:

- either the tarball or zip from `./installer/artifacts/packages/Release/Shipping/`
- the contents of `./nuget/`
- numerous other patches not covered here

## Can I use the NuGet packages to build for FreeBSD on other platforms?
MAYBE!

Microsoft does not have RID support for FreeBSD in its SDK. You must manually patch this in! Adjust path as needed.

BSD `sed`: `sed -i.ORI 's/osx-x64/osx-x64;freebsd-x64/' ../sdk/SDKVERSIONNUMBER/Microsoft.NETCoreSdk.BundledVersions.props`

GNU `sed`: `sed -i 's/osx-x64/osx-x64;freebsd-x64/' ../sdk/SDKVERSIONNUMBER/Microsoft.NETCoreSdk.BundledVersions.props`

You will also need these NuGet packages produced by this repo or the Azure version repo:

 - Microsoft.NETCore.App.Host.freebsd-x64.VERSION.nupkg
 - Microsoft.NETCore.App.Runtime.freebsd-x64.VERSION.nupkg
 - Microsoft.AspNetCore.App.Runtime.freebsd-x64.VERSION.nupkg

## Got Azure DevOPS version?
Yes! Please see https://github.com/Servarr/dotnet-bsd

## I am too lazy to build this! Got a prebuilt SDK?
Yes! Also covered by the above!

I try and publish it here too as a crossbuild. 

I also have a native-crossgen build here: https://github.com/Thefrank/dotnet-freebsd-native-binaries

Open a ticket if I am more than a few days behind an official release and I will try and get an update published as quick as I can
