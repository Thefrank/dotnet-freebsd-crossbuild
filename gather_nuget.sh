#! /bin/bash

mkdir nuget
cp -r ./runtime/artifacts/packages/Release/*/*.nupkg ./nuget/
cp -r ./aspnetcore/artifacts/packages/Release/*/*.nupkg ./nuget/