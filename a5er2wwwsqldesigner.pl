#!/usr/bin/perl

use strict;
use warnings;
use utf8;

#use Data::Dumper;

#
# Configure
#

my $position_scale = 0.5;

#
# variable for a5er Blocks
#

my %blocks = ();
my $block = "";
my $block_count = 0;
my %relations = ();

#
# Read a5er file and construct $blocks hash
#
while(<>){
  if($_ =~ /^\[(.*?)\]/){
    $block = $1;
    $block_count++;
  }
  next if $block eq "";

  my $line = $_;

  # a5er file return code is CR+LF.
  # so chop chop... :)
  # chomp $line;
  chop $line;
  chop $line;
  next if $line eq "";

  push(@{$blocks{$block}{$block_count}}, $line);
}

#
# construct relation info
#

foreach my $block_count (keys $blocks{'Relation'}){
  Relation(@{$blocks{'Relation'}{$block_count}});
}

#
# If a5er block is [Entity] -> call Entity Subroutine with block-lines.
#
print_header();
foreach my $block_count (keys $blocks{'Entity'}){
  Entity(@{$blocks{'Entity'}{$block_count}});
}
print_footer();


#
# Construct WWW SQL Designer XML
#


sub Comment() {
}

sub Entity(@) {

  my $PName;
  my $LName;
  my %Fields;
  my %Positions;

  # parse Entity info
  for my $line (@_){
    my($key, $value) = split /=/, $line;

    if($key eq "PName"){
      $PName = $value;
    } elsif ($key eq "LName"){
      $LName = $value;
    } elsif ($key eq "Field"){
      $value =~ s/"//g;
      my @fields = split /,/, $value;
      $Fields{@fields[1]}{'LName'} = @fields[0];
      $Fields{@fields[1]}{'Type'} = uc(@fields[2]);
      $Fields{@fields[1]}{'Default'} = @fields[4];
    } elsif ($key eq "Position"){
      my @positions = split /,/, $value;
      $Positions{'x'} = @positions[1] * $position_scale;
      $Positions{'y'} = @positions[2] * $position_scale;
    }
  }

  # print XML
  print '<table x="' . $Positions{'x'} . '" y="' . $Positions{'y'} . '" name="' . $PName . '">' . "\n";
  foreach my $name (keys %Fields){
    print '  <row name="' . $name . '" null="1" autoincrement="1">' . "\n";
    print '    <datatype>' . $Fields{$name}{'Type'} . '</datatype>' . "\n";
    print '    <default>' . $Fields{$name}{'Default'} . '</default>' . "\n";
    print '    <comment>' . $Fields{$name}{'LName'} . '</comment>' . "\n";
    if(exists($relations{$PName}{$name})){
      print '    <relation table="' . $relations{$PName}{$name}{'Entity'} . '" row="' . $relations{$PName}{$name}{'Fields'} . '" />' . "\n";
    }
    print '  </row>' . "\n";
  }
  print '  <comment>' . $LName . '</comment>' . "\n";
  print '</table>' . "\n";
}

sub Line() {
}

sub Manager() {
}

#
# parse and construct Relation info
#
sub Relation(@) {
  my $Entity1;
  my $Entity2;
  my $Fields1;
  my $Fields2;

  for my $line (@_){
    my($key, $value) = split /=/, $line;

    if($key eq "Entity1"){
      $Entity1 = $value;
    } elsif ($key eq "Entity2"){
      $Entity2 = $value;
    } elsif ($key eq "Fields1"){
      $Fields1 = $value;
    } elsif ($key eq "Fields2"){
      $Fields2 = $value;
    }
  }
  $relations{$Entity2}{$Fields2}{'Entity'} = $Entity1;
  $relations{$Entity2}{$Fields2}{'Fields'} = $Fields1;
}

sub print_header{

  print << "__HEADER__";
<?xml version="1.0" encoding="utf-8" ?>
<!-- SQL XML created by WWW SQL Designer, http://code.google.com/p/wwwsqldesigner/ -->
<!-- Active URL: http://dandydot.dyndns.org:8080/dc/db/ -->
<sql>
<datatypes db="postgresql">
  <group label="Numeric" color="rgb(238,238,170)">
    <type label="Integer" length="0" sql="INTEGER" re="INT" quote=""/>
    <type label="Small Integer" length="0" sql="SMALLINT" quote=""/>
    <type label="Big Integer" length="0" sql="BIGINT" quote=""/>
    <type label="Decimal" length="1" sql="DECIMAL" re="numeric" quote=""/>
    <type label="Serial" length="0" sql="SERIAL" re="SERIAL4" fk="Integer" quote=""/>
    <type label="Big Serial" length="0" sql="BIGSERIAL" re="SERIAL8" fk="Big Integer" quote=""/>
    <type label="Real" length="0" sql="BIGINT" quote=""/>
    <type label="Single precision" length="0" sql="FLOAT" quote=""/>
    <type label="Double precision" length="0" sql="DOUBLE" re="DOUBLE" quote=""/>
  </group>

  <group label="Character" color="rgb(255,200,200)">
    <type label="Char" length="1" sql="CHAR" quote="'"/>
    <type label="Varchar" length="1" sql="VARCHAR" re="CHARACTER VARYING" quote="'"/>
    <type label="Text" length="0" sql="TEXT" quote="'"/>
    <type label="Binary" length="1" sql="BYTEA" quote="'"/>
    <type label="Boolean" length="0" sql="BOOLEAN" quote="'"/>
  </group>

  <group label="Date &amp; Time" color="rgb(200,255,200)">
    <type label="Date" length="0" sql="DATE" quote="'"/>
    <type label="Time" length="1" sql="TIME" quote="'"/>
    <type label="Time w/ TZ" length="0" sql="TIME WITH TIME ZONE" quote="'"/>
    <type label="Interval" length="1" sql="INTERVAL" quote="'"/>
    <type label="Timestamp" length="1" sql="TIMESTAMP" quote="'"/>
    <type label="Timestamp w/ TZ" length="0" sql="TIMESTAMP WITH TIME ZONE" quote="'"/>
    <type label="Timestamp wo/ TZ" length="0" sql="TIMESTAMP WITHOUT TIME ZONE" quote="'"/>
  </group>

  <group label="Miscellaneous" color="rgb(200,200,255)">
    <type label="XML" length="1" sql="XML" quote="'"/>
    <type label="Bit" length="1" sql="BIT" quote="'"/>
    <type label="Bit Varying" length="1" sql="VARBIT" re="BIT VARYING" quote="'"/>
    <type label="Inet Host Addr" length="0" sql="INET" quote="'"/>
    <type label="Inet CIDR Addr" length="0" sql="CIDR" quote="'"/>
    <type label="Geometry" length="0" sql="GEOMETRY" quote="'"/>
  </group>
</datatypes>

__HEADER__

}

sub print_footer{

  print << "__FOOTER__";

</sql>

__FOOTER__
}
