AYADN
=====

App.net command-line client in Ruby.

## Features

- read your App.net unified stream

- write a post

- search hashtags  

- get informations about a user

- get the last posts from a user

- get the last posts mentioning a user

- get the last posts starred by a user

- read the App.net global stream

- get detailed informations on a post


## Instructions

On Mac OS X Ruby should already be installed. 

Windows users: first install Ruby with [http://rubyinstaller.org](http://rubyinstaller.org), it will automatically install Rubygems.

The app hasn't been tested on Linux yet, but it should work.

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

Installation done, you can **jump to Step 3 now**.

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

*Sometimes Windows seems to have problems with UTF8 and Ruby quits with errors. I haven't found a solution yet. Note: I don't have Windows, so... :p*

*Windows, again: jump to Step 4 now.*

### Step 3

While you can use the app with the ruby interpreter (see 'How to use'), it's recommended to make the app executable:

```
chmod +x ayadn.rb
```  

and to declare the app folder in your $PATH *or* create a symlink of the app in `/usr/local/bin` or whatever you're using as your $PATH.

### Step 4

I haven't coded an interactive authentification system yet, so you **have** to copy/paste your own unique token into the `token.rb` file.

This is easy:

- Go to [http://dev-lite.jonathonduerig.com](http://dev-lite.jonathonduerig.com) and click the `Authorize` button. Copy the token it gives you back.

- In any text editor, open the file `token.rb` and paste the token between the ticks:

![Paste your token in the file](https://www.evernote.com/shard/s89/sh/45c60042-292b-40ae-9a6a-fb23b4d93823/77635d28512633cd9fcf3315188b1096/deep/0/token.rb.png)

Hit `Save` and you're done.

## How to use

If you've not made the app executable, use it through Ruby:

```
ruby ayadn.rb
ruby ayadn.rb write 'Good morning ADN!!!'
ruby ayadn.rb posts @ericd
ruby ayadn.rb stars @jws
ruby ayadn.rb tag music
ruby ayadn.rb details 14582145
```

If the app is executable and in your $PATH, just launch it:

```
ayadn.rb help
ayadn.rb write 'Posting from AyaDN in #Ruby!'
ayadn.rb infos @fredvd
ayadn.rb tag ruby
ayadn.rb mentions @timrowe
```  

If the app is executable but not in your $PATH, then launch it locally:

```
./ayadn.rb
./ayadn.rb write '#Nowplaying some awesome music'
```  

My advice is to make an alias in your `.bashrc`:

```
alias a="your/path/to/ayadn.rb"
```  

Then it's easier to use, and very fast with the app's shortcuts:

```
a 
a h
a w 'The power of #shortcuts!'
a g
a i @ksniod
a p @ericd
a t adnafterdark
a m @hry
a p @nam3
a d 14579853
```  

Enjoy!  

## Contact

You can contact me on [App.net](http://alpha.app.net/ericd) if you have questions, ideas, if you've found bugs, or... if you know Ruby and you want to help some poor newbie. ;)

## Help

Be aware of the way the console treats what you type.

When posting with `"double quotes"`, any special character will be interpreted! So `"echo !"` becomes `"echo last command"`. You may not want to do that...

So you have to post with `'simple quotes'`, this way the console don't mess with your content.

The thing is, how do you then post a text *containing one ore more exclamation marks + one or more simple quotes*?

The answer is to use `\`, the *antislash* character, before any exclamation mark when posting **with double quotes**. 

Put an antislash before the special character that would be escaped, like this:

```
ayadn.rb write "Here's an escaped exclamation mark \!."
```  

In the future I will implement a method to automatically strip/escape the special characters. In the meantime, just be careful.

## Screencaps

![Write](https://www.evernote.com/shard/s89/sh/5f62c5f7-9232-4e1e-88d3-558af51814de/3adbfcbb38ce1ffae81e5ad0117f0689/deep/0/ayadn-write.png)

![Stream](https://www.evernote.com/shard/s89/sh/c6dc5210-db9c-4068-8e7d-ffd9fa1e1da7/2e983a17a452d3fa9d8b76355e05d70a/deep/0/ayadn-stream.png)

![Tag search](https://www.evernote.com/shard/s89/sh/a41e4e52-09af-4ad9-8fa5-4690b08bdf09/d9a70ddea0cc5eb4ce0a593974d596e6/deep/0/ayadn-hashtag.png)

![Post details](https://www.evernote.com/shard/s89/sh/62090404-4996-42b1-b558-ae5dc5fed8ca/3b7cf40503570db9cb1382826c767312/deep/0/ayadn-details.png)

![Help](https://www.evernote.com/shard/s89/sh/a3314901-093c-423a-81a8-b74554b2dd1e/575e5f316249822490a67e0bca4e3bc3/deep/0/ayadn-help.png)


