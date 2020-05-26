# GLASS-JANIS-comparison
This page explains Java and Perl programs used in the paper "Comparison of de-duplication methods used by WHO Global Antimicrobial Resistance Surveillance System (GLASS) and Japan Nosocomial Infections Surveillance (JANIS) in the surveillance of antimicrobial resistance" by Toshiki Kajihara, Koji Yahara, Sergey Romualdovich Eremin, Barbara  Tornimbene, Visanu Thamlikitkul, John Stelling, Aki Hirabayashi, Eiko Anzai, Satoyo Wakai, Nobuaki Matsunaga, Kayoko Hayakawa, Norio Ohmagari, Motoyuki Sugai, and Keigo Shibayama. 



The data tabulation according to WHO GLASS was conducted using the Java program as follows

```
java -jar CommandLineTool.jar input2017.csv.gz -sum 1  -clsi 2012 -dup_by_specimen -dup_days 365 -pre GLASS_2017_dupDays365_dup_by_specimen_ -postprocess 1 
```



The data tabulation according to JANIS (Japan Nosocomial Infections Surveillance) to calculate the number of patients was conducted using the Java program as follows:

```
java -jar CommandLineTool.jar input2017.csv.gz -sum 1  -clsi 2012                                -pre GLASS_2017_dupJANISpatient_ -postprocess 1 
```



The data tabulation according to JANIS (Japan Nosocomial Infections Surveillance) to calculate the number of isolates was conducted using the Java program as follows:

```
java -jar CommandLineTool.jar input2017.csv.gz -sum 1  -clsi 2012 -dup isolate                   -pre GLASS_2017_dupJANISisolate_ -postprocess 1 
```



The input files must contain the following data fields (with headers currently written in Japanese and codes of antimicrobial drugs, isolated bacteria, specimen sources, and susceptibility testing methods defined in JANIS): hospital ID, patient ID, inpatient or outpatient, specimen source, specimen reception date, isolated bacteria, antimicrobial susceptibility testing results, specimen ID.  The raw data are available to Japanese researchers who have a publicly-funded grant according to Article 32 of the Statistics Act in Japan.



If there is anyone who would like to utilize this program for tabulation of another data file with different data format, please take a contact with corresponding authors kajihara and k-yahara at niid.go.jp for discussions and collaborations we will appreciate.



The output files of the Java program (stored in "Perl" folder) were further tabulated using Perl scripts as follows:

```
### for tabulation according to GLASS
perl sum_GLASSformat_Sample.pl -f GLASS_2017_dupDays365_dup_by_specimen_patientGLASSSummary_20190524090903.csv > out_sample_GLASS.csv

perl sum_GLASSformat_RIS.pl    -f GLASS_2017_dupDays365_dup_by_specimen_bacteriaDrugGLASSSummary_20190524090903.txt_REFINE.csv | grep -v GENITAL > out_RIS_GLASS.csv

### for tabulation according to JANIS
perl sum_GLASSformat_Sample.pl -f GLASS_2017_dupJANISpatient_patientGLASSSummary_20190524094832.csv            > out_sample_JANIS.csv

perl sum_GLASSformat_RIS.pl    -f GLASS_2017_dupJANISisolate_bacteriaDrugGLASSSummary_20190524094848.txt_REFINE.csv | grep -v GENITAL > out_RIS_JANISisolate.csv

perl sum_GLASSformat_RIS.pl    -f GLASS_2017_dupJANISpatient_bacteriaDrugGLASSSummary_20190524094832.txt_REFINE.csv | grep -v GENITAL > out_RIS_JANISpatient.csv
```

