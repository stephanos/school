#include <stdio.h>


/* Variablen für Zahlen */
short z1, z2;

/* Externe Assembler-Routine */
extern short ggt(void);


/*------------------------------------------------------------------------------
 Hauptfunktion
------------------------------------------------------------------------------*/
int main(int argc, char** argv)
{
    short t = 0;

    /* Zahlen abfragen */
    printf("Berechnung des GGT zweier Zahlen:\nZahl 1: ");
    scanf("%i", &z1);

    printf("Zahl 2: ");
    scanf("%i", &z2);
  
    /* ggt ausrechnen und ausgeben */
    t = ggt();
	printf("\n -> GGT(%i, %i) = %i\n", z1, z2, t);
	
	#ifdef WIN32
	scanf("%i", &t);
	#endif

	return 0;
}
