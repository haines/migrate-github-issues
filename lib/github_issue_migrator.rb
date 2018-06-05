# frozen_string_literal: true

require "active_support/all"
require "octokit"

class GitHubIssueMigrator
  def initialize(from:, to:, access_token:, labels: [])
    @github = Octokit::Client.new(access_token: access_token)
    @github.auto_paginate = true
    @from = from
    @to = to
    @labels = labels
  end

  def migrate_issues
    @github.issues(@from).reverse_each do |issue|
      next if issue.pull_request
      migrate_issue issue
    end
  end

  private

  def migrate_issue(from_issue)
    $stderr.puts "Migrating #{@from}##{from_issue.number}..."
    to_issue = create_issue(from_issue)
    migrate_comments from_issue, to_issue
    close_issue from_issue, to_issue
    $stderr.puts "Migrated to #{@to}##{to_issue.number}"
  end

  def create_issue(issue)
    @github.create_issue(
      @to,
      issue.title,
      issue_body(issue),
      assignee: issue.assignee&.login,
      milestone: issue.milestone,
      labels: (@labels + issue.labels.map(&:name)).uniq
    )
  end

  def issue_body(issue)
    <<~MARKDOWN
      _Originally raised by @#{issue.user.login} [#{format_time(issue.created_at)}](#{issue.html_url})_

      #{issue.body}
    MARKDOWN
  end

  def migrate_comments(from_issue, to_issue)
    @github.issue_comments(@from, from_issue.number).each do |comment|
      @github.add_comment @to, to_issue.number, comment_body(comment)
    end
  end

  def comment_body(comment)
    <<~MARKDOWN
      _Originally posted by @#{comment.user.login} [#{format_time(comment.created_at)}](#{comment.html_url})_

      #{comment.body}
    MARKDOWN
  end

  def format_time(time)
    time.in_time_zone("London").strftime("on %F at %T %Z")
  end

  def close_issue(from_issue, to_issue)
    @github.close_issue @from, from_issue.number
    @github.add_comment @from, from_issue.number, "Migrated to #{@to}##{to_issue.number}"
  end
end
