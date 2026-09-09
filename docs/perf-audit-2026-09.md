# Scroll performance audit — topic list and thread (2026-09-09)

Why: scrolling the topic list and a thread feels slow. This is what was
measured, what in the render path costs the time, and what to change —
code first, then the UI simplifications that would remove work outright.

## Measurement

Benchmark: `integration_test/scroll_perf_test.dart` in the ABDA repo,
run with `flutter drive --profile` on a Pixel 10a (120 Hz, 2.625 dpr)
against meta.discourse.org, read-only. Eight flings per screen, frame
timings from `SchedulerBinding.addTimingsCallback`.

| screen | frames | build p50 / p90 / p99 / max | raster p50 / p90 / p99 / max | frames over 16.7 ms | over 33 ms |
|---|---|---|---|---|---|
| topic list (Latest), run 1 | 1182 | 6.8 / 14.0 / 23.0 / 118 ms | 5.8 / 8.6 / 11.2 / 28 ms | 332 (28 %) | 16 |
| topic list (Latest), run 2 | 1183 | 6.9 / 14.9 / 24.1 / 89 ms | 6.0 / 9.1 / 11.7 / 26 ms | 366 (31 %) | 16 |
| thread, run 1 | 1005 | 0.8 / 2.5 / 27.5 / 89 ms | 4.4 / 5.5 / 6.6 / 13 ms | 19 | 10 |
| thread, run 2 | 965 | 0.8 / 2.3 / 30.2 / 83 ms | 4.6 / 5.7 / 7.7 / 10 ms | 20 | 11 |

After phase 1 (v1.0.7: cached cooked-content parse, no per-post
`setState` on scroll, avatar decode at display size with one fetch and SVG
sniffing, flat avatar placeholder, participant cluster removed):

| screen | frames | build p50 / p90 / p99 / max | raster p50 / p90 / p99 / max | frames over 16.7 ms | over 33 ms |
|---|---|---|---|---|---|
| topic list (Latest) | 1157 | 3.3 / 11.3 / 21.1 / 99 ms | 4.9 / 6.9 / 8.3 / 32 ms | 84 (7 %) | 8 |
| thread | 1039 | 0.8 / 1.7 / 13.1 / 51 ms | 3.5 / 4.8 / 6.9 / 17 ms | 12 | 3 |

Avatar pipeline in the same run: 129 cache-miss lookups (was 598), 0
decode failures (was 10), 0 file-to-network fallbacks (was 88).

Reading the baseline:

- **The topic list is build-bound and slow on every frame.** A median
  build of 6.8 ms on a 120 Hz device (8.3 ms budget) leaves nothing for
  raster; 28 % of frames miss 60 Hz. Raster is fine. This is the
  "quite slow" the user feels: it is not occasional hitches, it is the
  steady cost of building far too much widget tree per frame.
- **The thread is cheap most of the time with big hitches.** Median
  build under 1 ms, but the 99th percentile is 27 ms and the worst 89 ms:
  each time a new post comes into view its HTML is parsed (twice) on the
  UI thread. Ten frames over 33 ms in eight flings is a visible stutter
  per fling.
