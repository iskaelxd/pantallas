using System;
using System.Data;
using System.Linq;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using WebApplicationPMRO2; // FuncionesMes

namespace MES
{
    public partial class IR_SwinLine : System.Web.UI.Page
    {
        private string Linea => Request.QueryString["linea"] ?? "IR";
        private int IdEstacion => int.TryParse(Request.QueryString["idest"], out var x) ? x : 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                lblLinea.Text = Linea;
                BindAll();
            }
        }

        protected void tmrRefresh_Tick(object sender, EventArgs e)
        {
            BindAll();
        }

        private void BindAll()
        {
            BindActual();
            BindSwinlineYKiteo();
        }

        private void BindActual()
        {
            // TransaCode='C' (último iniciado, sin Fecha_Fin, en la estación indicada)
            var dt = Exec("C", Linea, IdEstacion, DateTime.Today);
            if (dt.Rows.Count == 0)
            {
                pnlActual.Visible = false;
                pnlLoading.Visible = true;
                return;
            }
            pnlLoading.Visible = false;
            pnlActual.Visible = true;

            var r = dt.Rows[0];
            var serie = Convert.ToString(r["Numero_Serie"]);
            var color = Convert.ToString(r["ColorActual"]); // green|red

            divCurrent.InnerText = serie;
            divCurrent.Attributes["class"] = "current " + color;
        }

        private void BindSwinlineYKiteo()
        {
            // TransaCode='W' (lista de hoy + tack de la estación indicada)
            var dt = Exec("W", Linea, IdEstacion, DateTime.Today);

            // TACK (minutos -> segundos, defensivo)
            int tackMin = 10;
            if (dt.Rows.Count > 0)
            {
                var raw = (dt.Rows[0]["Tack_Estacion_Minutos"] ?? "").ToString().Trim();
                int mParsed;
                if (int.TryParse(raw, out mParsed) && mParsed > 0) tackMin = mParsed;
            }
            hfTackSeconds.Value = (tackMin * 60).ToString();

            // ---- SWINLINE: entregados (KitEntregado = 1), hasta 4 ----
            var swEnum = dt.AsEnumerable()
                           .Where(r => IsOne(r["KitEntregado"]))
                           .OrderBy(r => ToIntOr(r["Secuencia"], int.MaxValue))
                           .Take(4);

            DataTable sw = swEnum.Any() ? swEnum.CopyToDataTable() : DtExt.CreateEmptySchemaLike(dt);
            rptSwDelivered.DataSource = sw;
            rptSwDelivered.DataBind();

            // Ghost timers (si faltan lugares)
            int ghosts = Math.Max(0, 4 - sw.Rows.Count);
            var tblGhosts = new DataTable();
            tblGhosts.Columns.Add("Key", typeof(string));
            for (int i = 1; i <= ghosts; i++)
            {
                var row = tblGhosts.NewRow();
                row["Key"] = $"sw{i}";
                tblGhosts.Rows.Add(row);
            }
            rptSwGhosts.DataSource = tblGhosts;
            rptSwGhosts.DataBind();

            // ---- KITEO: no entregados (NULL/0/false), excluyendo los ya tomados por Swinline, hasta 4 ----
            var swSeries = sw.AsEnumerable()
                             .Select(r => (r["Numero_Serie"] ?? "").ToString())
                             .Where(s => !string.IsNullOrWhiteSpace(s))
                             .ToHashSet(StringComparer.OrdinalIgnoreCase);

            var ktEnum = dt.AsEnumerable()
                           .Where(r => !IsOne(r["KitEntregado"]))
                           .Where(r => !swSeries.Contains((r["Numero_Serie"] ?? "").ToString()))
                           .OrderBy(r => ToIntOr(r["Secuencia"], int.MaxValue))
                           .Take(4);

            DataTable kt = ktEnum.Any() ? ktEnum.CopyToDataTable() : DtExt.CreateEmptySchemaLike(dt);
            rptKiteo.DataSource = kt;
            rptKiteo.DataBind();
        }


        private DataTable Exec(string transa, string linea, int idEstacion, DateTime fecha)
        {
            var names = new[] { "@TransaCode", "@Linea", "@IdEstacion", "@Fecha" };
            var values = new object[] { transa, linea, idEstacion, fecha };
            return FuncionesMes.ExecuteDataTable("dbo.SP_MES_KiteoPantalla", names, values);
        }




        // Helpers de conversión segura
        private static bool IsOne(object v)
        {
            if (v == null || v == DBNull.Value) return false;
            if (v is bool b) return b;               // columnas BIT
            if (v is byte by) return by == 1;
            if (v is short s) return s == 1;
            if (v is int i) return i == 1;
            if (v is long l) return l == 1L;
            var s2 = v.ToString().Trim();
            if (string.Equals(s2, "true", StringComparison.OrdinalIgnoreCase)) return true;
            if (string.Equals(s2, "false", StringComparison.OrdinalIgnoreCase)) return false;
            int n; return int.TryParse(s2, out n) && n == 1;
        }

        private static int ToIntOr(object v, int fallback)
        {
            if (v == null || v == DBNull.Value) return fallback;
            try { return Convert.ToInt32(v); } catch { return fallback; }
        }




    }

    // Helpers de DataTable
    public static class DtExt
    {
        public static DataTable CreateEmptySchemaLike(DataTable src)
        {
            var dt = src.Clone();
            dt.Rows.Clear();
            return dt;
        }
    }

}
