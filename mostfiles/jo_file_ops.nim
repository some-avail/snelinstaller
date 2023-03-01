
# status: working
# source-machine: ndell-mint19
# source-scripts: insertTextInFIle
# author: joris bollen
# script-type: nim
#	birth-date      prog.name				version   update-machine
#	2020-02-25      jo_file_ops.nim     see var   ndell-mint19



import strutils
import os

var versionfl:float = 1.1



proc old_searchNthSubInString(stringst,subst:string,occurit:int, 
            directionst:string = "forward"): int =

  # UNIT INFO
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


proc searchNthSubInString(stringst,subst:string,occurit:int, 
            directionst:string = "forward",
            startposit:Natural=0): int =

  # UNIT INFO
  # search forward or backward for the occurence of a substring 
  # in a string and return its position (starting from from startposit)

  #echo "================================="
  #echo "starting searchNth..."
  ##echo "stringst = " & stringst
  #echo "subst = " & subst
  #echo "occurit = " & $occurit
  #echo "directionst = " & directionst
  #echo "startposit = " & $startposit
  
  var positionit:int
  var startna:Natural = 0
  var lastna: Natural = len(stringst)
  
  if startposit != 0:
    startna = startposit
    lastna = startposit
  
  for passit in 1..occurit:
  
    if directionst == "forward":
      positionit = find(stringst, subst, startna)
    elif directionst == "backward":
      positionit = rfind(stringst, subst, 0, lastna)
    #echo "positionit = " & $positionit
    if positionit >= 0:
      startna = positionit + 1
      if positionit >= 1:
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


proc getValueFromKey*(allargsq:seq[string], separatorst, keyst:string): string =
  # UNIT INFO
  # Retrieve a value from a key-value-sequence based on key and
  # separator
  var ikeyst, ivaluest:string
  
  for item in allargsq:
    (ikeyst,ivaluest) = item.split(separatorst)
    if ikeyst == keyst:
      return ivaluest
  
  
  
