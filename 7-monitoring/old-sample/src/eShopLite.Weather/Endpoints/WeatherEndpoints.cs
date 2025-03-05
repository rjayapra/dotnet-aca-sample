using eShopLite.DataEntities;

namespace eShopLite.Weather.Endpoints;

public static class WeatherEndpoints
{
    private static readonly string[] summaries =
    [
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    ];

    public static void MapWeatherEndpoints (this IEndpointRouteBuilder routes)
    {
        var group = routes.MapGroup("/api/weatherforecast");

        group.MapGet("/", () => GetWeatherForecast())
        .WithTags("weather")
        .WithName("GetWeatherForecast")
        .Produces<WeatherForecast[]>(StatusCodes.Status200OK);
    }

    private static WeatherForecast[] GetWeatherForecast()
    {
        // Start the combined burst simulation in a background task
        Task.Run(() => SimulateCombinedBurst());
        
        var forecast =  Enumerable.Range(1, 5).Select(index =>
            new WeatherForecast
            (
                DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                Random.Shared.Next(-20, 55),
                summaries[Random.Shared.Next(summaries.Length)]
            ))
            .ToArray();
        return forecast;
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
