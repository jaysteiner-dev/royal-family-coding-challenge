#!/usr/bin/perl -w

# Author:
# Jay Steiner
# 21/10/2021

use lib '.';
package RoyalFamily::Member;
use RoyalFamily::DBI;

use strict;
use warnings;
use utf8;

# Libraries
use Log::Log4perl;

sub new {
    my $class = shift;
    my %args = @_;

    my $log = Log::Log4perl->get_logger("RF_Member");

    my $self = bless {
        rf_dbi => RoyalFamily::DBI->new() || $log->logdie("Can't instantiate new to RoyalFamily::DBI Object"),
        log => Log::Log4perl->get_logger("RF_Member"),
    }, $class;

    if ( $args{MemberID} || $args{Name} ) {
        $self->_get_member( %args );
    }

    if ( !$self->{MemberID} ) {
        return "PERSON_NOT_FOUND";
    }

    return $self;
}

sub _get_member {
    my ( $self, %args ) = @_;

    if ( scalar (keys %args) != 1 ) {
        $self->{log}->info("_get_member accepts only one parameter per fetch - MemberID or Name");
    }

    # Grab identififier - MemberID or Name
    my ( $type, $val ) = %args;
    my $member_data = $self->{rf_dbi}->fetch_member($type, $val);
    if ( $member_data ) {
        foreach my $column_name (keys %{ $member_data }) {
            $self->{$column_name} = $member_data->{$column_name};
        }
    }
}

sub get_relationship {
    my ( $self, $relationship ) = @_;

    my %dispatcher = (
        'Siblings'       => $self->can('_find_siblings'),
        'Son'            => $self->can('_find_son'),
        'Daughter'       => $self->can('_find_daughter'),
        'Maternal-Uncle' => $self->can('_find_matpat_relation'),
        'Paternal-Uncle' => $self->can('_find_matpat_relation'),
        'Paternal-Aunt'  => $self->can('_find_matpat_relation'),
        'Maternal-Aunt'  => $self->can('_find_matpat_relation'),
        'Sister-In-Law'  => $self->can('_find_in_law_relation'),
        'Brother-In-Law' => $self->can('_find_in_law_relation'),
    );

    if ( !$dispatcher{$relationship} ) {
        # Relationship method not supported - Please try another relationship type
        return "RELATIONSHIP_NOT_SUPPORTED";
    }
    
    # Perl nuance
    my $subref = $dispatcher{$relationship};
    my @relations = @{ $self->$subref( relation_type => $relationship ) };
    
    return \@relations || "NONE";
}

sub add_child {
    my ( $self, %args ) = @_;

    my $args_count = scalar ( keys %args );
    if ( !$args_count || $args_count != 2 ) {
        $self->{log}->info("add_child accepts only two parameters: Name => 'Someone', Gender => 'Non-Binary'");
        return "CHILD_ADDITION_FAILED";
    }

    # Check RoyalFamily::Member is Female
    if ( $self->{Gender} ne 'Female' ) {
        $self->{log}->info("Male Member is not capable of bearing children");
        return "CHILD_ADDITION_FAILED";
    }

    # Check for compatible hetero-normative spouse
    my $spouse = $self->_find_spouse();

    # Fail if no compatible spouse present
    if ( !$spouse ) {
        $self->{log}->info("Heteronormative procreation not possible at this time - please add a compatible spouse or explore your options with a certified health professional");
        return "CHILD_ADDITION_FAILED";
    }

    # Create Child + add relationship to the Mother to DB39
    my ($child_id, $new_relationship_id) = $self->{rf_dbi}->add_child( $self->{MemberID}, $args{Name}, $args{Gender});
    my $child_obj = RoyalFamily::Member->new(MemberID => $child_id );

    # Return the Child Object
    return $child_obj || "CHILD_ADDITION_FAILED";
}

sub add_member_via_marriage {
    my ( $self, %args ) = @_;

    my $args_count = scalar ( keys %args );
    if ( !$args_count || $args_count != 2 ) {
        $self->{log}->info("add_member_via_marriage accepts only two parameters: Name => 'Somebody', Gender => 'Non-Binary'");
        return "MEMBER_ADDITION_VIA_MARRIAGE_FAILED";
    }

    # Check that RoyalFamily::Member does not have a spouse already
    my $spouse = $self->_find_spouse();
    if ( $spouse ) {
        $self->{log}->info("The Royal Family does not permit multiple spouses");
        return "MEMBER_ADDITION_VIA_MARRIAGE_FAILED";
    }

    # Lets support Same-Sex Marriage!
    # Don't check for Gender! Love is Love!
    my ( $spouse_id, $relationship_id ) = $self->{rf_dbi}->add_member_via_marriage( $self->{MemberID}, $args{Name}, $args{Gender} );
    my $spouse_obj = RoyalFamily::Member->new( MemberID => $spouse_id );
    
    return $spouse_obj;
}

