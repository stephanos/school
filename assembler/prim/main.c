/***********************************
 * © Stephan Behnke
 * Homepage: www.tcltk.de.vu
 * E-Mail: stephan.behnke@gmx.net
 ***********************************/

/* PS: Für den Befehl sqrt() den Paramter -lm an gcc anfügen */

#include <time.h>
#include <stdlib.h>
#include <stdio.h>


/* Variable für Zahl */
unsigned long z, bis, von;

/* Variablen für Zeitmessung */
clock_t start, ende;


/* Externe Assembler-Routine */
extern unsigned long prim(void);

/* Interne Routinen */
void        a_prim      ();
void        c_prim      ();
clock_t     zeit        (clock_t, clock_t, unsigned long, const char[]);


/*------------------------------------------------------------------------------
 Hauptfunktion
------------------------------------------------------------------------------*/
int main(long argc, char** argv)
{
    /* Start (ungerade!) */
    von = 5;
    
    printf("**** Vergleich von Assembler und C mittels Primzahlen ****");
    
    do {
        printf("\n\nGeben Sie eine Grenze zur Berechnung ein: ");
        scanf("%d", &bis);
        printf("\n");

        /* Berchnungen starten */
        a_prim();
        c_prim();
    
    } while(bis>0);

	return 0;
}


/*------------------------------------------------------------------------------
 Assembler-Routine
------------------------------------------------------------------------------*/
void a_prim()
{
    start = clock();
	   z = prim();
	ende = clock();

    /* Zeit ausgeben */
    zeit(start, ende, z, "Assembler");
}


/*------------------------------------------------------------------------------
 C-Routine
------------------------------------------------------------------------------*/
void c_prim()
{
    register short b;
	register unsigned long i;
	register unsigned long iTeiler  = 0;
	register unsigned long iZaehler = 0;
	register unsigned long iWurzel;

    start = clock();

    /* Zahlen durchgehen */
	for(i = von; i<bis; i+=2)
	{
        b = 1;
        iWurzel = sqrt(i);
	
        /* Teiler durchgehen */
        for(iTeiler=3; iTeiler<=iWurzel; iTeiler+=2)
        {
            if(!(i%iTeiler))
            {
                b = 0;
                break;
            }
        }

        if(b)
            iZaehler++;
	}
	
	ende = clock();
	
	/* Zeit ausgeben */
	zeit(start, ende, iZaehler, "C");
}


/*------------------------------------------------------------------------------
 Ausgabefunktion des Ergebnisses
------------------------------------------------------------------------------*/
clock_t zeit(clock_t start, clock_t ende, unsigned long anzahl, const char sprache[])
{
    clock_t zeit = ende - start;

    #ifndef WIN32
        zeit /= 1000;
    #endif

    printf("    %i Primzahlen in %i ms mit %s gefunden\n", anzahl, zeit, sprache);
}
