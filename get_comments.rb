require 'github_api'
require 'date'

ship_matchers = [
  ":ship:",
  ":shipit",
  ":sheep::it:",
  ":sheep: :it:",
  ":rocket:",
  ":speedboat:",
  ":sailboat:"
] 

users = {}

gh = Github.new basic_auth: "USERNAME:PASS",
  org: 'Quve',
  user: 'Quve',
  repo: 'quve'


# Date.new(year, month, day)
start_date = Date.new(2014,9,8)
page = 1
done = false
while !done do
  prs = gh.pull_requests.list state: 'closed', sort: 'updated', direction: 'desc', page: page

  prs.each do |r|
    date = DateTime.parse(r.updated_at)
    p date
    if date < start_date
      done = true
      break;
    end

    next if r.merged_at.nil? || DateTime.parse(r.merged_at) < start_date

    ship_users = [] 

    pr = gh.pull_requests.get number: r.number
    score = pr.additions + pr.deletions

    comments = gh.issues.comments.list number: r.number
    comments.each do |c|
      if ship_matchers.any? { |sm| c.body[sm] }
        ship_users << c.user.login if !ship_users.include? c.user.login
      end
    end

    if ship_users.length == 0
      puts "Unable to find ship for PR #{r.number}"
    elsif ship_users.length == 1
      users[ship_users[0]] ||= 0
      users[ship_users[0]] += score
    else
      puts "Found multiple ships for PR #{r.number}"
      p ship_users
    end

  end

  page += 1
end

p users
