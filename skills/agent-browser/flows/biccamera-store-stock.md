# Bic Camera: price and store stock

**Description**: reports one product's price, points, stock, and display unit at chosen Bic Camera (ビックカメラ) stores. Use for price, stock, inventory, 在庫, or 庫存 checks at Bic Camera stores.

**Inputs**: `GOODS_NO`, the number from a `biccamera.com/bc/item/<GOODS_NO>/` URL; `STORES`, a grep regex of store names (default `川崎|有楽町`).

**Steps**

1. `curl -s -m 3 http://127.0.0.1:9333/json/version`
   Expect: JSON containing `"Browser"`. Otherwise start the shared Chrome as the skill says, then repeat this step once.
2. `agent-browser --session biccamera-store-stock --cdp 9333 --pin-tab batch --bail "tab new https://www.biccamera.com/bc/item/<GOODS_NO>/" "wait --text 円相当"`
   Expect: output ends with `円相当`, with no `✗`.
3. `agent-browser --session biccamera-store-stock eval '(()=>{const t=document.body.innerText;return [document.querySelector("h1").textContent.trim(),t.match(/([0-9,]+円) （税込）/)[1],t.match(/([0-9,]+ポイント)[^\n]*円相当/)[1]].join(" | ")})()' | python3 -I -c 'import json,sys;print(json.load(sys.stdin))'`
   Expect: one line `product name | price円 | pointsポイント`.
4. `agent-browser --session biccamera-store-stock batch --bail "open https://www.biccamera.com/bc/tenpo/SfrBcToriokiList.jsp?GOODS_NO=<GOODS_NO>" "wait --fn \"document.querySelectorAll('#jpShopList li').length>10\""`
   Expect: output ends with `true`, with no `✗`.
5. `agent-browser --session biccamera-store-stock eval '[...new Set([...document.querySelectorAll("#jpShopList li")].map(l=>["Store","Stock","Display","Liedtime"].map(k=>l.querySelector(".bcs_KST_"+k).textContent.replace(/\s+/g," ").trim()).join(" | ")))].join("\n")' | python3 -I -c 'import json,sys;print(json.load(sys.stdin))' | grep -E '<STORES>'`
   Expect: one line per matching store: `store | stock | display (○ or －) | ready time`.
6. `agent-browser --session biccamera-store-stock close`

**Output**: the product name, price, and points from step 3, then a table `Store | Stock | Display | Ready` from step 5. The stock page shows no per-store price; say the price is the web price. Translate stock: `在庫あり` in stock, `在庫残少` low stock, `お取り寄せ` order only. Add both URLs.

**Tested**: 2026-10-22, agent-browser 0.38.2.
