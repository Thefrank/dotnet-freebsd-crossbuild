# dotnet-freebsd-crossbuild
Bash script and patches for building dotNET for FreeBSD under Linux

## Why would I use this?
You don't need / want SDK builds in Azure DevOPS

or

You are allergic to YAML

## How do I use this?

run as root:

1. setup.sh
2. build.sh
3. (optional) gather_nuget.sh

## How do I use the output?

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

## Got Azure DevOPS version?
Yes! Please see https://github.com/Servarr/dotnet-bsd

## I am too lazy to build this! Got a prebuilt SDK?
Yes! Also covered by the above!
