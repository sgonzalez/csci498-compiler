#include <iostream>

using namespace std;

int main(int argc, char* argv[]) {

	if (argc != 2){
		cout << "Error: must give filename" << endl;
		return 0;
	}

	char* filename = argv[1];

	return 0;
}

