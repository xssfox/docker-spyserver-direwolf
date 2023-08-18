#!/bin/bash

set -e
set -u
set -o pipefail
set -x

# allow exiting on SIGTERM
trap "exit" SIGINT SIGTERM

echo "Setting up direwolf config"
envsubst < /root/direwolf.conf.tpl > /root/direwolf.conf
cat /root/direwolf.conf


if [ "$MODE" == "LSB" ]
then
    echo "Connecting to $HOST LSB"
    ss_iq -a 1200 -r $HOST -q $PORT -f $FREQ -s 12000 -b 16 - | \
    csdr convert_s16_f |\
    csdr bandpass_fir_fft_cc -0.3 0.0 0.05 | csdr realpart_cf | csdr agc_ff | csdr limit_ff | \
    csdr convert_f_s16 | direwolf -r 12000 -D 1 - 
elif [ "$MODE" == "USB" ]
then
    echo "Connecting to $HOST USB"
    ss_iq -a 1200 -r $HOST -q $PORT -f $FREQ -s 12000 -b 16 - | \
    csdr convert_s16_f |\
    csdr bandpass_fir_fft_cc 0 0.3 0.05 | csdr realpart_cf | csdr agc_ff | csdr limit_ff | \
    csdr convert_f_s16 |  direwolf -r 12000 -D 1 - 
elif [ "$MODE" == "FM" ]
then
    echo "Using NBFM via SpyServer"
    ss_iq -a 12000 -r $HOST -q $PORT -f $FREQ -s 24000 -b 16 - | \
    csdr convert_s16_f |\
    csdr fmdemod_quadri_cf | csdr limit_ff | csdr fastagc_ff | csdr convert_f_s16 |\
    direwolf -r 24000 -D 1 - 
else
    echo "UNKNOWN MODE"
fi