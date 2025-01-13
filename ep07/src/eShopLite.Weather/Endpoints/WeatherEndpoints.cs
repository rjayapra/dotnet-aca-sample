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
        var endTime = DateTime.Now.AddSeconds(30); // Run for 30 seconds
        var midTime = DateTime.Now.AddSeconds(15); // Midpoint
        Random random = new Random();
        double tempSum = 0;
        List<byte[]> memoryHog = new List<byte[]>();
        bool midTimeLogged = false;
        
        Console.WriteLine("Burst simulation started...");

        while (DateTime.Now < endTime)
        {
            // CPU intensive task
            for (int i = 0; i < 1000000; i++) // Increase iterations
            {
                var result = Math.Sqrt(i);
                tempSum += result + random.Next(1, 11);
            }

            // Memory intensive task
            memoryHog.Add(new byte[2 * 1024 * 1024]); // Allocate 2MB
            // Reduce or remove delay
            Task.Delay(100).Wait();

            // Log midpoint message
            if (!midTimeLogged && DateTime.Now >= midTime)
            {
                Console.WriteLine("Burst simulation is at midpoint.");
                midTimeLogged = true;
            }
        }
        Console.WriteLine($"Burst simulation ended.");
        Console.WriteLine($"Math total: {tempSum}");
    }
}
