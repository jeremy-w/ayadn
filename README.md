AYADN
=====

[App.net](http://app.net) command-line client written in Ruby.

## Features

- read your App.net personalized stream

- write a post

- reply to a post 

- read the conversation around a post

- star/unstar a post

- repost/unrepost a post

- follow/unfollow a user

- mute/unmute a user

- search posts for word(s)

- search posts with hashtag

- get informations on a post/user

- get posts from a user

- get posts mentioning a user

- get posts starred by a user

- get posts reposted by a user

- get users who starred/reposted a post

- read other streams: Checkins, Global, Trending, Conversations

- delete a post

- save/load a post

- backup/display your lists of followings, followers, muted users...

- create links with Markdown in your text

- and more!


## TL;DR

```
git clone https://github.com/ericdke/ayadn.git
cd ayadn-master && chmod +x ayadn.rb
bundle install
[copy/paste your authentication token]
./ayadn.rb write 'Posting to App.net with Ruby!'
``` 

## Instructions

Mac OS X + Linux = it just works.

Windows = install Ruby with [http://rubyinstaller.org](http://rubyinstaller.org), it will automatically install Rubygems.

### Step 1

Download the ZIP (button in the sidebar) or clone the project:

```
git clone https://github.com/ericdke/ayadn.git
```  

### Step 2

#### With Bundler

If you already have [bundler](http://bundler.io) installed, you just have to enter the app folder and run `bundle install`:

```
cd ayadn-master
bundle install
```  

**Installation done, you can jump to Step 3 now**.

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

*Windows, again: jump to Step 4 now.*

Installing the gems only has to be done *once*, it's not necessary to do it each time you update AyaDN.

### Step 3

While you can use the app with the ruby interpreter -see [How to use](https://github.com/ericdke/ayadn#how-to-use)-, it's recommended to make the app executable:

```
chmod +x ayadn.rb
```  

and to declare the app folder in your $PATH *or* create a symlink of the app in `/usr/local/bin` or whatever you're using as your $PATH.

```
sudo ln -s ayadn.rb /usr/local/bin/ayadn
source ~/.bashrc
```  

### Step 4

I haven't coded an interactive authentification system yet, so you **have to** copy/paste your own unique token into the `token.rb` file.

- Connect to your app.net page, go to `settings`, go to `Manage apps` and in `Your app` create a new app with these characteristics: 

    - Application Name: "AyaDN"
    - Website: "http://ayadn-app.net"
    - Callback URL: leave it like it is

then in `App settings` click on `Generate a user token for yourself`. Copy the code it gives you back, it's your unique authentication token for using AyaDN.

- In any text editor, open the file `token.rb` and paste the token between the ticks:

![Paste your token in the file](https://www.evernote.com/shard/s89/sh/f7a5778c-f3db-4be8-9d95-0e9f14234899/3c061a327822a7a1a9e0bf1bcd70488f/deep/0/token.png)

Hit `Save` and you're done.

## How to use

**You type the name of the app + the action you want to do + the target of this action.**

If you don't provide any option to ayadn.rb, your personnalized stream is displayed.

If you provide the `write` command without text, you will enter the compose message feature. *(recommended)*  

By default, AyaDN displays only the new posts in the stream since your last visit.

### Through the Ruby interpreter

If you've not made the app executable, use it through Ruby:

```
ruby ayadn.rb
ruby ayadn.rb write
```

### As an executable in your PATH

If the app is executable and in your $PATH, just launch it:

```
ayadn.rb
ayadn.rb write 
```

### If you made the symlink

```
ayadn
ayadn write 
```  

### As a local executable

If the app is executable but not in your $PATH, then launch it locally:

```
./ayadn.rb
./ayadn.rb write
```  

### With an alias (recommended)

My advice is to make an alias in your `.bashrc`:

```
alias a="your/path/to/ayadn.rb"
```  

Refresh:  

```
source ~/.bashrc
```  

Then it's easier to use, and very fast with the app's shortcuts:

```
a 
a w
```  

Enjoy!  

## List of commands

The first 5 lines include the `[PRESS ENTER KEY]` indication but I don't continue after for obvious readability reasons.  

```
ayadn [PRESS ENTER KEY] *to display the unified stream*
ayadn write [PRESS ENTER KEY] *then write your post*
ayadn write '@ericd Good morning Eric!' [PRESS ENTER KEY] *(prefer the previous method, safer)*
ayadn write "[Subscribe](https://app.net/c/2zqf) to the #AyaDN broadcast!" [PRESS ENTER KEY] *Markdown links are supported*
ayadn reply 15723266 [PRESS ENTER KEY] *then write your post*
ayadn global
ayadn checkins
ayadn trending
ayadn photos
ayadn conversations
ayadn mentions @ericd
ayadn mentions me
ayadn posts @ericd
ayadn posts me
ayadn starred @ericd
ayadn starred me
ayadn starred 15723266
ayadn reposted 15723266
ayadn infos @ericd
ayadn infos me
ayadn infos 15723266
ayadn convo 15726105
ayadn tag nowplaying
ayadn follow @ericd
ayadn unfollow @ericd
ayadn mute @ericd
ayadn unmute @ericd
ayadn list muted
ayadn list followings @ericd
ayadn list followings me
ayadn list followers @ericd
ayadn list followers me
ayadn backup followings @ericd
ayadn backup followings me
ayadn backup followers @ericd
ayadn backup followers me
ayadn search ruby
ayadn search ruby,json
ayadn star 15723266
ayadn unstar 15723266
ayadn repost 15723266
ayadn unrepost 15723266
ayadn delete 12345678
ayadn save 15723266
ayadn load 15723266
ayadn reset pagination
```  


## Tips

### Unsafe commands

Some commands like *delete a post* don't have a shortcut, reducing the risk of accidental manipulation.

### GCC

If you've got an error while installing or cloning regarding `gcc`
not found, just type:

```
which gcc
```  

It should give you the location of your `gcc`, typically `/usr/bin/gcc`. Then make a symlink:

```
sudo ln -s /usr/bin/gcc /usr/bin/gcc-4.2
```  

On Mac OS X, you may have to answer `yes` if your computer asks you to download and install the "developer tools".  

### "me"

With some features like `infos`, `mentions` and more, you can replace `@username` by `me` if you want to check yourself.  


### Backup some data

```
ayadn.rb backup followings @ericd
ayadn.rb backup followers @ericd
ayadn.rb backup muted
```  

A JSON file containing the username and real name of your followings/followers/muted will be saved in `%USERDIR%/ayadn/data/lists`.

The `muted` option only works for yourself (this is a limitation from the API).

### Post links

- Write/paste a simple link:

```
ayadn.rb write "Subscribe to the #AyaDN broadcast! https://app.net/c/2zqf"
```  

- Write/paste a markdown link to embed the link:

```
ayadn.rb write "[Subscribe](https://app.net/c/2zqf) to the #AyaDN broadcast!"
```  

### Reset pagination data

If AyaDN shows you "No recent posts in this stream" but you still want to see the stream, you have to reset the pagination data first (without arguments: resets all pagination data).

```
./ayadn.rb reset pagination
./ayadn.rb reset pagination unified
./ayadn.rb reset pagination mentions @ericd
(etc)
```  

### Configuration

You can modify the values (right hand) in the `config.yml` file but be very careful not to modify anything else: don't change the indentation or the name of the keys (left hand), don't add or remove quotes or special characters, etc,  otherwise it may break the Internets.

## Help

Be aware of the way the console treats what you type.

When posting with `"double quotes"`, any special character will be interpreted! So `"echo !"` becomes `"echo last command"`. You may not want to do that...

So you have to post with `'simple quotes'`, this way the console don't mess with your content.

The thing is, how do you then post a text *containing one ore more exclamation marks AND/OR one or more simple quotes?*

The answer is to post with *"double quotes"* but use `\`, the *antislash* character, before any exclamation mark:

```
ayadn.rb write "Here's an escaped exclamation mark \! and a normal simple quote in the same text."
```  

**To avoid any problem, post with the compose feature, that is to say without providing arguments:** 

`ayadn.rb write`  


## Demo

*(todo)*

A few screencaps [here](http://ericd.re-app.net).

## Contact

Contact me on ADN [(@ericd)](http://alpha.app.net/ericd) if you have questions, ideas, if you've found bugs, or... if you know Ruby and you want to help a newbie to code better. ;)

Don't bother with @ayaio or @aya_tests, they are bots. The handle for the app itself is [@ayadn](http://alpha.app.net/ayadn).

## Credits

### Beta-testers

- Windows: [@ksniod](http://alpha.app.net/ksniod)

- Linux: 

    - [@martner_mala](http://alpha.app.net/martner_mala)
    - [@nguarracino](http://alpha.app.net/nguarracino)

- OpenBSD: *(soon)*
