#!/usr/bin/perl -w

# Notes:
# This is a test Library for RoyalFamily

use lib '..';
use RoyalFamily::Member;
use RoyalFamily::DBI;

use strict;
use warnings;

use Data::Dumper;

# Packages
use Test::More;
plan tests => 17;


# Object instantion
# 1 -- Effectively tests: new + _get_member
subtest 'Success -- RoyalFamily::Member->new( Name => Arthur )' => sub {
    plan tests => 4;
    my $rf_member = RoyalFamily::Member->new( Name => 'Arthur' );

    # Check Object is defined and of type RoyalFamily::Member
    ok ($rf_member->isa('RoyalFamily::Member'), "Object is a RoyalFamily::Member");

    # Check Object Values as expected
    ok ( $rf_member->{MemberID} == 1, "MemberID => 1 -- as Expected");
    ok ( $rf_member->{Name} eq 'Arthur', "Name => 'Arthur' -- as Expected" );
    ok ( $rf_member->{Gender} eq 'Male', "Gender => 'Male' -- as Expected" );
};
print "\n";

# 2 -- Effectively tests: new + _get_member
subtest 'Success -- RoyalFamily::Member->new( MemberID => 1 )' => sub {
    plan tests => 4;
    my $rf_member = RoyalFamily::Member->new( MemberID => 1 );

    # Check Object is defined and of type RoyalFamily::Member
    ok ($rf_member->isa('RoyalFamily::Member'), "Object is a RoyalFamily::Member");

    # Check Object Values as expected
    ok ( $rf_member->{MemberID} == 1, "MemberID => 1 -- as Expected");
    ok ( $rf_member->{Name} eq 'Arthur', "Name => 'Arthur' -- as Expected" );
    ok ( $rf_member->{Gender} eq 'Male', "Gender => 'Male' -- as Expected" );
};
print "\n";

# 3 -- Effectively tests: new + _get_member
subtest 'Fail Correctly -- RoyalFamily::Member->new(), No Params' => sub {
    plan tests => 1;
    my $rf_member = RoyalFamily::Member->new();
    ok ($rf_member eq "PERSON_NOT_FOUND", "PERSON_NOT_FOUND -- as Expected");
};
print "\n";

# 4 -- Effectively tests: new + _get_member
subtest 'Fail Correctly -- RoyalFamily::Member->new(), Incorrect MemberID' => sub {
    plan tests => 1;
    my $rf_member = RoyalFamily::Member->new( MemberID => 5000 );
    ok ($rf_member eq "PERSON_NOT_FOUND", "PERSON_NOT_FOUND -- as Expected");
};
print "\n";

# 5 -- Effectively tests: new + _get_member
subtest 'Fail Correctly -- RoyalFamily::Member->new(), Incorrect Name' => sub {
    plan tests => 1;
    my $rf_member = RoyalFamily::Member->new( Name => 'Snape' );
    ok ($rf_member eq "PERSON_NOT_FOUND", "PERSON_NOT_FOUND -- as Expected");
};
print "\n";

# 6 -- Effectively tests: get_relationship + _find_mat_pat, _find_mother, _find_siblings, _find_children
subtest "Success -- RoyalFamily::Member->get_relationship('Paternal-Uncle')" => sub {
    plan tests => 12;
    # Use Victoire
    my $rf_member = RoyalFamily::Member->new( MemberID => 12 );
    my @relationships = @{ $rf_member->get_relationship('Paternal-Uncle') };

    my $member_index = 0;
    my @expected_members = (
        {
            Name => 'Charlie',
            MemberID => 5,
            Gender => 'Male',
        },
        {
            Name => 'Percy',
            MemberID => 6,
            Gender => 'Male',
        },
        {
            Name => 'Ronald',
            MemberID => 8,
            Gender => 'Male',
        },
        {
            Name => 'Harry',
            MemberID => 11,
            Gender => 'Male',
        },
    );

    foreach my $member ( @relationships ) {
        print "Paternal-Uncle: " . $member->{Name} . "\n"; 
        ok ($member->{MemberID} == $expected_members[$member_index]->{MemberID}, "MemberID => " . $member->{MemberID} . " -- as Expected");
        ok ($member->{Name} eq $expected_members[$member_index]->{Name}, "Name => " . $member->{Name} . " -- as Expected");
        ok ($member->{Gender} eq $expected_members[$member_index]->{Gender}, "Gender => " . $member->{Gender} . " -- as Expected");
        print "\n";
        $member_index++;
    }
};
print "\n";

# 7 -- Effectively tests: get_relationship + _find_mat_pat, _find_mother, _find_siblings, _find_children
subtest "Fail Correctly -- RoyalFamily::Member->get_relationship('Paternal-Uncle'), None" => sub {
    plan tests => 1;
    # Use Bill
    my $rf_member = RoyalFamily::Member->new( MemberID => 3 );
    my @relationships = @{ $rf_member->get_relationship('Paternal-Uncle') };
    ok (!@relationships, "Empty Array -- as Expected");
};
print "\n";

