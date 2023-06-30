#!/bin/bash

echo "Installing perl libraries..."
export PERL_MM_USE_DEFAULT=1
export PERL_EXTUTILS_AUTOINSTALL="--defaultdeps"
perl -MCPAN -e "install 'Parse::PMFile'"

# Module Apache2_4::AuthCookie requires a "nobody" user.
useradd -U --no-create-home -s /sbin/nologin nobody

PERLLIBS=(
    'DBI'
    'DBD::SQLite'
    'Geo::Coder::Google'
    'Text::CSV'
    'Text::CSV_XS'
    'Text::CSV::Simple'
    'DateTime::Format::MySQL'
    'DateTime::Format::Flexible'
    'DateTime::Format::Pg'
    'Email::Valid'
    'Config::Simple'
    'Apache2_4::AuthCookie'
    'Color::Calc'
    'Apache::Htpasswd'
    'Authen::Simple'
    'CGI::Application'
    'CGI::Application::Dispatch'
    'CGI::Application::Plugin::AutoRunmode'
    'CGI::Application::Plugin::ActionDispatch'
    'CGI::Application::Plugin::DevPopup'
    'CGI::Application::Plugin::Session'
    'Log::Log4perl'
    'Net::OAuth2::Client'
    'Net::OAuth2::AccessToken'
    'Mozilla::CA'
    'Tree::R'
    'JSON::XS'
    'Hash::Merge'
    'XML::Simple'
    'XML::Writer'
    'XML::Parser::PerlSAX'
    'File::Lockfile'
    'JSON::Validator'
    'String::Random'
    'String::Escape'
    'XML::XSLT'
    'UNIVERSAL::require'
    'Apache::Solr'
    'MCE'
    'MCE::Shared'
    'Moo'
    'Throwable::Error'
    'Geo::WKT::Simple'
    'HTTP::CookieJar::LWP'
    'File::Copy::Recursive'
)
concat1=""
for s in "${PERLLIBS[@]}"
do
    concat1="$concat1 $s"
done
echo "cpanm $concat1"
cpanm -n $concat1
echo ""

echo "Installing Geo::Shapelib"
cd /tmp;
curl -L https://cpan.metacpan.org/authors/id/A/AJ/AJOLMA/Geo-Shapelib-0.22.tar.gz | tar zx;
cd /tmp/Geo-Shapelib-0.22;
perl -w Makefile.PL --shapelib=/usr/lib64/libshp.so;
make install;
rm -rf /tmp/Geo-Shapelib-0.22;

echo "Installing CGI::Application::Plugin::Authentication"
cd /tmp;
curl -L https://cpan.metacpan.org/authors/id/W/WE/WESM/CGI-Application-Plugin-Authentication-0.23.tar.gz | tar zx;
cd /tmp/CGI-Application-Plugin-Authentication-0.23;
perl -w Makefile.PL;
make install;
rm -rf /tmp/CGI-Application-Plugin-Authentication-0.23;

echo "Installing XML::Checker"
cd /tmp;
curl -L https://cpan.metacpan.org/authors/id/T/TJ/TJMATHER/XML-Checker-0.13.tar.gz | tar zx;
cd /tmp/XML-Checker-0.13;
perl -w Makefile.PL;
make;
make install;
rm -rf /tmp/XML-Checker-0.13;