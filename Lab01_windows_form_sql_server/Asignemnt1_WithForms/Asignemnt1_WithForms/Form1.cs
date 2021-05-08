using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Data.SqlClient;

namespace Asignemnt1_WithForms
{
    public partial class Form1 : Form
    {
        SqlConnection databaseConnection;   // create an object for a SQL Server database connection
        SqlDataAdapter dataAdapterClients, dataAdapterOrders;   // create objects for a two-way communication
                                                                // these objects store a set of commands and a connection
                                                                // and can fill the dataSet or update the database
        DataSet dataSet;    // create an object to temporarily store data from the database
                            // in-memory cache
                            // properties: Tables (collection of tables) and Relations (collection of child/parent tables)
        BindingSource bindingSourceClients, bindingSourceOrders;    // create an object to encapsulate data such that it can be shown on a form

        SqlCommandBuilder commandBuilder;

        private void updateButton_Click(object sender, EventArgs e)
        {
            // when the button is clicked we want to update the orders (child) table in the database
            dataAdapterOrders.Update(dataSet, "orders");
        }

        public Form1()
        {
            InitializeComponent();
        }


        private void Form1_Load(object sender, EventArgs e)
        {
            // first step: CONNECTING TO DATA
            databaseConnection = new SqlConnection(@"Data Source = DESKTOP-5K2EO8O\MSSQLSERVER01;" +
                "Initial Catalog = clothes_company_DB; Integrated Security = SSPI");


            dataSet = new DataSet();    // initialize the data set object 
            // step two: FETCHING DATA INTO THE APP
            dataAdapterClients = new SqlDataAdapter("SELECT * FROM clients", databaseConnection);
            dataAdapterOrders = new SqlDataAdapter("SELECT * FROM orders", databaseConnection);
            commandBuilder = new SqlCommandBuilder(dataAdapterOrders);

            dataAdapterClients.Fill(dataSet, "clients");
            dataAdapterOrders.Fill(dataSet, "orders");


            // step three:  CREATE A RELATION BETWEEN PARENT AND CHILD
            //              so that when selecting a parent only data of it's children will be shown
            DataRelation dataRelation = new DataRelation("FK_clients_orders",
                dataSet.Tables["clients"].Columns["CNP"],
                dataSet.Tables["orders"].Columns["customer_CNP"]);
            dataSet.Relations.Add(dataRelation);

            // step four: create bindingSources so that data can be easily read and updated, while being able to see it in the form
            bindingSourceClients = new BindingSource();
            bindingSourceClients.DataSource = dataSet;
            bindingSourceClients.DataMember = "clients";


            bindingSourceOrders = new BindingSource();
            bindingSourceOrders.DataSource = bindingSourceClients;
            bindingSourceOrders.DataMember = "FK_clients_orders";

            // last step: connect the gridViews to their bindingSources
            dgvClients.DataSource = bindingSourceClients;
            dgvOrders.DataSource = bindingSourceOrders;
        }
    }
}
