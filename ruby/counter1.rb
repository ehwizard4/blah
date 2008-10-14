n = $db.nRubyPageLoads.findOne || {'count' => 0}
n['count'] += 1
$db.nRubyPageLoads.save(n)

puts "<html><body>"
print "<p>This page has been loaded #{n['count'].to_i} times."
print " <a href=\"/admin/doc?f=/ruby/#{File.basename(__FILE__)}\">[code]</a>"
puts "</p>"
puts "</body></html>"
