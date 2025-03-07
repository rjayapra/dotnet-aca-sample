using eShopLite.Store.Endpoints;
using eShopLite.Store.Extensions;
using eShopLite.Store.StoreInfoData;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Add services to the container.
builder.Services.AddProblemDetails();

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

builder.AddNpgsqlDbContext<StoreInfoDbContext>("storeinfodb");

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.MapStoreInfoEndpoints();
app.CreateStoreInfoDbIfNotExists();

app.Run();

