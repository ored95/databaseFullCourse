using Microsoft.Owin;
using Owin;

[assembly: OwinStartupAttribute(typeof(ASP_Demo.Startup))]
namespace ASP_Demo
{
    public partial class Startup
    {
        public void Configuration(IAppBuilder app)
        {
            ConfigureAuth(app);
        }
    }
}
