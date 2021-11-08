#!/usr/bin/perl -w

# Author:
# Jay Steiner
# 21/10/2021

use lib '..';
package RoyalFamily::DBI;

use strict;
use warnings;
use utf8;

# Libraries
use DBI;
use DBD::CSV;
use Log::Log4perl;
use DateTime;
use Cwd;
use File::Spec;

# MySQL database configuration
my $DSN = "DBI:mysql:royalfamily";
my $USERNAME = "root";
my $PASSWORD = '';

# MySQL warning config
my %attr = ( 
    PrintError => 0, # turn off error reporting via warn()
    RaiseError => 1,  # turn on error reporting via die()
);

sub new {
    my $class = shift;

    my $log = Log::Log4perl->get_logger("RF_Member");
    my $dbh;
    my $db_type;

    eval {
        # Connect to MySQL database
        $db_type = 'MySQL';
        $dbh = DBI->connect($DSN, $USERNAME, $PASSWORD, \%attr) or die "Can't connect to $DSN: $DBI::errstr\n\n";
    };
    if ( $@ ) {
        # Log out the connection error
        $log->debug("Failed to Connect to MySQL DB - With an Error of:\n $@" ); #$DBI::errstr");
    }

    # Initiate Fallback - Check if DBI Object connected: If not, then fallback to CSV DB
    if ( !$dbh ) {
        eval {
            # Connect to CSV DB
            $db_type = 'CSV';
            $log->info("MySQL Database Connection Failed - Falling Back to CSV DB\n");
            # Bit Hacky but just has to be done
            my $f_dir = get_f_dir();
            $dbh = DBI->connect('dbi:CSV:', '', '', { f_dir => $f_dir, f_ext => '.csv/r', RaiseError => 1, } ) or die "Can't connect to CSV: $DBI::errstr";
            
        };

        # DBD::CSV behaves a little different to DBI - So check if the object can ping connection
        if ( !$dbh->ping() ) {
            # Die! Log out the connection error and die.
            $log->logwarn("Failed to Connect to Virtual CSV Database - With an Error of:\n $DBI::errstr\n");
            $log->logdie("Failed to connect to any Database, CSV fallback likely corrupted, please run ../db/build_csv_db.pl again");
        }
    }

    # Finally, bless the object
    my $self = bless {
        dbh => $dbh,
        log => $log,
        db_type => $db_type,
    }, $class;

    return $self;
}

sub fetch_member {
    my ($self, $type, $val) = @_;

    # Fetch row as Hash Ref
    my $sth = $self->{dbh}->prepare("SELECT MemberID, Name, Gender, DirectLineage, DateAdded FROM Members WHERE $type = ?");
    $sth->execute($val) or $self->{log}->logdie("ERROR: get_member - SELECT FAILED: " . $@);
    my $member = $sth->fetchrow_hashref;
    return $member;
}

sub get_relationships {
    my ($self, $type, $member_ord, $member_id) = @_;

    # Fetch relationship rows as Array of Hash
    my $sth = $self->{dbh}->prepare("SELECT RelationshipID, Type, To_Member, Member FROM Relationships WHERE Type = ? AND $member_ord = ?");
    $sth->execute($type, $member_id) or $self->{log}->logdie("ERROR: get_relationships - SELECT FAILED: " . $@);
    my @relationships = @{ $sth->fetchall_arrayref( {} ) };

    return \@relationships;
}

sub add_relationship {
    my ($self, $type, $to_member, $member) = @_;

    my $new_id;
    my $insert_query;
    if ( $self->{db_type} eq 'CSV' ) {
        ( $insert_query, $new_id ) = $self->_modify_insert_for_csv('add_relationship');
    } else {
        $insert_query = "INSERT INTO Relationships ( Type, To_Member, Member ) VALUES ( ?, ?, ? )";
    }
    # Insert Relationsip
    my $sth = $self->{dbh}->prepare($insert_query);
    $sth->execute($type, $to_member, $member) or $self->{log}->logdie("ERROR: add_relationship - INSERT FAILED: " . $@);
    # Grab Primary Key - new RelationshipID, or fallback to a manually incremented ID for CSV DB
    my $relationship_id = $sth->{mysql_insertid} || $new_id;

    return $relationship_id;
}

