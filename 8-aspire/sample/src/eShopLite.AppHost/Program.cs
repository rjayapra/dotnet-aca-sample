var builder = DistributedApplication.CreateBuilder(args);

var pg = builder.AddPostgres("pg")
                .WithPgAdmin();
var productsdb = pg.AddDatabase("productsdb");
var storeinfodb = pg.AddDatabase("storeinfodb");

var products = builder.AddProject<Projects.eShopLite_Products>("products")
                      .WithReference(productsdb)
                      .WaitFor(productsdb);

var storeinfo = builder.AddProject<Projects.eShopLite_StoreInfo>("storeinfo")
                       .WithReference(storeinfodb)
                       .WaitFor(storeinfodb);

var store = builder.AddProject<Projects.eShopLite_Store>("store")
                   .WithExternalHttpEndpoints()
                   .WithReference(products)
                   .WithReference(storeinfo)
                   .WaitFor(products)
                   .WaitFor(storeinfo);

builder.Build().Run();
