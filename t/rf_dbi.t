#!/usr/bin/perl -w

# Notes:
# This is a test library for RoyalFamily::DBI

use lib '..';
use RoyalFamily::DBI;

use strict;
use warnings;

use Data::Dumper;

# Packages
use Test::More;

# -------- RoyalFamily::DBI ---------
# Object instantion

# -- Test new DBI - Object
# -- Test fetch_member - Success
# -- Test fetch_member - No $val
# -- Test fetch_member - No $type
# -- Test fetch_member - No $self

# -- Test get_relationships - Success
# -- Test get_relationships - No $member_id
# -- Test get_relationships - No $member_ord
# -- Test get_relationships - No $type
# -- Test get_relationships - No $self

# -- Test add_relationship - Success
# -- Test add_relationship - No $member
# -- Test add_relationship - No $to_member
# -- Test add_relationship - No $type
# -- Test add_relationship - No $self

# -- Test add_child - Success
# -- Test add_child - No $child_gender
# -- Test add_child - No $child_name
# -- Test add_child - No $mother_id
# -- Test add_child - No $self

# -- Test add_member_via_marriage - Success
# -- Test add_member_via_marriage - No $spouse_name
# -- Test add_member_via_marriage - No $spouse_gender
# -- Test add_member_via_marriage - No $to_member_id
# -- Test add_member_via_marriage - No $self

# -- Test _modify_insert_for_csv - add_member - Success
# -- Test _modify_insert_for_csv - add_relationship - Success
# -- Test _modify_insert_for_csv - No $type
# -- Test _modify_insert_for_csv - No $self