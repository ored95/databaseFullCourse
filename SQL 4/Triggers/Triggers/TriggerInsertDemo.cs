using System.Data;
using System.Data.SqlClient;
using System.Text.RegularExpressions;   // Regex
using Microsoft.SqlServer.Server;

public class TriggerInsertDemo
{
    [SqlTrigger(Event = "FOR INSERT", Name = "UserNameAudit", Target = "Users")]
    public static void UserNameAudit()
    {
        SqlTriggerContext triggContext = SqlContext.TriggerContext;
        SqlParameter userName = new SqlParameter("@username", SqlDbType.NVarChar);

        if (triggContext.TriggerAction == TriggerAction.Insert)
        {
            using (SqlConnection connect = new SqlConnection("context connection=true"))
            {
                connect.Open();
                SqlCommand _command = new SqlCommand();
                SqlPipe _pipe = SqlContext.Pipe;

                _command.Connection = connect;
                _command.CommandText = "SELECT UserName from INSERTED";

                userName.Value = _command.ExecuteScalar().ToString();

                if (IsEMailAddress(userName.Value.ToString()))
                {
                    _command.Parameters.Add(userName);
                    _command.CommandText = "INSERT UsersAudit(UserName) VALUES(@username)";
                    _pipe.Send(_command.CommandText);
                    _pipe.ExecuteAndSend(_command);
                }
            }
        }
    }

    public static bool IsEMailAddress(string s)
    {
        return Regex.IsMatch(s, "^([\\w-]+\\.)*?[\\w-]+@[\\w-]+\\.([\\w-]+\\.)*?[\\w]+$");
    }
}