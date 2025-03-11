using eShopLite.Store.Endpoints;
using eShopLite.Store.Extensions;
using eShopLite.Store.StoreInfoData;

using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddProblemDetails();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();


builder.Services.AddDbContext<StoreInfoDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("StoreInfoContext") ?? throw new InvalidOperationException("Connection string 'StoreInfoContext' not found.");
    options.UseSqlite(connectionString);
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.MapStoreInfoEndpoints();
app.CreateStoreInfoDbIfNotExists();

app.Run();

