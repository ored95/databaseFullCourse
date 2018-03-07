using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Linq;
using System.Data.Linq.Mapping;

namespace LinqToSQL
{
    public class LinqToSQL
    {
        /// <summary>
        /// Using database from Sharp.mdl
        /// </summary>
        private SharpDataContext db = new SharpDataContext();
        
        /// <summary>
        /// Using table dbo.SongDB
        /// </summary>
        private Table<SongDB> SongTable;
        
        public LinqToSQL() { SongTable = db.GetTable<SongDB>(); }

        /// <summary>
        /// Displaying all songs
        /// </summary>
        private void DisplayTable()
        {
            var songs = from song in SongTable
                        select song;
        
            Console.Clear();
            Console.WriteLine("# Song: (total: {0})\n", songs.Count());
            foreach (var song in songs)
            {
                Console.WriteLine(" # ID: {0} - Title: {1}", song.SongID, song.SongTitle);
                Console.WriteLine("\t  - Singer: " + song.SongSinger);
                Console.WriteLine("\t  - PublisedDate: " + song.SongPublishedDate);
                Console.WriteLine("\t  -      Viewers: " + song.SongViewers);
                Console.WriteLine();
            }
        }

        /// <summary>
        /// Displaying all songs (test)
        /// </summary>
        public void Test01() { DisplayTable(); Console.ReadLine(); }

        /// <summary>
        /// Display songs in 2016 by viewers
        /// </summary>
        public void Test02()
        {
            var infor = from song in
                            from s in SongTable
                            where s.SongPublishedDate > new DateTime(2016, 1, 1)
                            select s
                        orderby song.SongPublishedDate.Month descending, song.SongViewers descending
                        //group song by song.SongPublishedDate.Month into songByMonth
                        //select songByMonth;
                        select song;
            Console.Clear();
            Console.WriteLine("# Top songs in 2016 by viewers: (total {0})\n", infor.Count());
            foreach (var song in infor)
            {
                Console.WriteLine(" # {0}: [{1}] {2}", song.SongID
                                                     , System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(song.SongPublishedDate.Month)
                                                     , song.SongTitle);
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Insert record, using InsertOnSubmit() and SubmitChanges()
        /// </summary>
        /// <param name="newSong"></param>
        public void Insert(List<SongDB> newSong)
        {
            SongTable.InsertAllOnSubmit(newSong);
            db.SubmitChanges();
            var updateData = from song in db.SongDBs
                             where song.SongID > 24
                             select song;
            DisplayTable();
            Console.WriteLine("\n\t( Total {0} rows was affected )", newSong.Count);
            Console.ReadLine();
        }

        /// <summary>
        /// Delete all inserted rows, using DeleteAllOnSubmit()
        /// </summary>
        public void Delete()
        {
            var updateData = from song in db.SongDBs
                             where song.SongID > 24
                             select song;
            int count = updateData.Count();
            SongTable.DeleteAllOnSubmit(updateData);
            db.SubmitChanges();
            DisplayTable();
            Console.WriteLine("\n\t( Total {0} rows was affected )", count);
            Console.ReadLine();
        }

        // Call the stored procedure
        public void SongByMonth(int month)
        {
            ISingleResult<SongDB> result = db.SongByMonth(month);
            
            Console.Clear();
            Console.WriteLine("# Songs is publised in {0}\n", 
                    System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(month));
            foreach (var song in result)
            {
                Console.WriteLine(" # ID: {0} - Title: {1}", song.SongID, song.SongTitle);
                Console.WriteLine("\t  - Singer: " + song.SongSinger);
                Console.WriteLine("\t  - PublisedDate: " + song.SongPublishedDate);
                Console.WriteLine("\t  -      Viewers: " + song.SongViewers);
                Console.WriteLine();
            }
            Console.ReadLine();
        }
    }
}
