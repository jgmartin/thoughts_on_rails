### clone project from github
git clone git://github.com/imathis/octopress.git octopress

### note: .rvmrc included... popup thing

### create gemset
rvm --create --rvmrc 1.9.3-p327@octopress

### install bundler
gem install bundler

### bundle
bundle install

### install the default theme
rake install

### deploy to heroku
  - gem install heroku
  - 
