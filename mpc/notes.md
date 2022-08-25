# EMP Design Lecture Notes
By David

## Architecture
To learn more about MPC compilers, see survey paper: Purpose Compilers for Secure MPC

### Circuit Builders
EMP libraries are a collection of Circuit Builders:

example) Bit class
    Overload &, create AND gate

example) Integer class, collection of bits
    Overload the + operator
    Int + Int creates a boolean circuit
    Overload comparison, outputs a bit, Bit b = (Int)i < (Int)j;

example) Circuit File class, reads a file into a circuit
    Can take an Integer and decompose into Bits and write to file

### Circuit Execution
generic pure virtual interface says what to do with each gate
"What computation for individual gates"

plain execution
no cryptography
does evaluation of a plain text circuit in a Circuit File

Half Gates Evaluator / Generator

### Protocol Execution
"What communication is done as part of the protocol"

plain protocol
no cryptography
runs the communication for a plain text circuit

semi honest evaluator / generator

covert evaluator / generator

### Control Flow
Set up a specific Circuit Execution and global Protocol Execution.

for example in the plain protocal/circuit execution
Create all the inputs
    on construction of Bit, the Protocal Execution object writes to a file
Create the computation (like Bit & Bit)
    when Bit+Bit is executed, behind the scenes calls the Circuit Execution object and writes to file
Call reveal on outputs
    Do not call reveal on intermediate steps

for example in the semihonest protocal/circuit execution
Set up communication with NetIO
    This is a "secure" communication channel between Alice and Bob
    Alice (the generator) is the server, Bob is the client
Create all the inputs
    on construction of Bit, the Protocal Execution object does actual communication with NetIO
    behind the scenes PE object does OT on Bob's inputs, Alice's inputs are sent straight over
Create the computation (like Bit & Bit)
    when Bit+Bit is executed, behind the scenes calls the Circuit Execution object
    On Alice's side, CE object sends circuit material
    On Bob's side, the Circuit Execution oject does the cryptographic evaluation of the circuit material.
    Circuit material is piped over the network as execution happens
Call reveal on outputs
    Does OT behind the scenes with Protocol Exectuion object to transfer ouputs



plain text file explanation
3 5
1 1 1

three gates, 5 wires
alice has one input, bob has one, one ouput


2 1 0 1 2 AND

AND gate has 2 inputs, 1 output, 0 is gate ID of input A, 1 is gate ID of input B, 2 is this gate ID
