#!/usr/bin/env nextflow
nextflow.enable.dsl=1
// If the user uses the --help flag, print the help text below
params.help = false

// Function which prints help message text
def helpMessage() {
    log.info"""
    Search for AntiMicrobial Resistance (AMR) sequences in a fasta sequence using NCBI's AMRFinder-Plus.
    
    Required Arguments:
      --seedfile               Query file in csv format
      --prefix              Output prefix (default: ${params.prefix})
      --project             Folder to place analysis outputs (default: ${params.project})
    """.stripIndent()
}

// Show help message if the user specifies the --help flag at runtime
if (params.help){
    // Invoke the function above which prints the help message
    helpMessage()
    // Exit out and do not run anything else
    exit 0
}

// // Show help message if the user specifies a fasta file but not makedb or db
if (params.seedfile  == null){
    // Invoke the function above which prints the help message
    helpMessage()
    // Exit out and do not run anything else
    exit 1
}

Channel
    .fromPath(params.seedfile)
    .ifEmpty { exit 1, "Cannot find any seed file matching: ${params.seedfile}." }
    .splitCsv(header: true, sep: ',')
    .map{ row -> tuple(row.sample_name, file(row.fasta_file)) }
    .set {  fasta_ch  }

//Creates working dir
workingpath = params.outdir + "/" + params.project + "/" + params.prefix
workingdir = file(workingpath)

if( !workingdir.exists() ) {
    if( !workingdir.mkdirs() )     {
        exit 1, "Cannot create working directory: $workingpath"
    } 
}

/* 
 * Executes a AMR job for each chunk emitted by the 'fasta_ch' channel 
 * and creates as output a channel named 'top_hits' emitting the resulting 
 * AMR matches  
 */
process amr {
    tag "${name}"
    maxRetries 5
    cpus {  4 * task.attempt }
    memory  { 16.GB * task.attempt }
    time { 1.hour * task.attempt }
    errorStrategy 'retry'

    container params.docker_ncbi_amr
    // beforeScript: 'ulimit -sS unlimited'

    publishDir "${workingpath}/${name}/", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(name), path(fasta) from fasta_ch

    output:
    // file 'blast_result' into hits_ch
    path("${name}.amrfinder_report.tsv")
    // file ("${prefix}-mutations.tsv") into mutations_ch optional: true

    script:
    def is_compressed = fasta.getName().endsWith(".gz") ? true : false
    fasta_name = fasta.getName().replace(".gz", "")

    """
    if [ "$is_compressed" == "true" ]; then
        gzip -c -d $fasta > $fasta_name
    fi

    amrfinder \\
      -n $fasta_name \\
      --threads $task.cpus \\
      --output ${name}.amrfinder_report.tsv
    """
}
