#!bin/bash
#
# A while loop runs continuously until a certain condition is met.The following code uses the less then or equal to symbol -li to run a loop until the counter variable x reaches the number 5.
x=1;
while [ $x -le 5 ]; do
  echo "Hello World"
  ((x=x+1))
done
