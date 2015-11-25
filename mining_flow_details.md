>  This page shows a few examples mining through the flow_details log file

# install this cool tool from Heng Li (https://github.com/lh3/bioawk)

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

# drilling into looking at errors
bioawk -tc hdr '{if($exit_code>0 && $started=="TRUE") print sub(".sh$", ".out", $cmd}' flow_details.txt


# this works
echo $fl | bioawk 'gsub(/sh/, "out", $0)'

```







# END
