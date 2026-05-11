# frozen_string_literal: true

# Seed a Discourse instance with demo data that exercises every
# Phase 5 feature the discourseapp client uses.
#
# Run with:
#   cd /Volumes/CRUCIAL/discourse
#   bin/rails runner /Volumes/CRUCIAL/byo/discourseapp/scripts/seed_discourse_demo.rb
#
# The script is idempotent-ish — it skips records that already exist by
# username / topic title / tag name. Re-run it freely.
#
# Features covered, in the order they appear:
#   * Tags                            (Phase 5.0 / 5.1)
#   * Solved indicator                (Phase 5.2)             — requires discourse-solved plugin
#   * Bookmarks                       (Phase 5.3.1bc / 5.3.2)
#   * Trust levels                    (Phase 5.3.1a)
#   * Server-side drafts              (Phase 5.3.3)
#   * Polls                           (Phase 5.3.4)
#   * Notification levels             (Phase 5.4)
#   * Suggested topics                (Phase 5.5a)            — automatic; needs ≥4 topics in a category
#   * Search filters                  (Phase 5.6)             — exercised by the variety of topic states
#   * User badges                     (Phase 5.7)
#   * Follow/unfollow                 (Phase 5.8)
#   * Moderator actions               (Phase 5.9)             — archived/unlisted/closed/pinned topics
#
# Anything missing (e.g. discourse-solved not installed) is reported but
# doesn't abort the script.

require 'securerandom'

puts "\n=== discourseapp demo seed ===\n"

# ----------------------------------------------------------------------
# Helpers
# ----------------------------------------------------------------------

def emoji_password
  # Stable per-username so the same user can be reused across runs.
  'demo-password-1234!'
end

def find_or_create_user(username:, email:, name: nil, trust_level: 1,
                       admin: false, moderator: false)
  existing = User.find_by(username_lower: username.downcase)
  if existing
    changed = false
    if existing.trust_level != trust_level
      existing.trust_level = trust_level
      changed = true
    end
    if admin && !existing.admin?
      existing.admin = true
      changed = true
    end
    if moderator && !existing.moderator?
      existing.moderator = true
      changed = true
    end
    existing.save! if changed
    return existing
  end

  user = User.new(
    username: username,
    email: email,
    name: name || username.capitalize,
    password: emoji_password,
    active: true,
    approved: true,
    trust_level: trust_level,
    admin: admin,
    moderator: moderator
  )
  user.skip_email_validation = true
  user.save!
  user.activate
  user.email_tokens.update_all(confirmed: true)
  puts "  + user @#{username} (TL#{trust_level}#{admin ? ', admin' : ''}#{moderator ? ', mod' : ''})"
  user
end

def find_or_create_category(name:, color: 'BF1E2E', text_color: 'FFFFFF',
                            description: nil)
  cat = Category.find_by(name: name)
  return cat if cat

  cat = Category.create!(
    name: name,
    user: Discourse.system_user,
    color: color,
    text_color: text_color,
    description: description || "Demo category: #{name}"
  )
  puts "  + category ##{cat.slug}"
  cat
end

def find_or_create_tag(name)
  Tag.find_or_create_by!(name: name).tap do |t|
    puts "  + tag :#{t.name}" if t.previously_new_record?
  end
end

def create_topic_with_posts(title:, category:, user:, body:, tags: [],
                            replies: [])
  existing = Topic.where(title: title, category_id: category.id).first
  return existing if existing

  post = PostCreator.create!(
    user,
    title: title,
    category: category.id,
    raw: body,
    tags: tags.map(&:to_s),
    skip_validations: true,
    bypass_rate_limiter: true
  )
  topic = post.topic
  reply_failures = 0

  replies.each do |reply|
    creator = PostCreator.new(
      reply[:user] || user,
      topic_id: topic.id,
      raw: reply[:raw],
      skip_validations: true,
      bypass_rate_limiter: true
    )
    new_post = creator.create
    if new_post.nil? || creator.errors.any?
      reply_failures += 1
      puts "    ! reply by @#{(reply[:user] || user).username} failed: #{creator.errors.full_messages.join('; ')}"
    end
  end

  topic.reload
  suffix = reply_failures.positive? ? " (#{reply_failures} reply failures)" : ''
  puts "  + topic “#{title.truncate(50)}” (#{topic.posts_count} posts)#{suffix}"
  topic
end

def award_badge(user, badge_name)
  badge = Badge.find_by(name: badge_name)
  unless badge
    puts "  ! badge “#{badge_name}” not found"
    return
  end
  BadgeGranter.grant(badge, user) unless UserBadge.where(
    user_id: user.id, badge_id: badge.id
  ).exists?
end

# ----------------------------------------------------------------------
# 1. Users (trust-level spread, plus an admin + a moderator)
# ----------------------------------------------------------------------

puts "\n[1/9] Users…"

users = {
  alice: find_or_create_user(
    username: 'alice', email: 'alice@example.com', name: 'Alice TL3',
    trust_level: 3
  ),
  bob: find_or_create_user(
    username: 'bob', email: 'bob@example.com', name: 'Bob TL2',
    trust_level: 2
  ),
  carol: find_or_create_user(
    username: 'carol', email: 'carol@example.com', name: 'Carol TL1',
    trust_level: 1
  ),
  dave: find_or_create_user(
    username: 'dave', email: 'dave@example.com', name: 'Dave TL0',
    trust_level: 0
  ),
  eve: find_or_create_user(
    username: 'eve', email: 'eve@example.com', name: 'Eve TL4 Leader',
    trust_level: 4
  ),
  mallory: find_or_create_user(
    username: 'mallory', email: 'mallory@example.com',
    name: 'Mallory Moderator', trust_level: 4, moderator: true
  ),
  # Extra demo users to give chat + topic activity a wider cast.
  frank: find_or_create_user(
    username: 'frank', email: 'frank@example.com', name: 'Frank Iglesias',
    trust_level: 2
  ),
  grace: find_or_create_user(
    username: 'grace', email: 'grace@example.com', name: 'Grace Kim',
    trust_level: 1
  ),
  henry: find_or_create_user(
    username: 'henry', email: 'henry@example.com', name: 'Henry Aldecoa',
    trust_level: 2
  ),
  ivy: find_or_create_user(
    username: 'ivy', email: 'ivy@example.com', name: 'Ivy Brennan',
    trust_level: 3
  )
}

# ----------------------------------------------------------------------
# 2. Categories
# ----------------------------------------------------------------------

