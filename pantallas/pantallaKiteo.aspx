<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="KiteoTV.aspx.cs" Inherits="MES.KiteoTV" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
  <meta charset="utf-8" />
  <title>Muro de Órdenes – 11 Líneas (TV)</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    :root{--bg:#0b1220;--bg2:#0c1426;--panel:rgba(19,27,45,.92);--border:#2b3b5f;--text:#fff;--muted:#d1def8;--muted2:#bfd0f5;--row1:rgba(255,255,255,.06);--row2:rgba(255,255,255,.10);--green:#22c55e;--blue:#3b82f6;--red:#ef4444;--yellow:#eab308}
    *{box-sizing:border-box}html,body{height:100%}
    body{margin:0;background:radial-gradient(1200px 1200px at 80% -10%, #1b2a4a 0%, transparent 60%),radial-gradient(900px 900px at -10% 100%, #13213b 0%, transparent 60%),linear-gradient(180deg,var(--bg),var(--bg2));color:var(--text);font-family:ui-sans-serif,system-ui,Segoe UI,Roboto,Arial,sans-serif;-webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility;overflow:hidden}
    header{padding:18px 24px 8px;display:flex;align-items:center;justify-content:space-between}
    .title{font-weight:800;letter-spacing:.2px;font-size:clamp(26px,3vw,58px);text-shadow:0 2px 10px rgba(0,0,0,.55)}
    .subtitle{font-size:clamp(14px,1.4vw,22px);text-transform:uppercase;color:var(--muted);letter-spacing:.18em}
    .legend{display:flex;align-items:center;gap:18px;margin:8px 24px 0;flex-wrap:wrap}
    .legend-item{display:flex;align-items:center;gap:10px;font-size:clamp(14px,1.4vw,22px);color:var(--muted)}
    .sq{width:22px;height:22px;border-radius:6px;border:1px solid var(--border);box-shadow:0 1px 2px rgba(0,0,0,.25)}
    .sq.white{background:#ffffff}
    .sq.blue{background:var(--blue)}
    .sq.yellow{background:var(--yellow)}
    .sq.green{background:var(--green)}
    .sq.red{background:var(--red)}

    main.wall{height:calc(100vh - 120px);padding:12px 16px 18px;display:flex;flex-direction:column;gap:16px}
    .row{flex:1;display:grid;gap:12px}.row.top{grid-template-columns:repeat(5,1fr)}.row.bottom{grid-template-columns:repeat(6,1fr)}
    .station{position:relative;display:flex;flex-direction:column;min-width:0;border-radius:18px;border:1px solid var(--border);background:var(--panel);box-shadow:0 8px 24px rgba(0,0,0,.40);overflow:hidden}
    .accent{height:8px;width:100%;background:linear-gradient(90deg,#0ea5e9,#6366f1)}
    .body{display:flex;flex-direction:column;padding:16px 16px 14px;gap:14px;min-height:0}
    .meta{display:flex;align-items:center;justify-content:space-between;gap:8px}
    .station-name{color:#fff;font-weight:900;letter-spacing:.06em;text-transform:uppercase;font-size:clamp(20px,2.3vw,42px);text-shadow:0 2px 10px rgba(0,0,0,.6)}
    .pill{background:#0f1a34;border:1px solid var(--border);color:#fff;border-radius:999px;padding:8px 14px;font-weight:800;letter-spacing:.12em;text-transform:uppercase;font-size:clamp(12px,1.3vw,20px)}
    .current{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,"Courier New",monospace;font-weight:900;letter-spacing:.18em;line-height:1.05;font-size:clamp(30px,3.4vw,72px);color:#fff;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;text-shadow:0 4px 18px rgba(0,0,0,.75),0 0 14px rgba(99,102,241,.5)}
    .current.green{color:var(--green);text-shadow:none}.current.red{color:var(--red);text-shadow:none}
    .queue{border:1px solid var(--border);border-radius:14px;overflow:hidden;display:flex;flex-direction:column;min-height:0}
    .q-head{display:grid;grid-template-columns:minmax(3.2ch,4.2ch) 1fr;background:rgba(14,23,41,.95);color:#fff;text-transform:uppercase;letter-spacing:.12em;font-weight:900;font-size:clamp(18px,2vw,30px)}
    .q-head div{padding:12px 14px}.q-list{list-style:none;margin:0;padding:0;overflow:hidden}
    .q-row{display:grid;grid-template-columns:minmax(3.2ch,4.2ch) 1fr;align-items:center;padding:clamp(8px,0.9vh,14px) 14px;font-size:clamp(22px,2.2vw,38px);line-height:1.28}
    .q-row:nth-child(odd){background:var(--row1)}.q-row:nth-child(even){background:var(--row2)}
    .q-row.white{}.q-row.blue{background:rgba(59,130,246,.20)}.q-row.green{background:rgba(34,197,94,.20)}.q-row.yellow{background:rgba(234,179,8,.25)}
    .seq{text-align:right;padding-right:16px;color:var(--muted2);font-weight:900;filter:drop-shadow(0 2px 6px rgba(0,0,0,.55))}
    .ord{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,"Courier New",monospace;color:#fff;font-weight:900;letter-spacing:.04em;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
    .loader{width:64px;height:64px;border-radius:50%;border:8px solid rgba(255,255,255,.15);border-top-color:#fff;animation:spin 1s linear infinite;margin:16px auto}
    @keyframes spin{to{transform:rotate(360deg)}}
    .empty{padding:14px;color:var(--muted);font-size:clamp(18px,2vw,30px);text-align:center}
    /* ====== OVERLAYS DE COLOR MÁS FUERTES ====== */

/* Top: orden actual más “viva” */
.current.green{
  color:#22c55e;
  text-shadow:0 0 14px rgba(34,197,94,.55), 0 0 28px rgba(34,197,94,.35);
}
.current.red{
  color:#ef4444;
  text-shadow:0 0 14px rgba(239,68,68,.55), 0 0 28px rgba(239,68,68,.35);
}

/* Cola: “no kiteado” en blanco puro */
.q-row.white{
  background:#ffffff !important;     /* fuerza blanco */
  border-left:6px solid #e5e7eb;     /* sutil */
}
.q-row.white .ord{ color:#0b1220; }  /* texto oscuro sobre blanco */
.q-row.white .seq{ color:#111827; }

/* Cola: colores con más presencia + acento lateral */
.q-row.blue{
  background:rgba(59,130,246,.32);
  border-left:6px solid #3b82f6;
  box-shadow:inset 0 0 0 9999px rgba(59,130,246,.08);
}
.q-row.green{
  background:rgba(34,197,94,.32);
  border-left:6px solid #22c55e;
  box-shadow:inset 0 0 0 9999px rgba(34,197,94,.08);
}
/* Amarillo: mejor contraste con texto oscuro */
.q-row.yellow{
  background:rgba(234,179,8,.38);
  border-left:6px solid #eab308;
  box-shadow:inset 0 0 0 9999px rgba(234,179,8,.10);
}
.q-row.yellow .ord{ color:#0b1220; }
.q-row.yellow .seq{ color:#1f2937; }

/* Cabeceras/colas: más contraste general */
.q-head{ background:rgba(14,23,41,.98); }
.seq{ text-shadow:none; }

  </style>
</head>
<body>
  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <header>
      <div>
        <div class="title">MES – KITEO</div>
        <div class="subtitle">Visualización de las Órdenes de Producción (11 líneas)</div>
      </div>
      <!-- Leyenda de colores -->
      <div class="legend">
        <div class="legend-item"><span class="sq white"></span> <span>No kiteado</span></div>
        <div class="legend-item"><span class="sq blue"></span>  <span>Kiteo completo</span></div>
        <div class="legend-item"><span class="sq yellow"></span><span>Faltantes</span></div>
        <div class="legend-item"><span class="sq green"></span> <span>Kit entregado</span></div>
        <div class="legend-item"><span class="sq red"></span>   <span>No entregado (en serie en producción)</span></div>
      </div>
    </header>

    <main class="wall">
      <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
        <ContentTemplate>

          <!-- Fila superior: 5 líneas -->
          <section class="row top">
            <asp:Repeater ID="rptTop" runat="server" OnItemDataBound="rpt_ItemDataBound">
              <ItemTemplate>
                <article class="station">
                  <div class="accent"></div>
                  <div class="body">
                    <div class="meta">
                      <span class="station-name">Línea <%# Eval("Linea") %></span>
                      <span class="pill">Estación: <asp:Label ID="lblEst" runat="server" /></span>
                    </div>

                    <!-- Actual -->
                    <asp:Panel ID="pnlActual" runat="server" Visible="false">
                      <div id="divCurrent" runat="server" class="current">—</div>
                    </asp:Panel>
                    <asp:Panel ID="pnlLoading" runat="server" Visible="false">
                      <div class="loader"></div>
                    </asp:Panel>

                    <!-- Cola -->
                    <div class="queue">
                      <div class="q-head"><div>#</div><div>Orden (Top 10 de hoy)</div></div>

                      <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                        No hay unidades planeadas el día de hoy.
                      </asp:Panel>

                      <asp:Repeater ID="rptQueue" runat="server">
                        <ItemTemplate>
                          <li class='q-row <%# Eval("ColorFila") %>'>
                            <span class="seq"><%# Eval("Secuencia") %></span>
                            <span class="ord"><%# Eval("Numero_Serie") %></span>
                          </li>
                        </ItemTemplate>
                        <HeaderTemplate><ol class="q-list"></HeaderTemplate>
                        <FooterTemplate></ol></FooterTemplate>
                      </asp:Repeater>
                    </div>
                  </div>
                </article>
              </ItemTemplate>
            </asp:Repeater>
          </section>

          <!-- Fila inferior: 6 líneas -->
          <section class="row bottom">
            <asp:Repeater ID="rptBottom" runat="server" OnItemDataBound="rpt_ItemDataBound">
              <ItemTemplate>
                <article class="station">
                  <div class="accent"></div>
                  <div class="body">
                    <div class="meta">
                      <span class="station-name">Línea <%# Eval("Linea") %></span>
                      <span class="pill">Estación: <asp:Label ID="lblEst" runat="server" /></span>
                    </div>

                    <asp:Panel ID="pnlActual" runat="server" Visible="false">
                      <div id="divCurrent" runat="server" class="current">—</div>
                    </asp:Panel>
                    <asp:Panel ID="pnlLoading" runat="server" Visible="false">
                      <div class="loader"></div>
                    </asp:Panel>

                    <div class="queue">
                      <div class="q-head"><div>#</div><div>Orden (Top 10 de hoy)</div></div>
                      <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                        No hay unidades planeadas el día de hoy.
                      </asp:Panel>
                      <asp:Repeater ID="rptQueue" runat="server">
                        <ItemTemplate>
                          <li class='q-row <%# Eval("ColorFila") %>'>
                            <span class="seq"><%# Eval("Secuencia") %></span>
                            <span class="ord"><%# Eval("Numero_Serie") %></span>
                          </li>
                        </ItemTemplate>
                        <HeaderTemplate><ol class="q-list"></HeaderTemplate>
                        <FooterTemplate></ol></FooterTemplate>
                      </asp:Repeater>
                    </div>
                  </div>
                </article>
              </ItemTemplate>
            </asp:Repeater>
          </section>

        </ContentTemplate>
      </asp:UpdatePanel>

      <!-- Auto refresh -->
      <asp:Timer ID="tmrRefresh" runat="server" Interval="10000" OnTick="tmrRefresh_Tick" />
    </main>
  </form>
</body>
</html>
