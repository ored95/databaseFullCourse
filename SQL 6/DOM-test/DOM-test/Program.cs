using System;
using System.Xml;
using System.IO;

namespace DOM_test
{
    class Program
    {
        static void Main(string[] args)
        {
            XmlDocument _xml = new XmlDocument();
            string choice, sub_choice, back = "n", next;
            int index;
            do
            {
                Menu();

                choice = Select(0); // select sub menu

                back = "n";     // initialize back flag

                // execute sub menu
                while (choice != "0" && back != "y")
                {
                    SubMenu(choice);
                    
                    switch (choice)
                    {
                        case "2":
                            _xml = Load("top.xml");
                            while (true)
                            {
                                sub_choice = Select(1);
                                if (valid(sub_choice)) break;
                            }
                            switch (sub_choice)
                            {
                                case "1": TestReader.ExecuteTagName(_xml); break;
                                case "2": TestReader.ExecuteById(_xml); break;
                                case "3": TestReader.ExecuteNodes(_xml, 1); break;  // flag = 1: get all nodes
                                case "4": TestReader.ExecuteNodes(_xml, 0); break;  // flag = 0: get single node
                            }
                            break;
                        case "3":
                            sub_choice = Select(2);
                            if (sub_choice == "1") _xml = Load("books.xml");
                            if (sub_choice == "4") _xml = Load("instruction.xml");
                            if (sub_choice == "5") _xml = Load("root.xml");

                            if (sub_choice == "2" || sub_choice == "3")
                            {
                                _xml = Load("DOM.xml");
                                if (sub_choice == "2") TestAccess.ReviewText(_xml);
                                if (sub_choice == "3") TestAccess.ReviewComment(_xml);
                            }
                            
                            if (sub_choice == "1" || sub_choice == "4" || sub_choice == "5")
                            {
                                index = 0;
                                next = "y";
                            
                                while (next == "y")
                                {
                                    Console.Write("\nInput index of instruction [0, 1, 2, 3, 4, 5]: ");
                                    index = Int32.Parse((string)Console.ReadLine());
                                    if (index < 0 || index > 5) index = 0;

                                    if (sub_choice == "1") TestAccess.ReviewElement(_xml, index);
                                    if (sub_choice == "4") TestAccess.ReviewProcessingInstruction(_xml, index);
                                    if (sub_choice == "5") TestAccess.ReviewAttribute(_xml, index);
                                    next = Continue();
                                }
                            }
                            break;
                        case "4":
                            _xml = Load("food.xml");
                            sub_choice = Select(2);

                            if (sub_choice == "1") TestChange.RemoveNodes(_xml);
                            if (sub_choice == "2") TestChange.UpdateNodes(_xml);
                            if (sub_choice == "3") TestChange.AppendNodes(_xml);
                            if (sub_choice == "4") TestChange.InsertNodes(_xml);
                            if (sub_choice == "5") TestChange.AddAttribute(_xml);
                            break;
                    }

                    _xml = null;    // remove XML documents
                    back = BackMainMenu();
                }

                // exit program
                if (choice == "0")
                {
                    Console.WriteLine("Exiting program..");
                    break;
                }
            }
            while (valid(choice));
            
            Console.ReadKey();
        }

        static bool valid(string choice)
        {
            return (choice == "1" || choice == "2" || choice == "3" || choice == "4");
        }

        static string BackMainMenu()
        {
            var ans = "n";
            //while (((back = BackMainMenu()) != 'y') || (back != 'n')) ;
            while (true)
            {
                Console.Write("\nBack to main menu (Y/N)? ");
                ans = Console.ReadLine();
                if (ans == "y" || ans == "n") break;
            }
            return ans;
        }
        
        static string Continue()
        {
            var ans = "n";
            while (true)
            {
                Console.Write("\nDo you want to continue (Y/N)? ");
                ans = Console.ReadLine();
                if (ans == "y" || ans == "n") break;
            }
            return ans;
        }

        static string Select(int index)
        {
            var choice = "1";
            while (true)    // selection
            {
                Console.Write("\nSelect: ");
                choice = Console.ReadLine();
                if ((index == 0 && (choice == "0" || valid(choice))) || 
                    (index == 1 && valid(choice)) ||
                    (index == 2 && (valid(choice) || choice == "5")))
                    break;
                else
                    Console.WriteLine("Error: Wrong choice! Try again.\n");
            }
            
            return choice;
        }

        static void Menu()
        {
            Console.Clear();
            Console.WriteLine("==================================");
            Console.WriteLine("============ MAIN MENU ===========");
            Console.WriteLine("==================================");
            Console.WriteLine(" 1. Load XML from file *.xml");
            Console.WriteLine(" 2. Search for information");
            Console.WriteLine(" 3. Access to content of nodes");
            Console.WriteLine(" 4. Change content of document");
            Console.WriteLine(" 0. Exit");
        }