puts "\n[2/9] Categories…"

cat_general = find_or_create_category(
  name: 'General Discussion', color: '0088CC',
  description: 'Anything goes — chat, intros, off-topic.'
)
cat_support = find_or_create_category(
  name: 'Support & Q&A', color: 'BF1E2E',
  description: 'Ask questions, get answers. Mark the answer as the solution.'
)
cat_announcements = find_or_create_category(
  name: 'Announcements', color: '25AAE2',
  description: 'Official announcements. Read-only for most users.'
)

# ----------------------------------------------------------------------
# 3. Tags (Phase 5.0 / 5.1)
# ----------------------------------------------------------------------

puts "\n[3/9] Tags…"

%w[flutter dart mobile ios android macos
   beginner advanced howto bug-report
   feature-request feedback meta].each { |name| find_or_create_tag(name) }

# ----------------------------------------------------------------------
# 4. Topics — variety pack
# ----------------------------------------------------------------------

puts "\n[4/9] Topics & posts…"

# A multi-tag support topic that we'll mark solved later.
topic_solved = create_topic_with_posts(
  title: 'How do I use the new bookmark feature on mobile?',
  category: cat_support,
  user: users[:carol],
  tags: %w[mobile beginner howto],
  body: <<~MARKDOWN,
    I just installed the latest mobile app and I see a bookmark icon
    next to every post. How does it work? Does it sync with my web
    bookmarks?

    Also — is there a separate Bookmarks tab somewhere? I have a few
    posts I want to save for reference.
  MARKDOWN
  replies: [
    {
      user: users[:alice],
      raw: <<~MD
        Yes, it syncs! Tapping the bookmark icon on a post calls
        `POST /bookmarks.json` server-side, so the same bookmarks
        show up on the web composer too.

        The Bookmarks list is reachable from your **own profile** —
        scroll to the action row, there's a "Bookmarks" button next to
        Send Message.
      MD
    },
    {
      user: users[:eve],
      raw: 'Confirming Alice — it works on iOS and Android equally well.'
    }
  ]
)

# Another support topic, untagged, will stay unsolved.
topic_unsolved = create_topic_with_posts(
  title: 'Mobile app crashes when I open a topic with a poll',
  category: cat_support,
  user: users[:dave],
  tags: %w[bug-report mobile ios],
  body: <<~MARKDOWN,
    Steps to reproduce:

    1. Open the app on iOS.
    2. Tap any topic that contains an embedded poll.
    3. Crash.

    Anyone else seeing this?
  MARKDOWN
  replies: [
    {
      user: users[:bob],
      raw: "I can't reproduce on iOS 17. What device + OS are you on?"
    }
  ]
)

# A meta/feedback topic with a poll attached.
topic_with_poll = create_topic_with_posts(
  title: 'Which feature should we prioritize next?',
  category: cat_general,
  user: users[:eve],
  tags: %w[feature-request feedback meta],
  body: <<~MARKDOWN
    Help us pick what to ship next on mobile. Vote below — multi-choice,
    pick up to two.

    [poll type=multiple results=always max=2 chartType=bar]
    * Markdown preview in the composer
    * Push notifications via FCM/APNs
    * Group pages
    * Activity feed on profile
    * Discourse Chat support
    [/poll]
  MARKDOWN
)

# An "unanswered" topic in support (good for status:noreplies search).
create_topic_with_posts(
  title: 'Anyone tried the new server-side drafts feature?',
  category: cat_support,
  user: users[:carol],
  tags: %w[mobile feedback],
  body: <<~MARKDOWN
    The drafts seem to round-trip between the mobile app and the web
    composer now. Curious if anyone else has tested this end-to-end.
  MARKDOWN
)

# A general-discussion topic with a long-ish thread for suggested topics
# and pagination testing.
topic_chatty = create_topic_with_posts(
  title: 'What are you building this month?',
  category: cat_general,
  user: users[:alice],
  tags: %w[meta],
  body: 'Drop a one-liner about what you’re working on.',
  replies: 8.times.map do |i|
    {
      user: [users[:alice], users[:bob], users[:carol], users[:eve]].sample,
      raw: case i
           when 0 then 'A side project — Discourse client in Flutter. Going well!'
           when 1 then 'Migrating our team forum to Discourse 3.x.'
           when 2 then 'A bot that summarises long topics. Early days.'
           when 3 then 'Trying to learn dart_mappable. Codegen is wild.'
           when 4 then 'Nothing this month, just lurking 👀'
           when 5 then 'A mobile theme component, badge-heavy.'
           when 6 then 'Documenting our internal style guide.'
           else        'Refactoring legacy BBCode → Markdown.'
           end
    }
  end
)

# A topic in Announcements that we'll pin globally.
topic_announce = create_topic_with_posts(
  title: 'Welcome to the demo forum',
  category: cat_announcements,
  user: users[:mallory],
  tags: %w[meta],
  body: <<~MARKDOWN
    This forum is pre-seeded with demo data for the discourseapp mobile
    client. Have a look around — every topic and user here is fake.

    The mobile app uses the standard Discourse REST API + User API
    Keys, so anything you can do on the web works on mobile too.
  MARKDOWN
)

# A topic we'll close + archive to exercise moderator UI.
topic_archived = create_topic_with_posts(
  title: 'Old thread — closed for historical reference',
  category: cat_general,
  user: users[:bob],
  tags: %w[meta],
  body: <<~MARKDOWN
    This thread was active a while ago. Leaving it up but locking it
    so no further replies happen.
  MARKDOWN
)

# A topic we'll unlist to exercise toggle-visibility.
topic_unlisted = create_topic_with_posts(
  title: 'Hidden topic — accessible by link only',
  category: cat_general,
  user: users[:bob],
  tags: %w[meta],
  body: 'This topic should not appear in Latest. URL still works.'
)

# ---- Bulk-pad the Latest tab with a varied mix of topics so the home
# feed feels alive. Spread across all 3 categories + various tags.

