# DroidDucky

## Abstract
*DroidDucky* is a [duckyscript](https://github.com/hak5darren/USB-Rubber-Ducky/wiki/Duckyscript) interpreter written in Bash which brings all of ducky scripting goodness to Android.

## Usage
In order to use *DroidDucky* you have to have some kind of Android terminal emulator application. Lots of them can be found on the [Play Store](https://play.google.com/store/search?q=terminal%20emulator) (both free and paid). I’m currently using *JuiceSSH*, and I can recommend it. Also, you'll have to have a custom kernel with [android-keyboard-gadget](https://github.com/pelya/android-keyboard-gadget) support.

Syntax is quite simple. Just run droidducky.sh with payload file name as the last argument. You can specify the keyboard layout option with -k, for example a french layout *fr*. By default is *us*. Make sure that droidducky.sh has execution permission.

    bash droidducky.sh -k fr payload.duck

## Example
You can try the payload code below.

    REM Loading payload code.
    GUI r
    STRING cmd
    REM Opening command prompt.
    ENTER
    DELAY 100
    REM Sending the message.
    STRING Hello World! I'm in guys.

## Live demonstration
[Executing DuckSlurp payload using DroidDucky](https://youtu.be/J5EbvqSoRzQ).

## Detailed info
More information about this project, including implementation details can be found in the following blog post: [DroidDucky - Can an Android quack like a duck?](http://zx.rs/6/DroidDucky---Can-an-Android-quack-like-a-duck/).

## Ideas ##
Implement dry run. Hint: https://ragrawal.wordpress.com/2012/03/19/dry-run-in-shell-scripts/