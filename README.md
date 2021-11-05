# Royal Family Solution - Jay Steiner

## Synopsis
----


## Table of Contents
----
- [Install](#install)
- [Setting Up](#usage)
- [Usage](#usage)

## Install
----

This project uses [perl](https://www.perl.org/) and [cpan](https://metacpan.org/). Go check them out if you don't have them locally installed.

Once set-up with your version of perl you will need the following packages, some will be out-of-thebox with your Perl environment package.
for example [strawberry](https://strawberryperl.com/)

```sh
$ cpanm Getopt::Long;
$ cpanm Pod::Usage;
$ cpanm Log::Log4perl;
$ cpanm Cwd;
$ cpanm File::Spec;
```

Furthermore you will need a [MySQL](https://www.mysql.com/) Servive running correctly on your Localhost
It's best to check you have these all installed correctly first.

## Setting up
----

With the above completed, and your MySQL Service running on Localhost - we can begin setting up the database in the following order:

```sh
$ cd db
$ MySQL -h <host_name> -u <user> # Typically: -u localhost -u root
$ \. create_rf_db.sql
$ \. populate_members.sql
$ \. populate_relationships.sql
```
> ### Note:
> I have created a fallback csv database - as there was a lot of mention of not using datastores in both the PP Exercise and in the notes of the task repo.
> So you can go right ahead and test without doing the DB Set-up, or in the event you're too lazy to! -- Happy Friday!

## Usage
----

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


