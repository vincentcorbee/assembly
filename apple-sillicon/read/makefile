ENTRYPOINT = main
FILE = read

main: $(FILE).o
	ld -o $(FILE) ${FILE}.o -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -e $(ENTRYPOINT) -arch arm64
main.o: $(FILE).s
	as -o $(FILE).o $(FILE).s -g