# Royal Family Solution - Jay Steiner

## Synopsis
Let's go ahead and factor the moving parts and in this exercise and make note of the assumptions.

  + **Lengaburu is an inclusive space**
    + Same-Sex Marriage is culturally accepted and legally viable - so from a code perspective it's no issue to add a new member via Same-Sex Marriage
    + Lengaburians are also inclusive of the non-binary genders, and represent themselves appropriately, legally and from a code perspective
      + So it's no issue to add a Lengaburian with a Gender of Non-Binary or Other
  + **Unfortunately, Due to medical complexity - Procreation is currently only achievable on Lengaburu via Heteronormative means**
    + Unfortunately, even in light of Lengaburu being an inclusive planet, procreation is currently only achievable on Lengaburu via Heteronormative means and for    complicated medical reasons it's not currently possible to perform IVF etc - which is unfortunate but is fully accepted and understood by it's peaceful inhabitants.
      + Simply put - currently only Female Lengaburians who have a compatible Male Spouse can procreate
      + Adoption may also be possible at some point but currently from an administration perspective we only keep track of births, ~~deaths~~ & Marriages
   + **Names on Lengaburu are **NOT** Unique**
      + Lengaburians are not known to be very creative with their child naming conventions, even sometimes simply naming their children after their favourite fictional popular cultural figures such as Harry Potter and more. So very frequently there are many [David Bowies](https://en.wikipedia.org/wiki/David_Bowie) or [Ronald Weasleys](https://harrypotter.fandom.com/wiki/Ronald_Weasley) in one class.
      + They have yet to circumnavigate this using our typical [regnal number](https://en.wikipedia.org/wiki/Regnal_number) format like a real Royal Family would.<br/>
        + Meaning when a `Henry` after another `Henry`, the latter becomes `Henry II`, `Henry III`, `Henry IV` - etc.<br/>
          But doing this would require a great deal of parsing and also ultimately affect - **how we accept parameters into the app**.<br/>
          As Arguments are currently whitespace delimited: `GET_RELATIONSHIP Henry IV, Paternal Uncle`
          <br/>
      + **A method of overcoming this - in theory: would be to add an additional regnal number column to our DB's and perhaps prompt users to choose which `Henry or Harry` they are referring to, which for the purposes of this exercise is out of scope**
  <br/>

## Table of Contents
- [Install](#install)
- [Setting Up](#usage)
- [Usage](#usage)

## Install
This project uses [perl](https://www.perl.org/) and [cpan](https://metacpan.org/). Go check them out if you don't have them locally installed.

Once set-up with your version of perl you will need the following packages, some will be out-of-the-box with your Perl environment package.
for example [strawberry](https://strawberryperl.com/) will contain already some of these.

```sh
$ cpanm Getopt::Long
$ cpanm Pod::Usage
$ cpanm Log::Log4perl
$ cpanm Cwd
$ cpanm File::Spec
$ cpanm Test::More
$ cpan Bundle::DBD::CSV
```

Furthermore you will need a [MySQL](https://www.mysql.com/) Service running correctly on your Localhost
It's best to check you have these all installed correctly first.

## Setting up
With the above completed, and your MySQL Service running on Localhost - we can begin setting up the database in the following order:

```sh
$ cd db
$ MySQL -h <host_name> -u <user> # Typically: -u localhost -u root
$ \. create_rf_db.sql
$ \. populate_members.sql
$ \. populate_relationships.sql
```
> ### Note:
> *I have created a fallback csv database - as there was a lot of mention of not using datastores in both the PP Exercise and in the notes of the task repo.
> So you can go right ahead and test without doing the DB Set-up, or in the event you're too lazy to! Happy Friday! -- Jay Steiner*

## Usage
Once you have all Modules installed and your DB created you can begin testing against the framework

```sh
$ perl run_me.pl --help
$ Usage:
    perl run_me.pl --file_path=text_input.txt
    Options:
       --file_path       A Relative or Absolute file path, including the filehandle
                         Accepts .txt format only

       --help            Shows this guide again

$ perl run_me.pl --file_path=data.txt
```

## Contributors
  <br/>
  <img src="assets/unnamed.gif" width="70px"/>

  [Jay Steiner](https://www.linkedin.com/in/jay-steiner)

