
library(dplyr)
library(params)

df = read_sheet("data/cgbrowser_summary.tsv") %>% tbl_df()

#+ create_flowmat
library(flowr)

# a function to create a flowmat
gtdownload <- function(uuid, 
                       samplename,
                       gtdownload_exe = "gtdownload", 
                       key = "cghub4.key",
                       gtdownload_opts = ""
                       
                       ){
  cmd = sprintf("%s %s -c %s -d %s -v", 
                gtdownload_exe, 
                gtdownload_opts, 
                key, uuid)
  
  
  flowmat = to_flowmat(list(gtdownload = cmd), samplename)
  
  return(flowmat)
}

# create flowmat
flowmat <- gtdownload(df$analysis_id, "set1")

flowdef = to_flowdef(flowmat, queue = "transfer", platform = "lsf", memory_reserved = 16384, walltime = "12:00", sub_type = "scatter")


write_sheet(flowmat, file.path(odir, "flowmat.tsv"))
write_sheet(flowdef, file.path(odir, "flowdef.tsv"))

cat(tools::file_path_as_absolute(odir))


# cd ~/tmp/wrangl_00_download_ccle

# submit the jobs to the cluster                                    we need to load a module
# flowr to_flow x=flowmat.tsv def=flowdef.tsv flow_run_path=~/tmp/ module_cmds="module load cghub" execute=TRUE

# flowr status x=flowname-set1-20160630-17-57-13-9wvGxTgB
# ================================================================================
#   Summarizing status (using triggers) of:
#   flowname-set1-20160630-17-57-13-9wvGxTgB
# |======================================================================| 100%
# |               | total| started| completed| exit_status|status     |
# |:--------------|-----:|-------:|---------:|-----------:|:----------|
# |001.gtdownload |   131|      20|         0|           0|processing |




