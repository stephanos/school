#include <iostream>
#include <stdlib.h>
#include <stdio.h>

using namespace std;

// Iterationsfunktion
inline float f(float* a, float* x) { return (*a**x*(1-*x)); }

int main(int argc, const char** argv)
{
    cout<<"[";

    // Argumente
    float start        = (-1)*(atof(argv[1]));
    float ende         = (-1)*(atof(argv[2]));
    float schritte     = (-1)*(atof(argv[3]));
    int   iterationen  = (-1)*(atoi(argv[4]));
    int   genauigkeit1 = (-1)*(atoi(argv[5]));
        
    // Variablen
    int einschwingen = 200;
    int vergleich    = 1;

    for (int i=0; i<genauigkeit1; i++) {vergleich*=10;}

    int   genauigkeit2 = 1;
    float temp         = schritte;

    while (temp<1) {temp*=10; ++genauigkeit2;}

    float ergebnisse[iterationen];
    float x;
    
	// Werte berechnen
	for (float a=start; a<ende; a+=schritte) {
 	    
        // Zurücksetzen
		for (int i=1; i<=iterationen; i++) {ergebnisse[i]=0;}
		x = 0.01;

		// Einschwingen
		for (int i=1; i<=einschwingen; i++) {x = f(&a, &x);}

		// Berechnen
		for (int i=1; i<=iterationen; i++) {
            ergebnisse[i] = f(&a, &x);
            x = ergebnisse[i];
        }

		// Ausgabe		
		for (int i=1; i<=iterationen; i++) {      
            if (ergebnisse[i]) {

                 if(i!=1 || a!=start) {cout<<",";}

                 cout.precision(genauigkeit2);
                 cout<<"["<<a<<",";
                 cout.precision(genauigkeit1);
                 cout<<ergebnisse[i]<<"]";

                 for (int j=i+1; j<=iterationen; j++) {
                      if (abs(ergebnisse[i]-ergebnisse[j])*vergleich<1)
                         ergebnisse[j]=0;       
                 }
            }         
		}
	}
	cout<<"]";
}
