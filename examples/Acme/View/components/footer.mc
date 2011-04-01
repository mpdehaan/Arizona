<%doc>
A footer component that shows the time and hostname.
</%doc>

<%args>
$time
$hostname
</%args>

<hr/>
<% $time->strftime("%D %H:%M:%S") %> -- <% $hostname %>

</body>
</html>
