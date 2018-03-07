using System;
using System.Collections.Generic;
using System.Linq;

namespace LinQ_Project
{
    public class LinqToObject
    {
        #region Protected fields
        protected enum sType { HOT, NEW, TRENDING };

        protected class Song
        {
            public int SongID { get; set; }
            public string SongTitle { get; set; }
            public string SongSinger { get; set; }
            public int SongSingerID { get; set; }
            /// <summary>
            /// Viewers' times
            /// </summary>
            public Int32 SongViews { get; set; }
            public DateTime SongPublishedDate { get; set; }
            public sType SongType { get; set; }
            public string Status
            {
                get
                {
                    var status = "# SongID: " + SongID.ToString() + ", " +
                                 TypeToString() + ", " +
                                 "Title: " + SongTitle.ToString() + ", " +
                                 "SingerID: " + SongSingerID.ToString() + ", " +
                                 "Singer: " + SongSinger.ToString() + ", " +
                                 "Published-Date: " + SongPublishedDate.ToShortDateString() + ", " +
                                 "Viewers: " + SongViews.ToString() + "\n";
                    return status;
                }
            }

            private string TypeToString()
            {
                var str = "Type: ";
                if (SongType == sType.HOT) str += "HOT";
                else
                    if (SongType == sType.NEW) str += "NEW";
                    else str += "TRENDING";
                return str;
            }
        }

        #endregion

        protected List<Song> ListSong()
        {
            return new List<Song>
            {
                new Song { SongID = 1, SongType = sType.NEW, SongTitle = "Red", SongSingerID = 12, SongSinger = "Taylor Swift", 
                           SongViews = 107988163, SongPublishedDate = new DateTime(2013, 12, 8)},
                new Song { SongID = 2, SongType = sType.HOT, SongTitle = "Starboy", SongSingerID = 4, SongSinger = "The Weeknd ft. Daft Punk",
                           SongViews = 269773904, SongPublishedDate = new DateTime(2016, 10, 1)},
                new Song { SongID = 3, SongType = sType.TRENDING, SongTitle = "Closer", SongSingerID = 2, SongSinger = "The Chainsmokers ft. Halsey",
                           SongViews = 747538824, SongPublishedDate = new DateTime(2016, 8, 21)},
                new Song { SongID = 4, SongType = sType.TRENDING, SongTitle = "We Don't Talk Anymore", SongSingerID = 11, SongSinger = "Charlie Puth ft. Selena Gomez", 
                           SongViews = 433824403, SongPublishedDate = new DateTime(2016, 8, 8)},
                new Song { SongID = 5, SongType = sType.HOT, SongTitle = "Faded", SongSingerID = 14, SongSinger = "Alan Walker",
                           SongViews = 779682477, SongPublishedDate = new DateTime(2016, 1, 1)},
                new Song { SongID = 6, SongType = sType.NEW, SongTitle = "My way", SongSingerID = 10, SongSinger = "Calvin Harris",
                           SongViews = 742638339, SongPublishedDate = new DateTime(2016, 11, 1)},
                new Song { SongID = 7, SongType = sType.NEW, SongTitle = "All we know", SongSingerID = 2, SongSinger = "The Chainsmokers ft. Phoebe Ryan", 
                           SongViews = 85160676, SongPublishedDate = new DateTime(2016, 10, 28)},
                new Song { SongID = 8, SongType = sType.TRENDING, SongTitle = "Sing me to sleep", SongSingerID = 14, SongSinger = "Alan Walker",
                           SongViews = 364753904, SongPublishedDate = new DateTime(2016, 7, 16)},
                new Song { SongID = 9, SongType = sType.HOT, SongTitle = "Firestone", SongSingerID = 5, SongSinger = "Kygo ft. Conrad Sewell",
                           SongViews = 847338844, SongPublishedDate = new DateTime(2016, 8, 18)},
                new Song { SongID = 10, SongType = sType.TRENDING, SongTitle = "Everytime we touch", SongSingerID = 7, SongSinger = "Cascada", 
                           SongViews = 333494999, SongPublishedDate = new DateTime(2007, 7, 17)}
            };
        }
    }

    public class TestLinqToObject : LinqToObject
    {
        protected List<Song> songs;

        public TestLinqToObject() { songs = ListSong(); }

