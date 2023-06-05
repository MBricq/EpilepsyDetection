# This directory contains different directories for testing the VHDL

To do a test, one first create a directory with the name of the test, and then generate the HDL Code along with a testbench as explained in `MATLAB/simulink/README.md`.

Then, one has to copy all the VHDL code along with the files `*.dat` in the new directory.

Finally, one can run Modelsim (the Intel version) and do the following:

- Create a new project in the directory of the test
- Add all the VHDL files to the project
- Compile the project, maybe need to do it more than once because of dependencies
- Run the simulation on work/project_name_tb.vhd
- Add the signals to the wave window
- Run the command `restart -f; run -all;` in the console
- Check the results, one can right click a wave and select `Format -> Analog` to see the signal as time function, mostly for the output signals
- If needed to stop the simulation, run the command `quit -sim` in the console

One test bench was left as an example.