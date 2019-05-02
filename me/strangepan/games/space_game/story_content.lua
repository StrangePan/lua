return {
  ['Story Page 1'] = {
    text = 'The light engine is malfunctioning. Every waning light in this ship is flashing. The pirates must have hit you just before warping. The controls aren\'t responding. Running diagnostics yields a blank, blue screen. Thanks Windows, so useful.\
\
It feels like you\'ve been warping for hours. Finally, you break out of warp. You see a small planet with a space port.\
\
They hail you, but you don\'t recognize their faction.',
    options = {
      {
        text = 'Defend with the ship\'s weapons',
        dest = 'Story Page 4',
      },
      {
        text = 'Flee',
        dest = 'Story Page 3',
      },
      {
        text = 'Respond to comms',
        dest = 'Story Page 2',
      },
    },
  },

  ['Story Page 2'] = {
    text = 'You open the comms port. You see an older man on the video feed, overweight and wearing a green hat.\
\
"Oi there, young feller. You seem to be in a bit of a ruffelsnuff. Let\'s haul your ass back to port before something worse happens to ya."',
    options = {
      {
        text = 'Agree and thank the man',
        dest = 'Story Page 5',
      },
      {
        text = 'Decline politely',
        dest = 'Story Page 6',
      },
      {
        text = 'Decline rudely',
        dest = 'Story Page 7',
      },
    },
  },

  ['Story Page 3'] = {
    text = 'Checking all the equipment, you see the only reason you broke out of warp was because you ran out of fuel to keep the worm hole open.\
\
You\'re stranded, whether you like it or not.',
    options = {
      {
        text = 'Respond to comms',
        dest = 'Story Page 2',
      },
      {
        text = 'Defend with the ship\'s weapons',
        dest = 'Story Page 4',
      },
    },
  },

  ['Story Page 4'] = {
    text = 'You power up weapons and shields, and take aim at the closest ship. You hit the ship with your laser, its shields weren\'t up yet and it explodes. You see shields come up on the other ship which fires at you.\
\
It hits you. Turns out that your shields were damaged from the warp. You hear the air quickly leaving your ship. You fire at the second ship, but pass out before you see if you hit.\
\
You are dead.',
    options = {
      {
        text = 'Restart',
        dest = 'Story Page 1',
      },
    },
  },

  ['Story Page 5'] = {
    text = 'The stranger\'s ship uses a tractor beam to connect to your ship.\
\
"This sector is controlled by the Sanguine Serpent Company of star A7-63VVE7. Your ship took quite a beating, but you look young enough to afford the repairs."\
\
You have no idea where you are or what the man is talking about.',
    options = {
      {
        text = 'Ask for more detail',
        dest = 'Story Page 11',
      },
      {
        text = 'Wait until docked at the station',
        dest = 'Story Page 12',
      },
    },
  },

  ['Story Page 6'] = {
    text = 'You attempt to repair the ship. You\'re out of fuel, your shields are busted, and navigation doesn\'t know where you are.\
\
You can use emergency power to start heading towards the station, but you\'ll have to pilot the ship manually.',
    options = {
      {
        text = 'Hail the trucker',
        dest = 'Story Page 8',
      },
      {
        text = 'Manually fly the ship to the station',
        dest = 'Story Page 9',
      },
    },
  },

  ['Story Page 7'] = {
    text = 'You don\'t need anyone\'s help, you\'ve been sailing the stars since you were a child.\
\
You attempt to repair the ship. You\'re out of fuel, your shields are busted, and navigation doesn\'t know where you are.\
\
You can use emergency power to start heading towards the station, but you\'ll have to pilot the ship manually.',
    options = {
      {
        text = 'Hail the trucker',
        dest = 'Story Page 10',
      },
      {
        text = 'Manually fly the ship to the station',
        dest = 'Story Page 9',
      },
    },
  },

  ['Story Page 8'] = {
    text = 'You open comms with the trucker.\
\
"Oi again. Did you need something?"\
\
You explain it\'s too dangerous to fly your ship into port yourself and that you could use a tow.\
\
"A\'ight, wait right there an\' we\'ll get you to the station."',
    options = {
      {
        text = 'Continue',
        dest = 'Story Page 5',
      },
    },
  },

  ['Story Page 9'] = {
    text = 'You\'re feeling pretty confident in your flying. You navigate to the port and line up with the dock. Just before locking in, your backup power runs out. You drift into the plated hull of the space port and explode.',
    options = {
      {
        text = 'Restart',
        dest = 'Story Page 1',
      },
    },
  },

  ['Story Page 10'] = {
    text = 'You hail the trucker. He laughs at you and says you\'re on your own. No one else responds to your hails. Emergency power runs out an hour later and you suffocate.',
    options = {
      {
        text = 'Restart',
        dest = 'Story Page 1',
      },
    },
  },

  ['Story Page 11'] = {
    text = '"You must not be from \'round these parts. We get folks like you every once a while. People \'round these parts don\'t use those fancy credit things you outsid\'rs use.\
 \
 "Once we get you to port, we\'ll hook you up with your own blood crystal. You can use your time just like the rest of us normal folk."',
    options = {
      {
        text = 'Wait until docked at the station',
        dest = 'Story Page 12',
      },
    },
  },

  ['Story Page 12'] = {
    text = 'Your ship finally docks at the space port. A dock inspector comes up to you.\
\
"Docking fees apply. That\'ll be 25 days. Scan your blood crystal here." She motions toward a machine.',
    options = {
      {
        text = 'Explain you don\'t have a blood crystal',
        dest = 'Story Page 13',
      },
      {
        text = 'Put random junk into the machine',
        dest = 'Story Page 18',
      },
    },
  },

  ['Story Page 13'] = {
    text = '"I see, you\'re one of thooossseee people. Come with me, let\'s get you into the system."\
\
She takes you to another part of the station. You are forced into machine and unable to move. A blood crystal is inserted into your arm. You feel older.\
\
The dock inspector says, "You\'ve been charged 15 years for integration services, as well as 25 days for docking fees." She leaves you.',
    options = {
      {
        text = 'Explore the space port',
        dest = 'Story Page 16',
      },
      {
        text = 'Head back to your ship',
        dest = 'Story Page 14',
      },
    },
  },

  ['Story Page 14'] = {
    text = 'You get back to the ship. A mechanic has already looked at it.\
\
"There\'s a lot of damage on this thing. I can get you back in a functioning ship for about... 40 years."',
    options = {
      {
        text = 'Take the deal and head home',
        dest = 'Story Page 15',
      },
      {
        text = 'Explore the space port',
        dest = 'Story Page 16',
      },
    },
  },

  ['Story Page 15'] = {
    text = 'You make it home safely. Your friends and family wonder why you look like you\'re 80. No one ever believes your crazy story about the Sanguine Serpent Company and their blood crystals.\
\
You die a couple years later from old age.',
    options = {
      {
        text = 'Restart',
        dest = 'Story Page 1',

      },
    },
  },

  ['Story Page 16'] = {
    text = 'The station is full of exotic entertainments and food. It would be nice to spend a few hours relaxing, given you almost died in space.',
    options = {
      {
        text = 'Have fun',
        dest = 'Story Page 17',
      },
      {
        text = 'Head back to your ship',
        dest = 'Story Page 14',
      },
    },
  },

  ['Story Page 17'] = {
    text = 'You spend your time in the station, using your new blood crystal on every indulgence you find. You feel yourself getting older, but your having too much fun to care.\
\
Time flies. You don\'t know how long it\'s been, but you\'re too old and tired to move. You wonder if your entire life was worth a few days of fun.\
\
You die of old age 3 days after arriving at the station.',
    options = {
      {
        text = 'Restart',
        dest = 'Story Page 1',
      },
    },
  },

  ['Story Page 18'] = {
    text = 'A small crystal given to you by your late grandfather seems to work on the machine. Your grandfather passed away before you even started your trips into space.\
\
You wonder how long you\'ll be able to keep using the crystal. A mechanic passes you to check the damage to your ship.',
    options = {
      {
        text = 'Wait for the mechanic',
        dest = 'Story Page 19',
      },
      {
        text = 'Explore the port',
        dest = 'Story Page 21',
      },
    },
  },

  ['Story Page 19'] = {
    text = 'You find the mechanic who inspected your ship.\
\
"There\'s a lot of damage on this thing. I can get you back in a functioning ship for about... 40 years."',
    options = {
      {
        text = 'Accept, using grandfather\'s crystal',
        dest = 'Story Page 20',
      },
      {
        text = 'Explore the station',
        dest = 'Story Page 21',
      },
    },
  },

  ['Story Page 20'] = {
    text = 'You make it back home safely. No one believes your strange story, and you can\'t convince your navigation computer to return. You\'re still young and have a bright future ahead of you.',
    options = {
      {
        text = 'Continue',
        dest = 'Win',
      },
    },
  },

  ['Story Page 21'] = {
    text = 'The station is full of exotic entertainments and food. It would be nice to spend a few hours relaxing, given you almost died in space. Other young people are here, parking of the most expensive attractions.\
\
You wonder how long your crystal will work in a place like this. Every shop keeper is drawn to you, trying to sell you their goods or services. All of it is so enticing...',
    options = {
      {
        text = 'Buy everything',
        dest = 'Story Page 22',
      },
      {
        text = 'Indulge just a little, then return home',
        dest = 'Story Page 20',
      },
      {
        text = 'Head back to your ship',
        dest = 'Story Page 19',
      },
    },
  },

  ['Story Page 22'] = {
    text = 'You spend years enjoying everything the station has to offer. Your grandfather\'s crystal never stops working.\
\
Eventually, you acquire the entire station. No one can figure out the secret to your unending youth. You eventually acquire enough influence to shape the Sanguine Serpent Company to your will.',
    options = {
      {
        text = 'Continue',
        dest = 'Win',
      },
    },
  },

  ['Win'] = {
    text = 'Writing by Johnathan Ackerman\
Programming by Dan Andrus\
\
Made for Ludum Dare 2019 in under 3 hours.\
\
Thank you for playing!',
    options = {
      {
        text = 'Play again',
        dest = 'Story Page 1',
      },
    },
  },
}