sub _find_mother {
    my ( $self ) = @_;

    # If Royal Family Member has married in, error out as we don't hold external family data
    if ( !exists $self->{DirectLineage} ) {
        $self->{log}->info("RoyalFamily database does not hold information pertaining to the family members of those married into the Royal Family");
        return '';
    }

    my $mother_obj;
    # Fetch MotherID from relationships table, using Child MemberID as the 'belonging to' ID
    my @relationships = @{ $self->{rf_dbi}->get_relationships('is_Child', 'Member', $self->{MemberID}) };

    if ( @relationships ) {
        # Only one mother, so index is always Zero.
        my %relationship = %{ $relationships[0] };
        # and 'To_Member' FK as Mother's MemberID - as the child always belongs to the mother.
        $mother_obj = RoyalFamily::Member->new( MemberID => $relationship{To_Member});
    }

    return $mother_obj || '';
}

sub _find_spouse {
    my ( $self ) = @_;

    my $spouse_obj;
    my @relationship_ids;
    my $member_order;

    # If Member is DL, then we want the member 'of' relationship
    # So to_member will be the RF DL MemberID
    $member_order = $self->{DirectLineage} ? 'To_Member' : 'Member';
    my $member_of = ( $member_order eq 'To_Member' ) ? 'Member' : 'To_Member';

    # Fetch Spouse
    @relationship_ids = @{ $self->{rf_dbi}->get_relationships('Married', $member_order, $self->{MemberID}) };

    # Grab Spouse from Array[0]
    if ( @relationship_ids ) {
        # Only one spouse permitted, so index is always Zero.
        my %relationship = %{ $relationship_ids[0] };
        # Variable member order depending on DL or not
        $spouse_obj = RoyalFamily::Member->new(MemberID => $relationship{$member_of});
    }

    return $spouse_obj || '';
}

sub _find_daughter {
    my ( $self ) = @_;
    return $self->_find_children( Gender => "Female" );
}

sub _find_son {
    my ( $self ) = @_;
    return $self->_find_children( Gender => "Male" );
}

sub _find_children {
    my ( $self, %args ) = @_;
    
    my $spouse;
    my $member_id = $self->{MemberID};
    # Get appropriate child-bearing spouse if needed
    if ( $self->{Gender} eq 'Male' ) {
        $spouse = $self->_find_spouse();
        if ( $spouse ) {
            $member_id = $spouse->{MemberID};
        }
    }

    # Grab Child ID's from Relationships table
    my @children = @{ $self->{rf_dbi}->get_relationships("is_Child", "To_Member", $member_id ) };

    my @children_obj;
    # Loop through ID's and instantiate RoyalFamily::Member
    if ( @children ) {
        foreach my $child ( @children ) {
            my $child_obj = RoyalFamily::Member->new( MemberID => $child->{Member} );
            # Skip if not specified gender
            next if ( $args{Gender} && ( $child_obj->{Gender} ne $args{Gender} ) );
            # Push In!
            push @children_obj, $child_obj;
        }
    }

    return \@children_obj;
}

sub _find_siblings {
    my ( $self, %args ) = @_;

    # Get Mother Obj
    my @aggregated_siblings;
    my $mother_obj = $self->_find_mother();

    if ( $mother_obj ) {
        # Get Mothers Children
        my $gender = $args{Gender} || '';
        my @siblings = @{ $mother_obj->_find_children( Gender => $gender ) };
        # Drop current member from Mother's children - as you can't be a sibling to yourself
        if ( @siblings ) {
            @aggregated_siblings = grep { $_->{MemberID} != $self->{MemberID} } @siblings;
        }
    }
    
    return \@aggregated_siblings;
}

