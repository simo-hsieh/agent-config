# Yodobashi: price and store stock

**Description**: reports one product's price, stock, and display unit at chosen Yodobashi (ヨドバシ) stores. Use for price, stock, inventory, 在庫, or 庫存 checks at Yodobashi stores.

**Inputs**: `ID`, the 18-digit product number from a `yodobashi.com/product/<ID>/` or `/ec/product/stock/<ID>/` URL; `STORES`, a grep regex of store names (default `川崎|横浜`).

**Steps**

1. `curl -s -m 3 http://127.0.0.1:9333/json/version`
   Expect: JSON containing `"Browser"`. Otherwise start the shared Chrome as the skill says, then repeat this step once.
2. `agent-browser --session yodobashi-store-stock --cdp 9333 --pin-tab batch --bail "tab new https://www.yodobashi.com/ec/product/stock/<ID>/" "wait --text 川崎ルフロン"`
   Expect: output ends with `川崎ルフロン`, with no `✗`.
3. `agent-browser --session yodobashi-store-stock get title`
   Expect: starts with `ヨドバシ.com - 店舗在庫情報 - `; the rest is the product name.
4. `agent-browser --session yodobashi-store-stock eval '[...document.querySelectorAll("tr")].map(r=>[...r.cells].map(c=>c.innerText.replace(/\s+/g," ").trim())).filter(c=>c.length==5&&/ヨドバシカメラ|石井/.test(c[0])).map(c=>[c[0].replace(/ 0\d.*$/,""),c[1].replace(/（.*$/,""),c[2]||"-",c[3],c[4]].join(" | ")).join("\n")' | python3 -I -c 'import json,sys;print(json.load(sys.stdin))' | grep -E '<STORES>'`
   Expect: one line per matching store: `store | ￥price | display (あり or -) | stock | ready time`.
5. `agent-browser --session yodobashi-store-stock close`

**Output**: the product name, then a table `Store | Price | Stock | Display | Ready` from step 4. Translate stock: `在庫あり` in stock, `在庫残少` low stock, `お取り寄せ` order only. Prices differ by store; say so when the lines disagree. Add the stock page URL.

**Tested**: 2026-10-22, agent-browser 0.38.2.
