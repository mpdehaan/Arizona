all:
	PERL5LIB=lib:examples perl examples/phoenix.pl	

test:
	PERL5LIB=lib:examples:examples/t perl examples/t/SqlFoo.t
	PERL5LIB=lib:examples:examples/t perl examples/t/NoSqlFoo.t