- **The avatar pipeline does far more than it should.** In run 2 the
  file-cache lookup in `ImageLoader.fetchImageFile` missed 598 times for
  114 distinct avatar URLs (one avatar 30 times — the non-lazy list
  builds every row's avatars at once, so the in-flight dedupe in
  `FCCacheManager` is all that stands between this and 598 fetches);
  10 decodes failed outright and 88 renders fell back from the file path
  to a second `CachedNetworkImage` load. Two of the cached files are
  SVG served under a `.png` URL (Discourse allows SVG avatars; the
  system user's is one), which no bitmap decoder accepts. See finding 4.

## Findings, ranked by expected impact

### Topic list

1. **Not virtualized.** `views/tabs/topic_list_tab.dart:490` is
   `ListView(children: […])` whose body is a `Column` of every loaded
   topic row (`:55-58`, `:501`). Every `setState` on the tab — each
   load-more fires two (`:244`, `:282`) — builds and lays out all rows
   and all their avatars. Same shape on the category page,
   `views/lists/forum_topic_list.dart:427`, which additionally does three
   `.where().toList()` passes over all topics inside `build()` (`:421`).
   *Fix:* `CustomScrollView` with `SliverToBoxAdapter` header and chips
   and a `SliverList.builder` for rows; partition pinned/regular once at
   load time.
2. **A hidden mirror of all five lists.** `topic_list_tab.dart:381-436`
   keeps an `IndexedStack` of the five filter lists at `Positioned(-10000)`
   inside `Opacity(0)`. `LatestTopicsList.build` and `UnreadTopicsList.build`
   still return a full `RefreshIndicator` + `ListView.builder`, so the
   Latest feed is built twice per frame. Hot/New/Top already return
   `SizedBox.shrink()`. *Fix:* same for Latest and Unread; use `Offstage`
   or move the loaders out of the widget tree.
3. **Per-row work that never changes.** `views/listitems/topic_list_item.dart`:
   `withEmojiShortcodes` on title and excerpt (`:245`, `:359`),
   `formatSmartDateTime` twice (`:93`, `:136`), a throwaway list to count
   flags (`:372`), two `Builder`s, `Material(clipBehavior: Clip.antiAlias)`
   per category/tag chip (`:287`, `:314` — a saveLayer per chip), two
   `Wrap`s. Up to seven `UserAvatar`s per row (`:71`, `:106-112`, `:125`).
   *Fix:* compute title/excerpt/dates once per topic (model or LRU keyed
   by id); plain `DecoratedBox` + `InkWell(borderRadius:)` for chips;
   `RepaintBoundary` per row.
4. **Avatars decode at full size, and twice.**
   `views/widgets/cached_redirect_image.dart:201-215` renders
   `Image(FileImage(...))` without the `cacheWidth`/`cacheHeight` that
   `user_avatar.dart:107` computed — a 240 px avatar decoded for a 40 px
   slot. `:128` schedules a post-frame `setState` before loading; `:194`,
   `:244`, `:275` nest three `FutureBuilder`s; `:210` fades with
   `AnimatedOpacity` (saveLayer per avatar for 500 ms). And per the
   benchmark log the file path fails and falls back to a second network
   fetch. *Fix:* `ResizeImage(FileImage(f), width:, height:)`; drop the
   post-frame hop; one future; fix or remove the SDK file-cache path for
   images (a plain `CachedNetworkImage` with `memCacheWidth` does all of
   this correctly). Sniff the bytes for `<svg`/`<?xml` and route those
   through `flutter_svg`, as `BrandImage` already does for logos.
5. **Placeholder shimmers with a ticker each.** `user_avatar.dart:5-64`
   `_ShimmerLoadingCircle` runs an `AnimationController` and rebuilds a
   gradient every frame, per avatar, until the image lands — seven per
   row across a non-lazy list. `topic_list_skeleton.dart:35` and the
   thread's loading cards use `Shimmer.fromColors` (ShaderMask saveLayer
   per frame). *Fix:* flat tinted circle / static grey blocks.
6. **Header at index 0.** `forum_header_widget.dart:230` `IntrinsicHeight`
   (double layout), `:252` `ColorFiltered` over a full-bleed image
   (saveLayer), `:62-70` `BoxShadow` + `ClipRRect`, all inside an `Obx`,
   re-laid-out on every tab `setState`. *Fix:* fixed height, pre-tinted
   asset, `RepaintBoundary`.
7. `utils/avatar_color_utils.dart` allocates a fresh colour map per
   avatar per build (`user_avatar.dart:96-105`). Memoize by username.

### Thread

1. **Post HTML parsed twice, in `build()`, uncached.**
   `views/listitems/post_list_item.dart:958` calls
   `_extractPostContentData()` → `utils/cooked_content.dart:68` (full
   `html` parse, six `querySelectorAll` sweeps, then `innerHtml`
   re-serialization) and hands the string to
   `views/widgets/rich_text_content.dart:56` `Html(...)`, which parses it
   again with flutter_html 3.0.0. `_foldAttachmentSize` (`:333`) runs a
   whole-string regex on top, compiled inline. *Fix:* parse once per
   post — in `initState`/`didUpdateWidget` (which already detects post
   changes at `:245`), or better at fetch time in
   `controllers/post_controller.dart:66` so the frame budget never sees
   it — and keep the built `RichTextContent` across rebuilds.
