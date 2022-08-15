# inVivo-ePhys

Custom scripts and functions for extracting and analyzing analog and digital data collected on a Plexon "full info here" chassis. 

Requirements:
- Plexon's SDK for Matlab offline analysis (link)
- Matlab's Signal Processing Toolkit

## Workflow:

**1) Extract raw .pl2 files with PL2_to_Mat.m** 
- This script (eventual function) extracts and saves sampling rate (sr), and broadband neural data in a channel x time matrix. 
- User-requested data channels and their respective sampling rates will be saved into separate matrices. 
- All extracted data is saved as a .mat into a subfolder of the working directory called "Extracted."

**2) Visualize data quality with PLQC.m.**

**3) Spike sorting applications**
- Spike_detect.m for multiunit activity
- Spike_sort.m for spike sorting
- Spike_align.m for spike alignment with user-defined epochs

**4) Spectral analysis**
- TBD!

