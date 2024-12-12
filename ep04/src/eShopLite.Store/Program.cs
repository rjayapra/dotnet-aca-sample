using eShopLite.Store.ApiClients;
using eShopLite.Store.Components;


var builder = WebApplication.CreateBuilder(args);

// Add HTTP clients
builder.Services.AddHttpClient<ProductApiClient>(client =>
{
    client.BaseAddress = new("http://products:8080");
});
builder.Services.AddHttpClient<WeatherApiClient>(client =>
{
    client.BaseAddress = new("http://weather:8080");
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
