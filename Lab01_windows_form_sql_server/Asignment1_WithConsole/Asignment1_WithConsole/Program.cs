using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Data.SqlClient;
using System.Data;

namespace Asignment1_WithConsole
{
    class Program
    {

        static void Main(string[] args)
        {
            // first step is to create a connection
            SqlConnection connection = new SqlConnection();

            SqlConnectionStringBuilder connectionStringBuilder = new SqlConnectionStringBuilder(getConnectionString());
            connection.ConnectionString = connectionStringBuilder.ConnectionString;

            bool showMenu = true;
            while (showMenu)
            {
                showMenu = MainMenu(connection);
            }

        }

        private static void displayRecordsFromPartentTable(SqlConnection connection)
        {
            // create a new DataSet where we will temporary store the data
            DataSet dataSet = new DataSet();

            SqlDataAdapter dataAdapter = new SqlDataAdapter("SELECT * FROM shop", connection);
            SqlCommandBuilder commandBuilder = new SqlCommandBuilder(dataAdapter);
            dataAdapter.Fill(dataSet, "shop");

            Console.WriteLine("Columns: sidentifier, shop_name, supplier_id");
            foreach (DataRow currentDataRow in dataSet.Tables["shop"].Rows)
            {
                Console.WriteLine("{0}, {1}, {2}", currentDataRow["sidentifier"], currentDataRow["shop_name"],currentDataRow["supplier_id"]);
            }
        }

        private static void displayRecordsFromChildTable(SqlConnection connection, int parentRecordId)
        {
            // create a new DataSet where we will temporary store the data
            DataSet dataSet = new DataSet();

            SqlDataAdapter dataAdapter = new SqlDataAdapter("SELECT * FROM employee", connection);
            SqlCommandBuilder commandBuilder = new SqlCommandBuilder(dataAdapter);
            dataAdapter.Fill(dataSet, "employee");

            Console.WriteLine("Columns: CNP, first_name, last_name");
            foreach (DataRow currentDataRow in dataSet.Tables["employee"].Rows)
            {
                if((int)currentDataRow["shop_id"] == parentRecordId)
                {
                    Console.WriteLine("{0}, {1}, {2}", currentDataRow["CNP"], currentDataRow["first_name"], currentDataRow["last_name"]);
                }
            }
        }

        private static void addToChildTable(SqlConnection connection, int shop_id, String first_name, String last_name)
        {
            connection.Open();
            SqlCommand insertCmd = new SqlCommand();
            insertCmd.CommandText = "INSERT INTO employee(shop_id,first_name,last_name) VALUES(" + shop_id + ",'" + first_name + "','" + last_name + "');";
            insertCmd.CommandType = CommandType.Text;
            insertCmd.Connection = connection;

            Console.WriteLine("{0} Rows affected",insertCmd.ExecuteNonQuery());
            connection.Close();
        }

        private static void removeToChildTable(SqlConnection connection, int CNP)
        {
            connection.Open();
            SqlCommand insertCmd = new SqlCommand();
            insertCmd.CommandText = "DELETE FROM employee WHERE CNP=" + CNP + ";";
            insertCmd.CommandType = CommandType.Text;
            insertCmd.Connection = connection;

            Console.WriteLine("{0} Rows affected", insertCmd.ExecuteNonQuery());
            connection.Close();
        }

        private static String getConnectionString()
        {
            return "Data Source = DESKTOP-5K2EO8O\\MSSQLSERVER01; Initial Catalog = clothes_company_DB; Integrated Security = SSPI";
        }

        private static bool MainMenu(SqlConnection connection)
        {
            Console.WriteLine("Choose an option:");
            Console.WriteLine("1) Display all records from parent table");
            Console.WriteLine("2) Display all records from child table given parent table");
            Console.WriteLine("3) Add");
            Console.WriteLine("4) Remove");
            Console.WriteLine("5) Update");
            Console.WriteLine("0) Exit");
            Console.Write("\r\nSelect an option: ");



            switch (Console.ReadLine())
            {
                case "1":
                    displayRecordsFromPartentTable(connection);
                    return true;
                case "2":
                    Console.Write("\r\nGive an id: ");
                    displayRecordsFromChildTable(connection, int.Parse(Console.ReadLine()));
                    return true;
                case "3":
                    Console.Write("\r\nGive an id: ");
                    int shop_id = int.Parse(Console.ReadLine());
                    Console.Write("\r\nGive first name: ");
                    String first_name = Console.ReadLine();
                    Console.Write("\r\nGive last name: ");
                    String last_name = Console.ReadLine();
                    addToChildTable(connection, shop_id, first_name, last_name);
                    return true;
                case "4":
                    Console.Write("\r\nGive a CNP: ");
                    removeToChildTable(connection, int.Parse(Console.ReadLine()));
                    return true;
                case "5":
                    //TODO
                    return true;
                case "0":
                    return false;
                default:
                    return true;
            }
        }
        
    }
}
