using eShopLite.Products.Data;
using eShopLite.Products.Endpoints;
using eShopLite.Products.Extensions;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Add services to the container.
builder.Services.AddProblemDetails();

// Add OpenAPI services
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

// Add database context
builder.AddNpgsqlDbContext<ProductDbContext>("productsdb");

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseStaticFiles();

app.MapProductEndpoints();

app.CreateDbIfNotExists();

app.Run();