extra_topics_spec = [
  {
    title: 'Tips for naming your first Flutter widgets',
    category: cat_general, user: users[:ivy],
    tags: %w[flutter beginner howto],
    body: <<~MD,
      A few patterns I picked up after my first six months in Flutter:

      1. **Suffix with the role** — `OrderListPage`, `OrderListItem`.
      2. **Avoid “Widget” in the name** — every widget is a widget already.
      3. **Co-locate state classes** unless you really need them shared.

      What's been working for you?
    MD
    replies: [
      [users[:henry], 'Also: stop using "MyXxx" everywhere. It survives in tutorials but it makes navigating the codebase harder.'],
      [users[:grace], 'Naming feels like 80% of the design work some days 😅'],
      [users[:bob],   "I've started prefixing route-level widgets with `Page` and reusable bits with no suffix. Makes intent obvious."]
    ]
  },
  {
    title: 'Anyone else seeing slow startup on macOS?',
    category: cat_support, user: users[:henry],
    tags: %w[macos bug-report],
    body: 'Cold start takes ~6s on my M2. Hot reload is fine. Profile-mode is faster than debug as expected, but still a noticeable hang on the splash. Is this expected?',
    replies: [
      [users[:eve], 'On M1 Pro debug-build cold start is around 4–5s for me. Most of that is Dart VM warm-up. Try `flutter run --profile` and see if you can shave a second.'],
      [users[:frank], 'macOS code signing on first launch can add a couple of seconds too. Subsequent launches should be faster.']
    ]
  },
  {
    title: 'Show & tell: dark theme tweaks',
    category: cat_general, user: users[:grace],
    tags: %w[feedback],
    body: 'Spent the weekend tuning the dark theme. Bumped the surface tints and increased contrast on muted text. Curious to hear what you think.',
    replies: [
      [users[:alice], 'The contrast is way better now. The old palette had quote blocks that were almost invisible.'],
      [users[:ivy], 'Could we get a screenshot in the OP? Hard to comment without seeing it 🙂'],
      [users[:carol], 'Subtle, but the shadow under the bottom toolbar is still pretty heavy in dark mode.']
    ]
  },
  {
    title: 'Roadmap: what would you like to see next?',
    category: cat_general, user: users[:eve],
    tags: %w[meta feedback],
    body: <<~MD,
      Loose roadmap thread — drop wishes, vote with hearts, mention people you'd want involved.

      No commitments here, just signal collection.
    MD
    replies: [
      [users[:bob], 'Push notifications, hands down.'],
      [users[:carol], 'Markdown preview in the composer.'],
      [users[:henry], 'Better tablet/landscape layout.'],
      [users[:grace], 'Threaded chat replies once we wire chat threads.'],
      [users[:frank], 'Search history sync across devices.']
    ]
  },
  {
    title: 'Heads-up: scheduled maintenance Sunday 02:00 UTC',
    category: cat_announcements, user: users[:mallory],
    tags: %w[meta],
    body: "Database upgrade + plugin updates. Expecting ~30 min downtime. Mobile app will reconnect automatically once we're back up.",
  },
  {
    title: 'Comparison: Discourse vs the legacy XF setup',
    category: cat_general, user: users[:alice],
    tags: %w[feedback meta],
    body: <<~MD,
      Now that we've been on Discourse for a few months, here's my (very
      subjective) summary:

      | Area | Old (XF) | Now (Discourse) |
      |------|---------|-----------------|
      | Composer | BBCode | Markdown |
      | Search | OK | Excellent (filters!) |
      | Mobile | Ad-hoc theme | Native app + responsive web |
      | Plugins | Heavy add-ons | Modular, npm-style |

      What surprised you (good or bad)?
    MD
    replies: [
      [users[:henry], 'The notification levels actually doing what they say is a huge change. On XF, "watch" felt like a roulette.'],
      [users[:ivy], 'Search is a different category entirely. The operators (`status:solved`, `in:bookmarks`) saved me last week.'],
      [users[:dave], 'Newcomer here — coming from Reddit, the trust-level system is a nice middle ground. Less karma-ish.']
    ]
  },
  {
    title: 'How to embed a YouTube video in a topic body?',
    category: cat_support, user: users[:dave],
    tags: %w[howto beginner],
    body: 'Just paste the URL on its own line, right? Mine renders as plain text.',
    replies: [
      [users[:carol], 'Yes — paste the URL on a line by itself, no Markdown link syntax around it. Discourse will onebox it on save.'],
      [users[:bob], "Also make sure the URL is the regular one (`youtube.com/watch?v=…`), not the embed URL."]
    ]
  },
  {
    title: 'Best Markdown cheat sheet?',
    category: cat_support, user: users[:frank],
    tags: %w[howto beginner],
    body: 'Looking for a 1-page reference I can pin somewhere. The Discourse FAQ has snippets but not a clean overview.',
    replies: [
      [users[:eve], 'CommonMark spec is the canonical one — but for daily reference I just keep the GitHub guide bookmarked: https://docs.github.com/en/get-started/writing-on-github']
    ]
  }
]

extra_topics_spec.each do |spec|
  create_topic_with_posts(
    title: spec[:title],
    category: spec[:category],
    user: spec[:user],
    tags: spec[:tags] || const_get(:Array).new,
    body: spec[:body],
    replies: (spec[:replies] || []).map { |u, r| { user: u, raw: r } }
  )
end

# Spread out timestamps so the Latest tab feels lived-in (not all
# clumped at the moment the seed ran). Ages in seconds — anchored on
# distinctive title fragments so re-running is safe.
[
  ['Welcome to the demo forum',                              5 * 86400], # 5 days ago
  ['Old thread — closed for historical reference',          14 * 86400], # 2 weeks
  ['Best practices for handling Cloudflare in mobile apps?', 3 * 86400],
  ['Anyone tried the new server-side drafts feature?',       2 * 86400],
  ['Mobile app crashes when I open a topic with a poll',    20 * 3600],  # 20h
  ['Best Markdown cheat sheet?',                             7 * 3600],
  ['How to embed a YouTube video in a topic body?',         30 * 3600],
  ['Comparison: Discourse vs the legacy XF setup',           4 * 3600],
  ['Roadmap: what would you like to see next?',              2 * 3600],
  ['Show & tell: dark theme tweaks',                        50 * 60],   # 50 min
  ['Anyone else seeing slow startup on macOS?',             25 * 60],
  ['Tips for naming your first Flutter widgets',             8 * 60]    # 8 min
].each do |fragment, age_seconds|
  t = Topic.where('title LIKE ?', "%#{fragment}%").first
  next unless t
  bumped = age_seconds.seconds.ago
  Topic.where(id: t.id).update_all(
    bumped_at: bumped,
    last_posted_at: bumped,
    created_at: bumped - 5.minutes
  )
end
puts "  · spread Latest-tab timestamps"