2. **Scrolling rebuilds the whole list.** `views/lists/posts_list.dart:1121-1134`
   wraps each post in a `VisibilityDetector` whose callback `setState`s
   `_currentVisiblePostIndex`, a value only the jump-to-post dialog reads.
   Every post that crosses 50 % visibility rebuilds `PostsList.build`
   (the `Obx` at `:1419`, the list, the poll card, the bottom bar) and
   every visible `PostListItem` — which re-parses HTML (finding 1).
   `:584-588` `_onScroll` also `setState`s `_isFirstPostVisible` from the
   positions listener. *Fix:* `ValueNotifier`s read only where needed;
   derive the current post from `itemPositions` instead of a
   `VisibilityDetector` per post; narrow the `Obx` to the list.
3. **Fresh handlers and closures per item per build.** `posts_list.dart:1117-1119`
   allocates `AvatarActions`, `ImageActions`, `PostActionsHandler` and
   `:1158-1170` a `PostActions` with ten closures for every item on every
   build, so `PostListItem` never receives an equal widget. *Fix:* build
   once in `initState`, share.
4. **Style tables rebuilt per post.** `rich_text_content.dart:87-182`
   and `:189-308` construct ~45 `Style`/`Margins`/`Border` objects and
   three extensions per post per build. They depend only on the theme.
   *Fix:* cache per `ColorScheme`.
5. **Element identity.** The only key is on the `VisibilityDetector`
   (`:1122`); the conditional `Column` wrappers at `:1178`, `:1199`,
   `:1478` are unkeyed, so a post that gains a time gap or the
   first/last decoration rebuilds from scratch. Move a `ValueKey(post.id)`
   to the outermost widget per index.
6. **Up to 30 inline preview cards per post** (`post_list_item.dart:873-891`),
   each fetching in `initState` and `setState`-ing on completion. Cap at
   one (web shows one onebox) and consult the preview caches
   synchronously on first build.
7. `AnimatedContainer` as the root of every post (`:966`) for a
   highlight only one post uses; `Opacity(0.5)` + 1 s `Timer.periodic`
   `setState` during like cooldown (`post_list_item_social.dart:115`,
   `post_list_item.dart:1594`); raw `Image.network` without decode size
   for custom-emoji reactions (`reaction_glyph.dart:93`); prefetch runway
   of three items with a page size of 20 (`posts_list.dart:560`, `:572`).
8. `ScrollablePositionedList` renders two sliver lists and cannot use
   `itemExtent`; it is only needed for jump-to-post. Keep it, but give
   rows a `RepaintBoundary` and stable keys; revisit if 1–5 are not
   enough.

## UI simplifications (remove work rather than optimize it)

1. Participant avatar cluster in the topic row: cap at three faces, or
   drop it. Removes five of seven network images per row.
2. Drop the last-poster mini avatar; keep "alice replied 3h ago".
3. Show at most two tag chips plus "+N"; no antialiased clip on chips.
4. Collapse the metadata row to replies / likes / views and one status
   icon, instead of two `Wrap`s of up to nine items.
5. Flat placeholders instead of shimmer (avatars, skeletons, loading
   cards).
6. Fixed-height header with a pre-tinted background asset.
7. One link/video/tweet preview per post, others behind a tap.
8. Plain `ColoredBox` for posts that are not highlighted.

## Order of work

- **Phase 1 (largest win, lowest risk):** cache the cooked-content parse
  per post and move it out of `build()`; delete the `VisibilityDetector`
  `setState`; pass decode size to the avatar `FileImage` path and stop
  the double download.
- **Phase 2 (structural):** virtualize `topic_list_tab.dart` and
  `forum_topic_list.dart`; make Latest/Unread `build()` return
  `SizedBox.shrink()` and swap the off-screen `Opacity(0)` holder for
  `Offstage`.
- **Phase 3 (hygiene):** hoist flutter_html styles and extensions; share
  handlers and `PostActions`; memoize avatar colours; drop shimmers;
  precompute titles and dates.

Re-run the benchmark after each phase; the numbers above are the
baseline.
