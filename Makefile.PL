# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# Copyright (C) 2002-2007 Jens Thoms Toerring <jt@toerring.de>
#
# $Id: Makefile.PL 8071 2007-08-05 21:06:18Z jens $


use ExtUtils::MakeMaker;
use Config;


# Check if there's a C compiler that we can use.

open $fh, '>cc_test.c' or die "Failed to open a file for writing: $!\n";
print $fh "int main(void)\n{\nreturn 0;\n}\n";
close $fh;

if ( system $Config{cc}, qw( -o cc_test cc_test.c ) ) {
    unlink 'cc_test.c';
    die "Can't run C compiler $Config{cc}\n";
}
unlink 'cc_test';
unlink 'cc_test.c';


# Check if using fcntl() works - if the this fails the system may not
# have a fcntl(2) system call at all.

open $fh, '>fcntl_test.c' or die "Failed to open a file for writing: $!\n";
print $fh <<EOF;
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
int main( void ) {
    struct flock f;
    f.l_type = F_RDLCK;
    f.l_whence = SEEK_SET;
    f.l_start = 0;
    f.l_len = 0;
    return fcntl( 0, F_SETLK, &f ) != -1 ? EXIT_SUCCESS : EXIT_FAILURE;
}
EOF
close $fh;

if ( system $Config{cc}, qw( -o fcntl_test fcntl_test.c ) ) {
    unlink 'fcntl_test.c';
    die "Failed to compile a program that uses fcntl(). Does your system " .
        "have a fcntl(2) system call?\n";
}
unlink 'fcntl_test';
unlink 'fcntl_test.c';


# Compile and run the program that creates the include file (first try
# a version that also tries 'long long', then one that only uses 'long'
# since 'long long' may not exist on all systems).

if ( ( system $Config{cc}, qw( -o sizes1 sizes1.c ) or system './sizes1' ) and
     ( system $Config{cc}, qw( -o sizes2 sizes2.c ) or system './sizes2' ) ) {
    unlink 'sizes1' if -e 'sizes1';
    unlink 'sizes2' if -e 'sizes2';
	unlink 'Fnctl_Lock.h' if -e 'Fnctl_Lock.h';
    die "Failed to create the necessary header file.\n";
}
unlink 'sizes1' if -e 'sizes1';
unlink 'sizes2' if -e 'sizes2';


# Finally create the Makefile

WriteMakefile(
    NAME              => 'File::Fcntl_Lock',
    ( $] >= 5.005 ?
      ( VERSION_FROM  => 'lib/File/Fcntl_Lock.pm',
        ABSTRACT_FROM => 'lib/File/Fcntl_Lock.pm',
        AUTHOR        => 'Jens Thoms Toerring <jt@toerring.de>' ) :
      ( ) ),
    PREREQ_PM         => { POSIX      => 0,
                           Errno      => 0,
                           Carp       => 0,
                           Exporter   => 0,
                           DynaLoader => 0 },
    PERL_MALLOC_OK    => TRUE,
    C                 => [ 'Fcntl_Lock.xs' ],
    test              => { TESTS => 't/*.t' },
    clean             => { FILES => 'Fcntl_Lock.h' }
);