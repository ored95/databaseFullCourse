using System;
using System.Data;
using System.Data.Sql;
using System.Data.SqlTypes;
using System.Data.SqlClient;
using System.Collections.Generic;

public class StoredProcedure
{
    [Microsoft.SqlServer.Server.SqlProcedure()]
    public static void InsertCurrency(SqlString currencyCode, SqlString name)
    {
        using (SqlConnection connect = new SqlConnection("context connection=true"))
        {
            SqlCommand InsertCurrencyCommand = new SqlCommand();
            SqlParameter currencyCodeParam = new SqlParameter("@CurrencyCode", SqlDbType.NVarChar);
            SqlParameter nameParam = new SqlParameter("@Name", SqlDbType.NVarChar);

            currencyCodeParam.Value = currencyCode;
            nameParam.Value = name;

            InsertCurrencyCommand.Parameters.Add(currencyCodeParam);
            InsertCurrencyCommand.Parameters.Add(nameParam);

            InsertCurrencyCommand.CommandText =
                "INSERT dbo.Currency (CurrencyCode, Name, ModifiedDate) VALUES(@CurrencyCode, @Name, GetDate())";

            InsertCurrencyCommand.Connection = connect;
            connect.Open();
            InsertCurrencyCommand.ExecuteNonQuery();
            connect.Close();
        }
    }
}
