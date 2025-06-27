using Microsoft.EntityFrameworkCore;
using ScrabbleServer.Data.Models.DatabaseModels;

namespace ScrabbleServer.Contexts;

public class DatabaseContext : DbContext
{
    public DatabaseContext(DbContextOptions<DatabaseContext> options) : base(options)
    {
    }
    
    public DbSet<Player> Players { get; init; }
    
    public DbSet<Game> Games { get; init; }
    
    public DbSet<GameMove> GameMoves { get; init; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        var playerBuilder = modelBuilder.Entity<Player>();
        playerBuilder.HasIndex(p => new { p.Username }).IsUnique();
        
        var gameBuilder = modelBuilder.Entity<Game>();
        gameBuilder.HasOne(g => g.InitiatingPlayer)
            .WithMany()
            .HasForeignKey(g => g.InitiatingPlayerId)
            .OnDelete(DeleteBehavior.Restrict);
        gameBuilder.HasOne(g => g.OpposingPlayer)
            .WithMany()
            .HasForeignKey(g => g.OpposingPlayerId)
            .OnDelete(DeleteBehavior.Restrict);
        gameBuilder.HasOne(g => g.InitiatingPlayerMove)
            .WithMany()
            .HasForeignKey(g => g.InitiatingPlayerMoveId)
            .OnDelete(DeleteBehavior.Restrict);
        gameBuilder.HasOne(g => g.OpposingPlayerMove)
            .WithMany()
            .HasForeignKey(g => g.OpposingPlayerMoveId)
            .OnDelete(DeleteBehavior.Restrict);
        
        var gameMovesBuilder = modelBuilder.Entity<GameMove>();
        gameMovesBuilder.HasOne(g => g.Game)
            .WithMany()
            .HasForeignKey(g => g.GameId)
            .OnDelete(DeleteBehavior.Restrict);
        gameMovesBuilder.HasOne(g => g.Player)
            .WithMany()
            .HasForeignKey(g => g.PlayerId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}