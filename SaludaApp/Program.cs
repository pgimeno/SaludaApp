using Amazon.Lambda.AspNetCoreServer.Hosting;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddAWSLambdaHosting(LambdaEventSource.HttpApi);

var app = builder.Build();

app.MapGet("/saludo", () =>
    $"Un saludo, a las {DateTime.Now:HH:mm:ss}.");

app.Run();

public partial class Program { }