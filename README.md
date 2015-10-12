## Best practices for writing modules/pipelines

These are some of the practices we follow in-house. We feel using these makes stitching custom pipelines using a set of modules quite easy. Consider this a check-list of a few ideas and a work in progress.

### Module function:

```{r picard_merge, echo=TRUE, comment=""}
picard_merge <- function(x, 
                        samplename = get_opts("samplename"),
                         mergedbam,
                         java_exe = get_opts("java_exe"),
                         java_mem = get_opts("java_mem"),
                         java_tmp = get_opts("java_tmp"),
                         picard_jar = get_opts("picard_jar")){
  

  check_args()  
  
  ## create a named list of commands
  bam_list = paste("INPUT=", x, sep = "", collapse = " ")
  cmds = list(merge = sprintf("%s %s -Djava.io.tmpdir=%s -jar %s MergeSamFiles %s OUTPUT=%s ASSUME_SORTED=TRUE VALIDATION_STRINGENCY=LENIENT CREATE_INDEX=true USE_THREADING=true",
                              java_exe, java_mem, java_tmp, picard_jar, bam_list, mergedbam))
  
  ## --- INPUT is a NAMED list
  flowmat = to_flowmat(cmds, samplename)
  return(list(outfiles = mergedbam, flowmat = flowmat))
}
```

1. should accept minimum of two inputs, 
    - **x** (a input file etc, depends on the module) and
    - samplename (is used to append a column to the flowmat)
2. should always return a list arguments:
    - **flowmat** (required)   : contains all the commands to run
    - **outfiles** (recommended): could be used as an input to other tools
3. can define all other default arguments such as paths to tools etc. in a seperate conf (tab-delimited) file.
  - Then use `get_opts("param")` to use their value.

```
## Example conf file:
cat my.conf
bwa_exe	/apps/bwa/bin/bwa
```

4. should use `check_args()` to make sure none of the default parameters are null. 

```{r}
## since this is not defined in the config file, returns NULLL
## check_args(), checks ALL the arguments of the function, and throws a error. use ?check_args for more details.
get_opts("my_new_tool")
```


### Pipeline structure
For example we have a pipeline consisting of alignment using bwa (aln1, aln2, sampe), fix rg tags using picard and merging the files.
We would create three files: 

```
fastq_bam_bwa.R      ## A R script, with sleep_pipe(), which creates a flowmat
fastq_bam_bwa.conf   ## An *optional* tab-delim conf file, defining default params
fastq_bam_bwa.def    ## A tab-delimited flow definition file
```

Notice how all files have the same basename; this is essential for the **run** function to find all these files.

We need that,
1. all three files should have the same basename
2. can have multiple flowdefs like fastq_bam_bwa_lsf.def, fastq_bam_bwa_lsf.def etc, where <basename>.def is used
 by default. But other are available for users to switch platforms quickly.

**Reason for using the same basename**:
- When we call `run("fastq_bam_bwa", ....)` it tries to look for a .R file inside flowr's package, `~/flowr/pipelines` OR your current wd. 
If there are multiple matches, later is chosen. 
- Then, it finds and load default parameters from `fastq_bam_bwa.conf` (if available). 
- Further, it calls the function `fastq_bam_bwa`, then stiches a flow using `fastq_bam_bwa.def` as the flow definition. 

**features**
- A user can supply a custom flow definition (`run("fastq_bam_bwa", def = path/myflowdef.def, ....)`). 
- Starting flowr version *0.9.8.9011*, run also accepts a custom conf file in addition to a flowdef file. Conf contains all the 
default parameters like absolute paths to tools, paths to genomes, indexes etc.

This is quite useful for portability, since to use the same pipeline across institution/computing clusters one only needs to change the 
flow definition and R function remains intact.

<div class="alert alert-info" role="alert">
**Tip:** 
Its important to note, that in this example we are using R functions, but any other language can be used to create a tab-delimited flowmat file, and submitted using `submit_flow` command.
</div>


## Nomeclature for parameters (recommeded for increased portability)

1. all binaries end with **_exe**
2. all folders end with **_dir**
3. 
