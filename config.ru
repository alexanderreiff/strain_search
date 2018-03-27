$:.unshift File.dirname(__FILE__)
require 'lib/strain_search/server'

run StrainSearch::Server
