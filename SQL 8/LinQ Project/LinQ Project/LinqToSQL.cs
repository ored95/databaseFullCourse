using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.Linq;
using System.Data.Linq.Mapping;

namespace LinQ_Project
{
    [Table(Name = "TopSongs")]
    public class Song
    {
        private int _songID;
        [Column(IsPrimaryKey=true, Storage = "_songID")]
        public int SongID
        {
            get { return _songID; }
            set { _songID = value; }
        }

        private string _songTitle;
        [Column(Storage = "_songTitle")]
        public string SongTitle
        {
            get { return _songTitle; }
            set { _songTitle = value; }
        }

        private string _songArtist;
        [Column(Storage = "_songArtist")]
        public string SongArtist
        {
            get { return _songArtist; }
            set { _songArtist = value; }
        }

        //private DateTime _songPublisedDate;
        //[Column(Storage = "_songPublishedDate")]
        //public DateTime SongPublishedDate
        //{
        //    get { return _songPublisedDate; }
        //    set { _songPublisedDate = value; }
        //}

        private int _songYoutubeViewsPerMillions;
        [Column(Storage = "_songYoutubeViewsPerMillions")]
        public int SongYoutubeViewsPerMillions
        {
            get { return _songYoutubeViewsPerMillions; }
            set { _songYoutubeViewsPerMillions = value; }
        }
    }

    public class LinqToSQL : Song
    {
        public LinqToSQL()
        {
            //// Use a connection string.
            //SharpDataContext db = new 
            //    SharpDataContext(@"C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\Sharp.mdf");

            //// Get a typed table to run queries.
            //Table<Song> Songs = db.GetTable<Song>();

            //// Attach the log to show generated SQL.
            ////db.Log = Console.Out;

            //// Query for songs.
            //IQueryable<Song> songQuery = from song in Songs
            //                             select song;

            //foreach (Song song in songQuery)
            //{
            //    Console.WriteLine(" - ID: {0}, Title: {1}", song.SongID, song.SongTitle);
            //}

            //// Prevent console window from closing.
            //Console.ReadLine();
        }
    }
}
