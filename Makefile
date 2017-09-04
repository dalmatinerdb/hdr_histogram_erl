REBAR=$(shell [ -f ./rebar3 ] && echo "./rebar3" || echo "rebar3" )
CC=$(shell clang -v >/dev/null && echo "clang" || echo "gcc")

.PHONY: all erl test clean doc 

all: test perf

build:
	$(REBAR) compile

dialyze:
	rebar3 dialyzer

test:
	$(REBAR) ct

eqc:
	$(REBAR) as eqc eqc

clean:
	$(REBAR) clean
	-rm -f doc/*.md doc/edoc-info
	-rm -rvf deps ebin .eunit

perf: build
	$(CC) -ggdb -c -O3 -ffast-math -std=c99 -I c_src perf/hh.c -o perf/hh.o
	$(CC) -ggdb -lm -o perf/hh c_src/hdr_histogram.o perf/hh.o
	perf/hh 1000000 1000000 1
	perf/hh 100000000 1000000 1
	perf/hh 1000000000 1000000 1
	perf/hh 1000000 1000000 3
	perf/hh 100000000 1000000 3
	perf/hh 1000000000 1000000 3
	perf/hh 1000000 1000000 5
	perf/hh 100000000 1000000 5
	perf/hh 1000000000 1000000 5

doc:
	$(REBAR) edoc

demo-elixir: doc
	elixir -pa ebin -r examples/simple.exs -e "Simple.main"

demo-lfe: doc
	ERL_LIBS=deps:.. lfescript examples/simple.lfe

demo-erlang: doc
	./examples/simple.erl

eqc-compile: build
	-mkdir ebin
	erl -make
