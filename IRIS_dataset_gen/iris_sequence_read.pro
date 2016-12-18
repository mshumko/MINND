; Created by: Roy Smart, Nicholas Bonham
; Date: 11-08-2016
;Purpose: This function reads and unzips IRIS Si IV data and copies it to a specified directory.
function iris_sequence_read, dir, filename

  gz = '.gz'                                                      ; Specify filetype
  directory = '/disk/data/roysmart/MINND/'                        ; Specify directory to copy data to
  FILE_COPY, dir+filename+gz, directory+filename+gz, /OVERWRITE   ; Copy IRIS file to our directory
  FILE_GUNZIP, directory+filename+gz, /delete                     ; Unzip IRIS file and delete .gz file
  d = iris_load(directory+filename)                               ; Use iris_load procedure to load data                                                  ; Show all lines for the dataset 
  d->show_lines
  iwin=d->getwindx(1403)
  print, iwin
  lambda=d->getlam(iwin)
  near = Min(Abs(lambda - 1402.85), core_ind)
  ;print, core_ind
  data=d->getvar(iwin, /load)

	cal = d->getcal()
	help, cal
	print, cal

  FILE_DELETE, directory+filename
  
  help,data

;  img[core_ind,*]=val
  return, data

 end