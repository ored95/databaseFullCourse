using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Linq;
using System.Data.Linq.Mapping;

namespace LinqToSQL
{
    class Program
    {
        static void Main(string[] args)
        {
            var Linq_Sql = new LinqToSQL();
            
            // #1: Displaying all songs
            Linq_Sql.Test01();
            
            // #2: Displaying songs, which has singer = "Alan Walker"
            Linq_Sql.Test02();

            // #3: Adding record
            var newSong = new List<SongDB>() 
            {
                new SongDB
                {
                    SongTitle = "Treat you better",
                    SongSinger = "Shawn Mendes",
                    SongPublishedDate = new DateTime(2016, 7, 12),
                    SongViewers = 421044778
                },
                new SongDB
                {
                    SongTitle = "Don't Wanna Know",
                    SongSinger = "Maroon 5",
                    SongPublishedDate = new DateTime(2016, 10, 14),
                    SongViewers = 75417892
                }
            };

            Linq_Sql.Insert(newSong);

            // #4: Delete records
            Linq_Sql.Delete();

            // #5: Call stored procedure
            Linq_Sql.SongByMonth(10);

            Linq_Sql.SongByMonth(7);
        }
    }
}
