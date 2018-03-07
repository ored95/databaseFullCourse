using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

namespace HandWrittenClassLibrary
{
    public class UserDefinedFunctions
    {
        [Microsoft.SqlServer.Server.SqlFunction]
        public static SqlInt32 IsPrime(SqlInt32 n)
        {
            if (n < 2)
                return 0;

            int sqrt = (int)Math.Sqrt((double)n);
            SqlInt32 res = 1;
            
            for (int i = 2; i <= sqrt; i++)
            {
                if (n % i == 0)
                {
                    res = 0;
                    break;
                }
            }
            
            return res;
        }
    }
}
