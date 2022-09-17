# Ruby
require 'optparse'

options = {}
opt_parser = OptionParser.new do |opts|
    opts.banner = 'here is help messages of the command line tool.'
    
    opts.separator ''
    opts.separator 'Specific options:'
    opts.separator ''
    
    options[:switch] = false
    
    opts.on('-s', '--switch', 'Set options as switch') do
        options[:switch] = true
    end
    
    opts.on('-n NAME', '--name Name', 'Pass-in single name') do |value|
        options[:name] = value
    end
    
    opts.on('-a A,B', '--array A,B', Array, 'List of arguments') do |value|
        options[:array] = value
    end
    
    opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
    end
end

opt_parser.parse!(ARGV)
puts options.inspect

