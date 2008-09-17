n=db.nLoads.findOne() or {'count':0}
n.count = n.count + 1
db.nLoads.save(n)

print "<html><body>This page has been loaded "
print n.count
print " times. "
print '<a href="/admin/doc?f=/py/counter.py">[code]</a>'
print "<p>"





