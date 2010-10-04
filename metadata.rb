maintainer       "Jason Ardell"
maintainer_email "ardell@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures CakePHP"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.0.1"
depends          "php"
depends          "apache2"
depends          "mysql"
depends          "openssl"

recipe "cakephp", "Installs and configures CakePHP LAMP stack on a single system"

%w{ debian ubuntu }.each do |os|
  supports os
end

attribute "cakephp/version",
  :display_name => "CakePHP download version",
  :description => "Version of CakePHP to download from the CakePHP site.",
  :default => "1.2.5"

attribute "cakephp/dir",
  :display_name => "CakePHP installation directory",
  :description => "Location to place CakePHP files.",
  :default => "/var/www"

attribute "cakephp/db/database",
  :display_name => "CakePHP MySQL database",
  :description => "CakePHP will use this MySQL database to store its data.",
  :default => "cakephpdb"

attribute "cakephp/db/user",
  :display_name => "CakePHP MySQL user",
  :description => "CakePHP will connect to MySQL using this user.",
  :default => "cakephpuser"

attribute "cakephp/db/password",
  :display_name => "CakePHP MySQL password",
  :description => "Password for the CakePHP MySQL user.",
  :default => "randomly generated"
