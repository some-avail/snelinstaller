
# status: working
# source-machine: ndell-mint19
# source-scripts: none
# author: joris bollen
# script-type: nim
#	birth-date      prog.name				version   update-machine
#	2020-02-13      snel_installer.nim  see var   ndell-mint19


# script-operation:
# simple installer of files
# uses installation-definition-file in which sources and targets are placed
# ---------------------------------------------------
# Format of the installation-definition-file (def-file):
# it contains multiple blocks starting with specific tasks:
# DIRECTORIES TO CREATE
# TARGET-LOCATION AND SOURCE-FILES TO COPY
# EDIT FILE (ADD, DELETE, REPLACE LINES)
# EXECUTE SHELL-COMMANDS - IN ORDER


# Please consult the def-file for addional info.
# ----------------------------------------------------

# ADAP HIS
# implement exception-handling
# substitute another separator-line between blocks instead of empty line
  # like >----------------------------------<
  # so that empty lines can be added to config files
# add command-section
# add an arguments-line,for:
  # linux:set_exe
# add one comment-line per block
# extend EDIT-block with additional options:
  # remove a line
  # prepend a string before a line (like commenting)
  # replace a line


# ADAP NOW


# ADAP FUT
# naming of entries in the defile, like:
  # dir===/somdir
  # line_orientatien==="after"
# functionalize main-code
# implement a dry run mode (instead of def-file-validation)
  # dry run means testing the def-file without making changes.
  # it is not a full validation but it can find some definition-faults.
# create a higher loop in which multiple packages can be installed.
  # use a higer folder for:
    # executable 
    # and higher install-order-config.txt
# add permissions-section
# reverse order = removal of installation
# add def-file validation
# conditional operations
  # create a block for test-variables which can 
  # later be used for conditional operations

#=============================================


var 
  versionfl:float = 2.2
  for_realbo: bool = true


# import std/[os, strutils, parseopt, paths]
import std/[os, strutils, parseopt, tables]
import jo_file_ops



proc yes(question: string): bool =
  echo question, " (y/n)"
  while true:
    case readLine(stdin)
    of "y", "Y", "yes", "Yes": return true
    of "n", "N", "no", "No": return false
    else: echo "Please be clear: yes or no"
  


proc confirmInstall(): bool =

  # report status and ask followup-action
  echo "\n==============================="
  echo "Program Snel_Installer " & $(versionfl) & " is running..."     
  echo "Make sure to run snel_installer with sufficient rights."

  if yes("Do you want to continue?"):
    echo "continuing..."
    result = true

  else:
    echo "aborting Snel_Installer...goodbye!"
    # quit(QuitSuccess)     # no longer needy
    result = false


proc expandVars(inputst, varsepst: string, variableta: var Table[string, string]): string = 
  #[
    Substitute in inputst all the vars surrounded by varsepst based on the
    key-value-list in variableta 
  ]#

  var 
    fullkeyst: string
    tekst = inputst

  for keyst, valst in variableta:
    fullkeyst = varsepst & keyst & varsepst
    if fullkeyst in tekst:
      tekst = tekst.replace(fullkeyst, valst)

  result = tekst