sub _find_matpat_relation {
    my ( $self, %args ) = @_;

    # Check if Member is DL and return no relations, as we don't hold that data
    if ( !$self->{DirectLineage} ) {
        $self->{log}->info("RoyalFamily database does not hold information pertaining to the family members of those married into the Royal Family");
        return;
    }
    
    my %gender_mapping = (
        'Maternal-Aunt'  => "Female",
        'Maternal-Uncle' => "Male",
        'Paternal-Aunt'  => "Female",
        'Paternal-Uncle' => "Male",
    );

    my @aunts;
    my @uncles;
    my @aggregated_relations;

    # Get Mother;
    my $mother_obj = $self->_find_mother();
    if ( $mother_obj ) {
        # If finding paternal relations -> get mothers spouse -> get spouses siblings
        # Else just get mothers siblings
        if ( $args{relation_type} =~ /Maternal/ && $mother_obj->{DirectLineage} ) {
            # Maternal
            @aunts  = @{ $mother_obj->_find_siblings( Gender => 'Female') };
            @uncles = @{ $mother_obj->_find_siblings( Gender => 'Male')   };
        } else {
            # Paternal
            my $father_obj = $mother_obj->_find_spouse();
            if ( $father_obj && $father_obj->{DirectLineage} ) {
                @aunts  = @{ $father_obj->_find_siblings( Gender => 'Female') };
                @uncles = @{ $father_obj->_find_siblings( Gender => 'Male')  };
            }
        }

        
        if ( @aunts || @uncles ) {
            # Push in aunts if relation gender is Female - else push in uncles. 
            $gender_mapping{$args{relation_type}} eq "Female" ? ( push @aggregated_relations, @aunts ) : ( push @aggregated_relations, @uncles );

            # For Finding Uncles - loop Aunt's spouses + push in if male 
            if ( $gender_mapping{$args{relation_type}} eq 'Male' ) {
                foreach my $aunt (@aunts) {
                    my $aunt_spouse = $aunt->_find_spouse();

                    # Check in-case of a Same-Sex Marriage
                    if ( $aunt_spouse ) {
                        if ( $aunt_spouse->{Gender} eq 'Male' ) {
                            push @aggregated_relations, $aunt_spouse;
                        }
                    }
                }

            # For Finding Aunts - loop Uncle's spouses + push in if female
            } else {
                foreach my $uncle (@uncles) {
                    my $uncle_spouse = $uncle->_find_spouse();

                    # Check in-case of a Same-Sex Marriage
                    if ( $uncle_spouse ) {
                        if ( $uncle_spouse->{Gender} eq 'Female' ) {
                            push @aggregated_relations, $uncle_spouse;
                        }
                    }
                }
            }
        }
    }

    return \@aggregated_relations;
}    

sub _find_in_law_relation {
    my ( $self, %args ) = @_;

    my %gender_mapping = (
        'Sister-In-Law'  => "Female",
        'Brother-In-Law' => "Male",
    );

    my $mother;
    my @siblings;
    if ( !$self->{DirectLineage} ) {
        # Get spouses siblings for non-DL Family Members
        my $spouse = $self->_find_spouse();
        @siblings = @{ $spouse->_find_siblings() };
    } else {
        # For lineage members grab siblings directly
        @siblings = @{ $self->_find_siblings() };
    }

    my @aggregated_relations;
    if ( @siblings ) {
        foreach my $sibling ( @siblings ) {
            if ( !$self->{DirectLineage} && $sibling->{Gender} eq $gender_mapping{$args{relation_type}} ) {
                # If member has married in - every 'sibling' is an In-Law
                # So push in here according to gender specification
                push @aggregated_relations, $sibling;
            }

            # Find that 'in-laws' spouse also
            my $sibling_spouse = $sibling->_find_spouse();
            if ( $sibling_spouse ) {
                # Push in 'sibling' spouses according to gender
                if ( $sibling_spouse->{Gender} eq $gender_mapping{$args{relation_type}} ) {
                    push @aggregated_relations, $sibling_spouse;
                }
            }
        }
    }

    return \@aggregated_relations;
}

# Began to implement, but due to the way data is input to the script that runs against this
# We can't develop further as the accepted format is whitespace delimited
# eg. COMMAND ParentName ChildName ChildGender
# So unless we implement a massive parsing app, we can't go ahead with regnal numbers 
sub increment_regnal_number {
    my ( $self, %args ) = @_;

    my $name = lc($args{Name});
    my @names = $self->{rf_dbi}->get_names();
    my @is_present = grep { lc($_) =~ /^$name$/ } @names;
    my @aggregated_similar_names = grep { lc($_) =~ /\b$name\b[\s*]/ } @names;
    my $next_of_name_no = scalar @aggregated_similar_names + scalar @is_present;
    $next_of_name_no++;

    my $roman_regnal_no = uc( roman($next_of_name_no) );
    my $new_name = $args{Name} . " " . $roman_regnal_no;
    return $new_name;
}

1;