# ----------------------------------------------------------------------
# 5. Moderator state — pin / close / archive / unlist (Phase 5.9)
# ----------------------------------------------------------------------

puts "\n[5/9] Moderator state…"

# Pin the announcement globally.
topic_announce.update_pinned(true, true)
puts "  · pinned globally: #{topic_announce.title.truncate(40)}"

# Close + archive the old thread.
topic_archived.update_status('closed', true, users[:mallory])
topic_archived.update_status('archived', true, users[:mallory])
puts "  · closed + archived: #{topic_archived.title.truncate(40)}"

# Unlist the hidden topic.
topic_unlisted.update_status('visible', false, users[:mallory])
puts "  · unlisted: #{topic_unlisted.title.truncate(40)}"

# ----------------------------------------------------------------------
# 6. Solved indicator (Phase 5.2) — only if discourse-solved is loaded
# ----------------------------------------------------------------------

puts "\n[6/9] Solved indicator…"

solved_plugin_loaded =
  defined?(DiscourseSolved) ||
  SiteSetting.respond_to?(:solved_enabled)

if solved_plugin_loaded
  begin
    SiteSetting.solved_enabled = true if SiteSetting.respond_to?(:solved_enabled)
    # Allow the Support category to accept solutions (some categories
    # have this gated by SiteSetting.allow_solved_on_all_topics).
    SiteSetting.allow_solved_on_all_topics = true if
      SiteSetting.respond_to?(:allow_solved_on_all_topics)

    answer_post = topic_solved.posts.where(user_id: users[:alice].id).first
    if answer_post.nil?
      puts "  ! no answer post found on #{topic_solved.title.truncate(40)}"
    elsif DiscourseSolved::SolvedTopic.exists?(topic_id: topic_solved.id)
      puts "  · already solved: #{topic_solved.title.truncate(40)}"
    else
      # Discourse-solved exposes a Service::Base — call with a guardian
      # context (acting user = the topic OP, who has permission to
      # accept their own answer) and the post_id in params.
      guardian = Guardian.new(users[:carol])
      result = DiscourseSolved::AcceptAnswer.call(
        guardian: guardian,
        params: { post_id: answer_post.id }
      )
      if result.respond_to?(:success?) && !result.success?
        # Fall back to creating the SolvedTopic record directly.
        DiscourseSolved::SolvedTopic.create!(
          topic: topic_solved,
          answer_post: answer_post,
          accepter: users[:carol]
        )
      end
      puts "  ✓ marked solved: #{topic_solved.title.truncate(40)}"
    end
  rescue => e
    puts "  ! solved-plugin call failed: #{e.class}: #{e.message}"
    # Last-resort fallback: directly create the SolvedTopic record.
    begin
      answer_post = topic_solved.posts.where(user_id: users[:alice].id).first
      if answer_post &&
         !DiscourseSolved::SolvedTopic.exists?(topic_id: topic_solved.id)
        DiscourseSolved::SolvedTopic.create!(
          topic: topic_solved,
          answer_post: answer_post,
          accepter: users[:carol]
        )
        puts "    → fell back to direct SolvedTopic.create!"
      end
    rescue => inner
      puts "    ! fallback also failed: #{inner.message}"
    end
  end
else
  puts "  - discourse-solved plugin not loaded, skipping"
end

# ----------------------------------------------------------------------
# 7. Bookmarks (Phase 5.3.1bc / 5.3.2)
# ----------------------------------------------------------------------

puts "\n[7/9] Bookmarks…"

# Helper: pull a topic by title fragment (returns nil if not yet seeded).
def topic_like(fragment)
  Topic.where('title LIKE ?', "%#{fragment}%").order(:id).first
end

bookmark_seeds = [
  [users[:alice], topic_solved.posts.first],
  [users[:alice], topic_with_poll.posts.first],
  [users[:alice], topic_chatty.posts.first],
  [users[:bob], topic_solved.posts.first],
  [users[:bob], topic_announce.posts.first],
  [users[:carol], topic_with_poll.posts.first],
  [users[:eve], topic_announce.posts.first],
  [users[:ivy], topic_like('Comparison: Discourse')&.posts&.first],
  [users[:henry], topic_like('Best Markdown cheat sheet')&.posts&.first],
  [users[:grace], topic_like('Tips for naming your first Flutter')&.posts&.first]
]

bookmark_seeds.each do |user, post|
  next unless post

  next if Bookmark.where(user_id: user.id, bookmarkable_id: post.id,
                         bookmarkable_type: 'Post').exists?
  Bookmark.create!(
    user: user,
    bookmarkable: post,
    name: nil,
    reminder_set_at: nil
  )
  puts "  + @#{user.username} bookmarked “#{post.topic.title.truncate(40)}”"
end

# ----------------------------------------------------------------------
# 7a. Likes — real Discourse likes (post_action_type_id=2). Spread
# across many posts so the like counts on the post action bar look
# realistic.
# ----------------------------------------------------------------------

puts "\n[7a] Likes…"

# (liker, post) pairs. Self-likes are auto-skipped by Discourse.
like_seeds = []

# Big pile of likes on the bookmark/solution thread.
solution_post = topic_solved.posts.where(user_id: users[:alice].id).first
if solution_post
  %i[bob carol eve frank grace henry ivy mallory dave].each do |u|
    like_seeds << [users[u], solution_post]
  end
end

# Steady likes on the chatty topic's replies.
topic_chatty.posts.each_with_index do |p, i|
  # Each reply gets 1–4 likes from random sets of users.
  pool = %i[alice bob eve frank grace henry ivy carol dave]
  count = (i % 4) + 1
  pool.first(count).each { |u| like_seeds << [users[u], p] }
end

# Likes on the announcement.
ann_post = topic_announce.posts.first
if ann_post
  %i[alice bob carol eve frank grace henry ivy].each do |u|
    like_seeds << [users[u], ann_post]
  end
end

# Likes scattered across the new bulk-padded topics' OPs.
[
  'Tips for naming your first Flutter',
  'Show & tell: dark theme tweaks',
  'Roadmap: what would you like to see next?',
  'Comparison: Discourse vs the legacy XF',
  'Anyone else seeing slow startup on macOS',
  'Best Markdown cheat sheet'
].each do |fragment|
  t = topic_like(fragment)
  next unless t
  op = t.posts.where(post_number: 1).first
  next unless op
  pool = %i[alice bob carol eve frank grace henry ivy dave]
  pool.sample(rand(2..5)).each { |u| like_seeds << [users[u], op] }
