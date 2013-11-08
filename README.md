AYADN
=====

App.net read-only command-line client as an exercise for learning Ruby.

## Features

- read your App.net unified stream

- read the App.net global stream

- get informations about a user

- get the last posts from a user

- get the last posts mentioning a user

- get the last posts starred by a user

- search hashtags  


## Instructions

On Mac OS X Ruby should already be installed. 

Windows users: first install Ruby with [http://rubyinstaller.org](http://rubyinstaller.org), it will automatically install Rubygems.

The hasn't been tested on Linux yet, but it should work.

### Step 1

Download the ZIP (button in the sidebar) or clone the project:

```
git clone https://github.com/ericdke/ayadn.git
```  

### Step 2

#### With Bundler

If you already have `bundler` installed, you just have to enter the app folder and run `bundle install`:

```
cd ayadn-master
bundle install
```  

Installation done, you can jump to Step 3 now.

#### Without Bundler

If you're not using Bundler, you have to install some dependencies manually:

```
cd ayadn-master
gem install json
gem install rest-client
```  

*Windows*: you have one more gem to install:

```
gem install win32console -v 1.3.2
```

### Step 3

While you can use the app with the ruby interpreter (see 'How to use'), it's recommended to make the app executable:

```
chmod +x ayadn.rb
```  

and to declare the app folder in your $PATH *or* create a symlink of the app in `/usr/local/bin` or whatever you're using as your $PATH.

### Step 4

I haven't coded an interactive authentification system yet, so you **have** to copy/paste your own unique token into the main file.

This is easy:

- Go to [http://dev-lite.jonathonduerig.com](http://dev-lite.jonathonduerig.com) and click the `Authorize` button. Copy the token it gives you back.

- In any text editor, open the file `ayadn.rb` and paste the token between the ticks, like this:

![Paste your token in the file](https://www.evernote.com/shard/s89/sh/62c690fd-3852-4ef9-b15a-ff0a5b40b901/d4dd6fb6e08c07db2a83b99a90ae01f0/deep/0/token.png)

Hit `Save` and you're done.

## How to use

If you've not made the app executable, use it through Ruby:

```
ruby ayadn.rb stream
ruby ayadn.rb posts @ericd
ruby ayadn.rb stars @jws
ruby ayadn.rb tag music
```

If the app is executable and in your $PATH, just launch it:

```
ayadn.rb help
ayadn.rb infos @fredvd
```  

If the app is executable but not in your $PATH, then launch it locally:

```
./ayadn.rb
./ayadn.rb global
./ayadn.rb mentions @hry
```  

My advice is to make an alias in your `.bashrc`:

```
alias a="your/path/to/ayadn.rb"
```  

Then it's easier to use:

```
a stream
a global
a infos @ksniod
a posts @ericd
a tag adnafterdark
```  

## Contact

You can contact me on [App.net](http://alpha.app.net/ericd) if you have questions, ideas, if you've found bugs, or... if you know Ruby and you want to help some poor newbie. ;)

## Screencaps

![Help](https://www.evernote.com/shard/s89/sh/c94deb1f-318f-405b-b4bd-05e084d90f13/9d4553a41dddf7c582e1e152f67d8ddd/deep/0/help.png)

![Stream](https://www.evernote.com/shard/s89/sh/19f3cf86-9af7-4417-a800-ad7e4f228606/29461ebb02b50eac4796d1c7b4f15f6f/deep/0/stream.png)

![Tag search](https://www.evernote.com/shard/s89/sh/e5bc450f-4c8a-4c66-91e6-8a66bfa76ab4/7d7ed1f01c75cc9b86d6be56a0a59c2c/deep/0/tag.png)


