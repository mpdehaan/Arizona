# a list of Controllers to load
# this is done in an include file vs dynamically to keep Moose computation
# costs ahead of Apache-forks, so no users have to wait

# View controllers
use Acme::Controllers::Page::Calculator;
# ...

# REST controllers
use Acme::Controllers::Rest::Calculator;
# ...

1;
