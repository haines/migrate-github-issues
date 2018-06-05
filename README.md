# migrate-github-issues

Move GitHub issues between repositories.

## Install

Requires Ruby 2.4+.

```console
$ git clone https://github.com/haines/migrate-github-issues.git
$ cd migrate-github-issues
$ bundle install
```

## Usage

```console
$ bin/migrate-github-issues --help
Move GitHub issues between repositories.

Usage:
  bin/migrate-github-issues [flags] from-user/repo to-user/repo

Arguments:
  from-user/repo  Slug of the repository to copy issues from
  to-user/repo    Slug of the repository to copy issues to

Required environment variables:
  GITHUB_TOKEN  OAuth access token with read and write access to both repositories

Flags:
      --label LABEL                Label to add to migrated issues
  -h, --help                       Get help
```