proc insertTextInFile*(targetfilepathst, locating_methodst, 
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
  
  # quit if file non-existant
  if not existsFile(targetfilepathst):
    echo "\pFollowing file does not exist: " & targetfilepathst
    echo "Exiting function insertTextInFile..."
    quit(QuitSuccess)
  
  # backup the target-file
  backupfilepathst = backupFile(targetfilepathst)
   
  # open the backup-file
  if open(backupfile, backupfilepathst): 
    try:
      filets = readAll(backupfile)
      filecontentst = $filets
      #echo filecontentst

    except:
      echo "=========er ging iets mis=========="
      raise
  else:
    echo "Could not open target-file!"

  defer: backupfile.close()
  
  # go to the file-location where to insert line(s)
  positionit = searchNthSubInString(filecontentst, locating_stringst, occurit,
                    directionst)

  echo "Locating-string found at: " & $positionit
  
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

  #echo filecontentst
  
  writeFile(targetfilepathst, filecontentst)

  
  
proc alterTextFile*(operationst, targetfilepathst, locating_stringst:string, 
          directionst:string, occurit: int,
          line_orientationst: string, operationparamsq:seq[string]) =

  #[
  UNIT INFO:
  Alter a text-file (targetfile) by means of an operation.
  Use a locating-string to determine the locating-point. The 
  line-orientation indicates before, on or after the 
  location-point that the operation must be done.
  Loc-string is found by searching in certain direction (forward or
  backward) and determining the wished occurence of the 
  search-string.
  Operations:
  insertions-params; a sequence of strings that form the new lines.
  deletions-params: a number of lines to be erased.
  replacement-params: strings to-replace and replace-to
  
  ]#

  var 
    backupfile: File
    backupfilepathst: string
    positionit: int
    filets: TaintedString
    filecontentst:string
    insertionpointit:int
  
  # quit if file non-existant
  if not existsFile(targetfilepathst):
    echo "\pFollowing file does not exist: " & targetfilepathst
    echo "Exiting function insertTextInFile..."
    quit(QuitSuccess)

  # backup the target-file
  backupfilepathst = backupFile(targetfilepathst)
  
  # open the backup-file for reading
  if open(backupfile, backupfilepathst): 
    try:
      filets = readAll(backupfile)
      filecontentst = $filets
      #echo filecontentst

    except:
      echo "=========er ging iets mis=========="
      raise
  else:
    echo "Could not open target-file!"

  defer: backupfile.close()
  
  # go to the file-location where to insert line(s)
  positionit = searchNthSubInString(filecontentst, locating_stringst, occurit,
                    directionst)

  echo "Locating-string found at: " & $positionit
  
  
  # Full line-operations expect the locating-string starting at
  # the start of the sentence.
  var startposit:int
  var endposit:int  
  
  
  case operationst    # concerning lines
  of "insertions":
  
    case line_orientationst
    of "before":
      insertionpointit = searchNthSubInString(filecontentst, "\p",
              1, "backward", positionit) + 1      

      for elem in operationparamsq:
        filecontentst.insert(elem & "\p", insertionpointit)
        insertionpointit += len(elem) + 1

    of "on":  # single prepend; does not go to the front!
      filecontentst.insert(operationparamsq[0], positionit)
  
    of "after":
      insertionpointit = searchNthSubInString(filecontentst, "\p",
              1, "forward", positionit)         
      for elem in operationparamsq:
        filecontentst.insert("\p" & elem, insertionpointit)
        insertionpointit += len(elem) + 1
    else: discard

  of "deletions":
    
    var numberoflinesit:int = parseint(operationparamsq[0])

    case line_orientationst
    of "on":
      #echo "orient = on"
      startposit = searchNthSubInString(filecontentst, "\p",
              1, "backward", positionit) + 1      
      endposit = searchNthSubInString(filecontentst, "\p",
            numberoflinesit, "forward", positionit)
      filecontentst.delete(startposit, endposit)
      
    of "after":
      #echo "orient = after"
      startposit = searchNthSubInString(filecontentst, "\p",
            1, "forward", positionit) + 1
      echo "startposit =" & $startposit
      endposit = searchNthSubInString(filecontentst, "\p",
            numberoflinesit + 1, "forward", positionit)
      echo "endposit = " & $endposit
      filecontentst.delete(startposit, endposit)
      
    of "before":
      #echo "orient = before"
      endposit = searchNthSubInString(filecontentst, "\p",
              1, "backward", positionit)
      startposit = searchNthSubInString(filecontentst, "\p",
            numberoflinesit + 1, "backward", positionit) + 1
      filecontentst.delete(startposit, endposit)


  of "replacement":
  
    #echo "entering replacement"
    var currentlinest:string
    var replacedlinest: string
    var to_replacest: string = operationparamsq[0]
    var replace_tost: string = operationparamsq[1]
  
  
    # seek previous line-marker
    startposit = searchNthSubInString(filecontentst, "\p",
            1, "backward", positionit) + 1
    #echo "startposit = " & $startposit
    
    # seek next line-marker
    endposit = searchNthSubInString(filecontentst, "\p",
            1, "forward", positionit)
    #echo "endposit = " & $endposit
    # copy the current line
    currentlinest = filecontentst[startposit .. endposit]
    #echo "currentlinest = " & currentlinest
    # delete the current line
    filecontentst.delete(startposit, endposit)
    #echo "to-repl =" & to_replacest
    #echo "rep-to =" & replace_tost
    # replace the current line
    replacedlinest = currentlinest.replace(to_replacest, replace_tost)
    #echo "repl.linest = " & replacedlinest
    # insert the replaced line
    filecontentst.insert(replacedlinest, startposit)


  #echo filecontentst
  
  writeFile(targetfilepathst, filecontentst)

echo "jo_file_ops " & $(versionfl) & " is called..."     

# test searchNthSubInString
#var posit : int = 0
#var stringst: string = "de-kat-is-de-kattigste-kat-van-de-wereld"
#var subst: string = "kat"
#posit = searchNthSubInString2(stringst,subst, 2, "backward",22)
#echo "Position = " & $posit
#-----------end test----


#echo getValueFromKey(@["arg1;;aap", "arg2;;noot", "arg3;;mies"], ";;","arg2")

#insertTextInFile("some_config.txt", "before", "hieronder",
          #1, "backward", @["aap","noot","mies"])
#
#
#echo "\n=====Gelukt====="

#operationst, targetfilepathst, locating_stringst:string, 
          #directionst:string, occurit: int,
          #line_orientationst: string, operationparamsq:seq[string]

#alterTextFile("insertions", "some_config.txt", "opdracht", 
          #"forward", 2, "on", @["winstgevende "])

#alterTextFile("deletions", "some_config.txt", "winst", 
          #"forward", 1, "before", @["3"])

#alterTextFile("deletions", "some_config.txt", "12", 
          #"forward", 1, "on", @["2"])

#alterTextFile("replacement", "some_config.txt", "opdracht", 
          #"forward", 2, "on", @["de","een"])
