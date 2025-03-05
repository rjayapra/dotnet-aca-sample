using eShopLite.Store.DataEntities;
using eShopLite.Store.StoreInfoData;

using Microsoft.EntityFrameworkCore;

namespace eShopLite.Store.Endpoints;

public static class StoreInfoEndpoints
{
    public static void MapStoreInfoEndpoints(this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/api/storeinfo");

        group.MapGet("/", async (StoreInfoDbContext db) => await GetAllStoreInfo(db))
            .WithTags("storeinfo")
            .WithName("GetStoreInfo")
            .Produces<List<StoreInfo>>(StatusCodes.Status200OK);


        group.MapPost("/", async (StoreInfo storeInfo, StoreInfoDbContext db) =>
        {
            db.Store.Add(storeInfo);
            await db.SaveChangesAsync();
            return Results.Created($"/api/storeinfo/{storeInfo.Id}", storeInfo);
        })
        .WithTags("storeinfo")
        .WithName("CreateStoreInfo")
        .Produces<StoreInfo>(StatusCodes.Status201Created);

        group.MapGet("/{id}", async (int id, StoreInfoDbContext db) =>
        {
            var storeInfo = await db.Store
                                    .AsNoTracking()
                                    .SingleOrDefaultAsync(model => model.Id == id);
            return storeInfo is StoreInfo model
                    ? Results.Ok(model)
                    : Results.NotFound();
        })
        .WithTags("storeinfo")
        .WithName("GetStoreInfoById")
        .Produces<StoreInfo>(StatusCodes.Status200OK);

        group.MapPut("/{id}", async (int id, StoreInfo storeInfo, StoreInfoDbContext db) =>
        {
            var affected = await db.Store
                                   .Where(model => model.Id == id)
                                   .ExecuteUpdateAsync(setters => setters
                                       .SetProperty(m => m.Id, storeInfo.Id)
                                       .SetProperty(m => m.Name, storeInfo.Name)
                                       .SetProperty(m => m.City, storeInfo.City)
                                       .SetProperty(m => m.State, storeInfo.State)
                                       .SetProperty(m => m.Hours, storeInfo.Hours)
                                   );
            return affected == 1 ? Results.Ok() : Results.NotFound();
        })
        .WithTags("storeinfo")
        .WithName("UpdateStoreInfo")
        .Produces(StatusCodes.Status200OK);
    }

    private async static Task<List<StoreInfo>> GetAllStoreInfo(StoreInfoDbContext db) 
    {
        // Start the combined burst simulation in a background task
        Task.Run(() => SimulateCombinedBurst());

        return await db.Store.ToListAsync();
    }

    private static void SimulateCombinedBurst()
    {
        DateTime lastLogTime = DateTime.Now;
        var endTime = DateTime.Now.AddSeconds(30); // Run for 30 seconds
        
        Random random = new Random();
        int batchNo = random.Next(1000, 10000); // Generates a random 4-digit number
        int loopPass = 0;
        List<byte[]> memoryHog = new List<byte[]>();

        Console.WriteLine($"Burst simulation #{batchNo} started...");

        while (DateTime.Now < endTime)
        {
            // CPU intensive task
            for (int i = 0; i < 100000; i++) // Increase iterations
            {
                var result = Math.Sqrt(i);
            }

            // Memory intensive task
            memoryHog.Add(new byte[1024 * 1024]); // Allocate 1MB
            // Reduce or remove delay
            Task.Delay(100).Wait();

            // Log every 10 seconds
            if ((DateTime.Now - lastLogTime).TotalSeconds >= 10)
            {
                Console.WriteLine($"Burst simulation #{batchNo} is ongoing, {loopPass} loops done.");
                lastLogTime = DateTime.Now;
            }
            loopPass++;
        }
        Console.WriteLine($"Burst simulation #{batchNo} ended.");
        Console.WriteLine($"Done in {loopPass} loops");
        Console.WriteLine($"MemoryHog size: {memoryHog.Count * 2} MB");
    }
}
