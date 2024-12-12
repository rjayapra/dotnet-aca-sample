using eShopLite.Store.ApiClients;
using eShopLite.Store.Components;
using eShopLite.Store.Services;

var builder = WebApplication.CreateBuilder(args);

// // Setup Product API
// builder.Services.AddSingleton<ProductService>();
// builder.Services.AddHttpClient<ProductService>(c =>
// {
//     var url = builder.Configuration["ProductEndpoint"] ?? throw new InvalidOperationException("ProductEndpoint is not set");

//     c.BaseAddress = new(url);
// });

// // Setup Weather API
// builder.Services.AddSingleton<WeatherService>();
// builder.Services.AddHttpClient<WeatherService>(c =>
// {
//     var url = builder.Configuration["ProductEndpoint"] ?? throw new InvalidOperationException("ProductEndpoint is not set");

//     c.BaseAddress = new(url);
// });

// Add HTTP clients
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    client.BaseAddress = new("http://localhost:5228");
});
builder.Services.AddHttpClient<WeatherApiClient>(client =>
{
    client.BaseAddress = new("http://localhost:5151");
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

app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();
