/*------------------------------------------------------------------------------
			
Title:			Computing a musical time-tracker
Author:			Carlotta Brüning
Last updated:	31.07.2024

--------------------------------------------------------------------------------	

							Introduction

In this do-file I use the fillin_-command to generate all possible paris of 
songs. After cleaning the data for duplicates, I generate the summed duration 
of each pair, enabling the user to find combinations of songs that match an 
(almost) exact time.

A list of songs can be retracted using the SpotifyR-toolkit in R. It allows 
to extract every song of a specific album, artist or playlist.
 
For this Do-File, I use a dataset that has already been cleaned and contains no 
duplicates. It contains the variables 'name', which is the title of each songs 
and 'duration_ms' which is the song's duration in milliseconds. 
The list must be exported as an excel-file and stored on the 
users harddrive.
------------------------------------------------------------------------------*/

* Generating a global for the data-folder
global data = "C:\Users\Carlotta\Desktop\BBC-Emotion\data"

/* Opening the list of all songs, in this example called 'fullset', alternatively 
   use the import-command to import the list of songs from excel or R
*/
use $data/fullset.dta  

* Sorting the songs alphabetically by their name
sort name

* Dropping the information on song duration, it will be merged later
drop duration_ms

/*-------------------------------------------------------------------------------

				Generating all possible pairs of songs
							using fillin_
							
fillin_ generates all possible interactions of two variables. In this case, as 
we only have one variable with all song names, what we want is to interact the 
variable with itself. Thus the variable needs to be copied in a first step.

-------------------------------------------------------------------------------*/	
* copying the name-variable	
gen v2 = name

* Generating all interactions between name and v2 using the fillin
fillin name v2

* Checking how many pairs have been generated // 9.604
des 

/*-------------------------------------------------------------------------------

							Cleaning the data

-------------------------------------------------------------------------------*/	
* Dropping all pairs that contain of the same song twice
drop if name == v2

* Checking how many cases are left // 9.506
des

/* There are a lot of duplicates in the list, as for example there is a pair of 
"Always Like This" and "Beg" but also "Beg" and "Always Like this" and so on.
For my purpose they are the same and thus only the first occurance of a pair 
should remain in the dataset. 

The following commands create two new variables, first and second. First takes 
the value of that song in a pair of name and v2 that comes first alphabetically, 
second takes the value of the song that comes second alphabetically. Then, both
are combined into a new string variable. 

Thus the pair Always Like This/Beg and Beg/Always Like This both become the string
"Always Like this Beg", now we can sort the dataset after the string, tag and 
keep only the first occurance of a string.

Download the rowsort command directly from the Stata Journal:
SJ9-1 pr0046.  Row rank and sort a set of variables
*/

*Generating variables first, second and string as outlined above
rowsort name v2, gen(first second)
gen string = first + second

* Sorting by the new string-variable
sort string

* Tagging every first occurance of a pair 
egen tag = tag(string)

* Keeping only the first occurance of each pair
keep if tag ==1

* Checking how many cases remain // 4.753
des

* Sorting the dataset alphabetically after the song title
sort name v2

* Dropping auxilliary variables
drop first second tag string _fillin

*Saving this dataset under a new name
save $data/run.dta, replace 

/*-------------------------------------------------------------------------------

					Adding the song duration and computing 
					the summed duration of each pair

-------------------------------------------------------------------------------*/	

* Merging the song duration of the first song from the original dataset
merge m:1 name using $data/fullset.dta, keepusing(duration_ms) keep(3) nogen

* Renaming the variable v2 to "name" so that it can be used as a matching variable
rename name v1
rename duration_ms dur_1
rename v2 name

* Merging the song duration of the second song from the original dataset
merge m:1 name using $data/fullset.dta, keepusing(duration_ms) keep(3) nogen

*Sorting the dataset alphabetically by the first song's name
sort v1

* Renaming name to v2 and duration_ms to dur_2 for clarity
rename name v2 
rename duration_ms dur_2

* Generating summed duration of each pair
gen sum_dur = dur_1 + dur_2



/*-------------------------------------------------------------------------------

					Finding pairs of songs that match a 
					desired time interval

As the song duration is stored in milliseconds your desired time interval has 
to be converted into milliseconds first, using the formula

 ms = m × 60 × 1000
 
 Adapt the code below to your desired time

-------------------------------------------------------------------------------*/	
* Simple converter, in this example 7 minutes to milliseconds
disp 7*60*1000

* Simple converter: 7 minutes to milliseconds with +/- second range
disp (7*60*1000)+1000
disp (7*60*1000)-1000

* Find pairs of songs that are exactly seven minutes long
list v1 v2 if sum_dur == 420000

/* If no pair is returned, consider loosening your restrictions and allowing 
   for a range for seconds +/- your desired time, in this example: 1 second
*/
list v1 v2 if sum_dur >= 419000 & sum_dur <=421000

