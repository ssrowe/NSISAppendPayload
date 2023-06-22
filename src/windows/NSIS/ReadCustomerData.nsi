; Include StrLoc function
!include inc\StrLoc.nsi

; ReadCustomerData ( data_prefix -> customer_data )
;   Reads string data appended to the end of the installer EXE.
;   The data must be preceded by a known string.
;   Only last 4Kb of EXE is searched for the prefix
;   (but this can be easily changed, see comment below).
; Inputs:
;   data_prefix (string) -- the string after which customer data begins
; Outputs:
;   customer_data (string) -- the data after the prefix (does NOT include the prefix),
;                             empty if prefix not found
; Author:
;   Andrey Tarantsov <andreyvit@gmail.com> -- please e-mail me useful modifications you make
;   Stephen White <swhite-nsiswiki@corefiling.com>
; Example:
;   Push "CUSTDATA:"
;   Call ReadCustomerData
;   Pop $1
;   StrCmp $1 "" 0 +3
;   MessageBox MB_OK "No data found"
;   Abort
;   MessageBox MB_OK "Customer data: '$1'"
Function ReadCustomerData
  ; arguments
  Exch $R1            ; customer data magic value
  ; locals
  Push $1             ; file name or (later) file handle
  Push $2             ; current trial offset
  Push $3             ; current trial string (which will match $R1 when customer data is found)
  Push $4             ; length of $R1
  Push $5             ; half length of $R1
  Push $6             ; first half of $R1
  Push $7             ; tmp

  FileOpen $1 $EXEPATH r

; change 4096 here to, e.g., 2048 to scan just the last 2Kb of EXE file
  IntOp $2 0 - 4096

  StrLen $4 $R1

  IntOp $5 $4 / 2
  StrCpy $6 $R1 $5


loop:
  FileSeek $1 $2 END
  FileRead $1 $3 $4
  StrCmpS $3 $R1 found

  ${StrLoc} $7 $3 $6 ">"
  StrCmpS $7 "" NotFound
    IntCmp $7 0 FoundAtStart
      ; We can jump forwards to the position at which we found the partial match
      IntOp $2 $2 + $7
      IntCmp $2 0 loop loop
FoundAtStart:
    ; We should make progress
    IntOp $2 $2 + 1
    IntCmp $2 0 loop loop
NotFound:
    ; We can safely jump forward half the length of the magic
    IntOp $2 $2 + $5
    IntCmp $2 0 loop loop

  StrCpy $R1 ""
  goto fin

found:
  IntOp $2 $2 + $4
  FileSeek $1 $2 END
  FileRead $1 $3
  StrCpy $R1 $3

fin:
  Pop $7
  Pop $6
  Pop $5
  Pop $4
  Pop $3
  Pop $2
  Pop $1
  Exch $R1
FunctionEnd

; Trim
;   Removes leading & trailing whitespace from a string
; Usage:
;   Push
;   Call Trim
;   Pop
Function Trim
    Exch $R1 ; Original string
    Push $R2

Loop:
    StrCpy $R2 "$R1" 1
    StrCmp "$R2" " " TrimLeft
    StrCmp "$R2" "$\r" TrimLeft
    StrCmp "$R2" "$\n" TrimLeft
    StrCmp "$R2" "  " TrimLeft ; this is a tab.
    GoTo Loop2
TrimLeft:
    StrCpy $R1 "$R1" "" 1
    Goto Loop

Loop2:
    StrCpy $R2 "$R1" 1 -1
    StrCmp "$R2" " " TrimRight
    StrCmp "$R2" "$\r" TrimRight
    StrCmp "$R2" "$\n" TrimRight
    StrCmp "$R2" "  " TrimRight ; this is a tab
    GoTo Done
TrimRight:
    StrCpy $R1 "$R1" -1
    Goto Loop2

Done:
    Pop $R2
    Exch $R1
FunctionEnd

; ReadCSV
; Uncomment to Enable ReadCSV Function
; !define Enable_ReadCSV

!ifdef Enable_ReadCSV
Function  ReadCSV
        Exch    $1  # input string (csv)
        Push    $2  # substring of $1: length 1, checked for commata
        Push    $3  # substring of $1: single value, returned to stack (below $r2)
        Push    $r1 # counter: length of $1, number letters to check
        Push    $r2 # counter: values found, returned to top of stack
        Push    $r3 # length: to determinate length of current value
        StrLen  $r1  $1
        StrCpy  $r2  0
        StrLen  $r3  $1
    loop:
        IntOp   $r1  $r1 - 1
        IntCmp  $r1  -1  text  done
        StrCpy  $2  $1  1  $r1
        StrCmp  $2  ";"  text
        Goto    loop
    text:
        Push    $r1
        IntOp   $r1  $r1 + 1
        IntOp   $r3  $r3 - $r1
        StrCpy  $3  $1  $r3  $r1
        Pop $r1
        StrCpy  $r3  $r1
        IntOp   $r2  $r2 + 1
        Push    $3
        Exch    6
        Exch    5
        Exch    4
        Exch    3
        Exch
        Goto    loop
    done:
        StrCpy  $1  $r2
        Pop $r3
        Pop $r2
        Pop $r1
        Pop $3
        Pop $2
        Exch    $1
FunctionEnd
!endif

; Push ":" ; divider char
; Push "string1:string2" ;input string
; Call SplitString
; Pop $R0 ;1st part ["string1"]
; Pop $R1 ;rest ["string2|string3|string4|string5"]
Function SplitString
  Exch $R0
  Exch
  Exch $R1
  Push $R2
  Push $R3
  StrCpy $R3 $R1
  StrLen $R1 $R0
  IntOp $R1 $R1 + 1
  loop:
    IntOp $R1 $R1 - 1
    StrCpy $R2 $R0 1 -$R1
    StrCmp $R1 0 exit0
    StrCmp $R2 $R3 exit1 loop
  exit0:
  StrCpy $R1 ""
  Goto exit2
  exit1:
    IntOp $R1 $R1 - 1
    StrCmp $R1 0 0 +3
     StrCpy $R2 ""
     Goto +2
    StrCpy $R2 $R0 "" -$R1
    IntOp $R1 $R1 + 1
    StrCpy $R0 $R0 -$R1
    StrCpy $R1 $R2
  exit2:
  Pop $R3
  Pop $R2
  Exch $R1 ;rest
  Exch
  Exch $R0 ;first
FunctionEnd