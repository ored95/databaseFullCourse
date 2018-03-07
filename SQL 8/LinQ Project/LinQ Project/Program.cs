using System; 
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LinQ_Project
{
    class Program
    {
        static void Main(string[] args)
        {
            //object[] data = new object[] { 1.0f, "hello", 'c', 0f, null, 129f, -129, "world" };

            //----------------------------------------------
            //--------- LinQ to Objects testing ------------
            //----------------------------------------------
            var LinqPart01 = new TestLinqToObject();

            // Commands: from..in..where..orderby..select
            LinqPart01.Test01();

            // Commands: group..by..into..orderby
            LinqPart01.Test02();

            // Commands: join..on..equals, method .Contain() + comparision ENUM type
            LinqPart01.Test03();

            // Commands: FirstOrDefault() as select top 1 (T-Sql) and set operation Func<>
            LinqPart01.Test04();

            // Commands: Take() as select top N (T-Sql) and aggregate function
            LinqPart01.Test05();

            //----------------------------------------------
            //------------ LinQ to XML testing -------------
            //----------------------------------------------
            var LinqToXml = new LinqToXml();

            // Read XML
            LinqToXml.Test01();

            // Modify + Write XML
            LinqToXml.Test02();

            // Selection with IEnumerable<>
            LinqToXml.Test03();

            //----------------------------------------------
            //---------------- LinQ to SQL -----------------
            //----------------------------------------------
            //var LinqToSql = new LinqToSQL(); (next file)
        }
    }
}
