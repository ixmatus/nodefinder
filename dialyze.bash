#!/bin/bash
DIRNAME=`pwd`
PROJNAME=`basename $DIRNAME`
 
if [[ ! -f "$HOME/.dialyzer_otp.plt" ]];
then
    echo "OTP plt not found"
    exit -1
fi
 
if [[ ! -f "deps.plt" ]];
then
    rebar compile
    echo "MUST REMOVE WARNINGS_AS_ERRORS FROM ALL REBAR.CONFIG FILES; KNOWN BUG"
    echo "Dialyzing dependencies"
    dialyzer --add_to_plt --plt $HOME/.dialyzer_otp.plt --output_plt deps.plt -r deps/*/ebin/
fi
 
rebar compile skip_deps=true
 
if [[ -f $PROJNAME.plt ]];
then
    dialyzer --check_plt --plt $PROJNAME.plt -r apps/*/ebin
    if [[ $? -ne 0 ]];
    then
	echo "Not up to date, dialyzing"
	dialyzer --add_to_plt --plt deps.plt --output_plt $PROJNAME.plt -r apps/*/ebin
    fi
else
    echo "Dialyzing $PROJNAME"
    dialyzer --add_to_plt --plt deps.plt --output_plt $PROJNAME.plt -r apps/*/ebin
fi
 
echo "Checking"
dialyzer -Werror_handling -Wrace_conditions -Wunderspecs --statistics --plt $PROJNAME.plt -r apps/*/ebin | fgrep -v -f ./dialyzer.ignore-warnings
