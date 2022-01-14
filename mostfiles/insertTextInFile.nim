
# status: working
# source-machine: ndell-mint19
# source-scripts: none
# author: joris bollen
# script-type: nim
#	birth-date            prog.name				version     update-machine
#	2020-02-25            insertTextInFile.nim  see var     ndell-mint19


# script-operation main-function:
#[
    Insert lines of text (insertionssq)in a text-file (targetfile).
    Use a locating-string to determine the insertion-point. The 
    locating-method indicates before or after the loc-string-point.
    Loc-string is found by searching in certain direction (forward or
    backward) and determining the wished occurence of the 
    search-string.
]#

import strutils
import os

var versionfl:float = 1.0


proc searchNthSubInString(stringst,subst:string,occurit:int, 
                        directionst:string = "forward"): int =
# UNIT INFO:
# search forward or backward for the occurence of a substring 
# in a string and return its position (starting from 0)

    var positionit:int = 0
    var startna:Natural = 0
    var lastna: Natural = len(stringst)
    
    for passit in 1..occurit:
    
        if directionst == "forward":
            positionit = find(stringst, subst, startna)
        elif directionst == "backward":
            positionit = rfind(stringst, subst, 0, lastna)

        if positionit >= 0:
            startna = positionit + 1
            lastna = positionit - 1
        elif positionit == -1:
            return -1
    return positionit

proc backupFile(filepathst:string): string =
    # copy the given file to one with the suffix .bak
    
    var 
        fulldirst: string
        filest:string
        bakfilest:string
        bakfilepathst:string
    
    (fulldirst, filest) = splitPath(filepathst)
    bakfilest = filest & ".bak"
    bakfilepathst = joinPath(fulldirst, bakfilest)
    copyFile(filepathst,bakfilepathst)
    return bakfilepathst


proc insertTextInFIle(targetfilepathst, locating_methodst, 
                    locating_stringst:string, occurit: int,
                    directionst:string,
                    insertionssq:seq[string]) =
    #[
    UNIT INFO:
    Insert lines of text (insertionssq)in a text-file (targetfile).
    Use a locating-string to determine the insertion-point. The 
    locating-method indicates before or after the loc-string-point.
    Loc-string is found by searching in certain direction (forward or
    backward) and determining the wished occurence of the 
    search-string.
    ]#
                    
    var 
        backupfile: File
        backupfilepathst: string
        positionit: int
        filets: TaintedString
        filecontentst:string
        insertionpointit:int
        
    # backup the target-file
    backupfilepathst = backupFile(targetfilepathst)
     
    # open the backup-file
    if open(backupfile, backupfilepathst): 
        try:
            filets = readAll(backupfile)
            filecontentst = $filets
            echo filecontentst

        except:
            echo "=========er ging iets mis=========="
            raise
    else:
        echo "Could not open target-file!"

    defer: backupfile.close()
    
    # go to the file-location where to insert line(s)
    positionit = searchNthSubInString(filecontentst, locating_stringst, occurit,
                                        directionst)
    echo positionit
    
    case locating_methodst
    of "before":
        insertionpointit = positionit        
        for elem in insertionssq:
            filecontentst.insert(elem & "\p", insertionpointit)
            insertionpointit += len(elem) + 1
            
    of "after":
        insertionpointit = positionit + len(locating_stringst)
        for elem in insertionssq:
            filecontentst.insert("\p" & elem, insertionpointit)
            insertionpointit += len(elem) + 1
    else: discard

    echo filecontentst
    
    writeFile(targetfilepathst, fileContentst)


#var posit : int = 0
#var stringst: string = "de-kat-is-de-kattigste-kat-van-de-wereld"
#var subst: string = "kat"
#
#posit = searchNthSubInString(stringst,subst, 3, "backward")
#echo "Position = " & $posit

insertTextInFIle("some_config.txt", "before", "hieronder",
                    1, "backward", @["aap","noot","mies"])

echo "\n=====Gelukt====="
    