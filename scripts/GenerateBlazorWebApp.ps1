param(
    [switch]$Prerelease,
    [string]$Tfm = "net8.0"
)

$PrereleaseArgs = $Prerelease ? @("--prerelease") : @()

$AppName = "BlazorWebApp"

$ModelClassName = "Movie"
$ModelPluralHumanizedName = "Movies"
$ModelPagesRoutePrefix = "movies"

$ModelClassFileContent = @"
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace $AppName.Models;

public class $ModelClassName
{
    public int Id { get; set; }

    [Required, StringLength(60, MinimumLength = 3)]
    public string? Title { get; set; }

    [DataType(DataType.Date)]
    public DateTime ReleaseDate { get; set; }

    [RegularExpression(@"^[A-Z]+[a-zA-Z()\s-]*$"), Required, StringLength(30)]
    public string? Genre { get; set; }

    [Range(0, 100)]
    [DataType(DataType.Currency)]
    [Column(TypeName = "decimal(18, 2)")]
    public decimal Price { get; set; }

    [RegularExpression(@"^(G|PG|PG-13|R|NC-17)$"), Required]
    public string? Rating { get; set; }
}
"@

$InteractiveGridFileContent = @"
@using Microsoft.AspNetCore.Components.QuickGrid
@using $AppName
@inject $AppName.Data.ApplicationDbContext DB

<QuickGrid Class="table" Items="DB.$ModelClassName" Pagination="pagination" >
    <PropertyColumn Property="model => model.Title" />
    <PropertyColumn Property="model => model.ReleaseDate" />
    <PropertyColumn Property="model => model.Genre" />
    <PropertyColumn Property="model => model.Price" />
    <PropertyColumn Property="model => model.Rating" />

    <TemplateColumn Context="model">
        <a href="@($"$ModelPagesRoutePrefix/edit?id={model.Id}")">Edit</a> |
        <a href="@($"$ModelPagesRoutePrefix/details?id={model.Id}")">Details</a> |
        <a href="@($"$ModelPagesRoutePrefix/delete?id={model.Id}")">Delete</a>
    </TemplateColumn>
</QuickGrid>

<Paginator State="pagination" />

@code {
    PaginationState pagination = new PaginationState() { ItemsPerPage = 5 };
}
"@

$SeedDataClassFileContent = @"
using Microsoft.EntityFrameworkCore;
using $AppName.Models;

namespace $AppName.Data;

