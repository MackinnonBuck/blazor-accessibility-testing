param(
    [switch]$Prerelease,
    [string]$Tfm = "net8.0"
)

$PrereleaseArgs = $Prerelease ? @("--prerelease") : @()

$AppName = "RazorPagesApp"

$ModelClassName = "Movie"
$ModelPluralHumanizedName = "Movies"

$ModelClassFileContent = @"
using System.ComponentModel.DataAnnotations;

namespace $AppName.Models;

public class $ModelClassName
{
    public int Id { get; set; }
    public string? Title { get; set; }
    [DataType(DataType.Date)]
    public DateTime ReleaseDate { get; set; }
    public string? Genre { get; set; }
    public decimal Price { get; set; }
}
"@

$SeedDataClassFileContent = @"
using Microsoft.EntityFrameworkCore;
using $AppName.Models;

namespace $AppName.Data;

public static class SeedData
{
    public static void Initialize(IServiceProvider serviceProvider)
    {
        using (var context = new ApplicationDbContext(
            serviceProvider.GetRequiredService<
                DbContextOptions<ApplicationDbContext>>()))
        {
            if (context.$ModelClassName == null)
            {
                throw new ArgumentNullException("Null $ModelClassName");
            }

            if (context.$ModelClassName.Any())
            {
                return;   // DB has been seeded
            }

            context.$ModelClassName.AddRange(
                new $ModelClassName
                {
                    Title = "When Harry Met Sally",
                    ReleaseDate = DateTime.Parse("1989-2-12"),
                    Genre = "Romantic Comedy",
                    Price = 7.99M
                },

                new $ModelClassName
                {
                    Title = "Ghostbusters ",
                    ReleaseDate = DateTime.Parse("1984-3-13"),
                    Genre = "Comedy",
                    Price = 8.99M
                },

                new $ModelClassName
                {
                    Title = "Ghostbusters 2",
                    ReleaseDate = DateTime.Parse("1986-2-23"),
                    Genre = "Comedy",
                    Price = 9.99M
                },

                new $ModelClassName
                {
                    Title = "Rio Bravo",
                    ReleaseDate = DateTime.Parse("1959-4-15"),
                    Genre = "Western",
                    Price = 3.99M
                }
            );
            context.SaveChanges();
        }
    }
}
"@

$SeedDataInitializationLandmark = "var app = builder.Build();"
$SeedDataInitializationCode = @"
$SeedDataInitializationLandmark

using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;

    SeedData.Initialize(services);
}
"@

$LayoutModelPageLinkLandmark = @"
                        <li class="nav-item">
                            <a class="nav-link text-dark" asp-area="" asp-page="/Index">Home</a>
                        </li>
"@
$LayoutModelPageLink = @"
$LayoutModelPageLinkLandmark
                        <li class="nav-item">
                            <a class="nav-link text-dark" asp-area="" asp-page="/$ModelPluralHumanizedName/Index">$ModelPluralHumanizedName</a>
                        </li>
"@

$PrevPWD = $PWD;

. $PSScriptRoot\Helpers.ps1

try {
    # Remove the previously-generated app, if it exists
    if (Test-Path ".\$AppName") {
        Write-Output "Removing .\$AppName..."
        Remove-Item -Recurse -Force ".\$AppName"
    }

    # Ensure necesssary tools are installed
    dotnet tool uninstall --global dotnet-aspnet-codegenerator 2>$null
    dotnet tool uninstall --global dotnet-ef 2>$null
    dotnet tool install @PrereleaseArgs --global dotnet-aspnet-codegenerator
    dotnet tool install @PrereleaseArgs --global dotnet-ef

    # Create a new Razor Pages app
    dotnet new webapp -f $Tfm -au Individual -o ".\$AppName"
    Set-Location -Path $AppName

    # Add the model class
    New-Item -Path ".\Models" -ItemType Directory
    $ModelClassFileContent | Out-File -FilePath ".\Models\$ModelClassName.cs"

    # Scaffold new pages from model
    dotnet add package Microsoft.EntityFrameworkCore.Design @PrereleaseArgs
    dotnet add package Microsoft.VisualStudio.Web.CodeGeneration.Design @PrereleaseArgs
    dotnet add package Microsoft.EntityFrameworkCore.SqlServer @PrereleaseArgs
    dotnet add package Microsoft.EntityFrameworkCore.Tools @PrereleaseArgs

    dotnet aspnet-codegenerator razorpage -m "$AppName.Models.$ModelClassName" -dc "$AppName.Data.ApplicationDbContext" -udl -outDir "Pages/$ModelPluralHumanizedName" --referenceScriptLibraries --databaseProvider sqlite

    # Create the initial database schema
    dotnet ef migrations add InitialCreate
    dotnet ef database update

    # Add seed data
    Update-ExactStringInFile `
        -FilePath "Program.cs" `
        -OldString $SeedDataInitializationLandmark `
        -NewString $SeedDataInitializationCode
    $SeedDataClassFileContent | Out-File -FilePath ".\Data\SeedData.cs"

    # Add a link to the "Movies" page
    Update-ExactStringInFile `
        -FilePath ".\Pages\Shared\_Layout.cshtml" `
        -OldString $LayoutModelPageLinkLandmark `
        -NewString $LayoutModelPageLink
} finally {
    $PrevPWD | Set-Location
}