end

success_likes = 0
skipped_likes = 0
like_seeds.each do |user, post|
  next unless post
  next if user.id == post.user_id  # Discourse forbids liking your own post

  next if PostAction.where(
    user_id: user.id,
    post_id: post.id,
    post_action_type_id: PostActionType.types[:like]
  ).exists?

  begin
    PostActionCreator.like(user, post)
    success_likes += 1
  rescue => e
    skipped_likes += 1
    puts "  ! @#{user.username} like failed on post ##{post.id}: #{e.class}"
  end
end
puts "  + #{success_likes} new likes (skipped #{skipped_likes})"

# ----------------------------------------------------------------------
# 7b. Reactions (Phase 5.11) — only when discourse-reactions installed
# ----------------------------------------------------------------------

puts "\n[7b] Reactions…"

# Enable the plugin if the constant is loaded but the setting is off.
if defined?(DiscourseReactions) &&
   SiteSetting.respond_to?(:discourse_reactions_enabled) &&
   !SiteSetting.discourse_reactions_enabled
  SiteSetting.discourse_reactions_enabled = true
  puts "  · flipped discourse_reactions_enabled = true"
end

reactions_plugin_loaded =
  defined?(DiscourseReactions) &&
  SiteSetting.respond_to?(:discourse_reactions_enabled) &&
  SiteSetting.discourse_reactions_enabled

if reactions_plugin_loaded
  begin
    # Pre-seed a few emoji reactions on the bookmark topic + the poll
    # topic so the chips row has something to render in the app.
    # Use Discourse's stock enabled-reaction set. Anything outside the
    # SiteSetting.discourse_reactions_enabled_reactions list raises
    # "Invalid reaction".
    sol_post = topic_solved.posts.where(user_id: users[:alice].id).first
    poll_op = topic_with_poll.posts.first
    chatty_replies = topic_chatty.posts.where('post_number > 1').to_a

    reaction_seeds = [
      [users[:bob],    sol_post, 'heart'],
      [users[:eve],    sol_post, 'clap'],
      [users[:carol],  sol_post, 'clap'],
      [users[:frank],  sol_post, 'clap'],
      [users[:henry],  sol_post, 'heart'],
      [users[:ivy],    sol_post, 'open_mouth'],
      [users[:alice],  poll_op,  'confetti_ball'],
      [users[:bob],    poll_op,  'heart'],
      [users[:grace],  poll_op,  'confetti_ball'],
      [users[:henry],  poll_op,  'laughing']
    ]
    # Spread a few reactions across the chatty thread for variety.
    chatty_replies.each_with_index do |p, i|
      [
        [users[:alice],  'heart'],
        [users[:eve],    'clap'],
        [users[:frank],  'laughing'],
        [users[:henry],  'open_mouth']
      ].sample((i % 3) + 1).each do |u, v|
        next if u.id == p.user_id
        reaction_seeds << [u, p, v]
      end
    end
    # And a couple on the announcement.
    if topic_announce.posts.first
      reaction_seeds << [users[:alice], topic_announce.posts.first, 'heart']
      reaction_seeds << [users[:bob],   topic_announce.posts.first, 'clap']
      reaction_seeds << [users[:eve],   topic_announce.posts.first, 'hugs']
    end
    success_reactions = 0
    skipped_reactions = 0
    reaction_seeds.each do |user, post, value|
      next unless post
      # Discourse blocks self-reactions.
      next if user.id == post.user_id

      already_reacted = DiscourseReactions::ReactionUser
                          .joins(:reaction)
                          .where(user_id: user.id,
                                 post_id: post.id,
                                 discourse_reactions_reactions: { reaction_value: value })
                          .exists?
      next if already_reacted

      begin
        DiscourseReactions::ReactionManager.new(
          reaction_value: value,
          user: user,
          post: post
        ).toggle!
        success_reactions += 1
      rescue => e
        skipped_reactions += 1
        # Individual failures are often "1 reaction per user per post" /
        # past-edit-window — don't abort the rest of the batch.
        next
      end
    end
    puts "  + #{success_reactions} new reactions (skipped #{skipped_reactions})"
  rescue => e
    puts "  ! reaction seeding skipped: #{e.message}"
  end
else
  puts "  - discourse-reactions plugin not installed, skipping"
end

# ----------------------------------------------------------------------
# 7c. Q&A post-voting (Phase 5.14) — only when discourse-post-voting
# is installed and enabled
# ----------------------------------------------------------------------

puts "\n[7c] Q&A post-voting…"

if defined?(PostVoting) &&
   SiteSetting.respond_to?(:post_voting_enabled) &&
   !SiteSetting.post_voting_enabled
  SiteSetting.post_voting_enabled = true
  puts "  · flipped post_voting_enabled = true"
end

post_voting_loaded = defined?(PostVoting) &&
                     SiteSetting.respond_to?(:post_voting_enabled) &&
                     SiteSetting.post_voting_enabled

