AYADN
=====

App.net command-line client written in Ruby.

## Features

- read your App.net unified stream

- write a post

- reply to a post 

- read the conversation around a post

- star/unstar a post

- follow/unfollow a user

- search hashtags 

- get informations on a post/user

- get posts from a user

- get posts mentioning a user

- get posts starred by a user

- get users who starred a post

- read the App.net Global stream

- read the App.net Explore streams: trending, checkins, conversations

- delete a post  


## TL;DR

```
git clone https://github.com/ericdke/ayadn.git
cd ayadn-master && chmod +x ayadn.rb
bundle install
[copy/paste your token from Dev-Lite]
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

### Step 4

I haven't coded an interactive authentification system yet, so you **have** to copy/paste your own unique token into the `token.rb` file.

This is easy:

- Go to [http://dev-lite.jonathonduerig.com](http://dev-lite.jonathonduerig.com) and click the `Authorize` button, connect with your App.net account then copy the token Dev-Lite gives you back.

- In any text editor, open the file `token.rb` and paste the token between the ticks:

![Paste your token in the file](https://www.evernote.com/shard/s89/sh/45c60042-292b-40ae-9a6a-fb23b4d93823/77635d28512633cd9fcf3315188b1096/deep/0/token.rb.png)

Hit `Save` and you're done.

## How to use

**You type the name of the app + the action you want to do + the target of this action.**

**If you don't provide any argument to the app, your personnalized stream is displayed.**

**If you provide the `write` command without text, you will enter the compose message feature.** *(recommended)*

### Through the Ruby interpreter

If you've not made the app executable, use it through Ruby:

```
ruby ayadn.rb
ruby ayadn.rb write
ruby ayadn.rb write 'Good morning ADN!!!'
ruby ayadn.rb write '@ksniod Bonjour Laurent'
ruby ayadn.rb reply 14579853
ruby ayadn.rb tag music
ruby ayadn.rb posts @ericd
ruby ayadn.rb star 14760322
ruby ayadn.rb starred @jws
ruby ayadn.rb starred 14682795
ruby ayadn.rb reposted 14805563
ruby ayadn.rb infos 14582145
ruby ayadn.rb convo 14638413
```

### As an executable in your PATH

If the app is executable and in your $PATH, just launch it:

```
ayadn.rb help
ayadn.rb write 
ayadn.rb write 'Posting from AyaDN in #Ruby!'
ayadn.rb write '@davidby Salut David, comment va ?'
```

And maybe make a symlink:

```
ln -s ayadn.rb ayadn
```  

->

```
ayadn infos @fredvd
ayadn tag ruby
ayadn mentions @timrowe
ayadn reply 14579853
ayadn unstar 14746446
ayadn starred @martner_mala
```  

### As a local executable

If the app is executable but not in your $PATH, then launch it locally:

```
./ayadn.rb
./ayadn.rb w
./ayadn.rb write '#Nowplaying some awesome music'
./ayadn.rb checkins
./ayadn.rb conversations
./ayadn.rb trending
```  

### With an alias (recommended)

My advice is to make an alias in your `.bashrc`:

```
alias a="your/path/to/ayadn.rb"
```  

Then it's easier to use, and very fast with the app's shortcuts:

```
a 
a h
a w
a w 'The power of #shortcuts!'
a r 14579853
a i @ksniod
a i 14698777
a p @ericd
a m @charl
a s @nam3
a c 14638413
a t adnafterdark
```  

Want to be the ultimate geek?

```
alias p='ayadn.rb w '
```  

->

```
p 'Wohoo! Posting to App.net with a single keystroke! #AyaDN'
```  

Enjoy!  

## Tips

### Data about yourself

When you want to ask information about yourself (the App.net account connected to AyaDN), you can use the keyword `me` instead of your `@username` to get correct data.

```
ayadn.rb infos me
```  

*Only available for the 'infos' action at the moment (V0.11)*

### Post a single word

No need to provide quotes if you want to post a single word (no spaces).

```
ayadn.rb write Awesome!
```  

*But maybe you shouldn't post single words to ADN... :p*

### Unsafe commands

Some commands like *star a post* (and others to come) don't have a shortcut, this is to reduce the risk of accidental manipulation.

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

Contact me on ADN [(@ericd)](http://alpha.app.net/ericd) if you have questions, ideas, if you've found bugs, or... if you know Ruby and you want to help a newbie refactoring his code. ;)

Don't bother with @ayaio or @aya_tests, they are bots. The handle for the app itself is @ayadn but it's not active yet.

## Credits

### Beta-testers

- Windows: [@ksniod](http://alpha.app.net/ksniod)

- Linux: 

    - [@martner_mala](http://alpha.app.net/martner_mala)
    - [@nguarracino](http://alpha.app.net/nguarracino)

- OpenBSD: *(soon)*
