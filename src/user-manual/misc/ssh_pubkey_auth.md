# ssh PubKey Auth
The cluster defaults to using password-based authentication tied together with Duo when attempting
to use `ssh` to connect to a machine. The Duo requirement is lifted when directly logging into a
computer (like a desktop workstation on campus); nevertheless, this security requirement can be
cumbersome for our workflows where we are `ssh`ing to and from machines frequently.

This is where [SSH Public Key Authentication](https://serverpilot.io/docs/how-to-use-ssh-public-key-authentication/)
comes in to save the day. The linked website goes through a very basic set up of SSH public key authentication.
After creating the SSH key, make sure to add it to your _local_ ssh agent with `ssh-add` so that you are not
required to unlock the SSH key everytime you wish to use it.

#### An Extended Aside About SSH Key Passwords
SSH keys can be password-locked to prevent anyone who gains access to your computer from using the SSH key to pretend to be you.
Password-locking is achieved by providing a non-empty password when generating the key.
Locking the SSH key _without any additional steps_, then means you have to unlock it everytime you wish to use it.
This still avoids the Duo step for us, but typing a password each time an SSH connection needs to be establish can become tedious.
This tedium is not new and so SSH Agents were born. These allow you to unlock an SSH key once and they stay unlocked until
the computer itself is turned off. This allows you to safely lock your SSH keys while also only having to type in a password
once-in-a-while. SSH Agents are complicated and so I do not try to explain how to set them up here. My best advice is to 
search online for "SSH Agent _your operating system_" to find some advice from more knowledgeable people.

All this being said, you can avoid this rigamarole by creating a password-less SSH key.
I am obligated to say that **this is not recommended** due to the security risk.
