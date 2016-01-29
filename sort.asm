extern printf
extern malloc
extern free
extern strlen
extern atoi

section .text

int_format: db "  %d", 0
newline: db 10, 0


; sortArray
; 1: int* to array, 2: int length of array
; returns void
sortArray:
  push ebx
  
  mov eax, [esp + 8]
  xor ecx, ecx
  
  mov ebx, [esp + 12]
  sub ebx, 1

.forward:
  mov edx, [eax + 4 * ecx]

.forward_loop:
  cmp ecx, ebx
  je .done

  mov esi, [eax + 4 * ecx + 4]
  
  cmp edx, esi
  jge .backward_loop
  
  inc ecx
  mov edx, esi
  jmp .forward_loop
  
.backward_loop:
  push ecx
  
.continue_backwards:
  mov [eax + 4 * ecx + 4], edx
  
  dec ecx
  cmp ecx, -1
  je .at_first
  
  mov edx, [eax + 4 * ecx]
  
  cmp edx, esi
  jg .continue_backwards
  
  ;back to forward
  mov [eax + 4 * ecx + 4], esi
  pop ecx
  inc ecx
  jmp .forward
  
.at_first:
  mov [eax], esi
  pop ecx
  inc ecx
  jmp .forward
  
.done:
  pop ebx
  ret


%macro check_if_digit 1
  cmp %1, '0'
  setge al
  shl eax, 8
  cmp %1, '9'
  setle al
  mov %1, al
  shr eax, 8
  and %1, al
%endmacro


; isInteger
; 1: const char*
; return 1 if string contains integer, else 0
isInteger:
  push ebx
  
  push dword [esp + 8]
  call strlen
  pop ebx
  xor ecx, ecx
  
  cmp eax, 1
  je .loop1
  
  push eax
  mov dl, [ebx]
  cmp dl, '-'
  sete al
  shl eax, 8
  check_if_digit dl
  shr eax, 8
  or dl, al
  pop eax
  
  test dl, dl
  jz .return_false
  
  inc ecx
  
.loop1:
  push eax
  mov dl, [ebx + ecx]
  check_if_digit dl
  pop eax
  
  test dl, dl
  jz .return_false
  
  inc ecx
  cmp ecx, eax
  jne .loop1
  
.return_true:
  pop ebx
  mov eax, 1
  ret
  
.return_false:
  pop ebx
  xor eax, eax
  ret


; printArray
; 1: int* to array of values, 2: int length of arrays
; return void
printArray:
  push ebx
  mov ebx, [esp + 8]
  mov eax, [esp + 12]
  sub esp, 16
  
  test eax, eax
  jz .end
  
  xor ecx, ecx
  mov [esp + 8], eax
  mov [esp + 12], ecx
  
  mov dword [esp], int_format
.loop:
  mov ecx, [esp + 12]
  mov ecx, [ebx + 4 * ecx]
  mov [esp + 4], ecx
  call printf
  inc dword [esp + 12]
  mov ecx, [esp + 12]
  cmp ecx, [esp + 8]
  jne .loop
  
.end:
  push newline
  call printf
  add esp, 4

  add esp, 16
  pop ebx
  ret


global main
main:
  push ebx
  
  ;exit if no command-line arguments
  mov eax, [esp + 8]
  dec eax
  jz .end
  
  ;allocate memory
  push eax
  imul eax, 4
  push eax
  call malloc
  add esp, 4
  pop ecx
  push eax
  
  mov ebx, [esp + 16]
  
  xor edx, edx
  
  sub esp, 12
  mov [esp + 8], edx
  
.read_loop:
  dec ecx
  
  mov [esp + 4], ecx
  mov ecx, [ebx + 4 * ecx + 4]
  mov [esp], ecx
  call isInteger
  test eax, eax
  jz .not_integer
  
  call atoi
  mov ecx, [esp + 12]
  mov edx, [esp + 8]
  mov [ecx + 4 * edx], eax
  inc edx
  mov [esp + 8], edx
  
.not_integer:
  mov ecx, [esp + 4]
  test ecx, ecx
  jnz .read_loop
  add esp, 12
  
  ;sort and print the integers
  push edx
  push dword [esp + 4]
  call sortArray
  call printArray
  add esp, 8
  
  call free
  add esp, 4

.end:
  pop ebx
  xor eax, eax
  ret
