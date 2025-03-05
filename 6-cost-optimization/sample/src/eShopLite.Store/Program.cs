using eShopLite.Store.ApiClients;
using eShopLite.Store.Components;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddProblemDetails();

// Add razor components
builder.Services.AddRazorComponents()
                .AddInteractiveServerComponents();

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

builder.Services.AddHttpClient<StoreInfoApiClient>(client =>
{
    var storeInfoApiUrl = builder.Configuration.GetValue<string>("StoreInfoApi");
    if (string.IsNullOrEmpty(storeInfoApiUrl))
    {
        throw new ArgumentNullException(nameof(storeInfoApiUrl), "StoreInfoApi configuration value is missing or empty.");
    }
    client.BaseAddress = new Uri(storeInfoApiUrl);
});


var app = builder.Build();

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
