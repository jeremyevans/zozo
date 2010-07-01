$:.unshift File.join(File.dirname(File.expand_path(__FILE__)), 'test1')
$:.unshift File.join(File.dirname(File.expand_path(__FILE__)), 'b', 'bin')
use Rack::ContentLength
run(proc{|env| [ 200, {'Content-Type' => 'text/plain'}, "a" ]})