if post_voting_loaded
  begin
    # Create a Q&A-style topic: subtype=question. The plugin allows
    # any topic to be flagged Q&A via custom field.
    qa_title = 'Best practices for handling Cloudflare in mobile apps?'
    qa_topic = Topic.where(title: qa_title).first
    if qa_topic.nil?
      # Discourse post-voting topics are marked at creation time by
      # passing `create_as_post_voting: true` to PostCreator — that
      # flips topic.subtype to 'question_answer', which the plugin's
      # is_post_voting? predicate checks. Subtype can't be changed
      # after creation, so existing topics can't be retro-fitted.
      qa_post = PostCreator.create!(
        users[:carol],
        title: qa_title,
        category: cat_support.id,
        raw: <<~MARKDOWN,
          We're building a mobile app that talks to a Discourse forum
          behind Cloudflare. Sometimes the WAF challenges block our
          API calls. What's the cleanest way to handle this?

          Looking for community wisdom — multiple voted answers
          welcome.
        MARKDOWN
        tags: %w[mobile flutter howto],
        # `create_as_post_voting` only flips the subtype when going
        # through NewPostManager — which PostCreator.create! bypasses.
        # Set the subtype directly via update_columns to skip the
        # plugin's "no changing subtype after creation" validation.
        skip_validations: true,
        bypass_rate_limiter: true
      )
      qa_topic = qa_post.topic
      qa_topic.update_columns(subtype: Topic::POST_VOTING_SUBTYPE)
      qa_topic.reload

      # A few answers from different users.
      [
        [users[:alice], <<~A1],
          The cleanest pattern is to intercept 403/503 responses in
          your HTTP client and pop a webview to let the user solve
          the challenge. Once they pass, the cf_clearance cookie
          persists in your shared cookie jar and subsequent API
          calls go through.
        A1
        [users[:eve], <<~A2],
          Make sure your User API Key webview shares cookies with
          the rest of the app's HTTP stack. Otherwise the challenge
          cookie won't be there when the SDK calls /t/{id}.json.
        A2
        [users[:bob], <<~A3]
          You can also reach out to your forum host and ask them to
          whitelist a User-Agent your app sets uniformly — much less
          friction for users than the challenge UI.
        A3
      ].each do |user, body|
        PostCreator.create!(
          user,
          topic_id: qa_topic.id,
          raw: body,
          skip_validations: true,
          bypass_rate_limiter: true
        )
      end
      qa_topic.reload
      puts "  + Q&A topic “#{qa_title.truncate(40)}” (#{qa_topic.posts_count} posts)"
    else
      puts "  · Q&A topic already exists"
    end

    # Cast a few votes so the score column has something to render.
    vote_seeds = [
      [users[:bob],   qa_topic.posts.where(user_id: users[:alice].id).first, 'up'],
      [users[:carol], qa_topic.posts.where(user_id: users[:alice].id).first, 'up'],
      [users[:eve],   qa_topic.posts.where(user_id: users[:alice].id).first, 'up'],
      [users[:alice], qa_topic.posts.where(user_id: users[:eve].id).first,   'up'],
      [users[:carol], qa_topic.posts.where(user_id: users[:eve].id).first,   'up'],
      [users[:dave],  qa_topic.posts.where(user_id: users[:bob].id).first,   'down']
    ]
    vote_seeds.each do |user, post, direction|
      next unless post

      # Skip if already voted.
      if PostVotingVote.exists?(votable: post, user_id: user.id)
        next
      end
      begin
        PostVoting::VoteManager.vote(post, user, direction: direction)
        puts "  + @#{user.username} voted #{direction} on post by @#{post.user.username}"
      rescue => e
        puts "  ! vote failed: #{e.message}"
      end
    end
  rescue => e
    puts "  ! post-voting seeding skipped: #{e.message}"
  end
else
  puts "  - discourse-post-voting plugin not installed, skipping"
end

# ----------------------------------------------------------------------
# 7d. Discourse Chat (Phase 5.15) — only when the chat plugin is enabled
# ----------------------------------------------------------------------

puts "\n[7d] Chat…"

