name             "sphinx-configuration"
maintainer_email "thomas.liebscher@iconicfuture.com"
maintainer       "Thomas Liebscher"
license          "Apache Software License 2.0"
description      "Configure sphinx search index"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

depends "mysql"
depends "sphinx"

%w{ ubuntu debian }.each do |os|
  supports os
end
