# HaplowebMaker

To use the online version of HaplowebMaker, you can just upload one or several FASTA files (one per marker) to https://eeg-ebe.github.io/HaplowebMaker/. In these FASTA files your sequences should be named like this:
```
>Individual1_a
ATGC...
>Individual1_b
ATGC...
>Individual2
ATCC...
>Individual3_a
ATTT...
>Individual3_b
ATCT...
```

Here Individual1 and Individual3 are heterozygous and Individual2 is homozygous. You can use anything after the "_" character to differentiate the various haplotypes of an individual, e.g. `_A` & `_B`, `_firstseq` & `_secondseq`, `_1` & `_2`. In case you have more than two haplotypes per individuals it works just fine, just use e.g. `_a`, `_b` and `_c`. If you prefer you can use another separator than `_`, e.g. `-`, `/` etc. - just specify the one you want user the drop-down menu in the Advanced Parameters section.

One important point in that sequences should be phased and without missing data, i.e. there should be no e.g. `W`, `Y`, `N` or `?` in the sequences (if there are some, then the program will issue a warning and the corresponding columns will be masked).

If you upload several FASTA files at once, in addition the haplowebs you get a "conspecificity matrix" (explained in http://www.sciencedirect.com/science/article/pii/S0960982216000816); unless your markers are perfectly concordant it is generally better to have at least 4 markers for the matrix to make sense. The matrix is provided both as a figure (with a rudimentary clustering algorithm - we plan to implement better ones) and as a tab-delimited file that you can download and cluster the way you like, for instance using the R package heatmap3).


