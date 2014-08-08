#!/usr/bin/perl

use strict;
use warnings;
use XML::XPath;
use XML::XPath::XMLParser;
use utf8;

use Data::Dumper

binmode STDOUT, ":utf8";

my $xp = XML::XPath->new(filename=>$ARGV[0]);

foreach my $table ( $xp->findnodes('//sql/table') ) {
  print $table->find('@name');
  foreach my $row ( $table->findnodes('row') ) {
    my $name = "" . $row->find('@name');
    next if $name eq "id";
    print " ";
    if($name =~ /_id$/){
      $name  =~ s/_id//;
      print $name . ":";
      print "references";
    } else {
      print $name . ":";
      print $row->find('datatype');
    }
    print " ";
  }
  print "\n";
}

