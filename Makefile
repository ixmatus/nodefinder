ERL = $(shell which erl)

ERLFLAGS= -pa $(CURDIR)/.eunit -pa $(CURDIR)/ebin -pa $(CURDIR)/*/ebin

REBAR=$(shell which rebar)

ifeq ($(REBAR),)
$(error "Rebar not available on this system")
endif

DEPSOLVER_PLT=$(CURDIR)/nodefinder.plt

.PHONY: dialyze clean distclean compile console deps

all: clean compile dist

dialyze:
	./dialyze.bash

distclean: clean
	rm $(DEPSOLVER_PLT)
	rm -rvf $(CURDIR)/deps/*

clean:
	$(REBAR) clean

compile:
	$(REBAR) compile

deps:
	$(REBAR) get-deps
