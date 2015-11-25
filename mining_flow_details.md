>  This page shows a few examples mining through the flow_details log file

> install this cool tool from Heng Li (https://github.com/lh3/bioawk)

```
brew install bioawk

# information regarding exit_code:
#    NA: not started yet
#    -1: started but not finished yet
#     0: completed successfully without errors
#    >0: there is a error in this file

# show jobs where it started and had errors
bioawk -tc hdr '{if($exit_code>0 && $started=="TRUE") print $jobname, $exit_code, $cmd}' flow_details.txt

# show jobs which did not start
bioawk -tc hdr '{if($started=="FALSE") print $jobname, $exit_code, $cmd}' flow_details.txt

# started, but have not finished yet (no exit status yet)
bioawk -tc hdr '{if($started=="TRUE" && $exit_code==-1) print $jobname, $exit_code, $cmd}' flow_details.txt

# get a list of files with errors
fls=$(bioawk -tc hdr '{ if($exit_code>0 && $started=="TRUE"){ gsub(/sh/, "out", $cmd); print $cmd }}' flow_details.txt)

# one may use tail to look at the errors:
tail -n 20 $fls

# use less, and then use :n to go to the next lines
less $fls

# this works
echo $fl | bioawk 'gsub(/sh/, "out", $0)'

```







# END
