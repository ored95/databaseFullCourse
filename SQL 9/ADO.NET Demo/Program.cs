using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ADO.NET_Demo
{
    class Program
    {
        static void Main(string[] args)
        {
            #region [ADO] Connected field

            Connected.ShowDatabase();
            Connected.CountFilmsInMarch("ReleaseDate");
            Connected.ShowTypeFilms("Adventure");
            Connected.Insert();
            Connected.Delete(11); 
            
            #endregion

            #region [ADO] Disconnected field

            Disconnected.FilmByTypeAndMonth("Adventure", 11);
            Disconnected.Filter("Type like '%Action%'", "ReleaseDate asc");

            var test = new Film
            {
                ID = 11,
                Title = "Power Rangers",
                Type = "Action, Adventure, Sci-Fi",
                Director = "Dean Israelite",
                Stars = "Elizabeth Banks, Bryan Cranston, Dacre Montgomery",
                ReleaseDate = new DateTime(2017, 3, 24),
                Country = "USA"
            };

            Disconnected.Insert(test);

            Disconnected.Delete(test.ID);

            Disconnected.CreateXML("2017", "asc");

            #endregion

        }
    }
}