# 8 -- Effectively tests: _find_siblings + _find_mother, _find_children    
subtest "Success -- RoyalFamily::Member->get_relationship(Siblings)" => sub {
    plan tests => 6;
    # Use Victoire
    my $rf_member = RoyalFamily::Member->new( MemberID => 12 );
    my @relationships = @{ $rf_member->get_relationship('Siblings') };

    my $member_index = 0;
    my @expected_members = (
        {
            Name => 'Dominique',
            MemberID => 14,
            Gender => 'Female'
        },
        {
            Name => 'Louis',
            MemberID => 15,
            Gender => 'Male'
        }
    );
 
    foreach my $member ( @relationships ) {
        print "Sibling: " . $member->{Name} . "\n";
        ok ($member->{MemberID} == $expected_members[$member_index]->{MemberID}, "MemberID => " . $member->{MemberID} . " -- as Expected");
        ok ($member->{Name} eq $expected_members[$member_index]->{Name}, "Name => " . $member->{Name} . " -- as Expected");
        ok ($member->{Gender} eq $expected_members[$member_index]->{Gender}, "Gender => " . $member->{Gender} . " -- as Expected");
        print "\n";
        $member_index++;
    }
};
print "\n";

# 9 -- Effectively tests: get_relationship + _find_mat_pat, _find_mother, _find_siblings, _find_children
subtest "Fail Correctly -- RoyalFamily::Member->get_relationship('Siblings'), None" => sub {
    plan tests => 1;
    # Use Remus - No Siblings
    my $rf_member = RoyalFamily::Member->new( MemberID => 26 );
    my @relationships = @{ $rf_member->get_relationship('Siblings') };
    ok (!@relationships, "Empty Array -- as Expected");
};
print "\n";

# 10 -- Effectively tests: _find_in_law_relation + _find_siblings, _find_spouse
subtest "Success -- RoyalFamily::Member->get_relationship('Sister-In-Law')" => sub {
     plan tests => 6;
     # Use Bill
     my $rf_member = RoyalFamily::Member->new( MemberID => 3 );
     my @relationships = @{ $rf_member->get_relationship('Sister-In-Law') };
 
     my $member_index = 0;
     my @expected_members = (
         {
             Name => 'Audrey',
             MemberID => 7,
             Gender => 'Female',
         },
         {
             Name => 'Helen',
             MemberID => 9,
             Gender => 'Female',
         },
     );
 
     foreach my $member ( @relationships ) {
         print "Sister-In-Law: " . $member->{Name} . "\n";
         ok ($member->{MemberID} == $expected_members[$member_index]->{MemberID}, "MemberID => " . $member->{MemberID} . " -- as Expected");
         ok ($member->{Name} eq $expected_members[$member_index]->{Name}, "Name => " . $member->{Name} . " -- as Expected");
         ok ($member->{Gender} eq $expected_members[$member_index]->{Gender}, "Gender => " . $member->{Gender} . " -- as Expected");
         print "\n";
         $member_index++;
     }
};
print "\n";

# 11 -- Effectively tests: get_relationship + _find_mat_pat, _find_mother, _find_siblings, _find_children
subtest "Fail Correctly -- RoyalFamily::Member->get_relationship('Sister-In-Law'), None" => sub {
    plan tests => 1;
    # Use Remus
    my $rf_member = RoyalFamily::Member->new( MemberID => 26 );
    my @relationships = @{ $rf_member->get_relationship('Sister-In-Law')};
    ok (!@relationships, "Empty Array -- as Expected");
};
print "\n";

# 12 -- Effectively tests: _find_in_law_relation + _find_siblings, _find_spouse
subtest "Success -- RoyalFamily::Member->get_relationship('Son')" => sub {
     plan tests => 6;
     # Use Harry
     my $rf_member = RoyalFamily::Member->new( MemberID => 11 );
     my @relationships = @{ $rf_member->get_relationship('Son') };
 
     my $member_index = 0;
     my @expected_members = (
         {
             Name => 'James',
             MemberID => 22,
             Gender => 'Male',
         },
         {
             Name => 'Albus',
             MemberID => 24,
             Gender => 'Male',
         },
     );

     foreach my $member ( @relationships ) {
         print "Son: " . $member->{Name} . "\n";
         ok ($member->{MemberID} == $expected_members[$member_index]->{MemberID}, "MemberID => " . $member->{MemberID} . " -- as Expected");
         ok ($member->{Name} eq $expected_members[$member_index]->{Name}, "Name => " . $member->{Name} . " -- as Expected");
         ok ($member->{Gender} eq $expected_members[$member_index]->{Gender}, "Gender => " . $member->{Gender} . " -- as Expected");
         print "\n";
         $member_index++;
     }
};
print "\n";

