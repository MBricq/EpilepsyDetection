# Description of the different simulink models

## full_system.slx
As the name suggests, this is the full system. If given as input the EGG signal and enable, it will output the detected seizure. It was built using the HDL Coder. It is not the model that is used in the FPGA. In a perfect test, we could run only this on a FPGA with as input the two mentionned signals and it would output the dectected seizure. But in reality, we need to run it along with Nios II. This is why we have the next model.

## full_system_nios.slx
This is the same model as full_system.slx but it is built with the goal of working along with Nios II. It is the model that is used in the FPGA. Instead of sending a full signal, it receives one epoch (512 samples or one second of data) at a time. It doesn't output the actual final value but what is called the predictor in my report, meaning the value of beta * x + bias. This value is then saved by the Nios II CPU which itself computes the average. This is done because MATLAB is unable to send data with consistent timing.
Another point is the new second output, the signal `done`. This signal is used to tell the Nios II CPU that the computation is done and that it can read the value of the predictor. The issue with this model is that the board we use (DE2-115) doesn't have enough logic elements to run it. This is why we have the next models.

## full_system_nios_id*.slx
It is the same as the previous but with goal of working only for one chosen patient. For each of them, I copied `full_system_nios`and then removed all unneeded compuations, wether they are DWT coeff or all unwanted statistics. This is why we have one model for each patient. These are the ones actually tested on the FPGA

## hdlcoder_dwt.slx
This is the model that was used to generate the HDL code for the DWT. It is not used in the FPGA. It was used to built the DWT blocks used in the other systems and is still used by MATLAB to compute the DWT coefficients.


## How to run the models
For the first three, one runs them by launching the scripts `test_classifier.m`, where one need to change the file name. They can be run directly from Simulink, but one needs to load in the workspace the correct input singals as it is done in `test_classifier.m`. For the dwt, it is run by the script `generate_stats.m`.
To get the HDL code, one needs to open the model and then click on the HDL Coder button after selecting the global block. One can also generate a test bench to test the generated code (see the Modelsim directory). All of the code is generated in the directory `hdlsrc`.