public class SeedData
{
    public static void Initialize(IServiceProvider serviceProvider)
    {
        using var context = new ApplicationDbContext(
            serviceProvider.GetRequiredService<
                DbContextOptions<ApplicationDbContext>>());

        if (context.$ModelClassName == null)
        {
            throw new InvalidOperationException("Null $ModelClassName DbSet");
        }

        if (context.$ModelClassName.Any())
        {
            return;
        }

        context.$ModelClassName.AddRange(
            new $ModelClassName
            {
                Title = "Mad Max",
                ReleaseDate = DateTime.Parse("1979-4-12"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 2.51M,
                Rating = "R",
            },
            new $ModelClassName
            {
                Title = "The Road Warrior",
                ReleaseDate = DateTime.Parse("1981-12-24"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 2.78M,
                Rating = "R",
            },
            new $ModelClassName
            {
                Title = "Mad Max: Beyond Thunderdome",
                ReleaseDate = DateTime.Parse("1985-7-10"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 3.55M,
                Rating = "PG-13",
            },
            new $ModelClassName
            {
                Title = "Mad Max: Fury Road",
                ReleaseDate = DateTime.Parse("2015-5-15"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 8.43M,
                Rating = "R",
            },
            new $ModelClassName
            {
                Title = "Furiosa: A Mad Max Saga",
                ReleaseDate = DateTime.Parse("2024-5-24"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 13.49M,
                Rating = "R",
            },
            new $ModelClassName
            {
                Title = "The Matrix",
                ReleaseDate = DateTime.Parse("1999-3-31"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 4.99M,
                Rating = "R",
            },
            new $ModelClassName
            {
                Title = "The Matrix Reloaded",
                ReleaseDate = DateTime.Parse("2003-5-15"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 5.99M,
                Rating = "R",
            },
            new $ModelClassName
            {
                Title = "The Matrix Revolutions",
                ReleaseDate = DateTime.Parse("2003-11-5"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 5.99M,
                Rating = "R",
            },
            new $ModelClassName
            {
                Title = "The Animatrix",
                ReleaseDate = DateTime.Parse("2003-6-3"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 5.99M,
                Rating = "R",
            },
            new $ModelClassName
            {
                Title = "The Matrix Resurrections",
                ReleaseDate = DateTime.Parse("2021-12-22"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 9.99M,
                Rating = "R",
            }
        );

        context.SaveChanges();
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

$NavMenuModelPageLinkLandmark = @"
        <div class="nav-item px-3">
            <NavLink class="nav-link" href="weather">
                <span class="bi bi-list-nested-nav-menu" aria-hidden="true"></span> Weather
            </NavLink>
        </div>
"@
$NavMenuModelPageLink = @"
$NavMenuModelPageLinkLandmark

        <div class="nav-item px-3">
            <NavLink class="nav-link" href="$ModelPagesRoutePrefix">
                <span class="bi bi-list-nested-nav-menu" aria-hidden="true"></span> $ModelPluralHumanizedName
            </NavLink>
        </div>
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

    # Create a new Blazor Web App with Server interactivity
    dotnet new blazor -f $Tfm -int Server -au Individual -o ".\$AppName"
    Set-Location -Path $AppName

    # Add the model class
    New-Item -Path ".\Models" -ItemType Directory
    $ModelClassFileContent | Out-File -FilePath ".\Models\$ModelClassName.cs"

    # Scaffold new pages from model
    dotnet add package Microsoft.EntityFrameworkCore.Design @PrereleaseArgs
    dotnet add package Microsoft.VisualStudio.Web.CodeGeneration.Design @PrereleaseArgs
    dotnet add package Microsoft.EntityFrameworkCore.SqlServer @PrereleaseArgs
    dotnet add package Microsoft.EntityFrameworkCore.Tools @PrereleaseArgs
    dotnet add package Microsoft.AspNetCore.Components.QuickGrid @PrereleaseArgs
    dotnet add package Microsoft.AspNetCore.Components.QuickGrid.EntityFrameworkAdapter @PrereleaseArgs

    dotnet aspnet-codegenerator blazor CRUD -m "$AppName.Models.$ModelClassName" -dc "$AppName.Data.ApplicationDbContext"

    # Create the initial database schema
    dotnet ef migrations add InitialCreate
    dotnet ef database update

    # Use AddDbContextFactory instead of AddDbContext
    Update-ExactStringInFile -FilePath "Program.cs" -OldString "AddDbContext" -NewString "AddDbContextFactory"

    # Remove the QuickGrid component from 'Index.razor' and replace it with an interactive one
    Update-StringInFile `
        -FilePath ".\Components\Pages\${ModelClassName}Pages\Index.razor" `
        -Prefix "<QuickGrid" `
        -Suffix "</QuickGrid>" `
        -NewString "<${ModelClassName}Grid @rendermode=`"InteractiveServer`" />"
    $InteractiveGridFileContent | Out-File -FilePath ".\Components\${ModelClassNAme}Grid.razor"

    # Add seed data
    Update-ExactStringInFile `
        -FilePath "Program.cs" `
        -OldString $SeedDataInitializationLandmark `
        -NewString $SeedDataInitializationCode
    $SeedDataClassFileContent | Out-File -FilePath ".\Data\SeedData.cs"

    # Add a link to the "Movies" page
    Update-ExactStringInFile `
        -FilePath ".\Components\Layout\NavMenu.razor" `
        -OldString $NavMenuModelPageLinkLandmark `
        -NewString $NavMenuModelPageLink
    $SeedDataClassFileContent | Out-File -FilePath ".\Data\SeedData.cs"
} finally {
    $PrevPWD | Set-Location
}
