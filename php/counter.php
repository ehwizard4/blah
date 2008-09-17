<html><body>
<h3>Counter example</h3>

<?php 

echo 'This page has been loaded ';

$t = $db["phpCount"];
$o = $t->findOne();
if( !$o )
  $o = array( "count" => 0 );
$o["count"]++;
$t->save($o);

echo $o["count"];
echo " times";
?> 

<p>
<a href="/admin/doc?f=/php/counter.php">[Code]</a>
</body></html>
