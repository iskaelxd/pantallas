using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using WebApplicationPMRO2; // <= FuncionesMes

namespace MES
{
    public partial class KiteoTV : System.Web.UI.Page
    {
        // Líneas a mostrar (11 cards)
        private static readonly string[] LINES = new[]
        { "IR","YK","YZ","TEMPO","VSD","VSD2","VSD3","VSD4","OPTIVIEW","INV1","VDC" };

        // 🚨 PASA LOS IDs DESDE BACKEND: completa este diccionario con los Id_Estacion (primera estación o la que tú definas)
        // Puedes sobreescribirlos por QueryString usando ?idestmap=IR=1;YK=9;...
        private static readonly Dictionary<string, int> StationIdForLine =
          new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
        {
      { "IR", 1 }, { "YK", 9 }, { "YZ", 14 }, { "TEMPO", 19 }, { "VSD", 23 },
      { "VSD2", 29 }, { "VSD3", 35 }, { "VSD4", 40 }, { "OPTIVIEW", 45 }, { "INV1", 49 }, { "VDC", 55 }
        };

        private Dictionary<string, int> GetStationMapFromQueryOrDefault()
        {
            var map = new Dictionary<string, int>(StationIdForLine, StringComparer.OrdinalIgnoreCase);
            var raw = Request.QueryString["idestmap"];
            if (string.IsNullOrWhiteSpace(raw)) return map;

            foreach (var pair in raw.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries))
            {
                var kv = pair.Split(new[] { '=' }, 2);
                if (kv.Length != 2) continue;
                var line = kv[0].Trim();
                if (int.TryParse(kv[1].Trim(), out int id) && !string.IsNullOrEmpty(line))
                    map[line] = id;
            }
            return map;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindLines();
            }
        }

        protected void tmrRefresh_Tick(object sender, EventArgs e)
        {
            BindLines();
            updMain.Update();
        }

        private void BindLines()
        {
            // 5 arriba, 6 abajo
            var dtTop = new DataTable(); dtTop.Columns.Add("Linea", typeof(string));
            foreach (var ln in LINES.Take(5)) dtTop.Rows.Add(ln);
            var dtBottom = new DataTable(); dtBottom.Columns.Add("Linea", typeof(string));
            foreach (var ln in LINES.Skip(5)) dtBottom.Rows.Add(ln);

            rptTop.DataSource = dtTop; rptTop.DataBind();
            rptBottom.DataSource = dtBottom; rptBottom.DataBind();
        }

        protected void rpt_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

            var drv = (e.Item.DataItem as System.Data.DataRowView);
            var linea = Convert.ToString(drv["Linea"]);
            var stationId = ResolveStationId(linea);

            // Controles
            var lblEst = (Label)e.Item.FindControl("lblEst");
            var pnlActual = (Panel)e.Item.FindControl("pnlActual");
            var pnlLoading = (Panel)e.Item.FindControl("pnlLoading");
            var pnlEmpty = (Panel)e.Item.FindControl("pnlEmpty");
            var divCurrent = (HtmlGenericControl)e.Item.FindControl("divCurrent");
            var rptQueue = (Repeater)e.Item.FindControl("rptQueue");

            lblEst.Text = stationId.HasValue ? stationId.Value.ToString() : "—";

            // ACTUAL (C) — OBLIGATORIO IdEstacion
            if (!stationId.HasValue || stationId.Value <= 0)
            {
                pnlActual.Visible = false;
                pnlLoading.Visible = true;
            }
            else
            {
                var dtActual = ExecSP_DataTable("C", linea, stationId.Value, null);
                if (dtActual.Rows.Count == 0)
                {
                    pnlActual.Visible = false;
                    pnlLoading.Visible = true;
                }
                else
                {
                    pnlLoading.Visible = false;
                    pnlActual.Visible = true;
                    var row = dtActual.Rows[0];
                    var serie = Convert.ToString(row["Numero_Serie"]);
                    var color = Convert.ToString(row["ColorActual"]); // 'green'|'red'
                    divCurrent.InnerText = serie;
                    divCurrent.Attributes["class"] = "current " + color;
                }
            }

            // COLA (Q) — Top10 HOY por línea
            var dtQueue = ExecSP_DataTable("Q", linea, null, null);
            if (dtQueue.Rows.Count == 0)
            {
                rptQueue.DataSource = null; rptQueue.DataBind();
                pnlEmpty.Visible = true;
            }
            else
            {
                pnlEmpty.Visible = false;
                rptQueue.DataSource = dtQueue; rptQueue.DataBind();
            }
        }

        private int? ResolveStationId(string linea)
        {
            var map = GetStationMapFromQueryOrDefault();
            return map.TryGetValue(linea, out var id) ? id : (int?)null;
        }

        // Wrapper usando FuncionesMes.ExecuteDataTable
        private DataTable ExecSP_DataTable(string transaCode, string linea, int? idEstacion, DateTime? fecha)
        {
            var names = new[] { "@TransaCode", "@Linea", "@IdEstacion", "@Fecha" };
            var values = new object[] { transaCode, linea, (object)idEstacion ?? DBNull.Value, (object)fecha ?? DBNull.Value };
            return FuncionesMes.ExecuteDataTable("dbo.SP_MES_KiteoPantalla", names, values);
        }
    }
}
