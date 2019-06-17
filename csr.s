.section .data
prompt_str:
    .string "\n Данная программа работает с русским и английским алфавитом\n\n"
    .string " Введите исходный шифр: \n(ограничение в 2048 байт)\n"
pstr_end:
    .set STR_SIZE, pstr_end - prompt_str
greet_str:
    .string "Введите ключ в диапозоне +/- 9:\n"
gstr_end:
    .set GSTR_SIZE, gstr_end - greet_str
;//arr1:
;//.byte 0xd0, 0xd1
;//arr2:
;//.byte 0xb1, 0xb2, 0xb3, 0xb4, 0xb5, 0x91, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc, 0xbd, 0xbe, 0xbf, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88, 0x89, 0x8a, 0x8b, 0x8c, 0x8d, 0x8e, 0x8f
.section .bss
buff:
.space 2048	;// зарезервируем х для хранения вводных данных
k:
.space 4
hrnlsh:	;//h
.space 2048	;// зарезервируем х для хранения выводимых данных
.section .text
.globl main
main:
    jmp code
write:
    movl $4, %eax               ;//номера
    movl $1, %ebx               ;//системных вызовов
    movl $prompt_str, %ecx      ;//адрес вывода текста
    movl $STR_SIZE, %edx        ;//длинна текста
    int $0x80
    jmp jmpwr                   ;//прыжок на code:(1)

write1:
    movl $4, %eax               ;//номера
    movl $1, %ebx               ;//системных вызовов
    movl $greet_str, %ecx       ;//адрес вывода текста
    movl $GSTR_SIZE, %edx       ;//длинна текста
    int $0x80
    jmp jmpwr1                  ;//прыжок на code:(3)

write2:
movl $0x0a, %eax	;//дополнительный байт
movl %eax, (%ebx)	;//переноса строки
    movl $4, %eax               ;//номера
    movl $1, %ebx               ;//системных вызовов
    movl $hrnlsh, %ecx          ;//адрес вывода дешифрованного текста
    movl $2048, %edx              ;//длинна текста
    int $0x80

    jmp _exit                   ;//прыжок на exit

read:
    movl $3, %eax               ;//номера
    movl $0, %ebx               ;//системных вызовов
    movl $buff, %ecx            ;//адрес ввода шифра
    movl $2048, %edx              ;//видимо, размер шифра
    int $0x80
    jmp jmprd                   ;//прыжок на code:(2)

read1:
    movl $3, %eax               ;//номера
    movl $0, %ebx               ;//системных вызовов
    movl $k, %ecx          ;//адрес ввода ключа
    movl $4, %edx               ;//видимо, размер ключа
    int $0x80
    jmp korn                  ;//прыжок на code:(4)

code:
    jmp write   ;//просьба ввода исходного шифра
jmpwr:			;//1
    jmp read    ;//считать исходный шифр
jmprd:			;//2
    jmp write1  ;//просьба ввести ключ
jmpwr1:			;//3
    jmp read1   ;//считать ключ
korn:			;//4


key:
xor %eax, %eax
movw k, %ax
cmp $0x2d, %al
je keymn
keypl:
cmp $0, %ax		;//обработчик пустого ввода
je raspr		;//с "0", не знаю зачем

cmp $0x0a, %al		;//обработчик
je raspr		;//пустого ввода с 0a

sub $0x30, %al	;//уменьшаем k
movl %eax, k	;//на $0x30
jmp raspr
keymn:
sub $0x30, %ah
xor %al, %al
sub %ah, %al
xor %ah,%ah
movl %eax, k
raspr:
movl $hrnlsh, %ebx      ;//в %ebx поместили адрес буфера h
movl $buff, %edx        ;//адрес буфера исходного шифра теперь в %edx
;//movl $32, %ecx          ;//подготовка к 32-разовому циклу
xor %eax, %eax
jmp qoo

aoo:
inc %ebx        ;//%ebx++ (адрес готового текста (h) сместился н
inc %edx
probel:
inc %edx        ;//%edc++ (адрес шифрованного текста (buff) смес
inc %ebx
qoo:
movw (%edx), %ax
cmp $0, %ax	;//выход из цикла
je write2	;//когда данные кончатся

cmp $0x20, %al		;//прерывание пробела
jne lf
movb %al, (%ebx)
jmp probel

lf:
cmp $0x0a, %al		;//прерывание 0x0a
jne selectd0d1
movb %al, (%ebx)
jmp probel

selectd0d1:
cmp $0xd1, %al	;//распределение
je eqd1		;//по d0/d1
cmp $0xd0, %al	;//eng/rus
jne eng
eqd0:		;//%al=d0
add k, %ah
cmp $0xb0, %ah
jnb eqd0nxt	;//jge->jnl->jnb

sub $0x20, %ah
add $1, %al
movw %ax, (%ebx)
jmp aoo		;//тут раньше был loop
eqd0nxt:
cmp $0xbf, %ah	;//селектор
jg peqd0
movw %ax, (%ebx);//%ah!>bf
 jmp aoo		;//тут раньше был loop
peqd0:
sub $0x40, %ah
add $1, %al
movw %ax, (%ebx)
 jmp aoo		;//тут раньше был loop 1
eqd1:		;//%al=d1
add k, %ah
cmp $0x80, %ah
jnb eqd1nxt	;//jge->jnl->jnb	--------------
md1:
add $0x40, %ah
sub $1, %al
movw %ax, (%ebx)
jmp aoo		;//тут раньше был loop
eqd1nxt:
cmp $0x8f, %ah
ja peqd1	;//------------было g
movw %ax, (%ebx)
jmp aoo			;//тут раньше был loop
peqd1:
sub $1, %al
add $0x20, %ah
movw %ax, (%ebx)
 jmp aoo		;//тут раньше был loop
eng:		;//обработчик английского текста
add k, %al
cmp $0x7a, %al
ja engb

cmp $0x61, %al
jb engs

movb %al, (%ebx)
jmp probel
engs:
add $0x1a, %al
movb %al, (%ebx)
jmp probel
engb:
sub $0x1a, %al
movb %al, (%ebx)
jmp probel

_exit:
    movl $1, %eax
    movl $0, %ebx
    int $0x80

