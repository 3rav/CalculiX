#!/usr/bin/perl

chomp($date=`date`);

# inserting the date into ccx_2.3.c

@ARGV="ccx_2.3.c";
$^I="";
while(<>){
    s/You are using an executable made on.*/You are using an executable made on $date\\n");/g;
    print;
}


