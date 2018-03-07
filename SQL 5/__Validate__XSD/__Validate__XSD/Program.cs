using System;
using System.Xml;
using System.Xml.Schema;

namespace __Validate__XSD
{
    class Program
    {
        static void Main(string[] args)
        {
            // Create a cache of schemas, and add two schemas
            XmlSchemaCollection list = new XmlSchemaCollection();
            list.Add("", "../../Schemas/iPhone.xsd");
            
            // Create a validating reader object
            XmlTextReader textReader = new XmlTextReader("../../Schemas/iPhone.xml");
            XmlValidatingReader validReader = new XmlValidatingReader(textReader);

            validReader.ValidationType = ValidationType.Schema;
            validReader.Schemas.Add(list);

            // Register a validation event handler method
            validReader.ValidationEventHandler += new ValidationEventHandler(myEventHandler);

            try
            {
                int count = 0;
                while (validReader.Read())
                {
                    //if (validReader.NodeType == XmlNodeType.Attribute && validReader.Name == "TradeName")
                    //{
                    //    string name = validReader.ReadContentAsString();
                    //    Console.WriteLine(name);
                    //}

                    if (validReader.NodeType == XmlNodeType.Element && validReader.LocalName == "Release-Date")
                    {
                        String value = validReader.ReadElementString();
                        Console.WriteLine("Release-Date: {0}", value);
                        if (value != null)
                            count++;
                    }
                }

                Console.WriteLine("\nNumber of models is counted: {0}\n", count);
            }
            catch (XmlException e)
            {
                Console.WriteLine("XmlException occured: " + e.Message);
            }
            finally
            {
                Console.ReadKey();
                validReader.Close();
            }
        }

        // Validation event handler method
        public static void myEventHandler(object sender, ValidationEventArgs e)
        {
            Console.WriteLine("Validation Error: " + e.Message);
        }
    }
}