        static void SubMenu(string index)
        {
            Console.Clear();
            switch (index)
            {
                case "1":
                    Console.WriteLine("Result: *.xml is loaded successfully!");
                    break;
                case "2":
                    Console.WriteLine("Sub menu #2: Search for information");
                    Console.WriteLine(" 1. using GetElementsByTagName");
                    Console.WriteLine(" 2. using GetElementsById");
                    Console.WriteLine(" 3. using SelectNodes");
                    Console.WriteLine(" 4. using SelectSingleNode");
                    break;
                case "3":
                    Console.WriteLine("Sub menu #3: Access to content of nodes, where case of NodeType includes:");
                    Console.WriteLine(" 1. NodeType = XmlElement");
                    Console.WriteLine(" 2. NodeType = XmlText");
                    Console.WriteLine(" 3. NodeType = XmlComment");
                    Console.WriteLine(" 4. NodeType = XmlProcessingInstruction");
                    Console.WriteLine(" 5. Access to attributes");
                    break;
                case "4":
                    Console.WriteLine("Sub menu #4: Change content of document");
                    Console.WriteLine("    Notice!!! Result will be saved into new file *.xml\n");
                    Console.WriteLine(" 1. Remove nodes");
                    Console.WriteLine(" 2. Update nodes");
                    Console.WriteLine(" 3. Append nodes");
                    Console.WriteLine(" 4. Insert nodes");
                    Console.WriteLine(" 5. Add attributes");
                    break;
                default:
                    Console.WriteLine("Exiting program..");
                    break;
            }
        }

        static XmlDocument Load(string name)
        {
            string path = "../../source/" + name;
            XmlDocument _xml = new XmlDocument();
            FileStream _stream = new FileStream(path, FileMode.Open);
            _xml.Load(_stream);
            _stream.Close();
            Console.WriteLine("\n# Using source file [" + name + "]");
            return _xml;
        }
    }

    class TestReader
    {
        public static void ExecuteTagName(XmlDocument _xml)
        {
            // GET element by tag name
            Console.WriteLine("\n# Top hot MV in June 2016 (using Tags: 'Name' and 'Singer'):");
            XmlNodeList _name = _xml.GetElementsByTagName("Name");
            for (var j = 0; j < _name.Count; j++)
            {
                Console.Write(" + " + _name[j].ChildNodes[0].Value + " - ");

                XmlElement tmp = (XmlElement)_xml.DocumentElement.ChildNodes[j];
                var _info = tmp.GetElementsByTagName("Singer");
                Console.WriteLine(_info[0].ChildNodes[0].Value);

                tmp = null;
            }
            _name = null;
        }

        public static void ExecuteById(XmlDocument _xml)//, FileStream _stream)
        {
            Console.WriteLine("\n# Top hot MV in June 2016 (using ID: 1-5):");

            //XmlValidatingReader _validR = new XmlValidatingReader(_stream, XmlNodeType.Document, null);
            string[] id = { "1", "2", "3", "4", "5" };

            foreach (string curid in id)
            {
                XmlElement tmp = _xml.GetElementById(curid);
                Console.WriteLine(" + " + tmp.ChildNodes[0].ChildNodes[0].Value + " (" + tmp.ChildNodes[3].ChildNodes[0].Value + ")");
                tmp = null;
            }
            //_validR = null;
        }

        public static void ExecuteNodes(XmlDocument _xml, int flag)
        {
            Console.WriteLine("\n# Top MV having greater than 10k views (using Node):");

            string path = "//mv/Name/text()[../../Views/text() > '10000000']";
            switch (flag)
            {
                case 0:     // SELECT SINGLE NODE
                    XmlNode node = _xml.SelectSingleNode(path);
                    Console.WriteLine("  1. " + node.Value);
                    node = null;
                    break;
                case 1:
                    XmlNodeList list = _xml.SelectNodes(path);
                    for (var j = 0; j < list.Count; j++)
                        Console.WriteLine("  " + (j + 1).ToString() + ". " + list[j].Value);
                    list = null;
                    break;
            }
        }
    }

    class TestAccess
    {
        public static void ReviewElement(XmlDocument _xml, int index)   // using book
        {
            Console.WriteLine("\nBook review:");
            XmlElement temp = (XmlElement)_xml.DocumentElement.ChildNodes[index];
            Console.WriteLine(" + Author: " + temp.ChildNodes[0].InnerText);
            Console.WriteLine(" + Title : " + temp.ChildNodes[1].InnerText);
            Console.WriteLine(" + Genre : " + temp.ChildNodes[2].InnerText);
            Console.WriteLine(" + Price : " + temp.ChildNodes[3].InnerText);
            Console.WriteLine(" + Published-Date: " + temp.ChildNodes[4].InnerText);
            Console.WriteLine(" + Description: " + temp.ChildNodes[5].InnerText);
            temp = null;
        }

        public static void ReviewText(XmlDocument _xml)
        {
            Console.WriteLine("\n# [CDATA]:");
            var content = _xml.DocumentElement.ChildNodes;    // XML-TEXT !?!
            for (var j = 0; j < content.Count; j++)
            {
                if (content[j].NodeType == XmlNodeType.CDATA)
                    Console.WriteLine(content[j].Value);
            }
            content = null;    
        }

