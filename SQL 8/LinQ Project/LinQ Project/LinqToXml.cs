using System;
using System.Collections.Generic;
using System.Linq;
using System.Xml;
using System.Xml.Linq;

namespace LinQ_Project
{
    public class LinqToXml
    {
        private string source;
        /// <summary>
        /// Read data in root.xml file
        /// </summary>
        public LinqToXml() { source = "../../root.xml"; }

        /// <summary>
        /// Using XDocument (Descendants)
        /// </summary>
        public void Test01()
        {
            var books = XDocument.Load(source);
            var infor = from book in books.Descendants("book")
                        select book.Value;
            Console.WriteLine("# List books: (total: " + infor.Count() + ")\n");
            foreach (var item in infor) Console.WriteLine(" - " + item);
            Console.ReadLine();
        }

        /// <summary>
        /// Set Attribute by given value
        /// </summary>
        /// <param name="doc"></param>
        /// <param name="xIndex"></param>
        /// <param name="value"></param>
        private static void SetValueToDetailElement(XDocument doc, string xIndex, string value)
        {
            var detail = doc.Elements("Details").SingleOrDefault(x => x.Attribute("XIndex").Value == xIndex);
            if (detail != null)
                detail.SetAttributeValue("Index", value);
        }

        /// <summary>
        /// Using XElement to modify and write into XML
        /// </summary>
        public void Test02()
        {
            //var tmp = XDocument.Load(source);
            //XElement element = tmp.Elements("edit").SingleOrDefault(x => x.Attribute("Xindex").ToString() == "One");
            //element.SetAttributeValue("Index", "X1");
            //element.SetElementValue("text", "Test02 is executed.");
            XElement books = XElement.Load(source);
            Console.WriteLine("# [BEFORE] XML:");
            var detail = from txt in books.Elements("edit")
                         select txt;
            foreach (var txt in detail) Console.WriteLine(txt);
            Console.WriteLine();

            Console.WriteLine("# [AFTER] Modifying XML:");
            books.Element("edit").Element("text").SetValue("Test02 is executed!");
            books.Element("edit").Attribute("Index").SetValue("X1");
            foreach (var txt in detail) Console.WriteLine(txt);
            Console.ReadLine();
        }

        /// <summary>
        /// Using XElement (Elements)
        /// </summary>
        public void Test03()
        {
            var books = XElement.Load(source);
            IEnumerable<XElement> infor = from book in books.Elements("book")
                                          where (string)book.Element("genre") == "Computer"
                                          select book;
            
            Console.WriteLine("# List books about computer: (total: " + infor.Count() + ")\n");
            foreach (var book in infor)
            {
                Console.WriteLine(" - Title : " + (string)book.Element("title"));
                Console.WriteLine("   Author: " + (string)book.Element("author"));
                Console.WriteLine("   Price : $" + (string)book.Element("price") + "\n");
            }
            Console.ReadLine();
        }
    }
}
