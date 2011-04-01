<%doc>
Example Mason template.
</%doc>

<%args>
$hostname
$time
$title
</%args>
<& "/components/header.mc", title => $title &>

<script type='text/javascript'>
    $(document).ready(function() {
        $('#submit').click(function() {
            $.ajax({
                url: "/Rest/Calculator/add",
                context: document.body,
                method: 'POST',
                data: {
                   'a' : $('#a').val(),
                   'b' : $('#b').val(),
                },
                dataType: 'json',
                success: function(result) {
                   alert(result.data.sum);
                }
            });
        });
   });
</script>


<!-- inline javascript may not be cool, but this is just a simple AJAX demo -->
<!-- you'll also probably want nicer HTML -->
<!-- note, this setup doesn't serve static files through Dancer, there's no point, configure Apache/etc for that -->
<!-- this demo is just using a CDN -->

<div class='header'>
<p>Enter two numbers and press the button.</p>
</div>

<div class='calculator'>
<p>
A: <input type='text' name='a' id='a'/><br/>
B: <input type='text' name='b' id='b'/><br/>
Submit: <input type='button' name='submit' id='submit'/><br/>
</p>
</div>

<& "/components/footer.mc", hostname => $hostname, time => $time, &>
</body>
</html>
