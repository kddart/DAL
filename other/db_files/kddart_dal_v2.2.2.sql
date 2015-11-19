


<!DOCTYPE html>
<html lang="en" class=" is-copy-enabled">
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# object: http://ogp.me/ns/object# article: http://ogp.me/ns/article# profile: http://ogp.me/ns/profile#">
    <meta charset='utf-8'>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Content-Language" content="en">
    <meta name="viewport" content="width=1020">
    
    
    <title>DAL/kddart_dal_v2.2.2.sql at master · kddart/DAL</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub">
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub">
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-114.png">
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114.png">
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-144.png">
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144.png">
    <meta property="fb:app_id" content="1401488693436528">

      <meta content="@github" name="twitter:site" /><meta content="summary" name="twitter:card" /><meta content="kddart/DAL" name="twitter:title" /><meta content="DAL - KDDart Data Access Layer project" name="twitter:description" /><meta content="https://avatars1.githubusercontent.com/u/10160855?v=3&amp;s=400" name="twitter:image:src" />
      <meta content="GitHub" property="og:site_name" /><meta content="object" property="og:type" /><meta content="https://avatars1.githubusercontent.com/u/10160855?v=3&amp;s=400" property="og:image" /><meta content="kddart/DAL" property="og:title" /><meta content="https://github.com/kddart/DAL" property="og:url" /><meta content="DAL - KDDart Data Access Layer project" property="og:description" />
      <meta name="browser-stats-url" content="https://api.github.com/_private/browser/stats">
    <meta name="browser-errors-url" content="https://api.github.com/_private/browser/errors">
    <link rel="assets" href="https://assets-cdn.github.com/">
    <link rel="web-socket" href="wss://live.github.com/_sockets/NzYwNDY4OTowMTdiODFkN2Y3YzYxODBjZjFmZTk4NGNlZjE1Njk1YzpjMTQ5ZDE4YTU2OGQ1NDc3ZDEwNzE1ZDA2ZjU3Mjg2YTI3NjllODg3MTVhNjFmNjM1Zjg2YjJhNTA3ODhlMzlh--8754d728793bbde152e0f1be5b81a68a1a7cb2e6">
    <meta name="pjax-timeout" content="1000">
    <link rel="sudo-modal" href="/sessions/sudo_modal">

    <meta name="msapplication-TileImage" content="/windows-tile.png">
    <meta name="msapplication-TileColor" content="#ffffff">
    <meta name="selected-link" value="repo_source" data-pjax-transient>

    <meta name="google-site-verification" content="KT5gs8h0wvaagLKAVWq8bbeNwnZZK1r1XQysX3xurLU">
    <meta name="google-analytics" content="UA-3769691-2">

<meta content="collector.githubapp.com" name="octolytics-host" /><meta content="github" name="octolytics-app-id" /><meta content="895C413E:09B2:35DC7356:564D4533" name="octolytics-dimension-request_id" /><meta content="7604689" name="octolytics-actor-id" /><meta content="grzegorz69" name="octolytics-actor-login" /><meta content="e5212f53766d76349e0874e67f62960fe56171ff6fbf7adffe9ff38a9ef12b24" name="octolytics-actor-hash" />

<meta content="Rails, view, blob#show" data-pjax-transient="true" name="analytics-event" />


  <meta class="js-ga-set" name="dimension1" content="Logged In">
    <meta class="js-ga-set" name="dimension4" content="Current repo nav">




    <meta name="is-dotcom" content="true">
        <meta name="hostname" content="github.com">
    <meta name="user-login" content="grzegorz69">

      <link rel="mask-icon" href="https://assets-cdn.github.com/pinned-octocat.svg" color="#4078c0">
      <link rel="icon" type="image/x-icon" href="https://assets-cdn.github.com/favicon.ico">

    <meta content="096393ccbbfab2e5a36f5e830a7ff47176042ee8" name="form-nonce" />

    <link crossorigin="anonymous" href="https://assets-cdn.github.com/assets/github-ceefdafe87b6f218cd93adcaec6a8878ed1f959f7f5937d308b4b0f6b251a7a0.css" media="all" rel="stylesheet" />
    <link crossorigin="anonymous" href="https://assets-cdn.github.com/assets/github2-7048b51d8e88507e1babbe42418137bac3f5ef75f4b1957242327b23ebacd292.css" media="all" rel="stylesheet" />
    
    
    


    <meta http-equiv="x-pjax-version" content="4d4367b1adcd44808937b8e9a8c65f0b">

      
  <meta name="description" content="DAL - KDDart Data Access Layer project">
  <meta name="go-import" content="github.com/kddart/DAL git https://github.com/kddart/DAL.git">

  <meta content="10160855" name="octolytics-dimension-user_id" /><meta content="kddart" name="octolytics-dimension-user_login" /><meta content="28945861" name="octolytics-dimension-repository_id" /><meta content="kddart/DAL" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="28945861" name="octolytics-dimension-repository_network_root_id" /><meta content="kddart/DAL" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/kddart/DAL/commits/master.atom" rel="alternate" title="Recent Commits to DAL:master" type="application/atom+xml">

  </head>


  <body class="logged_in   env-production linux vis-public page-blob">
    <a href="#start-of-content" tabindex="1" class="accessibility-aid js-skip-to-content">Skip to content</a>

    
    
    



      <div class="header header-logged-in true" role="banner">
  <div class="container clearfix">

    <a class="header-logo-invertocat" href="https://github.com/" data-hotkey="g d" aria-label="Homepage" data-ga-click="Header, go to dashboard, icon:logo">
  <span class="mega-octicon octicon-mark-github"></span>
</a>


      <div class="site-search repo-scope js-site-search" role="search">
          <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/kddart/DAL/search" class="js-site-search-form" data-global-search-url="/search" data-repo-search-url="/kddart/DAL/search" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>
  <label class="js-chromeless-input-container form-control">
    <div class="scope-badge">This repository</div>
    <input type="text"
      class="js-site-search-focus js-site-search-field is-clearable chromeless-input"
      data-hotkey="s"
      name="q"
      placeholder="Search"
      aria-label="Search this repository"
      data-global-scope-placeholder="Search GitHub"
      data-repo-scope-placeholder="Search"
      tabindex="1"
      autocapitalize="off">
  </label>
</form>
      </div>

      <ul class="header-nav left" role="navigation">
        <li class="header-nav-item">
          <a href="/pulls" class="js-selected-navigation-item header-nav-link" data-ga-click="Header, click, Nav menu - item:pulls context:user" data-hotkey="g p" data-selected-links="/pulls /pulls/assigned /pulls/mentioned /pulls">
            Pull requests
</a>        </li>
        <li class="header-nav-item">
          <a href="/issues" class="js-selected-navigation-item header-nav-link" data-ga-click="Header, click, Nav menu - item:issues context:user" data-hotkey="g i" data-selected-links="/issues /issues/assigned /issues/mentioned /issues">
            Issues
</a>        </li>
          <li class="header-nav-item">
            <a class="header-nav-link" href="https://gist.github.com/" data-ga-click="Header, go to gist, text:gist">Gist</a>
          </li>
      </ul>

    
<ul class="header-nav user-nav right" id="user-links">
  <li class="header-nav-item">
      <span class="js-socket-channel js-updatable-content"
        data-channel="notification-changed:grzegorz69"
        data-url="/notifications/header">
      <a href="/notifications" aria-label="You have no unread notifications" class="header-nav-link notification-indicator tooltipped tooltipped-s" data-ga-click="Header, go to notifications, icon:read" data-hotkey="g n">
          <span class="mail-status all-read"></span>
          <span class="octicon octicon-bell"></span>
</a>  </span>

  </li>

  <li class="header-nav-item dropdown js-menu-container">
    <a class="header-nav-link tooltipped tooltipped-s js-menu-target" href="/new"
       aria-label="Create new…"
       data-ga-click="Header, create new, icon:add">
      <span class="octicon octicon-plus left"></span>
      <span class="dropdown-caret"></span>
    </a>

    <div class="dropdown-menu-content js-menu-content">
      <ul class="dropdown-menu dropdown-menu-sw">
        
<a class="dropdown-item" href="/new" data-ga-click="Header, create new repository">
  New repository
</a>


  <a class="dropdown-item" href="/organizations/new" data-ga-click="Header, create new organization">
    New organization
  </a>

  <div class="dropdown-divider"></div>
  <div class="dropdown-header">
    <span title="kddart">This organization</span>
  </div>
  <a class="dropdown-item" href="/orgs/kddart/invitations/new" data-ga-click="Header, invite someone">
    Invite someone
  </a>
  <a class="dropdown-item" href="/orgs/kddart/new-team" data-ga-click="Header, create new team">
    New team
  </a>
  <a class="dropdown-item" href="/organizations/kddart/repositories/new" data-ga-click="Header, create new organization repository, icon:repo">
    New repository
  </a>


  <div class="dropdown-divider"></div>
  <div class="dropdown-header">
    <span title="kddart/DAL">This repository</span>
  </div>
    <a class="dropdown-item" href="/kddart/DAL/issues/new" data-ga-click="Header, create new issue">
      New issue
    </a>
    <a class="dropdown-item" href="/kddart/DAL/settings/collaboration" data-ga-click="Header, create new collaborator">
      New collaborator
    </a>

      </ul>
    </div>
  </li>

  <li class="header-nav-item dropdown js-menu-container">
    <a class="header-nav-link name tooltipped tooltipped-s js-menu-target" href="/grzegorz69"
       aria-label="View profile and more"
       data-ga-click="Header, show menu, icon:avatar">
      <img alt="@grzegorz69" class="avatar" height="20" src="https://avatars1.githubusercontent.com/u/7604689?v=3&amp;s=40" width="20" />
      <span class="dropdown-caret"></span>
    </a>

    <div class="dropdown-menu-content js-menu-content">
      <div class="dropdown-menu  dropdown-menu-sw">
        <div class=" dropdown-header header-nav-current-user css-truncate">
            Signed in as <strong class="css-truncate-target">grzegorz69</strong>

        </div>


        <div class="dropdown-divider"></div>

          <a class="dropdown-item" href="/grzegorz69" data-ga-click="Header, go to profile, text:your profile">
            Your profile
          </a>
        <a class="dropdown-item" href="/stars" data-ga-click="Header, go to starred repos, text:your stars">
          Your stars
        </a>
        <a class="dropdown-item" href="/explore" data-ga-click="Header, go to explore, text:explore">
          Explore
        </a>
          <a class="dropdown-item" href="/integrations" data-ga-click="Header, go to integrations, text:integrations">
            Integrations
          </a>
        <a class="dropdown-item" href="https://help.github.com" data-ga-click="Header, go to help, text:help">
          Help
        </a>

          <div class="dropdown-divider"></div>

          <a class="dropdown-item" href="/settings/profile" data-ga-click="Header, go to settings, icon:settings">
            Settings
          </a>

          <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/logout" class="logout-form" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="jPxZiWoCPH7uXG/sc8onMHwOSawwkIuLfoaTa+HssFSmzJHdhSVGq6NKeqa9l2MMKA+mUQSnh1GoUHeltCXyDg==" /></div>
            <button class="dropdown-item dropdown-signout" data-ga-click="Header, sign out, icon:logout">
              Sign out
            </button>
</form>
      </div>
    </div>
  </li>
</ul>


    
  </div>
</div>

      

      


    <div id="start-of-content" class="accessibility-aid"></div>

    <div id="js-flash-container">
</div>


    <div role="main" class="main-content">
        <div itemscope itemtype="http://schema.org/WebPage">
    <div class="pagehead repohead instapaper_ignore readability-menu">

      <div class="container">

        <div class="clearfix">
          

<ul class="pagehead-actions">

  <li>
        <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/notifications/subscribe" class="js-social-container" data-autosubmit="true" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="pZPxXRf8tq+0wUSBtdSctVUEXdpYyOCqxiY/KxlTbWOkJE0rGy7e46U542KkNKH+7dbHO7k6nRLlWjhMlSyKow==" /></div>      <input id="repository_id" name="repository_id" type="hidden" value="28945861" />

        <div class="select-menu js-menu-container js-select-menu">
          <a href="/kddart/DAL/subscription"
            class="btn btn-sm btn-with-count select-menu-button js-menu-target" role="button" tabindex="0" aria-haspopup="true"
            data-ga-click="Repository, click Watch settings, action:blob#show">
            <span class="js-select-button">
              <span class="octicon octicon-eye"></span>
              Unwatch
            </span>
          </a>
          <a class="social-count js-social-count" href="/kddart/DAL/watchers">
            1
          </a>

        <div class="select-menu-modal-holder">
          <div class="select-menu-modal subscription-menu-modal js-menu-content" aria-hidden="true">
            <div class="select-menu-header">
              <span class="octicon octicon-x js-menu-close" role="button" aria-label="Close"></span>
              <span class="select-menu-title">Notifications</span>
            </div>

              <div class="select-menu-list js-navigation-container" role="menu">

                <div class="select-menu-item js-navigation-item " role="menuitem" tabindex="0">
                  <span class="select-menu-item-icon octicon octicon-check"></span>
                  <div class="select-menu-item-text">
                    <input id="do_included" name="do" type="radio" value="included" />
                    <span class="select-menu-item-heading">Not watching</span>
                    <span class="description">Be notified when participating or @mentioned.</span>
                    <span class="js-select-button-text hidden-select-button-text">
                      <span class="octicon octicon-eye"></span>
                      Watch
                    </span>
                  </div>
                </div>

                <div class="select-menu-item js-navigation-item selected" role="menuitem" tabindex="0">
                  <span class="select-menu-item-icon octicon octicon octicon-check"></span>
                  <div class="select-menu-item-text">
                    <input checked="checked" id="do_subscribed" name="do" type="radio" value="subscribed" />
                    <span class="select-menu-item-heading">Watching</span>
                    <span class="description">Be notified of all conversations.</span>
                    <span class="js-select-button-text hidden-select-button-text">
                      <span class="octicon octicon-eye"></span>
                      Unwatch
                    </span>
                  </div>
                </div>

                <div class="select-menu-item js-navigation-item " role="menuitem" tabindex="0">
                  <span class="select-menu-item-icon octicon octicon-check"></span>
                  <div class="select-menu-item-text">
                    <input id="do_ignore" name="do" type="radio" value="ignore" />
                    <span class="select-menu-item-heading">Ignoring</span>
                    <span class="description">Never be notified.</span>
                    <span class="js-select-button-text hidden-select-button-text">
                      <span class="octicon octicon-mute"></span>
                      Stop ignoring
                    </span>
                  </div>
                </div>

              </div>

            </div>
          </div>
        </div>
</form>
  </li>

  <li>
    
  <div class="js-toggler-container js-social-container starring-container on">

    <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/kddart/DAL/unstar" class="js-toggler-form starred js-unstar-button" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="UqQpwTd3tD6h6sTOayHxzA0no7Sse+NBx6eFs7F9BrC4Mt5J7cEXWokNKDu2rDHyVv26phZl1DCAGX5tn/S8NQ==" /></div>
      <button
        class="btn btn-sm btn-with-count js-toggler-target"
        aria-label="Unstar this repository" title="Unstar kddart/DAL"
        data-ga-click="Repository, click unstar button, action:blob#show; text:Unstar">
        <span class="octicon octicon-star"></span>
        Unstar
      </button>
        <a class="social-count js-social-count" href="/kddart/DAL/stargazers">
          1
        </a>
</form>
    <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/kddart/DAL/star" class="js-toggler-form unstarred js-star-button" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="MW+urhnKyuOBU6jW89Wbv9mn4zPoFn/qwnwN/Dmp+46M/YP1xhlY8KxwrVvyqz2lAeMnSkMq0y3aFg6SQ8IEmA==" /></div>
      <button
        class="btn btn-sm btn-with-count js-toggler-target"
        aria-label="Star this repository" title="Star kddart/DAL"
        data-ga-click="Repository, click star button, action:blob#show; text:Star">
        <span class="octicon octicon-star"></span>
        Star
      </button>
        <a class="social-count js-social-count" href="/kddart/DAL/stargazers">
          1
        </a>
</form>  </div>

  </li>

  <li>
          <a href="#fork-destination-box" class="btn btn-sm btn-with-count"
              title="Fork your own copy of kddart/DAL to your account"
              aria-label="Fork your own copy of kddart/DAL to your account"
              rel="facebox"
              data-ga-click="Repository, show fork modal, action:blob#show; text:Fork">
            <span class="octicon octicon-repo-forked"></span>
            Fork
          </a>

          <div id="fork-destination-box" style="display: none;">
            <h2 class="facebox-header" data-facebox-id="facebox-header">Where should we fork this repository?</h2>
            <include-fragment src=""
                class="js-fork-select-fragment fork-select-fragment"
                data-url="/kddart/DAL/fork?fragment=1">
              <img alt="Loading" height="64" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-128.gif" width="64" />
            </include-fragment>
          </div>

    <a href="/kddart/DAL/network" class="social-count">
      0
    </a>
  </li>
</ul>

          <h1 itemscope itemtype="http://data-vocabulary.org/Breadcrumb" class="entry-title public ">
  <span class="mega-octicon octicon-repo"></span>
  <span class="author"><a href="/kddart" class="url fn" itemprop="url" rel="author"><span itemprop="title">kddart</span></a></span><!--
--><span class="path-divider">/</span><!--
--><strong><a href="/kddart/DAL" data-pjax="#js-repo-pjax-container">DAL</a></strong>

  <span class="page-context-loader">
    <img alt="" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
  </span>

</h1>

        </div>
      </div>
    </div>

    <div class="container">
      <div class="repository-with-sidebar repo-container new-discussion-timeline ">
        <div class="repository-sidebar clearfix">
          
<nav class="sunken-menu repo-nav js-repo-nav js-sidenav-container-pjax js-octicon-loaders"
     role="navigation"
     data-pjax="#js-repo-pjax-container"
     data-issue-count-url="/kddart/DAL/issues/counts">
  <ul class="sunken-menu-group">
    <li class="tooltipped tooltipped-w" aria-label="Code">
      <a href="/kddart/DAL" aria-label="Code" aria-selected="true" class="js-selected-navigation-item selected sunken-menu-item" data-hotkey="g c" data-selected-links="repo_source repo_downloads repo_commits repo_releases repo_tags repo_branches /kddart/DAL">
        <span class="octicon octicon-code"></span> <span class="full-word">Code</span>
        <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>    </li>

      <li class="tooltipped tooltipped-w" aria-label="Issues">
        <a href="/kddart/DAL/issues" aria-label="Issues" class="js-selected-navigation-item sunken-menu-item" data-hotkey="g i" data-selected-links="repo_issues repo_labels repo_milestones /kddart/DAL/issues">
          <span class="octicon octicon-issue-opened"></span> <span class="full-word">Issues</span>
          <span class="js-issue-replace-counter"></span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>

    <li class="tooltipped tooltipped-w" aria-label="Pull requests">
      <a href="/kddart/DAL/pulls" aria-label="Pull requests" class="js-selected-navigation-item sunken-menu-item" data-hotkey="g p" data-selected-links="repo_pulls /kddart/DAL/pulls">
          <span class="octicon octicon-git-pull-request"></span> <span class="full-word">Pull requests</span>
          <span class="js-pull-replace-counter"></span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>    </li>

      <li class="tooltipped tooltipped-w" aria-label="Wiki">
        <a href="/kddart/DAL/wiki" aria-label="Wiki" class="js-selected-navigation-item sunken-menu-item" data-hotkey="g w" data-selected-links="repo_wiki /kddart/DAL/wiki">
          <span class="octicon octicon-book"></span> <span class="full-word">Wiki</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
  </ul>
  <div class="sunken-menu-separator"></div>
  <ul class="sunken-menu-group">

    <li class="tooltipped tooltipped-w" aria-label="Pulse">
      <a href="/kddart/DAL/pulse" aria-label="Pulse" class="js-selected-navigation-item sunken-menu-item" data-selected-links="pulse /kddart/DAL/pulse">
        <span class="octicon octicon-pulse"></span> <span class="full-word">Pulse</span>
        <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>    </li>

    <li class="tooltipped tooltipped-w" aria-label="Graphs">
      <a href="/kddart/DAL/graphs" aria-label="Graphs" class="js-selected-navigation-item sunken-menu-item" data-selected-links="repo_graphs repo_contributors /kddart/DAL/graphs">
        <span class="octicon octicon-graph"></span> <span class="full-word">Graphs</span>
        <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>    </li>
  </ul>


    <div class="sunken-menu-separator"></div>
    <ul class="sunken-menu-group">
      <li class="tooltipped tooltipped-w" aria-label="Settings">
        <a href="/kddart/DAL/settings" aria-label="Settings" class="js-selected-navigation-item sunken-menu-item" data-selected-links="repo_settings repo_branch_settings hooks /kddart/DAL/settings">
          <span class="octicon octicon-gear"></span> <span class="full-word">Settings</span>
          <img alt="" class="mini-loader" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32.gif" width="16" />
</a>      </li>
    </ul>
</nav>

            <div class="only-with-full-nav">
                
<div class="js-clone-url clone-url open"
  data-protocol-type="http">
  <h3 class="text-small text-muted"><span class="text-emphasized">HTTPS</span> clone URL</h3>
  <div class="input-group js-zeroclipboard-container">
    <input type="text" class="input-mini text-small text-muted input-monospace js-url-field js-zeroclipboard-target"
           value="https://github.com/kddart/DAL.git" readonly="readonly" aria-label="HTTPS clone URL">
    <span class="input-group-button">
      <button aria-label="Copy to clipboard" class="js-zeroclipboard btn btn-sm zeroclipboard-button tooltipped tooltipped-s" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>

  
<div class="js-clone-url clone-url "
  data-protocol-type="ssh">
  <h3 class="text-small text-muted"><span class="text-emphasized">SSH</span> clone URL</h3>
  <div class="input-group js-zeroclipboard-container">
    <input type="text" class="input-mini text-small text-muted input-monospace js-url-field js-zeroclipboard-target"
           value="git@github.com:kddart/DAL.git" readonly="readonly" aria-label="SSH clone URL">
    <span class="input-group-button">
      <button aria-label="Copy to clipboard" class="js-zeroclipboard btn btn-sm zeroclipboard-button tooltipped tooltipped-s" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>

  
<div class="js-clone-url clone-url "
  data-protocol-type="subversion">
  <h3 class="text-small text-muted"><span class="text-emphasized">Subversion</span> checkout URL</h3>
  <div class="input-group js-zeroclipboard-container">
    <input type="text" class="input-mini text-small text-muted input-monospace js-url-field js-zeroclipboard-target"
           value="https://github.com/kddart/DAL" readonly="readonly" aria-label="Subversion checkout URL">
    <span class="input-group-button">
      <button aria-label="Copy to clipboard" class="js-zeroclipboard btn btn-sm zeroclipboard-button tooltipped tooltipped-s" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </span>
  </div>
</div>



<div class="clone-options text-small text-muted">You can clone with
  <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/users/set_protocol?protocol_selector=http&amp;protocol_type=push" class="inline-form js-clone-selector-form is-enabled" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="OOyOVLUfaarfU7QBPRPiYZun5ylnO8ZF0UOieNrMfmMEmv92MqW43O41+XUtOiECh+ql8hS1/Pu16NJK/70knQ==" /></div><button class="btn-link js-clone-selector" data-protocol="http" type="submit">HTTPS</button></form>, <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/users/set_protocol?protocol_selector=ssh&amp;protocol_type=push" class="inline-form js-clone-selector-form is-enabled" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="93HN7HNQk2fLkeD+Fkw8tChcTDE2/pHGG4CwBt3320f2Hq5s8DTyCwplI33FKR0RkPbn62wxbDCnd70t0CRLKg==" /></div><button class="btn-link js-clone-selector" data-protocol="ssh" type="submit">SSH</button></form>, or <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/users/set_protocol?protocol_selector=subversion&amp;protocol_type=push" class="inline-form js-clone-selector-form is-enabled" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="MOYYaw4VWEPqFJG6rjUALMwBQNon2KiOV7InG9f1Hdol0vsGRDa+T4vm9jifobj/9Q/Rel59U5iL79FaHC1Y+Q==" /></div><button class="btn-link js-clone-selector" data-protocol="subversion" type="submit">Subversion</button></form>.
  <a href="https://help.github.com/articles/which-remote-url-should-i-use" class="help tooltipped tooltipped-n" aria-label="Get help on which URL is right for you.">
    <span class="octicon octicon-question"></span>
  </a>
</div>

              <a href="/kddart/DAL/archive/master.zip"
                 class="btn btn-sm sidebar-button"
                 aria-label="Download the contents of kddart/DAL as a zip file"
                 title="Download the contents of kddart/DAL as a zip file"
                 rel="nofollow">
                <span class="octicon octicon-cloud-download"></span>
                Download ZIP
              </a>
            </div>
        </div>
        <div id="js-repo-pjax-container" class="repository-content context-loader-container" data-pjax-container>

          

<a href="/kddart/DAL/blob/ae9dc10c9e4c41b63b57402a98120ce93c9ebfc9/other/db_files/kddart_dal_v2.2.2.sql" class="hidden js-permalink-shortcut" data-hotkey="y">Permalink</a>

<!-- blob contrib key: blob_contributors:v21:1252de6f35b655ac54b71e33e97b3581 -->

  <div class="file-navigation js-zeroclipboard-container">
    
<div class="select-menu js-menu-container js-select-menu left">
  <button class="btn btn-sm select-menu-button js-menu-target css-truncate" data-hotkey="w"
    title="master"
    type="button" aria-label="Switch branches or tags" tabindex="0" aria-haspopup="true">
    <i>Branch:</i>
    <span class="js-select-button css-truncate-target">master</span>
  </button>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax aria-hidden="true">

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <span class="octicon octicon-x js-menu-close" role="button" aria-label="Close"></span>
        <span class="select-menu-title">Switch branches/tags</span>
      </div>

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Find or create a branch…" id="context-commitish-filter-field" class="js-filterable-field js-navigation-enable" placeholder="Find or create a branch…">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" data-filter-placeholder="Find or create a branch…" class="js-select-menu-tab" role="tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" data-filter-placeholder="Find a tag…" class="js-select-menu-tab" role="tab">Tags</a>
            </li>
          </ul>
        </div>
      </div>

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches" role="menu">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <a class="select-menu-item js-navigation-item js-navigation-open selected"
               href="/kddart/DAL/blob/master/other/db_files/kddart_dal_v2.2.2.sql"
               data-name="master"
               data-skip-pjax="true"
               rel="nofollow">
              <span class="select-menu-item-icon octicon octicon-check"></span>
              <span class="select-menu-item-text css-truncate-target" title="master">
                master
              </span>
            </a>
        </div>

          <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/kddart/DAL/branches" class="js-create-branch select-menu-item select-menu-new-item-form js-navigation-item js-new-item-form" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="5jw2THegVcMAyAf9nBqUDZw/7MroByY1qBkow1MzCNDMeysRgwPCbGShj74TmaCf8yE8XcdK15dyCe7P8kJbuA==" /></div>
            <span class="octicon octicon-git-branch select-menu-item-icon"></span>
            <div class="select-menu-item-text">
              <span class="select-menu-item-heading">Create branch: <span class="js-new-item-name"></span></span>
              <span class="description">from ‘master’</span>
            </div>
            <input type="hidden" name="name" id="name" class="js-new-item-value">
            <input type="hidden" name="branch" id="branch" value="master">
            <input type="hidden" name="path" id="path" value="other/db_files/kddart_dal_v2.2.2.sql">
</form>
      </div>

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div>

    </div>
  </div>
</div>

    <div class="btn-group right">
      <a href="/kddart/DAL/find/master"
            class="js-show-file-finder btn btn-sm empty-icon tooltipped tooltipped-nw"
            data-pjax
            data-hotkey="t"
            aria-label="Quickly jump between files">
        <span class="octicon octicon-list-unordered"></span>
      </a>
      <button aria-label="Copy file path to clipboard" class="js-zeroclipboard btn btn-sm zeroclipboard-button tooltipped tooltipped-s" data-copied-hint="Copied!" type="button"><span class="octicon octicon-clippy"></span></button>
    </div>

    <div class="breadcrumb js-zeroclipboard-target">
      <span class="repo-root js-repo-root"><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/kddart/DAL" class="" data-branch="master" data-pjax="true" itemscope="url"><span itemprop="title">DAL</span></a></span></span><span class="separator">/</span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/kddart/DAL/tree/master/other" class="" data-branch="master" data-pjax="true" itemscope="url"><span itemprop="title">other</span></a></span><span class="separator">/</span><span itemscope="" itemtype="http://data-vocabulary.org/Breadcrumb"><a href="/kddart/DAL/tree/master/other/db_files" class="" data-branch="master" data-pjax="true" itemscope="url"><span itemprop="title">db_files</span></a></span><span class="separator">/</span><strong class="final-path">kddart_dal_v2.2.2.sql</strong>
    </div>
  </div>

<include-fragment class="commit-tease" src="/kddart/DAL/contributors/master/other/db_files/kddart_dal_v2.2.2.sql">
  <div>
    Fetching contributors&hellip;
  </div>

  <div class="commit-tease-contributors">
    <img alt="" class="loader-loading left" height="16" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-32-EAF2F5.gif" width="16" />
    <span class="loader-error">Cannot retrieve contributors at this time</span>
  </div>
