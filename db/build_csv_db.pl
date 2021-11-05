#!/usr/bin/perl -w
use lib '..';
# Author:
# Jay Steiner
# 21/10/2021

# Notes:
# This is the script for populating
use lib '..';

use strict;
use warnings;
use utf8;

# Packages
use DBI;
use DBD::CSV;
use DateTime;

my $dbh = DBI->connect('dbi:CSV:f_dir=misc', '', '', { f_ext => '.csv/r', });

my $dt = DateTime->now( time_zone => 'Australia/Sydney', locale => 'en-AU' );
my $time_added = $dt->format_cldr( 'yyyy-MM-dd HH:mm:ss' );

$dbh->do(
    "CREATE TABLE Members ( " .
    "MemberID INT, " .
    "Name VARCHAR(255), " .
    "Gender VARCHAR(255), " .
    "DirectLineage INT, " .
    "DateAdded VARCHAR(255), )"
);

$dbh->do(
   "CREATE TABLE Relationships ( " .
   "RelationshipID INT, " .
   "Type VARCHAR(255), " .
   "To_Member INT, " .
   "Member INT )"

   
);

 $dbh->do(
     "INSERT INTO Members (MemberID, Name, Gender, DirectLineage, DateAdded )" .
     "VALUES " .
     "( 1, 'Arthur', 'Male', 1, '$time_added' ), "       .
     "( 2, 'Margaret', 'Female', 1, '$time_added' ), "   .
     "( 3, 'Bill', 'Male', 1, '$time_added' ), "         .
     "( 4, 'Flora', 'Female', 0, '$time_added' ), "      .
     "( 5, 'Charlie', 'Male', 1, '$time_added' ), "      .
     "( 6, 'Percy', 'Male', 1, '$time_added' ), "        .
     "( 7, 'Audrey', 'Female', 0, '$time_added' ), "     .
     "( 8, 'Ronald', 'Male', 1, '$time_added' ), "       .
     "( 9, 'Helen', 'Female', 0, '$time_added' ), "      .
     "( 10, 'Ginerva', 'Female', 1, '$time_added' ), "   .
     "( 11, 'Harry', 'Male', 0, '$time_added' ), "       .
     "( 12, 'Victoire', 'Female', 1, '$time_added' ), "  .
     "( 13, 'Ted', 'Male', 0, '$time_added' ), "         .
     "( 14, 'Dominique', 'Female', 1, '$time_added' ), " .
     "( 15, 'Louis', 'Male', 1, '$time_added' ), "       .
     "( 16, 'Molly', 'Female', 1, '$time_added' ), "     .
     "( 17, 'Lucy', 'Female', 1, '$time_added' ), "       .
     "( 18, 'Malfoy', 'Male', 0, '$time_added' ), "      .
     "( 19, 'Rose', 'Female', 1, '$time_added' ), "       .
     "( 20, 'Hugo', 'Male', 1, '$time_added' ), "        .
     "( 21, 'Darcy', 'Female', 0, '$time_added' ), "     .
     "( 22, 'James', 'Male', 1, '$time_added' ), "       .
     "( 23, 'Alice', 'Female', 0, '$time_added' ), "     .
     "( 24, 'Albus', 'Male', 1, '$time_added' ), "       .
     "( 25, 'Lily', 'Female', 1, '$time_added' ), "      .
     "( 26, 'Remus', 'Male', 1, '$time_added' ), "       .
     "( 27, 'Draco', 'Male', 1, '$time_added' ), "       .
     "( 28, 'Aster', 'Female', 1, '$time_added' ), "     .
     "( 29, 'William', 'Male', 1, '$time_added' ), "     .
     "( 30, 'Ron', 'Male', 1, '$time_added' ), "         .
     "( 31, 'Ginny', 'Female', 1, '$time_added' )"
 );

$dbh->do(
    "INSERT INTO Relationships ( RelationshipID, Type, To_Member, Member ) " .
    "VALUES " .
    "( 1, 'Married', 1, 2 ), "      .
    "( 2, 'is_Child', 2, 3 ), "     .
    "( 3, 'is_Child', 2, 5 ), "     .
    "( 4, 'is_Child', 2, 6 ), "     .
    "( 5, 'is_Child', 2, 8 ), "     .
    "( 6, 'is_Child', 2, 10 ), "    .
    "( 7, 'Married', 3, 4 ), "      .
    "( 8, 'is_Child', 4, 12 ), "    .
    "( 9, 'is_Child', 4, 14 ), "    .
    "( 10, 'is_Child', 4, 15 ), "    .
    "( 11, 'Married', 12, 13 ), "    .
    "( 12, 'is_Child', 12, 26 ), "   .
    "( 13, 'Married', 6, 7 ), "      .
    "( 14, 'is_Child', 7, 16 ), "    .
    "( 15, 'is_Child', 7, 17 ), "   .
    "( 16, 'Married', 8, 9 ), "     .
    "( 17, 'is_Child', 9, 19 ), "   .
    "( 18, 'is_Child', 9, 20 ), "   .
    "( 19, 'Married', 19, 18 ), "   .
    "( 20, 'is_Child', 9, 27 ), "   .
    "( 21, 'is_Child', 9, 28 ), "   .
    "( 22, 'Married', 10, 11 ), "   .
    "( 23, 'is_Child', 10, 22 ), "  .
    "( 24, 'is_Child', 10, 24 ), "  .
    "( 25, 'is_Child', 10, 25 ), "  .
    "( 26, 'Married', 22, 21 ), "   .
    "( 27, 'is_Child', 21, 29 ), "  .
    "( 28, 'Married', 24, 23 ), "   .
    "( 29, 'is_Child', 23, 30 ), "  .
    "( 30, 'is_Child', 23, 31 )"
);