if defined?(Chat) && SiteSetting.respond_to?(:chat_enabled) &&
   SiteSetting.chat_enabled
  begin
    # Make sure all our demo users are allowed to chat: the default
    # SiteSetting.chat_allowed_groups is "trust_level_1" — Dave (TL0)
    # would be excluded otherwise. Widen to "everyone" for the demo.
    if SiteSetting.respond_to?(:chat_allowed_groups) &&
       !SiteSetting.chat_allowed_groups.to_s.include?(Group::AUTO_GROUPS[:everyone].to_s)
      SiteSetting.chat_allowed_groups = Group::AUTO_GROUPS[:everyone].to_s
      puts "  · widened chat_allowed_groups → everyone"
    end
    # Allow DM channels for all users — defaults to TL1, which would
    # exclude Dave.
    if SiteSetting.respond_to?(:direct_message_enabled_groups) &&
       !SiteSetting.direct_message_enabled_groups.to_s.include?(Group::AUTO_GROUPS[:everyone].to_s)
      SiteSetting.direct_message_enabled_groups = Group::AUTO_GROUPS[:everyone].to_s
      puts "  · widened direct_message_enabled_groups → everyone"
    end

    # ===== Helpers ======================================================

    send_chat = ->(channel, user, body) {
      sample = body.first(40)
      return if Chat::Message.where(chat_channel_id: channel.id, user_id: user.id)
                              .where('message ILIKE ?', "#{sample}%").exists?
      begin
        Chat::CreateMessage.call(
          guardian: Guardian.new(user),
          params: { chat_channel_id: channel.id, message: body }
        )
      rescue => e
        puts "  ! send by @#{user.username} failed: #{e.class}: #{e.message}"
      end
    }

    create_or_find_category_channel = ->(name:, category:, description:) {
      ch = Chat::Channel.find_by(name: name)
      return ch if ch
      ch = Chat::CategoryChannel.create!(
        chatable: category,
        name: name,
        description: description,
        slug: name,
        status: Chat::Channel.statuses[:open]
      )
      puts "  + chat channel ##{name}"
      ch
    }

    join_all = ->(channel, user_handles) {
      user_handles.each do |handle|
        u = users[handle]
        next unless u
        begin
          Chat::ChannelMembershipManager.new(channel).follow(u)
        rescue => e
          puts "  ! follow @#{u.username} failed: #{e.message}"
        end
      end
    }

    # ===== Channel 1: #demo-watercooler (general off-topic) =============

    channel = create_or_find_category_channel.call(
      name: 'demo-watercooler',
      category: cat_general,
      description: 'Open chat room for the demo forum'
    )
    join_all.call(channel, %i[alice bob carol dave eve mallory frank grace henry ivy])

    watercooler_seeds = [
      [users[:alice],   "👋 Welcome to the watercooler!"],
      [users[:bob],     "Quick question — does the mobile app handle Cloudflare challenges OK?"],
      [users[:alice],   "It does — there's an in-app webview that pops up when CF sends a 403/503."],
      [users[:carol],   "Nice. I'll test on iOS later today."],
      [users[:eve],     "Let me know if you hit anything weird with the User API Key handshake."],
      [users[:bob],     "Will do 🙂"],
      [users[:henry],   "anyone here who's tried the Flutter inspector on the new app?"],
      [users[:ivy],     "@henry yes! the rebuild stats helped me find a couple of needless setStates"],
      [users[:henry],   "👀 sharing screenshots now"],
      [users[:grace],   "i love the new dark theme"],
      [users[:frank],   "+1 — the muted text contrast is way better"],
      [users[:eve],     "we still need to fix the bottom bar shadow on dark mode though"],
      [users[:dave],    "is push notifications coming next?"],
      [users[:alice],   "soon™. it's in the phase plan as Phase 3."],
      [users[:bob],     "speaking of which: anyone seen the chat tab work on macOS yet?"],
      [users[:ivy],     "tested 30 min ago, polling cadence feels fine"],
      [users[:carol],   "i can see your messages 🚀"],
      [users[:eve],     "let's get reactions on chat messages next?"],
      [users[:henry],   "yes please, that'd be a 1-day add given the picker we already built"],
      [users[:mallory], "heads up: i'll be archiving the old `#help` channel later this week — folded into `#mobile-dev`"],
      [users[:frank],   "👍"],
      [users[:alice],   "anyone working on the **markdown preview** for the composer?"],
      [users[:grace],   "i started a branch but it's rough"],
      [users[:henry],   "happy to review the diff when it's ready"],
      [users[:ivy],     "fun bug of the day: long-pressing a like sometimes opens both the reaction picker AND likes someone's post 😅"],
      [users[:alice],   "haha. need to gate the tap callback when the long-press fires"],
      [users[:bob],     "filed it as #1234"],
      [users[:dave],    "what's the recommended Flutter version for contributions?"],
      [users[:eve],     "we pin `^3.6.1` in pubspec — anything that fits should be fine"],
      [users[:henry],   "and run `./buildlib.sh` after pulling, codegen is hand-rolled on Dart 3.10"],
      [users[:dave],    "got it, thanks"],
      [users[:grace],   "remember: bots are watching 🤖"],
      [users[:frank],   "🤣"],
      [users[:alice],   "ok back to coding — ping me with @alice if anything blocks"],
      [users[:carol],   "lunch break, brb"]
    ]
    watercooler_seeds.each { |u, body| send_chat.call(channel, u, body) }

    # Edit one of Bob's messages so the "(edited)" indicator shows up.
    bob_msg = Chat::Message.where(chat_channel_id: channel.id, user_id: users[:bob].id)
                            .where('message ILIKE ?', '+1%')
                            .first
    if bob_msg && !bob_msg.edited
      # Use update_columns to skip plugin validations / hooks (we just
      # want the edited flag visible to the UI).
      bob_msg.update_columns(
        message: '+1 — the muted text contrast is way better. (esp. quote blocks)',
        cooked: '<p>+1 — the muted text contrast is way better. (esp. quote blocks)</p>',
        last_editor_id: users[:bob].id,
        edited: true,
        updated_at: Time.now
      )
    end

    channel.reload
    puts "  · ##{channel.name}: #{Chat::Message.where(chat_channel_id: channel.id).count} messages"

    # ===== Channel 2: #mobile-dev (focused tech channel) ================

    dev_channel = create_or_find_category_channel.call(
      name: 'mobile-dev',
      category: cat_support,
      description: 'Mobile client development — Flutter + Discourse REST'
    )
    join_all.call(dev_channel, %i[alice bob eve frank henry ivy mallory])

    mobile_dev_seeds = [
      [users[:alice], "kicking this off — the discourseapp is now at Phase 5.15"],
      [users[:eve],   "🎉"],
      [users[:henry], "are we feature-frozen on the chat side or do we want MessageBus for real-time?"],
      [users[:alice], "polling is fine for v1. MessageBus would be ~1 day of work but better as a follow-up"],
      [users[:frank], "what's blocking the Markdown preview?"],
      [users[:ivy],   "nothing technical — just need a 50/50 split view widget and to debounce the html re-render"],
      [users[:henry], "i can take that one"],
      [users[:bob],   "any opinions on debouncing? 200ms felt right when i prototyped it"],
      [users[:eve],   "200ms is the sweet spot. anything faster fights with autocorrect on iOS"],
      [users[:alice], "let's also keep the markdown raw view visible at all times during preview"],
      [users[:frank], "👍 side-by-side then, not toggle"],
      [users[:henry], "ok — i'll open a PR by friday"],
      [users[:alice], "🙏"]
    ]
    mobile_dev_seeds.each { |u, body| send_chat.call(dev_channel, u, body) }

    dev_channel.reload
    puts "  · ##{dev_channel.name}: #{Chat::Message.where(chat_channel_id: dev_channel.id).count} messages"

    # ===== Channel 3: DM between alice and bob ==========================

    dm_users = [users[:alice], users[:bob]].compact
    if dm_users.length == 2
      # Look for an existing 2-person DM with exactly these users.
      existing_dm = Chat::Channel
                      .joins(:user_chat_channel_memberships)
                      .where(chatable_type: 'DirectMessage')
                      .where(user_chat_channel_memberships: { user_id: dm_users.map(&:id) })
                      .group('chat_channels.id')
                      .having('COUNT(DISTINCT user_chat_channel_memberships.user_id) = ?', 2)
                      .first

      if existing_dm
        dm = existing_dm
        puts "  · DM channel already exists (id #{dm.id})"
      else
        direct = Chat::DirectMessage.create!(group: false)
        dm = Chat::DirectMessageChannel.create!(
          chatable: direct,
          status: Chat::Channel.statuses[:open]
        )
        # Add memberships and direct-message-user rows for each user.
        dm_users.each do |u|
          Chat::UserChatChannelMembership.find_or_create_by!(
            user: u, chat_channel: dm
          ) do |m|
            m.following = true
          end
          Chat::DirectMessageUser.find_or_create_by!(
            user: u, direct_message: direct
          )
        end
        puts "  + DM channel (alice ↔ bob)"
      end

      dm_seeds = [
        [users[:bob],   "hey — quick favour, can you review my chat-reactions PR?"],
        [users[:alice], "sure — link?"],
        [users[:bob],   "https://github.com/forumcopilot/discourse-app/pull/42"],
        [users[:alice], "looking now 👀"],
        [users[:alice], "looks great. one tiny nit on the picker — left a comment"],
        [users[:bob],   "ty, will fix and re-request"]
      ]
      dm_seeds.each { |u, body| send_chat.call(dm, u, body) }

      dm.reload
      puts "  · DM: #{Chat::Message.where(chat_channel_id: dm.id).count} messages"
    end
  rescue => e
    puts "  ! chat seeding skipped: #{e.class}: #{e.message}"
  end
else
  puts "  - Discourse Chat not installed/enabled, skipping"
end

# ----------------------------------------------------------------------
# 8. Badges (Phase 5.7) + follows (Phase 5.8) + notification levels (5.4)
# ----------------------------------------------------------------------

puts "\n[8/9] Badges, follows, notification levels…"