# 13 -- Effectively tests: get_relationship + _find_mat_pat, _find_mother, _find_siblings, _find_children
subtest "Fail Correctly -- RoyalFamily::Member->get_relationship('Son'), None" => sub {
    plan tests => 1;
    # Use Remus
    my $rf_member = RoyalFamily::Member->new( MemberID => 26 );
    my @relationships = @{ $rf_member->get_relationship('Son') };
    ok (!@relationships, "Empty Array -- as Expected");
};
print "\n";

# 14 -- Effectively tests: _find_spouse
subtest "Success -- RoyalFamily::Member->add_child( Name => 'Hermione', Gender => 'Female' )" => sub {
    plan tests => 2;
    # Use Audrey
    my $rf_member = RoyalFamily::Member->new( MemberID => 7 );
    my $child = $rf_member->add_child( Name => 'Hermione', Gender => 'Female' );

    # MemberID will vary unless DB Mocked, which is out of scope
    # just check for Name and Gender
    ok ($child->{Name} eq 'Hermione', "Child Name => " . $child->{Name} . "-- as Expected");
    ok ($child->{Gender} eq 'Female', "Gender => " . $child->{Gender} . " -- as Expected");
    clean_db( $child );
};
print "\n";

# 15 -- Effectively tests: _find_spouse
subtest "Fail Correctly -- RoyalFamily::Member->add_child( Name => 'Hermione', Gender => 'Female' )" => sub {
    plan tests => 4;
    # Use Dominique, Unmarried
    my $unmarried_member = RoyalFamily::Member->new( MemberID => 14 );
    # Use Percy, Male
    my $male_member = RoyalFamily::Member->new( MemberID => 6 );
    # Use Victoire
    my $compatible_member = RoyalFamily::Member->new( MemberID => 12 );

    my %new_child = (
        Name => 'Hermione',
        Gender => 'Female'
    );
    
    my $expected_return = 'CHILD_ADDITION_FAILED';
    ok ($unmarried_member->add_child( %new_child ) eq $expected_return, "Member without compatible spouse -- As Expected");
    ok ($male_member->add_child( %new_child ) eq $expected_return, "Member is Male, Procreation not possible at this time -- As Expected");
    ok ($compatible_member->add_child( Name => 'Hermione') eq $expected_return, "Incorrect Params - Too Few -- As Expected");
    ok ($compatible_member->add_child( Name => 'Hermione', Full_Name => 'Django', Gender => 'Female') eq $expected_return, "Incorrect Params - Too Many -- As Expected");
};
print "\n";

# 16 -- Effectively tests: add_member_via_marriage, _find_spouse
subtest "Success -- RoyalFamily::Member->add_member_via_marriage(Name => 'Ben-Kenobi', Gender => 'Male')" => sub {
    plan tests => 2;

    # Use Molly - Unmarried
    my $unmarried_member = RoyalFamily::Member->new( MemberID => 16 );
    my $new_member = $unmarried_member->add_member_via_marriage( Name => "Ben-Kenobi", Gender => "Male" );
    
    # -- Test add_child to Unmarried
    print "Marriage Successful \n";
    ok ($new_member->{Name} eq 'Ben-Kenobi', "Name => " . $new_member->{Name});
    ok ($new_member->{Gender} eq 'Male', "Gender => " . $new_member->{Gender});
    clean_db( $new_member );
};
print "\n";

# 17 -- Effectively tests: _find_spouse
subtest "Fail Correctly -- RoyalFamily::Member->add_member_via_marriage('Ben-Kenobi', 'Male')" => sub {
    plan tests => 3;
    # Use Molly - Unmarried
    my $unmarried_member = RoyalFamily::Member->new( MemberID => 16 );
    # Use Bill - Married
    my $married_member = RoyalFamily::Member->new( MemberID => 3 );
    my $fail_too_few = $unmarried_member->add_member_via_marriage( Name => "Ben-Kenobi" );
    my $fail_too_many = $unmarried_member->add_member_via_marriage( Name => "Ben-Kenobi", Title => "Obi-Wan", Gender => "Male" );
    my $has_spouse = $married_member->add_member_via_marriage( Name => "Ben-Kenobi", Gender => "Male" );
    
    my $expected_return = 'MEMBER_ADDITION_VIA_MARRIAGE_FAILED';
    ok ($fail_too_few eq $expected_return, "Incorrect Params - Too Few -- As Expected");
    ok ($fail_too_many eq $expected_return, "Incorrect Params - Too Many -- As Expected");
    ok ($has_spouse eq $expected_return, "Has Spouse Already -- As Expected");
};
print "\n";

done_testing();

# NOTE:
# STOP! This is not good practice, in future Mock DB
sub clean_db {
    my ( $member ) = @_;

    my $rf_dbi = RoyalFamily::DBI->new();
    # Drop Relationship
    my $sth = $rf_dbi->{dbh}->prepare("DELETE FROM Relationships WHERE Member = " . $member->{MemberID});
    $sth->execute();

    # Drop Member
    $sth = $rf_dbi->{dbh}->prepare("DELETE FROM Members WHERE MemberID = " . $member->{MemberID});
    $sth->execute();
}