# 🍼 Mila — Guida all'installazione

Mila diventa una vera app installabile, con database condiviso e sincronizzazione
in tempo reale tra te e tua moglie. Segui i 4 passi. Si fa meglio da computer, ma
è fattibile anche da telefono. Tempo: ~15 minuti.

I file:
- `index.html` — l'app
- `manifest.webmanifest`, `sw.js`, le icone `.png` — per l'installazione come app
- `supabase-schema.sql` — da incollare in Supabase
- `LEGGIMI.md` — questa guida

---

## 1) Supabase — il database condiviso (gratis)

1. Vai su **https://supabase.com** → **Start your project** → accedi (anche con GitHub).
2. **New project**: dai un nome (es. *mila*), scegli una password del database e la
   regione più vicina (Europe). Attendi ~2 minuti che sia pronto.
3. Menu a sinistra → **SQL Editor** → **New query**. Apri il file
   `supabase-schema.sql`, copia **tutto**, incollalo e premi **Run**.
   Deve comparire *Success*.
4. **Disattiva la conferma via email** (così l'accesso è immediato):
   menu **Authentication** → **Sign In / Providers** (o *Providers*) → **Email** →
   spegni **Confirm email** → **Save**.
5. Prendi le due chiavi: **Project Settings** (l'ingranaggio) → **API Keys**
   (o **API**). Ti servono:
   - **Project URL** — es. `https://abcd1234.supabase.co`
   - **anon public** — una lunga stringa (è pubblica, va bene metterla nell'app)

6. Apri `index.html` con un editor di testo, in cima allo `<script>` trovi:
   ```js
   const CONFIG = {
     url:     "INCOLLA_QUI_IL_PROJECT_URL",
     anonKey: "INCOLLA_QUI_LA_CHIAVE_ANON_PUBLIC"
   };
   ```
   Sostituisci i due valori con i tuoi, tra virgolette. Salva.

---

## 2) GitHub — dove vivono i file (gratis)

1. Vai su **https://github.com** → accedi/registrati → **New repository**.
2. Nome: `mila` → **Private** → **Create repository**.
3. **Add file → Upload files** → trascina **tutti** i file della cartella
   (index.html, manifest.webmanifest, sw.js, le icone .png, ecc.) → **Commit changes**.

> Da telefono: il sito GitHub funziona dal browser, l'upload dei file è supportato.

---

## 3) Vercel — pubblica il sito con un link (gratis)

1. Vai su **https://vercel.com** → **Sign up** → **Continue with GitHub**.
2. **Add New… → Project** → scegli il repository `mila` → **Import**.
3. **Framework Preset:** lascia **Other** (nessuna configurazione, è un sito statico).
   Non serve toccare Build/Output. → **Deploy**.
4. Dopo ~1 minuto ottieni un link tipo **https://mila-xxxx.vercel.app**.
   Questo è l'indirizzo della vostra app. 🎉

> Ogni volta che aggiorni un file su GitHub, Vercel ripubblica da solo.

---

## 4) Metti l'icona sul telefono + primo accesso

Aprite il link Vercel su **entrambi** i telefoni:

- **iPhone (Safari):** icona **Condividi** → **Aggiungi a Home** → *Aggiungi*.
- **Android (Chrome):** menu **⋮** → **Aggiungi a schermata Home** / *Installa app*.

Comparirà l'icona **Mila** che apre l'app a tutto schermo.

**Primo accesso:**
1. **Tu**: apri Mila → scheda **Crea** → nome, email, password → *Crea la famiglia*.
   In **Impostazioni** trovi il **codice famiglia** (6 caratteri).
2. **Tua moglie**: apre Mila → scheda **Unisciti** → nome, email, password +
   il **codice famiglia** che le hai dato → *Unisciti*.

Da quel momento vedete e modificate le stesse spese, in tempo reale. ✨

---

## Come si usa (veloce)
- **+** al centro: aggiungi una spesa (importo, categoria, chi ha pagato, come si divide, data).
- **Assegno INPS** nella schermata Casa: imposta l'importo del mese (o predefinito in Impostazioni).
- Il **salvadanaio** mostra quanto resta; **Andamento** i grafici; **Spese** l'elenco filtrabile.

## Divisione 50/50 e conti tra voi due
- Ogni spesa si divide **50/50** in automatico. Per i casi particolari puoi scegliere
  **"tutta a mamma"** o **"tutta a papà"** (es. un regalo personale).
- Nella schermata **Casa**, la scheda **"Conti tra di voi"** mostra sempre
  **chi ha anticipato quanto** e **chi deve quanto all'altro**.
- Quando vi pareggiate (uno dà i soldi all'altro), aprite quella scheda e toccate
  **"Segna come saldato"**: il conto torna a zero e resta lo storico dei saldi.
- Nota: l'**assegno INPS** è conteggiato a parte per il budget del mese e **non**
  entra nel saldo personale tra voi due.

## Costi
Tutto rientra nei piani **gratuiti** di Supabase, GitHub e Vercel: per una famiglia
non li supererete mai.

## Problemi comuni
- *"Manca la configurazione di Supabase"* → non hai incollato URL/anon key in `index.html`.
- *Signup non entra* → non hai disattivato **Confirm email** (passo 1.4).
- *Non si sincronizza tra i due telefoni* → controlla di aver usato lo **stesso codice
  famiglia**, e che il passo `alter publication supabase_realtime …` dello schema sia andato a buon fine.