sub add_child {
    my ($self, $mother_id, $child_name, $child_gender ) = @_;

    # Add Child
    my $insert_query;
    my $new_id;
    if ( $self->{db_type} eq 'CSV' ) {
        ( $insert_query, $new_id ) = $self->_modify_insert_for_csv('add_member');
    } else {
        $insert_query = "INSERT INTO Members ( Name, Gender, DirectLineage ) VALUES ( ?, ?, ? )";
    }

    my $sth = $self->{dbh}->prepare($insert_query);
    $sth->execute($child_name, $child_gender, 1) or $self->{log}->logdie("ERROR: add_child - INSERT FAILED: " . $@);
    # Grab Primary Key - new MemberID, or fallback to a manually incremented ID for CSV DB
    my $child_id = $sth->{mysql_insertid} || $new_id;
    # Add Relevant Relationship
    my $relationship_id = $self->add_relationship( "is_Child", $mother_id, $child_id );

    return $child_id, $relationship_id;
}

sub add_member_via_marriage {
    my ( $self, $to_member_id, $spouse_name, $spouse_gender, ) = @_;

    # System only supports marriages *into* the Royal Family
    # So those that get added to the family *must* be from another family
    # So set that here.
    my $direct_lineage = 0;

    my $insert_query;
    my $new_id;
    if ( $self->{db_type} eq 'CSV' ) {
        ( $insert_query, $new_id ) = $self->_modify_insert_for_csv('add_member');
    } else {
        $insert_query = "INSERT INTO Members (Name, Gender, DirectLineage ) VALUES ( ?, ?, ? )";
    }

    # Insert new Member into Members table
    my $sth = $self->{dbh}->prepare($insert_query);
    $sth->execute( $spouse_name, $spouse_gender, $direct_lineage ) or $self->{log}->logdie("ERROR: add_member_via_marriage - INSERT FAILED: " . $@);
    # Grab Primary Key - new MemberID, or fallback to a manually incremented ID for CSV DB
    my $new_spouse_id = $sth->{mysql_insertid} || $new_id;
    # Add Relevant Relationship
    my $relationship_id = $self->add_relationship( "Married", $to_member_id, $new_spouse_id );

    return $new_spouse_id, $relationship_id;
}

sub _modify_insert_for_csv {
    my ($self, $type) = @_;

    my $column_name;
    my $table_name;
    my $time_added = '';
    my $last_added_id;

    if ( $type eq 'add_member' ) {
        $table_name = 'members';
        $column_name = 'MemberID';
        my $dt = DateTime->now( time_zone => 'Australia/Sydney', locale => 'en-AU' );
        $time_added = $dt->format_cldr( 'yyyy-MM-dd HH:mm:ss' );
    } else {
        $table_name = 'relationships';
        $column_name = 'RelationshipID';
    }

    my $sth = $self->{dbh}->prepare("SELECT $column_name FROM $table_name ORDER BY $column_name DESC LIMIT 1");
    $sth->execute();
    my $result = $sth->fetchrow_hashref;
    $last_added_id = $result->{$column_name};

    # Hacky but works - Perl cast as a number
    $last_added_id = $last_added_id + 0;
    my $new_id = ++$last_added_id;

    # Hacky but works
    my %mapped_queries = (
        add_member       => "INSERT INTO Members (MemberID, Name, Gender, DirectLineage, DateAdded ) VALUES ( $new_id, ?, ?, ?, '$time_added' )",
        add_relationship => "INSERT INTO Relationships (RelationshipID, Type, To_Member, Member) VALUES ( $new_id, ?, ?, ? )"
    );

    return $mapped_queries{$type}, $new_id;
}

# Beginning of implementing regnal numbers
sub get_names {
    my ( $self ) = @_;
        # Fetch All
        my @names = $self->{dbh}->selectall_array("SELECT Name FROM Members");

        my @extracted_names;
        foreach my $name ( @names ) {
            push @extracted_names, $name->[0];
        }
        return @extracted_names;
}

sub get_f_dir {
    my $dir = getcwd();
    my ( $volume, $directories, $test_path ) = File::Spec->splitpath( $dir );

    my $f_dir;
    # We're checking if we're being called from the /t directory *groan*
    if ($test_path eq 't') {
        return '../db/vdb';
    }

    return 'db/vdb';
}

1;