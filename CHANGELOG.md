AYADN
=====

AYADN is a learning exercise: while it's fully functional, it's still very alpha (remember I'm a beginner with Ruby).  

## 2013-12-22 v0.5.1c
- AyaDN follows the ADN config protocol (automatic post and message length)
- faster + lower memory usage
- list of commands
- bugfix in mute/unmute

## 2013-12-21 v0.5.1b
- layout bug fixes
- list all channels and show types + names
- send message to any channel
- backup list of channels

## 2013-12-20 v0.5.1a
- lots of bug squashing
- faster, faster, pussycat
- layout is more consistent
- new: at the end of the headline,
    - put the name of the post's ADN client (option, false by default)
    - put "<" if post is a reply, ">" if post has replies, "< >" if post is both (option, true by default)
- semantic versioning
- changed the way the API endpoints are managed
- connection and loading info displayed while calling the API


## 2013-12-19 v0.40
- Skip posts containing specific @username!

## 2013-12-15 v0.38
- Skip posts containing specific #hashtag!
- better colors and layout
- better username detect
- bugfixes
- introducing AyaDN to some multithreading :)

## 2013-12-14 v0.37
- many bugfixes
- internal code improvements

## 2013-12-12 v0.36
- No more Rest-Client, all HTTP by hand

## 2013-12-10 v0.35
- Save a post to Pinboard!

## 2013-12-08 v0.34b
- Upload a file to your ADN account! (no Windows support)
- Delete a file from your ADN account!
- Change file attribute: private/public!

## 2013-12-07 v0.34a
- List your ADN files!
- Download files from your ADN account!
- authorization bugfix
- explore streams bugfix
- various bugfixes and improvements

## 2013-12-02 v0.33
- Skip specific clients!
- improvement in the colorization of posts

## 2013-11-30 v0.32
- Refactoring
- Local permanent config!
- Auto redirect to original post when replying, (un)reposting and (un)starring!

## 2013-11-29 v0.31
- Interactions!

## 2013-11-28 v0.30
- Authorize with your App.net account in AyaDN! (no more `token.rb`)

## 2013-11-26 v0.26
- Private messages!

## 2013-11-25 v0.25
- config bugfix
- multiple accounts

## 2013-11-24 v0.24
- Config! 
    - number of elements in each stream
    - timeline order normal/inverse
    - directed posts
- Scrolling streams!
- show a few posts from the stream after posting

## 2013-11-23 v0.23
- Markdown links
- AyaDN displays only the new posts in the stream since your last visit!
- new token procedure

## 2013-11-21 v0.22
- search for word(s) 

## 2013-11-19 v0.21
- bugfixes
- backup/display followings/followers/muted lists
- mute/unmute a user

## 2013-11-17 v0.20
- major internal refactoring

## 2013-11-12 v0.15
- see who starred this post!
- see who reposted this post!
- follow/unfollow a user!
- delete a post!
- get original post from a repost!

## 2013-11-11 v0.14
- auto-fill with the right mentions when replying!
- refactoring
- star/unstar a post!
- Explore Streams!

## 2013-11-11 v0.13
- better layout

## 2013-11-10 v0.12
- Reply to!
- better help screen
- `details` is gone, merged with `infos`

## 2013-11-10 v0.11
- somewhat compatible Windows

## 2013-11-09 v0.10
- methods refactoring
- better error handling
- bugfixes
- optimizations
- Conversations!

## 2013-11-09 v0.09
- Post details!
- shortcuts
- bugfixes
- better help + readme

## 2013-11-08 v0.08
- Write you own posts!

## 2013-11-08 v0.07
- Each lib in its own file
- token is declared in a separate file
- Global stream!
- I botched the GitHub repo, so I had to start again from zero: no commit history before today

## 2013-11-08 v0.06
- Changed the logic for ARGV
- Inverted syntax for better consistence
- Hashtag search!

## 2013-11-07 v0.05
- User starred posts!
- Bug fixes

## 2013-11-06 v0.04b
- User mentions!

## 2013-11-06 v0.04a
- Refactored libs
- Token is declared in main app
- Fixed 'deleted posts' bug
- Add Gemfile
- Better platform detection

## 2013-11-05 v0.03
- Platform detection
- Colorization is Windows-compatible

## 2013-11-04 v0.02b
- User infos!
- User posts!

## 2013-11-04 v0.02a
- Unified stream (+ directed posts)!
- colorization
- ARGS

## 2013-11-03 v0.01
- Basic structure for an App.net read-only commande-line client

