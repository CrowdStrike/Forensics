/// <summary>LogParser COM Input format sample</summary>
namespace MSUtil.LogQuery.Sample
{
    using System;
    using System.Collections;
    using System.Runtime.InteropServices;
    using System.Xml;
    using System.Xml.XPath;
    
    public interface ILogParserInputContext
    {
        void OpenInput(string from);
        int GetFieldCount();
        string GetFieldName(int index);
        int GetFieldType(int index);
        bool ReadRecord();
        object GetValue(int index);
        void CloseInput(bool abort);
    }

    // TODO: Generate a unique GUID for your input format
    /// <summary>XMLInputFormat for LogParser</summary>
    [Guid("FBB03457-D80A-4d83-AB3A-2DF63779DDC8")]
    public class XMLInputFormat : ILogParserInputContext
    {
        // For an XML file, such as books.xml, the following 'fields' are available:
				// Author
				// Price
				// PubDate
        
        XmlDocument xmlFile;
        IEnumerator bookNodes;
        ArrayList xmlFields;
        
        #region LogField Class
        private class LogField
        {
            string fieldName;
            FieldType fieldType;

            public LogField(string FieldName, FieldType FieldType)
            {
                fieldName = FieldName;
                fieldType = FieldType;
            }

            public string FieldName
            {
                get { return fieldName; }
                set { fieldName = value; }
            }

            public FieldType FieldType
            {
                get { return fieldType; }
                set { fieldType = value; }
            }
        }
        #endregion

        /// <summary>XMLInputFormat constructor</summary>
        public XMLInputFormat()
        {
            xmlFields = new ArrayList();
            
            xmlFields.Add(new LogField("Author", FieldType.String));  
            xmlFields.Add(new LogField("Price", FieldType.Real));
            xmlFields.Add(new LogField("PubDate", FieldType.Timestamp));
        }

        /// <summary>InputFormat.FieldType Enumeration</summary>
        private enum FieldType
        {
            /// <summary>VT_I8</summary>
            Integer = 1,
            /// <summary>VT_R8</summary>
            Real = 2,
            /// <summary>VT_BSTR</summary>
            String = 3,
            /// <summary>VT_DATE or VT_I8 (UTC)</summary>
            Timestamp = 4
        }

        /// <summary>Open a log file or resource</summary>
        /// <param name="from">Entity to open that specified in the FROM statement</param>
        public void OpenInput(string from)
        {
            if( from != "" )
            {
                // Load the xml file
                xmlFile = new XmlDocument();
                xmlFile.Load(from);
                XmlNode xmlNodeRoot = xmlFile.FirstChild;
                XmlNode booksNode = xmlNodeRoot.NextSibling;

                // Get an enumerator for the book nodes
                XmlNodeList bookNodeList = booksNode.SelectNodes("book");
                bookNodes = bookNodeList.GetEnumerator();
            }
        }

        /// <summary>Return the total number of fields that are exported to logparser</summary>
        /// <returns>Number of fields in entity</returns>
        public int GetFieldCount()
        {
            return xmlFields.Count;
        }

        /// <summary>Return the name of the field. Method is called as many times as specified by GetFieldCount.</summary>
        /// <param name="index">0 based index of the field name to return</param>
        /// <returns>Field name</returns>
        public string GetFieldName(int index)
        {
            LogField logfield = (LogField)xmlFields[index];
            return logfield.FieldName;
        }

        /// <summary>Returns the type of the field. Method is called as many times as specified by GetFieldCount.</summary>
        /// <param name="index">0 based index of the field type to return</param>
        /// <returns>Field Type</returns>
        public int GetFieldType(int index)
        {
            LogField logfield = (LogField)xmlFields[index];
            return (int)logfield.FieldType;
        }

        /// <summary>Read a new record advancing the internal 'state' machine. This method is called until there are no more records to export.</summary>
        /// <returns>TRUE if record was read, FALSE if there are no more records to read</returns>
        public bool ReadRecord()
        {
            return bookNodes.MoveNext();
        }

        /// <summary>Must return the value of the last record 'read'</summary>
        /// <param name="index">0 based index of the field value to read</param>
        /// <returns>Value of the field. Can also return null.</returns>
        public object GetValue(int index)
        {
            LogField lf = (LogField)xmlFields[index];

            // Look each value in the XML file
            XmlNode bookNode = (XmlNode)bookNodes.Current;
            
            if (String.Compare(lf.FieldName, "Author") == 0)
            {
                XmlNode bookDetailsNode = bookNode.SelectSingleNode("author");
                return bookDetailsNode.InnerText;
            }
            else if (String.Compare(lf.FieldName, "Price") == 0)
            {
                XmlNode bookDetailsNode = bookNode.SelectSingleNode("price");
                Double price = Double.Parse(bookDetailsNode.InnerText);
                return price;
            }
            else if (String.Compare(lf.FieldName, "PubDate") == 0)
            {
                XmlNode bookDetailsNode = bookNode.SelectSingleNode("pubdate");
                DateTime dt = DateTime.Parse(bookDetailsNode.InnerText);
                return dt;
            }
            return null;
        }

        /// <summary>Close log file or resource</summary>
        /// <param name="abort">TRUE if execution is terminated by abnormal situation, such as Ctrl+C</param>
        public void CloseInput(bool abort)
        {
        }
    }
}

