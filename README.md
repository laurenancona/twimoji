# twimoji
a mostly-for-fun exercise in analyzing location-enabled tweets with emoji in Philadelphia

![alltweets.gif]

## Data
#### Collection
This project uses the simplest method to aggregate tweets based on simple parameters:
- This IFTTT job to collect tweets _with location attributes_ in a given radius around Philadelphia:

<a href="https://ifttt.com/view_embed_recipe/305098-collect-tweets-with-location" target = "_blank" class="embed_recipe embed_recipe-l_28" id= "embed_recipe-305098"><img src= '/web/images/ifttt.png' alt="IFTTT Recipe: Collect Tweets with Location connects twitter to google-drive" width="370px" style="max-width:100%"/></a>
- Saves to a Google Spreadsheet, when full begins new sheet

#### Cleanup & Reshape
- Tokenize words from tweet text for possible later NLP
- Extract latitude & longitude from link to map field string

#### Analysis
- Emoji lookup table
- Map unicode and bytes from table
- Calculate word frequency
- Only count 1st occurence of an emoji per tweet

## Visualization
#### Geocoding
- CartoDB

#### Location Filtering
- Uses city boundaries file (link)
- Add geodata for additional demographic analysis:
  - Census tracts or Block segments
  - Zip codes?

#### Time-based animation
- Torque.js


