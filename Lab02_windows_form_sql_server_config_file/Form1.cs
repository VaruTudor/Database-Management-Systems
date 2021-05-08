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
using System.Configuration;

namespace Lab2_firstTry
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

        String parentTable = ConfigurationManager.AppSettings["parentTable"];
        String childTable = ConfigurationManager.AppSettings["childTable"];
        String parentPK = ConfigurationManager.AppSettings["parentPK"];
        String childFK = ConfigurationManager.AppSettings["childFK"];

        private void updateButton_Click(object sender, EventArgs e)
        {
            // when the button is clicked we want to update the orders (child) table in the database
            dataAdapterOrders.Update(dataSet, childTable);
        }

        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            // setting up the needed strings for managing the app
            
            var relation = "FK_parent_child";
            var selectFrom = "SELECT * FROM ";
            var connectionString = ConfigurationManager.ConnectionStrings["clothes_company_DB"].ConnectionString;


            // first step: CONNECTING TO DATA
            databaseConnection = new SqlConnection(@connectionString);


            dataSet = new DataSet();    // initialize the data set object 
            // step two: FETCHING DATA INTO THE APP
            dataAdapterClients = new SqlDataAdapter(selectFrom + parentTable, databaseConnection);
            dataAdapterOrders = new SqlDataAdapter(selectFrom + childTable, databaseConnection);
            commandBuilder = new SqlCommandBuilder(dataAdapterOrders);

            dataAdapterClients.Fill(dataSet, parentTable);
            dataAdapterOrders.Fill(dataSet, childTable);


            // step three:  CREATE A RELATION BETWEEN PARENT AND CHILD
            //              so that when selecting a parent only data of it's children will be shown
            DataRelation dataRelation = new DataRelation(relation,
                dataSet.Tables[parentTable].Columns[parentPK],
                dataSet.Tables[childTable].Columns[childFK]);
            dataSet.Relations.Add(dataRelation);

            // step four: create bindingSources so that data can be easily read and updated, while being able to see it in the form
            bindingSourceClients = new BindingSource();
            bindingSourceClients.DataSource = dataSet;
            bindingSourceClients.DataMember = parentTable;


            bindingSourceOrders = new BindingSource();
            bindingSourceOrders.DataSource = bindingSourceClients;
            bindingSourceOrders.DataMember = relation;

            // last step: connect the gridViews to their bindingSources
            dgvClients.DataSource = bindingSourceClients;
            dgvOrders.DataSource = bindingSourceOrders;
            parentLabel.Text= parentTable;
            childLabel.Text= childTable;
        }
    }
}
