# NF-BLAST

## Update pipeline

```bash
aws s3 sync . s3://nextflow-pipelines/nf-amr --delete
```

A Nextflow script that will run BLAST and using fasta files on S3 and databases available on a shared filesystem (EFS).

```bash
aws batch submit-job \
    --job-name nf-amr-TEST \
    --job-queue priority-maf-pipelines \
    --job-definition nextflow-production \
    --container-overrides command=s3://nextflow-pipelines/nf-amr,\
"--project","00_TEST",\
"--prefix","20230822",\
"--seedfile","s3://nextflow-pipelines/nf-amr/data/sample_seedfile.csv"
```

## UHGG

```bash
aws batch submit-job \
    --job-name nf-amr-uhgg-2-0-1 \
    --job-queue priority-maf-pipelines \
    --job-definition nextflow-production \
    --container-overrides command=s3://nextflow-pipelines/nf-amr,\
"--project","UHGG_v2.0.1",\
"--prefix","20230822",\
"--seedfile","s3://genomics-workflow-core/Results/AMRFinderPlus/UHGG_v2.0.1/20230822/00_seedfile/uhgg_seedfile.attempt2.csv"
```

### check if completed

```bash
aws s3 ls s3://genomics-workflow-core/Results/AMRFinderPlus/UHGG_v2.0.1/20230822/ | wc -l
```

## MITI-MCB [DONE]

```bash
aws batch submit-job \
    --job-name nf-amr-miti-mcb \
    --job-queue priority-maf-pipelines \
    --job-definition nextflow-production \
    --container-overrides command=s3://nextflow-pipelines/nf-amr,\
"--project","MITI-MCB",\
"--prefix","20230822",\
"--seedfile","s3://genomics-workflow-core/Results/AMRFinderPlus/MITI-MCB/20230822/00_seedfile/MITI_genomes.seedfile.csv"
```

### check if completed

```bash
aws s3 ls s3://genomics-workflow-core/Results/AMRFinderPlus/MITI-MCB/20230822/ | wc -l
```

## Human Pathogens

```bash
aws batch submit-job \
    --job-name nf-amr-human-pathogens \
    --job-queue priority-maf-pipelines \
    --job-definition nextflow-production \
    --container-overrides command=s3://nextflow-pipelines/nf-amr,\
"--project","human_pathogens",\
"--prefix","20230822",\
"--seedfile","s3://genomics-workflow-core/Results/AMRFinderPlus/human_pathogens/20230822/00_seedfile/pathogens.seedfile.csv"
```

### check if completed

```bash
aws s3 ls s3://genomics-workflow-core/Results/AMRFinderPlus/human_pathogens/20230822/ | wc -l
```
