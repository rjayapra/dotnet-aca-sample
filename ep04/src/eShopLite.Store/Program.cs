using eShopLite.Store.ApiClients;
using eShopLite.Store.Components;

var builder = WebApplication.CreateBuilder(args);

// Add HTTP clients
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    var productsApiUrl = builder.Configuration.GetValue<string>("ProductsApi");
    if (string.IsNullOrEmpty(productsApiUrl))
    {
        throw new ArgumentNullException(nameof(productsApiUrl), "ProductsApi configuration value is missing or empty.");
    }
    client.BaseAddress = new Uri(productsApiUrl);
});

builder.Services.AddHttpClient<WeatherApiClient>(client =>
{
    var weatherApiUrl = builder.Configuration.GetValue<string>("WeatherApi");
    if (string.IsNullOrEmpty(weatherApiUrl))
    {
        throw new ArgumentNullException(nameof(weatherApiUrl), "WeatherApi configuration value is missing or empty.");
    }
    client.BaseAddress = new Uri(weatherApiUrl);
});

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

//app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
