# Kakalove Cafe: newest beans

**Description**: lists the newest products on kakalovecafe.com.tw, newest first. Use for new or latest coffee beans (新豆, 咖啡豆) at Kakalove Cafe.

**Inputs**: `N`, how many single-origin or blend beans to report (default 10).

**Steps**

1. `curl -s -m 3 http://127.0.0.1:9333/json/version`
   Expect: JSON containing `"Browser"`. Otherwise start the shared Chrome as the skill says, then repeat this step once.
2. `agent-browser --session kakalove-new-beans --cdp 9333 --pin-tab batch --bail "tab new https://www.kakalovecafe.com.tw/products?sort_by=created_at&order_by=desc" "wait --text Newest"`
   Expect: output ends with `Newest`, with no `✗`.
3. `agent-browser --session kakalove-new-beans snapshot -i -c | grep 'NT\$' | sed -E 's/^- link "//; s/" \[ref=[^]]*\]$//'`
   Expect: at least 5 lines, each ending in one or two `NT$` prices. Each name appears twice; keep one copy.
4. `agent-browser --session kakalove-new-beans close`

**Output**: a table `# | Bean | Price` with the first `N` lines from step 3, in page order. Mark lines containing `Sold Out`. List bundles (names containing `total` and `oz`) separately below the table. Add a final line with the page URL.

**Tested**: 2026-10-09, agent-browser 0.38.2.
