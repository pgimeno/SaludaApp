var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapGet("/saludo", () => $"Un saludo, a las {DateTime.Now.ToString("HH:mm:ss")}.");

app.Run();

public partial class Program { }