</include-fragment>
<div class="file">
  <div class="file-header">
  <div class="file-actions">

    <div class="btn-group">
      <a href="/kddart/DAL/raw/master/other/db_files/kddart_dal_v2.2.2.sql" class="btn btn-sm " id="raw-url">Raw</a>
        <a href="/kddart/DAL/blame/master/other/db_files/kddart_dal_v2.2.2.sql" class="btn btn-sm js-update-url-with-hash">Blame</a>
      <a href="/kddart/DAL/commits/master/other/db_files/kddart_dal_v2.2.2.sql" class="btn btn-sm " rel="nofollow">History</a>
    </div>


        <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/kddart/DAL/edit/master/other/db_files/kddart_dal_v2.2.2.sql" class="inline-form js-update-url-with-hash" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="WsHgdmlhCvr0od8+V4Udj7+efF7bSk4sh38ZRHVy0yJsAT8yFRA7jQPoUmwuyu7E/m1AZQRopTogvi/gJeMcaw==" /></div>
          <button class="octicon-btn tooltipped tooltipped-nw" type="submit"
            aria-label="Edit this file" data-hotkey="e" data-disable-with>
            <span class="octicon octicon-pencil"></span>
          </button>
</form>        <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="/kddart/DAL/delete/master/other/db_files/kddart_dal_v2.2.2.sql" class="inline-form" data-form-nonce="096393ccbbfab2e5a36f5e830a7ff47176042ee8" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="VAi8PMe3rhjozumf8JYZKSzSKPQxOvTQjNYPAoyy6ic0l8ZgngYV5efomaLR1uMyWFaJGZt8ba8jDSllRo+rZw==" /></div>
          <button class="octicon-btn octicon-btn-danger tooltipped tooltipped-nw" type="submit"
            aria-label="Delete this file" data-disable-with>
            <span class="octicon octicon-trashcan"></span>
          </button>
</form>  </div>

  <div class="file-info">
      1668 lines (1514 sloc)
      <span class="file-info-divider"></span>
    85.8 KB
  </div>
