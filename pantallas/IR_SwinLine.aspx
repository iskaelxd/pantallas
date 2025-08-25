<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="IR_SwinLine.aspx.cs" Inherits="MES.IR_SwinLine" %>
<!DOCTYPE html>
<html lang="es">
<head runat="server">
  <meta charset="utf-8" />
  <title>Estación IR – Swinline / Kiteo (43")</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    :root{
      --bg:#0b1220; --bg2:#0c1426; --panel:rgba(19,27,45,.92); --border:#2b3b5f; --text:#fff;
      --muted:#c8d6f8; --green:#22c55e; --yellow:#eab308; --red:#ef4444; --blue:#3b82f6;
    }
    *{box-sizing:border-box} html,body{height:100%}
    body{margin:0;background:linear-gradient(180deg,var(--bg),var(--bg2));color:var(--text);
         font-family:ui-sans-serif,system-ui,Segoe UI,Roboto,Arial,sans-serif;
         -webkit-font-smoothing:antialiased;text-rendering:optimizeLegibility}
    header{padding:16px 18px; display:flex; align-items:center; justify-content:space-between; gap:16px; flex-wrap:wrap}
    .title{font-weight:900; letter-spacing:.04em; font-size:clamp(28px,4vw,56px)}
    .pill{background:#0f1a34; border:1px solid var(--border); padding:6px 12px; border-radius:999px; color:#fff; font-weight:800; letter-spacing:.12em; text-transform:uppercase}
    .grid{
      display:grid; gap:14px; padding:12px 16px 18px;
      grid-template-columns: 1.1fr 1.4fr 1.4fr;
      grid-template-areas: "e0 sw kt";
      height:calc(100vh - 92px);
    }
    .col{background:var(--panel); border:1px solid var(--border); border-radius:16px; display:flex; flex-direction:column; overflow:hidden; min-width:0}
    .col h2{margin:0; padding:12px 14px; font-size:clamp(18px,2.6vw,34px); letter-spacing:.08em; text-transform:uppercase; border-bottom:1px solid var(--border)}
    .col .body{padding:14px; display:flex; flex-direction:column; gap:12px; min-height:0}
    .col.e0{grid-area:e0}
    .col.sw{grid-area:sw}
    .col.kt{grid-area:kt}

    /* E0 (actual) */
    .current{
      font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,"Courier New",monospace;
      font-weight:900; letter-spacing:.16em; line-height:1.05;
      font-size:clamp(28px,4.2vw,72px);
      white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
      text-shadow:0 0 14px rgba(99,102,241,.35);
    }
    .current.green{color:var(--green); text-shadow:0 0 14px rgba(34,197,94,.55)}
    .current.red{color:var(--red); text-shadow:0 0 14px rgba(239,68,68,.55)}
    .loader{width:64px;height:64px;border-radius:50%;border:8px solid rgba(255,255,255,.15);border-top-color:#fff;animation:spin 1s linear infinite;margin:16px auto}
    @keyframes spin{to{transform:rotate(360deg)}}

    /* Listas Swinline/Kiteo */
    .cards{display:grid; grid-template-columns:1fr; gap:10px; align-content:flex-start}
    .card{
      display:flex; align-items:center; justify-content:center; min-height:72px;
      border:1px solid var(--border); border-radius:12px; padding:10px 12px; font-weight:900;
      font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,"Courier New",monospace;
      letter-spacing:.06em; font-size:clamp(18px,2.4vw,40px);
      white-space:nowrap; overflow:hidden; text-overflow:ellipsis;
      background:rgba(255,255,255,.04);
    }
    .card.delivered{background:rgba(34,197,94,.22); border-left:8px solid var(--green)}
    .card.kiteo{background:rgba(59,130,246,.18); border-left:8px solid var(--blue)}

    /* Ghost timers para lugares vacíos en Swinline */
    .ghost{position:relative; display:flex; flex-direction:column; gap:6px; align-items:center; justify-content:center;
           min-height:82px; border:1px dashed var(--border); border-radius:12px; background:#ffffff; color:#0b1220}
    .ghost .timer{font-weight:900; font-size:clamp(18px,2.2vw,36px); letter-spacing:.08em}
    .ghost .label{font-size:clamp(12px,1.6vw,18px); color:#374151}
    .ghost.green{box-shadow:inset 0 0 0 9999px rgba(34,197,94,.14)}
    .ghost.yellow{box-shadow:inset 0 0 0 9999px rgba(234,179,8,.22)}
    .ghost.red{box-shadow:inset 0 0 0 9999px rgba(239,68,68,.22)}

    /* Responsive (43" y también notebooks) */
    @media (max-width: 1400px){
      .grid{grid-template-columns: 1fr 1fr; grid-template-areas:"e0 sw" "kt kt";}
      .col.kt .cards{grid-template-columns: repeat(2, 1fr);}
    }
    @media (max-width: 900px){
      .grid{grid-template-columns: 1fr; grid-template-areas:"e0" "sw" "kt";}
      .col.sw .cards,.col.kt .cards{grid-template-columns: 1fr}
      .current{font-size:clamp(26px,8vw,54px)}
    }

    /* === Cards más grandes (Swinline / Kiteo) === */
.cards{ gap:14px; }

/* Celdas de serie */
.card{
  min-height:110px;              /* antes ~72px */
  padding:16px 18px;             /* más aire */
  font-size:clamp(24px,3.2vw,56px);  /* antes clamp(18px,2.4vw,40px) */
  border-radius:14px;
}
.card.delivered,
.card.kiteo{
  border-left-width:10px;        /* acento más notorio */
}

/* Lugares vacíos con timer (ghost) */
.ghost{
  min-height:120px;              /* antes ~82px */
  border-radius:14px;
}
.ghost .timer{
  font-size:clamp(22px,3vw,48px); /* más legible */
}
.ghost .label{
  font-size:clamp(14px,2vw,22px);
}



  </style>
</head>
<body>
  <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <header>
      <div class="title">Estación <asp:Label ID="lblLinea" runat="server" Text="IR" /></div>
      <span class="pill">Vista: Swinline &amp; Kiteo</span>
    </header>

    <div class="grid">
      <!-- Col 1: E0 -->
      <section class="col e0">
        <h2>E0 (Estación 0)</h2>
        <div class="body">
          <asp:Panel ID="pnlActual" runat="server" Visible="false">
            <div id="divCurrent" runat="server" class="current">—</div>
          </asp:Panel>
          <asp:Panel ID="pnlLoading" runat="server" Visible="false">
            <div class="loader"></div>
          </asp:Panel>
        </div>
      </section>

      <!-- Col 2: Swinline -->
      <section class="col sw">
        <h2>Swinline (Kit entregado)</h2>
        <div class="body">
          <div class="cards">
            <!-- 1) Entregados -->
            <asp:Repeater ID="rptSwDelivered" runat="server">
              <ItemTemplate>
                <div class="card delivered" title='<%# Eval("Numero_Serie") %>'>
                  <%# Eval("Numero_Serie") %>
                </div>
              </ItemTemplate>
            </asp:Repeater>
            <!-- 2) Ghost timers (lugares vacíos) -->
            <asp:Repeater ID="rptSwGhosts" runat="server">
              <ItemTemplate>
                <div class="ghost" data-slot-key='<%# Eval("Key") %>'>
                  <div class="timer">00:00</div>
                  <div class="label">Esperando kit</div>
                </div>
              </ItemTemplate>
            </asp:Repeater>
          </div>
        </div>
      </section>

      <!-- Col 3: Kiteo -->
      <section class="col kt">
        <h2>Kiteo</h2>
        <div class="body">
          <div class="cards">
            <asp:Repeater ID="rptKiteo" runat="server">
              <ItemTemplate>
                <div class="card kiteo" title='<%# Eval("Numero_Serie") %>'>
                  <%# Eval("Numero_Serie") %>
                </div>
              </ItemTemplate>
            </asp:Repeater>
          </div>
        </div>
      </section>
    </div>

    <!-- Auto refresh -->
    <asp:UpdatePanel ID="updMain" runat="server" UpdateMode="Conditional">
      <ContentTemplate>
        <asp:HiddenField ID="hfTackSeconds" runat="server" />
      </ContentTemplate>
    </asp:UpdatePanel>
    <asp:Timer ID="tmrRefresh" runat="server" Interval="8000" OnTick="tmrRefresh_Tick" />

    <!-- JS Timers: persisten con localStorage y se reinician al llenarse -->
    <script>
      (function(){
        const prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_endRequest(initTimers);
        window.addEventListener('DOMContentLoaded', initTimers);

        function initTimers(){
          const tack = parseInt(document.getElementById('<%=hfTackSeconds.ClientID%>').value || '600', 10);
          const greenMax = Math.floor(tack * 0.80);
          const yellowMax = Math.floor(tack * 0.95);

          // Depurar keys que ya no existen en DOM
          const domKeys = new Set(Array.from(document.querySelectorAll('.ghost[data-slot-key]')).map(el => el.dataset.slotKey));
          Object.keys(localStorage).forEach(k => {
            if (k.startsWith('timer:')) {
              const key = k.slice(6);
              if (!domKeys.has(key)) localStorage.removeItem(k);
            }
          });

          document.querySelectorAll('.ghost[data-slot-key]').forEach((el) => {
            const key = 'timer:' + el.dataset.slotKey;
            let start = parseInt(localStorage.getItem(key) || '0', 10);
            if (!start){ start = Date.now(); localStorage.setItem(key, String(start)); }

            const tEl = el.querySelector('.timer');
            function tick(){
              const elapsedSec = Math.floor((Date.now() - start) / 1000);
              const m = Math.floor(elapsedSec / 60);
              const s = elapsedSec % 60;
              tEl.textContent = String(m).padStart(2,'0') + ':' + String(s).padStart(2,'0');
              el.classList.remove('green','yellow','red');
              if (elapsedSec < greenMax) el.classList.add('green');
              else if (elapsedSec <= yellowMax) el.classList.add('yellow');
              else el.classList.add('red');
            }
            tick();
            // Cada tarjeta lleva su propio intervalo
            const intId = setInterval(tick, 1000);
            // Limpia si el elemento se elimina (postback rápido)
            const obs = new MutationObserver(()=> {
              if (!document.body.contains(el)) { clearInterval(intId); obs.disconnect(); }
            });
            obs.observe(document.body, {childList:true, subtree:true});
          });
        }
      })();
    </script>
  </form>
</body>
</html>
