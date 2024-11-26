- Download dasm (https://dasm-assembler.github.io) and Stella (https://stella-emu.github.io/)
- Configure environment variables
- Compile and run with:

dasm *.asm -f3 -v0 -ocart.bin -lcart.lst -scart.sym
stella cart.bin
