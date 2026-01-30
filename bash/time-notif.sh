#!/usr/bin/env bash
notify-send "Detailed Time" "<b>Today is</b>: $(date +%A), $(date +%B) $(date +%d), $(date +%G)\n <b>The current time is</b>: $(date +%T)\n <b>Week</b> $(date +%U) of the year."
