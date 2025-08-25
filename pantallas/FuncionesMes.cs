using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace WebApplicationPMRO2
{
    public class FuncionesMes
    {
        public static string ConnectionString { get; set; } =
          ConfigurationManager.ConnectionStrings["MESConn"].ConnectionString;

        public static SqlDataReader ExecuteReader(string storedProc, string[] paramNames, object[] paramValues)
        {
            if (paramNames == null) paramNames = Array.Empty<string>();
            if (paramValues == null) paramValues = Array.Empty<object>();
            if (paramNames.Length != paramValues.Length)
                throw new ArgumentException("paramNames y paramValues deben tener la misma longitud.");

            var conn = new SqlConnection(ConnectionString);
            var cmd = conn.CreateCommand();
            cmd.CommandText = storedProc;
            cmd.CommandType = CommandType.StoredProcedure;

            for (int i = 0; i < paramNames.Length; i++)
            {
                cmd.Parameters.AddWithValue(paramNames[i], paramValues[i] ?? DBNull.Value);
            }

            conn.Open();
            // Al cerrar el reader, se cierra la conexión.
            return cmd.ExecuteReader(CommandBehavior.CloseConnection);
        }

        // Helper para obtener DataTable (ideal para bindear Repeater/Grid, etc.)
        public static DataTable ExecuteDataTable(string storedProc, string[] paramNames, object[] paramValues)
        {
            using (var reader = ExecuteReader(storedProc, paramNames, paramValues))
            {
                var dt = new DataTable();
                dt.Load(reader);
                return dt;
            }
        }

        // Tu helper de combos (idéntico, sin cambios)
        public static void LlenarDropDownList(
          DropDownList ddl,
          string storedProcedure,
          string[] parametros,
          string[] valores,
          string textoDefault,
          string valorDefault,
          string campoTexto,
          string campoValor)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add(campoValor);
            dt.Columns.Add(campoTexto);

            DataRow defaultRow = dt.NewRow();
            defaultRow[campoValor] = valorDefault;
            defaultRow[campoTexto] = textoDefault;
            dt.Rows.Add(defaultRow);

            using (SqlDataReader reader = ExecuteReader(storedProcedure, parametros, valores))
            {
                if (reader != null)
                {
                    while (reader.Read())
                    {
                        DataRow row = dt.NewRow();
                        row[campoValor] = reader[campoValor].ToString();
                        row[campoTexto] = reader[campoTexto].ToString();
                        dt.Rows.Add(row);
                    }
                }
            }

            ddl.DataSource = dt;
            ddl.DataTextField = campoTexto;
            ddl.DataValueField = campoValor;
            ddl.DataBind();
        }
    }
}
