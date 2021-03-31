# Online Presence Text Analysis

### Demo
A demo of this app is available [here.](https://msyphus.shinyapps.io/text-analysis/)

### General
This is a text analysis of my resume and LinkedIn articles to evaluate my professional online presence.  My resume was imported from a file and the text of my LinkedIn articles was scraped from the web.

The dashboard has three tabs and a link to this readme file.  The "Overall Sentiment" tab shows the combined results of the text from my resume and all LinkedIn articles.  The "Resume" tab shows the results of just the text from my resume.  The "Articles" tab shows the results of only the text from my LinkedIn articles.

![Dashboard Screenshot](/screenshot.PNG)

The plot on the top left shows the 10 most occurring words, in order, and how many times the words occurred.

The plot on the top right is a word cloud that artistically visualizes the most frequently occurring words.  The larger the word, the more frequently it occurs.

The plot on the bottom left shows the proportion of emotional sentiments that occurred.  Words were classified as having a sentiment portraying anger, anticipation, disgust, fear, joy, negativity, positivity, sadness, surprise, or trust.  The proportion of each category is plotted (for example, 27% of all words were positive, 3% of all words had a feeling of anger, etc.).

The plot on the bottom middle shows the sentiment score of the top 10 words.  These 10 words are not the same as the Top 10 from the top row because not every word has a sentiment score attached to it according to the Bing method of sentiment ranking.  Thus, this Top 10 list shows the 10 most occurring words with a sentiment score.  Positive numbers indicate a positive sentiment.  The larger the number, the more positive the sentiment.  Negative numbers indicate a negative sentiment, with the more negative numbers having a stronger negative sentiment.

On the bottom right is an accumulative sentiment score.  This is just the sum of all word scores (positives + neutrals + negatives).  If the number is positive, it indicates that the sum of the positive scores is greater than the sum of the negative scores.  The more positive this number is, the more positive the overall sentiment is.

Please note that just because a word is classified/ranked as negative does not mean that the tone of my wording was negative.  For example, the following line of text ranked negatively:

```
"and project management. Previously led diverse projects with cross-functional teams spanning"
```

When looking at each word individually: 1 word was associated with anger, 1 with fear, 1 with sadness, and 2 were negative.  This outweighed the words that scored for "positive" and "trust".  Who knew project management was so negative?!

Also note that negative words like, "risk" and "waste" are actually a good thing.  I address how to deal with those topics in my articles! 

# Technology Used
This app was made using the following technologies:
* R
* RStudio
* CSS
* shinydashboards.io

R packages included:
* shiny
* shinydashboard
* tm
* wordcloud
* syuzhet
* ggplot2
* rvest
* magrittr
* RColorBrewer
* tidytext
* dplyr