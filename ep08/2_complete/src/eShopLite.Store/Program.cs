using eShopLite.Store.ApiClients;
using eShopLite.Store.Components;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Add services to the container.
builder.Services.AddProblemDetails();

// Add razor components
builder.Services.AddRazorComponents()
                .AddInteractiveServerComponents();

// Add HTTP clients
builder.Services.AddHttpClient<ProductApiClient>(client => client.BaseAddress = new Uri("https+http://products"));
builder.Services.AddHttpClient<WeatherApiClient>(client => client.BaseAddress = new Uri("https+http://weather"));

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseAntiforgery();

app.MapStaticAssets();

app.MapRazorComponents<App>()
   .AddInteractiveServerRenderMode();

app.Run();
