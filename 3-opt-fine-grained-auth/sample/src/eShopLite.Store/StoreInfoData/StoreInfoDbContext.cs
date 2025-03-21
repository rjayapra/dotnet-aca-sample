using eShopLite.Store.DataEntities;

using Microsoft.EntityFrameworkCore;

namespace eShopLite.Store.StoreInfoData;

public class StoreInfoDbContext : DbContext
{
    public StoreInfoDbContext(DbContextOptions<StoreInfoDbContext> options)
        : base(options)
    {
    }

    public DbSet<StoreInfo> Store { get; set; } = default!;
}
