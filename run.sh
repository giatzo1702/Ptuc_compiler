#/bin/bash

echo -n "\nPlease give the name of the example you want to run:\n"
read answer

echo "\n\nCleaning..."
echo "------------\n"
make clean
echo "\n\nmake"
echo "------\n"
make
echo "\n\nRemoving c_output.c file..."
echo "----------------------------\n"
rm c_output.c
echo "\n\nRunning example_1..."
echo "---------------------\n"
./mycompiler < examples/$answer
