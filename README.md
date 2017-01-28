fetor
=========
FakE traffic generaTOR - simple Perl daemon to generate some network traffic in
background. May be useful to obfuscate real network activity by creating
background noise, simulate it or just to generate some pseudorandom network HTTP
traffic.

Description
---------
* reads URLs from config file
* visit each URL and look for URLs on website
* checks if found URLs works and adds it to a list
* starts children processes downloading content of random URLs in random delays

Usage
---------
* clone this repository
* adjust config file (number of forked processes, random delays)
* run script with perl FakEtrafficgeneraTOR.pl

Notes
---------
* config file has to contains URLs
* you can disable/comment lines in config file with # sign
* it's rather WIP than ready software
* it does not mask real traffic in reliable way, it just makes spying/recording
  real traffic harder and more expensive

How to commit
---------
* Fork repo on GitHub
* Comment your changes
* Send pull request
