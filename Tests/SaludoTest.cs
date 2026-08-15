
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.VisualStudio.TestPlatform.TestHost;
using Xunit;

namespace Tests
{
    public class SaludoTest
    {
        [Fact]
        public async Task Saludo_DevuelveRespuestaCorrecta()
        {
            await using var application =
                new WebApplicationFactory<Program>();

            var client = application.CreateClient();

            var response = await client.GetAsync("/saludo");

            response.EnsureSuccessStatusCode();

            var contenido = await response.Content.ReadAsStringAsync();

            Assert.StartsWith("Un saludo, a las ", contenido);
        }
    }
}