</div>

  

  <div class="blob-wrapper data type-sql">
      <table class="highlight tab-size js-file-line-container" data-tab-size="8">
      <tr>
        <td id="L1" class="blob-num js-line-number" data-line-number="1"></td>
        <td id="LC1" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- MySQL dump 10.11</span></td>
      </tr>
      <tr>
        <td id="L2" class="blob-num js-line-number" data-line-number="2"></td>
        <td id="LC2" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L3" class="blob-num js-line-number" data-line-number="3"></td>
        <td id="LC3" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Host: localhost    Database: kddart_v2_2_2</span></td>
      </tr>
      <tr>
        <td id="L4" class="blob-num js-line-number" data-line-number="4"></td>
        <td id="LC4" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- ------------------------------------------------------</span></td>
      </tr>
      <tr>
        <td id="L5" class="blob-num js-line-number" data-line-number="5"></td>
        <td id="LC5" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Server version	5.0.67</span></td>
      </tr>
      <tr>
        <td id="L6" class="blob-num js-line-number" data-line-number="6"></td>
        <td id="LC6" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L7" class="blob-num js-line-number" data-line-number="7"></td>
        <td id="LC7" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Copyright (C) 2014 by Diversity Arrays Technology Pty Ltd</span></td>
      </tr>
      <tr>
        <td id="L8" class="blob-num js-line-number" data-line-number="8"></td>
        <td id="LC8" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- </span></td>
      </tr>
      <tr>
        <td id="L9" class="blob-num js-line-number" data-line-number="9"></td>
        <td id="LC9" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- This program is free software: you can redistribute it and/or modify</span></td>
      </tr>
      <tr>
        <td id="L10" class="blob-num js-line-number" data-line-number="10"></td>
        <td id="LC10" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- it under the terms of the GNU General Public License as published by</span></td>
      </tr>
      <tr>
        <td id="L11" class="blob-num js-line-number" data-line-number="11"></td>
        <td id="LC11" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- the Free Software Foundation, either version 3 of the License, or</span></td>
      </tr>
      <tr>
        <td id="L12" class="blob-num js-line-number" data-line-number="12"></td>
        <td id="LC12" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- (at your option) any later version.</span></td>
      </tr>
      <tr>
        <td id="L13" class="blob-num js-line-number" data-line-number="13"></td>
        <td id="LC13" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- </span></td>
      </tr>
      <tr>
        <td id="L14" class="blob-num js-line-number" data-line-number="14"></td>
        <td id="LC14" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- This program is distributed in the hope that it will be useful,</span></td>
      </tr>
      <tr>
        <td id="L15" class="blob-num js-line-number" data-line-number="15"></td>
        <td id="LC15" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- but WITHOUT ANY WARRANTY; without even the implied warranty of</span></td>
      </tr>
      <tr>
        <td id="L16" class="blob-num js-line-number" data-line-number="16"></td>
        <td id="LC16" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the</span></td>
      </tr>
      <tr>
        <td id="L17" class="blob-num js-line-number" data-line-number="17"></td>
        <td id="LC17" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- GNU General Public License for more details.</span></td>
      </tr>
      <tr>
        <td id="L18" class="blob-num js-line-number" data-line-number="18"></td>
        <td id="LC18" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L19" class="blob-num js-line-number" data-line-number="19"></td>
        <td id="LC19" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */</span>;</td>
      </tr>
      <tr>
        <td id="L20" class="blob-num js-line-number" data-line-number="20"></td>
        <td id="LC20" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */</span>;</td>
      </tr>
      <tr>
        <td id="L21" class="blob-num js-line-number" data-line-number="21"></td>
        <td id="LC21" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */</span>;</td>
      </tr>
      <tr>
        <td id="L22" class="blob-num js-line-number" data-line-number="22"></td>
        <td id="LC22" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40101 SET NAMES utf8 */</span>;</td>
      </tr>
      <tr>
        <td id="L23" class="blob-num js-line-number" data-line-number="23"></td>
        <td id="LC23" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */</span>;</td>
      </tr>
      <tr>
        <td id="L24" class="blob-num js-line-number" data-line-number="24"></td>
        <td id="LC24" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40103 SET TIME_ZONE=&#39;+00:00&#39; */</span>;</td>
      </tr>
      <tr>
        <td id="L25" class="blob-num js-line-number" data-line-number="25"></td>
        <td id="LC25" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */</span>;</td>
      </tr>
      <tr>
        <td id="L26" class="blob-num js-line-number" data-line-number="26"></td>
        <td id="LC26" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */</span>;</td>
      </tr>
      <tr>
        <td id="L27" class="blob-num js-line-number" data-line-number="27"></td>
        <td id="LC27" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE=&#39;NO_AUTO_VALUE_ON_ZERO&#39; */</span>;</td>
      </tr>
      <tr>
        <td id="L28" class="blob-num js-line-number" data-line-number="28"></td>
        <td id="LC28" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */</span>;</td>
      </tr>
      <tr>
        <td id="L29" class="blob-num js-line-number" data-line-number="29"></td>
        <td id="LC29" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L30" class="blob-num js-line-number" data-line-number="30"></td>
        <td id="LC30" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L31" class="blob-num js-line-number" data-line-number="31"></td>
        <td id="LC31" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `activitylog`</span></td>
      </tr>
      <tr>
        <td id="L32" class="blob-num js-line-number" data-line-number="32"></td>
        <td id="LC32" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L33" class="blob-num js-line-number" data-line-number="33"></td>
        <td id="LC33" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L34" class="blob-num js-line-number" data-line-number="34"></td>
        <td id="LC34" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>activitylog<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L35" class="blob-num js-line-number" data-line-number="35"></td>
        <td id="LC35" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L36" class="blob-num js-line-number" data-line-number="36"></td>
        <td id="LC36" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L37" class="blob-num js-line-number" data-line-number="37"></td>
        <td id="LC37" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">activitylog</span>` (</td>
      </tr>
      <tr>
        <td id="L38" class="blob-num js-line-number" data-line-number="38"></td>
        <td id="LC38" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ActivityLogId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>activity log id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L39" class="blob-num js-line-number" data-line-number="39"></td>
        <td id="LC39" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>user id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L40" class="blob-num js-line-number" data-line-number="40"></td>
        <td id="LC40" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ActivityDateTime<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date time of the activity<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L41" class="blob-num js-line-number" data-line-number="41"></td>
        <td id="LC41" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ActivityLevel<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Logout=2,Incorrect Password=3, Edit=101,Delete=102<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L42" class="blob-num js-line-number" data-line-number="42"></td>
        <td id="LC42" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ActivityText<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>description of activity<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L43" class="blob-num js-line-number" data-line-number="43"></td>
        <td id="LC43" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ActivityLogId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L44" class="blob-num js-line-number" data-line-number="44"></td>
        <td id="LC44" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xal_UserId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L45" class="blob-num js-line-number" data-line-number="45"></td>
        <td id="LC45" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>activitylog_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>systemuser<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L46" class="blob-num js-line-number" data-line-number="46"></td>
        <td id="LC46" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L47" class="blob-num js-line-number" data-line-number="47"></td>
        <td id="LC47" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L48" class="blob-num js-line-number" data-line-number="48"></td>
        <td id="LC48" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L49" class="blob-num js-line-number" data-line-number="49"></td>
        <td id="LC49" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L50" class="blob-num js-line-number" data-line-number="50"></td>
        <td id="LC50" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `authorisedsystemgroup`</span></td>
      </tr>
      <tr>
        <td id="L51" class="blob-num js-line-number" data-line-number="51"></td>
        <td id="LC51" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L52" class="blob-num js-line-number" data-line-number="52"></td>
        <td id="LC52" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L53" class="blob-num js-line-number" data-line-number="53"></td>
        <td id="LC53" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>authorisedsystemgroup<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L54" class="blob-num js-line-number" data-line-number="54"></td>
        <td id="LC54" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L55" class="blob-num js-line-number" data-line-number="55"></td>
        <td id="LC55" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L56" class="blob-num js-line-number" data-line-number="56"></td>
        <td id="LC56" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">authorisedsystemgroup</span>` (</td>
      </tr>
      <tr>
        <td id="L57" class="blob-num js-line-number" data-line-number="57"></td>
        <td id="LC57" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AuthorisedSystemGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>authorised system group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L58" class="blob-num js-line-number" data-line-number="58"></td>
        <td id="LC58" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>user id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L59" class="blob-num js-line-number" data-line-number="59"></td>
        <td id="LC59" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SystemGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>system group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L60" class="blob-num js-line-number" data-line-number="60"></td>
        <td id="LC60" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>IsGroupOwner<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>flag [0|1] if the user group owner.<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L61" class="blob-num js-line-number" data-line-number="61"></td>
        <td id="LC61" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>AuthorisedSystemGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L62" class="blob-num js-line-number" data-line-number="62"></td>
        <td id="LC62" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xasg_UserId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L63" class="blob-num js-line-number" data-line-number="63"></td>
        <td id="LC63" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xasg_SystemGroupId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SystemGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L64" class="blob-num js-line-number" data-line-number="64"></td>
        <td id="LC64" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xasg_IsGroupOwner<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>IsGroupOwner<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L65" class="blob-num js-line-number" data-line-number="65"></td>
        <td id="LC65" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>authorisedsystemgroup_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SystemGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>systemgroup<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SystemGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L66" class="blob-num js-line-number" data-line-number="66"></td>
        <td id="LC66" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>authorisedsystemgroup_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>systemuser<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L67" class="blob-num js-line-number" data-line-number="67"></td>
        <td id="LC67" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L68" class="blob-num js-line-number" data-line-number="68"></td>
        <td id="LC68" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L69" class="blob-num js-line-number" data-line-number="69"></td>
        <td id="LC69" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L70" class="blob-num js-line-number" data-line-number="70"></td>
        <td id="LC70" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L71" class="blob-num js-line-number" data-line-number="71"></td>
        <td id="LC71" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `barcodeconf`</span></td>
      </tr>
      <tr>
        <td id="L72" class="blob-num js-line-number" data-line-number="72"></td>
        <td id="LC72" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L73" class="blob-num js-line-number" data-line-number="73"></td>
        <td id="LC73" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L74" class="blob-num js-line-number" data-line-number="74"></td>
        <td id="LC74" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>barcodeconf<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L75" class="blob-num js-line-number" data-line-number="75"></td>
        <td id="LC75" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L76" class="blob-num js-line-number" data-line-number="76"></td>
        <td id="LC76" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L77" class="blob-num js-line-number" data-line-number="77"></td>
        <td id="LC77" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">barcodeconf</span>` (</td>
      </tr>
      <tr>
        <td id="L78" class="blob-num js-line-number" data-line-number="78"></td>
        <td id="LC78" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>BarcodeConfId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>configuration id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L79" class="blob-num js-line-number" data-line-number="79"></td>
        <td id="LC79" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SystemTable<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>configuration is for this table in the system<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L80" class="blob-num js-line-number" data-line-number="80"></td>
        <td id="LC80" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SystemField<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>configuration is for this field (in the SystemTable)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L81" class="blob-num js-line-number" data-line-number="81"></td>
        <td id="LC81" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>BarcodeCode<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">12</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Name of barcode system (e.g. EAN13, Code39, QR, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L82" class="blob-num js-line-number" data-line-number="82"></td>
        <td id="LC82" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>BarcodeDef<span class="pl-pds">`</span></span> mediumtext <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>String with barcode definition<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L83" class="blob-num js-line-number" data-line-number="83"></td>
        <td id="LC83" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>BarcodeConfId<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L84" class="blob-num js-line-number" data-line-number="84"></td>
        <td id="LC84" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L85" class="blob-num js-line-number" data-line-number="85"></td>
        <td id="LC85" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L86" class="blob-num js-line-number" data-line-number="86"></td>
        <td id="LC86" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L87" class="blob-num js-line-number" data-line-number="87"></td>
        <td id="LC87" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L88" class="blob-num js-line-number" data-line-number="88"></td>
        <td id="LC88" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `breedingmethod`</span></td>
      </tr>
      <tr>
        <td id="L89" class="blob-num js-line-number" data-line-number="89"></td>
        <td id="LC89" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L90" class="blob-num js-line-number" data-line-number="90"></td>
        <td id="LC90" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L91" class="blob-num js-line-number" data-line-number="91"></td>
        <td id="LC91" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>breedingmethod<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L92" class="blob-num js-line-number" data-line-number="92"></td>
        <td id="LC92" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L93" class="blob-num js-line-number" data-line-number="93"></td>
        <td id="LC93" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L94" class="blob-num js-line-number" data-line-number="94"></td>
        <td id="LC94" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">breedingmethod</span>` (</td>
      </tr>
      <tr>
        <td id="L95" class="blob-num js-line-number" data-line-number="95"></td>
        <td id="LC95" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>internal id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L96" class="blob-num js-line-number" data-line-number="96"></td>
        <td id="LC96" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>BreedingMethodName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">100</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>breeding method name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L97" class="blob-num js-line-number" data-line-number="97"></td>
        <td id="LC97" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>BreedingMethodNote<span class="pl-pds">`</span></span> mediumtext COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>breeding method short description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L98" class="blob-num js-line-number" data-line-number="98"></td>
        <td id="LC98" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L99" class="blob-num js-line-number" data-line-number="99"></td>
        <td id="LC99" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L100" class="blob-num js-line-number" data-line-number="100"></td>
        <td id="LC100" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L101" class="blob-num js-line-number" data-line-number="101"></td>
        <td id="LC101" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L102" class="blob-num js-line-number" data-line-number="102"></td>
        <td id="LC102" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L103" class="blob-num js-line-number" data-line-number="103"></td>
        <td id="LC103" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `breedingmethodfactor`</span></td>
      </tr>
      <tr>
        <td id="L104" class="blob-num js-line-number" data-line-number="104"></td>
        <td id="LC104" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L105" class="blob-num js-line-number" data-line-number="105"></td>
        <td id="LC105" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L106" class="blob-num js-line-number" data-line-number="106"></td>
        <td id="LC106" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>breedingmethodfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L107" class="blob-num js-line-number" data-line-number="107"></td>
        <td id="LC107" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L108" class="blob-num js-line-number" data-line-number="108"></td>
        <td id="LC108" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L109" class="blob-num js-line-number" data-line-number="109"></td>
        <td id="LC109" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">breedingmethodfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L110" class="blob-num js-line-number" data-line-number="110"></td>
        <td id="LC110" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Breeding method id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L111" class="blob-num js-line-number" data-line-number="111"></td>
        <td id="LC111" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L112" class="blob-num js-line-number" data-line-number="112"></td>
        <td id="LC112" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Value of the virtual column for Breeding Method<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L113" class="blob-num js-line-number" data-line-number="113"></td>
        <td id="LC113" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L114" class="blob-num js-line-number" data-line-number="114"></td>
        <td id="LC114" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L115" class="blob-num js-line-number" data-line-number="115"></td>
        <td id="LC115" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>breedingmethodfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L116" class="blob-num js-line-number" data-line-number="116"></td>
        <td id="LC116" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>breedingmethodfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>breedingmethod<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L117" class="blob-num js-line-number" data-line-number="117"></td>
        <td id="LC117" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L118" class="blob-num js-line-number" data-line-number="118"></td>
        <td id="LC118" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L119" class="blob-num js-line-number" data-line-number="119"></td>
        <td id="LC119" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L120" class="blob-num js-line-number" data-line-number="120"></td>
        <td id="LC120" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L121" class="blob-num js-line-number" data-line-number="121"></td>
        <td id="LC121" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `contact`</span></td>
      </tr>
      <tr>
        <td id="L122" class="blob-num js-line-number" data-line-number="122"></td>
        <td id="LC122" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L123" class="blob-num js-line-number" data-line-number="123"></td>
        <td id="LC123" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L124" class="blob-num js-line-number" data-line-number="124"></td>
        <td id="LC124" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>contact<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L125" class="blob-num js-line-number" data-line-number="125"></td>
        <td id="LC125" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L126" class="blob-num js-line-number" data-line-number="126"></td>
        <td id="LC126" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L127" class="blob-num js-line-number" data-line-number="127"></td>
        <td id="LC127" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">contact</span>` (</td>
      </tr>
      <tr>
        <td id="L128" class="blob-num js-line-number" data-line-number="128"></td>
        <td id="LC128" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>contact id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L129" class="blob-num js-line-number" data-line-number="129"></td>
        <td id="LC129" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactLastName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>last name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L130" class="blob-num js-line-number" data-line-number="130"></td>
        <td id="LC130" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactFirstName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>first name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L131" class="blob-num js-line-number" data-line-number="131"></td>
        <td id="LC131" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactAcronym<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>acronym<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L132" class="blob-num js-line-number" data-line-number="132"></td>
        <td id="LC132" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactAddress<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">128</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>address<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L133" class="blob-num js-line-number" data-line-number="133"></td>
        <td id="LC133" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactTelephone<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">14</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>phone number<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L134" class="blob-num js-line-number" data-line-number="134"></td>
        <td id="LC134" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactMobile<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">14</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>mobile number<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L135" class="blob-num js-line-number" data-line-number="135"></td>
        <td id="LC135" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactEMail<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>e-mail<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L136" class="blob-num js-line-number" data-line-number="136"></td>
        <td id="LC136" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>organisation id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L137" class="blob-num js-line-number" data-line-number="137"></td>
        <td id="LC137" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L138" class="blob-num js-line-number" data-line-number="138"></td>
        <td id="LC138" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xc_LastFirstName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactLastName<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>ContactFirstName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L139" class="blob-num js-line-number" data-line-number="139"></td>
        <td id="LC139" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xc_OrganisationId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L140" class="blob-num js-line-number" data-line-number="140"></td>
        <td id="LC140" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xc_ContactEMail<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactEMail<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L141" class="blob-num js-line-number" data-line-number="141"></td>
        <td id="LC141" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>contact_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>organisation<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L142" class="blob-num js-line-number" data-line-number="142"></td>
        <td id="LC142" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L143" class="blob-num js-line-number" data-line-number="143"></td>
        <td id="LC143" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L144" class="blob-num js-line-number" data-line-number="144"></td>
        <td id="LC144" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L145" class="blob-num js-line-number" data-line-number="145"></td>
        <td id="LC145" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L146" class="blob-num js-line-number" data-line-number="146"></td>
        <td id="LC146" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `contactfactor`</span></td>
      </tr>
      <tr>
        <td id="L147" class="blob-num js-line-number" data-line-number="147"></td>
        <td id="LC147" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L148" class="blob-num js-line-number" data-line-number="148"></td>
        <td id="LC148" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L149" class="blob-num js-line-number" data-line-number="149"></td>
        <td id="LC149" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>contactfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L150" class="blob-num js-line-number" data-line-number="150"></td>
        <td id="LC150" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L151" class="blob-num js-line-number" data-line-number="151"></td>
        <td id="LC151" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L152" class="blob-num js-line-number" data-line-number="152"></td>
        <td id="LC152" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">contactfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L153" class="blob-num js-line-number" data-line-number="153"></td>
        <td id="LC153" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>contact id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L154" class="blob-num js-line-number" data-line-number="154"></td>
        <td id="LC154" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L155" class="blob-num js-line-number" data-line-number="155"></td>
        <td id="LC155" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L156" class="blob-num js-line-number" data-line-number="156"></td>
        <td id="LC156" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L157" class="blob-num js-line-number" data-line-number="157"></td>
        <td id="LC157" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L158" class="blob-num js-line-number" data-line-number="158"></td>
        <td id="LC158" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>contactfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>contact<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L159" class="blob-num js-line-number" data-line-number="159"></td>
        <td id="LC159" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>contactfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L160" class="blob-num js-line-number" data-line-number="160"></td>
        <td id="LC160" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L161" class="blob-num js-line-number" data-line-number="161"></td>
        <td id="LC161" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L162" class="blob-num js-line-number" data-line-number="162"></td>
        <td id="LC162" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L163" class="blob-num js-line-number" data-line-number="163"></td>
        <td id="LC163" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L164" class="blob-num js-line-number" data-line-number="164"></td>
        <td id="LC164" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `designtype`</span></td>
      </tr>
      <tr>
        <td id="L165" class="blob-num js-line-number" data-line-number="165"></td>
        <td id="LC165" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L166" class="blob-num js-line-number" data-line-number="166"></td>
        <td id="LC166" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L167" class="blob-num js-line-number" data-line-number="167"></td>
        <td id="LC167" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>designtype<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L168" class="blob-num js-line-number" data-line-number="168"></td>
        <td id="LC168" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L169" class="blob-num js-line-number" data-line-number="169"></td>
        <td id="LC169" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L170" class="blob-num js-line-number" data-line-number="170"></td>
        <td id="LC170" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">designtype</span>` (</td>
      </tr>
      <tr>
        <td id="L171" class="blob-num js-line-number" data-line-number="171"></td>
        <td id="LC171" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DesignTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>design type id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L172" class="blob-num js-line-number" data-line-number="172"></td>
        <td id="LC172" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DesignTypeName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>design type name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L173" class="blob-num js-line-number" data-line-number="173"></td>
        <td id="LC173" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DesignSoftware<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>The executable file of the Software (such as DiGGer) that is used to design the trial of this design type.<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L174" class="blob-num js-line-number" data-line-number="174"></td>
        <td id="LC174" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DesignTemplateFile<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>The template file defines how the parameter are required to be inserted in the input file for the design software.<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L175" class="blob-num js-line-number" data-line-number="175"></td>
        <td id="LC175" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DesignGenotypeFormat<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Format in which the Specimen Name and Specimen Id will be exported into the trial design input file.<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L176" class="blob-num js-line-number" data-line-number="176"></td>
        <td id="LC176" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DesignFactorAliasPrefix<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">16</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Prefix that will be used to find the factor for the Trial Design Parameter while importing trial design from the output file generated by the trial design software (such as DiGGer).<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L177" class="blob-num js-line-number" data-line-number="177"></td>
        <td id="LC177" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>DesignTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L178" class="blob-num js-line-number" data-line-number="178"></td>
        <td id="LC178" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xdt_DesignTypeName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>DesignTypeName<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L179" class="blob-num js-line-number" data-line-number="179"></td>
        <td id="LC179" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L180" class="blob-num js-line-number" data-line-number="180"></td>
        <td id="LC180" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L181" class="blob-num js-line-number" data-line-number="181"></td>
        <td id="LC181" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L182" class="blob-num js-line-number" data-line-number="182"></td>
        <td id="LC182" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L183" class="blob-num js-line-number" data-line-number="183"></td>
        <td id="LC183" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `deviceregister`</span></td>
      </tr>
      <tr>
        <td id="L184" class="blob-num js-line-number" data-line-number="184"></td>
        <td id="LC184" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L185" class="blob-num js-line-number" data-line-number="185"></td>
        <td id="LC185" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L186" class="blob-num js-line-number" data-line-number="186"></td>
        <td id="LC186" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>deviceregister<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L187" class="blob-num js-line-number" data-line-number="187"></td>
        <td id="LC187" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L188" class="blob-num js-line-number" data-line-number="188"></td>
        <td id="LC188" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L189" class="blob-num js-line-number" data-line-number="189"></td>
        <td id="LC189" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">deviceregister</span>` (</td>
      </tr>
      <tr>
        <td id="L190" class="blob-num js-line-number" data-line-number="190"></td>
        <td id="LC190" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DeviceRegisterId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Internal id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L191" class="blob-num js-line-number" data-line-number="191"></td>
        <td id="LC191" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DeviceTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>device type id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L192" class="blob-num js-line-number" data-line-number="192"></td>
        <td id="LC192" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DeviceId<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">100</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Unique device name / id under which it is registered in database<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L193" class="blob-num js-line-number" data-line-number="193"></td>
        <td id="LC193" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DeviceNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Description of the device<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L194" class="blob-num js-line-number" data-line-number="194"></td>
        <td id="LC194" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Latitude<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">14</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Latitude of the device in decimal degrees (-90, 90)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L195" class="blob-num js-line-number" data-line-number="195"></td>
        <td id="LC195" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Longitude<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">13</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Longitude of the device in decimal degrees (-180, 180)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L196" class="blob-num js-line-number" data-line-number="196"></td>
        <td id="LC196" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>DeviceRegisterId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L197" class="blob-num js-line-number" data-line-number="197"></td>
        <td id="LC197" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xdr_DeviceId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>DeviceId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L198" class="blob-num js-line-number" data-line-number="198"></td>
        <td id="LC198" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xdr_DeviceTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>DeviceTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L199" class="blob-num js-line-number" data-line-number="199"></td>
        <td id="LC199" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>deviceregister_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>DeviceTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L200" class="blob-num js-line-number" data-line-number="200"></td>
        <td id="LC200" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L201" class="blob-num js-line-number" data-line-number="201"></td>
        <td id="LC201" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L202" class="blob-num js-line-number" data-line-number="202"></td>
        <td id="LC202" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L203" class="blob-num js-line-number" data-line-number="203"></td>
        <td id="LC203" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L204" class="blob-num js-line-number" data-line-number="204"></td>
        <td id="LC204" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `deviceregisterfactor`</span></td>
      </tr>
      <tr>
        <td id="L205" class="blob-num js-line-number" data-line-number="205"></td>
        <td id="LC205" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L206" class="blob-num js-line-number" data-line-number="206"></td>
        <td id="LC206" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L207" class="blob-num js-line-number" data-line-number="207"></td>
        <td id="LC207" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>deviceregisterfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L208" class="blob-num js-line-number" data-line-number="208"></td>
        <td id="LC208" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L209" class="blob-num js-line-number" data-line-number="209"></td>
        <td id="LC209" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L210" class="blob-num js-line-number" data-line-number="210"></td>
        <td id="LC210" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">deviceregisterfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L211" class="blob-num js-line-number" data-line-number="211"></td>
        <td id="LC211" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DeviceRegisterId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>device register id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L212" class="blob-num js-line-number" data-line-number="212"></td>
        <td id="LC212" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>virtual column id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L213" class="blob-num js-line-number" data-line-number="213"></td>
        <td id="LC213" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value for column and device id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L214" class="blob-num js-line-number" data-line-number="214"></td>
        <td id="LC214" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>DeviceRegisterId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L215" class="blob-num js-line-number" data-line-number="215"></td>
        <td id="LC215" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L216" class="blob-num js-line-number" data-line-number="216"></td>
        <td id="LC216" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>deviceregisterfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>DeviceRegisterId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>deviceregister<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>DeviceRegisterId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L217" class="blob-num js-line-number" data-line-number="217"></td>
        <td id="LC217" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>deviceregisterfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L218" class="blob-num js-line-number" data-line-number="218"></td>
        <td id="LC218" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L219" class="blob-num js-line-number" data-line-number="219"></td>
        <td id="LC219" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L220" class="blob-num js-line-number" data-line-number="220"></td>
        <td id="LC220" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L221" class="blob-num js-line-number" data-line-number="221"></td>
        <td id="LC221" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L222" class="blob-num js-line-number" data-line-number="222"></td>
        <td id="LC222" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `factor`</span></td>
      </tr>
      <tr>
        <td id="L223" class="blob-num js-line-number" data-line-number="223"></td>
        <td id="LC223" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L224" class="blob-num js-line-number" data-line-number="224"></td>
        <td id="LC224" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L225" class="blob-num js-line-number" data-line-number="225"></td>
        <td id="LC225" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L226" class="blob-num js-line-number" data-line-number="226"></td>
        <td id="LC226" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L227" class="blob-num js-line-number" data-line-number="227"></td>
        <td id="LC227" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L228" class="blob-num js-line-number" data-line-number="228"></td>
        <td id="LC228" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">factor</span>` (</td>
      </tr>
      <tr>
        <td id="L229" class="blob-num js-line-number" data-line-number="229"></td>
        <td id="LC229" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L230" class="blob-num js-line-number" data-line-number="230"></td>
        <td id="LC230" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>column name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L231" class="blob-num js-line-number" data-line-number="231"></td>
        <td id="LC231" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorCaption<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>caption (shorter version of name)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L232" class="blob-num js-line-number" data-line-number="232"></td>
        <td id="LC232" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorDescription<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>what is stored in the column<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L233" class="blob-num js-line-number" data-line-number="233"></td>
        <td id="LC233" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TableNameOfFactor<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>which main table this factor refers to<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L234" class="blob-num js-line-number" data-line-number="234"></td>
        <td id="LC234" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorDataType<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">8</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>data type (e.g. VARCHAR)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L235" class="blob-num js-line-number" data-line-number="235"></td>
        <td id="LC235" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>CanFactorHaveNull<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">1</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>can value be null (0|1)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L236" class="blob-num js-line-number" data-line-number="236"></td>
        <td id="LC236" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValueMaxLength<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>maximum size of value (e.g. 256) refers to the maximum length of FactorValue is VARCHAR in the factor data table like contactfactor<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L237" class="blob-num js-line-number" data-line-number="237"></td>
        <td id="LC237" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorUnit<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">16</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value unit (e.g. kg, meters, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L238" class="blob-num js-line-number" data-line-number="238"></td>
        <td id="LC238" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>the group that owns this virtual column definition<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L239" class="blob-num js-line-number" data-line-number="239"></td>
        <td id="LC239" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Public<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>if public=1, it means other group administrators can edit and delete this definition<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L240" class="blob-num js-line-number" data-line-number="240"></td>
        <td id="LC240" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValidRule<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">100</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor value validation rule (optional)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L241" class="blob-num js-line-number" data-line-number="241"></td>
        <td id="LC241" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValidRuleErrMsg<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>error message if value does not conform to validation rule<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L242" class="blob-num js-line-number" data-line-number="242"></td>
        <td id="LC242" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L243" class="blob-num js-line-number" data-line-number="243"></td>
        <td id="LC243" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xf_FactorName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L244" class="blob-num js-line-number" data-line-number="244"></td>
        <td id="LC244" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xf_FactorCaption<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorCaption<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L245" class="blob-num js-line-number" data-line-number="245"></td>
        <td id="LC245" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xf_TableNameOfFactor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TableNameOfFactor<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L246" class="blob-num js-line-number" data-line-number="246"></td>
        <td id="LC246" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L247" class="blob-num js-line-number" data-line-number="247"></td>
        <td id="LC247" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L248" class="blob-num js-line-number" data-line-number="248"></td>
        <td id="LC248" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L249" class="blob-num js-line-number" data-line-number="249"></td>
        <td id="LC249" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L250" class="blob-num js-line-number" data-line-number="250"></td>
        <td id="LC250" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `factoralias`</span></td>
      </tr>
      <tr>
        <td id="L251" class="blob-num js-line-number" data-line-number="251"></td>
        <td id="LC251" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L252" class="blob-num js-line-number" data-line-number="252"></td>
        <td id="LC252" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L253" class="blob-num js-line-number" data-line-number="253"></td>
        <td id="LC253" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>factoralias<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L254" class="blob-num js-line-number" data-line-number="254"></td>
        <td id="LC254" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L255" class="blob-num js-line-number" data-line-number="255"></td>
        <td id="LC255" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L256" class="blob-num js-line-number" data-line-number="256"></td>
        <td id="LC256" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">factoralias</span>` (</td>
      </tr>
      <tr>
        <td id="L257" class="blob-num js-line-number" data-line-number="257"></td>
        <td id="LC257" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorAliasId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factoralias id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L258" class="blob-num js-line-number" data-line-number="258"></td>
        <td id="LC258" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorAliasName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>alternative name of the factor<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L259" class="blob-num js-line-number" data-line-number="259"></td>
        <td id="LC259" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L260" class="blob-num js-line-number" data-line-number="260"></td>
        <td id="LC260" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>FactorAliasId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L261" class="blob-num js-line-number" data-line-number="261"></td>
        <td id="LC261" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xfa_FactorAliasName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorAliasName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L262" class="blob-num js-line-number" data-line-number="262"></td>
        <td id="LC262" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xfa_FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L263" class="blob-num js-line-number" data-line-number="263"></td>
        <td id="LC263" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>factoralias_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L264" class="blob-num js-line-number" data-line-number="264"></td>
        <td id="LC264" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L265" class="blob-num js-line-number" data-line-number="265"></td>
        <td id="LC265" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L266" class="blob-num js-line-number" data-line-number="266"></td>
        <td id="LC266" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L267" class="blob-num js-line-number" data-line-number="267"></td>
        <td id="LC267" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L268" class="blob-num js-line-number" data-line-number="268"></td>
        <td id="LC268" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `generaltype`</span></td>
      </tr>
      <tr>
        <td id="L269" class="blob-num js-line-number" data-line-number="269"></td>
        <td id="LC269" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L270" class="blob-num js-line-number" data-line-number="270"></td>
        <td id="LC270" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L271" class="blob-num js-line-number" data-line-number="271"></td>
        <td id="LC271" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L272" class="blob-num js-line-number" data-line-number="272"></td>
        <td id="LC272" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L273" class="blob-num js-line-number" data-line-number="273"></td>
        <td id="LC273" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L274" class="blob-num js-line-number" data-line-number="274"></td>
        <td id="LC274" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">generaltype</span>` (</td>
      </tr>
      <tr>
        <td id="L275" class="blob-num js-line-number" data-line-number="275"></td>
        <td id="LC275" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>general type id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L276" class="blob-num js-line-number" data-line-number="276"></td>
        <td id="LC276" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Class<span class="pl-pds">`</span></span> <span class="pl-k">set</span>(<span class="pl-s"><span class="pl-pds">&#39;</span>site<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>item<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>container<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>deviceregister<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>trial<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>trialevent<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>sample<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>specimengroup<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>state<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>parent<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>itemparent<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>genotypespecimen<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>markerstate<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>markerquality<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>workflow<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>project<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>itemlog<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>plate<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>genmap<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>multimedia<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>tissue<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>genotypealias<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>genparent<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>genotypealiasstatus<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>traitgroup<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>unittype<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>multilocation<span class="pl-pds">&#39;</span></span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>class of type - possible values (site, item, container, deviceregister, trial, operation, sample, specimengroup, state, parent, itemparent, genotypespecimen, markerstate, markerquality, workflow, project, itemlog, plate, genmap, multimedia, tissue, genoty<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L277" class="blob-num js-line-number" data-line-number="277"></td>
        <td id="LC277" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TypeName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">100</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>name of the type within notation<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L278" class="blob-num js-line-number" data-line-number="278"></td>
        <td id="LC278" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TypeNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>type description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L279" class="blob-num js-line-number" data-line-number="279"></td>
        <td id="LC279" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>IsTypeActive<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">1</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>1<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>0|1 flag to indicate if type is active (can be used)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L280" class="blob-num js-line-number" data-line-number="280"></td>
        <td id="LC280" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L281" class="blob-num js-line-number" data-line-number="281"></td>
        <td id="LC281" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xgt_ClassTypeName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>Class<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>TypeName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L282" class="blob-num js-line-number" data-line-number="282"></td>
        <td id="LC282" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgt_TypeName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L283" class="blob-num js-line-number" data-line-number="283"></td>
        <td id="LC283" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgt_IsTypeActive<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>IsTypeActive<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L284" class="blob-num js-line-number" data-line-number="284"></td>
        <td id="LC284" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L285" class="blob-num js-line-number" data-line-number="285"></td>
        <td id="LC285" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L286" class="blob-num js-line-number" data-line-number="286"></td>
        <td id="LC286" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L287" class="blob-num js-line-number" data-line-number="287"></td>
        <td id="LC287" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L288" class="blob-num js-line-number" data-line-number="288"></td>
        <td id="LC288" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `generaltypefactor`</span></td>
      </tr>
      <tr>
        <td id="L289" class="blob-num js-line-number" data-line-number="289"></td>
        <td id="LC289" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L290" class="blob-num js-line-number" data-line-number="290"></td>
        <td id="LC290" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L291" class="blob-num js-line-number" data-line-number="291"></td>
        <td id="LC291" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>generaltypefactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L292" class="blob-num js-line-number" data-line-number="292"></td>
        <td id="LC292" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L293" class="blob-num js-line-number" data-line-number="293"></td>
        <td id="LC293" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L294" class="blob-num js-line-number" data-line-number="294"></td>
        <td id="LC294" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">generaltypefactor</span>` (</td>
      </tr>
      <tr>
        <td id="L295" class="blob-num js-line-number" data-line-number="295"></td>
        <td id="LC295" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>type id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L296" class="blob-num js-line-number" data-line-number="296"></td>
        <td id="LC296" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>virtual column id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L297" class="blob-num js-line-number" data-line-number="297"></td>
        <td id="LC297" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value of the virtual column<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L298" class="blob-num js-line-number" data-line-number="298"></td>
        <td id="LC298" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L299" class="blob-num js-line-number" data-line-number="299"></td>
        <td id="LC299" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L300" class="blob-num js-line-number" data-line-number="300"></td>
        <td id="LC300" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>generaltypefactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L301" class="blob-num js-line-number" data-line-number="301"></td>
        <td id="LC301" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>generaltypefactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L302" class="blob-num js-line-number" data-line-number="302"></td>
        <td id="LC302" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L303" class="blob-num js-line-number" data-line-number="303"></td>
        <td id="LC303" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L304" class="blob-num js-line-number" data-line-number="304"></td>
        <td id="LC304" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L305" class="blob-num js-line-number" data-line-number="305"></td>
        <td id="LC305" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L306" class="blob-num js-line-number" data-line-number="306"></td>
        <td id="LC306" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `genotype`</span></td>
      </tr>
      <tr>
        <td id="L307" class="blob-num js-line-number" data-line-number="307"></td>
        <td id="LC307" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L308" class="blob-num js-line-number" data-line-number="308"></td>
        <td id="LC308" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L309" class="blob-num js-line-number" data-line-number="309"></td>
        <td id="LC309" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>genotype<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L310" class="blob-num js-line-number" data-line-number="310"></td>
        <td id="LC310" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L311" class="blob-num js-line-number" data-line-number="311"></td>
        <td id="LC311" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L312" class="blob-num js-line-number" data-line-number="312"></td>
        <td id="LC312" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">genotype</span>` (</td>
      </tr>
      <tr>
        <td id="L313" class="blob-num js-line-number" data-line-number="313"></td>
        <td id="LC313" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L314" class="blob-num js-line-number" data-line-number="314"></td>
        <td id="LC314" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L315" class="blob-num js-line-number" data-line-number="315"></td>
        <td id="LC315" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenusId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genus / organism<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L316" class="blob-num js-line-number" data-line-number="316"></td>
        <td id="LC316" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpeciesName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>name in Latin - common naming conventions should be established - For use when using different species and a trial from another genus<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L317" class="blob-num js-line-number" data-line-number="317"></td>
        <td id="LC317" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeAcronym<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>short name of genotype<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L318" class="blob-num js-line-number" data-line-number="318"></td>
        <td id="LC318" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OriginId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Scource Identifier - possible Part of Plant Variety Rights Information - could refer to organisation or contact<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L319" class="blob-num js-line-number" data-line-number="319"></td>
        <td id="LC319" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>CanPublishGenotype<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">1</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>flag if publicly available<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L320" class="blob-num js-line-number" data-line-number="320"></td>
        <td id="LC320" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeColor<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Possibly to utilise as Part of Plant Variety Rights Information<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L321" class="blob-num js-line-number" data-line-number="321"></td>
        <td id="LC321" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">6000</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L322" class="blob-num js-line-number" data-line-number="322"></td>
        <td id="LC322" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>group id which owns the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L323" class="blob-num js-line-number" data-line-number="323"></td>
        <td id="LC323" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>group id with access to the record (different than own group)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L324" class="blob-num js-line-number" data-line-number="324"></td>
        <td id="LC324" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>permission for the own group members<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L325" class="blob-num js-line-number" data-line-number="325"></td>
        <td id="LC325" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>permission for the other group members<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L326" class="blob-num js-line-number" data-line-number="326"></td>
        <td id="LC326" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OtherPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>permission for all the other system users<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L327" class="blob-num js-line-number" data-line-number="327"></td>
        <td id="LC327" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L328" class="blob-num js-line-number" data-line-number="328"></td>
        <td id="LC328" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xg_GenotypeNameGenusId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeName<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>GenusId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L329" class="blob-num js-line-number" data-line-number="329"></td>
        <td id="LC329" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xg_GenusId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenusId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L330" class="blob-num js-line-number" data-line-number="330"></td>
        <td id="LC330" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xg_OriginId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>OriginId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L331" class="blob-num js-line-number" data-line-number="331"></td>
        <td id="LC331" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xg_SpeciesName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpeciesName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L332" class="blob-num js-line-number" data-line-number="332"></td>
        <td id="LC332" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotype_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenusId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genus<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenusId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L333" class="blob-num js-line-number" data-line-number="333"></td>
        <td id="LC333" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L334" class="blob-num js-line-number" data-line-number="334"></td>
        <td id="LC334" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L335" class="blob-num js-line-number" data-line-number="335"></td>
        <td id="LC335" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L336" class="blob-num js-line-number" data-line-number="336"></td>
        <td id="LC336" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L337" class="blob-num js-line-number" data-line-number="337"></td>
        <td id="LC337" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `genotypealias`</span></td>
      </tr>
      <tr>
        <td id="L338" class="blob-num js-line-number" data-line-number="338"></td>
        <td id="LC338" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L339" class="blob-num js-line-number" data-line-number="339"></td>
        <td id="LC339" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L340" class="blob-num js-line-number" data-line-number="340"></td>
        <td id="LC340" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>genotypealias<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L341" class="blob-num js-line-number" data-line-number="341"></td>
        <td id="LC341" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L342" class="blob-num js-line-number" data-line-number="342"></td>
        <td id="LC342" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L343" class="blob-num js-line-number" data-line-number="343"></td>
        <td id="LC343" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">genotypealias</span>` (</td>
      </tr>
      <tr>
        <td id="L344" class="blob-num js-line-number" data-line-number="344"></td>
        <td id="LC344" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype alias id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L345" class="blob-num js-line-number" data-line-number="345"></td>
        <td id="LC345" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype alias name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L346" class="blob-num js-line-number" data-line-number="346"></td>
        <td id="LC346" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L347" class="blob-num js-line-number" data-line-number="347"></td>
        <td id="LC347" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasType<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype alias type from generaltype table class agenotypealiasa<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L348" class="blob-num js-line-number" data-line-number="348"></td>
        <td id="LC348" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasStatus<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>status of the alias (e.g. used, preferred, old, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L349" class="blob-num js-line-number" data-line-number="349"></td>
        <td id="LC349" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasLang<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">15</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>language of the genotype alias name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L350" class="blob-num js-line-number" data-line-number="350"></td>
        <td id="LC350" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L351" class="blob-num js-line-number" data-line-number="351"></td>
        <td id="LC351" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xga_GenotypeAliasName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L352" class="blob-num js-line-number" data-line-number="352"></td>
        <td id="LC352" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xga_GenotypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L353" class="blob-num js-line-number" data-line-number="353"></td>
        <td id="LC353" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xga_GenotypeAliasType<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasType<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L354" class="blob-num js-line-number" data-line-number="354"></td>
        <td id="LC354" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xga_GenotypeAliasStatus<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasStatus<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L355" class="blob-num js-line-number" data-line-number="355"></td>
        <td id="LC355" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xga_GenotypeAliasLang<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasLang<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L356" class="blob-num js-line-number" data-line-number="356"></td>
        <td id="LC356" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypealias_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genotype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L357" class="blob-num js-line-number" data-line-number="357"></td>
        <td id="LC357" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypealias_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasType<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L358" class="blob-num js-line-number" data-line-number="358"></td>
        <td id="LC358" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypealias_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasStatus<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L359" class="blob-num js-line-number" data-line-number="359"></td>
        <td id="LC359" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L360" class="blob-num js-line-number" data-line-number="360"></td>
        <td id="LC360" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L361" class="blob-num js-line-number" data-line-number="361"></td>
        <td id="LC361" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L362" class="blob-num js-line-number" data-line-number="362"></td>
        <td id="LC362" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L363" class="blob-num js-line-number" data-line-number="363"></td>
        <td id="LC363" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `genotypealiasfactor`</span></td>
      </tr>
      <tr>
        <td id="L364" class="blob-num js-line-number" data-line-number="364"></td>
        <td id="LC364" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L365" class="blob-num js-line-number" data-line-number="365"></td>
        <td id="LC365" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L366" class="blob-num js-line-number" data-line-number="366"></td>
        <td id="LC366" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>genotypealiasfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L367" class="blob-num js-line-number" data-line-number="367"></td>
        <td id="LC367" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L368" class="blob-num js-line-number" data-line-number="368"></td>
        <td id="LC368" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L369" class="blob-num js-line-number" data-line-number="369"></td>
        <td id="LC369" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">genotypealiasfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L370" class="blob-num js-line-number" data-line-number="370"></td>
        <td id="LC370" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype alias id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L371" class="blob-num js-line-number" data-line-number="371"></td>
        <td id="LC371" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L372" class="blob-num js-line-number" data-line-number="372"></td>
        <td id="LC372" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L373" class="blob-num js-line-number" data-line-number="373"></td>
        <td id="LC373" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L374" class="blob-num js-line-number" data-line-number="374"></td>
        <td id="LC374" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L375" class="blob-num js-line-number" data-line-number="375"></td>
        <td id="LC375" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypealiasfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genotypealias<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeAliasId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L376" class="blob-num js-line-number" data-line-number="376"></td>
        <td id="LC376" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypealiasfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L377" class="blob-num js-line-number" data-line-number="377"></td>
        <td id="LC377" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L378" class="blob-num js-line-number" data-line-number="378"></td>
        <td id="LC378" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L379" class="blob-num js-line-number" data-line-number="379"></td>
        <td id="LC379" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L380" class="blob-num js-line-number" data-line-number="380"></td>
        <td id="LC380" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L381" class="blob-num js-line-number" data-line-number="381"></td>
        <td id="LC381" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `genotypefactor`</span></td>
      </tr>
      <tr>
        <td id="L382" class="blob-num js-line-number" data-line-number="382"></td>
        <td id="LC382" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L383" class="blob-num js-line-number" data-line-number="383"></td>
        <td id="LC383" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L384" class="blob-num js-line-number" data-line-number="384"></td>
        <td id="LC384" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>genotypefactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L385" class="blob-num js-line-number" data-line-number="385"></td>
        <td id="LC385" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L386" class="blob-num js-line-number" data-line-number="386"></td>
        <td id="LC386" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L387" class="blob-num js-line-number" data-line-number="387"></td>
        <td id="LC387" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">genotypefactor</span>` (</td>
      </tr>
      <tr>
        <td id="L388" class="blob-num js-line-number" data-line-number="388"></td>
        <td id="LC388" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L389" class="blob-num js-line-number" data-line-number="389"></td>
        <td id="LC389" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L390" class="blob-num js-line-number" data-line-number="390"></td>
        <td id="LC390" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L391" class="blob-num js-line-number" data-line-number="391"></td>
        <td id="LC391" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L392" class="blob-num js-line-number" data-line-number="392"></td>
        <td id="LC392" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L393" class="blob-num js-line-number" data-line-number="393"></td>
        <td id="LC393" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypefactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L394" class="blob-num js-line-number" data-line-number="394"></td>
        <td id="LC394" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypefactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genotype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L395" class="blob-num js-line-number" data-line-number="395"></td>
        <td id="LC395" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L396" class="blob-num js-line-number" data-line-number="396"></td>
        <td id="LC396" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L397" class="blob-num js-line-number" data-line-number="397"></td>
        <td id="LC397" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L398" class="blob-num js-line-number" data-line-number="398"></td>
        <td id="LC398" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L399" class="blob-num js-line-number" data-line-number="399"></td>
        <td id="LC399" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `genotypespecimen`</span></td>
      </tr>
      <tr>
        <td id="L400" class="blob-num js-line-number" data-line-number="400"></td>
        <td id="LC400" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L401" class="blob-num js-line-number" data-line-number="401"></td>
        <td id="LC401" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L402" class="blob-num js-line-number" data-line-number="402"></td>
        <td id="LC402" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>genotypespecimen<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L403" class="blob-num js-line-number" data-line-number="403"></td>
        <td id="LC403" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L404" class="blob-num js-line-number" data-line-number="404"></td>
        <td id="LC404" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L405" class="blob-num js-line-number" data-line-number="405"></td>
        <td id="LC405" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">genotypespecimen</span>` (</td>
      </tr>
      <tr>
        <td id="L406" class="blob-num js-line-number" data-line-number="406"></td>
        <td id="LC406" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeSpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the group of genotype and plant combination<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L407" class="blob-num js-line-number" data-line-number="407"></td>
        <td id="LC407" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the specimen<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L408" class="blob-num js-line-number" data-line-number="408"></td>
        <td id="LC408" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the genotype<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L409" class="blob-num js-line-number" data-line-number="409"></td>
        <td id="LC409" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeSpecimenType<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>relation to type - useful when a few genotypes compose specimen and one is of type scion and the other is rootstock<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L410" class="blob-num js-line-number" data-line-number="410"></td>
        <td id="LC410" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>GenotypeSpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L411" class="blob-num js-line-number" data-line-number="411"></td>
        <td id="LC411" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgp_genotype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L412" class="blob-num js-line-number" data-line-number="412"></td>
        <td id="LC412" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgp_specimen<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L413" class="blob-num js-line-number" data-line-number="413"></td>
        <td id="LC413" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgp_gst<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeSpecimenType<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L414" class="blob-num js-line-number" data-line-number="414"></td>
        <td id="LC414" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypespecimen_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>specimen<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L415" class="blob-num js-line-number" data-line-number="415"></td>
        <td id="LC415" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypespecimen_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genotype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L416" class="blob-num js-line-number" data-line-number="416"></td>
        <td id="LC416" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypespecimen_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeSpecimenType<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L417" class="blob-num js-line-number" data-line-number="417"></td>
        <td id="LC417" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L418" class="blob-num js-line-number" data-line-number="418"></td>
        <td id="LC418" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L419" class="blob-num js-line-number" data-line-number="419"></td>
        <td id="LC419" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L420" class="blob-num js-line-number" data-line-number="420"></td>
        <td id="LC420" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L421" class="blob-num js-line-number" data-line-number="421"></td>
        <td id="LC421" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `genotypetrait`</span></td>
      </tr>
      <tr>
        <td id="L422" class="blob-num js-line-number" data-line-number="422"></td>
        <td id="LC422" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L423" class="blob-num js-line-number" data-line-number="423"></td>
        <td id="LC423" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L424" class="blob-num js-line-number" data-line-number="424"></td>
        <td id="LC424" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>genotypetrait<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L425" class="blob-num js-line-number" data-line-number="425"></td>
        <td id="LC425" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L426" class="blob-num js-line-number" data-line-number="426"></td>
        <td id="LC426" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L427" class="blob-num js-line-number" data-line-number="427"></td>
        <td id="LC427" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">genotypetrait</span>` (</td>
      </tr>
      <tr>
        <td id="L428" class="blob-num js-line-number" data-line-number="428"></td>
        <td id="LC428" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeTraitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype trait id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L429" class="blob-num js-line-number" data-line-number="429"></td>
        <td id="LC429" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L430" class="blob-num js-line-number" data-line-number="430"></td>
        <td id="LC430" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trait id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L431" class="blob-num js-line-number" data-line-number="431"></td>
        <td id="LC431" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>known trait value, whatever the user specifies it to be, very generic<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L432" class="blob-num js-line-number" data-line-number="432"></td>
        <td id="LC432" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>GenotypeTraitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L433" class="blob-num js-line-number" data-line-number="433"></td>
        <td id="LC433" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgt_GenotypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L434" class="blob-num js-line-number" data-line-number="434"></td>
        <td id="LC434" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgt_TraitId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L435" class="blob-num js-line-number" data-line-number="435"></td>
        <td id="LC435" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypetrait_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genotype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L436" class="blob-num js-line-number" data-line-number="436"></td>
        <td id="LC436" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genotypetrait_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trait<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L437" class="blob-num js-line-number" data-line-number="437"></td>
        <td id="LC437" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L438" class="blob-num js-line-number" data-line-number="438"></td>
        <td id="LC438" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L439" class="blob-num js-line-number" data-line-number="439"></td>
        <td id="LC439" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L440" class="blob-num js-line-number" data-line-number="440"></td>
        <td id="LC440" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L441" class="blob-num js-line-number" data-line-number="441"></td>
        <td id="LC441" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `genpedigree`</span></td>
      </tr>
      <tr>
        <td id="L442" class="blob-num js-line-number" data-line-number="442"></td>
        <td id="LC442" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L443" class="blob-num js-line-number" data-line-number="443"></td>
        <td id="LC443" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L444" class="blob-num js-line-number" data-line-number="444"></td>
        <td id="LC444" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>genpedigree<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L445" class="blob-num js-line-number" data-line-number="445"></td>
        <td id="LC445" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L446" class="blob-num js-line-number" data-line-number="446"></td>
        <td id="LC446" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L447" class="blob-num js-line-number" data-line-number="447"></td>
        <td id="LC447" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">genpedigree</span>` (</td>
      </tr>
      <tr>
        <td id="L448" class="blob-num js-line-number" data-line-number="448"></td>
        <td id="LC448" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenPedigreeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>GenPedigree id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L449" class="blob-num js-line-number" data-line-number="449"></td>
        <td id="LC449" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the genotype<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L450" class="blob-num js-line-number" data-line-number="450"></td>
        <td id="LC450" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ParentGenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the parent genotype<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L451" class="blob-num js-line-number" data-line-number="451"></td>
        <td id="LC451" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenParentType<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>what is the type of parent (e.g. male, female, self, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L452" class="blob-num js-line-number" data-line-number="452"></td>
        <td id="LC452" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>NumberOfGenotypes<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>optional number of parent genotypes perhaps useful to store<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L453" class="blob-num js-line-number" data-line-number="453"></td>
        <td id="LC453" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>GenPedigreeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L454" class="blob-num js-line-number" data-line-number="454"></td>
        <td id="LC454" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xgp_GePaType<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>ParentGenotypeId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>GenParentType<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L455" class="blob-num js-line-number" data-line-number="455"></td>
        <td id="LC455" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgp_GenotypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L456" class="blob-num js-line-number" data-line-number="456"></td>
        <td id="LC456" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgp_ParentGenotypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ParentGenotypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L457" class="blob-num js-line-number" data-line-number="457"></td>
        <td id="LC457" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xgp_GenParentType<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenParentType<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L458" class="blob-num js-line-number" data-line-number="458"></td>
        <td id="LC458" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genpedigree_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ParentGenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genotype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L459" class="blob-num js-line-number" data-line-number="459"></td>
        <td id="LC459" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genpedigree_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genotype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L460" class="blob-num js-line-number" data-line-number="460"></td>
        <td id="LC460" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>genpedigree_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenParentType<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L461" class="blob-num js-line-number" data-line-number="461"></td>
        <td id="LC461" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L462" class="blob-num js-line-number" data-line-number="462"></td>
        <td id="LC462" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L463" class="blob-num js-line-number" data-line-number="463"></td>
        <td id="LC463" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L464" class="blob-num js-line-number" data-line-number="464"></td>
        <td id="LC464" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L465" class="blob-num js-line-number" data-line-number="465"></td>
        <td id="LC465" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `genus`</span></td>
      </tr>
      <tr>
        <td id="L466" class="blob-num js-line-number" data-line-number="466"></td>
        <td id="LC466" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L467" class="blob-num js-line-number" data-line-number="467"></td>
        <td id="LC467" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L468" class="blob-num js-line-number" data-line-number="468"></td>
        <td id="LC468" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>genus<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L469" class="blob-num js-line-number" data-line-number="469"></td>
        <td id="LC469" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L470" class="blob-num js-line-number" data-line-number="470"></td>
        <td id="LC470" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L471" class="blob-num js-line-number" data-line-number="471"></td>
        <td id="LC471" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">genus</span>` (</td>
      </tr>
      <tr>
        <td id="L472" class="blob-num js-line-number" data-line-number="472"></td>
        <td id="LC472" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenusId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genus id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L473" class="blob-num js-line-number" data-line-number="473"></td>
        <td id="LC473" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenusName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genus name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L474" class="blob-num js-line-number" data-line-number="474"></td>
        <td id="LC474" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>GenusId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L475" class="blob-num js-line-number" data-line-number="475"></td>
        <td id="LC475" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xg_GenusName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenusName<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L476" class="blob-num js-line-number" data-line-number="476"></td>
        <td id="LC476" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L477" class="blob-num js-line-number" data-line-number="477"></td>
        <td id="LC477" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L478" class="blob-num js-line-number" data-line-number="478"></td>
        <td id="LC478" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L479" class="blob-num js-line-number" data-line-number="479"></td>
        <td id="LC479" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L480" class="blob-num js-line-number" data-line-number="480"></td>
        <td id="LC480" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `item`</span></td>
      </tr>
      <tr>
        <td id="L481" class="blob-num js-line-number" data-line-number="481"></td>
        <td id="LC481" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L482" class="blob-num js-line-number" data-line-number="482"></td>
        <td id="LC482" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L483" class="blob-num js-line-number" data-line-number="483"></td>
        <td id="LC483" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>item<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L484" class="blob-num js-line-number" data-line-number="484"></td>
        <td id="LC484" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L485" class="blob-num js-line-number" data-line-number="485"></td>
        <td id="LC485" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L486" class="blob-num js-line-number" data-line-number="486"></td>
        <td id="LC486" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">item</span>` (</td>
      </tr>
      <tr>
        <td id="L487" class="blob-num js-line-number" data-line-number="487"></td>
        <td id="LC487" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Id of the stored item<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L488" class="blob-num js-line-number" data-line-number="488"></td>
        <td id="LC488" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialUnitSpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Id of the trial unit specimen - where the item (seeds) were harvested from in the field<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L489" class="blob-num js-line-number" data-line-number="489"></td>
        <td id="LC489" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemSourceId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Id of the contact (who is the external source)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L490" class="blob-num js-line-number" data-line-number="490"></td>
        <td id="LC490" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContainerTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the container type<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L491" class="blob-num js-line-number" data-line-number="491"></td>
        <td id="LC491" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the specimen (bit redundant with trial unit specimen, but since this it may not be present then at least specimen info is there)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L492" class="blob-num js-line-number" data-line-number="492"></td>
        <td id="LC492" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ScaleId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the device used to take measurement<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L493" class="blob-num js-line-number" data-line-number="493"></td>
        <td id="LC493" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StorageId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the storage location<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L494" class="blob-num js-line-number" data-line-number="494"></td>
        <td id="LC494" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemUnitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>unit in which the measurement has been done<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L495" class="blob-num js-line-number" data-line-number="495"></td>
        <td id="LC495" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>type of the item<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L496" class="blob-num js-line-number" data-line-number="496"></td>
        <td id="LC496" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemStateId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the state description (e.g. damaged, thrown away, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L497" class="blob-num js-line-number" data-line-number="497"></td>
        <td id="LC497" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemBarcode<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>barcode on the item container<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L498" class="blob-num js-line-number" data-line-number="498"></td>
        <td id="LC498" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Amount<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">3</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>amount of the item in container<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L499" class="blob-num js-line-number" data-line-number="499"></td>
        <td id="LC499" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DateAdded<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date time when added<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L500" class="blob-num js-line-number" data-line-number="500"></td>
        <td id="LC500" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AddedByUserId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>who added<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L501" class="blob-num js-line-number" data-line-number="501"></td>
        <td id="LC501" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>LastMeasuredDate<span class="pl-pds">`</span></span> datetime default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date time when last updated<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L502" class="blob-num js-line-number" data-line-number="502"></td>
        <td id="LC502" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>LastMeasuredUserId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>who last updated<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L503" class="blob-num js-line-number" data-line-number="503"></td>
        <td id="LC503" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemOperation<span class="pl-pds">`</span></span> <span class="pl-k">set</span>(<span class="pl-s"><span class="pl-pds">&#39;</span>subsample<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>group<span class="pl-pds">&#39;</span></span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>in case item is derived from other items by taking sample or grouping (mixing) this can be defined here. Item parentage is defined in itemparent table<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L504" class="blob-num js-line-number" data-line-number="504"></td>
        <td id="LC504" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>some comments<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L505" class="blob-num js-line-number" data-line-number="505"></td>
        <td id="LC505" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L506" class="blob-num js-line-number" data-line-number="506"></td>
        <td id="LC506" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xi_ItemBarcode<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemBarcode<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L507" class="blob-num js-line-number" data-line-number="507"></td>
        <td id="LC507" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_ScaleId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ScaleId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L508" class="blob-num js-line-number" data-line-number="508"></td>
        <td id="LC508" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_StorageId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>StorageId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L509" class="blob-num js-line-number" data-line-number="509"></td>
        <td id="LC509" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_ItemUnitId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemUnitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L510" class="blob-num js-line-number" data-line-number="510"></td>
        <td id="LC510" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_ItemTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L511" class="blob-num js-line-number" data-line-number="511"></td>
        <td id="LC511" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_AddedByUserId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>AddedByUserId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L512" class="blob-num js-line-number" data-line-number="512"></td>
        <td id="LC512" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_LastMeasuredUserId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>LastMeasuredUserId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L513" class="blob-num js-line-number" data-line-number="513"></td>
        <td id="LC513" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_DateAdded<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>DateAdded<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L514" class="blob-num js-line-number" data-line-number="514"></td>
        <td id="LC514" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_LastMeasuredDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>LastMeasuredDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L515" class="blob-num js-line-number" data-line-number="515"></td>
        <td id="LC515" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_ItemStateId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemStateId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L516" class="blob-num js-line-number" data-line-number="516"></td>
        <td id="LC516" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_TrialUnitSpecimenId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitSpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L517" class="blob-num js-line-number" data-line-number="517"></td>
        <td id="LC517" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_ItemSourceId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemSourceId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L518" class="blob-num js-line-number" data-line-number="518"></td>
        <td id="LC518" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_ContainerTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContainerTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L519" class="blob-num js-line-number" data-line-number="519"></td>
        <td id="LC519" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xi_SpecimenId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L520" class="blob-num js-line-number" data-line-number="520"></td>
        <td id="LC520" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>item_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>specimen<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L521" class="blob-num js-line-number" data-line-number="521"></td>
        <td id="LC521" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>item_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>AddedByUserId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>systemuser<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L522" class="blob-num js-line-number" data-line-number="522"></td>
        <td id="LC522" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>item_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ItemTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L523" class="blob-num js-line-number" data-line-number="523"></td>
        <td id="LC523" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L524" class="blob-num js-line-number" data-line-number="524"></td>
        <td id="LC524" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L525" class="blob-num js-line-number" data-line-number="525"></td>
        <td id="LC525" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L526" class="blob-num js-line-number" data-line-number="526"></td>
        <td id="LC526" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L527" class="blob-num js-line-number" data-line-number="527"></td>
        <td id="LC527" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `itemfactor`</span></td>
      </tr>
      <tr>
        <td id="L528" class="blob-num js-line-number" data-line-number="528"></td>
        <td id="LC528" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L529" class="blob-num js-line-number" data-line-number="529"></td>
        <td id="LC529" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L530" class="blob-num js-line-number" data-line-number="530"></td>
        <td id="LC530" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>itemfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L531" class="blob-num js-line-number" data-line-number="531"></td>
        <td id="LC531" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L532" class="blob-num js-line-number" data-line-number="532"></td>
        <td id="LC532" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L533" class="blob-num js-line-number" data-line-number="533"></td>
        <td id="LC533" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">itemfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L534" class="blob-num js-line-number" data-line-number="534"></td>
        <td id="LC534" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>item id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L535" class="blob-num js-line-number" data-line-number="535"></td>
        <td id="LC535" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>virtual column id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L536" class="blob-num js-line-number" data-line-number="536"></td>
        <td id="LC536" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value in column for an item id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L537" class="blob-num js-line-number" data-line-number="537"></td>
        <td id="LC537" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L538" class="blob-num js-line-number" data-line-number="538"></td>
        <td id="LC538" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L539" class="blob-num js-line-number" data-line-number="539"></td>
        <td id="LC539" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>item<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L540" class="blob-num js-line-number" data-line-number="540"></td>
        <td id="LC540" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L541" class="blob-num js-line-number" data-line-number="541"></td>
        <td id="LC541" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L542" class="blob-num js-line-number" data-line-number="542"></td>
        <td id="LC542" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L543" class="blob-num js-line-number" data-line-number="543"></td>
        <td id="LC543" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L544" class="blob-num js-line-number" data-line-number="544"></td>
        <td id="LC544" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L545" class="blob-num js-line-number" data-line-number="545"></td>
        <td id="LC545" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `itemgroup`</span></td>
      </tr>
      <tr>
        <td id="L546" class="blob-num js-line-number" data-line-number="546"></td>
        <td id="LC546" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L547" class="blob-num js-line-number" data-line-number="547"></td>
        <td id="LC547" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L548" class="blob-num js-line-number" data-line-number="548"></td>
        <td id="LC548" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>itemgroup<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L549" class="blob-num js-line-number" data-line-number="549"></td>
        <td id="LC549" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L550" class="blob-num js-line-number" data-line-number="550"></td>
        <td id="LC550" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L551" class="blob-num js-line-number" data-line-number="551"></td>
        <td id="LC551" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">itemgroup</span>` (</td>
      </tr>
      <tr>
        <td id="L552" class="blob-num js-line-number" data-line-number="552"></td>
        <td id="LC552" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Item group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L553" class="blob-num js-line-number" data-line-number="553"></td>
        <td id="LC553" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemGroupName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>item group name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L554" class="blob-num js-line-number" data-line-number="554"></td>
        <td id="LC554" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemGroupNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>comments about item group<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L555" class="blob-num js-line-number" data-line-number="555"></td>
        <td id="LC555" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AddedByUser<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>system user id, who created item group<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L556" class="blob-num js-line-number" data-line-number="556"></td>
        <td id="LC556" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DateAdded<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date time when item group added<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L557" class="blob-num js-line-number" data-line-number="557"></td>
        <td id="LC557" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Active<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">1</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>1<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>flag if group active<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L558" class="blob-num js-line-number" data-line-number="558"></td>
        <td id="LC558" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ItemGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L559" class="blob-num js-line-number" data-line-number="559"></td>
        <td id="LC559" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xig_ItemGroupName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemGroupName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L560" class="blob-num js-line-number" data-line-number="560"></td>
        <td id="LC560" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xig_AddedByUser<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>AddedByUser<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L561" class="blob-num js-line-number" data-line-number="561"></td>
        <td id="LC561" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L562" class="blob-num js-line-number" data-line-number="562"></td>
        <td id="LC562" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L563" class="blob-num js-line-number" data-line-number="563"></td>
        <td id="LC563" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L564" class="blob-num js-line-number" data-line-number="564"></td>
        <td id="LC564" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L565" class="blob-num js-line-number" data-line-number="565"></td>
        <td id="LC565" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `itemgroupentry`</span></td>
      </tr>
      <tr>
        <td id="L566" class="blob-num js-line-number" data-line-number="566"></td>
        <td id="LC566" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L567" class="blob-num js-line-number" data-line-number="567"></td>
        <td id="LC567" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L568" class="blob-num js-line-number" data-line-number="568"></td>
        <td id="LC568" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>itemgroupentry<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L569" class="blob-num js-line-number" data-line-number="569"></td>
        <td id="LC569" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L570" class="blob-num js-line-number" data-line-number="570"></td>
        <td id="LC570" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L571" class="blob-num js-line-number" data-line-number="571"></td>
        <td id="LC571" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">itemgroupentry</span>` (</td>
      </tr>
      <tr>
        <td id="L572" class="blob-num js-line-number" data-line-number="572"></td>
        <td id="LC572" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>item id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L573" class="blob-num js-line-number" data-line-number="573"></td>
        <td id="LC573" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>item group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L574" class="blob-num js-line-number" data-line-number="574"></td>
        <td id="LC574" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xige_ItemId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L575" class="blob-num js-line-number" data-line-number="575"></td>
        <td id="LC575" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xige_ItemGroupId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L576" class="blob-num js-line-number" data-line-number="576"></td>
        <td id="LC576" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemgroupentry_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>item<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L577" class="blob-num js-line-number" data-line-number="577"></td>
        <td id="LC577" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemgroupentry_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ItemGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>itemgroup<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L578" class="blob-num js-line-number" data-line-number="578"></td>
        <td id="LC578" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L579" class="blob-num js-line-number" data-line-number="579"></td>
        <td id="LC579" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L580" class="blob-num js-line-number" data-line-number="580"></td>
        <td id="LC580" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L581" class="blob-num js-line-number" data-line-number="581"></td>
        <td id="LC581" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L582" class="blob-num js-line-number" data-line-number="582"></td>
        <td id="LC582" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `itemlog`</span></td>
      </tr>
      <tr>
        <td id="L583" class="blob-num js-line-number" data-line-number="583"></td>
        <td id="LC583" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L584" class="blob-num js-line-number" data-line-number="584"></td>
        <td id="LC584" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L585" class="blob-num js-line-number" data-line-number="585"></td>
        <td id="LC585" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>itemlog<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L586" class="blob-num js-line-number" data-line-number="586"></td>
        <td id="LC586" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L587" class="blob-num js-line-number" data-line-number="587"></td>
        <td id="LC587" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L588" class="blob-num js-line-number" data-line-number="588"></td>
        <td id="LC588" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">itemlog</span>` (</td>
      </tr>
      <tr>
        <td id="L589" class="blob-num js-line-number" data-line-number="589"></td>
        <td id="LC589" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemLogId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>item log id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L590" class="blob-num js-line-number" data-line-number="590"></td>
        <td id="LC590" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>LogTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>type, action to log<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L591" class="blob-num js-line-number" data-line-number="591"></td>
        <td id="LC591" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SystemUserId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>who did/log that action<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L592" class="blob-num js-line-number" data-line-number="592"></td>
        <td id="LC592" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>item it was logged for<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L593" class="blob-num js-line-number" data-line-number="593"></td>
        <td id="LC593" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>LogDateTime<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date time of action<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L594" class="blob-num js-line-number" data-line-number="594"></td>
        <td id="LC594" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>LogMessage<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>message or info logged<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L595" class="blob-num js-line-number" data-line-number="595"></td>
        <td id="LC595" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ItemLogId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L596" class="blob-num js-line-number" data-line-number="596"></td>
        <td id="LC596" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xil_LogTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>LogTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L597" class="blob-num js-line-number" data-line-number="597"></td>
        <td id="LC597" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xil_SystemUserId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SystemUserId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L598" class="blob-num js-line-number" data-line-number="598"></td>
        <td id="LC598" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xil_ItemId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L599" class="blob-num js-line-number" data-line-number="599"></td>
        <td id="LC599" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xil_LogDateTime<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>LogDateTime<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L600" class="blob-num js-line-number" data-line-number="600"></td>
        <td id="LC600" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemlog_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>item<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L601" class="blob-num js-line-number" data-line-number="601"></td>
        <td id="LC601" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemlog_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SystemUserId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>systemuser<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L602" class="blob-num js-line-number" data-line-number="602"></td>
        <td id="LC602" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemlog_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>LogTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L603" class="blob-num js-line-number" data-line-number="603"></td>
        <td id="LC603" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L604" class="blob-num js-line-number" data-line-number="604"></td>
        <td id="LC604" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L605" class="blob-num js-line-number" data-line-number="605"></td>
        <td id="LC605" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L606" class="blob-num js-line-number" data-line-number="606"></td>
        <td id="LC606" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L607" class="blob-num js-line-number" data-line-number="607"></td>
        <td id="LC607" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `itemparent`</span></td>
      </tr>
      <tr>
        <td id="L608" class="blob-num js-line-number" data-line-number="608"></td>
        <td id="LC608" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L609" class="blob-num js-line-number" data-line-number="609"></td>
        <td id="LC609" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L610" class="blob-num js-line-number" data-line-number="610"></td>
        <td id="LC610" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>itemparent<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L611" class="blob-num js-line-number" data-line-number="611"></td>
        <td id="LC611" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L612" class="blob-num js-line-number" data-line-number="612"></td>
        <td id="LC612" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L613" class="blob-num js-line-number" data-line-number="613"></td>
        <td id="LC613" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">itemparent</span>` (</td>
      </tr>
      <tr>
        <td id="L614" class="blob-num js-line-number" data-line-number="614"></td>
        <td id="LC614" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemParentId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>internal id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L615" class="blob-num js-line-number" data-line-number="615"></td>
        <td id="LC615" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemParentType<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>item parent type (different than parent type in generaltype table) class - itemparent<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L616" class="blob-num js-line-number" data-line-number="616"></td>
        <td id="LC616" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>newly created item id from other items<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L617" class="blob-num js-line-number" data-line-number="617"></td>
        <td id="LC617" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ParentId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>item id of the parent item<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L618" class="blob-num js-line-number" data-line-number="618"></td>
        <td id="LC618" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ItemParentId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L619" class="blob-num js-line-number" data-line-number="619"></td>
        <td id="LC619" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xip_ItemIDParentID<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>ParentId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L620" class="blob-num js-line-number" data-line-number="620"></td>
        <td id="LC620" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xip_ItemId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L621" class="blob-num js-line-number" data-line-number="621"></td>
        <td id="LC621" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xip_ParentId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ParentId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L622" class="blob-num js-line-number" data-line-number="622"></td>
        <td id="LC622" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xip_ItemParentType<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemParentType<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L623" class="blob-num js-line-number" data-line-number="623"></td>
        <td id="LC623" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemparent_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>item<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L624" class="blob-num js-line-number" data-line-number="624"></td>
        <td id="LC624" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemparent_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ParentId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>item<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L625" class="blob-num js-line-number" data-line-number="625"></td>
        <td id="LC625" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemparent_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ItemParentType<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L626" class="blob-num js-line-number" data-line-number="626"></td>
        <td id="LC626" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L627" class="blob-num js-line-number" data-line-number="627"></td>
        <td id="LC627" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L628" class="blob-num js-line-number" data-line-number="628"></td>
        <td id="LC628" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L629" class="blob-num js-line-number" data-line-number="629"></td>
        <td id="LC629" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L630" class="blob-num js-line-number" data-line-number="630"></td>
        <td id="LC630" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `itemunit`</span></td>
      </tr>
      <tr>
        <td id="L631" class="blob-num js-line-number" data-line-number="631"></td>
        <td id="LC631" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L632" class="blob-num js-line-number" data-line-number="632"></td>
        <td id="LC632" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L633" class="blob-num js-line-number" data-line-number="633"></td>
        <td id="LC633" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>itemunit<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L634" class="blob-num js-line-number" data-line-number="634"></td>
        <td id="LC634" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L635" class="blob-num js-line-number" data-line-number="635"></td>
        <td id="LC635" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L636" class="blob-num js-line-number" data-line-number="636"></td>
        <td id="LC636" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">itemunit</span>` (</td>
      </tr>
      <tr>
        <td id="L637" class="blob-num js-line-number" data-line-number="637"></td>
        <td id="LC637" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemUnitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>item unit id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L638" class="blob-num js-line-number" data-line-number="638"></td>
        <td id="LC638" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UnitTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>optional FK to type (e.g. weight, temperature, length etc) - class unittype<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L639" class="blob-num js-line-number" data-line-number="639"></td>
        <td id="LC639" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemUnitName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">12</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>unit name (e.g. kg, dkg, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L640" class="blob-num js-line-number" data-line-number="640"></td>
        <td id="LC640" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GramsConversionMultiplier<span class="pl-pds">`</span></span> float <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>1<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value to multiply to convert into grams (or any other multiplier into other units being commonly used in particular situation)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L641" class="blob-num js-line-number" data-line-number="641"></td>
        <td id="LC641" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemUnitNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>some description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L642" class="blob-num js-line-number" data-line-number="642"></td>
        <td id="LC642" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ConversionRule<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>function (sudo code or EXPR) to define possibly complex conversion from this unit to canonical unit<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L643" class="blob-num js-line-number" data-line-number="643"></td>
        <td id="LC643" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ItemUnitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L644" class="blob-num js-line-number" data-line-number="644"></td>
        <td id="LC644" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xiu_ItemUnitName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemUnitName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L645" class="blob-num js-line-number" data-line-number="645"></td>
        <td id="LC645" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>UnitTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UnitTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L646" class="blob-num js-line-number" data-line-number="646"></td>
        <td id="LC646" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>itemunit_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>UnitTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L647" class="blob-num js-line-number" data-line-number="647"></td>
        <td id="LC647" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L648" class="blob-num js-line-number" data-line-number="648"></td>
        <td id="LC648" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L649" class="blob-num js-line-number" data-line-number="649"></td>
        <td id="LC649" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L650" class="blob-num js-line-number" data-line-number="650"></td>
        <td id="LC650" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L651" class="blob-num js-line-number" data-line-number="651"></td>
        <td id="LC651" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `metgroup`</span></td>
      </tr>
      <tr>
        <td id="L652" class="blob-num js-line-number" data-line-number="652"></td>
        <td id="LC652" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L653" class="blob-num js-line-number" data-line-number="653"></td>
        <td id="LC653" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L654" class="blob-num js-line-number" data-line-number="654"></td>
        <td id="LC654" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>metgroup<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L655" class="blob-num js-line-number" data-line-number="655"></td>
        <td id="LC655" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L656" class="blob-num js-line-number" data-line-number="656"></td>
        <td id="LC656" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L657" class="blob-num js-line-number" data-line-number="657"></td>
        <td id="LC657" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">metgroup</span>` (</td>
      </tr>
      <tr>
        <td id="L658" class="blob-num js-line-number" data-line-number="658"></td>
        <td id="LC658" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L659" class="blob-num js-line-number" data-line-number="659"></td>
        <td id="LC659" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trait id (replacement of former variate id)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L660" class="blob-num js-line-number" data-line-number="660"></td>
        <td id="LC660" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METGroupName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met group name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L661" class="blob-num js-line-number" data-line-number="661"></td>
        <td id="LC661" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L662" class="blob-num js-line-number" data-line-number="662"></td>
        <td id="LC662" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AnalystId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Id that identifies te analyst (contact) who analysed data.<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L663" class="blob-num js-line-number" data-line-number="663"></td>
        <td id="LC663" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AnalysisDoneDate<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>when analysis done<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L664" class="blob-num js-line-number" data-line-number="664"></td>
        <td id="LC664" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StatisticalModel<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Text representation of model formula (with covariate information)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L665" class="blob-num js-line-number" data-line-number="665"></td>
        <td id="LC665" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>PercentVarianceExplained<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>percentage of variance explained<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L666" class="blob-num js-line-number" data-line-number="666"></td>
        <td id="LC666" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ControlGenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>shouldnat it be related to genotype idkMHgIt should be linked, it is in my schemak/MHg<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L667" class="blob-num js-line-number" data-line-number="667"></td>
        <td id="LC667" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>BiPlotImageFileName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>FileName(and Path) of Image File<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L668" class="blob-num js-line-number" data-line-number="668"></td>
        <td id="LC668" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METGroupNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">6000</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met group description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L669" class="blob-num js-line-number" data-line-number="669"></td>
        <td id="LC669" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L670" class="blob-num js-line-number" data-line-number="670"></td>
        <td id="LC670" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>AlternateKey<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupName<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>METId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L671" class="blob-num js-line-number" data-line-number="671"></td>
        <td id="LC671" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>METId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L672" class="blob-num js-line-number" data-line-number="672"></td>
        <td id="LC672" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>Contact_METGroup_FK1<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>AnalystId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L673" class="blob-num js-line-number" data-line-number="673"></td>
        <td id="LC673" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>Genotype_METGroup_FK1<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ControlGenotypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L674" class="blob-num js-line-number" data-line-number="674"></td>
        <td id="LC674" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L675" class="blob-num js-line-number" data-line-number="675"></td>
        <td id="LC675" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgroup_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>METId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>multienvtrial<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L676" class="blob-num js-line-number" data-line-number="676"></td>
        <td id="LC676" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgroup_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trait<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L677" class="blob-num js-line-number" data-line-number="677"></td>
        <td id="LC677" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgroup_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>AnalystId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>contact<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L678" class="blob-num js-line-number" data-line-number="678"></td>
        <td id="LC678" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L679" class="blob-num js-line-number" data-line-number="679"></td>
        <td id="LC679" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L680" class="blob-num js-line-number" data-line-number="680"></td>
        <td id="LC680" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L681" class="blob-num js-line-number" data-line-number="681"></td>
        <td id="LC681" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L682" class="blob-num js-line-number" data-line-number="682"></td>
        <td id="LC682" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `metgroupegv`</span></td>
      </tr>
      <tr>
        <td id="L683" class="blob-num js-line-number" data-line-number="683"></td>
        <td id="LC683" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L684" class="blob-num js-line-number" data-line-number="684"></td>
        <td id="LC684" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L685" class="blob-num js-line-number" data-line-number="685"></td>
        <td id="LC685" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>metgroupegv<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L686" class="blob-num js-line-number" data-line-number="686"></td>
        <td id="LC686" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L687" class="blob-num js-line-number" data-line-number="687"></td>
        <td id="LC687" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L688" class="blob-num js-line-number" data-line-number="688"></td>
        <td id="LC688" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">metgroupegv</span>` (</td>
      </tr>
      <tr>
        <td id="L689" class="blob-num js-line-number" data-line-number="689"></td>
        <td id="LC689" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METGroupEGVId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met group egv id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L690" class="blob-num js-line-number" data-line-number="690"></td>
        <td id="LC690" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L691" class="blob-num js-line-number" data-line-number="691"></td>
        <td id="LC691" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L692" class="blob-num js-line-number" data-line-number="692"></td>
        <td id="LC692" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>treatment id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L693" class="blob-num js-line-number" data-line-number="693"></td>
        <td id="LC693" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met sub group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L694" class="blob-num js-line-number" data-line-number="694"></td>
        <td id="LC694" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>EGV<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>EGV - Expected Genetic Value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L695" class="blob-num js-line-number" data-line-number="695"></td>
        <td id="LC695" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>METGroupEGVId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L696" class="blob-num js-line-number" data-line-number="696"></td>
        <td id="LC696" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>AlternateKey<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L697" class="blob-num js-line-number" data-line-number="697"></td>
        <td id="LC697" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L698" class="blob-num js-line-number" data-line-number="698"></td>
        <td id="LC698" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L699" class="blob-num js-line-number" data-line-number="699"></td>
        <td id="LC699" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>METSubGroup_METGroupEGV_FK1<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L700" class="blob-num js-line-number" data-line-number="700"></td>
        <td id="LC700" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgroupegv_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genotype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L701" class="blob-num js-line-number" data-line-number="701"></td>
        <td id="LC701" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgroupegv_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>metgroup<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L702" class="blob-num js-line-number" data-line-number="702"></td>
        <td id="LC702" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgroupegv_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>metsubgroup<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L703" class="blob-num js-line-number" data-line-number="703"></td>
        <td id="LC703" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgroupegv_ibfk_4<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>treatment<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L704" class="blob-num js-line-number" data-line-number="704"></td>
        <td id="LC704" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L705" class="blob-num js-line-number" data-line-number="705"></td>
        <td id="LC705" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L706" class="blob-num js-line-number" data-line-number="706"></td>
        <td id="LC706" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L707" class="blob-num js-line-number" data-line-number="707"></td>
        <td id="LC707" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L708" class="blob-num js-line-number" data-line-number="708"></td>
        <td id="LC708" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `metgroupegvfactor`</span></td>
      </tr>
      <tr>
        <td id="L709" class="blob-num js-line-number" data-line-number="709"></td>
        <td id="LC709" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L710" class="blob-num js-line-number" data-line-number="710"></td>
        <td id="LC710" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L711" class="blob-num js-line-number" data-line-number="711"></td>
        <td id="LC711" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>metgroupegvfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L712" class="blob-num js-line-number" data-line-number="712"></td>
        <td id="LC712" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L713" class="blob-num js-line-number" data-line-number="713"></td>
        <td id="LC713" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L714" class="blob-num js-line-number" data-line-number="714"></td>
        <td id="LC714" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">metgroupegvfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L715" class="blob-num js-line-number" data-line-number="715"></td>
        <td id="LC715" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METGroupEGVId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met group egv id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L716" class="blob-num js-line-number" data-line-number="716"></td>
        <td id="LC716" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L717" class="blob-num js-line-number" data-line-number="717"></td>
        <td id="LC717" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L718" class="blob-num js-line-number" data-line-number="718"></td>
        <td id="LC718" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>METGroupEGVId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L719" class="blob-num js-line-number" data-line-number="719"></td>
        <td id="LC719" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L720" class="blob-num js-line-number" data-line-number="720"></td>
        <td id="LC720" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>METGroupEGV_METGroupEGVFactor_FK1<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupEGVId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L721" class="blob-num js-line-number" data-line-number="721"></td>
        <td id="LC721" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgroupegvfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L722" class="blob-num js-line-number" data-line-number="722"></td>
        <td id="LC722" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgroupegvfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupEGVId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>metgroupegv<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupEGVId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L723" class="blob-num js-line-number" data-line-number="723"></td>
        <td id="LC723" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L724" class="blob-num js-line-number" data-line-number="724"></td>
        <td id="LC724" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L725" class="blob-num js-line-number" data-line-number="725"></td>
        <td id="LC725" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L726" class="blob-num js-line-number" data-line-number="726"></td>
        <td id="LC726" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L727" class="blob-num js-line-number" data-line-number="727"></td>
        <td id="LC727" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `metgrouptrial`</span></td>
      </tr>
      <tr>
        <td id="L728" class="blob-num js-line-number" data-line-number="728"></td>
        <td id="LC728" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L729" class="blob-num js-line-number" data-line-number="729"></td>
        <td id="LC729" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L730" class="blob-num js-line-number" data-line-number="730"></td>
        <td id="LC730" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>metgrouptrial<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L731" class="blob-num js-line-number" data-line-number="731"></td>
        <td id="LC731" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L732" class="blob-num js-line-number" data-line-number="732"></td>
        <td id="LC732" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L733" class="blob-num js-line-number" data-line-number="733"></td>
        <td id="LC733" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">metgrouptrial</span>` (</td>
      </tr>
      <tr>
        <td id="L734" class="blob-num js-line-number" data-line-number="734"></td>
        <td id="LC734" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METGroupTrialId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met group trial id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L735" class="blob-num js-line-number" data-line-number="735"></td>
        <td id="LC735" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met group trial<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L736" class="blob-num js-line-number" data-line-number="736"></td>
        <td id="LC736" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L737" class="blob-num js-line-number" data-line-number="737"></td>
        <td id="LC737" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>METGroupTrialId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L738" class="blob-num js-line-number" data-line-number="738"></td>
        <td id="LC738" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>AlternateKey<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L739" class="blob-num js-line-number" data-line-number="739"></td>
        <td id="LC739" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L740" class="blob-num js-line-number" data-line-number="740"></td>
        <td id="LC740" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgrouptrial_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>metgroup<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L741" class="blob-num js-line-number" data-line-number="741"></td>
        <td id="LC741" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metgrouptrial_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trial<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L742" class="blob-num js-line-number" data-line-number="742"></td>
        <td id="LC742" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L743" class="blob-num js-line-number" data-line-number="743"></td>
        <td id="LC743" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L744" class="blob-num js-line-number" data-line-number="744"></td>
        <td id="LC744" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L745" class="blob-num js-line-number" data-line-number="745"></td>
        <td id="LC745" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L746" class="blob-num js-line-number" data-line-number="746"></td>
        <td id="LC746" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `metsubgroup`</span></td>
      </tr>
      <tr>
        <td id="L747" class="blob-num js-line-number" data-line-number="747"></td>
        <td id="LC747" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L748" class="blob-num js-line-number" data-line-number="748"></td>
        <td id="LC748" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L749" class="blob-num js-line-number" data-line-number="749"></td>
        <td id="LC749" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>metsubgroup<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L750" class="blob-num js-line-number" data-line-number="750"></td>
        <td id="LC750" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L751" class="blob-num js-line-number" data-line-number="751"></td>
        <td id="LC751" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L752" class="blob-num js-line-number" data-line-number="752"></td>
        <td id="LC752" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">metsubgroup</span>` (</td>
      </tr>
      <tr>
        <td id="L753" class="blob-num js-line-number" data-line-number="753"></td>
        <td id="LC753" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met sub group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L754" class="blob-num js-line-number" data-line-number="754"></td>
        <td id="LC754" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METSubGroupText<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met sub group description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L755" class="blob-num js-line-number" data-line-number="755"></td>
        <td id="LC755" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L756" class="blob-num js-line-number" data-line-number="756"></td>
        <td id="LC756" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>AlternateKey<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METSubGroupText<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L757" class="blob-num js-line-number" data-line-number="757"></td>
        <td id="LC757" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L758" class="blob-num js-line-number" data-line-number="758"></td>
        <td id="LC758" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L759" class="blob-num js-line-number" data-line-number="759"></td>
        <td id="LC759" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L760" class="blob-num js-line-number" data-line-number="760"></td>
        <td id="LC760" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L761" class="blob-num js-line-number" data-line-number="761"></td>
        <td id="LC761" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `metsubgroupfactor`</span></td>
      </tr>
      <tr>
        <td id="L762" class="blob-num js-line-number" data-line-number="762"></td>
        <td id="LC762" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L763" class="blob-num js-line-number" data-line-number="763"></td>
        <td id="LC763" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L764" class="blob-num js-line-number" data-line-number="764"></td>
        <td id="LC764" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>metsubgroupfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L765" class="blob-num js-line-number" data-line-number="765"></td>
        <td id="LC765" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L766" class="blob-num js-line-number" data-line-number="766"></td>
        <td id="LC766" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L767" class="blob-num js-line-number" data-line-number="767"></td>
        <td id="LC767" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">metsubgroupfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L768" class="blob-num js-line-number" data-line-number="768"></td>
        <td id="LC768" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met sub group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L769" class="blob-num js-line-number" data-line-number="769"></td>
        <td id="LC769" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L770" class="blob-num js-line-number" data-line-number="770"></td>
        <td id="LC770" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L771" class="blob-num js-line-number" data-line-number="771"></td>
        <td id="LC771" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L772" class="blob-num js-line-number" data-line-number="772"></td>
        <td id="LC772" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L773" class="blob-num js-line-number" data-line-number="773"></td>
        <td id="LC773" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>METSubGroup_METSubGroupFactor_FK1<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L774" class="blob-num js-line-number" data-line-number="774"></td>
        <td id="LC774" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metsubgroupfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L775" class="blob-num js-line-number" data-line-number="775"></td>
        <td id="LC775" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>metsubgroupfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>metsubgroup<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METSubGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L776" class="blob-num js-line-number" data-line-number="776"></td>
        <td id="LC776" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L777" class="blob-num js-line-number" data-line-number="777"></td>
        <td id="LC777" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L778" class="blob-num js-line-number" data-line-number="778"></td>
        <td id="LC778" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L779" class="blob-num js-line-number" data-line-number="779"></td>
        <td id="LC779" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L780" class="blob-num js-line-number" data-line-number="780"></td>
        <td id="LC780" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `multienvtrial`</span></td>
      </tr>
      <tr>
        <td id="L781" class="blob-num js-line-number" data-line-number="781"></td>
        <td id="LC781" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L782" class="blob-num js-line-number" data-line-number="782"></td>
        <td id="LC782" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L783" class="blob-num js-line-number" data-line-number="783"></td>
        <td id="LC783" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>multienvtrial<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L784" class="blob-num js-line-number" data-line-number="784"></td>
        <td id="LC784" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L785" class="blob-num js-line-number" data-line-number="785"></td>
        <td id="LC785" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L786" class="blob-num js-line-number" data-line-number="786"></td>
        <td id="LC786" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">multienvtrial</span>` (</td>
      </tr>
      <tr>
        <td id="L787" class="blob-num js-line-number" data-line-number="787"></td>
        <td id="LC787" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L788" class="blob-num js-line-number" data-line-number="788"></td>
        <td id="LC788" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L789" class="blob-num js-line-number" data-line-number="789"></td>
        <td id="LC789" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METStartYear<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met started (more precise date?) could be date or string(season?)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L790" class="blob-num js-line-number" data-line-number="790"></td>
        <td id="LC790" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METEndYear<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>met finished (more precise date?) should be datetime<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L791" class="blob-num js-line-number" data-line-number="791"></td>
        <td id="LC791" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>METNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">6000</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L792" class="blob-num js-line-number" data-line-number="792"></td>
        <td id="LC792" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>group id which owns the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L793" class="blob-num js-line-number" data-line-number="793"></td>
        <td id="LC793" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>group id which have some access to the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L794" class="blob-num js-line-number" data-line-number="794"></td>
        <td id="LC794" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>permission for the owner group<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L795" class="blob-num js-line-number" data-line-number="795"></td>
        <td id="LC795" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>permission for the other group<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L796" class="blob-num js-line-number" data-line-number="796"></td>
        <td id="LC796" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OtherPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>permission for the rest of system users<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L797" class="blob-num js-line-number" data-line-number="797"></td>
        <td id="LC797" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>METId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L798" class="blob-num js-line-number" data-line-number="798"></td>
        <td id="LC798" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>AlternateKey<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>METName<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L799" class="blob-num js-line-number" data-line-number="799"></td>
        <td id="LC799" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L800" class="blob-num js-line-number" data-line-number="800"></td>
        <td id="LC800" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L801" class="blob-num js-line-number" data-line-number="801"></td>
        <td id="LC801" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L802" class="blob-num js-line-number" data-line-number="802"></td>
        <td id="LC802" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L803" class="blob-num js-line-number" data-line-number="803"></td>
        <td id="LC803" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `multimedia`</span></td>
      </tr>
      <tr>
        <td id="L804" class="blob-num js-line-number" data-line-number="804"></td>
        <td id="LC804" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L805" class="blob-num js-line-number" data-line-number="805"></td>
        <td id="LC805" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L806" class="blob-num js-line-number" data-line-number="806"></td>
        <td id="LC806" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>multimedia<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L807" class="blob-num js-line-number" data-line-number="807"></td>
        <td id="LC807" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L808" class="blob-num js-line-number" data-line-number="808"></td>
        <td id="LC808" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L809" class="blob-num js-line-number" data-line-number="809"></td>
        <td id="LC809" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">multimedia</span>` (</td>
      </tr>
      <tr>
        <td id="L810" class="blob-num js-line-number" data-line-number="810"></td>
        <td id="LC810" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>MultimediaId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>internal id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L811" class="blob-num js-line-number" data-line-number="811"></td>
        <td id="LC811" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SystemTable<span class="pl-pds">`</span></span> <span class="pl-k">set</span>(<span class="pl-s"><span class="pl-pds">&#39;</span>genotype<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>specimen<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>project<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>site<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>trial<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>trialunit<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>item<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>extract<span class="pl-pds">&#39;</span></span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>name of the supported system table, for which file is attached<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L812" class="blob-num js-line-number" data-line-number="812"></td>
        <td id="LC812" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>RecordId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>record id in the table<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L813" class="blob-num js-line-number" data-line-number="813"></td>
        <td id="LC813" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>system user, who uploaded (updated) the file<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L814" class="blob-num js-line-number" data-line-number="814"></td>
        <td id="LC814" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FileType<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>file type (e.g. csv table, fasta sequence, image, video, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L815" class="blob-num js-line-number" data-line-number="815"></td>
        <td id="LC815" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OrigFileName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>name of the original file<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L816" class="blob-num js-line-number" data-line-number="816"></td>
        <td id="LC816" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>HashFileName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>hash of the orignial file name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L817" class="blob-num js-line-number" data-line-number="817"></td>
        <td id="LC817" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UploadTime<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>time of upload, update of the file<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L818" class="blob-num js-line-number" data-line-number="818"></td>
        <td id="LC818" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FileExtension<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">10</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>file extension<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L819" class="blob-num js-line-number" data-line-number="819"></td>
        <td id="LC819" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>MultimediaId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L820" class="blob-num js-line-number" data-line-number="820"></td>
        <td id="LC820" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xmme_SystemTable<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SystemTable<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L821" class="blob-num js-line-number" data-line-number="821"></td>
        <td id="LC821" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xmme_RecordId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>RecordId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L822" class="blob-num js-line-number" data-line-number="822"></td>
        <td id="LC822" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xmme_OperatorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L823" class="blob-num js-line-number" data-line-number="823"></td>
        <td id="LC823" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xmme_FileType<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FileType<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L824" class="blob-num js-line-number" data-line-number="824"></td>
        <td id="LC824" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>multimedia_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FileType<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L825" class="blob-num js-line-number" data-line-number="825"></td>
        <td id="LC825" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>multimedia_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>systemuser<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L826" class="blob-num js-line-number" data-line-number="826"></td>
        <td id="LC826" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L827" class="blob-num js-line-number" data-line-number="827"></td>
        <td id="LC827" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L828" class="blob-num js-line-number" data-line-number="828"></td>
        <td id="LC828" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L829" class="blob-num js-line-number" data-line-number="829"></td>
        <td id="LC829" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L830" class="blob-num js-line-number" data-line-number="830"></td>
        <td id="LC830" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `organisation`</span></td>
      </tr>
      <tr>
        <td id="L831" class="blob-num js-line-number" data-line-number="831"></td>
        <td id="LC831" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L832" class="blob-num js-line-number" data-line-number="832"></td>
        <td id="LC832" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L833" class="blob-num js-line-number" data-line-number="833"></td>
        <td id="LC833" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>organisation<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L834" class="blob-num js-line-number" data-line-number="834"></td>
        <td id="LC834" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L835" class="blob-num js-line-number" data-line-number="835"></td>
        <td id="LC835" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L836" class="blob-num js-line-number" data-line-number="836"></td>
        <td id="LC836" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">organisation</span>` (</td>
      </tr>
      <tr>
        <td id="L837" class="blob-num js-line-number" data-line-number="837"></td>
        <td id="LC837" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>organisation id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L838" class="blob-num js-line-number" data-line-number="838"></td>
        <td id="LC838" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OrganisationName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>organisation name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L839" class="blob-num js-line-number" data-line-number="839"></td>
        <td id="LC839" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L840" class="blob-num js-line-number" data-line-number="840"></td>
        <td id="LC840" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xo_OrganisationName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>OrganisationName<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L841" class="blob-num js-line-number" data-line-number="841"></td>
        <td id="LC841" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L842" class="blob-num js-line-number" data-line-number="842"></td>
        <td id="LC842" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L843" class="blob-num js-line-number" data-line-number="843"></td>
        <td id="LC843" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L844" class="blob-num js-line-number" data-line-number="844"></td>
        <td id="LC844" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L845" class="blob-num js-line-number" data-line-number="845"></td>
        <td id="LC845" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `organisationfactor`</span></td>
      </tr>
      <tr>
        <td id="L846" class="blob-num js-line-number" data-line-number="846"></td>
        <td id="LC846" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L847" class="blob-num js-line-number" data-line-number="847"></td>
        <td id="LC847" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L848" class="blob-num js-line-number" data-line-number="848"></td>
        <td id="LC848" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>organisationfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L849" class="blob-num js-line-number" data-line-number="849"></td>
        <td id="LC849" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L850" class="blob-num js-line-number" data-line-number="850"></td>
        <td id="LC850" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L851" class="blob-num js-line-number" data-line-number="851"></td>
        <td id="LC851" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">organisationfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L852" class="blob-num js-line-number" data-line-number="852"></td>
        <td id="LC852" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>organisation id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L853" class="blob-num js-line-number" data-line-number="853"></td>
        <td id="LC853" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L854" class="blob-num js-line-number" data-line-number="854"></td>
        <td id="LC854" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L855" class="blob-num js-line-number" data-line-number="855"></td>
        <td id="LC855" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L856" class="blob-num js-line-number" data-line-number="856"></td>
        <td id="LC856" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L857" class="blob-num js-line-number" data-line-number="857"></td>
        <td id="LC857" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>organisationfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>organisation<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>OrganisationId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L858" class="blob-num js-line-number" data-line-number="858"></td>
        <td id="LC858" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>organisationfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L859" class="blob-num js-line-number" data-line-number="859"></td>
        <td id="LC859" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L860" class="blob-num js-line-number" data-line-number="860"></td>
        <td id="LC860" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L861" class="blob-num js-line-number" data-line-number="861"></td>
        <td id="LC861" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L862" class="blob-num js-line-number" data-line-number="862"></td>
        <td id="LC862" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L863" class="blob-num js-line-number" data-line-number="863"></td>
        <td id="LC863" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `pedigree`</span></td>
      </tr>
      <tr>
        <td id="L864" class="blob-num js-line-number" data-line-number="864"></td>
        <td id="LC864" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L865" class="blob-num js-line-number" data-line-number="865"></td>
        <td id="LC865" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L866" class="blob-num js-line-number" data-line-number="866"></td>
        <td id="LC866" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>pedigree<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L867" class="blob-num js-line-number" data-line-number="867"></td>
        <td id="LC867" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L868" class="blob-num js-line-number" data-line-number="868"></td>
        <td id="LC868" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L869" class="blob-num js-line-number" data-line-number="869"></td>
        <td id="LC869" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">pedigree</span>` (</td>
      </tr>
      <tr>
        <td id="L870" class="blob-num js-line-number" data-line-number="870"></td>
        <td id="LC870" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>PedigreeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>internal record id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L871" class="blob-num js-line-number" data-line-number="871"></td>
        <td id="LC871" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the specimen<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L872" class="blob-num js-line-number" data-line-number="872"></td>
        <td id="LC872" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ParentSpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of another specimen, which is its parent<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L873" class="blob-num js-line-number" data-line-number="873"></td>
        <td id="LC873" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ParentType<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Parent type (male female self) or others as in generaltype table in class aparenta<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L874" class="blob-num js-line-number" data-line-number="874"></td>
        <td id="LC874" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SelectionReason<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">100</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Short description (optional) why the selection was made<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L875" class="blob-num js-line-number" data-line-number="875"></td>
        <td id="LC875" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>NumberOfSpecimens<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Number of Specimens: The number of a specific parent specimen used in a breeding process to make progeny specimen. e.g. FemaleSpecimenName: F; MaleSpecimenName: M; 1xF is crossed with 20xM; Pedigree holds: NumberOfSpecimens Female F is 1; NumberOfSpecimen<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L876" class="blob-num js-line-number" data-line-number="876"></td>
        <td id="LC876" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>PedigreeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L877" class="blob-num js-line-number" data-line-number="877"></td>
        <td id="LC877" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xpe_SpPaType<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>ParentSpecimenId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>ParentType<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L878" class="blob-num js-line-number" data-line-number="878"></td>
        <td id="LC878" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xpe_SpecimenId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L879" class="blob-num js-line-number" data-line-number="879"></td>
        <td id="LC879" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xpe_ParentSpecimenId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ParentSpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L880" class="blob-num js-line-number" data-line-number="880"></td>
        <td id="LC880" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xpe_ParentType<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ParentType<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L881" class="blob-num js-line-number" data-line-number="881"></td>
        <td id="LC881" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>pedigree_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ParentSpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>specimen<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L882" class="blob-num js-line-number" data-line-number="882"></td>
        <td id="LC882" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>pedigree_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>specimen<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L883" class="blob-num js-line-number" data-line-number="883"></td>
        <td id="LC883" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>pedigree_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ParentType<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L884" class="blob-num js-line-number" data-line-number="884"></td>
        <td id="LC884" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L885" class="blob-num js-line-number" data-line-number="885"></td>
        <td id="LC885" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L886" class="blob-num js-line-number" data-line-number="886"></td>
        <td id="LC886" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L887" class="blob-num js-line-number" data-line-number="887"></td>
        <td id="LC887" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L888" class="blob-num js-line-number" data-line-number="888"></td>
        <td id="LC888" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `project`</span></td>
      </tr>
      <tr>
        <td id="L889" class="blob-num js-line-number" data-line-number="889"></td>
        <td id="LC889" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L890" class="blob-num js-line-number" data-line-number="890"></td>
        <td id="LC890" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L891" class="blob-num js-line-number" data-line-number="891"></td>
        <td id="LC891" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>project<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L892" class="blob-num js-line-number" data-line-number="892"></td>
        <td id="LC892" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L893" class="blob-num js-line-number" data-line-number="893"></td>
        <td id="LC893" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L894" class="blob-num js-line-number" data-line-number="894"></td>
        <td id="LC894" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">project</span>` (</td>
      </tr>
      <tr>
        <td id="L895" class="blob-num js-line-number" data-line-number="895"></td>
        <td id="LC895" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>project id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L896" class="blob-num js-line-number" data-line-number="896"></td>
        <td id="LC896" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ProjectManagerId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>manager of the project, link to contact table<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L897" class="blob-num js-line-number" data-line-number="897"></td>
        <td id="LC897" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>project type, link to general type table class project<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L898" class="blob-num js-line-number" data-line-number="898"></td>
        <td id="LC898" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ProjectName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>project name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L899" class="blob-num js-line-number" data-line-number="899"></td>
        <td id="LC899" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ProjectStatus<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>project status (e.g. stage 2, confirmed, discontinued, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L900" class="blob-num js-line-number" data-line-number="900"></td>
        <td id="LC900" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ProjectStartDate<span class="pl-pds">`</span></span> datetime default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>start project date<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L901" class="blob-num js-line-number" data-line-number="901"></td>
        <td id="LC901" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ProjectEndDate<span class="pl-pds">`</span></span> datetime default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>end project date<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L902" class="blob-num js-line-number" data-line-number="902"></td>
        <td id="LC902" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ProjectNote<span class="pl-pds">`</span></span> mediumtext COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>project general description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L903" class="blob-num js-line-number" data-line-number="903"></td>
        <td id="LC903" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L904" class="blob-num js-line-number" data-line-number="904"></td>
        <td id="LC904" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xp_ProjectName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L905" class="blob-num js-line-number" data-line-number="905"></td>
        <td id="LC905" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xp_ProjectManagerId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectManagerId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L906" class="blob-num js-line-number" data-line-number="906"></td>
        <td id="LC906" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xp_TypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L907" class="blob-num js-line-number" data-line-number="907"></td>
        <td id="LC907" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xp_ProjectStartDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectStartDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L908" class="blob-num js-line-number" data-line-number="908"></td>
        <td id="LC908" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xp_ProjectEndDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectEndDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L909" class="blob-num js-line-number" data-line-number="909"></td>
        <td id="LC909" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xp_ProjectStatus<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectStatus<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L910" class="blob-num js-line-number" data-line-number="910"></td>
        <td id="LC910" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>project_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L911" class="blob-num js-line-number" data-line-number="911"></td>
        <td id="LC911" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>project_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectManagerId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>contact<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L912" class="blob-num js-line-number" data-line-number="912"></td>
        <td id="LC912" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L913" class="blob-num js-line-number" data-line-number="913"></td>
        <td id="LC913" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L914" class="blob-num js-line-number" data-line-number="914"></td>
        <td id="LC914" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L915" class="blob-num js-line-number" data-line-number="915"></td>
        <td id="LC915" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L916" class="blob-num js-line-number" data-line-number="916"></td>
        <td id="LC916" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `projectfactor`</span></td>
      </tr>
      <tr>
        <td id="L917" class="blob-num js-line-number" data-line-number="917"></td>
        <td id="LC917" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L918" class="blob-num js-line-number" data-line-number="918"></td>
        <td id="LC918" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L919" class="blob-num js-line-number" data-line-number="919"></td>
        <td id="LC919" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>projectfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L920" class="blob-num js-line-number" data-line-number="920"></td>
        <td id="LC920" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L921" class="blob-num js-line-number" data-line-number="921"></td>
        <td id="LC921" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L922" class="blob-num js-line-number" data-line-number="922"></td>
        <td id="LC922" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">projectfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L923" class="blob-num js-line-number" data-line-number="923"></td>
        <td id="LC923" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>project id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L924" class="blob-num js-line-number" data-line-number="924"></td>
        <td id="LC924" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L925" class="blob-num js-line-number" data-line-number="925"></td>
        <td id="LC925" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value for project factor<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L926" class="blob-num js-line-number" data-line-number="926"></td>
        <td id="LC926" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L927" class="blob-num js-line-number" data-line-number="927"></td>
        <td id="LC927" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L928" class="blob-num js-line-number" data-line-number="928"></td>
        <td id="LC928" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>projectfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>project<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L929" class="blob-num js-line-number" data-line-number="929"></td>
        <td id="LC929" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>projectfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L930" class="blob-num js-line-number" data-line-number="930"></td>
        <td id="LC930" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L931" class="blob-num js-line-number" data-line-number="931"></td>
        <td id="LC931" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L932" class="blob-num js-line-number" data-line-number="932"></td>
        <td id="LC932" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L933" class="blob-num js-line-number" data-line-number="933"></td>
        <td id="LC933" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L934" class="blob-num js-line-number" data-line-number="934"></td>
        <td id="LC934" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `reservedkeyword`</span></td>
      </tr>
      <tr>
        <td id="L935" class="blob-num js-line-number" data-line-number="935"></td>
        <td id="LC935" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L936" class="blob-num js-line-number" data-line-number="936"></td>
        <td id="LC936" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L937" class="blob-num js-line-number" data-line-number="937"></td>
        <td id="LC937" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>reservedkeyword<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L938" class="blob-num js-line-number" data-line-number="938"></td>
        <td id="LC938" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L939" class="blob-num js-line-number" data-line-number="939"></td>
        <td id="LC939" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L940" class="blob-num js-line-number" data-line-number="940"></td>
        <td id="LC940" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">reservedkeyword</span>` (</td>
      </tr>
      <tr>
        <td id="L941" class="blob-num js-line-number" data-line-number="941"></td>
        <td id="LC941" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>KeywordName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Keyword<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L942" class="blob-num js-line-number" data-line-number="942"></td>
        <td id="LC942" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ApplicationName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Application<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L943" class="blob-num js-line-number" data-line-number="943"></td>
        <td id="LC943" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>KeywordName<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L944" class="blob-num js-line-number" data-line-number="944"></td>
        <td id="LC944" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L945" class="blob-num js-line-number" data-line-number="945"></td>
        <td id="LC945" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L946" class="blob-num js-line-number" data-line-number="946"></td>
        <td id="LC946" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L947" class="blob-num js-line-number" data-line-number="947"></td>
        <td id="LC947" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L948" class="blob-num js-line-number" data-line-number="948"></td>
        <td id="LC948" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `samplemeasurement`</span></td>
      </tr>
      <tr>
        <td id="L949" class="blob-num js-line-number" data-line-number="949"></td>
        <td id="LC949" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L950" class="blob-num js-line-number" data-line-number="950"></td>
        <td id="LC950" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L951" class="blob-num js-line-number" data-line-number="951"></td>
        <td id="LC951" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>samplemeasurement<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L952" class="blob-num js-line-number" data-line-number="952"></td>
        <td id="LC952" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L953" class="blob-num js-line-number" data-line-number="953"></td>
        <td id="LC953" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L954" class="blob-num js-line-number" data-line-number="954"></td>
        <td id="LC954" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">samplemeasurement</span>` (</td>
      </tr>
      <tr>
        <td id="L955" class="blob-num js-line-number" data-line-number="955"></td>
        <td id="LC955" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial unit id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L956" class="blob-num js-line-number" data-line-number="956"></td>
        <td id="LC956" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the trait being measured<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L957" class="blob-num js-line-number" data-line-number="957"></td>
        <td id="LC957" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>user performing the measurement<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L958" class="blob-num js-line-number" data-line-number="958"></td>
        <td id="LC958" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>MeasureDateTime<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date / time of the measurement<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L959" class="blob-num js-line-number" data-line-number="959"></td>
        <td id="LC959" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>InstanceNumber<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>1<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>next consecutive number of the measurement instance if all other values of primary key are the same<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L960" class="blob-num js-line-number" data-line-number="960"></td>
        <td id="LC960" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SampleTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>sample type id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L961" class="blob-num js-line-number" data-line-number="961"></td>
        <td id="LC961" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>measurement value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L962" class="blob-num js-line-number" data-line-number="962"></td>
        <td id="LC962" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>MeasureDateTime<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>InstanceNumber<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>SampleTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L963" class="blob-num js-line-number" data-line-number="963"></td>
        <td id="LC963" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xsm_OperatorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L964" class="blob-num js-line-number" data-line-number="964"></td>
        <td id="LC964" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xsm_TraitId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L965" class="blob-num js-line-number" data-line-number="965"></td>
        <td id="LC965" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xsm_MeasureDateTime<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>MeasureDateTime<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L966" class="blob-num js-line-number" data-line-number="966"></td>
        <td id="LC966" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xsm_TrialUnitId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L967" class="blob-num js-line-number" data-line-number="967"></td>
        <td id="LC967" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xsm_SampleTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SampleTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L968" class="blob-num js-line-number" data-line-number="968"></td>
        <td id="LC968" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>samplemeasurement_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trialunit<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L969" class="blob-num js-line-number" data-line-number="969"></td>
        <td id="LC969" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>samplemeasurement_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trait<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L970" class="blob-num js-line-number" data-line-number="970"></td>
        <td id="LC970" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>samplemeasurement_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>systemuser<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L971" class="blob-num js-line-number" data-line-number="971"></td>
        <td id="LC971" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>samplemeasurement_ibfk_4<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SampleTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L972" class="blob-num js-line-number" data-line-number="972"></td>
        <td id="LC972" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L973" class="blob-num js-line-number" data-line-number="973"></td>
        <td id="LC973" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L974" class="blob-num js-line-number" data-line-number="974"></td>
        <td id="LC974" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L975" class="blob-num js-line-number" data-line-number="975"></td>
        <td id="LC975" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L976" class="blob-num js-line-number" data-line-number="976"></td>
        <td id="LC976" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `site`</span></td>
      </tr>
      <tr>
        <td id="L977" class="blob-num js-line-number" data-line-number="977"></td>
        <td id="LC977" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L978" class="blob-num js-line-number" data-line-number="978"></td>
        <td id="LC978" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L979" class="blob-num js-line-number" data-line-number="979"></td>
        <td id="LC979" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>site<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L980" class="blob-num js-line-number" data-line-number="980"></td>
        <td id="LC980" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L981" class="blob-num js-line-number" data-line-number="981"></td>
        <td id="LC981" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L982" class="blob-num js-line-number" data-line-number="982"></td>
        <td id="LC982" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">site</span>` (</td>
      </tr>
      <tr>
        <td id="L983" class="blob-num js-line-number" data-line-number="983"></td>
        <td id="LC983" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>site id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L984" class="blob-num js-line-number" data-line-number="984"></td>
        <td id="LC984" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SiteTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>site type id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L985" class="blob-num js-line-number" data-line-number="985"></td>
        <td id="LC985" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SiteName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L986" class="blob-num js-line-number" data-line-number="986"></td>
        <td id="LC986" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SiteAcronym<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">5</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>short name of the site, can be used as e.g. part of the trial naming convention<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L987" class="blob-num js-line-number" data-line-number="987"></td>
        <td id="LC987" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>CurrentSiteManagerId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>person currently managing the site, not necessarily a user of this system, so linked to the contactId<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L988" class="blob-num js-line-number" data-line-number="988"></td>
        <td id="LC988" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SiteStartDate<span class="pl-pds">`</span></span> datetime default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Date when site started to exist<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L989" class="blob-num js-line-number" data-line-number="989"></td>
        <td id="LC989" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SiteEndDate<span class="pl-pds">`</span></span> datetime default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Date when site stopped to exist<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L990" class="blob-num js-line-number" data-line-number="990"></td>
        <td id="LC990" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L991" class="blob-num js-line-number" data-line-number="991"></td>
        <td id="LC991" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xs_SiteName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SiteName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L992" class="blob-num js-line-number" data-line-number="992"></td>
        <td id="LC992" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xs_CurrentSiteManagerId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>CurrentSiteManagerId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L993" class="blob-num js-line-number" data-line-number="993"></td>
        <td id="LC993" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xs_SiteAcronym<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SiteAcronym<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L994" class="blob-num js-line-number" data-line-number="994"></td>
        <td id="LC994" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xs_SiteStartDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SiteStartDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L995" class="blob-num js-line-number" data-line-number="995"></td>
        <td id="LC995" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xs_SiteEndDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SiteEndDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L996" class="blob-num js-line-number" data-line-number="996"></td>
        <td id="LC996" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>SiteTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SiteTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L997" class="blob-num js-line-number" data-line-number="997"></td>
        <td id="LC997" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>site_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>CurrentSiteManagerId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>contact<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L998" class="blob-num js-line-number" data-line-number="998"></td>
        <td id="LC998" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>site_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SiteTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L999" class="blob-num js-line-number" data-line-number="999"></td>
        <td id="LC999" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1000" class="blob-num js-line-number" data-line-number="1000"></td>
        <td id="LC1000" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1001" class="blob-num js-line-number" data-line-number="1001"></td>
        <td id="LC1001" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1002" class="blob-num js-line-number" data-line-number="1002"></td>
        <td id="LC1002" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1003" class="blob-num js-line-number" data-line-number="1003"></td>
        <td id="LC1003" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `sitefactor`</span></td>
      </tr>
      <tr>
        <td id="L1004" class="blob-num js-line-number" data-line-number="1004"></td>
        <td id="LC1004" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1005" class="blob-num js-line-number" data-line-number="1005"></td>
        <td id="LC1005" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1006" class="blob-num js-line-number" data-line-number="1006"></td>
        <td id="LC1006" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>sitefactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1007" class="blob-num js-line-number" data-line-number="1007"></td>
        <td id="LC1007" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1008" class="blob-num js-line-number" data-line-number="1008"></td>
        <td id="LC1008" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1009" class="blob-num js-line-number" data-line-number="1009"></td>
        <td id="LC1009" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">sitefactor</span>` (</td>
      </tr>
      <tr>
        <td id="L1010" class="blob-num js-line-number" data-line-number="1010"></td>
        <td id="LC1010" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>site id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1011" class="blob-num js-line-number" data-line-number="1011"></td>
        <td id="LC1011" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1012" class="blob-num js-line-number" data-line-number="1012"></td>
        <td id="LC1012" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1013" class="blob-num js-line-number" data-line-number="1013"></td>
        <td id="LC1013" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1014" class="blob-num js-line-number" data-line-number="1014"></td>
        <td id="LC1014" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1015" class="blob-num js-line-number" data-line-number="1015"></td>
        <td id="LC1015" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>sitefactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1016" class="blob-num js-line-number" data-line-number="1016"></td>
        <td id="LC1016" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>sitefactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>site<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1017" class="blob-num js-line-number" data-line-number="1017"></td>
        <td id="LC1017" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1018" class="blob-num js-line-number" data-line-number="1018"></td>
        <td id="LC1018" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1019" class="blob-num js-line-number" data-line-number="1019"></td>
        <td id="LC1019" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1020" class="blob-num js-line-number" data-line-number="1020"></td>
        <td id="LC1020" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1021" class="blob-num js-line-number" data-line-number="1021"></td>
        <td id="LC1021" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `specimen`</span></td>
      </tr>
      <tr>
        <td id="L1022" class="blob-num js-line-number" data-line-number="1022"></td>
        <td id="LC1022" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1023" class="blob-num js-line-number" data-line-number="1023"></td>
        <td id="LC1023" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1024" class="blob-num js-line-number" data-line-number="1024"></td>
        <td id="LC1024" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>specimen<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1025" class="blob-num js-line-number" data-line-number="1025"></td>
        <td id="LC1025" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1026" class="blob-num js-line-number" data-line-number="1026"></td>
        <td id="LC1026" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1027" class="blob-num js-line-number" data-line-number="1027"></td>
        <td id="LC1027" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">specimen</span>` (</td>
      </tr>
      <tr>
        <td id="L1028" class="blob-num js-line-number" data-line-number="1028"></td>
        <td id="LC1028" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Individual specimen id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1029" class="blob-num js-line-number" data-line-number="1029"></td>
        <td id="LC1029" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the breeding method<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1030" class="blob-num js-line-number" data-line-number="1030"></td>
        <td id="LC1030" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Specimen name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1031" class="blob-num js-line-number" data-line-number="1031"></td>
        <td id="LC1031" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenBarcode<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Optional specimen barcode - if assigned could be printed on label<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1032" class="blob-num js-line-number" data-line-number="1032"></td>
        <td id="LC1032" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>IsActive<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">2</span>) default <span class="pl-s"><span class="pl-pds">&#39;</span>1<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Set to 0 if we want to indicate that it is no longer in production, program or some other binary switch<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1033" class="blob-num js-line-number" data-line-number="1033"></td>
        <td id="LC1033" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Pedigree<span class="pl-pds">`</span></span> mediumtext COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Could be generated Purdy string from male and female parent ID (or some other than Purdy standard)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1034" class="blob-num js-line-number" data-line-number="1034"></td>
        <td id="LC1034" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SelectionHistory<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Can be siblings clones etc, where genotype name is the same. pulses use this a lot<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1035" class="blob-num js-line-number" data-line-number="1035"></td>
        <td id="LC1035" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FilialGeneration<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Level of specimens being selfed, required when full selection history is not available<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1036" class="blob-num js-line-number" data-line-number="1036"></td>
        <td id="LC1036" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1037" class="blob-num js-line-number" data-line-number="1037"></td>
        <td id="LC1037" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xs_SpecimenName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1038" class="blob-num js-line-number" data-line-number="1038"></td>
        <td id="LC1038" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xs_SpecimenBarcode<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenBarcode<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1039" class="blob-num js-line-number" data-line-number="1039"></td>
        <td id="LC1039" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xs_BreedingMethodId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1040" class="blob-num js-line-number" data-line-number="1040"></td>
        <td id="LC1040" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xs_IsActive<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>IsActive<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1041" class="blob-num js-line-number" data-line-number="1041"></td>
        <td id="LC1041" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>specimen_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>breedingmethod<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>BreedingMethodId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1042" class="blob-num js-line-number" data-line-number="1042"></td>
        <td id="LC1042" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1043" class="blob-num js-line-number" data-line-number="1043"></td>
        <td id="LC1043" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1044" class="blob-num js-line-number" data-line-number="1044"></td>
        <td id="LC1044" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1045" class="blob-num js-line-number" data-line-number="1045"></td>
        <td id="LC1045" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1046" class="blob-num js-line-number" data-line-number="1046"></td>
        <td id="LC1046" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `specimenfactor`</span></td>
      </tr>
      <tr>
        <td id="L1047" class="blob-num js-line-number" data-line-number="1047"></td>
        <td id="LC1047" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1048" class="blob-num js-line-number" data-line-number="1048"></td>
        <td id="LC1048" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1049" class="blob-num js-line-number" data-line-number="1049"></td>
        <td id="LC1049" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>specimenfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1050" class="blob-num js-line-number" data-line-number="1050"></td>
        <td id="LC1050" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1051" class="blob-num js-line-number" data-line-number="1051"></td>
        <td id="LC1051" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1052" class="blob-num js-line-number" data-line-number="1052"></td>
        <td id="LC1052" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">specimenfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L1053" class="blob-num js-line-number" data-line-number="1053"></td>
        <td id="LC1053" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span>,</td>
      </tr>
      <tr>
        <td id="L1054" class="blob-num js-line-number" data-line-number="1054"></td>
        <td id="LC1054" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span>,</td>
      </tr>
      <tr>
        <td id="L1055" class="blob-num js-line-number" data-line-number="1055"></td>
        <td id="LC1055" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span>,</td>
      </tr>
      <tr>
        <td id="L1056" class="blob-num js-line-number" data-line-number="1056"></td>
        <td id="LC1056" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1057" class="blob-num js-line-number" data-line-number="1057"></td>
        <td id="LC1057" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1058" class="blob-num js-line-number" data-line-number="1058"></td>
        <td id="LC1058" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1059" class="blob-num js-line-number" data-line-number="1059"></td>
        <td id="LC1059" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>specimenfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>specimen<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1060" class="blob-num js-line-number" data-line-number="1060"></td>
        <td id="LC1060" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>specimenfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1061" class="blob-num js-line-number" data-line-number="1061"></td>
        <td id="LC1061" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1062" class="blob-num js-line-number" data-line-number="1062"></td>
        <td id="LC1062" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1063" class="blob-num js-line-number" data-line-number="1063"></td>
        <td id="LC1063" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1064" class="blob-num js-line-number" data-line-number="1064"></td>
        <td id="LC1064" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1065" class="blob-num js-line-number" data-line-number="1065"></td>
        <td id="LC1065" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `specimengroup`</span></td>
      </tr>
      <tr>
        <td id="L1066" class="blob-num js-line-number" data-line-number="1066"></td>
        <td id="LC1066" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1067" class="blob-num js-line-number" data-line-number="1067"></td>
        <td id="LC1067" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1068" class="blob-num js-line-number" data-line-number="1068"></td>
        <td id="LC1068" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>specimengroup<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1069" class="blob-num js-line-number" data-line-number="1069"></td>
        <td id="LC1069" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1070" class="blob-num js-line-number" data-line-number="1070"></td>
        <td id="LC1070" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1071" class="blob-num js-line-number" data-line-number="1071"></td>
        <td id="LC1071" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">specimengroup</span>` (</td>
      </tr>
      <tr>
        <td id="L1072" class="blob-num js-line-number" data-line-number="1072"></td>
        <td id="LC1072" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the group of specimens<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1073" class="blob-num js-line-number" data-line-number="1073"></td>
        <td id="LC1073" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the specimen group type<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1074" class="blob-num js-line-number" data-line-number="1074"></td>
        <td id="LC1074" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>group name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1075" class="blob-num js-line-number" data-line-number="1075"></td>
        <td id="LC1075" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1076" class="blob-num js-line-number" data-line-number="1076"></td>
        <td id="LC1076" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1077" class="blob-num js-line-number" data-line-number="1077"></td>
        <td id="LC1077" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xsg_SpecimenGroupName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1078" class="blob-num js-line-number" data-line-number="1078"></td>
        <td id="LC1078" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xsg_SpecimenGroupTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1079" class="blob-num js-line-number" data-line-number="1079"></td>
        <td id="LC1079" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>specimengroup_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1080" class="blob-num js-line-number" data-line-number="1080"></td>
        <td id="LC1080" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1081" class="blob-num js-line-number" data-line-number="1081"></td>
        <td id="LC1081" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1082" class="blob-num js-line-number" data-line-number="1082"></td>
        <td id="LC1082" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1083" class="blob-num js-line-number" data-line-number="1083"></td>
        <td id="LC1083" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1084" class="blob-num js-line-number" data-line-number="1084"></td>
        <td id="LC1084" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `specimengroupentry`</span></td>
      </tr>
      <tr>
        <td id="L1085" class="blob-num js-line-number" data-line-number="1085"></td>
        <td id="LC1085" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1086" class="blob-num js-line-number" data-line-number="1086"></td>
        <td id="LC1086" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1087" class="blob-num js-line-number" data-line-number="1087"></td>
        <td id="LC1087" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>specimengroupentry<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1088" class="blob-num js-line-number" data-line-number="1088"></td>
        <td id="LC1088" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1089" class="blob-num js-line-number" data-line-number="1089"></td>
        <td id="LC1089" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1090" class="blob-num js-line-number" data-line-number="1090"></td>
        <td id="LC1090" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">specimengroupentry</span>` (</td>
      </tr>
      <tr>
        <td id="L1091" class="blob-num js-line-number" data-line-number="1091"></td>
        <td id="LC1091" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupEntryId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>entry id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1092" class="blob-num js-line-number" data-line-number="1092"></td>
        <td id="LC1092" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>specimen id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1093" class="blob-num js-line-number" data-line-number="1093"></td>
        <td id="LC1093" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>specimen group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1094" class="blob-num js-line-number" data-line-number="1094"></td>
        <td id="LC1094" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>special note for this specimen in the group<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1095" class="blob-num js-line-number" data-line-number="1095"></td>
        <td id="LC1095" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupEntryId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1096" class="blob-num js-line-number" data-line-number="1096"></td>
        <td id="LC1096" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xsge_SpecimenId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1097" class="blob-num js-line-number" data-line-number="1097"></td>
        <td id="LC1097" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xsge_SpecimenGroupId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1098" class="blob-num js-line-number" data-line-number="1098"></td>
        <td id="LC1098" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>specimengroupentry_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>specimengroup<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenGroupId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1099" class="blob-num js-line-number" data-line-number="1099"></td>
        <td id="LC1099" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>specimengroupentry_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>specimen<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1100" class="blob-num js-line-number" data-line-number="1100"></td>
        <td id="LC1100" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1101" class="blob-num js-line-number" data-line-number="1101"></td>
        <td id="LC1101" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1102" class="blob-num js-line-number" data-line-number="1102"></td>
        <td id="LC1102" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1103" class="blob-num js-line-number" data-line-number="1103"></td>
        <td id="LC1103" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1104" class="blob-num js-line-number" data-line-number="1104"></td>
        <td id="LC1104" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `storage`</span></td>
      </tr>
      <tr>
        <td id="L1105" class="blob-num js-line-number" data-line-number="1105"></td>
        <td id="LC1105" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1106" class="blob-num js-line-number" data-line-number="1106"></td>
        <td id="LC1106" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1107" class="blob-num js-line-number" data-line-number="1107"></td>
        <td id="LC1107" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>storage<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1108" class="blob-num js-line-number" data-line-number="1108"></td>
        <td id="LC1108" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1109" class="blob-num js-line-number" data-line-number="1109"></td>
        <td id="LC1109" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1110" class="blob-num js-line-number" data-line-number="1110"></td>
        <td id="LC1110" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">storage</span>` (</td>
      </tr>
      <tr>
        <td id="L1111" class="blob-num js-line-number" data-line-number="1111"></td>
        <td id="LC1111" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StorageId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the storage position<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1112" class="blob-num js-line-number" data-line-number="1112"></td>
        <td id="LC1112" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StorageBarcode<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>barcode of the storage position<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1113" class="blob-num js-line-number" data-line-number="1113"></td>
        <td id="LC1113" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StorageLocation<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>location of the storage (e.g. building, room, freezer, shelf, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1114" class="blob-num js-line-number" data-line-number="1114"></td>
        <td id="LC1114" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StorageParentId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the parent storage (e.g. for room parent storage could be building where the room is located)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1115" class="blob-num js-line-number" data-line-number="1115"></td>
        <td id="LC1115" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StorageDetails<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>more info about a storage<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1116" class="blob-num js-line-number" data-line-number="1116"></td>
        <td id="LC1116" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StorageNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>detailed storage description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1117" class="blob-num js-line-number" data-line-number="1117"></td>
        <td id="LC1117" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>StorageId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1118" class="blob-num js-line-number" data-line-number="1118"></td>
        <td id="LC1118" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xs_StorageBarcode<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>StorageBarcode<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1119" class="blob-num js-line-number" data-line-number="1119"></td>
        <td id="LC1119" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xs_StorageLocation<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>StorageLocation<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1120" class="blob-num js-line-number" data-line-number="1120"></td>
        <td id="LC1120" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xs_StorageParentId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>StorageParentId<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L1121" class="blob-num js-line-number" data-line-number="1121"></td>
        <td id="LC1121" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1122" class="blob-num js-line-number" data-line-number="1122"></td>
        <td id="LC1122" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1123" class="blob-num js-line-number" data-line-number="1123"></td>
        <td id="LC1123" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1124" class="blob-num js-line-number" data-line-number="1124"></td>
        <td id="LC1124" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1125" class="blob-num js-line-number" data-line-number="1125"></td>
        <td id="LC1125" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `systemgroup`</span></td>
      </tr>
      <tr>
        <td id="L1126" class="blob-num js-line-number" data-line-number="1126"></td>
        <td id="LC1126" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1127" class="blob-num js-line-number" data-line-number="1127"></td>
        <td id="LC1127" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1128" class="blob-num js-line-number" data-line-number="1128"></td>
        <td id="LC1128" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>systemgroup<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1129" class="blob-num js-line-number" data-line-number="1129"></td>
        <td id="LC1129" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1130" class="blob-num js-line-number" data-line-number="1130"></td>
        <td id="LC1130" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1131" class="blob-num js-line-number" data-line-number="1131"></td>
        <td id="LC1131" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">systemgroup</span>` (</td>
      </tr>
      <tr>
        <td id="L1132" class="blob-num js-line-number" data-line-number="1132"></td>
        <td id="LC1132" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SystemGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>system group id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1133" class="blob-num js-line-number" data-line-number="1133"></td>
        <td id="LC1133" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SystemGroupName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>system group name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1134" class="blob-num js-line-number" data-line-number="1134"></td>
        <td id="LC1134" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SystemGroupDescription<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>system group description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1135" class="blob-num js-line-number" data-line-number="1135"></td>
        <td id="LC1135" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>SystemGroupId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1136" class="blob-num js-line-number" data-line-number="1136"></td>
        <td id="LC1136" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xsg_SystemGroupName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SystemGroupName<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L1137" class="blob-num js-line-number" data-line-number="1137"></td>
        <td id="LC1137" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1138" class="blob-num js-line-number" data-line-number="1138"></td>
        <td id="LC1138" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1139" class="blob-num js-line-number" data-line-number="1139"></td>
        <td id="LC1139" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1140" class="blob-num js-line-number" data-line-number="1140"></td>
        <td id="LC1140" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1141" class="blob-num js-line-number" data-line-number="1141"></td>
        <td id="LC1141" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `systemuser`</span></td>
      </tr>
      <tr>
        <td id="L1142" class="blob-num js-line-number" data-line-number="1142"></td>
        <td id="LC1142" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1143" class="blob-num js-line-number" data-line-number="1143"></td>
        <td id="LC1143" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1144" class="blob-num js-line-number" data-line-number="1144"></td>
        <td id="LC1144" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>systemuser<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1145" class="blob-num js-line-number" data-line-number="1145"></td>
        <td id="LC1145" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1146" class="blob-num js-line-number" data-line-number="1146"></td>
        <td id="LC1146" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1147" class="blob-num js-line-number" data-line-number="1147"></td>
        <td id="LC1147" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">systemuser</span>` (</td>
      </tr>
      <tr>
        <td id="L1148" class="blob-num js-line-number" data-line-number="1148"></td>
        <td id="LC1148" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>user id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1149" class="blob-num js-line-number" data-line-number="1149"></td>
        <td id="LC1149" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UserName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>user name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1150" class="blob-num js-line-number" data-line-number="1150"></td>
        <td id="LC1150" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UserPassword<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">128</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>user password<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1151" class="blob-num js-line-number" data-line-number="1151"></td>
        <td id="LC1151" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>PasswordSalt<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>password salt (used to hash/encrypt password?)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1152" class="blob-num js-line-number" data-line-number="1152"></td>
        <td id="LC1152" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>contact id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1153" class="blob-num js-line-number" data-line-number="1153"></td>
        <td id="LC1153" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>LastLoginDateTime<span class="pl-pds">`</span></span> datetime default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date and time of last logon<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1154" class="blob-num js-line-number" data-line-number="1154"></td>
        <td id="LC1154" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UserPreference<span class="pl-pds">`</span></span> mediumtext COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>what preferences are stored here and in what format?<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1155" class="blob-num js-line-number" data-line-number="1155"></td>
        <td id="LC1155" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UserType<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">20</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>distinguish between humans and mechanical devices for data input or processing<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1156" class="blob-num js-line-number" data-line-number="1156"></td>
        <td id="LC1156" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1157" class="blob-num js-line-number" data-line-number="1157"></td>
        <td id="LC1157" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xsu_UserName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1158" class="blob-num js-line-number" data-line-number="1158"></td>
        <td id="LC1158" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xsu_ContactId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1159" class="blob-num js-line-number" data-line-number="1159"></td>
        <td id="LC1159" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>systemuser_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>contact<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1160" class="blob-num js-line-number" data-line-number="1160"></td>
        <td id="LC1160" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1161" class="blob-num js-line-number" data-line-number="1161"></td>
        <td id="LC1161" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1162" class="blob-num js-line-number" data-line-number="1162"></td>
        <td id="LC1162" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1163" class="blob-num js-line-number" data-line-number="1163"></td>
        <td id="LC1163" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1164" class="blob-num js-line-number" data-line-number="1164"></td>
        <td id="LC1164" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trait`</span></td>
      </tr>
      <tr>
        <td id="L1165" class="blob-num js-line-number" data-line-number="1165"></td>
        <td id="LC1165" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1166" class="blob-num js-line-number" data-line-number="1166"></td>
        <td id="LC1166" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1167" class="blob-num js-line-number" data-line-number="1167"></td>
        <td id="LC1167" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trait<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1168" class="blob-num js-line-number" data-line-number="1168"></td>
        <td id="LC1168" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1169" class="blob-num js-line-number" data-line-number="1169"></td>
        <td id="LC1169" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1170" class="blob-num js-line-number" data-line-number="1170"></td>
        <td id="LC1170" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trait</span>` (</td>
      </tr>
      <tr>
        <td id="L1171" class="blob-num js-line-number" data-line-number="1171"></td>
        <td id="LC1171" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trait id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1172" class="blob-num js-line-number" data-line-number="1172"></td>
        <td id="LC1172" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitGroupTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>optional - class traitgroup - (e.g. all plant height related traits can be grouped in aplantheighta type<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1173" class="blob-num js-line-number" data-line-number="1173"></td>
        <td id="LC1173" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trait name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1174" class="blob-num js-line-number" data-line-number="1174"></td>
        <td id="LC1174" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitCaption<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trait name (e.g. to display) shorter version or e.g. name without spaces<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1175" class="blob-num js-line-number" data-line-number="1175"></td>
        <td id="LC1175" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitDescription<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>description about trait<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1176" class="blob-num js-line-number" data-line-number="1176"></td>
        <td id="LC1176" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitDataType<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">8</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>data type (e.g. varchar, integer, etc)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1177" class="blob-num js-line-number" data-line-number="1177"></td>
        <td id="LC1177" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitValueMaxLength<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>max length of the value (e.g. 12)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1178" class="blob-num js-line-number" data-line-number="1178"></td>
        <td id="LC1178" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitUnit<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>FK to unit definitions<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1179" class="blob-num js-line-number" data-line-number="1179"></td>
        <td id="LC1179" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>IsTraitUsedForAnalysis<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">1</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>flag - can be used to streamline export, e.g export all that need analysis<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1180" class="blob-num js-line-number" data-line-number="1180"></td>
        <td id="LC1180" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitValRule<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>validation rule for the value of the trait<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1181" class="blob-num js-line-number" data-line-number="1181"></td>
        <td id="LC1181" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitValRuleErrMsg<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>error message to display, when validation rule criteria are not met<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1182" class="blob-num js-line-number" data-line-number="1182"></td>
        <td id="LC1182" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>group id owning the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1183" class="blob-num js-line-number" data-line-number="1183"></td>
        <td id="LC1183" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>group id with some access to the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1184" class="blob-num js-line-number" data-line-number="1184"></td>
        <td id="LC1184" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>owning group permissions<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1185" class="blob-num js-line-number" data-line-number="1185"></td>
        <td id="LC1185" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>other group permissions<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1186" class="blob-num js-line-number" data-line-number="1186"></td>
        <td id="LC1186" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OtherPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>all system users permissions<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1187" class="blob-num js-line-number" data-line-number="1187"></td>
        <td id="LC1187" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1188" class="blob-num js-line-number" data-line-number="1188"></td>
        <td id="LC1188" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xt_TraitName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1189" class="blob-num js-line-number" data-line-number="1189"></td>
        <td id="LC1189" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xt_TraitCaption<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitCaption<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1190" class="blob-num js-line-number" data-line-number="1190"></td>
        <td id="LC1190" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xt_TraitGroupTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitGroupTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1191" class="blob-num js-line-number" data-line-number="1191"></td>
        <td id="LC1191" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xt_TraitUnit<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitUnit<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1192" class="blob-num js-line-number" data-line-number="1192"></td>
        <td id="LC1192" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trait_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TraitUnit<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>itemunit<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemUnitId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1193" class="blob-num js-line-number" data-line-number="1193"></td>
        <td id="LC1193" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trait_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TraitGroupTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1194" class="blob-num js-line-number" data-line-number="1194"></td>
        <td id="LC1194" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1195" class="blob-num js-line-number" data-line-number="1195"></td>
        <td id="LC1195" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1196" class="blob-num js-line-number" data-line-number="1196"></td>
        <td id="LC1196" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1197" class="blob-num js-line-number" data-line-number="1197"></td>
        <td id="LC1197" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1198" class="blob-num js-line-number" data-line-number="1198"></td>
        <td id="LC1198" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `traitalias`</span></td>
      </tr>
      <tr>
        <td id="L1199" class="blob-num js-line-number" data-line-number="1199"></td>
        <td id="LC1199" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1200" class="blob-num js-line-number" data-line-number="1200"></td>
        <td id="LC1200" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1201" class="blob-num js-line-number" data-line-number="1201"></td>
        <td id="LC1201" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>traitalias<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1202" class="blob-num js-line-number" data-line-number="1202"></td>
        <td id="LC1202" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1203" class="blob-num js-line-number" data-line-number="1203"></td>
        <td id="LC1203" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1204" class="blob-num js-line-number" data-line-number="1204"></td>
        <td id="LC1204" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">traitalias</span>` (</td>
      </tr>
      <tr>
        <td id="L1205" class="blob-num js-line-number" data-line-number="1205"></td>
        <td id="LC1205" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitAliasId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trait alias id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1206" class="blob-num js-line-number" data-line-number="1206"></td>
        <td id="LC1206" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trait id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1207" class="blob-num js-line-number" data-line-number="1207"></td>
        <td id="LC1207" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitAliasName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>name of trait alias<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1208" class="blob-num js-line-number" data-line-number="1208"></td>
        <td id="LC1208" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitAliasCaption<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">64</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>caption of the trait alias<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1209" class="blob-num js-line-number" data-line-number="1209"></td>
        <td id="LC1209" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitAliasDescription<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>description of the trait alias<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1210" class="blob-num js-line-number" data-line-number="1210"></td>
        <td id="LC1210" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitAliasValueRuleErrMsg<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value rule error message of the trait alias<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1211" class="blob-num js-line-number" data-line-number="1211"></td>
        <td id="LC1211" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitLang<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">6</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>language code (e.g. en for English, sp for Spanish etc) in case trait alias is just a trait translation<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1212" class="blob-num js-line-number" data-line-number="1212"></td>
        <td id="LC1212" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TraitAliasId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1213" class="blob-num js-line-number" data-line-number="1213"></td>
        <td id="LC1213" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xta_TraitAliasName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitAliasName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1214" class="blob-num js-line-number" data-line-number="1214"></td>
        <td id="LC1214" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xta_TraitId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1215" class="blob-num js-line-number" data-line-number="1215"></td>
        <td id="LC1215" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xta_TraitLang<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitLang<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1216" class="blob-num js-line-number" data-line-number="1216"></td>
        <td id="LC1216" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>traitalias_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trait<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1217" class="blob-num js-line-number" data-line-number="1217"></td>
        <td id="LC1217" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1218" class="blob-num js-line-number" data-line-number="1218"></td>
        <td id="LC1218" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1219" class="blob-num js-line-number" data-line-number="1219"></td>
        <td id="LC1219" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1220" class="blob-num js-line-number" data-line-number="1220"></td>
        <td id="LC1220" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1221" class="blob-num js-line-number" data-line-number="1221"></td>
        <td id="LC1221" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `treatment`</span></td>
      </tr>
      <tr>
        <td id="L1222" class="blob-num js-line-number" data-line-number="1222"></td>
        <td id="LC1222" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1223" class="blob-num js-line-number" data-line-number="1223"></td>
        <td id="LC1223" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1224" class="blob-num js-line-number" data-line-number="1224"></td>
        <td id="LC1224" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>treatment<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1225" class="blob-num js-line-number" data-line-number="1225"></td>
        <td id="LC1225" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1226" class="blob-num js-line-number" data-line-number="1226"></td>
        <td id="LC1226" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1227" class="blob-num js-line-number" data-line-number="1227"></td>
        <td id="LC1227" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">treatment</span>` (</td>
      </tr>
      <tr>
        <td id="L1228" class="blob-num js-line-number" data-line-number="1228"></td>
        <td id="LC1228" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>treatment id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1229" class="blob-num js-line-number" data-line-number="1229"></td>
        <td id="LC1229" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TreatmentText<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>treatment description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1230" class="blob-num js-line-number" data-line-number="1230"></td>
        <td id="LC1230" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1231" class="blob-num js-line-number" data-line-number="1231"></td>
        <td id="LC1231" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xt_TreatmentText<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentText<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L1232" class="blob-num js-line-number" data-line-number="1232"></td>
        <td id="LC1232" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1233" class="blob-num js-line-number" data-line-number="1233"></td>
        <td id="LC1233" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1234" class="blob-num js-line-number" data-line-number="1234"></td>
        <td id="LC1234" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1235" class="blob-num js-line-number" data-line-number="1235"></td>
        <td id="LC1235" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1236" class="blob-num js-line-number" data-line-number="1236"></td>
        <td id="LC1236" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `treatmentfactor`</span></td>
      </tr>
      <tr>
        <td id="L1237" class="blob-num js-line-number" data-line-number="1237"></td>
        <td id="LC1237" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1238" class="blob-num js-line-number" data-line-number="1238"></td>
        <td id="LC1238" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1239" class="blob-num js-line-number" data-line-number="1239"></td>
        <td id="LC1239" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>treatmentfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1240" class="blob-num js-line-number" data-line-number="1240"></td>
        <td id="LC1240" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1241" class="blob-num js-line-number" data-line-number="1241"></td>
        <td id="LC1241" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1242" class="blob-num js-line-number" data-line-number="1242"></td>
        <td id="LC1242" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">treatmentfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L1243" class="blob-num js-line-number" data-line-number="1243"></td>
        <td id="LC1243" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>treatment id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1244" class="blob-num js-line-number" data-line-number="1244"></td>
        <td id="LC1244" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1245" class="blob-num js-line-number" data-line-number="1245"></td>
        <td id="LC1245" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1246" class="blob-num js-line-number" data-line-number="1246"></td>
        <td id="LC1246" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1247" class="blob-num js-line-number" data-line-number="1247"></td>
        <td id="LC1247" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1248" class="blob-num js-line-number" data-line-number="1248"></td>
        <td id="LC1248" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>treatmentfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1249" class="blob-num js-line-number" data-line-number="1249"></td>
        <td id="LC1249" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>treatmentfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>treatment<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1250" class="blob-num js-line-number" data-line-number="1250"></td>
        <td id="LC1250" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1251" class="blob-num js-line-number" data-line-number="1251"></td>
        <td id="LC1251" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1252" class="blob-num js-line-number" data-line-number="1252"></td>
        <td id="LC1252" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1253" class="blob-num js-line-number" data-line-number="1253"></td>
        <td id="LC1253" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1254" class="blob-num js-line-number" data-line-number="1254"></td>
        <td id="LC1254" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trial`</span></td>
      </tr>
      <tr>
        <td id="L1255" class="blob-num js-line-number" data-line-number="1255"></td>
        <td id="LC1255" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1256" class="blob-num js-line-number" data-line-number="1256"></td>
        <td id="LC1256" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1257" class="blob-num js-line-number" data-line-number="1257"></td>
        <td id="LC1257" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trial<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1258" class="blob-num js-line-number" data-line-number="1258"></td>
        <td id="LC1258" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1259" class="blob-num js-line-number" data-line-number="1259"></td>
        <td id="LC1259" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1260" class="blob-num js-line-number" data-line-number="1260"></td>
        <td id="LC1260" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trial</span>` (</td>
      </tr>
      <tr>
        <td id="L1261" class="blob-num js-line-number" data-line-number="1261"></td>
        <td id="LC1261" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1262" class="blob-num js-line-number" data-line-number="1262"></td>
        <td id="LC1262" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the project that trial belongs to, it is optional<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1263" class="blob-num js-line-number" data-line-number="1263"></td>
        <td id="LC1263" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>CurrentWorkflowId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>current workflow id to identify which workflow is currently assigned to trial. Optional as trial may not have a workflow assigned at all.<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1264" class="blob-num js-line-number" data-line-number="1264"></td>
        <td id="LC1264" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial type id (general type, different from design type, which is trial specific definition)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1265" class="blob-num js-line-number" data-line-number="1265"></td>
        <td id="LC1265" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>site id, to which trial belongs to<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1266" class="blob-num js-line-number" data-line-number="1266"></td>
        <td id="LC1266" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">100</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Trial name (can be created as concatenation of site, type, date, number)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1267" class="blob-num js-line-number" data-line-number="1267"></td>
        <td id="LC1267" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialNumber<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial running number<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1268" class="blob-num js-line-number" data-line-number="1268"></td>
        <td id="LC1268" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialAcronym<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">30</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>alternative short name for a trial<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1269" class="blob-num js-line-number" data-line-number="1269"></td>
        <td id="LC1269" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>DesignTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>design type - relation to design type table<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1270" class="blob-num js-line-number" data-line-number="1270"></td>
        <td id="LC1270" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialManagerId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>person managing trial<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1271" class="blob-num js-line-number" data-line-number="1271"></td>
        <td id="LC1271" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialStartDate<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>when started<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1272" class="blob-num js-line-number" data-line-number="1272"></td>
        <td id="LC1272" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialEndDate<span class="pl-pds">`</span></span> datetime default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>when finished<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1273" class="blob-num js-line-number" data-line-number="1273"></td>
        <td id="LC1273" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">6000</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>description text<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1274" class="blob-num js-line-number" data-line-number="1274"></td>
        <td id="LC1274" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the group which owns the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1275" class="blob-num js-line-number" data-line-number="1275"></td>
        <td id="LC1275" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the group which have permissions to the record (different to the own group)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1276" class="blob-num js-line-number" data-line-number="1276"></td>
        <td id="LC1276" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>permissions of the own group to the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1277" class="blob-num js-line-number" data-line-number="1277"></td>
        <td id="LC1277" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>permissions of the other group to the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1278" class="blob-num js-line-number" data-line-number="1278"></td>
        <td id="LC1278" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OtherPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>permissions for all registered users to the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1279" class="blob-num js-line-number" data-line-number="1279"></td>
        <td id="LC1279" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1280" class="blob-num js-line-number" data-line-number="1280"></td>
        <td id="LC1280" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_TrialName<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1281" class="blob-num js-line-number" data-line-number="1281"></td>
        <td id="LC1281" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_TrialAcronym<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAcronym<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1282" class="blob-num js-line-number" data-line-number="1282"></td>
        <td id="LC1282" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_ContactId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialManagerId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1283" class="blob-num js-line-number" data-line-number="1283"></td>
        <td id="LC1283" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_DesignTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>DesignTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1284" class="blob-num js-line-number" data-line-number="1284"></td>
        <td id="LC1284" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_SiteId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1285" class="blob-num js-line-number" data-line-number="1285"></td>
        <td id="LC1285" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_TrialTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1286" class="blob-num js-line-number" data-line-number="1286"></td>
        <td id="LC1286" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_TrialStartDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialStartDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1287" class="blob-num js-line-number" data-line-number="1287"></td>
        <td id="LC1287" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_TrialEndDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialEndDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1288" class="blob-num js-line-number" data-line-number="1288"></td>
        <td id="LC1288" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_CurrentWorkflowId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>CurrentWorkflowId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1289" class="blob-num js-line-number" data-line-number="1289"></td>
        <td id="LC1289" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtr_ProjectId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1290" class="blob-num js-line-number" data-line-number="1290"></td>
        <td id="LC1290" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trial_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>DesignTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>designtype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>DesignTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1291" class="blob-num js-line-number" data-line-number="1291"></td>
        <td id="LC1291" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trial_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>site<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SiteId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1292" class="blob-num js-line-number" data-line-number="1292"></td>
        <td id="LC1292" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trial_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialManagerId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>contact<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1293" class="blob-num js-line-number" data-line-number="1293"></td>
        <td id="LC1293" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trial_ibfk_4<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1294" class="blob-num js-line-number" data-line-number="1294"></td>
        <td id="LC1294" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trial_ibfk_5<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>project<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ProjectId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1295" class="blob-num js-line-number" data-line-number="1295"></td>
        <td id="LC1295" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1296" class="blob-num js-line-number" data-line-number="1296"></td>
        <td id="LC1296" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1297" class="blob-num js-line-number" data-line-number="1297"></td>
        <td id="LC1297" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1298" class="blob-num js-line-number" data-line-number="1298"></td>
        <td id="LC1298" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1299" class="blob-num js-line-number" data-line-number="1299"></td>
        <td id="LC1299" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialanalysis`</span></td>
      </tr>
      <tr>
        <td id="L1300" class="blob-num js-line-number" data-line-number="1300"></td>
        <td id="LC1300" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1301" class="blob-num js-line-number" data-line-number="1301"></td>
        <td id="LC1301" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1302" class="blob-num js-line-number" data-line-number="1302"></td>
        <td id="LC1302" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialanalysis<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1303" class="blob-num js-line-number" data-line-number="1303"></td>
        <td id="LC1303" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1304" class="blob-num js-line-number" data-line-number="1304"></td>
        <td id="LC1304" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1305" class="blob-num js-line-number" data-line-number="1305"></td>
        <td id="LC1305" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialanalysis</span>` (</td>
      </tr>
      <tr>
        <td id="L1306" class="blob-num js-line-number" data-line-number="1306"></td>
        <td id="LC1306" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial analysis id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1307" class="blob-num js-line-number" data-line-number="1307"></td>
        <td id="LC1307" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AnalystId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span>,</td>
      </tr>
      <tr>
        <td id="L1308" class="blob-num js-line-number" data-line-number="1308"></td>
        <td id="LC1308" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1309" class="blob-num js-line-number" data-line-number="1309"></td>
        <td id="LC1309" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StatisticalModel<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>statistical model used<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1310" class="blob-num js-line-number" data-line-number="1310"></td>
        <td id="LC1310" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AnalysisDoneDate<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date of analysis<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1311" class="blob-num js-line-number" data-line-number="1311"></td>
        <td id="LC1311" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">6000</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>some additional description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1312" class="blob-num js-line-number" data-line-number="1312"></td>
        <td id="LC1312" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>group id owning the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1313" class="blob-num js-line-number" data-line-number="1313"></td>
        <td id="LC1313" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>group id with some access to the record<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1314" class="blob-num js-line-number" data-line-number="1314"></td>
        <td id="LC1314" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OwnGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>owning group permissions<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1315" class="blob-num js-line-number" data-line-number="1315"></td>
        <td id="LC1315" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>AccessGroupPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>other group permissions<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1316" class="blob-num js-line-number" data-line-number="1316"></td>
        <td id="LC1316" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OtherPerm<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>all system users permissions<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1317" class="blob-num js-line-number" data-line-number="1317"></td>
        <td id="LC1317" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1318" class="blob-num js-line-number" data-line-number="1318"></td>
        <td id="LC1318" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>AlternateKey<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>StatisticalModel<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1319" class="blob-num js-line-number" data-line-number="1319"></td>
        <td id="LC1319" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xanalystid_trialanalysis<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>AnalystId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1320" class="blob-num js-line-number" data-line-number="1320"></td>
        <td id="LC1320" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialanalysis_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trial<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1321" class="blob-num js-line-number" data-line-number="1321"></td>
        <td id="LC1321" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialanalysis_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>AnalystId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>contact<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ContactId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1322" class="blob-num js-line-number" data-line-number="1322"></td>
        <td id="LC1322" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1323" class="blob-num js-line-number" data-line-number="1323"></td>
        <td id="LC1323" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1324" class="blob-num js-line-number" data-line-number="1324"></td>
        <td id="LC1324" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1325" class="blob-num js-line-number" data-line-number="1325"></td>
        <td id="LC1325" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1326" class="blob-num js-line-number" data-line-number="1326"></td>
        <td id="LC1326" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialanalysisfactor`</span></td>
      </tr>
      <tr>
        <td id="L1327" class="blob-num js-line-number" data-line-number="1327"></td>
        <td id="LC1327" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1328" class="blob-num js-line-number" data-line-number="1328"></td>
        <td id="LC1328" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1329" class="blob-num js-line-number" data-line-number="1329"></td>
        <td id="LC1329" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialanalysisfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1330" class="blob-num js-line-number" data-line-number="1330"></td>
        <td id="LC1330" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1331" class="blob-num js-line-number" data-line-number="1331"></td>
        <td id="LC1331" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1332" class="blob-num js-line-number" data-line-number="1332"></td>
        <td id="LC1332" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialanalysisfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L1333" class="blob-num js-line-number" data-line-number="1333"></td>
        <td id="LC1333" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial analysis id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1334" class="blob-num js-line-number" data-line-number="1334"></td>
        <td id="LC1334" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1335" class="blob-num js-line-number" data-line-number="1335"></td>
        <td id="LC1335" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1336" class="blob-num js-line-number" data-line-number="1336"></td>
        <td id="LC1336" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1337" class="blob-num js-line-number" data-line-number="1337"></td>
        <td id="LC1337" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1338" class="blob-num js-line-number" data-line-number="1338"></td>
        <td id="LC1338" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialanalysisfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1339" class="blob-num js-line-number" data-line-number="1339"></td>
        <td id="LC1339" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialanalysisfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trialanalysis<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1340" class="blob-num js-line-number" data-line-number="1340"></td>
        <td id="LC1340" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1341" class="blob-num js-line-number" data-line-number="1341"></td>
        <td id="LC1341" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1342" class="blob-num js-line-number" data-line-number="1342"></td>
        <td id="LC1342" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1343" class="blob-num js-line-number" data-line-number="1343"></td>
        <td id="LC1343" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1344" class="blob-num js-line-number" data-line-number="1344"></td>
        <td id="LC1344" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialaov`</span></td>
      </tr>
      <tr>
        <td id="L1345" class="blob-num js-line-number" data-line-number="1345"></td>
        <td id="LC1345" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1346" class="blob-num js-line-number" data-line-number="1346"></td>
        <td id="LC1346" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1347" class="blob-num js-line-number" data-line-number="1347"></td>
        <td id="LC1347" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialaov<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1348" class="blob-num js-line-number" data-line-number="1348"></td>
        <td id="LC1348" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1349" class="blob-num js-line-number" data-line-number="1349"></td>
        <td id="LC1349" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1350" class="blob-num js-line-number" data-line-number="1350"></td>
        <td id="LC1350" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialaov</span>` (</td>
      </tr>
      <tr>
        <td id="L1351" class="blob-num js-line-number" data-line-number="1351"></td>
        <td id="LC1351" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial aov id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1352" class="blob-num js-line-number" data-line-number="1352"></td>
        <td id="LC1352" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial analysis id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1353" class="blob-num js-line-number" data-line-number="1353"></td>
        <td id="LC1353" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StatisticalMethod<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>method ?kMHgGeneral text by the statistician about how the analysis was donek/MHg<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1354" class="blob-num js-line-number" data-line-number="1354"></td>
        <td id="LC1354" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GeneralMean<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>mean value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1355" class="blob-num js-line-number" data-line-number="1355"></td>
        <td id="LC1355" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>LSD<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Least Significant Difference (Fisher test?)kMHgFisher Testk/MHg<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1356" class="blob-num js-line-number" data-line-number="1356"></td>
        <td id="LC1356" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>CoV<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Covariance<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1357" class="blob-num js-line-number" data-line-number="1357"></td>
        <td id="LC1357" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>EDF<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Expected Default Frequency kMHgNumber of Times it should have been replicatedk/MHg<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1358" class="blob-num js-line-number" data-line-number="1358"></td>
        <td id="LC1358" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SED<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Standard Error of the Difference ???kMHgComponent of LSDk/MHg<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1359" class="blob-num js-line-number" data-line-number="1359"></td>
        <td id="LC1359" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1360" class="blob-num js-line-number" data-line-number="1360"></td>
        <td id="LC1360" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>AlternateKey<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1361" class="blob-num js-line-number" data-line-number="1361"></td>
        <td id="LC1361" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialaov_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trialanalysis<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAnalysisId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1362" class="blob-num js-line-number" data-line-number="1362"></td>
        <td id="LC1362" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1363" class="blob-num js-line-number" data-line-number="1363"></td>
        <td id="LC1363" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1364" class="blob-num js-line-number" data-line-number="1364"></td>
        <td id="LC1364" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1365" class="blob-num js-line-number" data-line-number="1365"></td>
        <td id="LC1365" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1366" class="blob-num js-line-number" data-line-number="1366"></td>
        <td id="LC1366" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialaovfactor`</span></td>
      </tr>
      <tr>
        <td id="L1367" class="blob-num js-line-number" data-line-number="1367"></td>
        <td id="LC1367" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1368" class="blob-num js-line-number" data-line-number="1368"></td>
        <td id="LC1368" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1369" class="blob-num js-line-number" data-line-number="1369"></td>
        <td id="LC1369" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialaovfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1370" class="blob-num js-line-number" data-line-number="1370"></td>
        <td id="LC1370" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1371" class="blob-num js-line-number" data-line-number="1371"></td>
        <td id="LC1371" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1372" class="blob-num js-line-number" data-line-number="1372"></td>
        <td id="LC1372" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialaovfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L1373" class="blob-num js-line-number" data-line-number="1373"></td>
        <td id="LC1373" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial aov id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1374" class="blob-num js-line-number" data-line-number="1374"></td>
        <td id="LC1374" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1375" class="blob-num js-line-number" data-line-number="1375"></td>
        <td id="LC1375" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1376" class="blob-num js-line-number" data-line-number="1376"></td>
        <td id="LC1376" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1377" class="blob-num js-line-number" data-line-number="1377"></td>
        <td id="LC1377" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1378" class="blob-num js-line-number" data-line-number="1378"></td>
        <td id="LC1378" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialaovfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1379" class="blob-num js-line-number" data-line-number="1379"></td>
        <td id="LC1379" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialaovfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trialaov<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1380" class="blob-num js-line-number" data-line-number="1380"></td>
        <td id="LC1380" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1381" class="blob-num js-line-number" data-line-number="1381"></td>
        <td id="LC1381" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1382" class="blob-num js-line-number" data-line-number="1382"></td>
        <td id="LC1382" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1383" class="blob-num js-line-number" data-line-number="1383"></td>
        <td id="LC1383" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1384" class="blob-num js-line-number" data-line-number="1384"></td>
        <td id="LC1384" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialevent`</span></td>
      </tr>
      <tr>
        <td id="L1385" class="blob-num js-line-number" data-line-number="1385"></td>
        <td id="LC1385" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1386" class="blob-num js-line-number" data-line-number="1386"></td>
        <td id="LC1386" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1387" class="blob-num js-line-number" data-line-number="1387"></td>
        <td id="LC1387" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialevent<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1388" class="blob-num js-line-number" data-line-number="1388"></td>
        <td id="LC1388" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1389" class="blob-num js-line-number" data-line-number="1389"></td>
        <td id="LC1389" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1390" class="blob-num js-line-number" data-line-number="1390"></td>
        <td id="LC1390" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialevent</span>` (</td>
      </tr>
      <tr>
        <td id="L1391" class="blob-num js-line-number" data-line-number="1391"></td>
        <td id="LC1391" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialEventId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial event id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1392" class="blob-num js-line-number" data-line-number="1392"></td>
        <td id="LC1392" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialEventUnit<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial event unit id - definition of units for the value, can be null if value is descriptive<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1393" class="blob-num js-line-number" data-line-number="1393"></td>
        <td id="LC1393" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>EventTypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial event type id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1394" class="blob-num js-line-number" data-line-number="1394"></td>
        <td id="LC1394" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1395" class="blob-num js-line-number" data-line-number="1395"></td>
        <td id="LC1395" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>person who performed operation<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1396" class="blob-num js-line-number" data-line-number="1396"></td>
        <td id="LC1396" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialEventValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>event value (number in the units defined)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1397" class="blob-num js-line-number" data-line-number="1397"></td>
        <td id="LC1397" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialEventDate<span class="pl-pds">`</span></span> datetime <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>operation date<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1398" class="blob-num js-line-number" data-line-number="1398"></td>
        <td id="LC1398" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialEventNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>additional description of the event<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1399" class="blob-num js-line-number" data-line-number="1399"></td>
        <td id="LC1399" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialEventId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1400" class="blob-num js-line-number" data-line-number="1400"></td>
        <td id="LC1400" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xte_OperatorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1401" class="blob-num js-line-number" data-line-number="1401"></td>
        <td id="LC1401" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xte_TrialId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1402" class="blob-num js-line-number" data-line-number="1402"></td>
        <td id="LC1402" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xte_EventTypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>EventTypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1403" class="blob-num js-line-number" data-line-number="1403"></td>
        <td id="LC1403" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xte_TrialEventDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialEventDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1404" class="blob-num js-line-number" data-line-number="1404"></td>
        <td id="LC1404" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xte_TrialEventUnit<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialEventUnit<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1405" class="blob-num js-line-number" data-line-number="1405"></td>
        <td id="LC1405" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialevent_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trial<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1406" class="blob-num js-line-number" data-line-number="1406"></td>
        <td id="LC1406" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialevent_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>EventTypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1407" class="blob-num js-line-number" data-line-number="1407"></td>
        <td id="LC1407" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialevent_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>OperatorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>systemuser<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UserId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1408" class="blob-num js-line-number" data-line-number="1408"></td>
        <td id="LC1408" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialevent_ibfk_4<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialEventUnit<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>itemunit<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemUnitId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1409" class="blob-num js-line-number" data-line-number="1409"></td>
        <td id="LC1409" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1410" class="blob-num js-line-number" data-line-number="1410"></td>
        <td id="LC1410" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1411" class="blob-num js-line-number" data-line-number="1411"></td>
        <td id="LC1411" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1412" class="blob-num js-line-number" data-line-number="1412"></td>
        <td id="LC1412" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1413" class="blob-num js-line-number" data-line-number="1413"></td>
        <td id="LC1413" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialeventfactor`</span></td>
      </tr>
      <tr>
        <td id="L1414" class="blob-num js-line-number" data-line-number="1414"></td>
        <td id="LC1414" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1415" class="blob-num js-line-number" data-line-number="1415"></td>
        <td id="LC1415" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1416" class="blob-num js-line-number" data-line-number="1416"></td>
        <td id="LC1416" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialeventfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1417" class="blob-num js-line-number" data-line-number="1417"></td>
        <td id="LC1417" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1418" class="blob-num js-line-number" data-line-number="1418"></td>
        <td id="LC1418" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1419" class="blob-num js-line-number" data-line-number="1419"></td>
        <td id="LC1419" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialeventfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L1420" class="blob-num js-line-number" data-line-number="1420"></td>
        <td id="LC1420" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1421" class="blob-num js-line-number" data-line-number="1421"></td>
        <td id="LC1421" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialEventId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial event id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1422" class="blob-num js-line-number" data-line-number="1422"></td>
        <td id="LC1422" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1423" class="blob-num js-line-number" data-line-number="1423"></td>
        <td id="LC1423" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>TrialEventId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1424" class="blob-num js-line-number" data-line-number="1424"></td>
        <td id="LC1424" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1425" class="blob-num js-line-number" data-line-number="1425"></td>
        <td id="LC1425" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>TrialEventId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialEventId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1426" class="blob-num js-line-number" data-line-number="1426"></td>
        <td id="LC1426" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialeventfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1427" class="blob-num js-line-number" data-line-number="1427"></td>
        <td id="LC1427" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialeventfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialEventId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trialevent<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialEventId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1428" class="blob-num js-line-number" data-line-number="1428"></td>
        <td id="LC1428" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1429" class="blob-num js-line-number" data-line-number="1429"></td>
        <td id="LC1429" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1430" class="blob-num js-line-number" data-line-number="1430"></td>
        <td id="LC1430" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1431" class="blob-num js-line-number" data-line-number="1431"></td>
        <td id="LC1431" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1432" class="blob-num js-line-number" data-line-number="1432"></td>
        <td id="LC1432" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialfactor`</span></td>
      </tr>
      <tr>
        <td id="L1433" class="blob-num js-line-number" data-line-number="1433"></td>
        <td id="LC1433" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1434" class="blob-num js-line-number" data-line-number="1434"></td>
        <td id="LC1434" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1435" class="blob-num js-line-number" data-line-number="1435"></td>
        <td id="LC1435" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1436" class="blob-num js-line-number" data-line-number="1436"></td>
        <td id="LC1436" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1437" class="blob-num js-line-number" data-line-number="1437"></td>
        <td id="LC1437" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1438" class="blob-num js-line-number" data-line-number="1438"></td>
        <td id="LC1438" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L1439" class="blob-num js-line-number" data-line-number="1439"></td>
        <td id="LC1439" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1440" class="blob-num js-line-number" data-line-number="1440"></td>
        <td id="LC1440" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1441" class="blob-num js-line-number" data-line-number="1441"></td>
        <td id="LC1441" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1442" class="blob-num js-line-number" data-line-number="1442"></td>
        <td id="LC1442" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1443" class="blob-num js-line-number" data-line-number="1443"></td>
        <td id="LC1443" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1444" class="blob-num js-line-number" data-line-number="1444"></td>
        <td id="LC1444" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1445" class="blob-num js-line-number" data-line-number="1445"></td>
        <td id="LC1445" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trial<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1446" class="blob-num js-line-number" data-line-number="1446"></td>
        <td id="LC1446" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1447" class="blob-num js-line-number" data-line-number="1447"></td>
        <td id="LC1447" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1448" class="blob-num js-line-number" data-line-number="1448"></td>
        <td id="LC1448" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1449" class="blob-num js-line-number" data-line-number="1449"></td>
        <td id="LC1449" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1450" class="blob-num js-line-number" data-line-number="1450"></td>
        <td id="LC1450" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialmean`</span></td>
      </tr>
      <tr>
        <td id="L1451" class="blob-num js-line-number" data-line-number="1451"></td>
        <td id="LC1451" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1452" class="blob-num js-line-number" data-line-number="1452"></td>
        <td id="LC1452" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1453" class="blob-num js-line-number" data-line-number="1453"></td>
        <td id="LC1453" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialmean<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1454" class="blob-num js-line-number" data-line-number="1454"></td>
        <td id="LC1454" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1455" class="blob-num js-line-number" data-line-number="1455"></td>
        <td id="LC1455" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1456" class="blob-num js-line-number" data-line-number="1456"></td>
        <td id="LC1456" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialmean</span>` (</td>
      </tr>
      <tr>
        <td id="L1457" class="blob-num js-line-number" data-line-number="1457"></td>
        <td id="LC1457" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialMeanId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial mean id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1458" class="blob-num js-line-number" data-line-number="1458"></td>
        <td id="LC1458" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial aov id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1459" class="blob-num js-line-number" data-line-number="1459"></td>
        <td id="LC1459" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>genotype id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1460" class="blob-num js-line-number" data-line-number="1460"></td>
        <td id="LC1460" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>treatment id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1461" class="blob-num js-line-number" data-line-number="1461"></td>
        <td id="LC1461" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>MeanValue<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>mean value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1462" class="blob-num js-line-number" data-line-number="1462"></td>
        <td id="LC1462" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SuccessfulRep<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">6</span>,<span class="pl-c1">2</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>number of successful replications???kMHgnumber of non missing variations (incase animals ate some of the crop and a replicate could not be used)k/MHg<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1463" class="blob-num js-line-number" data-line-number="1463"></td>
        <td id="LC1463" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Weight<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>weight<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1464" class="blob-num js-line-number" data-line-number="1464"></td>
        <td id="LC1464" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Rank<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>rank<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1465" class="blob-num js-line-number" data-line-number="1465"></td>
        <td id="LC1465" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>EMS<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Expected Mean Square?kMHgError Mean Squared, Residue variation from analysisk/MHg<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1466" class="blob-num js-line-number" data-line-number="1466"></td>
        <td id="LC1466" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StandardError<span class="pl-pds">`</span></span> <span class="pl-k">decimal</span>(<span class="pl-c1">16</span>,<span class="pl-c1">6</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>standard error<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1467" class="blob-num js-line-number" data-line-number="1467"></td>
        <td id="LC1467" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialMeanId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1468" class="blob-num js-line-number" data-line-number="1468"></td>
        <td id="LC1468" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>AlternateKey<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1469" class="blob-num js-line-number" data-line-number="1469"></td>
        <td id="LC1469" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1470" class="blob-num js-line-number" data-line-number="1470"></td>
        <td id="LC1470" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1471" class="blob-num js-line-number" data-line-number="1471"></td>
        <td id="LC1471" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialmean_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>genotype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>GenotypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1472" class="blob-num js-line-number" data-line-number="1472"></td>
        <td id="LC1472" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialmean_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>treatment<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1473" class="blob-num js-line-number" data-line-number="1473"></td>
        <td id="LC1473" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialmean_ibfk_3<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trialaov<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialAOVId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1474" class="blob-num js-line-number" data-line-number="1474"></td>
        <td id="LC1474" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1475" class="blob-num js-line-number" data-line-number="1475"></td>
        <td id="LC1475" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1476" class="blob-num js-line-number" data-line-number="1476"></td>
        <td id="LC1476" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1477" class="blob-num js-line-number" data-line-number="1477"></td>
        <td id="LC1477" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1478" class="blob-num js-line-number" data-line-number="1478"></td>
        <td id="LC1478" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialtrait`</span></td>
      </tr>
      <tr>
        <td id="L1479" class="blob-num js-line-number" data-line-number="1479"></td>
        <td id="LC1479" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1480" class="blob-num js-line-number" data-line-number="1480"></td>
        <td id="LC1480" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1481" class="blob-num js-line-number" data-line-number="1481"></td>
        <td id="LC1481" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialtrait<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1482" class="blob-num js-line-number" data-line-number="1482"></td>
        <td id="LC1482" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1483" class="blob-num js-line-number" data-line-number="1483"></td>
        <td id="LC1483" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1484" class="blob-num js-line-number" data-line-number="1484"></td>
        <td id="LC1484" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialtrait</span>` (</td>
      </tr>
      <tr>
        <td id="L1485" class="blob-num js-line-number" data-line-number="1485"></td>
        <td id="LC1485" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialTraitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>record id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1486" class="blob-num js-line-number" data-line-number="1486"></td>
        <td id="LC1486" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1487" class="blob-num js-line-number" data-line-number="1487"></td>
        <td id="LC1487" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trait id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1488" class="blob-num js-line-number" data-line-number="1488"></td>
        <td id="LC1488" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Compulsory<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">1</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>0|1 flag indicating that this combination is compulsory to measure in the trial<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1489" class="blob-num js-line-number" data-line-number="1489"></td>
        <td id="LC1489" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialTraitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1490" class="blob-num js-line-number" data-line-number="1490"></td>
        <td id="LC1490" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtt_TraitId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1491" class="blob-num js-line-number" data-line-number="1491"></td>
        <td id="LC1491" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtt_TrialId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1492" class="blob-num js-line-number" data-line-number="1492"></td>
        <td id="LC1492" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialtrait_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trait<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TraitId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1493" class="blob-num js-line-number" data-line-number="1493"></td>
        <td id="LC1493" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialtrait_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trial<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1494" class="blob-num js-line-number" data-line-number="1494"></td>
        <td id="LC1494" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1495" class="blob-num js-line-number" data-line-number="1495"></td>
        <td id="LC1495" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1496" class="blob-num js-line-number" data-line-number="1496"></td>
        <td id="LC1496" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1497" class="blob-num js-line-number" data-line-number="1497"></td>
        <td id="LC1497" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1498" class="blob-num js-line-number" data-line-number="1498"></td>
        <td id="LC1498" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialunit`</span></td>
      </tr>
      <tr>
        <td id="L1499" class="blob-num js-line-number" data-line-number="1499"></td>
        <td id="LC1499" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1500" class="blob-num js-line-number" data-line-number="1500"></td>
        <td id="LC1500" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1501" class="blob-num js-line-number" data-line-number="1501"></td>
        <td id="LC1501" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialunit<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1502" class="blob-num js-line-number" data-line-number="1502"></td>
        <td id="LC1502" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1503" class="blob-num js-line-number" data-line-number="1503"></td>
        <td id="LC1503" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1504" class="blob-num js-line-number" data-line-number="1504"></td>
        <td id="LC1504" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialunit</span>` (</td>
      </tr>
      <tr>
        <td id="L1505" class="blob-num js-line-number" data-line-number="1505"></td>
        <td id="LC1505" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial unit id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1506" class="blob-num js-line-number" data-line-number="1506"></td>
        <td id="LC1506" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1507" class="blob-num js-line-number" data-line-number="1507"></td>
        <td id="LC1507" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>unit position id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1508" class="blob-num js-line-number" data-line-number="1508"></td>
        <td id="LC1508" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>treatment id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1509" class="blob-num js-line-number" data-line-number="1509"></td>
        <td id="LC1509" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SourceTrialUnitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>Source Trial Unit that identifies the source of the sample used in the Trial Unit of the Trial. For example, the source trial unit for a wheat grain sample used in a milling trial can be a trial unit of a Wheat Variety Evaluation Trial. While importing da<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1510" class="blob-num js-line-number" data-line-number="1510"></td>
        <td id="LC1510" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ReplicateNumber<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>replicate number - next instance of the same specimen<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1511" class="blob-num js-line-number" data-line-number="1511"></td>
        <td id="LC1511" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialUnitBarcode<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>barcode of the trial unit (plot)<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1512" class="blob-num js-line-number" data-line-number="1512"></td>
        <td id="LC1512" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialUnitNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>additional description for the trial unit<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1513" class="blob-num js-line-number" data-line-number="1513"></td>
        <td id="LC1513" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SampleSupplierId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">10</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>sample supplier id (contact or organisation, no defined relation here). Optional field to define who supplied the the seed. Choosing if this is contact or organisation is a matter for organisations convention.<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1514" class="blob-num js-line-number" data-line-number="1514"></td>
        <td id="LC1514" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1515" class="blob-num js-line-number" data-line-number="1515"></td>
        <td id="LC1515" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>xtu_TrialUnitBarcode<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitBarcode<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1516" class="blob-num js-line-number" data-line-number="1516"></td>
        <td id="LC1516" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtu_TrialUnitPosition<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1517" class="blob-num js-line-number" data-line-number="1517"></td>
        <td id="LC1517" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtu_SampleSupplierId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SampleSupplierId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1518" class="blob-num js-line-number" data-line-number="1518"></td>
        <td id="LC1518" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtu_TreatmentId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TreatmentId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1519" class="blob-num js-line-number" data-line-number="1519"></td>
        <td id="LC1519" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtu_UnitPositionId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1520" class="blob-num js-line-number" data-line-number="1520"></td>
        <td id="LC1520" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtu_SourceTrialUnitId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SourceTrialUnitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1521" class="blob-num js-line-number" data-line-number="1521"></td>
        <td id="LC1521" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialunit_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trial<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1522" class="blob-num js-line-number" data-line-number="1522"></td>
        <td id="LC1522" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialunit_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>unitposition<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1523" class="blob-num js-line-number" data-line-number="1523"></td>
        <td id="LC1523" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1524" class="blob-num js-line-number" data-line-number="1524"></td>
        <td id="LC1524" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1525" class="blob-num js-line-number" data-line-number="1525"></td>
        <td id="LC1525" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1526" class="blob-num js-line-number" data-line-number="1526"></td>
        <td id="LC1526" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1527" class="blob-num js-line-number" data-line-number="1527"></td>
        <td id="LC1527" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialunitspecimen`</span></td>
      </tr>
      <tr>
        <td id="L1528" class="blob-num js-line-number" data-line-number="1528"></td>
        <td id="LC1528" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1529" class="blob-num js-line-number" data-line-number="1529"></td>
        <td id="LC1529" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1530" class="blob-num js-line-number" data-line-number="1530"></td>
        <td id="LC1530" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialunitspecimen<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1531" class="blob-num js-line-number" data-line-number="1531"></td>
        <td id="LC1531" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1532" class="blob-num js-line-number" data-line-number="1532"></td>
        <td id="LC1532" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1533" class="blob-num js-line-number" data-line-number="1533"></td>
        <td id="LC1533" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialunitspecimen</span>` (</td>
      </tr>
      <tr>
        <td id="L1534" class="blob-num js-line-number" data-line-number="1534"></td>
        <td id="LC1534" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialUnitSpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the group of specimens in trial unit<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1535" class="blob-num js-line-number" data-line-number="1535"></td>
        <td id="LC1535" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the planted specimen<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1536" class="blob-num js-line-number" data-line-number="1536"></td>
        <td id="LC1536" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>trial unit id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1537" class="blob-num js-line-number" data-line-number="1537"></td>
        <td id="LC1537" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>source item (e.g. seed bag) for this particular trial unit - having it here allows to use different seed bags for each planted specimen if this is a case, link is optional as the seed source may come from other places<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1538" class="blob-num js-line-number" data-line-number="1538"></td>
        <td id="LC1538" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>PlantDate<span class="pl-pds">`</span></span> <span class="pl-k">date</span> default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date when specimen has been planted in the trial unit<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1539" class="blob-num js-line-number" data-line-number="1539"></td>
        <td id="LC1539" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>HarvestDate<span class="pl-pds">`</span></span> <span class="pl-k">date</span> default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>date when specimen has been harvested from the trial unit<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1540" class="blob-num js-line-number" data-line-number="1540"></td>
        <td id="LC1540" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>HasDied<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>flag if specimen died<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1541" class="blob-num js-line-number" data-line-number="1541"></td>
        <td id="LC1541" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Notes<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>additional notes<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1542" class="blob-num js-line-number" data-line-number="1542"></td>
        <td id="LC1542" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitSpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1543" class="blob-num js-line-number" data-line-number="1543"></td>
        <td id="LC1543" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtus_TrialUnitId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1544" class="blob-num js-line-number" data-line-number="1544"></td>
        <td id="LC1544" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtus_SpecimenId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1545" class="blob-num js-line-number" data-line-number="1545"></td>
        <td id="LC1545" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtus_PlantDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>PlantDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1546" class="blob-num js-line-number" data-line-number="1546"></td>
        <td id="LC1546" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtus_HarvestDate<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>HarvestDate<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1547" class="blob-num js-line-number" data-line-number="1547"></td>
        <td id="LC1547" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xtus_ItemId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>ItemId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1548" class="blob-num js-line-number" data-line-number="1548"></td>
        <td id="LC1548" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialunitspecimen_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trialunit<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialUnitId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1549" class="blob-num js-line-number" data-line-number="1549"></td>
        <td id="LC1549" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialunitspecimen_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>specimen<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>SpecimenId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1550" class="blob-num js-line-number" data-line-number="1550"></td>
        <td id="LC1550" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1551" class="blob-num js-line-number" data-line-number="1551"></td>
        <td id="LC1551" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1552" class="blob-num js-line-number" data-line-number="1552"></td>
        <td id="LC1552" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1553" class="blob-num js-line-number" data-line-number="1553"></td>
        <td id="LC1553" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1554" class="blob-num js-line-number" data-line-number="1554"></td>
        <td id="LC1554" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `trialworkflow`</span></td>
      </tr>
      <tr>
        <td id="L1555" class="blob-num js-line-number" data-line-number="1555"></td>
        <td id="LC1555" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1556" class="blob-num js-line-number" data-line-number="1556"></td>
        <td id="LC1556" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1557" class="blob-num js-line-number" data-line-number="1557"></td>
        <td id="LC1557" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>trialworkflow<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1558" class="blob-num js-line-number" data-line-number="1558"></td>
        <td id="LC1558" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1559" class="blob-num js-line-number" data-line-number="1559"></td>
        <td id="LC1559" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1560" class="blob-num js-line-number" data-line-number="1560"></td>
        <td id="LC1560" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">trialworkflow</span>` (</td>
      </tr>
      <tr>
        <td id="L1561" class="blob-num js-line-number" data-line-number="1561"></td>
        <td id="LC1561" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialWorkflowId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>internal id of trial workflow step<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1562" class="blob-num js-line-number" data-line-number="1562"></td>
        <td id="LC1562" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>WorkflowdefId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of workflow step<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1563" class="blob-num js-line-number" data-line-number="1563"></td>
        <td id="LC1563" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>id of the trial the workflow is attached to<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1564" class="blob-num js-line-number" data-line-number="1564"></td>
        <td id="LC1564" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>CompleteBy<span class="pl-pds">`</span></span> datetime default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>optional deadline to complete step<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1565" class="blob-num js-line-number" data-line-number="1565"></td>
        <td id="LC1565" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Completed<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>flag if completed - default 0<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1566" class="blob-num js-line-number" data-line-number="1566"></td>
        <td id="LC1566" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ReminderAt<span class="pl-pds">`</span></span> datetime default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>optional date and time of reminder<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1567" class="blob-num js-line-number" data-line-number="1567"></td>
        <td id="LC1567" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>ReminderTo<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>optional e-mail list where to send reminders to<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1568" class="blob-num js-line-number" data-line-number="1568"></td>
        <td id="LC1568" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>Note<span class="pl-pds">`</span></span> mediumtext COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>notes about this step<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1569" class="blob-num js-line-number" data-line-number="1569"></td>
        <td id="LC1569" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>TrialWorkflowId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1570" class="blob-num js-line-number" data-line-number="1570"></td>
        <td id="LC1570" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>twf_workflowdef<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowdefId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1571" class="blob-num js-line-number" data-line-number="1571"></td>
        <td id="LC1571" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>twf_trial<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1572" class="blob-num js-line-number" data-line-number="1572"></td>
        <td id="LC1572" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialworkflow_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>trial<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TrialId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1573" class="blob-num js-line-number" data-line-number="1573"></td>
        <td id="LC1573" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>trialworkflow_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowdefId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>workflowdef<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowdefId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1574" class="blob-num js-line-number" data-line-number="1574"></td>
        <td id="LC1574" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1575" class="blob-num js-line-number" data-line-number="1575"></td>
        <td id="LC1575" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1576" class="blob-num js-line-number" data-line-number="1576"></td>
        <td id="LC1576" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1577" class="blob-num js-line-number" data-line-number="1577"></td>
        <td id="LC1577" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1578" class="blob-num js-line-number" data-line-number="1578"></td>
        <td id="LC1578" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `unitposition`</span></td>
      </tr>
      <tr>
        <td id="L1579" class="blob-num js-line-number" data-line-number="1579"></td>
        <td id="LC1579" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1580" class="blob-num js-line-number" data-line-number="1580"></td>
        <td id="LC1580" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1581" class="blob-num js-line-number" data-line-number="1581"></td>
        <td id="LC1581" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>unitposition<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1582" class="blob-num js-line-number" data-line-number="1582"></td>
        <td id="LC1582" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1583" class="blob-num js-line-number" data-line-number="1583"></td>
        <td id="LC1583" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1584" class="blob-num js-line-number" data-line-number="1584"></td>
        <td id="LC1584" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">unitposition</span>` (</td>
      </tr>
      <tr>
        <td id="L1585" class="blob-num js-line-number" data-line-number="1585"></td>
        <td id="LC1585" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>unit position id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1586" class="blob-num js-line-number" data-line-number="1586"></td>
        <td id="LC1586" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UnitPositionText<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">255</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>unit position description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1587" class="blob-num js-line-number" data-line-number="1587"></td>
        <td id="LC1587" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1588" class="blob-num js-line-number" data-line-number="1588"></td>
        <td id="LC1588" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>xup_UnitPositionText<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UnitPositionText<span class="pl-pds">`</span></span>)</td>
      </tr>
      <tr>
        <td id="L1589" class="blob-num js-line-number" data-line-number="1589"></td>
        <td id="LC1589" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB AUTO_INCREMENT<span class="pl-k">=</span><span class="pl-c1">1</span> DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1590" class="blob-num js-line-number" data-line-number="1590"></td>
        <td id="LC1590" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1591" class="blob-num js-line-number" data-line-number="1591"></td>
        <td id="LC1591" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1592" class="blob-num js-line-number" data-line-number="1592"></td>
        <td id="LC1592" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1593" class="blob-num js-line-number" data-line-number="1593"></td>
        <td id="LC1593" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `unitpositionfactor`</span></td>
      </tr>
      <tr>
        <td id="L1594" class="blob-num js-line-number" data-line-number="1594"></td>
        <td id="LC1594" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1595" class="blob-num js-line-number" data-line-number="1595"></td>
        <td id="LC1595" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1596" class="blob-num js-line-number" data-line-number="1596"></td>
        <td id="LC1596" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>unitpositionfactor<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1597" class="blob-num js-line-number" data-line-number="1597"></td>
        <td id="LC1597" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1598" class="blob-num js-line-number" data-line-number="1598"></td>
        <td id="LC1598" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1599" class="blob-num js-line-number" data-line-number="1599"></td>
        <td id="LC1599" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">unitpositionfactor</span>` (</td>
      </tr>
      <tr>
        <td id="L1600" class="blob-num js-line-number" data-line-number="1600"></td>
        <td id="LC1600" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>unit position id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1601" class="blob-num js-line-number" data-line-number="1601"></td>
        <td id="LC1601" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>factor id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1602" class="blob-num js-line-number" data-line-number="1602"></td>
        <td id="LC1602" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>FactorValue<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">32</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>value<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1603" class="blob-num js-line-number" data-line-number="1603"></td>
        <td id="LC1603" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1604" class="blob-num js-line-number" data-line-number="1604"></td>
        <td id="LC1604" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1605" class="blob-num js-line-number" data-line-number="1605"></td>
        <td id="LC1605" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>unitpositionfactor_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>factor<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>FactorId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION,</td>
      </tr>
      <tr>
        <td id="L1606" class="blob-num js-line-number" data-line-number="1606"></td>
        <td id="LC1606" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>unitpositionfactor_ibfk_2<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>unitposition<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>UnitPositionId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1607" class="blob-num js-line-number" data-line-number="1607"></td>
        <td id="LC1607" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1608" class="blob-num js-line-number" data-line-number="1608"></td>
        <td id="LC1608" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1609" class="blob-num js-line-number" data-line-number="1609"></td>
        <td id="LC1609" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1610" class="blob-num js-line-number" data-line-number="1610"></td>
        <td id="LC1610" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1611" class="blob-num js-line-number" data-line-number="1611"></td>
        <td id="LC1611" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `workflow`</span></td>
      </tr>
      <tr>
        <td id="L1612" class="blob-num js-line-number" data-line-number="1612"></td>
        <td id="LC1612" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1613" class="blob-num js-line-number" data-line-number="1613"></td>
        <td id="LC1613" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1614" class="blob-num js-line-number" data-line-number="1614"></td>
        <td id="LC1614" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>workflow<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1615" class="blob-num js-line-number" data-line-number="1615"></td>
        <td id="LC1615" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1616" class="blob-num js-line-number" data-line-number="1616"></td>
        <td id="LC1616" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1617" class="blob-num js-line-number" data-line-number="1617"></td>
        <td id="LC1617" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">workflow</span>` (</td>
      </tr>
      <tr>
        <td id="L1618" class="blob-num js-line-number" data-line-number="1618"></td>
        <td id="LC1618" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>WorkflowId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>workflow internal id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1619" class="blob-num js-line-number" data-line-number="1619"></td>
        <td id="LC1619" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>WorkflowName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">100</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>workflow name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1620" class="blob-num js-line-number" data-line-number="1620"></td>
        <td id="LC1620" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>WorkflowType<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>workflow type<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1621" class="blob-num js-line-number" data-line-number="1621"></td>
        <td id="LC1621" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>WorkflowNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>some description about workflow<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1622" class="blob-num js-line-number" data-line-number="1622"></td>
        <td id="LC1622" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>IsActive<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>1<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>flag if it is active<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1623" class="blob-num js-line-number" data-line-number="1623"></td>
        <td id="LC1623" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>WorkflowId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1624" class="blob-num js-line-number" data-line-number="1624"></td>
        <td id="LC1624" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>wf_name<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1625" class="blob-num js-line-number" data-line-number="1625"></td>
        <td id="LC1625" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>wf_type<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowType<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1626" class="blob-num js-line-number" data-line-number="1626"></td>
        <td id="LC1626" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>wf_active<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>IsActive<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1627" class="blob-num js-line-number" data-line-number="1627"></td>
        <td id="LC1627" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>workflow_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowType<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>generaltype<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>TypeId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1628" class="blob-num js-line-number" data-line-number="1628"></td>
        <td id="LC1628" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1629" class="blob-num js-line-number" data-line-number="1629"></td>
        <td id="LC1629" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1630" class="blob-num js-line-number" data-line-number="1630"></td>
        <td id="LC1630" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1631" class="blob-num js-line-number" data-line-number="1631"></td>
        <td id="LC1631" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1632" class="blob-num js-line-number" data-line-number="1632"></td>
        <td id="LC1632" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Table structure for table `workflowdef`</span></td>
      </tr>
      <tr>
        <td id="L1633" class="blob-num js-line-number" data-line-number="1633"></td>
        <td id="LC1633" class="blob-code blob-code-inner js-file-line"><span class="pl-c">--</span></td>
      </tr>
      <tr>
        <td id="L1634" class="blob-num js-line-number" data-line-number="1634"></td>
        <td id="LC1634" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1635" class="blob-num js-line-number" data-line-number="1635"></td>
        <td id="LC1635" class="blob-code blob-code-inner js-file-line"><span class="pl-k">DROP</span> <span class="pl-k">TABLE</span> IF EXISTS <span class="pl-s"><span class="pl-pds">`</span>workflowdef<span class="pl-pds">`</span></span>;</td>
      </tr>
      <tr>
        <td id="L1636" class="blob-num js-line-number" data-line-number="1636"></td>
        <td id="LC1636" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> @saved_cs_client     <span class="pl-k">=</span> @@character_set_client;</td>
      </tr>
      <tr>
        <td id="L1637" class="blob-num js-line-number" data-line-number="1637"></td>
        <td id="LC1637" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> utf8;</td>
      </tr>
      <tr>
        <td id="L1638" class="blob-num js-line-number" data-line-number="1638"></td>
        <td id="LC1638" class="blob-code blob-code-inner js-file-line"><span class="pl-k">CREATE</span> <span class="pl-k">TABLE</span> `<span class="pl-en">workflowdef</span>` (</td>
      </tr>
      <tr>
        <td id="L1639" class="blob-num js-line-number" data-line-number="1639"></td>
        <td id="LC1639" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>WorkflowdefId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> auto_increment COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>workflow step id<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1640" class="blob-num js-line-number" data-line-number="1640"></td>
        <td id="LC1640" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>WorkflowId<span class="pl-pds">`</span></span> <span class="pl-k">int</span>(<span class="pl-c1">11</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>workflow id - this step is part of<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1641" class="blob-num js-line-number" data-line-number="1641"></td>
        <td id="LC1641" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StepName<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">100</span>) <span class="pl-k">NOT NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>step name<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1642" class="blob-num js-line-number" data-line-number="1642"></td>
        <td id="LC1642" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StepOrder<span class="pl-pds">`</span></span> <span class="pl-k">tinyint</span>(<span class="pl-c1">4</span>) <span class="pl-k">NOT NULL</span> default <span class="pl-s"><span class="pl-pds">&#39;</span>0<span class="pl-pds">&#39;</span></span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>step order<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1643" class="blob-num js-line-number" data-line-number="1643"></td>
        <td id="LC1643" class="blob-code blob-code-inner js-file-line">  <span class="pl-s"><span class="pl-pds">`</span>StepNote<span class="pl-pds">`</span></span> <span class="pl-k">varchar</span>(<span class="pl-c1">254</span>) default <span class="pl-k">NULL</span> COMMENT <span class="pl-s"><span class="pl-pds">&#39;</span>step description<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L1644" class="blob-num js-line-number" data-line-number="1644"></td>
        <td id="LC1644" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">PRIMARY KEY</span>  (<span class="pl-s"><span class="pl-pds">`</span>WorkflowdefId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1645" class="blob-num js-line-number" data-line-number="1645"></td>
        <td id="LC1645" class="blob-code blob-code-inner js-file-line">  UNIQUE KEY <span class="pl-s"><span class="pl-pds">`</span>wfd_workflowname<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowId<span class="pl-pds">`</span></span>,<span class="pl-s"><span class="pl-pds">`</span>StepName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1646" class="blob-num js-line-number" data-line-number="1646"></td>
        <td id="LC1646" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>wfd_workflow<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowId<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1647" class="blob-num js-line-number" data-line-number="1647"></td>
        <td id="LC1647" class="blob-code blob-code-inner js-file-line">  KEY <span class="pl-s"><span class="pl-pds">`</span>wfd_name<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>StepName<span class="pl-pds">`</span></span>),</td>
      </tr>
      <tr>
        <td id="L1648" class="blob-num js-line-number" data-line-number="1648"></td>
        <td id="LC1648" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">CONSTRAINT</span> <span class="pl-s"><span class="pl-pds">`</span>workflowdef_ibfk_1<span class="pl-pds">`</span></span> <span class="pl-k">FOREIGN KEY</span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowId<span class="pl-pds">`</span></span>) <span class="pl-k">REFERENCES</span> <span class="pl-s"><span class="pl-pds">`</span>workflow<span class="pl-pds">`</span></span> (<span class="pl-s"><span class="pl-pds">`</span>WorkflowId<span class="pl-pds">`</span></span>) <span class="pl-k">ON DELETE</span> NO ACTION <span class="pl-k">ON</span> <span class="pl-k">UPDATE</span> NO ACTION</td>
      </tr>
      <tr>
        <td id="L1649" class="blob-num js-line-number" data-line-number="1649"></td>
        <td id="LC1649" class="blob-code blob-code-inner js-file-line">) ENGINE<span class="pl-k">=</span>InnoDB DEFAULT CHARSET<span class="pl-k">=</span>utf8;</td>
      </tr>
      <tr>
        <td id="L1650" class="blob-num js-line-number" data-line-number="1650"></td>
        <td id="LC1650" class="blob-code blob-code-inner js-file-line"><span class="pl-k">SET</span> character_set_client <span class="pl-k">=</span> @saved_cs_client;</td>
      </tr>
      <tr>
        <td id="L1651" class="blob-num js-line-number" data-line-number="1651"></td>
        <td id="LC1651" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */</span>;</td>
      </tr>
      <tr>
        <td id="L1652" class="blob-num js-line-number" data-line-number="1652"></td>
        <td id="LC1652" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1653" class="blob-num js-line-number" data-line-number="1653"></td>
        <td id="LC1653" class="blob-code blob-code-inner js-file-line"><span class="pl-k">INSERT INTO</span> <span class="pl-s"><span class="pl-pds">`</span>organisation<span class="pl-pds">`</span></span> <span class="pl-k">VALUES</span>  (<span class="pl-c1">1</span>,<span class="pl-s"><span class="pl-pds">&#39;</span>Diversity Arrays Technology Pty Ltd<span class="pl-pds">&#39;</span></span>);</td>
      </tr>
      <tr>
        <td id="L1654" class="blob-num js-line-number" data-line-number="1654"></td>
        <td id="LC1654" class="blob-code blob-code-inner js-file-line"><span class="pl-k">INSERT INTO</span> <span class="pl-s"><span class="pl-pds">`</span>contact<span class="pl-pds">`</span></span> <span class="pl-k">VALUES</span>  (<span class="pl-c1">1</span>,<span class="pl-s"><span class="pl-pds">&#39;</span>Arrays<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>Diversity<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span><span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>University of Canberra<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>02 6122 7300<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span><span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>admin@example.com<span class="pl-pds">&#39;</span></span>,<span class="pl-c1">1</span>);</td>
      </tr>
      <tr>
        <td id="L1655" class="blob-num js-line-number" data-line-number="1655"></td>
        <td id="LC1655" class="blob-code blob-code-inner js-file-line"><span class="pl-k">INSERT INTO</span> <span class="pl-s"><span class="pl-pds">`</span>systemgroup<span class="pl-pds">`</span></span> <span class="pl-k">VALUES</span>  (<span class="pl-c1">0</span>,<span class="pl-s"><span class="pl-pds">&#39;</span>admin<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>Admin group<span class="pl-pds">&#39;</span></span>);</td>
      </tr>
      <tr>
        <td id="L1656" class="blob-num js-line-number" data-line-number="1656"></td>
        <td id="LC1656" class="blob-code blob-code-inner js-file-line"><span class="pl-k">INSERT INTO</span> <span class="pl-s"><span class="pl-pds">`</span>systemuser<span class="pl-pds">`</span></span> <span class="pl-k">VALUES</span>  (<span class="pl-c1">0</span>,<span class="pl-s"><span class="pl-pds">&#39;</span>admin<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>dda375a9a8b5e9a809f1939a11a088e06862a253<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span><span class="pl-pds">&#39;</span></span>,<span class="pl-c1">1</span>,<span class="pl-s"><span class="pl-pds">&#39;</span>2013-12-11 10:01:35<span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span><span class="pl-pds">&#39;</span></span>,<span class="pl-s"><span class="pl-pds">&#39;</span>human<span class="pl-pds">&#39;</span></span>);</td>
      </tr>
      <tr>
        <td id="L1657" class="blob-num js-line-number" data-line-number="1657"></td>
        <td id="LC1657" class="blob-code blob-code-inner js-file-line"><span class="pl-k">INSERT INTO</span> <span class="pl-s"><span class="pl-pds">`</span>authorisedsystemgroup<span class="pl-pds">`</span></span> <span class="pl-k">VALUES</span>  (<span class="pl-c1">1</span>,<span class="pl-c1">0</span>,<span class="pl-c1">0</span>,<span class="pl-c1">1</span>);</td>
      </tr>
      <tr>
        <td id="L1658" class="blob-num js-line-number" data-line-number="1658"></td>
        <td id="LC1658" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1659" class="blob-num js-line-number" data-line-number="1659"></td>
        <td id="LC1659" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40101 SET SQL_MODE=@OLD_SQL_MODE */</span>;</td>
      </tr>
      <tr>
        <td id="L1660" class="blob-num js-line-number" data-line-number="1660"></td>
        <td id="LC1660" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */</span>;</td>
      </tr>
      <tr>
        <td id="L1661" class="blob-num js-line-number" data-line-number="1661"></td>
        <td id="LC1661" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */</span>;</td>
      </tr>
      <tr>
        <td id="L1662" class="blob-num js-line-number" data-line-number="1662"></td>
        <td id="LC1662" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */</span>;</td>
      </tr>
      <tr>
        <td id="L1663" class="blob-num js-line-number" data-line-number="1663"></td>
        <td id="LC1663" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */</span>;</td>
      </tr>
      <tr>
        <td id="L1664" class="blob-num js-line-number" data-line-number="1664"></td>
        <td id="LC1664" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */</span>;</td>
      </tr>
      <tr>
        <td id="L1665" class="blob-num js-line-number" data-line-number="1665"></td>
        <td id="LC1665" class="blob-code blob-code-inner js-file-line"><span class="pl-c">/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */</span>;</td>
      </tr>
      <tr>
        <td id="L1666" class="blob-num js-line-number" data-line-number="1666"></td>
        <td id="LC1666" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L1667" class="blob-num js-line-number" data-line-number="1667"></td>
        <td id="LC1667" class="blob-code blob-code-inner js-file-line"><span class="pl-c">-- Dump completed on 2014-09-03  2:35:00</span></td>
      </tr>
</table>

  </div>

</div>

<a href="#jump-to-line" rel="facebox[.linejump]" data-hotkey="l" style="display:none">Jump to Line</a>
<div id="jump-to-line" style="display:none">
  <!-- </textarea> --><!-- '"` --><form accept-charset="UTF-8" action="" class="js-jump-to-line-form" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>
    <input class="linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" aria-label="Jump to line" autofocus>
    <button type="submit" class="btn">Go</button>
</form></div>

        </div>
      </div>
      <div class="modal-backdrop"></div>
    </div>
  </div>


    </div>

      <div class="container">
  <div class="site-footer" role="contentinfo">
    <ul class="site-footer-links right">
        <li><a href="https://status.github.com/" data-ga-click="Footer, go to status, text:status">Status</a></li>
      <li><a href="https://developer.github.com" data-ga-click="Footer, go to api, text:api">API</a></li>
      <li><a href="https://training.github.com" data-ga-click="Footer, go to training, text:training">Training</a></li>
      <li><a href="https://shop.github.com" data-ga-click="Footer, go to shop, text:shop">Shop</a></li>
        <li><a href="https://github.com/blog" data-ga-click="Footer, go to blog, text:blog">Blog</a></li>
        <li><a href="https://github.com/about" data-ga-click="Footer, go to about, text:about">About</a></li>
        <li><a href="https://github.com/pricing" data-ga-click="Footer, go to pricing, text:pricing">Pricing</a></li>

    </ul>

    <a href="https://github.com" aria-label="Homepage">
      <span class="mega-octicon octicon-mark-github" title="GitHub"></span>
</a>
    <ul class="site-footer-links">
      <li>&copy; 2015 <span title="0.16709s from github-fe131-cp1-prd.iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="https://github.com/site/terms" data-ga-click="Footer, go to terms, text:terms">Terms</a></li>
        <li><a href="https://github.com/site/privacy" data-ga-click="Footer, go to privacy, text:privacy">Privacy</a></li>
        <li><a href="https://github.com/security" data-ga-click="Footer, go to security, text:security">Security</a></li>
        <li><a href="https://github.com/contact" data-ga-click="Footer, go to contact, text:contact">Contact</a></li>
        <li><a href="https://help.github.com" data-ga-click="Footer, go to help, text:help">Help</a></li>
    </ul>
  </div>
</div>



    
    
    

    <div id="ajax-error-message" class="flash flash-error">
      <span class="octicon octicon-alert"></span>
      <button type="button" class="flash-close js-flash-close js-ajax-error-dismiss" aria-label="Dismiss error">
        <span class="octicon octicon-x"></span>
      </button>
      Something went wrong with that request. Please try again.
    </div>


      <script crossorigin="anonymous" src="https://assets-cdn.github.com/assets/frameworks-7d180c2bb5779ecb7ab5d04ce8af999e73836dcf0df1a8c44b69c62a1de0732f.js"></script>
      <script async="async" crossorigin="anonymous" src="https://assets-cdn.github.com/assets/github-4124fa34f820cfc0ed2519b488b60b9b547d96a68e4ded4efe0d6735dc3fcef2.js"></script>
      
      
    <div class="js-stale-session-flash stale-session-flash flash flash-warn flash-banner hidden">
      <span class="octicon octicon-alert"></span>
      <span class="signed-in-tab-flash">You signed in with another tab or window. <a href="">Reload</a> to refresh your session.</span>
      <span class="signed-out-tab-flash">You signed out in another tab or window. <a href="">Reload</a> to refresh your session.</span>
    </div>
  </body>
</html>

