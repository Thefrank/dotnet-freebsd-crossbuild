# dotnet-freebsd-crossbuild
Bash script and patches for building dotNET for FreeBSD under Linux

Currently working for: v8.0.204, 7.0.409, 6.0.422, and older (check commits and/or tags if you want to build old versions).
Built outside of repo but published here: v9.0.100-preview.3.24204.13

Scripts might require some tweaks. 

If you want a more comprehensive, repo-by-repo script setup:
@sec also has a (better) native crossgen build that can be found here: https://github.com/sec/dotnet-core-freebsd-source-build


## What is here?

Currently published here: 

FreeBSD 12.4 (EOL)
- net8 SDK <= 8.0.100
- net7 SDK <= 7.0.403
- net6 SDK <= 6.0.416

FreeBSD 13.2
- net8 SDK >= 8.0.101
- net7 SDK >= 7.0.405
- net6 SDK >= 6.0.418

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

NEW!: This public feed should provide (most) of my (recently) built items: 
- https://pkgs.dev.azure.com/IFailAt/freebsd-dotnet-runtime-nightly/_packaging/freebsd-dotnet/nuget/v3/index.json
  - Cons: As this is Azure-based it will be limited to only the RTM and the newest few releases
  - Cons: Due to limited storage this only contains FreeBSD 12.4 supported NuGets
  - Pros: Easy to add to NuGet.config or donet source list, no auth needed
- https://nuget.pkg.github.com/TheFrank/index.json
  - Cons: requires API auth but any GH account should be able to access it 
  - Pros: has all packages from this repo

OLD:
- either the tarball or zip from `./installer/artifacts/packages/Release/Shipping/`
 - from runtime (also found in `./nuget/`):
    - Microsoft.NETCore.App.Host.freebsd-x64.VERSION.nupkg
    - Microsoft.NETCore.App.Runtime.freebsd-x64.VERSION.nupkg
 - from ASPNetCore (also found in `./nuget/`):
    - Microsoft.AspNetCore.App.Runtime.freebsd-x64.VERSION.nupkg

For building dotNET under FreeBSD natively:

- either the tarball or zip from `./installer/artifacts/packages/Release/Shipping/`
- the contents of `./nuget/`
- numerous other patches not covered here if building dotNET6 or lower.

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
Yes! The Servarr teams maintains: https://github.com/Servarr/dotnet-bsd

## Updates

Open a ticket if I am more than a few days behind an official release and I will try and get an update published as quick as I can
