using System;
using System.Data;
using System.Data.OleDb;
using System.Data.SqlClient;

namespace ADO.NET_Demo
{
    public struct Film
    {
        public int ID { get; set; }
        public string Title { get; set; }
        public string Type { get; set; }
        public string Director { get; set; }
        public string Stars { get; set; }
        public DateTime ReleaseDate { get; set; }
        public string Country { get; set; }
    };

    public class Disconnected
    {
        #region Private fields

        private static string _ConnectionString = @"Data Source = ORED-SA;
                                                    Initial Catalog = UpcomingFilms2017;
                                                    Integrated Security = True";
        private static SqlConnection _SqlConnection = new SqlConnection(_ConnectionString);
        private static SqlDataAdapter Adapter;
        private static DataSet dSet = new DataSet();
        private static DataTable dTable;
        private static string Table = "UpcomingFilms2017";

        #endregion

        /// <summary>
        /// Using SqlAdapter, SqlDataSet, SqlDataTable
        /// </summary>
        /// <param name="cmd"></param>
        private static void SetUpConnection(string cmd)
        {
            _SqlConnection.Open();

            Adapter = new SqlDataAdapter(cmd, _SqlConnection);
            Adapter.Fill(dSet, Table);
            dTable = dSet.Tables[Table];

            _SqlConnection.Close();
        }

        private static int Detail()
        {
            int count = 0;
            Console.Clear();
            Console.WriteLine("# Films' detail:");
            foreach (DataRow row in dTable.Rows)
            {
                Console.Write("\n - ");
                foreach (DataColumn column in dTable.Columns)
                    Console.WriteLine("\t" + row[column]);
                count++;
            }
            return count;
        }

        /// <summary>
        /// Select films by given Type and Month
        /// </summary>
        /// <param name="type"></param>
        /// <param name="month"></param>
        public static void FilmByTypeAndMonth(string type, int month)
        {
            string cmd = @"select Title, Type, ReleaseDate from " + Table +
                          " where Type like '%" + type + "%' and MONTH(ReleaseDate) = " + month.ToString();
            
            SetUpConnection(cmd);
            
            int count = Detail();
            Console.Write("\n\t( {0} rows were affected! )", count);
            Console.ReadLine();
        }

        /// <summary>
        /// Filter and sort
        /// </summary>
        /// <param name="filter"></param>
        /// <param name="sort"></param>
        public static void Filter(string filter, string sort)
        {
            string cmd = @"select Title, Type, ReleaseDate from " + Table;
            SetUpConnection(cmd);

            int count = 0;
            Console.Clear();
            Console.WriteLine("# Films' detail, using filter = \"{0}\" and sorting = \"{1}\":", filter, sort);
            
            foreach (DataRow Row in dTable.Select(filter, sort))
            {
                Console.Write("\n -");
                foreach (DataColumn column in dTable.Columns)
                    Console.WriteLine("\t" + Row[column]);
                count++;
            }

            Console.Write("\n\t( {0} rows were affected! )", count);
            Console.ReadLine();
        }

        public static void Insert(Film newFilm)
        {
            string select = @"select * from " + Table;

            // Set up adapter
            SetUpConnection(select);

            // create and add new record
            DataRow NewRow = dTable.NewRow();
            NewRow["ID"] = newFilm.ID;
            NewRow["Title"] = newFilm.Title;
            NewRow["Type"] = newFilm.Type;
            NewRow["Director"] = newFilm.Director;
            NewRow["Stars"] = newFilm.Stars;
            NewRow["ReleaseDate"] = newFilm.ReleaseDate;
            NewRow["Country"] = newFilm.Country;
            dTable.Rows.Add(NewRow);
            
            _SqlConnection.Open();
            string Insert = @"insert into " + Table + "(ID, Title, Type, Director, Stars, ReleaseDate, Country)"
                                            + " values(@ID, @Title, @Type, @Director, @Stars, @ReleaseDate, @Country)";
            Adapter = new SqlDataAdapter();
            SqlCommand cmd = new SqlCommand(Insert, _SqlConnection);
            cmd.Parameters.AddWithValue("@ID", newFilm.ID);
            cmd.Parameters.AddWithValue("@Title", newFilm.Title);
            cmd.Parameters.AddWithValue("@Type", newFilm.Type);
            cmd.Parameters.AddWithValue("@Director", newFilm.Director);
            cmd.Parameters.AddWithValue("@Stars", newFilm.Stars);
            cmd.Parameters.AddWithValue("@ReleaseDate", newFilm.ReleaseDate);
            cmd.Parameters.AddWithValue("@Country", newFilm.Country);

            // insert and update data
            Adapter.InsertCommand = cmd;
            Adapter.Update(dSet, Table);
            _SqlConnection.Close();

            // show details
            Detail();
            Console.Write("\n\t( 1 rows were affected! )");
            Console.ReadLine();
        }

        /// <summary>
        /// Delete records by given ID
        /// </summary>
        /// <param name="ID"></param>
        public static void Delete(int ID)
        {
            string Delete = @"delete from " + Table + " where ID = @ID";
            string select = @"select * from " + Table;

            //SetUpConnection(select);
            _SqlConnection.Open();

            // set up adapter
            Adapter = new SqlDataAdapter();
            Adapter.SelectCommand = new SqlCommand(select, _SqlConnection);
            
            dSet = new DataSet();
            Adapter.Fill(dSet, Table);
            dTable = dSet.Tables[Table];

            SqlCommand cmd = new SqlCommand(Delete, _SqlConnection);
            cmd.Parameters.Add("@ID", SqlDbType.Int, 4, "ID");

            int total = 0;
            foreach (DataRow Row in dTable.Select(@"ID = " + ID.ToString()))
            {
                Row.Delete();
                total++;
            }

            Adapter.DeleteCommand = cmd;
            Adapter.Update(dSet, Table);
            _SqlConnection.Close();

            // show details
            Detail();
            Console.Write("\n\t( {0} row was affected! )", total);
            Console.ReadLine();
        }

        /// <summary>
        /// Create XML from database
        /// </summary>
        /// <param name="filename"></param>
        /// <param name="sort"></param>
        public static void CreateXML(string filename, string sort)
        {
            string selectAll = @"select * from " + Table + " order by ReleaseDate " + sort;
            string location = "../../" + filename;
            _SqlConnection.Open();
            
            Adapter = new SqlDataAdapter(selectAll, _SqlConnection);
            dSet = new DataSet();
            Adapter.Fill(dSet, Table);
            

            // write to XML
            dSet.WriteXml(location);
            
            _SqlConnection.Close();

            Console.Clear();
            Console.Write("# File {0}.xml was created succesfully!", filename);
            Console.ReadLine();
        }
    }
}
