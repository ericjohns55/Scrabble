using Microsoft.EntityFrameworkCore;
using ScrabbleServer.Data.Models.DatabaseModels;

namespace ScrabbleServer.Data;

public class ScrabbleContext : DbContext
{
    public ScrabbleContext(DbContextOptions<ScrabbleContext> options) : base(options)
    {
    }
    
    public DbSet<Player> Players { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var playerBuilder = modelBuilder.Entity<Player>();
        playerBuilder.HasIndex(p => new { p.Username }).IsUnique();
    }
}