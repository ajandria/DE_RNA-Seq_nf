
process star {

    publishDir "${params.outDir}/star", mode: 'symlink'

    label = 'intense'

    tag "star on ${sample_id}"

    input:
    tuple val(sample_id), path(reads)

    output:
    tuple val(sample_id), path("${sample_id}*.bam"), emit: aligned_with_star
    path("*"), emit: star_to_multiqc

    script:
    if(params.protocol == 'paired-end')

        """
        STAR --runMode alignReads \
        --genomeDir ${params.reference_genome} \
        --sjdbGTFfile ${params.gtf} \
        --readFilesIn ${reads[0]} ${reads[1]} \
        --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate \
        --outFileNamePrefix ${sample_id} \
        --runThreadN ${task.cpus}

        samtools index -@ ${task.cpus} *.bam
        """  

    else if(params.protocol == 'single-end')

        """
        STAR --runMode alignReads \
        --genomeDir ${params.reference_genome} \
        --sjdbGTFfile ${params.gtf} \
        --readFilesIn ${reads[0]} \
        --readFilesCommand zcat \
        --outSAMtype BAM SortedByCoordinate \
        --outFileNamePrefix ${sample_id} \
        --runThreadN ${task.cpus}

        samtools index -@ ${task.cpus} *.bam
        """  

    else

        throw new IllegalArgumentException("Unknown strandedness $params.strandedness")
        
}