        /// <summary>
        /// Using commands: from..in..where..orderby..select
        /// </summary>
        public void Test01()
        {
            Console.WriteLine("#1 Top published songs in 2016:");
            var infor = from song in songs
                        where song.SongPublishedDate > new DateTime(2016, 1, 1)
                        orderby song.SongPublishedDate descending
                        select song;
            foreach (var song in infor)
            {
                Console.WriteLine("[" + song.SongPublishedDate.ToString("dd'/'MM'/'yyyy") + "] " +
                                  song.SongTitle.ToString() + " - " + song.SongSinger.ToString());
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Using commands: group..by..into..orderby
        /// </summary>
        public void Test02()
        {
            Console.WriteLine("#2: Number songs group by type:");
            var infor = from song in songs
                        group song by song.SongType into SameTypeGroup
                        orderby SameTypeGroup.Count() descending, SameTypeGroup.Key
                        select new
                        {
                            SongTypeKey = SameTypeGroup.Key,
                            TypeCount = SameTypeGroup.Count(),
                        };
            foreach (var song in infor)
            {
                Console.WriteLine(" - TypeKey:[{0}] | Total: {1}", song.SongTypeKey, song.TypeCount);
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Using commands: join..on..equals, method .Contain() + comparision ENUM type
        /// </summary>
        public void Test03()
        {
            Console.WriteLine("#3: List pair of singers which has only one hit MV (join by month):");
            var _track_list_1 = from song in songs
                                where song.SongPublishedDate > new DateTime(2016, 1, 1)
                                select new
                                {
                                    PublishedMonth = song.SongPublishedDate.Month,
                                    SongTitle = song.SongTitle,
                                    SongSinger = song.SongSinger,
                                    SongViews = song.SongViews
                                };
            var _track_list_2 = from song in songs
                                where !song.SongSinger.Contains("ft.") &&
                                      (song.SongType == sType.TRENDING || song.SongType == sType.NEW)
                                select new
                                {
                                    PublishedMonth = song.SongPublishedDate.Month,
                                    SongSinger = song.SongSinger
                                };
            var JoinTrackList = from first in _track_list_1
                                join second in _track_list_2 on first.PublishedMonth equals second.PublishedMonth
                                where second.SongSinger != first.SongSinger
                                orderby first.PublishedMonth ascending, first.SongViews descending
                                select new
                                {
                                    Month = first.PublishedMonth,
                                    NewInfor = first.SongSinger + " & " + second.SongSinger
                                };
            foreach (var song in JoinTrackList)
            {
                Console.WriteLine(" * Month: " + System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat.GetMonthName(song.Month) + " | " + song.NewInfor);
            }
            Console.ReadLine();
        }

        /// <summary>
        /// Using commands: FirstOrDefault() as select top 1 (T-Sql) and set operation Func<>
        /// </summary>
        public void Test04()
        {
            Console.WriteLine("#4: Maximum TotalSongViewers by SingerID:");
            Func<int, string> songBySingerID =
                sid => " + ID: " + sid.ToString("D2") + " | Viewers: " +
                        (from track in songs
                        where track.SongSingerID == sid
                        orderby track.SongViews descending
                        select track.SongViews).FirstOrDefault().ToString();

            var listID = from song in songs
                         group song by song.SongSingerID into SID
                         orderby SID.Key
                         select SID.Key;

            foreach (var sid in listID)
                Console.WriteLine(songBySingerID(sid));
            Console.ReadLine();
        }

        /// <summary>
        /// Using commands: Take() as select top N (T-Sql) and aggregate function
        /// </summary>
        public void Test05()
        {
            Console.WriteLine("#5: Top 3 singers with more than one MV/song:");
            var infor = (from track in songs
                         group track by track.SongSingerID into TopSongSinger
                         orderby TopSongSinger.Count() descending
                         select new
                         {
                             ID = TopSongSinger.Key,
                             Times = TopSongSinger.Count(),
                             MaxViewers = (from view in TopSongSinger
                                           select view.SongViews).Max()
                         }).Take(3);
            foreach (var singer in infor)
            {
                Console.WriteLine(" + ID: " + singer.ID.ToString("D2") + " | Times: " + singer.Times.ToString() +
                                                                     " | MaxViewers: " + singer.MaxViewers.ToString());
            }
            Console.ReadLine();
        }
    }
}