# FPGA implementation of a seizure detector using spectral domain features extraction.

This folder contains the files for the FPGA detector as it was built for a semester project at EPFL. It was completed in Spring 2023 by Marin Bricq (Robotic student). The project was supervised by Prof. Alexandre Schmid.

## Description
The goal of this project was to build a detector for epileptic seizures. It is based on the short-term dataset from the SWEC-ETHZ (http://ieeg-swez.ethz.ch/). The detector uses statistics computed from Discret Wavelet Transform coefficients and linear SVM models to detect the seizures. The detector was built using MATLAB and Simulink and then converted to an FPGA version using the HDL Coder. The detector was tested on the FPGA DE2-115 using some C code running on the NIOS II processor for testing. More details can be found in the report.

## Structure
The folder contains the following directories:
- `MATLAB`: Contains all MATLAB scripts along with the Simulink models required for the project.
- `Modelsim`: Contains the Modelsim projects for the FPGA testing.
- `FPGA`: Contains the source code (VHDL and C) for the FPGA testing.

In each of those directories, there is a README.md file explaining the structure of the directory and how to rebuild the project. I would recommend to read them in the order mentioned above.