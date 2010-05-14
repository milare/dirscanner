#
# demo.rb 
# This script is responsible to check if there is a new or an out of data file
# in the input directory.

require 'lib/dirscanner'
require 'pp'

# Checks for updates in the input dir
Dirscanner.scan( "/home/bruno/Projects/marta/dados_abril/new_punch/" )

# List of new ou update needed files
files = Dirscanner.list_files

# files["kept"] - files that did not change.
# files["updated"] - files that have been updated.
# files["new"] - new files on the directory
pp files
