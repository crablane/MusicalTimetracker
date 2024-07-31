# Building a musical time-tracker in Stata 

## Introduction

I recently had a conversation about listening to music on your commute. Even though I once had my own car—a VW Polo with a sunroof, as old as I was, and whose bright turquoise color was an attempt to divert you from its pitch-black soul, that would soon drain my savings, practically falling apart underneath me,... where was I? I had a car, but the image that this conversation evoked was one of me sitting in my older sister’s car, driving to school and listening to a mixtape that I had recorded for her. To me, nothing kills the vibe quite like arriving at your destination before the song is over, forcing you to either cut the song dead in the middle of the chorus or awkwardly sit in your parked car while you wait for the song to finish. A thought took shape in me: Wouldn’t it be perfect, if you had a playlist that is customized to match your commute exactly? 

Naturally, my first instinct was to ask ChatGPT, so as a test, I asked for some pairs of songs that together add up to 6 minutes. Surprisingly, ChatGPT’s results were fairly inaccurate, ranging between 4:53 (_Yesterday and Folsom Prison Blues_) and 7:36 (_What a Wonderful World_ and _I Will Survive_). Surely, I could do better?

In theory, this shouldn’t be too hard. Provided that I have a list of songs and their duration, I just have to get all possible combinations of songs, add up their times and see if there’s one that matches the time I was looking for. Now, even though I have greatly reduced my commute in the last year from more than two hours, to only thirty minutes, that still means I would need to add five to seven songs to fill that time. Let me get you in on the math with this: If I had the info on 98 songs how many groups of 5 songs can I make?

<img width="188" alt="formula_98_5" src="https://github.com/user-attachments/assets/f6f1dc84-2755-43d4-a87e-e384854f5499">

Yes, that is more than 9 _billion_ possibilities. Among these are a lot of duplicates that you could weed out (more on that later), but even if you looked for unique song-chains, that still leaves you with about 68 million possibilities (Technically: Combinations without replacement). Believe me, I tried everything. I tried different commands, I tried looping over every song, dropping the duplicates in every step, but all that I got were countless crashes of Stata. Defeated, I gave up. Clearly, this project exceeded my laptop’s computing power.

It wasn’t until a few weeks ago, when I started training for my first 5k run that I thought about this project again. I follow a training-scheme with intermittent walking and running, where the running intervals gradually increase every week, from 2 to 5 to 7 to 9 minutes, and so on. Now, wouldn’t it be perfect if you had a playlist, that matched that time exactly? And you can easily get to, say, 7 minutes with just two songs! And how many ways are there to group two songs out of 98?

<img width="175" alt="formula_98_2" src="https://github.com/user-attachments/assets/66d00973-fa93-495e-b148-97dc124c0b8a">

Less than ten thousand! A fraction of the number I was dealing with before! After all, in my disappointment about not being able to get the perfect thirty minute playlist, I might have missed another use-case! So back to the desk!

## Data and Method
I used R’s _SpotifyR_ package to acquire a list of songs. _SpotifyR_ allows you to download song information like the title, duration, bpm and a host of Spotify’s own estimates about a song’s charachteristics. You can download the information by artist, album or playlist. For this project, you will only need a songs’ title and duration. However, it is crucial that each songs name is unique, so you might want to download the title of the record a song has appeard on too, to tell two songs with the same name apart. I downloaded all songs by my favourite Band, Bombay Bicycle Club, and made sure each had a unique, identifiable, name. All further analyses are done in Stata18 BE.

The first challenge is to to combine every song with every other song in the list. The command that I found most useful for this was _fillin_. It creates all possible interactions between two variables. Now, what I need here, are the interactions of a variable with itself, I therefore just copied the song-name variable and let _fillin_ create the interactions. The picture below shows you how the dataset looks before and after the execution of the _fillin_ command. 

**Before using fillin_**

<img width="503" alt="before_fillin" src="https://github.com/user-attachments/assets/d9707280-bbd6-41a1-8a88-12434e5947f9">

**After using fillin_**

<img width="503" alt="after_fillin_" src="https://github.com/user-attachments/assets/b794fefe-ad4b-471d-9293-fdf5652eb863">

You can see that the first song, _Always Like This_, has now been paired with every other song in the dataset. And the same thing happened for all the other 97 songs. Now two problems become evident. Firstly, _Always Like This_ has also been paired with itself (something a friend of mine has coined a _Carry Me_-Loop, when you’re stuck listening to your favourite song on repeat). Personally, I prefer to have only pairs of different songs, so I deleted all 98 cases in which a song would have been on repeat. Secondly, if you look at line 1 and line 99 in the picture, you can see that there is not only the pair _Always Like This / Autumn_ but also _Autumn / Always Like This_. For my purpose, the order doesn’t make a combination distinctive, so it is sufficient to keep only one of those pairs. After deleting all the duplicates, we are left with 4,753 pairs of songs. 

Lastly, all we have to do, is to add the songs’ duration for each pair (using two merge_ commands), generate their sum, and with a simple list-command find pairs that match the time we were looking for. Since the duration is measured in milliseconds you have to convert the time you are looking for first by the formula Minute x 60,000 x 1,000. I furthermore recommend allowing at least one second (1,000 milliseconds) +/- that time, to ensure you will find enough results.

## Results
So, assuming I want to run for six minutes, which pairs of songs match that time?

<img width="447" alt="6 minutes songs" src="https://github.com/user-attachments/assets/cd094640-9790-49f4-abd2-87cccecd5b13">

That’s already 25 pairs of songs to choose from. You might intervene that some of those are wild concoctions, musically, like combining energtic Overdone with a sweet acoustic guitar based Fairytale Lullaby. And I agree! You could handpick songs that you would like to keep (or drop) in step one to avoid this, but you would also decrease the number of possible pairs of songs with this. If you allowed for an additional second +/- your desired time, the number of possible pairs doubles to triples, depening on the specific interval. Here’s an overview of how many suggestions I got for each time-interval:

![Number of Songs per Interval](https://github.com/user-attachments/assets/f5e93b88-678e-4056-9aa6-6233d2531b43)

Now, it is even possible to extend this project to triples of songs, or technically speaking: three-way-interactions. This generates 152,096 triples of songs and extends the range of time-intervals to as much as 17 minutes. 

![triples](https://github.com/user-attachments/assets/557300af-3372-460f-8ea1-eda18f98b077)

As happy as I am about the abundance of song-triples to choose from, I clearly don’t have the time to look at 1,213 suggestion for an 11 Minute time interval. In this case it might be reasonable to reduce the number of songs in step 1. You could for example download Spotify’s energy-estimate for each song and only choose the 25% of songs with the highest energy for your run. However, previous projects have taught me not to trust Spotify’s estimates blindly, so I suggest you inspect exactly which songs would be deleted in such a process and whether you agree with it.

To me, the beauty of this project lies in the fact, that the code is independent of any artist. You can download your own playlist of tracks to run to, or adapt this to whatever your favourite artist is. 

## Conclusion
I outdid ChatGPT. Let me have my moment here. 
