# ssh PubKey Auth
The cluster defaults to using password-based authentication tied together with Duo when attempting
to use `ssh` to connect to a machine. The Duo requirement is lifted when directly logging into a
computer (like a desktop workstation on campus); nevertheless, this security requirement can be
cumbersome for our workflows where we are `ssh`ing to and from machines frequently.

This is where [SSH Public Key Authentication](https://serverpilot.io/docs/how-to-use-ssh-public-key-authentication/)
comes in to save the day. The linked website goes through a very basic set up of SSH public key authentication.
After creating the SSH key, make sure to add it to your _local_ ssh agent with `ssh-add` so that you are not
required to unlock the SSH key everytime you wish to use it.
