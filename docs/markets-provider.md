# Markets provider and data contract — v0.6.0

Verified against Alpha Vantage's official pages on 2026-09-05.

- [GLOBAL_QUOTE documentation](https://www.alphavantage.co/documentation/#latestprice): the default endpoint updates at the end of each trading day. This integration never requests `entitlement=realtime` or `entitlement=delayed`. A 15-minute **local cache** does not mean a 15-minute-delayed market feed.
- [Support and key registration](https://www.alphavantage.co/support/#api-key): the ordinary free allowance is 25 API requests per day. Each ticker is one request. No project exemption is assumed.
- [Provider terms](https://www.alphavantage.co/terms_of_service/): individual personal use is distinguished from commercial use. This optional feature requests a user's own key and displays their own observations locally. It is not a shared market-data service. Commercial distribution of market data requires an appropriate provider agreement.

## User workflow

Markets opens without requesting quotes. The initial watchlist is AAPL, MSFT and NVDA with no invented prices. Users can add ordinary 1–5 letter US symbols, remove them, and reorder them; at most eight symbols are saved. Exchange-suffixed tickers, indices, class-share punctuation, other markets and currency conversion are intentionally outside this release.

Users obtain a personal key from the linked provider page and save it in macOS Keychain. “Save and verify” retrieves only the first watchlist symbol and explicitly consumes one request. “Refresh quotes” fetches only symbols whose individual cache is missing or older than 15 minutes. Repeated clicks within the cache window do not consume requests. Removing the key disables requests; clearing the quote cache is a separate action.

The UI always names Alpha Vantage, labels quotes as end-of-day/non-realtime, shows the provider's trading date separately from local retrieval time, and marks expired caches. The daily-range marker derives only from the returned high, low and price; no synthetic chart history is generated.

## Stability and privacy

- Requests are serial with at least two seconds between starts, a 10-second request timeout, a 12-second overall deadline and a 64 KiB response cap. Redirects are rejected to avoid forwarding credential-bearing URLs. Ephemeral sessions use no cookies or URL cache and invalidate after each request.
- A persisted rolling 24-hour allowance caps this Mac at 25 attempts, including failures and cancellation. The provider can additionally enforce its own limits or shared-key usage elsewhere. Provider 429/limit messages halt the current batch. No automatic retries or background polling occur.
- Each successful quote is independently validated and persisted. Missing optional range/volume data is accepted; missing core fields, mismatched symbols, nonfinite values, impossible dates, invalid ranges and negative volume are rejected. A failed row retains its previous quote and shows a readable error. Cancellation invalidates the request generation so a late response cannot replace state.
- The key is stored as a nonsynchronizing, this-device-only Keychain item, never in preferences or log messages. Provider error text and underlying URL errors are not displayed verbatim. Watchlist, quote cache and quota timestamps are small local preference values. No analytics or remote aggregation was added.

## Verification scope

`MarketTests` uses deterministic HTTP and storage substitutes covering schema, malformed/partial/nonfinite responses, HTTP errors, rate limits, timeout/cancellation, symbol validation, watchlist persistence, fresh/stale/corrupt cache, partial refresh, serial request execution, rolling quota and key isolation. Tests do not contact the provider or require a real key. A real credential must be supplied by the user to verify their personal account entitlement; the application does not bundle a shared API key.
