# NF-AMR

## Description

A Nextflow script that will run AMRFinderPlus on fasta files on S3 and databases available on a shared filesystem (EFS).

```bash
aws batch submit-job \
    --job-name nf-amr-TEST \
    --job-queue priority-maf-pipelines \
    --job-definition nextflow-production \
    --container-overrides command=fischbachLab/nf-amr,\
"--project","00_TEST",\
"--prefix","20230822",\
"--seedfile","s3://nextflow-pipelines/nf-amr/data/sample_seedfile.csv"
```

## Seedfile

The seedfile is a CSV file with the following columns: `sample_name`,`fasta_file`. A sample seedfile is available in [data/sample_seedfile.csv](data/sample_seedfile.csv).

## Note about implementation

As of 2023/09/09, the date of implementing this pipeline, there is an error in AMRFinderPlus that has been difficult to reproduce reliably. This error causes the application to exit with `Segmentation Fault` apparently on random genomes. It has also been discussed on the official AMRFinderPlus repo as an issue [here](https://github.com/ncbi/amr/issues/123).

In order to work around it, we simply retry the job upto 5 times and that seems to work. Until a fix is available, this is the best we can do.
