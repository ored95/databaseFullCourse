using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;

namespace ADO.NET_Demo
{
    public class Connected
    {
        #region OleDb region

        //public OleDbConnection _Connection;
        //public OleDbDataAdapter dAdapter;
        //public DataSet dSet;
        //public string ConnectionString = @"Provider=Microsoft.Jet.OLEDB.4.0;Data Source=../../../UpcomingFilms2017.mdb";
        //public string Table = "UpcomingFilms2017";
        //public void GetRaw(string Table)
        //{
        //    try
        //    {
        //        _Connection = new OleDbConnection(ConnectionString);
        //        dAdapter = new OleDbDataAdapter("select * from " + Table, _Connection);
        //        dSet = new DataSet();
        //        dAdapter.Fill(dSet, Table);
        //    }
        //    catch (Exception ex)
        //    {
        //        Console.WriteLine("Error : " + ex.Message);
        //    }

        //    Console.ReadLine();
        //}

        #endregion

        #region Private fields
        
        private static string _ConnectionString = @"Data Source = ORED-SA;
                                                    Initial Catalog = UpcomingFilms2017;
                                                    Integrated Security = True";
        private static SqlConnection _SqlConnection = new SqlConnection(_ConnectionString);
        //private SqlDataAdapter sAdapter;
        private static string Table = "UpcomingFilms2017";

        private struct Film
        {
            public int ID { get; set; }
            public string Title { get; set; }
            public string Type { get; set; }
            public string Director { get; set; }
            public string Stars { get; set; }
            public DateTime ReleaseDate { get; set; }
            public string Country { get; set; }
        };

        #endregion
        
        /// <summary>
        /// Show all data of table, using SqlDataReader
        /// </summary>
        public static void ShowDatabase()
        {
            string detail = @"select * from " + Table;

            _SqlConnection.Open();
            var RCom = new SqlCommand(detail, _SqlConnection);

            Console.Clear();
            Console.WriteLine("- Database [" + Table + "]\n");
            
            SqlDataReader DataReader = RCom.ExecuteReader();
            while (DataReader.Read())
            {
                Console.Write("# " + DataReader.GetValue(0));
                for (int i = 1; i < DataReader.FieldCount; i++)
                    Console.WriteLine("\t" + DataReader.GetValue(i));
                Console.WriteLine();
            }
            
            _SqlConnection.Close();
            Console.ReadLine();
        }

        /// <summary>
        /// Select all films with release date in March
        /// </summary>
        /// <param name="Column"></param>
        public static void CountFilmsInMarch(string Column)
        {
            string count = @"select COUNT(*) from " + Table +
                             " where MONTH(" + Column + ") = 3";

            var TCom = new SqlCommand(count, _SqlConnection);
            _SqlConnection.Open();
            
            Console.Clear();
            Console.WriteLine("# Table: " + Table + ", Columns: " + Column);
            Console.WriteLine("\n- Total: {0} films will be released in March 2017.", TCom.ExecuteScalar());
            
            _SqlConnection.Close();
            Console.ReadLine();
        }

        /// <summary>
        /// List films by given type
        /// </summary>
        /// <param name="filmType"></param>
        public static void ShowTypeFilms(string filmType)
        {
            string detail = @"select * from " + Table +
                " where Type like '%" + filmType + "%'" + 
                " order by ReleaseDate asc";

            _SqlConnection.Open();
            var cmd = new SqlCommand(detail, _SqlConnection);
            
            Console.Clear();
            Console.WriteLine("# List releasing films (Type: {0}):\n", filmType);
            int count = 0;

            SqlDataReader DataReader = cmd.ExecuteReader();
            while (DataReader.Read())
            {
                count++;
                Console.WriteLine(" + [Title]: {0}\n   [Type] : {1}\n   [Director]: {2}\n   [ReleaseDate]: {3}\n",
                                    DataReader[1], DataReader[2], DataReader[3], DataReader[5]);
            }

            Console.WriteLine("\n\t( {0} rows were affected! )", count);

            _SqlConnection.Close();
            Console.ReadLine();
        }

        /// <summary>
        /// Insert into table new value
        /// </summary>
        public static void Insert()
        {
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

            //string InsertOn  = @"set identity_insert " + Table + " on";
            //string InsertOff = @"set identity_insert " + Table + " off";
            string Insert = @"insert into " + Table + "(ID, Title, Type, Director, Stars, ReleaseDate, Country)" 
                                               + " values(@ID, @Title, @Type, @Director, @Stars, @ReleaseDate, @Country)";

            SqlCommand cmd = new SqlCommand(Insert, _SqlConnection);
            _SqlConnection.Open();
            //cmd.ExecuteNonQuery();
            
            cmd.Parameters.Add("@ID"    , SqlDbType.Int);
            cmd.Parameters.Add("@Title" , SqlDbType.NVarChar, 30);
            cmd.Parameters.Add("@Type"  , SqlDbType.NVarChar, 50);
            cmd.Parameters.Add("@Director", SqlDbType.NVarChar, 30);
            cmd.Parameters.Add("@Stars" , SqlDbType.NVarChar, 60);
            cmd.Parameters.Add("@ReleaseDate", SqlDbType.DateTime);
            cmd.Parameters.Add("@Country", SqlDbType.NVarChar, 30);

            cmd.Parameters["@ID"].Value = test.ID;
            cmd.Parameters["@Title"].Value = test.Title;
            cmd.Parameters["@Type"].Value = test.Type;
            cmd.Parameters["@Director"].Value = test.Director;
            cmd.Parameters["@Stars"].Value = test.Stars;
            cmd.Parameters["@ReleaseDate"].Value = test.ReleaseDate;
            cmd.Parameters["@Country"].Value = test.Country;
            
            cmd.CommandText = Insert;
            cmd.ExecuteNonQuery();
            _SqlConnection.Close();

            ShowDatabase();
            Console.WriteLine("\n\t( 1 row was affected! )");
            Console.ReadLine();
        }

        /// <summary>
        /// Delete record from table by given ID, here ID(test) = 11
        /// </summary>
        /// <param name="ID"></param>
        public static void Delete(int ID)
        {
            string count = @"select COUNT(*) from " + Table + " where ID = " + ID.ToString();
            string Delete = @"delete from " + Table + " where ID = @ID";

            _SqlConnection.Open();
            var Tcmd = new SqlCommand(count, _SqlConnection);
            var total = Tcmd.ExecuteScalar();

            SqlCommand cmd = new SqlCommand(Delete, _SqlConnection);

            cmd.Parameters.Add("@ID", SqlDbType.Int);
            cmd.Parameters["@ID"].Value = ID;
            
            cmd.CommandText = Delete;
            cmd.ExecuteNonQuery();
            _SqlConnection.Close();
            
            ShowDatabase();
            Console.WriteLine("\n\t( {0} rows was affected! )", total);
            Console.ReadLine();
        }
    }
}