# Sample badge grants — these names match Discourse's pre-seeded badges
# (Discourse 3.x). If your install has different badges, the script
# falls back to a warning and continues.
[
  [users[:alice], ['Welcome', 'Autobiographer', 'First Like', 'First Quote',
                   'Member', 'Regular', 'Leader']],
  [users[:bob],   ['Welcome', 'First Like', 'Member', 'Editor']],
  [users[:carol], ['Welcome', 'First Link']],
  [users[:eve],   ['Welcome', 'Autobiographer', 'First Like', 'First Share',
                   'Regular', 'Champion']]
].each do |user, badges|
  badges.each { |b| award_badge(user, b) }
end

# Follow graph — only when the follow plugin/columns exist. Discourse 3.2+
# adds the table directly; earlier versions need the user-following plugin.
if ActiveRecord::Base.connection.table_exists?('user_follows') ||
   ActiveRecord::Base.connection.table_exists?('follows')
  begin
    follow_table =
      ActiveRecord::Base.connection.table_exists?('user_follows') ? 'user_follows' : 'follows'
    pairs = [
      [users[:carol], users[:alice]],
      [users[:carol], users[:eve]],
      [users[:bob], users[:eve]],
      [users[:alice], users[:eve]]
    ]
    pairs.each do |follower, following|
      already = ActiveRecord::Base.connection.exec_query(
        "SELECT 1 FROM #{follow_table} WHERE user_id=$1 AND followed_user_id=$2 LIMIT 1",
        'sql',
        [follower.id, following.id]
      ).rows.any?
      next if already

      ActiveRecord::Base.connection.exec_query(
        "INSERT INTO #{follow_table} (user_id, followed_user_id, created_at, updated_at) " \
        'VALUES ($1, $2, NOW(), NOW())',
        'sql',
        [follower.id, following.id]
      )
      puts "  + @#{follower.username} follows @#{following.username}"
    end
  rescue => e
    puts "  ! follow seeding skipped: #{e.message}"
  end
else
  puts "  - follow tables not present; install discourse-follow plugin"
  puts "    (https://github.com/discourse/discourse-follow) to enable @follows"
end

# Notification levels — make Alice "Watch" the bookmark topic, Bob track
# the support category.
TopicUser.change(users[:alice].id, topic_solved.id,
                 notification_level: TopicUser.notification_levels[:watching])
puts "  · @alice → Watching “#{topic_solved.title.truncate(40)}”"

CategoryUser.set_notification_level_for_category(
  users[:bob], CategoryUser.notification_levels[:tracking], cat_support.id
)
puts "  · @bob → Tracking ##{cat_support.slug}"

CategoryUser.set_notification_level_for_category(
  users[:dave], CategoryUser.notification_levels[:muted], cat_announcements.id
)
puts "  · @dave → Muted ##{cat_announcements.slug}"

# ----------------------------------------------------------------------
# 9. Server-side drafts (Phase 5.3.3)
# ----------------------------------------------------------------------

puts "\n[9/9] Server-side drafts…"

[
  # A reply draft on the bookmark topic.
  {
    user: users[:carol],
    key: "topic_#{topic_solved.id}",
    data: {
      reply: "Following up — does this work for whisper posts too?",
      action: 'reply'
    }
  },
  # A new-topic draft for Bob.
  {
    user: users[:bob],
    key: 'new_topic',
    data: {
      reply: "I'm drafting a longer post about migrating to Markdown…",
      title: 'Markdown migration notes',
      action: 'createTopic',
      categoryId: cat_general.id
    }
  }
].each do |spec|
  # `Draft.set` enforces an optimistic-concurrency sequence number that
  # increments on every save. On a fresh DB the sequence is 0; on
  # re-run it's wherever the previous run left it. Look up the current
  # sequence so re-running the seed doesn't trip Draft::OutOfSequence.
  current_sequence = DraftSequence.current(spec[:user], spec[:key])
  begin
    Draft.set(spec[:user], spec[:key], current_sequence, spec[:data].to_json)
    puts "  + draft “#{spec[:key]}” for @#{spec[:user].username}"
  rescue Draft::OutOfSequence
    # Sequence advanced between the lookup and the set; safe to skip.
    puts "  · draft “#{spec[:key]}” already up-to-date for @#{spec[:user].username}"
  end
end

# ----------------------------------------------------------------------
# Done
# ----------------------------------------------------------------------

topic_count = Topic.where(id: Topic.where.not(archetype: 'private_message').pluck(:id)).count
post_count = Post.where.not(post_type: Post.types[:whisper]).count
like_count = PostAction.where(post_action_type_id: PostActionType.types[:like]).count

puts <<~SUMMARY

  === seed complete ===

  Inventory:
    * #{User.where('id > 1').count} demo users
    * #{topic_count} topics, #{post_count} posts, #{like_count} likes
    * #{Bookmark.count} bookmarks, #{DiscourseReactions::ReactionUser.count rescue 0} reactions
    * #{Chat::Channel.count rescue 0} chat channels, #{Chat::Message.count rescue 0} chat messages

  Users (password = #{emoji_password}):
    alice   — TL3, lots of likes + reactions
    bob     — TL2, tracking the Support category
    carol   — TL1, has a reply draft
    dave    — TL0, muted Announcements
    eve     — TL4 (Leader), most-liked answer in the bookmark thread
    mallory — Moderator (use this account to test mod actions)
    frank, grace, henry, ivy — extra chat + topic participants

  Try in the mobile app:
    * Latest tab → varied topics across 3 categories, with tag chips
    * Tap a tag → tag-filtered list (5.1)
    * Open the bookmark topic → "Solution" banner + ~10 likes on the answer
    * Bookmark icon on any post → toggles via /bookmarks.json (5.3.1)
    * Your profile → Bookmarks button + Trust level chip + badges row
    * Bell icon on a topic → 4-level Watching/Tracking/Normal/Muted picker
    * Scroll to bottom of any topic → "Suggested Topics" footer
    * Search → filter icon → status:solved chip filters topics
    * Open the poll topic → vote widget at the top (5.3.4)
    * Q&A topic ("Best practices for handling Cloudflare…") → up/down arrows
    * Long-press the heart on a post → emoji reaction picker (5.11)
    * Open any user's profile (not your own) → Follow button
    * Chat icon (top-right of Home) →
        - #demo-watercooler (35 messages, 10 members)
        - #mobile-dev (13 messages, 7 members)
        - DM: alice ↔ bob (6 messages)
    * Log in as @mallory → kebab menu shows Archive / Unlist / Rename

SUMMARY
