# dotnet-freebsd-crossbuild
Bash script and patches for building dotNET for FreeBSD under Linux.
Yes. This needs an overhaul.

## NOTE(S)

VMR as of net10p7 the VMR fully supports crossbuilds! General build instructions can be found [here](https://github.com/dotnet/dotnet?tab=readme-ov-file#building)

**Ports `pkg install dotnet` will be the most direct way to get dotNET for FreeBSD**

I will try and provide the SourceBuilt artifacts and SDK under releases. NuGets will remain under both Azure feed and Github for this repo.

If you want a more comprehensive, repo-by-repo script setup: 
@sec also has a (better) native crossgen build that can be found here: https://github.com/sec/dotnet-core-freebsd-source-build

## What is here?

The Y.0.1xx branch is used for net8 and net9 due to a merging of the `sdk` and `installer` repos.

Currently working for: 
- v9.0.114 (SDK version != runtime version. Ask Microsoft why they are disjointed), 
- ~v8.0.300~ 8.0.124 (there was no 8.0.109?)

EOL: 
- ~6.0.423~ 6.0.136 (there was no 6.0.134?), and older (check commits and/or tags if you want to build old versions).

Built outside of repo but published here:

- NET9: v9.0.100 v9.0.114 (SDK version != runtime version. Ask Microsoft why they are disjointed) 
- NET10: v10.0.100-preview.1.25120.13->v10.0.103
- NET11: v11.0.100-preview.1.26104.118

- 
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

## Updates / Bugs

Open a ticket if I am more than a few days behind an official release and I will try and get an update published as quick as I can. Same with bug reports.
