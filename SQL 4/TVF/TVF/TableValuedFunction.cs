using System;
using System.IO;
using System.Collections;
using System.Data;
using System.Data.SqlClient;
using System.Data.SqlTypes;
using Microsoft.SqlServer.Server;

public class DemoTVF
{
    /// <summary>
    /// Basic class
    /// </summary>
    private class FileProperties
    {
        public SqlString FileName;
        public SqlInt64 FileSize;
        public SqlDateTime CreationTime;

        public FileProperties(SqlString fileName, SqlInt64 fileSize, SqlDateTime creationTime)
        {
            FileName = fileName;
            FileSize = fileSize;
            CreationTime = creationTime;
        }
    }
    /// <summary>
    /// Register this code as a user defined function
    /// </summary>
    /// <param name="targetDirectory"></param>
    /// <param name="searchPattern"></param>
    /// <returns></returns>
    [Microsoft.SqlServer.Server.SqlFunction(
        FillRowMethodName = "FindFiles",
        TableDefinition = "FileName NVARCHAR(500), FileSize BIGINT, CreationTime DATETIME")]
    public static IEnumerable FileLog(string targetDirectory, string searchPattern)
    {
        try
        {
            ArrayList FilePropertiesCollection = new ArrayList();
            DirectoryInfo dirInfo = new DirectoryInfo(targetDirectory);
            FileInfo[] files = dirInfo.GetFiles(searchPattern);
            foreach (FileInfo fileInfo in files)
            {
                // Adds to the colection the properties (FileProperties) of each file is found
                FilePropertiesCollection.Add(new FileProperties(fileInfo.Name, fileInfo.Length, fileInfo.CreationTime));
            }
            return FilePropertiesCollection;
        }
        catch (Exception ex)
        {
            return null;
        }
    }

    /// <summary>
    /// FillRow method. The method name has been specified above as a SqlFunction attribute property
    /// </summary>
    /// <param name="objFileProperties"></param>
    /// <param name="fileName"></param>
    /// <param name="fileSize"></param>
    /// <param name="creationTime"></param>
    public static void FindFiles(object objFileProperties, out SqlString fileName, out SqlInt64 fileSize, out SqlDateTime creationTime)
    {
        // Using here the FileProperties class defined above
        var fileProperties = (FileProperties)objFileProperties;
        fileName = fileProperties.FileName;
        fileSize = fileProperties.FileSize;
        creationTime = fileProperties.CreationTime;
    }
};