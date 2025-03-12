#!/usr/bin/env nextflow
nextflow.enable.dsl = 2
// If the user uses the --help flag, print the help text below
params.help = false

workflow {
    // Show help message if the user specifies the --help flag at runtime
    if (params.help) {
        // Invoke the function above which prints the help message
        helpMessage()
        // Exit out and do not run anything else
        exit(0)
    }

    fasta_ch = Channel.fromPath(params.seedfile)
        | ifEmpty { exit(1, "Cannot find any seed file matching: ${params.seedfile}.") }
        | splitCsv(header: true, sep: ',')
        | map { row -> tuple(row.sample_name, file(row.fasta_file)) }

    // Run the AMR process for each fasta file
    amr(fasta_ch)
}

/* 
 * Executes a AMR job for each chunk emitted by the 'fasta_ch' channel 
 * and creates as output a channel named 'top_hits' emitting the resulting 
 * AMR matches  
 */
process amr {
    tag "${name}"
    // beforeScript: 'ulimit -sS unlimited'

    publishDir "${params.workingpath}/${name}/", mode: 'copy', pattern: "*.tsv"

    input:
    tuple val(name), path(fasta)

    output:
    // file 'blast_result' into hits_ch
    path "${name}.amrfinder_report.tsv"

    script:
    def is_compressed = fasta.getName().endsWith(".gz") ? true : false
    def fasta_name = fasta.getName().replace(".gz", "")

    """
    if [ "${is_compressed}" == "true" ]; then
        gzip -c -d ${fasta} > ${fasta_name}
    fi

    amrfinder \\
      -n ${fasta_name} \\
      --threads ${task.cpus} \\
      --output ${name}.amrfinder_report.tsv
    """

    stub:
    def is_compressed = fasta.getName().endsWith(".gz") ? true : false
    def fasta_name = fasta.getName().replace(".gz", "")
    """
    echo "is_compressed: ${is_compressed}" >> ${name}.amrfinder_report.tsv
    echo "fasta_name: ${fasta_name}" >> ${name}.amrfinder_report.tsv
    echo "workingpath: ${params.workingpath}" >> ${name}.amrfinder_report.tsv
    echo "amrfinder -n ${fasta_name} --threads ${task.cpus} --output ${name}.amrfinder_report.tsv" >> ${name}.amrfinder_report.tsv
    """
}

// Function which prints help message text
def helpMessage() {
    log.info(
        """
    Search for AntiMicrobial Resistance (AMR) sequences in a fasta sequence using NCBI's AMRFinder-Plus.
    
    Required Arguments:
      --seedfile               Query file in csv format
      --prefix              Output prefix (default: ${params.prefix})
      --project             Folder to place analysis outputs (default: ${params.project})
    """.stripIndent()
    )
}
