# Briefing: public primary sources

Verified on 2026-09-05. This feature curates public publisher headlines; it does not claim confidential access, investment intelligence, or AI-generated article summaries.

| Source | Publisher evidence | Feed and live verification |
| --- | --- | --- |
| GitHub Blog | [The official GitHub Blog](https://github.blog/) publishes `<link rel="alternate" type="application/rss+xml" href="https://github.blog/feed/">`. | [RSS feed](https://github.blog/feed/): HTTP 200, 624,342 bytes, RSS 2.0. |
| Swift.org | [Official Swift Blog](https://www.swift.org/blog/) publishes an Atom alternate link and “Subscribe to Site Updates” link to `/atom.xml`. | [Atom feed](https://www.swift.org/atom.xml): HTTP 200, 683,990 bytes, Atom. |
| NASA | [NASA RSS feeds](https://www.nasa.gov/rss-feeds/) lists its “Recently Published Content” feed and provides an RSS alternate link. | [RSS feed](https://www.nasa.gov/feed/): HTTP 200, 227,401 bytes, RSS 2.0. |

Response sizes are observations at verification time, not fixed specifications. JPL's separate feed returned HTTP 403 in this environment; NASA's official site-wide feed is used instead.

## Behavior

- Latest and Unread show at most 20 matching articles, sorted by source publication date (Atom update date when publication is absent). Each source has up to 20 cached articles. Select All sources, GitHub Blog, Swift.org, or NASA.
- Headlines retain the publisher's original language. Dates are labeled Published or Updated according to the feed field; fetched timestamps are displayed separately per source.
- Topic labels are deterministic title-token/source rules. Security words take precedence, then AI words, then source-specific themes. They are disclosed as classification, never presented as generated summaries, hidden knowledge, or popularity rankings.
- Search matches only loaded headlines, source names and topic labels locally. No search text or reading state is submitted to any service.
- Bookmarks retain article metadata independently of feed rotation, up to 100 items. The Saved shelf displays every matching saved article; a full shelf asks the user to remove one instead of silently evicting it.
- The most recent 256 read states persist locally. Opening an original marks it read only if macOS accepts the browser-open request; read/unread can be toggled manually.
- Preferences use `briefing.library.v1` in the app's UserDefaults domain. Feed snapshots live in `Application Support/Notch Calendar/Briefing/{github,swift,nasa}.json`.
- Cached headlines are immediately usable. Caches are fresh for 30 minutes; stale headlines stay available while a foreground refresh runs. Partial errors preserve successful feeds and existing cached content, with source names and retry guidance.
- Page entry checks the cache; the Refresh button bypasses freshness. There is no timer, background polling, pagination loop, full-article scraping or remote image loading. SwiftUI owns the refresh task and cancels it when the page disappears.

## Limits and validation

- Three concurrent source requests at most. Existing ephemeral `RadarURLSessionTransport` supplies an 8-second URLSession request/resource timeout; each feed also has a 12-second structured task deadline.
- A feed response is limited to 1 MiB, XML nesting to 48 levels and parsed entries to 100. Only headline metadata is retained, with at most 20 accepted articles per feed.
- Only UTF-8 feeds without NUL are accepted. Actual XML DTD and ENTITY declarations are rejected before parsing; external entity resolution is disabled. Inert text inside CDATA, comments or processing instructions is skipped by a linear scan. GitHub's RSS legitimately embeds HTML DOCTYPE text inside `content:encoded` CDATA; this is never rendered or interpreted as a declaration.
- Malformed feeds, HTTP failures, oversized responses, invalid dates, blank/oversized titles, unsafe links, duplicates and dates more than one day ahead of fetch time are rejected or skipped as appropriate.
- Original links must be HTTP(S), have a host and contain no credentials or embedded control characters. URL fragments are removed for stable duplicate detection. Titles are plain text; article HTML is never rendered.
- Disk snapshots are atomically written and capped at 256 KiB per source. Corrupt, mismatched-source, duplicate and future-dated snapshots are ignored. An invalid local library recovers to an empty library without affecting the feeds.

## Integration and verification

The shell can use `BriefingWorkspaceView()` directly. For native view rendering or injected data, initialize `BriefingStore(...)`, await `load()`, optionally set `selectedSource`, `filter` or `search`, then pass `BriefingWorkspaceView(store: store)`. `toggleSaved(article)` and `markRead(article)` create real local shelf/reading state.

`Tests/NotchCalendarTests/BriefingTests.swift` covers RSS/Atom parsing, source dates, CDATA/entities, safe links, invalid/future dates, duplicate sorting, size/depth limits, HTTP errors, deadlines/cancellation, stale/corrupt/future/mismatched disk cache, partial offline loads, fresh-cache reuse, forced refresh, local search, bookmark/read persistence, shelf capacity and topic rules. The root task runs the shared build and test suite to avoid concurrent build-directory contention.

On 2026-09-05, the opt-in production-client check passed for all three sources: GitHub 10 articles, Swift.org 20 and NASA 10. All 14 Briefing tests passed with `DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer NOTCH_LIVE_BRIEFING=1 swift test --filter BriefingTests`. Without that environment flag, the live check is skipped so ordinary tests remain deterministic and offline. The GitHub-specific regression accepts inert HTML DOCTYPE text inside RSS CDATA while continuing to reject actual DTD/ENTITY declarations outside it.
