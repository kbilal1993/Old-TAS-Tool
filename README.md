# Old-TAS-Tool

An archive of the software part of my old university final year project: A device which pretends to be a keyboard, and sends key presses read from a script. It's not very good, and I'm planning on redoing this in the future.

## Overview

setup.sh tells the Beaglebone Black to start a serial session. This is run first.

parse.perl is run with a script in the scripts folder. It interprets the script and outputs information through serial as it goes.

The scripts folder contains some example scripts I made to demonstrate the project. Two that print random text, and one that's supposed to work with a SEGA Master System emulator and a copy of Sonic 1, which beats the first level using a glitch.

## Commentary

The code in this repo ran on a Beaglebone Black, connected to a Teensy 2.0 via serial. The Teensy would then connect to a computer by USB and appear as a keyboard. The BBB would read a script containing button inputs, and pass them on to the Teensy to send as a standard USB keyboard event.

If this sounds complicated, that's because it is. I aimed too high, and ended up with a project that just barely managed. I learned a lot though, and this project got me into electrical engineering as a hobby.
