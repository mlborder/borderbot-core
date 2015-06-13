require 'rbatch'

args = ARGV.getopts('s:f:')
series_name = args['s'] || 'sample'
file_path = File.expand_path("#{args['f'] || "tmp/#{series_name}.series"}", ENV['RB_HOME'])

datastore = Mlborder::Datastore.new
datastore.push_from_file series_name, file_path
