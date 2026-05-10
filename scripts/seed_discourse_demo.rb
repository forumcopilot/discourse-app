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

[
  [users[:alice], topic_solved.posts.first],
  [users[:alice], topic_with_poll.posts.first],
  [users[:alice], topic_chatty.posts.first],
  [users[:bob], topic_solved.posts.first],
  [users[:bob], topic_announce.posts.first]
].each do |user, post|
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
  Draft.set(spec[:user], spec[:key], 0, spec[:data].to_json)
  puts "  + draft “#{spec[:key]}” for @#{spec[:user].username}"
end

# ----------------------------------------------------------------------
# Done
# ----------------------------------------------------------------------

puts <<~SUMMARY

  === seed complete ===

  Users (password = #{emoji_password}):
    alice   — TL3, follows Eve, has bookmarks + drafts + badges
    bob     — TL2, follows Eve, tracking the Support category
    carol   — TL1, follows Alice + Eve, has a reply draft
    dave    — TL0, muted Announcements
    eve     — TL4 (Leader), no follows
    mallory — Moderator (use this account to test mod actions)

  Try in the mobile app:
    * Latest tab → see the tag chips on topics (5.0)
    * Tap a tag → tag-filtered list (5.1)
    * Open the bookmark topic → "Solution" banner on Alice's reply (5.2)
    * Bookmark icon on any post → toggles via /bookmarks.json (5.3.1)
    * Your profile → "Bookmarks" button + Trust level chip + badges row (5.3.2, 5.3.1a, 5.7)
    * Bell icon on a topic → 4-level Watching/Tracking/Normal/Muted picker (5.4)
    * Scroll to bottom of any topic → "Suggested Topics" footer (5.5a)
    * Search → filter icon → status:solved chip filters this run's topics (5.6)
    * Open the poll topic → vote widget at the top (5.3.4)
    * Open any user's profile (not your own) → Follow button (5.8)
    * Log in as @mallory → kebab menu shows Archive / Unlist / Rename (5.9)

SUMMARY
