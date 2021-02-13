    ;Archivo:	    main.s
    ;Dispositivo:   PIC16F887
    ;Autor:	    Margareth Vela
    ;Compilador:    pic-as(v2.31), MPLABX V5.40
    ;
    ;Programa:	    Sumador de 4 bits
    ;Hardware:	    LEDs en puerto B, C y D, & push buttons en puerto A y C
    ;
    ;Creado: 09 feb, 2021
    ;Última modificación: 10 feb, 2021
    
PROCESSOR 16F887
#include <xc.inc>

; configuration word 1
CONFIG FOSC=XT	    //Oscilador externo 
CONFIG WDTE=OFF	    //WDT disabled (reinicio dispositivo del pic)
CONFIG PWRTE=ON    //PWRT enabled (espera de 72ms al iniciar)
CONFIG MCLRE=OFF    //El pin de MCLR se utiliza como I/O
CONFIG CP=OFF	    //Sin protección de código
CONFIG CPD=OFF	    //Sin protección de datos

CONFIG BOREN=OFF    //Sin reinicio cuándo el voltaje de alimentacion baja de 4v
CONFIG IESO=OFF	    //Reinicio sin cambio de reloj de interno a externo
CONFIG FCMEN=OFF    //Cambio de reloj externo a interno en caso de fallo
CONFIG LVP=ON	    //programacion en bajo voltaje permitida

;configuration word 2
CONFIG WRT=OFF	    //Protección de autoescritura por el programa desactivada
CONFIG BOR4V=BOR40V //Reinicio abajo de 4V, (BOR21V=2.1V)
    
;-------------------------------------------------------------------------------
; Vector Reset
;-------------------------------------------------------------------------------
PSECT code, delta=2, abs
ORG 0x0000
resetvector:
    PAGESEL main
    goto main

;-------------------------------------------------------------------------------
; Código Principal 
;-------------------------------------------------------------------------------
PSECT code, delta=2, abs
ORG 0x000A
main:
    bsf STATUS, 5 ;banco 11
    bsf STATUS, 6
    clrf ANSEL    ;pines digitales
    clrf ANSELH
   
    bsf STATUS, 5 ;banco 01
    bcf STATUS, 6
    
    movlw 0xF0
    movwf TRISB	;port B (4 bits entrada, 4 bits salidas)
    movlw 0xF0
    movwf TRISC	;port C (4 bits entrada, 4 bits salidas)
    clrf  TRISD	;port D (salidas)
   
    bcf STATUS, 5 ;banco 00
    bcf STATUS, 6
    
    clrf PORTB ;comenzar el primer contador en 0
    clrf PORTC ;comenzar el segundo contador en 0
    clrf PORTD ;comenzar la suma en 0
    
loop:
    btfsc   PORTA, 0 ;se presiona el push
    call    inc_push1 
    btfsc   PORTA, 1 ;se presiona el push
    call    dec_push2
    btfsc   PORTC, 5 ;se presiona el push
    call    inc_push3
    btfsc   PORTC, 6 ;se presiona el push
    call    dec_push4
    btfsc   PORTC, 7 ;se presiona el push
    call    suma
    goto    loop
    
inc_push1:
    btfsc   PORTA, 0 ;antirebote
    goto    $-1
    incf    PORTC, F ;se incrementa el primer contador
    return
dec_push2:
    btfsc   PORTA, 1 ;antirebote
    goto    $-1
    decf    PORTC, F ;se decrementa el primer contador 
    return
inc_push3:
    btfsc   PORTC, 5 ;antirebote
    goto    $-1
    incf    PORTB, F ;se incrementa el segundo contador
    return
dec_push4:
    btfsc   PORTC, 6 ;antirebote
    goto    $-1
    decf    PORTB, F ;se decrementa el segundo contador
    return
suma:
    btfsc   PORTC, 7 ;antirebote
    goto    $-1
    movf    PORTC, 0 ;mover el valor del primer contador al registro w
    addwf   PORTB, 0 ;sumar el valor del registro w con el segundo contador
    movwf   PORTD    ;mostrar resultado en puerto D
    return
end