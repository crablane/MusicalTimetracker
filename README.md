# Building a musical time-tracker in Stata 

## Introduction

I recently had a conversation about listening to music on your commute. My first - and to date only - car was a VW Polo with a sunroof, as old as I was, and whose bright turquoise color can only be described as a diversion from its pitch-black soul, which would soon drain my savings with an endless list of repairs. Reminiscing about the many happy memories with this car, from thick white clouds of steam rising from the bonnet mid-drive to scraping off ice from the inside at every red light because the heating stopped working, one memory stands out as the peak annoyence: Me, in the front seat, vibing to my favourite music, and arriving at my destination, but alas, _too early_. What do I do? Cut the song dead in the middle, when I was just preparing to get into an epic bass solo? Circle around until the song is over? Or awkwardly sit in my parked car, while I wait for the song to finish? 

A thought took shape in me: **Wouldn’t it be perfect, if you had a playlist that was customized to match your commute exactly?** 

Naturally, my first instinct was to ask ChatGPT, so as a test, I asked for some pairs of songs that together add up to 6 minutes. Surprisingly, ChatGPT’s results were fairly inaccurate, ranging between 4:53 (_Yesterday and Folsom Prison Blues_) and 7:36 (_What a Wonderful World_ and _I Will Survive_). Surely, I could do better?

In theory, this shouldn’t be too hard. Provided that I have a list of songs and their durations, I just have to get all possible combinations of songs, add up their times and see if there’s one that matches the time I was looking for. Now, even though I have greatly reduced my commute in the last year from more than two hours, to only thirty minutes, that still means I would need to add five to seven songs to fill that time. Let me get you in on the math with this: If I had the info on 98 songs how many groups of 5 songs can I make?

<img width="188" alt="formula_98_5" src="https://github.com/user-attachments/assets/f6f1dc84-2755-43d4-a87e-e384854f5499">

Yes, that is more than 9 _billion_ possibilities (technically, these are permutations with replacement). Among these are a lot of duplicates that you could weed out (more on that later), but even if you looked for unique "song-chains", that still leaves you with about 68 million possibilities (technically, combinations without replacement). Believe me, I tried everything. I tried different commands, I tried looping over every song, dropping the duplicates in every step, but all that I got were countless crashes of Stata. Defeated, I gave up. Clearly, this project exceeded my laptop’s computing power.

It wasn’t until a few weeks ago, when I started training for my first 5k run, that I thought about this project again. I follow a training scheme with intermittent walking and running, where the running intervals gradually increase every week, from 2 to 5 to 7 to 9 minutes, and so on. Now, _wouldn’t it be perfect if you had a playlist that matched that time exactly?_ 
And you can easily get to, say, 7 minutes with just two songs! Let's see how many ways there are to group two songs from 98:

<img width="175" alt="formula_98_2" src="https://github.com/user-attachments/assets/66d00973-fa93-495e-b148-97dc124c0b8a">

Less than ten thousand! A fraction of the number I was dealing with before! After all, in my disappointment about not being able to get the perfect thirty-minute playlist, I might have missed that there is a purpose in creating shorter playlists. So back to the desk!

## Data and Method
I used R’s _SpotifyR_ package to acquire a list of songs. _SpotifyR_ allows you to download song information like the title, duration and a host of Spotify’s own estimates about a song’s characteristics. You can download the information by artist, album or playlist. For this project, I will only need a songs’ title and duration. However, it is crucial that each song's name is unique, so you might want to download the title of the record a song has appeard on too, to tell two songs with the same name apart. I downloaded all songs by my favourite Band, Bombay Bicycle Club, and made sure each had a unique, identifiable, name. All further analyses are done in Stata18 BE.

The first and main challenge is to combine every song with every other song in the list. The command that I found most useful for this was _fillin_. It creates all possible interactions between two variables. Now, what I need here, are the interactions of a variable with itself, I therefore just copied the song-name variable and let _fillin_ create the interactions. The picture below shows you how the dataset looks before and after executing the _fillin_ command. 

**Before using fillin_**

<img width="503" alt="before_fillin" src="https://github.com/user-attachments/assets/d9707280-bbd6-41a1-8a88-12434e5947f9">

**After using fillin_**

<img width="503" alt="after_fillin_" src="https://github.com/user-attachments/assets/b794fefe-ad4b-471d-9293-fdf5652eb863">

You can see that the first song, _Always Like This_, has now been paired with every other song in the dataset. And the same thing happened for all the other 97 songs. Two problems become apparent. Firstly, _Always Like This_ has also been paired with itself (something a friend of mine has coined a _Carry Me_-Loop, when you’re stuck listening to your favourite song on repeat). Personally, I prefer to have only pairs of different songs, so I deleted all 98 cases where a song would have been on repeat. Secondly, if you look at line 1 and line 99 in the picture, you can see that there is not only the pair _Always Like This / Autumn_ but also _Autumn / Always Like This_. For my purpose, the order doesn’t make a pair distinctive, so it is sufficient to keep only one of those pairs. After deleting all the duplicates, we are left with 4,753 pairs of songs. 

Lastly, all I have to do, is to add the songs’ durations for each pair (using two merge_ commands), generate their sum, and with a simple list-command find pairs that match the time I am looking for. Since the duration is measured in milliseconds I have to convert the time I am looking for first by the formula _minutes x 60,000 x 1,000_. I furthermore recommend allowing at least one second (1,000 milliseconds) +/- that time, to ensure you will find enough results.

## Results
So, assuming I want to run for six minutes, which pairs of songs match that time?

<img width="447" alt="6 minutes songs" src="https://github.com/user-attachments/assets/cd094640-9790-49f4-abd2-87cccecd5b13">

There are already 25 pairs of songs to choose from. You might argue that some of those are wild concoctions, musically, like combining energetic _Overdone_ with an acoustic guitar based _Fairytale Lullaby_. And I agree! You could handpick songs that you would like to keep (or drop) before generating the interactions to avoid this. However, you would also decrease the number of possible pairs of songs with this. If you allowed for an additional second +/- your desired time, the number of possible pairs doubles to triples, depending on the specific interval. Here’s an overview of how many suggestions I got for each time-interval:

<img width="600" alt="Number of Songs per Interval" src="https://github.com/user-attachments/assets/ddd78e3c-acba-43b7-bce8-e7cae29d66f8">


After a bit of trial and error, I found that it is even possible to extend this project to triples of songs, or technically speaking: three-way-interactions. This generates 152,096 triples of songs and extends the range of time-intervals to as much as 17 minutes. However, anything above a three-way interaction only resulted in crashes of the program.


<img width="600" alt="Triples" src="https://github.com/user-attachments/assets/b4a38820-363b-4917-ad9c-29b8e45c826e">

As happy as I am about the abundance of song-triples to choose from, I clearly don’t have the time to look at the 1,213 suggestions for an 11-minute time interval. In this case it might indeed be reasonable to reduce the number of songs. You could for instance download Spotify’s energy-estimate for each song and only choose the 25% of songs with the highest energy for your run. However, previous projects have taught me not to trust Spotify’s estimates blindly, so I suggest you carefully examine which songs would be deleted in such a process and whether you agree with it.

To me, the beauty of this project lies in the fact that the code is independent of any artist. You can download your own playlist of tracks that you like to run to, or adapt this to whatever your favourite artist is and generate your own playlists according to your running intervals or commute. 

## Conclusion
I outdid ChatGPT. Let me have my moment here. 