        public static void ReviewComment(XmlDocument _xml)
        {
            Console.WriteLine("\n# [Comments]:\n");
            var list = _xml.DocumentElement.ChildNodes;
            for (var j = 0; j < list.Count; j++)
            {
                if (list[j].NodeType == XmlNodeType.Comment)
                    Console.WriteLine("  #" + (j+1).ToString() + " " + list[j].Value + "\n");
            }
            list = null;
        }

        public static void ReviewProcessingInstruction(XmlDocument _xml, int index)
        {
            Console.WriteLine("\nReview:");
            XmlProcessingInstruction proc = (XmlProcessingInstruction)_xml.DocumentElement.ChildNodes[index];
            Console.WriteLine(" + Name: " + proc.Name);
            Console.WriteLine(" + Data: " + proc.Data);
            proc = null;
        }

        public static void ReviewAttribute(XmlDocument _xml, int index)
        {
            Console.WriteLine("\n# List of attributes from the first iPhone:");

            XmlAttributeCollection model = (XmlAttributeCollection)_xml.ChildNodes[0].ChildNodes[index].Attributes;
            for (var j = 0; j < model.Count; j++)
                Console.WriteLine(" - " + model[j].Name + ": " + model[j].Value);
            Console.WriteLine("\n - Information:");
            XmlAttributeCollection list = (XmlAttributeCollection)_xml.ChildNodes[0].ChildNodes[index].ChildNodes[0].Attributes;
            for (var j = 0; j < list.Count; j++)
                Console.WriteLine("   + " + list[j].Name + ": " + list[j].Value);
            model = null;
            list = null;
            _xml = null;
        }
    }

    class TestChange
    {
        public static void RemoveNodes(XmlDocument _xml)
        {
            Console.WriteLine("\n# Remove all NodeName = 'description':");
            var node = _xml.DocumentElement.ChildNodes;
            for (int i = 0; i < node.Count; i++)
                node[i].RemoveChild(node[i].SelectNodes("//food/description")[0]);
            
            Console.WriteLine(". Total removed ChildNodes: {0}\n", node.Count);
            Console.WriteLine(". Result is saved into [./changed/log.xml]. Open to view it's changes.");
            _xml.Save("../../source/changed/log.xml");
            node = null;
        }

        public static void UpdateNodes(XmlDocument _xml)
        {
            Console.WriteLine("\n# Update all prices (x2):");
            var node = _xml.SelectNodes("//food/price/text()");
            for (int j = 0; j < node.Count; j++)
            {
                string value = node[j].Value;
                string main = value.Substring(1, value.Length - 1);
                double real = double.Parse(main) * 2;

                node[j].Value = "$" + real.ToString();
            }

            Console.WriteLine(". Total updated childnodes: {0}\n", node.Count);
            Console.WriteLine(". Result is saved into [./changed/log.xml]. Open to view it's changes.");
            _xml.Save("../../source/changed/log.xml");
            node = null;
        }

        public static void AppendNodes(XmlDocument _xml)
        {
            Console.WriteLine("\n# Append all nodes by <votes>:");
            var node = _xml.DocumentElement.ChildNodes;
            Random ran = new Random();
            for (int i = 0; i < node.Count; i++)
            {
                XmlElement times = _xml.CreateElement("votes");
                XmlText value = _xml.CreateTextNode(ran.Next(100).ToString());
                times.AppendChild(value);
                node[i].AppendChild(times);
                System.Threading.Thread.Sleep(5);
            }

            Console.WriteLine(". Total appended childnodes: {0}\n", node.Count);
            Console.WriteLine(". Result is saved into [./changed/log.xml]. Open to view it's changes.");
            _xml.Save("../../source/changed/log.xml");
            ran = null;
            node = null;
        }

        public static void InsertNodes(XmlDocument _xml)
        {
            string[] days = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" };
            
            Console.WriteLine("\n# Insert all nodes by <day>:");
            var node = _xml.DocumentElement.ChildNodes;
            Random ran = new Random();
            for (int i = 0; i < node.Count; i++)
            {
                XmlElement day = _xml.CreateElement("day");
                day.InnerText = days[ran.Next(days.Length)];
                System.Threading.Thread.Sleep(5);

                node[i].PrependChild(day);
            }

            Console.WriteLine(". Total inserted childnodes: {0}\n", node.Count);
            Console.WriteLine(". Result is saved into [./changed/log.xml]. Open to view it's changes.");
            _xml.Save("../../source/changed/log.xml");
            ran = null;
            node = null;
        }

        public static void AddAttribute(XmlDocument _xml)
        {
            Console.WriteLine("\n# Add attribute for main:");
            XmlAttribute _att = _xml.CreateAttribute("publised-date");
            _att.Value = "2016-11-11";
            _xml.DocumentElement.SetAttributeNode(_att);
            _xml.Save("../../source/changed/log.xml");
            
            Console.WriteLine(". Result is saved into [./changed/log.xml]. Open to view it's changes.");
            _att = null;
        }
    }
}
