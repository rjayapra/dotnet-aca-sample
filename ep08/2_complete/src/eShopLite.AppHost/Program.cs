var builder = DistributedApplication.CreateBuilder(args);

// Add PostgreSQL database
var productsdb = builder.AddPostgres("pg")
                        .WithPgAdmin()
                        .AddDatabase("productsdb");

// Add the Products API app
var products = builder.AddProject<Projects.eShopLite_Products>("products")
                      .WithReference(productsdb)
                      .WaitFor(productsdb);

// Add the Weather API app
var weather = builder.AddProject<Projects.eShopLite_Weather>("weather");

// Add the Store app
var store = builder.AddProject<Projects.eShopLite_Store>("store")
                   .WithReference(products)
                   .WithReference(weather)
                   .WaitFor(products)
                   .WaitFor(weather);

builder.Build().Run();
