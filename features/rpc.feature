@refresh_token
Scenario: Do not know how to betamax initial oauth handshake
  When begin recording "refresh_token"
  Given gnus
  Then end recording "refresh_token"

@random
Scenario: random subreddit
  When begin recording "random"
  Given gnus
  And rpc "random_subreddit" returns "wholesomegifs"
  Then end recording "random"

@subscribe
Scenario: subscribe and unsubscribe
  When begin recording "subscribe"
  Given gnus
  And I goto group "chvrches"
  And I press "q"
  Then I should be in buffer "*Group*"
  And I go to word "chvrches"
  And I press "u"
  And I open latest "log/test_py"
  Then I wait for buffer to say "('action', 'sub')"
  And I switch to buffer "*Group*"
  And I go to word "chvrches"
  And I press "u"
  And I open latest "log/test_py"
  Then I wait for buffer to say "('action', 'unsub')"
  Then end recording "subscribe"

@scan
Scenario: scanning doesn't reuse, selecting reuses, selecting again scans.
  When begin recording "scan"
  Given gnus
  And I go to word "emacs"
  And I press "M-g"
  And I switch to buffer "*Messages*"
  And I should not see pattern "nnreddit-request-group: reuse.+emacs"
  And I switch to buffer "*Group*"
  And I go to word "emacs"
  And I press "RET"
  And I should be in buffer "*Summary nnreddit:emacs*"
  And I switch to buffer "*Messages*"
  And I should see pattern "nnreddit-request-group: reuse.+emacs"
  And I switch to buffer "*Group*"
  And I go to word "orgmode"
  And I press "RET"
  And I should be in buffer "*Summary nnreddit:orgmode*"
  And I switch to buffer "*Messages*"
  And I should see pattern "nnreddit-request-group: reuse.+orgmode"
  And I switch to buffer "*Group*"
  And I go to word "orgmode"
  And I clear buffer "*Messages*"
  And I press "RET"
  And I switch to buffer "*Messages*"
  And I should not see pattern "nnreddit-request-group: reuse.+orgmode"
  Then end recording "scan"