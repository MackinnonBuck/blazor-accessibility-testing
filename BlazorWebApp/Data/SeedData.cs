using Microsoft.EntityFrameworkCore;
using BlazorWebApp.Models;

namespace BlazorWebApp.Data;

public class SeedData
{
    public static void Initialize(IServiceProvider serviceProvider)
    {
        using var context = new ApplicationDbContext(
            serviceProvider.GetRequiredService<
                DbContextOptions<ApplicationDbContext>>());

        if (context.Movie == null)
        {
            throw new InvalidOperationException("Null Movie DbSet");
        }

        if (context.Movie.Any())
        {
            return;
        }

        context.Movie.AddRange(
            new Movie
            {
                Title = "Mad Max",
                ReleaseDate = DateTime.Parse("1979-4-12"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 2.51M,
                Rating = "R",
            },
            new Movie
            {
                Title = "The Road Warrior",
                ReleaseDate = DateTime.Parse("1981-12-24"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 2.78M,
                Rating = "R",
            },
            new Movie
            {
                Title = "Mad Max: Beyond Thunderdome",
                ReleaseDate = DateTime.Parse("1985-7-10"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 3.55M,
                Rating = "PG-13",
            },
            new Movie
            {
                Title = "Mad Max: Fury Road",
                ReleaseDate = DateTime.Parse("2015-5-15"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 8.43M,
                Rating = "R",
            },
            new Movie
            {
                Title = "Furiosa: A Mad Max Saga",
                ReleaseDate = DateTime.Parse("2024-5-24"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 13.49M,
                Rating = "R",
            },
            new Movie
            {
                Title = "The Matrix",
                ReleaseDate = DateTime.Parse("1999-3-31"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 4.99M,
                Rating = "R",
            },
            new Movie
            {
                Title = "The Matrix Reloaded",
                ReleaseDate = DateTime.Parse("2003-5-15"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 5.99M,
                Rating = "R",
            },
            new Movie
            {
                Title = "The Matrix Revolutions",
                ReleaseDate = DateTime.Parse("2003-11-5"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 5.99M,
                Rating = "R",
            },
            new Movie
            {
                Title = "The Animatrix",
                ReleaseDate = DateTime.Parse("2003-6-3"),
                Genre = "Sci-fi (Cyberpunk)",
                Price = 5.99M,
                Rating = "R",
            },
            new Movie
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
