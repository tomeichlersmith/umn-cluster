# New Cluster User
We always forget how to get new users started because we only ever have to do it once.

This page has manual notes on the process as of Fall 2022.
The time is important because the start-up process may change if the cluster backend changes.

### 0. Get a UMN Internet Account
For UMN students (grad or undergrad), this is automatic. For summer students, this may take a few days of paperwork.

**Test**: You have a UMN email and/or a UMN student ID.

### 1. Activate SPA Computing Account
Email `csehelp@umn.edu` and ask them to activiate your SPA computing account.
Provide the following information in your email:
- Which professor is your advisor (they may want to double-check with that person if they can't find your name in their system)
- That you would like a SPA computing account and have access to the "SPA OSG cluster" (that's their name for this cluster).
  I belive this second substep amounts to adding you to the `SPA-hepcms` Active Directory group.

**Test**: You can SSH to the general-access node with your UMN credentials.
```
ssh <username>@spa-ssh-01.spa.umn.edu
```
_Note_: New users may be unfamiliar with SSH and so should be assisted in the test.

### 2. Access SPA OSG Cluster
In some instances in the past, CSE IT has not added the new user to the necessary computing groups to access the cluster.
This step merely consists of emailing `csehelp@umn.edu` again and re-asking for access to the cluster.

**Test**: You can SSH to a cluster node with your UMN credentials.
```
ssh <username>@spa-osg-login.spa.umn.edu
```
_Note_: If you are off campus, you will need to connect to the general-access node first, and then SSH again.

**Alternative Test**: You can log-in to one of the interactive desktops in the HEP-CMS offices.

### 3. Permissions on the SPA OSG Cluster
This is helpful for double checking that you have the correct access when connecting to the cluster.

**Test 1**: Make sure you can view the contents of our group's directory.
Type the following into the shell and press enter _after_ logging in.
```
ls /local/cms/user
```
You should see a listing of files in this directory. If you see `Permission denied` or similar,
then you should contact CSE IT.

**Test 2**: Make sure you can modify the contents of our group's directory.
While still logged in to the cluster run the following command.
```
mkdir /local/cms/user/${USER}
```
This command will not printout anything if it was successful. If you see `Permission denied`,
then contact CSE IT. If you see `File exists`, then you (or someone else) already created this
directory and you should ask around the office for help if you don't remember doing it yourself.

## Quality of Life Improvements
There are a few things you can do to make the SSH connection process easier.
I encourage you to google around and read articles about SSH and how to configure it
for your personal setup, but I have summarized some helpful and common information in
the Misc section.
- [PubKey Auth](misc/ssh_pubkey_auth.md)
- [Config](misc/ssh_config.md)

