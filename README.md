# Blazor Accessibility Testing

> [!WARNING]
> This repo is intended for use by the ASP.NET Core team and likely doesn't serve any general-purpose use case

This repo contains scripts to automatically generate variations of ASP.NET project templates for the purposes of validating accessibility. Each script performs a series of edits to automate steps that mimic each framework's "Getting started" tutorial.

A generated project can be run locally by running the following from the project's folder:

```PowerShell
dotnet ef database update
dotnet run
```

Generated template variations are included in this repo. To regenerate a template, run the script in the `scripts` folder that does so. For example, from the repo root:

```PowerShell
# Generate a Blazor Web App targeting .NET 8
.\scripts\GenerateBlazorWebApp.ps1 -Tfm "net8.0"

# Generate a Blazor Web App targeting .NET 9
# The "-Prerelease" switch allows the script to utilize prerelease versions of nuget packages and dotnet tools
.\scripts\GenerateBlazorWebApp.ps1 -Tfm "net9.0" -Prerelease
```