proc installFromDef(install_def_filest: string, first_callbo: bool = true): bool = 
  #[
    Install files based on the definition passed as argument in the program-call.
  ]#


  var
    def_filenamest: string = install_def_filest
    completionbo: bool = false
    myfile: File
    blockheadar: array[5, string] = [
        "VARIABLES TO SET", 
        "DIRECTORIES TO CREATE",
        "TARGET-LOCATION AND SOURCE-FILES TO COPY",
        "EDIT FILE (ADD, DELETE, REPLACE LINES)",
        "EXECUTE SHELL-COMMANDS - IN ORDER"]
    blockphasest: string = ""
    blocklineit: int
    blockseparatorst = ">----------------------------------<"
    targetdirpathst: string
    targetfilepathst: string
    sourcedirpathst: string
    sourcefilepathst: string
    sourcefilest: string
    editfileprops:array[6,string]
    ops_paramsq:seq[string] = @[]
    lastline: string
    all_argst: string
    argumentsq: seq[string] = @[]
    linux_setexe: bool= false
    linux_use_sudo: bool = false
    varsepst: string
    varsta = initTable[string, string]()
    varlinesq: seq[string] = @[]
    pathst: string
    

  echo "\pCurrent directory: ", getAppDir()

  echo "\pTrying to open file: " & def_filenamest & "\p"

  if open(myfile, def_filenamest):    # try to open the def-file
    try:
      # validate the def-file (skip for now)

      # walk thru the lines of the file
      echo "\n=====Begin processing===="
      for line in myfile.lines:
        lastline = line
        
        # check for block-header
        if line in blockheadar:
          blockphasest = line
          echo "\p" & blockphasest
          blocklineit = 0
        elif line != "":
        
          blocklineit += 1
          if line != blockseparatorst:   # block-separating string

            if blockphasest == "VARIABLES TO SET":
              if blocklineit == 1:  # comment-line
                discard
              elif blocklineit == 2:  # read the separator-string
                # handle arguments
                all_argst = line.split("---")[1]
                varsepst = all_argst.split("=")[1]
              else:
                varlinesq = line.split("=")
                varsta[varlinesq[0]] = varlinesq[1]
                echo line
              
            elif blockphasest == "DIRECTORIES TO CREATE":
              if blocklineit == 1:  # comment-line
                discard
              elif blocklineit == 2:
                # handle arguments
                discard
              else:
                pathst = expandTilde(line)
                pathst = expandVars(pathst, varsepst, varsta)
                if not existsOrCreateDir(pathst):   # proc creates only when non-existent
                  echo "creating directory: " & pathst

            elif blockphasest == "TARGET-LOCATION AND SOURCE-FILES TO COPY":

              if blocklineit == 1:  # comment-line
                discard

              elif blocklineit == 2:    # handle arguments
                if line != "arguments---none":
                  all_argst = line.split("---")[1]
                  argumentsq = all_argst.split(",,")
                  #echo repr argumentsq
                  if jo_file_ops.getValueFromKey(argumentsq, "=", "linux_set_exe") == "1":
                    echo "linux_set_exe = true"
                    linux_setexe = true
                  if jo_file_ops.getValueFromKey(argumentsq, "=", "linux_use_sudo") == "1":
                    echo "linux_use_sudo = true"
                    linux_use_sudo = true

              elif blocklineit == 3:
                pathst = expandTilde(line)
                targetdirpathst = expandVars(pathst, varsepst, varsta)
              elif blocklineit == 4:
                pathst = expandTilde(line)
                sourcedirpathst = expandVars(pathst, varsepst, varsta)

              else:
                sourcefilest = line
                sourcefilepathst = joinPath(sourcedirpathst, sourcefilest)                
                echo "copying: " & sourcefilepathst & "   to:   " & targetdirpathst
                targetfilepathst = joinPath(targetdirpathst, sourcefilest)
                copyfile(sourcefilepathst,targetfilepathst)
                if linux_setexe:
                  var prependst:string = ""
                  if linux_use_sudo: prependst = "sudo "
                  discard execShellCmd(prependst & "chmod +x " & targetfilepathst)

            elif blockphasest == "EDIT FILE (ADD, DELETE, REPLACE LINES)":
              #echo "----edit-test----"
              #echo blocklineit
              if blocklineit != 4: 
                echo line

              if blocklineit == 1:  # comment-line
                discard
              elif blocklineit == 2:
                # handle arguments
                discard      
              elif blocklineit in 3..8:
                editfileprops[blocklineit - 3]=line
                if blocklineit == 4:
                  pathst = expandTilde(line)
                  pathst = expandVars(pathst, varsepst, varsta)
                  echo pathst
              elif blocklineit > 8:
                if line == "end-of-edit-block-here":
                  jo_file_ops.alterTextFile(
                        operationst = editfileprops[0],
                        targetfilepathst = pathst, 
                        line_orientationst = editfileprops[5], 
                        locating_stringst = editfileprops[4], 
                        occurit = parseint(editfileprops[3]),
                        directionst = editfileprops[2],
                        operationparamsq = ops_paramsq)
                  echo "\p" & editfileprops[0] & " performed on: " & pathst & "\p"

                else:
                  ops_paramsq.add(line)

            elif blockphasest == "EXECUTE SHELL-COMMANDS - IN ORDER":
              if blocklineit == 1:  # comment-line
                discard
              elif blocklineit == 2:
                # handle arguments
                discard
              else:
                echo "Running command: " & line
                discard execShellCmd(line)

          else:
            # then the former block is completed
            blockphasest = ""
            # set arguments to none:
            linux_setexe = false
            linux_use_sudo = false
      

      completionbo = true
      result = completionbo
      echo "\p===End of processing====\p"
      
    except IOError:
      echo "IO error!"
    
    except RangeDefect:
      echo "\p\p+++++++ search-config not found +++++++++++\p"
      echo "You have probably entered a search-config that could not be found. \p" &
          "Re-examine you search-config. \p" &
          "The problem originated probably in the above EDIT FILE-block"
      let errob = getCurrentException()
      echo "\p******* Technical error-information ******* \p" 
      echo "block-phase: " & blockphasest & "\p"
      echo "Last def-file-line read: " & lastline & "\p"
      echo repr(errob) & "\p****End exception****\p"

    
    except:
      let errob = getCurrentException()
      echo "\p******* Unanticipated error ******* \p" 
      echo "In block-phase: " & blockphasest & "\p"
      echo "Last def-file-line read: " & lastline & "\p"
      echo repr(errob) & "\p****End exception****\p"
        
    finally:
      close(myfile)
  else:
    echo "Could not open file! \pThe argument provided is not a valid file. "


proc processCommandLine() = 
  
  # Process the args appended after the calling executable
  # Currently only the install-def-file

  # possible format: "-ab -e:5 --foo --bar=20 file.txt"
  var
    optob = initOptParser()
    passit: int = 0

  while true:
    optob.next()
    var keyst = optob.key
    var valst = optob.val
    case optob.kind
    of cmdEnd:
      if passit == 0:
        echo "\pYou did not append an install-definition-file as argument!"
        echo "Please provide one."
        echo "Quiting..."
      break

    of cmdArgument:
      # echo "Argument: ", optob.key
      if installFromDef(keyst, true):
        echo "Installation or dry-run has been completed!"
      else:
        echo "Installation or dry-run ended prematurely!"

    of cmdShortOption, cmdLongOption:
      # not yet used
      if optob.val == "":
        echo "Option: ", optob.key
      else:
        echo "Option and value: ", optob.key, ", ", optob.val

    passit += 1


proc dummy() = 
  discard



# **********************************************************

if for_realbo:   # run the actual program
  if confirmInstall():
    processCommandLine()
else:   # perform tests
  var 
    varsta = initTable[string, string]()
    inputst = "i am #tes# the #stal# files"
  
  varsta["stal"] = "installable"
  varsta["tes"] = "testing"


  echo inputst
  echo expandVars(inputst, "#", varsta)


