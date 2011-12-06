/***********************************
 * © Stephan Behnke
 * Homepage: www.tcltk.de.vu
 * E-Mail: stephan.behnke@gmx.net
 ***********************************/

#include <time.h>
#include <stdlib.h>
#include <stdio.h>


/* Variablen für Approximationen */
double  w_pi=0, w_e=0;

/* Variablen für Zeitmessung */
clock_t start, ende;


/* Externe Assembler-Routine */
extern double e(void);
extern double pi(void);

/* Interne Routinen */
void        a_pi        ();
void        a_e         ();
clock_t     zeit        (clock_t, clock_t, double, const char[]);


/*------------------------------------------------------------------------------
 Hauptfunktion
------------------------------------------------------------------------------*/
int main(long argc, char** argv)
{
    char zahl;

    do {
        zahl = 'x';

        /* Abfrage */
        do {
            printf("\n\n\n** Ermitteln von Naeherungswerten fuer die Kreiszahl sowie die Eulersche Zahl **");
            printf("\nGeben Sie die zu berechnende Zahl ein, pi bzw. e: ");
            scanf("%s", &zahl);
        } while(zahl != 'p' && zahl != 'e');

        /* Berechnung */
        if(zahl == 'p')
            a_pi();
        else
            a_e();

    }while(1);

	return 0;
}


/*------------------------------------------------------------------------------
 Kreiszahl - Assembler-Routine
------------------------------------------------------------------------------*/
void a_pi()
{
    start = clock();
	   w_pi = pi();
	ende = clock();

    /* Zeit ausgeben*/
    zeit(start, ende, w_pi, "Kreiszahl");
}


/*------------------------------------------------------------------------------
 Eulersche Zahl - Assembler-Routine
------------------------------------------------------------------------------*/
void a_e()
{
    start = clock();
	   w_e = e();
	ende = clock();

    /* Zeit ausgeben*/
    zeit(start, ende, w_e, "Eulersche Zahl");
}


/*------------------------------------------------------------------------------
 Ausgabefunktion des Ergebnisses
------------------------------------------------------------------------------*/
clock_t zeit(clock_t start, clock_t ende, double wert, const char zahl[])
{
    clock_t zeit = ende - start;

    #ifndef WIN32
        zeit /= 1000;
    #endif

    printf("\n -> %s wurde in %i ms mit der Naeherung %f bestimmt\n", zahl, zeit, wert);
}
