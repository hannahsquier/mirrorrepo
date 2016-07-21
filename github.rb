require 'octokit'
require 'pp'
require 'httparty'
require 'pry'
require 'json'


class GithubRepos

  include Octokit

  def initialize()
    Octokit.auto_paginate = true
    @client = Octokit::Client.new(access_token: ENV['GIT_API_KEY'])
    @user = @client.user
    @repos = @client.repos(@user.login).sort_by { |a| a[:created_at] }.reverse
  end

  def print_commits
    last_ten_names = get_last_ten_names
    get_commit_messages.each_with_index do |repo, index|
      puts "**************************************"
      puts "Last 10 #{last_ten_names[index]} commits:"
      puts "**************************************"
      repo.each do |message|
        puts message
      end
    end
  end

  def get_last_ten_names
    names = []
    @repos.each do |repo|
      names << repo[:full_name]
    end
    names
  end

  def get_commit_messages
    @repos.map do |repo|

      commits = @client.commits(repo[:full_name]).map { |commit| commit.commit.message }
    end
  end


  def clone_repo(repo)
    `git clone #{repo}`
  end

  def forked_repos
    forked_repos = []
    @repos.each do |repo|
      forked_repos << repo if repo["fork"]
    end
    forked_repos
  end

  def get_dates
    dates = []
    forked_repos.each do |repo|
      dates << @client.commits(repo[:full_name]).map { |commit| commit.commit.committer.date }
    end
    dates.flatten.map { |date| date.iso8601 }
  end

  def create_commits

    get_dates.each do |date|
      system("echo \"#{date}\" >> README.md")
      system('git add -A')
      system("git commit --date #{date} -m \"Private Repo\"")
    end
    system('gpom')
  end

end

gh = GithubRepos.new
gh.create_commits


